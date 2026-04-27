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

                // 1. Trace block — the trace canvas now spans the
                //    full inner width and the y-axis scale is
                //    overlaid on top-left. The line therefore
                //    extends *under* the dB labels at the left
                //    edge instead of starting after them; the
                //    rightmost tip and pen-tip dot stay inset 10pt
                //    so they don't clip.
                ZStack(alignment: .topLeading) {
                    TimelineView(.animation) { context in
                        ActiveTraceView(
                            samples: session.samples,
                            windowSeconds: windowSeconds,
                            endTime: context.date,
                            sessionStartedAt: session.startedAt
                        )
                        .gesture(pinchGesture())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    ScaleView()
                        .frame(width: Self.scaleColumnWidth)
                        .allowsHitTesting(false)
                }
                .frame(maxHeight: .infinity)

                // 2. Time axis — same full-width as the trace, so
                //    its leftmost tick aligns with the trace's
                //    leftmost x. Sits below the 0 dB baseline.
                TimelineView(.animation) { context in
                    TimeAxisView(
                        windowSeconds: windowSeconds,
                        endTime: context.date
                    )
                }
                .padding(.top, 6)

                // 3. Live timestamp — left edge aligned to the y-axis
                //    label column so its first character ("2" of
                //    "20260427") lines up with the dB labels.
                TimestampView()
                    .padding(.top, Theme.unit / 2)
                    .padding(.bottom, Theme.unit / 5)

                // 4. Hairline
                Rectangle().fill(Theme.hairline).frame(height: 0.5)

                // 5. History strip
                TimelineView(.animation) { context in
                    HistoryStripView(
                        samples: session.samples,
                        sessionStartedAt: session.startedAt,
                        viewportEndTime: context.date,
                        viewportWindowSeconds: windowSeconds
                    )
                }
                .frame(height: 96)
                .padding(.top, Theme.unit / 4)
            }
            .padding(Theme.unit)
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
