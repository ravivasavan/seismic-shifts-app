import SwiftUI

/// Hidden archive view triggered by triple-long-press. Lists past
/// sessions grouped by day, each rendered as a horizontal strip.
/// Triple-long-press anywhere dismisses back to the live trace.
struct HistoryView: View {
    @Binding var isPresented: Bool
    @State private var sessions: [SessionFile] = []
    @State private var dismissCount = 0
    @State private var dismissResetTask: Task<Void, Never>?

    private var grouped: [DayGroup] {
        let cal = Calendar.current
        var dict: [Date: [SessionFile]] = [:]
        for s in sessions {
            let day = cal.startOfDay(for: s.startedAt)
            dict[day, default: []].append(s)
        }
        return dict.keys.sorted(by: >).map { date in
            DayGroup(
                id: date,
                date: date,
                sessions: dict[date]!.sorted { $0.startedAt > $1.startedAt }
            )
        }
    }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("HISTORY")
                        .font(.system(size: 12, design: .monospaced))
                        .tracking(2.5)
                        .foregroundColor(Theme.ink)
                    Spacer()
                    Text("\(sessions.count) SESSION\(sessions.count == 1 ? "" : "S")")
                        .font(.system(size: 10, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(Theme.inkQuiet)
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 24)

                Rectangle().fill(Theme.hairline).frame(height: 0.5)

                if sessions.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("NO RECORDED SESSIONS")
                            .font(.system(size: 11, design: .monospaced))
                            .tracking(2)
                            .foregroundColor(Theme.inkQuiet)
                        Spacer()
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(grouped) { day in
                                DayRow(day: day)
                                Rectangle()
                                    .fill(Theme.hairline)
                                    .frame(height: 0.5)
                                    .padding(.horizontal, 60)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(dismissGesture())
        .onAppear {
            sessions = SessionLoader.loadAll()
        }
    }

    private func dismissGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.6)
            .onEnded { _ in
                dismissCount += 1
                dismissResetTask?.cancel()
                if dismissCount >= 3 {
                    dismissCount = 0
                    isPresented = false
                } else {
                    dismissResetTask = Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        if !Task.isCancelled {
                            dismissCount = 0
                        }
                    }
                }
            }
    }
}

struct DayGroup: Identifiable {
    let id: Date
    let date: Date
    let sessions: [SessionFile]
}

struct DayRow: View {
    let day: DayGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(DateFormatting.dayHeader(date: day.date))
                .font(.system(size: 11, design: .monospaced))
                .tracking(2)
                .foregroundColor(Theme.ink)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(day.sessions) { session in
                    SessionRow(session: session)
                }
            }

            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 60)
    }
}

struct SessionRow: View {
    let session: SessionFile

    private var duration: String {
        let total = session.durationSeconds
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return String(format: "%dH %02dM", h, m) }
        if m > 0 { return String(format: "%dM %02dS", m, s) }
        return String(format: "%dS", s)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(DateFormatting.clockHMS(date: session.startedAt))
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(1.2)
                    .foregroundColor(Theme.inkQuiet)
                Text("·")
                    .foregroundColor(Theme.inkQuiet)
                Text(duration)
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(1.2)
                    .foregroundColor(Theme.inkQuiet)
                Spacer()
                Text("\(session.samples.count) PTS")
                    .font(.system(size: 9, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(Theme.inkFaint)
            }
            Canvas { context, size in
                let n = session.samples.count
                guard n > 1 else { return }
                let centerY = size.height / 2
                let amp = size.height * 0.4
                let columns = min(n, max(2, Int(size.width)))

                var path = Path()
                for col in 0..<columns {
                    let s = (col * n) / columns
                    let endRaw = ((col + 1) * n) / columns
                    let e = max(s + 1, min(n, endRaw))
                    let slice = session.samples[s..<e]
                    let avg = slice.reduce(0, +) / Float(slice.count)
                    let nval = max(0, min(1, avg / 120))
                    let xFrac = columns > 1 ? Double(col) / Double(columns - 1) : 0.5
                    let x = size.width * CGFloat(xFrac)
                    let y = centerY - CGFloat(nval) * amp
                    if col == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(path, with: .color(Theme.ink), lineWidth: 0.7)
            }
            .frame(height: 56)
        }
    }
}
