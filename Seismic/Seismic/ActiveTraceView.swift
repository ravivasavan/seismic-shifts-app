import SwiftUI

/// The main scrolling trace. Renders the slice of `samples` that
/// falls inside the current `windowSeconds` ending at `endTime`.
/// `samples` are dB SPL at `SessionStore.sampleRate` Hz, with index 0
/// at `sessionStartedAt`. Re-rendered at display refresh by the
/// enclosing `TimelineView(.animation)`.
///
/// A small red dot is drawn at the most recent sample so the cursor
/// position reads as a pen tip — there's a visible point being
/// inked, not just a line.
struct ActiveTraceView: View {
    let samples: [Float]
    let windowSeconds: TimeInterval
    let endTime: Date
    let sessionStartedAt: Date

    private static let penDotSize: CGFloat = 6

    var body: some View {
        Canvas { context, size in
            guard samples.count > 1 else { return }
            let rate = SessionStore.sampleRate

            let secondsFromStart = endTime.timeIntervalSince(sessionStartedAt)
            let windowStart = secondsFromStart - windowSeconds

            let startIdx = max(0, Int((windowStart * rate).rounded(.down)))
            let endIdx = min(samples.count, Int((secondsFromStart * rate).rounded(.up)) + 1)
            guard startIdx < endIdx else { return }

            var path = Path()
            var lastPoint = CGPoint.zero
            for i in startIdx..<endIdx {
                let secondsFromWindowStart = Double(i) / rate - windowStart
                let frac = secondsFromWindowStart / windowSeconds
                let x = size.width * CGFloat(frac)
                let normalized = max(0, min(1, samples[i] / 120))
                let y = size.height * (1 - CGFloat(normalized))
                let pt = CGPoint(x: x, y: y)
                if i == startIdx {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
                lastPoint = pt
            }
            context.stroke(path, with: .color(Theme.ink), lineWidth: 1.0)

            // Pen-tip cursor: small red dot at the most recent sample.
            let s = Self.penDotSize
            let dotRect = CGRect(
                x: lastPoint.x - s / 2,
                y: lastPoint.y - s / 2,
                width: s,
                height: s
            )
            context.fill(Path(ellipseIn: dotRect), with: .color(Theme.pen))
        }
    }
}
