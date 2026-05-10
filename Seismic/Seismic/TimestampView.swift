import SwiftUI

/// Live timestamp `YYYYMMDD HH:MM:SS:CS` driven by `TimelineView` so
/// it re-renders synced to display refresh — fine on the iPad's
/// 120 Hz ProMotion panel and cheap on the rest of the view tree.
struct TimestampView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.01)) { context in
            Text(DateFormatting.instrumentTimestamp(date: context.date))
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Theme.pen)
                .monospacedDigit()
                .tracking(1)
        }
    }
}
