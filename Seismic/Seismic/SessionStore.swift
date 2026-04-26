import Foundation
import Combine

/// Owns the visible-data side of a session: per-second dB SPL values
/// from launch until termination. Replaces the Phase-1 `TraceBuffer`.
/// All views (active trace, history strip) read from this single store.
@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var samples: [Float] = []

    let startedAt: Date

    private var accumulator: [Float] = []
    private let samplesPerSecond = 10
    private var smoothedDb: Float = 50  // mid-range start so the trace doesn't slam

    private let recorder: TraceRecorder?

    init(recorder: TraceRecorder? = nil, startedAt: Date = Date()) {
        self.recorder = recorder
        self.startedAt = startedAt
    }

    /// Audio thread feeds dB SPL readings (~10/s). One visual sample
    /// is emitted per second after light EMA smoothing.
    func ingest(_ value: Float) {
        accumulator.append(value)
        guard accumulator.count >= samplesPerSecond else { return }

        let avg = accumulator.reduce(0, +) / Float(accumulator.count)
        accumulator.removeAll(keepingCapacity: true)

        smoothedDb = smoothedDb * 0.85 + avg * 0.15

        samples.append(smoothedDb)
        recorder?.record(value: smoothedDb)
    }

    func close() {
        recorder?.close()
    }
}
