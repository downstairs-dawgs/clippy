import AppKit
import Foundation

enum ClipboardContent {
    case text(String)
    case image(NSImage)

    var byteSize: Int {
        switch self {
        case .text(let string):
            return string.utf8.count
        case .image(let image):
            return image.tiffRepresentation?.count ?? 0
        }
    }
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

    var byteSize: Int { content.byteSize }

    var relativeTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
