import Foundation

struct Note: Codable {
    let id: Int
    var title: String
    var body: String
    var tags: [String]
    let createdAt: Date
}

struct NoteStore {
    private let fileURL: URL
    private var notes: [Note] = []

    init(fileName: String = "notes.json") {
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.fileURL = cwd.appendingPathComponent(fileName)
        self.notes = Self.load(from: fileURL)
    }

    private static func load(from url: URL) -> [Note] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            if data.isEmpty { return [] }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Note].self, from: data)
        } catch {
            fputs("Warning: failed to load notes: \(error)\n", stderr)
            return []
        }
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(notes)
            try data.write(to: fileURL)
        } catch {
            fputs("Error: failed to save notes: \(error)\n", stderr)
        }
    }

    mutating func add(title: String, body: String, tags: [String]) {
        let nextID = (notes.map { $0.id }.max() ?? 0) + 1
        let cleanedTags = tags
            .flatMap { $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines).lowercased() } }
            .filter { !$0.isEmpty }
        let note = Note(id: nextID, title: title, body: body, tags: cleanedTags, createdAt: Date())
        notes.append(note)
        save()
        print("✅ Added note #\(note.id)")
    }

    func list(filterTag: String? = nil) {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short

        var filtered = notes
        if let tag = filterTag?.lowercased(), !tag.isEmpty {
            filtered = filtered.filter { $0.tags.map { $0.lowercased() }.contains(tag) }
        }

        if filtered.isEmpty {
            print("No notes found\(filterTag != nil ? " with tag '\(filterTag!)'" : "").")
            return
        }

        for note in filtered.sorted(by: { $0.id < $1.id }) {
            let tagsString = note.tags.isEmpty ? "-" : note.tags.joined(separator: ", ")
            print("------------------------------------------------------------")
            print("#\(note.id) • \(note.title)")
            print("Created: \(df.string(from: note.createdAt))")
            print("Tags:    \(tagsString)")
            print("")
            print(note.body)
            print("")
        }
        print("------------------------------------------------------------")
        print("Total notes: \(filtered.count)")
    }

    func search(query: String) {
        let q = query.lowercased()
        let matches = notes.filter { note in
            note.title.lowercased().contains(q) || note.body.lowercased().contains(q)
        }

        if matches.isEmpty {
            print("No notes matched \"\(query)\".")
            return
        }

        for note in matches.sorted(by: { $0.id < $1.id }) {
            print("------------------------------------------------------------")
            print("#\(note.id) • \(note.title)")
            let snippet = snippetFor(note: note, query: q)
            print(snippet)
        }
        print("------------------------------------------------------------")
        print("Matches: \(matches.count)")
    }

    private func snippetFor(note: Note, query: String) -> String {
        let text = note.body
        let lower = text.lowercased()
        guard let range = lower.range(of: query) else {
            return text.count > 120 ? String(text.prefix(120)) + "..." : text
        }

        let startIndex = range.lowerBound
        let snippetStart = lower.index(startIndex, offsetBy: -40, limitedBy: lower.startIndex) ?? lower.startIndex
        let snippetEnd = lower.index(startIndex, offsetBy: 80, limitedBy: lower.endIndex) ?? lower.endIndex

        let snippetRange = snippetStart..<snippetEnd
        var snippet = String(text[snippetRange])

        if snippetStart > lower.startIndex {
            snippet = "..." + snippet
        }
        if snippetEnd < lower.endIndex {
            snippet += "..."
        }
        return snippet
    }

    mutating func delete(id: Int) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else {
            print("No note with id #\(id).")
            return
        }
        notes.remove(at: index)
        save()
        print("🗑 Deleted note #\(id)")
    }
}

func printUsage() {
    let usage = """
    NoteTagger – Simple Swift CLI note & tag manager

    Usage:
      notetagger add \"Title\" \"Body text\" [tags...]
      notetagger list
      notetagger list tag <tagName>
      notetagger search <text>
      notetagger delete <id>

    Examples:
      notetagger add \"Ideas\" \"Try building a Swift CLI\" swift cli ideas
      notetagger list
      notetagger list tag swift
      notetagger search swift
      notetagger delete 2

    Notes are stored in 'notes.json' in the current directory.
    """

    print(usage)
}

func main() {
    var args = CommandLine.arguments
    guard args.count >= 2 else {
        printUsage()
        return
    }
    _ = args.removeFirst() // executable name
    let command = args.removeFirst()

    var store = NoteStore()

    switch command {
    case "add":
        guard args.count >= 2 else {
            print("Error: 'add' requires a title and body.")
            printUsage()
            return
        }
        let title = args.removeFirst()
        let body = args.removeFirst()
        let tags = args
        store.add(title: title, body: body, tags: tags)

    case "list":
        if args.count == 2 && args[0] == "tag" {
            let tag = args[1]
            store.list(filterTag: tag)
        } else {
            store.list()
        }

    case "search":
        guard args.count >= 1 else {
            print("Error: 'search' requires a query string.")
            printUsage()
            return
        }
        let query = args.joined(separator: " ")
        store.search(query: query)

    case "delete":
        guard let first = args.first, let id = Int(first) else {
            print("Error: 'delete' requires a numeric id.")
            printUsage()
            return
        }
        store.delete(id: id)

    case "help", "-h", "--help":
        printUsage()

    default:
        print("Unknown command: \(command)")
        printUsage()
    }
}

main()
