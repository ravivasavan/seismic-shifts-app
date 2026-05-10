import SwiftUI

/// Left-aligned dB SPL scale: 0–120, major ticks every 20 dB labeled.
/// Labels sit at the left edge so they line up with the rest of the
/// 40 pt frame (e.g. the leading edge of the timestamp text); ticks
/// hug the right edge of the gutter, abutting the trace area.
struct ScaleView: View {
    let minDb: Double = 0
    let maxDb: Double = 120
    let majorStep: Double = 20

    var body: some View {
        GeometryReader { geo in
            let range = maxDb - minDb

            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    var v = minDb
                    while v <= maxDb {
                        let y = size.height * (1 - CGFloat((v - minDb) / range))
                        var path = Path()
                        path.move(to: CGPoint(x: size.width - 8, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(path, with: .color(Theme.penFaint), lineWidth: 0.5)
                        v += majorStep
                    }

                    var m = minDb
                    while m <= maxDb {
                        if m.truncatingRemainder(dividingBy: majorStep) != 0 {
                            let y = size.height * (1 - CGFloat((m - minDb) / range))
                            var path = Path()
                            path.move(to: CGPoint(x: size.width - 4, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                            context.stroke(path, with: .color(Theme.penFaint), lineWidth: 0.5)
                        }
                        m += 5
                    }
                }

                ForEach(Array(stride(from: minDb, through: maxDb, by: majorStep)), id: \.self) { value in
                    Text("\(Int(value))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Theme.penQuiet)
                        .frame(width: 28, alignment: .leading)
                        .position(
                            x: 14,
                            y: geo.size.height * (1 - CGFloat((value - minDb) / range))
                        )
                }
            }
        }
    }
}
