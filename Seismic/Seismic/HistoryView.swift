import SwiftUI

/// Hidden archive view triggered by triple-tap. List of past
/// sessions, most recent first. Each row shows start time, end
/// time, duration, and sample count, with two icons:
///
/// - **Share** — `ShareLink` exports the session's CSV via the
///   system share sheet (AirDrop, Files, Mail, ...).
/// - **Trash** — deletes the CSV. Single-row deletes confirm via
///   alert; multi-select deletes confirm with a count.
///
/// Multi-select uses the system Edit button: tap **Select**, tap
/// rows to mark, then either **Delete** the selection or tap the
/// share icon in the toolbar to export all selected files at once.
struct HistoryView: View {
    @Binding var isPresented: Bool

    @State private var sessions: [SessionFile] = []
    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<URL>()

    @State private var pendingSingleDelete: SessionFile?
    @State private var pendingBulkDelete: Bool = false

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
                    List(selection: $selection) {
                        ForEach(sessions) { session in
                            SessionListRow(
                                session: session,
                                onDeleteRequest: { pendingSingleDelete = session }
                            )
                            .listRowBackground(Theme.paper)
                            .listRowSeparatorTint(Theme.hairline)
                            .tag(session.id)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, $editMode)
                }
            }
            .navigationTitle("HISTORY")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.paper, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if sessions.isEmpty {
                        EmptyView()
                    } else if editMode == .active {
                        Button("Done") {
                            editMode = .inactive
                            selection.removeAll()
                        }
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(Theme.ink)
                    } else {
                        Button("Select") { editMode = .active }
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Theme.ink)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("HISTORY")
                        .font(.system(size: 12, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Theme.ink)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if editMode == .active && !selection.isEmpty {
                        HStack(spacing: 18) {
                            ShareLink(items: selection.compactMap { url in url }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(Theme.ink)
                            }
                            Button(role: .destructive) {
                                pendingBulkDelete = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(Theme.pen)
                            }
                        }
                    } else {
                        Button("Close") { isPresented = false }
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Theme.ink)
                    }
                }
            }
            .alert(
                "Delete this session?",
                isPresented: Binding(
                    get: { pendingSingleDelete != nil },
                    set: { if !$0 { pendingSingleDelete = nil } }
                ),
                presenting: pendingSingleDelete
            ) { session in
                Button("Delete", role: .destructive) { delete([session.id]) }
                Button("Cancel", role: .cancel) { }
            } message: { session in
                Text("\(session.samples.count) data points recorded over \(formatDuration(session.durationSeconds)). This cannot be undone.")
            }
            .alert(
                "Delete \(selection.count) session\(selection.count == 1 ? "" : "s")?",
                isPresented: $pendingBulkDelete
            ) {
                Button("Delete", role: .destructive) {
                    delete(Array(selection))
                    selection.removeAll()
                    editMode = .inactive
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This cannot be undone.")
            }
        }
        .onAppear {
            sessions = SessionLoader.loadAll()
        }
    }

    private func delete(_ urls: [URL]) {
        for url in urls {
            try? FileManager.default.removeItem(at: url)
        }
        let dropping = Set(urls)
        sessions.removeAll { dropping.contains($0.id) }
    }

    private func formatDuration(_ total: Int) -> String {
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return String(format: "%dH %02dM", h, m) }
        if m > 0 { return String(format: "%dM %02dS", m, s) }
        return String(format: "%dS", s)
    }
}

private struct SessionListRow: View {
    let session: SessionFile
    let onDeleteRequest: () -> Void

    private var startedFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd  HH:mm:ss"
        return f.string(from: session.startedAt)
    }

    private var endedFormatted: String {
        let ended = session.startedAt.addingTimeInterval(TimeInterval(session.durationSeconds))
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: ended)
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
            VStack(alignment: .leading, spacing: 6) {
                Text(startedFormatted)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Theme.ink)

                HStack(spacing: 14) {
                    Label {
                        Text("END  \(endedFormatted)")
                    } icon: { EmptyView() }
                        .labelStyle(.titleOnly)
                        .font(.system(size: 10, design: .monospaced))
                        .tracking(1)
                        .foregroundColor(Theme.inkQuiet)

                    Text("·")
                        .foregroundColor(Theme.inkFaint)

                    Text("\(durationFormatted)")
                        .font(.system(size: 10, design: .monospaced))
                        .tracking(1)
                        .foregroundColor(Theme.inkQuiet)

                    Text("·")
                        .foregroundColor(Theme.inkFaint)

                    Text("\(session.samples.count) PTS")
                        .font(.system(size: 10, design: .monospaced))
                        .tracking(1)
                        .foregroundColor(Theme.inkQuiet)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                ShareLink(item: session.id) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Theme.ink)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(action: onDeleteRequest) {
                    Image(systemName: "trash")
                        .font(.system(size: 17, weight: .light))
                        .foregroundColor(Theme.pen)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
    }
}
