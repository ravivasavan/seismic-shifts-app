import Foundation
import Combine

/// Owns the visible-data side of a session: dB SPL samples at
/// `sampleRate` Hz from launch until termination. Replaces the
/// Phase-1 `TraceBuffer`. All views (active trace, history strip)
/// read from this single store.
@MainActor
final class SessionStore: ObservableObject {
    /// Visual sample rate. The audio tap fires every 100 ms (10 Hz),
    /// and each tap becomes one sample here — no per-second
    /// down-averaging — so the trace can scroll smoothly at display
    /// refresh rather than stepping once per second.
    static let sampleRate: Double = 10

    @Published private(set) var samples: [Float] = []

    let startedAt: Date

    private var smoothedDb: Float = 50

    private var diskAccumulator: [Float] = []
    private static let samplesPerDiskRow = 10  // 1 Hz on disk

    private let recorder: TraceRecorder?

    init(recorder: TraceRecorder? = nil, startedAt: Date = Date()) {
        self.recorder = recorder
        self.startedAt = startedAt
    }

    /// Audio thread feeds dB SPL readings ~10 / s. Each one becomes a
    /// visual sample (after light EMA), and every tenth one drives a
    /// CSV row so the on-disk archive stays at 1 Hz.
    func ingest(_ value: Float) {
        // EMA: 0.6 / 0.4 at 10 Hz gives ~0.25 s time constant — fast
        // enough to track claps and door slams without jitter on
        // ambient room noise.
        smoothedDb = smoothedDb * 0.6 + value * 0.4

        samples.append(smoothedDb)

        diskAccumulator.append(smoothedDb)
        if diskAccumulator.count >= Self.samplesPerDiskRow {
            let avg = diskAccumulator.reduce(0, +) / Float(diskAccumulator.count)
            diskAccumulator.removeAll(keepingCapacity: true)
            recorder?.record(value: avg)
        }
    }

    func close() {
        recorder?.close()
    }
}
