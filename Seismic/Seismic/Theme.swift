import SwiftUI

enum Theme {
    /// Single layout unit used for outer margins, gutters, and section
    /// spacing. Keep everything visible on screen as multiples or
    /// fractions of this so the page reads as one consistent grid.
    static let unit: CGFloat = 40

    static let paper = Color(red: 0.957, green: 0.937, blue: 0.902)
    static let ink = Color(red: 0.102, green: 0.102, blue: 0.102)
    static let inkQuiet = Color.black.opacity(0.55)
    static let inkFaint = Color.black.opacity(0.30)
    static let hairline = Color.black.opacity(0.30)
    static let viewport = Color(red: 0.86, green: 0.45, blue: 0.18, opacity: 0.95)
    static let viewportFill = Color(red: 0.86, green: 0.45, blue: 0.18, opacity: 0.10)

    /// "Pen tip" colour for the live cursor at the right edge of the
    /// active trace — quietly red, like a needle on seismograph paper.
    static let pen = Color(red: 0.78, green: 0.18, blue: 0.12)
}
