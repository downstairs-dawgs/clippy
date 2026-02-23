import AppKit
import Combine
import Foundation

final class ClipboardManager: ObservableObject {
    @Published var entries: [ClipboardEntry] = []

    private var timer: Timer?
    private var lastChangeCount: Int
    private let maxEntries = 100

    /// Set to true when we're writing to the pasteboard ourselves,
    /// so we don't re-capture our own paste-back.
    var isWriting = false

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        guard !isWriting else { return }

        // Prefer text when available; only capture as image when there's no string content
        // (e.g. screenshots, copied images from Preview/Photoshop).
        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            addEntry(.text(string))
        } else if let image = NSImage(pasteboard: pasteboard) {
            addEntry(.image(image))
        }
    }

    private func addEntry(_ content: ClipboardContent) {
        // Deduplicate: remove existing entry with same content
        switch content {
        case .text(let newText):
            entries.removeAll { entry in
                if case .text(let existing) = entry.content {
                    return existing == newText
                }
                return false
            }
        case .image:
            break // Images are always added as new entries
        }

        let entry = ClipboardEntry(content: content)
        entries.insert(entry, at: 0)

        // Trim to max
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
    }

    func filteredEntries(searchText: String) -> [ClipboardEntry] {
        guard !searchText.isEmpty else { return entries }
        return entries.filter { entry in
            switch entry.content {
            case .text(let string):
                return string.localizedCaseInsensitiveContains(searchText)
            case .image:
                return "[image]".localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
