import SwiftUI

/// The main scrolling trace. Renders the slice of `samples` that
/// falls inside the current `windowSeconds` ending at `endTime`.
/// `samples` are dB SPL at `SessionStore.sampleRate` Hz, with index 0
/// at `sessionStartedAt`. Re-rendered at display refresh by the
/// enclosing `TimelineView(.animation)`.
///
/// The line between sample points is drawn as a Catmull-Rom curve so
/// the trace reads as a continuous needle stroke rather than as
/// connected line segments. The data itself is untouched.
///
/// A small red dot is drawn at the most recent sample so the cursor
/// position reads as a pen tip.
struct ActiveTraceView: View {
    let samples: [Float]
    let windowSeconds: TimeInterval
    let endTime: Date
    let sessionStartedAt: Date
    /// Where the dB grid lines begin (right edge of the y-axis
    /// ticks, in canvas coordinates). Grid lines run from here to
    /// the canvas right edge.
    let gridStartX: CGFloat

    private static let penDotSize: CGFloat = 8
    /// Inset from the right edge so the trace's "now" tip and the
    /// pen-tip dot both stay fully visible — the dot is no longer
    /// clipped against the right boundary of the canvas.
    private static let rightInset: CGFloat = 10

    var body: some View {
        Canvas { context, size in
            // Major dB grid lines drawn first so they sit beneath the
            // trace. Spans from the y-axis ticks' right edge to the
            // trace canvas's right edge.
            for v in stride(from: 0.0, through: 120.0, by: 20.0) {
                let y = size.height * (1 - CGFloat(v / 120))
                var grid = Path()
                grid.move(to: CGPoint(x: gridStartX, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(grid, with: .color(Theme.inkFaint), lineWidth: 0.5)
            }

            guard samples.count > 1 else { return }
            let rate = SessionStore.sampleRate

            let secondsFromStart = endTime.timeIntervalSince(sessionStartedAt)
            let windowStart = secondsFromStart - windowSeconds

            let startIdx = max(0, Int((windowStart * rate).rounded(.down)))
            let endIdx = min(samples.count, Int((secondsFromStart * rate).rounded(.up)) + 1)
            guard startIdx < endIdx else { return }

            let usableWidth = max(1, size.width - Self.rightInset)

            var points: [CGPoint] = []
            points.reserveCapacity(endIdx - startIdx)
            for i in startIdx..<endIdx {
                let secondsFromWindowStart = Double(i) / rate - windowStart
                let frac = secondsFromWindowStart / windowSeconds
                let x = usableWidth * CGFloat(frac)
                let normalized = max(0, min(1, samples[i] / 120))
                let y = size.height * (1 - CGFloat(normalized))
                points.append(CGPoint(x: x, y: y))
            }

            context.stroke(
                .smoothCurve(through: points),
                with: .color(Theme.ink),
                lineWidth: 1.0
            )

            if let last = points.last {
                let s = Self.penDotSize
                let dotRect = CGRect(
                    x: last.x - s / 2,
                    y: last.y - s / 2,
                    width: s,
                    height: s
                )
                context.fill(Path(ellipseIn: dotRect), with: .color(Theme.pen))
            }
        }
    }
}
