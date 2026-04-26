import AVFoundation
import Accelerate
import Combine

@MainActor
final class AudioMonitor: ObservableObject {
    @Published var currentEnergy: Float = 0.0

    private let engine = AVAudioEngine()

    func start() throws {
#if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [])
        try session.setActive(true)
#endif

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(onBus: 0, bufferSize: 4800, format: format) { [weak self] buffer, _ in
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameCount = Int(buffer.frameLength)

            var rms: Float = 0
            vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameCount))

            let db = 20 * log10(max(rms, 0.000001))
            let normalised = max(0, min(1, (db + 60) / 40))

            Task { @MainActor [weak self] in
                guard let self else { return }
                self.currentEnergy = self.currentEnergy * 0.9 + normalised * 0.1
            }
        }

        try engine.start()
    }
}
