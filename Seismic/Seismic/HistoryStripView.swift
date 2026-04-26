import SwiftUI

/// The full-session compressed strip at the bottom of the screen,
/// with an orange viewport rectangle marking the active window.
struct HistoryStripView: View {
    let samples: [Float]
    let sessionStartedAt: Date
    let viewportEndTime: Date
    let viewportWindowSeconds: TimeInterval

    var body: some View {
        Canvas { context, size in
            let centerY = size.height / 2
            let amp = size.height * 0.4

            // Compressed trace
            if samples.count > 1 {
                let bucketCount = max(1, Int(size.width))
                let perBucket = max(1, samples.count / bucketCount)
                var path = Path()
                var first = true

                var col = 0
                while col * perBucket < samples.count && col < bucketCount {
                    let s = col * perBucket
                    let e = min(s + perBucket, samples.count)
                    let slice = samples[s..<e]
                    let avg = slice.reduce(0, +) / Float(slice.count)
                    let n = max(0, min(1, avg / 120))
                    let x = CGFloat(col) * (size.width / CGFloat(bucketCount))
                    let y = centerY - CGFloat(n) * amp
                    if first {
                        path.move(to: CGPoint(x: x, y: y))
                        first = false
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    col += 1
                }
                context.stroke(path, with: .color(Theme.inkQuiet), lineWidth: 0.7)
            }

            // Viewport rectangle
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
