import SwiftUI

/// Animated launch sequence:
/// 1. Black ink background, single red dot dead-centre.
/// 2. Three concentric red rings ripple outward from the dot,
///    staggered like a stone-on-water impact.
/// 3. The dot's fill transitions from red to paper-cream and the
///    dot scales up to cover the whole screen — "becoming" the
///    app's background.
/// 4. `onComplete` fires; the app replaces this view with
///    `SeismicView` and audio capture begins.
struct LaunchView: View {
    let onComplete: () -> Void

    @State private var ripplesActive = false
    @State private var dotExpanding = false

    private static let dotDiameter: CGFloat = 18
    private static let rippleCount = 3
    private static let rippleDuration: Double = 1.4
    private static let rippleStagger: Double = 0.22
    private static let dotExpandDuration: Double = 0.65

    private static let beforeDotExpand: Double = 1.6
    private static let totalDuration: Double = 2.45

    var body: some View {
        ZStack {
            Theme.ink
                .ignoresSafeArea()

            ForEach(0..<Self.rippleCount, id: \.self) { i in
                Circle()
                    .stroke(Theme.pen, lineWidth: 1.5)
                    .frame(width: Self.dotDiameter, height: Self.dotDiameter)
                    .scaleEffect(ripplesActive ? 70 : 1)
                    .opacity(ripplesActive ? 0 : 0.85)
                    .animation(
                        .easeOut(duration: Self.rippleDuration)
                            .delay(Double(i) * Self.rippleStagger),
                        value: ripplesActive
                    )
            }

            Circle()
                .fill(dotExpanding ? Theme.paper : Theme.pen)
                .frame(width: Self.dotDiameter, height: Self.dotDiameter)
                .scaleEffect(dotExpanding ? 280 : 1)
                .animation(.easeIn(duration: Self.dotExpandDuration), value: dotExpanding)
        }
        .onAppear {
            ripplesActive = true

            DispatchQueue.main.asyncAfter(deadline: .now() + Self.beforeDotExpand) {
                dotExpanding = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.totalDuration) {
                onComplete()
            }
        }
    }
}
