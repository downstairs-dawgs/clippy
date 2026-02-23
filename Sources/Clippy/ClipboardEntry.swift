import AppKit
import Foundation

enum ClipboardContent {
    case text(String)
    case image(NSImage)
}

final class ClipboardEntry: Identifiable, ObservableObject {
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

    var isText: Bool {
        if case .text = content { return true }
        return false
    }

    var isImage: Bool {
        if case .image = content { return true }
        return false
    }

    var iconName: String {
        switch content {
        case .text: return "doc.on.doc"
        case .image: return "photo"
        }
    }

    var relativeTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
