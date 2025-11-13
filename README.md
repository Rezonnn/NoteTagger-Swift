# 🗒️ NoteTagger – Swift CLI Notes & Tags Manager

A small but polished **Swift command-line app** that lets you create, list, search, and delete notes with tags.

My project showcases:

- **Swift** (outside of iOS UI)
- **Swift Package Manager** (SPM)
- JSON persistence using `Codable`
- Command-line argument parsing
- Clean CLI UX and text formatting

---

## ✨ Features

- `add` – create a new note with title, body, and tags
- `list` – list all notes
- `list tag <tag>` – list notes filtered by a specific tag
- `search <text>` – search in titles & bodies (case-insensitive)
- `delete <id>` – delete a note by id
- Notes are stored in a local `notes.json` file

Each note has:

```swift
struct Note: Codable {
    let id: Int
    var title: String
    var body: String
    var tags: [String]
    let createdAt: Date
}
```

---

## 🧱 Tech Stack

- **Language**: Swift
- **Build tool**: Swift Package Manager (SPM)
- Uses:
  - `Foundation`
  - `Codable` for JSON
  - `Date` / `DateFormatter`
  - `CommandLine.arguments` parsing

---

## 📂 Project Structure

```text
swift_note_tagger/
├─ Package.swift
├─ README.md
└─ Sources/
   └─ NoteTagger/
      └─ main.swift
```

---

## ▶️ How to Build & Run

1. Make sure you have Swift & SPM installed:

```bash
swift --version
```

2. From the project root:

```bash
swift build
```

3. Run using `swift run`:

```bash
# Show usage
swift run notetagger help

# Add a note
swift run notetagger add "Ideas" "Try building a Swift CLI app" swift cli ideas

# List all notes
swift run notetagger list

# List notes with a specific tag
swift run notetagger list tag swift

# Search notes by text
swift run notetagger search "swift"

# Delete a note by id
swift run notetagger delete 1
```

Notes are stored in `notes.json` in the current working directory.
