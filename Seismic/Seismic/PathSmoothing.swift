import SwiftUI

extension Path {
    /// Catmull-Rom interpolated path through the given points. The
    /// curve passes through every input point exactly; the segments
    /// between are cubic Béziers with tangents derived from each
    /// point's neighbors. Endpoint tangents are clamped so the line
    /// does not extrapolate off either end.
    ///
    /// Used to render the dB SPL trace as a continuous curve — the
    /// data points are unchanged, only the *line between them* is
    /// drawn smoothly. Faithful to a needle-on-paper seismograph;
    /// not data smoothing.
    static func smoothCurve(through points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        guard points.count > 1 else {
            path.move(to: first)
            return path
        }
        if points.count == 2 {
            path.move(to: first)
            path.addLine(to: points[1])
            return path
        }

        path.move(to: first)
        for i in 0..<(points.count - 1) {
            let p0 = i == 0 ? points[i] : points[i - 1]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = (i + 2 < points.count) ? points[i + 2] : p2

            let c1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6,
                y: p1.y + (p2.y - p0.y) / 6
            )
            let c2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6,
                y: p2.y - (p3.y - p1.y) / 6
            )
            path.addCurve(to: p2, control1: c1, control2: c2)
        }
        return path
    }
}
