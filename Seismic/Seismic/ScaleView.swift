import SwiftUI

/// Left-gutter dB SPL scale: 0–120, major ticks every 20 dB labeled.
struct ScaleView: View {
    let minDb: Double = 0
    let maxDb: Double = 120
    let majorStep: Double = 20

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    let range = maxDb - minDb
                    var v = minDb
                    while v <= maxDb {
                        let y = size.height * (1 - CGFloat((v - minDb) / range))
                        var path = Path()
                        path.move(to: CGPoint(x: size.width - 8, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(path, with: .color(Theme.inkFaint), lineWidth: 0.5)
                        v += majorStep
                    }

                    var m = minDb
                    while m <= maxDb {
                        if m.truncatingRemainder(dividingBy: majorStep) != 0 {
                            let y = size.height * (1 - CGFloat((m - minDb) / range))
                            var path = Path()
                            path.move(to: CGPoint(x: size.width - 4, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                            context.stroke(path, with: .color(Theme.inkFaint), lineWidth: 0.5)
                        }
                        m += 5
                    }
                }

                let range = maxDb - minDb
                ForEach(Array(stride(from: minDb, through: maxDb, by: majorStep)), id: \.self) { value in
                    Text("\(Int(value))")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Theme.inkQuiet)
                        .position(
                            x: geo.size.width - 24,
                            y: geo.size.height * (1 - CGFloat((value - minDb) / range))
                        )
                }
            }
        }
    }
}
