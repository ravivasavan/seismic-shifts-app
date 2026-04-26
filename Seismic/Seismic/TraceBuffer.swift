import Foundation
import Combine

@MainActor
final class TraceBuffer: ObservableObject {
    @Published private(set) var samples: [Float] = []

    private var accumulator: [Float] = []
    private let samplesPerSecond = 10
    private let maxSamples: Int

    init(width: Int) {
        self.maxSamples = width
    }

    func ingest(_ value: Float) {
        accumulator.append(value)
        guard accumulator.count >= samplesPerSecond else { return }

        let avg = accumulator.reduce(0, +) / Float(accumulator.count)
        accumulator.removeAll(keepingCapacity: true)

        samples.append(avg)
        if samples.count > maxSamples {
            samples.removeFirst(samples.count - maxSamples)
        }
    }
}
