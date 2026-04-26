import Foundation

/// Session-based CSV writer. One file per app launch named for the
/// session-start timestamp; never appended to a prior session's file.
/// Header row is written once at file creation; thereafter one row
/// per second containing ISO 8601 timestamp + averaged dB SPL.
final class TraceRecorder {
    private var fileHandle: FileHandle?
    private var writeCount = 0
    private(set) var fileURL: URL?

    static let recordingsDirectoryName = "seismic-recordings"

    init() {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let dir = documents.appendingPathComponent(Self.recordingsDirectoryName)

        try? FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true
        )

        var dirURL = dir
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        _ = try? dirURL.setResourceValues(resourceValues)

        let filename = DateFormatting.sessionFilename()
        let url = dir.appendingPathComponent(filename)
        let header = "timestamp,db_spl\n"
        try? header.write(to: url, atomically: true, encoding: .utf8)

        fileURL = url
        fileHandle = try? FileHandle(forWritingTo: url)
        _ = try? fileHandle?.seekToEnd()
    }

    func record(value: Float, at date: Date = Date()) {
        let timestamp = DateFormatting.iso8601.string(from: date)
        let line = "\(timestamp),\(value)\n"
        guard let data = line.data(using: .utf8) else { return }
        try? fileHandle?.write(contentsOf: data)
        writeCount += 1
        if writeCount % 60 == 0 {
            try? fileHandle?.synchronize()
        }
    }

    func close() {
        try? fileHandle?.synchronize()
        try? fileHandle?.close()
        fileHandle = nil
    }

    deinit {
        close()
    }
}

/// Read-only loader for past session files (History view).
struct SessionFile: Identifiable {
    let id: URL
    let startedAt: Date
    let durationSeconds: Int
    let samples: [Float]
}

enum SessionLoader {
    static func recordingsDirectory() -> URL {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        return documents.appendingPathComponent(TraceRecorder.recordingsDirectoryName)
    }

    static func loadAll() -> [SessionFile] {
        let dir = recordingsDirectory()
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        )) ?? []
        let csvURLs = urls.filter { $0.pathExtension == "csv" }

        var sessions: [SessionFile] = []
        for url in csvURLs {
            guard let session = parse(url: url) else { continue }
            sessions.append(session)
        }
        return sessions.sorted { $0.startedAt > $1.startedAt }
    }

    private static func parse(url: URL) -> SessionFile? {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        guard lines.count > 1 else { return nil }

        var samples: [Float] = []
        samples.reserveCapacity(lines.count - 1)
        for line in lines.dropFirst() {
            let parts = line.split(separator: ",", maxSplits: 1)
            guard parts.count == 2,
                  let value = Float(parts[1]) else { continue }
            samples.append(value)
        }
        guard !samples.isEmpty else { return nil }

        let started = DateFormatting.sessionDate(from: url.lastPathComponent) ?? Date()
        return SessionFile(
            id: url,
            startedAt: started,
            durationSeconds: samples.count,
            samples: samples
        )
    }
}
