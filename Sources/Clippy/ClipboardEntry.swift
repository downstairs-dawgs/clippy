import AppKit
import Foundation

enum ClipboardContent {
    case text(String)
    case image(NSImage)
}

struct ClipboardEntry: Identifiable {
    let id = UUID()
    let content: ClipboardContent
    let timestamp: Date

    init(content: ClipboardContent, timestamp: Date = Date()) {
        self.content = content
        self.timestamp = timestamp
    }

    var displayText: String {
        switch content {
        case .text(let string):
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        case .image:
            return "[Image]"
        }
    }

    var relativeTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
