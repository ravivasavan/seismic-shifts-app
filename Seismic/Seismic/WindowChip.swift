import SwiftUI

/// Solid-orange duration chip rendering the active window's length
/// as `HH:MM:SS`. Sits on the timestamp row at the trailing edge so
/// it visually labels the scrubber's viewport rectangle below.
struct WindowChip: View {
    let seconds: TimeInterval

    var body: some View {
        Text(DateFormatting.durationHMS(seconds: seconds))
            .font(.system(size: 10, design: .monospaced))
            .tracking(1.5)
            .foregroundColor(Theme.paper)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.86, green: 0.45, blue: 0.18))
            )
            .fixedSize()
    }
}
