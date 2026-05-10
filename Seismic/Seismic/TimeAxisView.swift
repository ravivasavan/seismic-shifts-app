import SwiftUI

/// Time tick markers along the bottom of the active trace. Tick
/// spacing adapts to the current zoom window so a handful of ticks
/// remain visible across short and long windows alike.
struct TimeAxisView: View {
    let windowSeconds: TimeInterval
    let endTime: Date

    private var tickInterval: TimeInterval {
        switch windowSeconds {
        case 0..<10:        return 1     // ≤ 10 s  → every 1 s
        case 10..<30:       return 3     // ≤ 30 s  → every 3 s
        case 30..<120:      return 15    // ≤ 2 min → every 15 s
        case 120..<360:     return 30    // ≤ 6 min → every 30 s
        case 360..<900:     return 60    // ≤ 15 min → every 1 min
        case 900..<1800:    return 120   // ≤ 30 min → every 2 min
        case 1800..<3600:   return 300   // ≤ 60 min → every 5 min
        case 3600..<14400:  return 600   // ≤ 4 h   → every 10 min
        default:            return 1800  // > 4 h   → every 30 min
        }
    }

    private func label(for date: Date) -> String {
        windowSeconds <= 360 ? DateFormatting.clockHMS(date: date) : DateFormatting.clockHM(date: date)
    }

    var body: some View {
        GeometryReader { geo in
            let startTime = endTime.addingTimeInterval(-windowSeconds)
            let interval = tickInterval
            // Extend the iterated range one tick interval past each
            // edge of the visible window. The leftmost tick is then
            // already off-screen-left when introduced (negative x),
            // and the next-to-appear tick is already off-screen-right
            // (x > size.width) — so as time advances they slide in
            // from the right edge and slide off the left edge rather
            // than snapping in/out at the screen edges.
            let firstEpoch = ceil(startTime.timeIntervalSince1970 / interval) * interval - interval
            let lastEpoch = endTime.timeIntervalSince1970 + interval

            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    var t = firstEpoch
                    while t <= lastEpoch {
                        let frac = (t - startTime.timeIntervalSince1970) / windowSeconds
                        let x = size.width * CGFloat(frac)
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: 4))
                        context.stroke(path, with: .color(Theme.penFaint), lineWidth: 0.5)
                        t += interval
                    }
                }

                ForEach(
                    Array(stride(from: firstEpoch, through: lastEpoch, by: interval)),
                    id: \.self
                ) { tickEpoch in
                    let frac = (tickEpoch - startTime.timeIntervalSince1970) / windowSeconds
                    let x = geo.size.width * CGFloat(frac)
                    Text(label(for: Date(timeIntervalSince1970: tickEpoch)))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Theme.penQuiet)
                        .fixedSize()
                        .position(x: x, y: 14)
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(height: 22)
    }
}
