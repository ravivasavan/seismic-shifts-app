import SwiftUI
import Combine

/// Top-level composition. Wires audio -> session store -> three
/// visible surfaces (active trace + scale + time axis, timestamp,
/// history strip). Handles two hidden gestures with no UI affordance:
///
/// - **Pinch** on the active trace adjusts the visible window between
///   1 and 60 minutes.
/// - **Three consecutive long-presses** within ~2 seconds reveals
///   the History view (an artist-only archive of past sessions).
///   Three more long-presses inside the History view dismiss it.
struct SeismicView: View {
    @StateObject private var session: SessionStore
    @StateObject private var audio: AudioMonitor

    @State private var windowSeconds: TimeInterval = 900   // 15 minutes default
    @State private var pinchBaseline: TimeInterval? = nil
    @State private var showHistory = false

    @State private var longPressCount = 0
    @State private var longPressResetTask: Task<Void, Never>?

    static let minWindow: TimeInterval = 60        // 1 minute
    static let maxWindow: TimeInterval = 3600      // 60 minutes

    init() {
        let recorder = TraceRecorder()
        let store = SessionStore(recorder: recorder)
        let monitor = AudioMonitor(store: store)
        _session = StateObject(wrappedValue: store)
        _audio = StateObject(wrappedValue: monitor)
    }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ScaleView()
                        .frame(width: 56)
                        .padding(.leading, 16)

                    VStack(spacing: 0) {
                        TimelineView(.periodic(from: .now, by: 0.5)) { context in
                            ActiveTraceView(
                                samples: session.samples,
                                windowSeconds: windowSeconds,
                                endTime: context.date,
                                sessionStartedAt: session.startedAt
                            )
                            .gesture(pinchGesture())
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            TimeAxisView(
                                windowSeconds: windowSeconds,
                                endTime: context.date
                            )
                        }
                        .padding(.top, 6)
                    }
                    .padding(.trailing, 16)
                }
                .frame(maxHeight: .infinity)

                HStack {
                    TimestampView()
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 8)

                Rectangle().fill(Theme.hairline).frame(height: 0.5)

                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    HistoryStripView(
                        samples: session.samples,
                        sessionStartedAt: session.startedAt,
                        viewportEndTime: context.date,
                        viewportWindowSeconds: windowSeconds
                    )
                }
                .frame(height: 110)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
            }
        }
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
                windowSeconds = max(Self.minWindow, min(Self.maxWindow, target))
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
