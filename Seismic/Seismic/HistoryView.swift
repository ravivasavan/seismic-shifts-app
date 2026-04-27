import SwiftUI

/// Hidden archive view triggered by triple-long-press. Simple list of
/// past sessions, most recent first, with swipe-to-delete and a
/// share button per row that exports the session's CSV file via the
/// system share sheet (AirDrop, Files, Mail, Messages, ...).
struct HistoryView: View {
    @Binding var isPresented: Bool
    @State private var sessions: [SessionFile] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.paper.ignoresSafeArea()

                if sessions.isEmpty {
                    VStack {
                        Spacer()
                        Text("NO RECORDED SESSIONS")
                            .font(.system(size: 11, design: .monospaced))
                            .tracking(2)
                            .foregroundColor(Theme.inkQuiet)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(sessions) { session in
                            SessionListRow(session: session)
                                .listRowBackground(Theme.paper)
                                .listRowSeparatorTint(Theme.hairline)
                        }
                        .onDelete(perform: deleteRows)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("HISTORY")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.paper, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isPresented = false }
                        .foregroundColor(Theme.ink)
                        .font(.system(size: 14, design: .monospaced))
                }
            }
        }
        .onAppear {
            sessions = SessionLoader.loadAll()
        }
    }

    private func deleteRows(at offsets: IndexSet) {
        for idx in offsets {
            try? FileManager.default.removeItem(at: sessions[idx].id)
        }
        sessions.remove(atOffsets: offsets)
    }
}

private struct SessionListRow: View {
    let session: SessionFile

    private var startedFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd  HH:mm:ss"
        return f.string(from: session.startedAt)
    }

    private var durationFormatted: String {
        let total = session.durationSeconds
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return String(format: "%dH %02dM", h, m) }
        if m > 0 { return String(format: "%dM %02dS", m, s) }
        return String(format: "%dS", s)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(startedFormatted)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Theme.ink)
                Text("\(durationFormatted)  ·  \(session.samples.count) PTS")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(Theme.inkQuiet)
            }

            Spacer()

            ShareLink(item: session.id) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(Theme.ink)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 6)
    }
}
