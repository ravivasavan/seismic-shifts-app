import SwiftUI

/// The compressed timeline strip at the bottom of the screen, showing
/// the **latest `stripWindowSeconds` of the session** rather than the
/// whole thing. Default 5 minutes. The orange viewport rectangle marks
/// where the active trace's window sits within those 5 minutes, and a
/// small solid-orange chip (above the strip, centred on the viewport)
/// labels the active window's duration as `HH:MM:SS`.
struct HistoryStripView: View {
    let samples: [Float]
    let sampleRate: Double
    let sessionStartedAt: Date
    let viewportEndTime: Date
    let viewportWindowSeconds: TimeInterval
    let stripWindowSeconds: TimeInterval

    var body: some View {
        GeometryReader { geo in
            let elapsed = max(0.001, viewportEndTime.timeIntervalSince(sessionStartedAt))
            let stripDuration = max(0.001, min(stripWindowSeconds, elapsed))
            let viewportFraction = min(1.0, viewportWindowSeconds / stripDuration)
            let viewportEndFraction: Double = 1.0
            let viewportStartFraction = max(0.0, viewportEndFraction - viewportFraction)
            let viewportCenterX = geo.size.width * CGFloat((viewportStartFraction + viewportEndFraction) / 2)

            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    let centerY = size.height / 2
                    let amp = size.height * 0.4

                    let stripStart = elapsed - stripDuration

                    let startIdx = max(0, Int((stripStart * sampleRate).rounded(.down)))
                    let endIdx = min(samples.count, Int((elapsed * sampleRate).rounded(.up)) + 1)
                    let visibleCount = endIdx - startIdx

                    if visibleCount > 1 {
                        let columns = min(visibleCount, max(2, Int(size.width)))
                        var points: [CGPoint] = []
                        points.reserveCapacity(columns)
                        for col in 0..<columns {
                            let s = (col * visibleCount) / columns
                            let endRaw = ((col + 1) * visibleCount) / columns
                            let e = max(s + 1, min(visibleCount, endRaw))
                            let slice = samples[(startIdx + s)..<(startIdx + e)]
                            let avg = slice.reduce(0, +) / Float(slice.count)
                            let normalized = max(0, min(1, avg / 120))
                            let xFrac = columns > 1 ? Double(col) / Double(columns - 1) : 0.5
                            let x = size.width * CGFloat(xFrac)
                            let y = centerY - CGFloat(normalized) * amp
                            points.append(CGPoint(x: x, y: y))
                        }
                        context.stroke(
                            .smoothCurve(through: points),
                            with: .color(Theme.inkQuiet),
                            lineWidth: 0.7
                        )
                    }

                    let rect = CGRect(
                        x: size.width * CGFloat(viewportStartFraction),
                        y: 2,
                        width: max(3, size.width * CGFloat(viewportFraction)),
                        height: size.height - 4
                    )
                    context.fill(Path(rect), with: .color(Theme.viewportFill))
                    context.stroke(Path(rect), with: .color(Theme.viewport), lineWidth: 1.5)
                }

                // Solid-orange duration chip, anchored to the viewport's
                // centre x. Sits at the top edge of the strip so the
                // value is legible regardless of how narrow the viewport
                // rectangle becomes when zoomed in.
                Text(DateFormatting.durationHMS(seconds: viewportWindowSeconds))
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(Theme.paper)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.86, green: 0.45, blue: 0.18))
                    )
                    .fixedSize()
                    .position(x: viewportCenterX, y: 12)
            }
        }
    }
}
