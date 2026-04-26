import AVFoundation
import Accelerate
import Combine

/// Captures the mic, applies A-weighting + RMS, converts to dB SPL,
/// and pushes ~10 readings per second to the `SessionStore`.
///
/// Phase-4 hardening:
/// - Listens for `AVAudioSession.interruptionNotification` to restart
///   after Siri / phone calls / other system audio interruptions.
/// - Listens for route-change notifications and re-establishes the
///   tap if the input device changes.
/// - Runs a 5-second watchdog: if the audio thread stalls (no
///   buffers seen), tears down and restarts the engine.
@MainActor
final class AudioMonitor: ObservableObject {
    /// Default offset assuming 0 dB FS ≈ 94 dB SPL on the iPad's
    /// built-in mic at default input gain. Calibrate against a sound
    /// level meter to tighten this — see ui-roadmap.md.
    static let dbSPLOffset: Float = 94.0

    private let engine = AVAudioEngine()
    private var aWeighting: AWeightingFilter?
    private weak var store: SessionStore?

    private var lastBufferTime: Date = Date()
    private var watchdogTimer: Timer?
    private var notificationTokens: [NSObjectProtocol] = []

    init(store: SessionStore) {
        self.store = store
    }

    func start() throws {
#if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [])
        try session.setActive(true)
#endif

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate

        aWeighting = AWeightingFilter(sampleRate: sampleRate)

        input.installTap(onBus: 0, bufferSize: 4800, format: format) { [weak self] buffer, _ in
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameCount = Int(buffer.frameLength)
            guard frameCount > 0 else { return }

            self?.aWeighting?.apply(to: channelData, count: frameCount)

            var rms: Float = 0
            vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameCount))

            let dbFS = 20 * log10(max(rms, 1e-7))
            let dbSPL = dbFS + Self.dbSPLOffset
            let clamped = max(0, min(120, dbSPL))

            Task { @MainActor [weak self] in
                self?.lastBufferTime = Date()
                self?.store?.ingest(clamped)
            }
        }

        try engine.start()
        installResilience()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        watchdogTimer?.invalidate()
        watchdogTimer = nil
        for token in notificationTokens {
            NotificationCenter.default.removeObserver(token)
        }
        notificationTokens.removeAll()
    }

#if os(iOS)
    private func installResilience() {
        let center = NotificationCenter.default

        let interruption = center.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let info = note.userInfo,
                  let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            if type == .ended {
                Task { @MainActor [weak self] in
                    try? self?.restart()
                }
            }
        }

        let routeChange = center.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                try? self?.restart()
            }
        }

        notificationTokens = [interruption, routeChange]

        watchdogTimer?.invalidate()
        watchdogTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if Date().timeIntervalSince(self.lastBufferTime) > 5.0 {
                    try? self.restart()
                }
            }
        }
    }
#else
    private func installResilience() { }
#endif

    private func restart() throws {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        try start()
    }
}
