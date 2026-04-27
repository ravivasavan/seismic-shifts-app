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
/// - **Three consecutive long-presses** within ~2 s reveal the
///   History view (an artist-only archive of past sessions).
struct SeismicView: View {
    @StateObject private var session: SessionStore
    @StateObject private var audio: AudioMonitor

    @State private var windowSeconds: TimeInterval = 15
    @State private var pinchBaseline: TimeInterval? = nil
    @State private var showHistory = false

    @State private var longPressCount = 0
    @State private var longPressResetTask: Task<Void, Never>?

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

                // 1. Trace block
                HStack(alignment: .top, spacing: Self.scaleToTraceGap) {
                    ScaleView()
                        .frame(width: Self.scaleColumnWidth)

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
                }
                .frame(maxHeight: .infinity)

                // 2. Time axis — sits below the trace, so all tick
                //    labels are below the 0 dB baseline rather than
                //    overlapping it. Indented via .padding rather
                //    than a spacer column so it doesn't grab flex
                //    height in the parent VStack.
                TimelineView(.animation) { context in
                    TimeAxisView(
                        windowSeconds: windowSeconds,
                        endTime: context.date
                    )
                }
                .padding(.leading, Self.scaleColumnWidth + Self.scaleToTraceGap)
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
        .simultaneousGesture(tripleLongPress())
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

    private func tripleLongPress() -> some Gesture {
        LongPressGesture(minimumDuration: 0.6)
            .onEnded { _ in
                longPressCount += 1
                longPressResetTask?.cancel()
                if longPressCount >= 3 {
                    longPressCount = 0
                    showHistory = true
                } else {
                    longPressResetTask = Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        if !Task.isCancelled {
                            longPressCount = 0
                        }
                    }
                }
            }
    }
}
