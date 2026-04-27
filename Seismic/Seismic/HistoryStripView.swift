import SwiftUI

/// The full-session compressed strip at the bottom of the screen,
/// with an orange viewport rectangle marking the active window.
///
/// The data line always spans the full strip width: each pixel
/// column maps to a proportional slice of the entire sample array,
/// regardless of whether the session is shorter or longer than the
/// strip's pixel count. The viewport rectangle's right edge is
/// always "now" (= the right edge of the strip), so the line and
/// the viewport's right edge always meet there.
struct HistoryStripView: View {
    let samples: [Float]
    let sessionStartedAt: Date
    let viewportEndTime: Date
    let viewportWindowSeconds: TimeInterval

    var body: some View {
        Canvas { context, size in
            let centerY = size.height / 2
            let amp = size.height * 0.4

            let n = samples.count
            if n > 1 {
                let columns = min(n, max(2, Int(size.width)))
                var path = Path()
                for col in 0..<columns {
                    let s = (col * n) / columns
                    let endRaw = ((col + 1) * n) / columns
                    let e = max(s + 1, min(n, endRaw))
                    let slice = samples[s..<e]
                    let avg = slice.reduce(0, +) / Float(slice.count)
                    let normalized = max(0, min(1, avg / 120))

                    let xFrac = columns > 1 ? Double(col) / Double(columns - 1) : 0.5
                    let x = size.width * CGFloat(xFrac)
                    let y = centerY - CGFloat(normalized) * amp

                    if col == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(path, with: .color(Theme.inkQuiet), lineWidth: 0.7)
            }

            // Viewport rectangle. Right edge anchors at "now"; width
            // shrinks the longer the session runs vs. the active
            // window. Clamped to full width when the session is
            // shorter than one window.
            let totalSeconds = viewportEndTime.timeIntervalSince(sessionStartedAt)
            guard totalSeconds > 0 else { return }
            let viewportFraction = min(1.0, viewportWindowSeconds / totalSeconds)
            let viewportEndFraction = 1.0
            let viewportStartFraction = max(0.0, viewportEndFraction - viewportFraction)

            let rect = CGRect(
                x: size.width * CGFloat(viewportStartFraction),
                y: 2,
                width: max(3, size.width * CGFloat(viewportFraction)),
                height: size.height - 4
            )

            context.fill(Path(rect), with: .color(Theme.viewportFill))
            context.stroke(Path(rect), with: .color(Theme.viewport), lineWidth: 1.5)
        }
    }
}
