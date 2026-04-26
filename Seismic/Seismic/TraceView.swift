import SwiftUI

struct TraceView: View {
    @ObservedObject var buffer: TraceBuffer

    var body: some View {
        Canvas { context, size in
            guard buffer.samples.count > 1 else { return }

            var path = Path()
            let stepX = size.width / CGFloat(max(buffer.samples.count, 1))
            let centerY = size.height / 2
            let amplitude = size.height * 0.4

            for (i, sample) in buffer.samples.enumerated() {
                let x = CGFloat(i) * stepX
                let y = centerY - CGFloat(sample) * amplitude
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            context.stroke(path, with: .color(.black), lineWidth: 1.0)
        }
        .background(Color(red: 0.96, green: 0.94, blue: 0.90))
    }
}
