import SwiftUI

/// The main scrolling trace. Renders the slice of `samples` that
/// falls inside the current `windowSeconds` ending at `endTime`.
/// `samples` are dB SPL values at 1 Hz starting at `sessionStartedAt`.
struct ActiveTraceView: View {
    let samples: [Float]
    let windowSeconds: TimeInterval
    let endTime: Date
    let sessionStartedAt: Date

    var body: some View {
        Canvas { context, size in
            guard samples.count > 1 else { return }

            let secondsFromStart = endTime.timeIntervalSince(sessionStartedAt)
            let windowStart = secondsFromStart - windowSeconds

            let startIdx = max(0, Int(windowStart.rounded(.down)))
            let endIdx = min(samples.count, Int(secondsFromStart.rounded(.up)) + 1)
            guard startIdx < endIdx else { return }

            var path = Path()
            for i in startIdx..<endIdx {
                let secondsFromWindowStart = Double(i) - windowStart
                let frac = secondsFromWindowStart / windowSeconds
                let x = size.width * CGFloat(frac)
                let normalized = max(0, min(1, samples[i] / 120))
                let y = size.height * (1 - CGFloat(normalized))
                if i == startIdx {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            context.stroke(path, with: .color(Theme.ink), lineWidth: 1.0)
        }
    }
}
