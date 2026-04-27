import SwiftUI
import Combine

/// Top-level composition. Layout, top-down:
///
/// 1. Trace block: y-axis scale + active trace, side-by-side.
/// 2. Time axis: tick row directly below the trace, **below** the
///    0 dB baseline. Aligned horizontally to the trace column.
/// 3. Live timestamp.
/// 4. Hairline divider.
/// 5. Compressed history strip.
///
/// Everything sits inside a single 40 pt outer frame — no element
/// touches the screen edge.
///
/// Two hidden gestures:
///
/// - **Pinch** on the active trace: 5 s minimum window up to the
///   full session length. Default 15 s.
/// - **Triple-tap** anywhere on the screen reveals the History
///   view (an artist-only archive of past sessions). Triple-tap
///   over a chained long-press because tap-count gestures are
///   strictly more reliable on iPad — long-press chains can drop
///   when the gesture system arbitrates with system / pinch
///   gestures.
struct SeismicView: View {
    @StateObject private var session: SessionStore
    @StateObject private var audio: AudioMonitor

    @State private var windowSeconds: TimeInterval = 15
    @State private var pinchBaseline: TimeInterval? = nil
    @State private var showHistory = false

    static let minWindow: TimeInterval = 5
    /// The bottom timeline shows only the most recent 5 minutes of
    /// the session, not the whole thing.
    static let stripWindowSeconds: TimeInterval = 5 * 60

    /// Pinch zoom-out is bounded by the session length so far so
    /// that the maximum window is always the "whole session" view.
    private var maxWindow: TimeInterval {
        let elapsed = max(Self.minWindow, Date().timeIntervalSince(session.startedAt))
        return elapsed
    }

    static let scaleColumnWidth: CGFloat = 40
    static let scaleToTraceGap: CGFloat = 8

    init() {
        let recorder = TraceRecorder()
        let store = SessionStore(recorder: recorder)
        let monitor = AudioMonitor(store: store)
        _session = StateObject(wrappedValue: store)
        _audio = StateObject(wrappedValue: monitor)
    }

    var body: some View {
        ZStack {
            Theme.paper

            VStack(alignment: .leading, spacing: 0) {

                // 1. Trace block — bleeds to the left screen edge.
                //    The active trace canvas spans from x=0 of the
                //    screen to (screen-right − 40 pt). The y-axis
                //    scale is overlaid on top, padded leading 40 pt
                //    so its labels sit in the same 40 pt-from-screen
                //    column as the timestamp / strip below. The
                //    line itself runs *off* the left screen edge
                //    rather than stopping at the 40 pt frame.
                ZStack(alignment: .topLeading) {
                    TimelineView(.animation) { context in
                        ActiveTraceView(
                            samples: session.samples,
                            windowSeconds: windowSeconds,
                            endTime: context.date,
                            sessionStartedAt: session.startedAt,
                            gridStartX: Theme.unit + Self.scaleColumnWidth
                        )
                        .gesture(pinchGesture())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    ScaleView()
                        .frame(width: Self.scaleColumnWidth)
                        .padding(.leading, Theme.unit)
                        .allowsHitTesting(false)
                }
                .frame(maxHeight: .infinity)

                // 2. Time axis — same full-width-bleed as the trace
                //    so the leftmost tick aligns with the trace's
                //    leftmost x even when that x is the screen edge.
                TimelineView(.animation) { context in
                    TimeAxisView(
                        windowSeconds: windowSeconds,
                        endTime: context.date
                    )
                }
                .padding(.top, 6)

                // 3. Live timestamp — inset 40 pt from screen left
                //    so its first character ("2" of "20260427")
                //    lines up with the dB labels.
                TimestampView()
                    .padding(.leading, Theme.unit)
                    .padding(.top, Theme.unit / 2)
                    .padding(.bottom, Theme.unit / 5)

                // 4. Hairline — leading inset 40 pt; trailing 40 pt
                //    comes from the outer container, so no extra
                //    horizontal padding is needed here (otherwise it
                //    would double up to 80 pt on the right).
                Rectangle()
                    .fill(Theme.hairline)
                    .frame(height: 0.5)
                    .padding(.leading, Theme.unit)

                // 5. History strip — same: leading-only padding.
                TimelineView(.animation) { context in
                    HistoryStripView(
                        samples: session.samples,
                        sampleRate: SessionStore.sampleRate,
                        sessionStartedAt: session.startedAt,
                        viewportEndTime: context.date,
                        viewportWindowSeconds: windowSeconds,
                        stripWindowSeconds: Self.stripWindowSeconds
                    )
                }
                .frame(height: 96)
                .padding(.leading, Theme.unit)
                .padding(.top, Theme.unit / 4)
            }
            // Outer padding: top/right/bottom only. Leading is left
            // unpadded so the trace + time axis bleed to the screen
            // edge while every other element sits in the 40 pt frame
            // via its own .padding(.leading).
            .padding(.top, Theme.unit)
            .padding(.trailing, Theme.unit)
            .padding(.bottom, Theme.unit)
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture(count: 3) {
            showHistory = true
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView(isPresented: $showHistory)
        }
        .onAppear {
            try? audio.start()
        }
        .onDisappear {
            audio.stop()
            session.close()
        }
    }

    private func pinchGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                if pinchBaseline == nil { pinchBaseline = windowSeconds }
                let base = pinchBaseline ?? windowSeconds
                let target = base / Double(scale)
                windowSeconds = max(Self.minWindow, min(maxWindow, target))
            }
            .onEnded { _ in
                pinchBaseline = nil
            }
    }

}
