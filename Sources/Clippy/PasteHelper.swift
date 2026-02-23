import AppKit

enum PasteHelper {
    /// Write the entry's content to the system pasteboard and simulate Cmd+V.
    static func paste(entry: ClipboardEntry, clipboardManager: ClipboardManager) {
        let pasteboard = NSPasteboard.general

        // Prevent the ClipboardManager from re-capturing this write
        clipboardManager.isWriting = true

        pasteboard.clearContents()
        switch entry.content {
        case .text(let string):
            pasteboard.setString(string, forType: .string)
        case .image(let image):
            if let tiffData = image.tiffRepresentation {
                pasteboard.setData(tiffData, forType: .tiff)
            }
        }

        // Small delay to let the panel close and the previous app regain focus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            simulatePaste()

            // Re-enable clipboard monitoring after the paste completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                clipboardManager.isWriting = false
            }
        }
    }

    /// Simulate Cmd+V keypress via CGEvent.
    private static func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)

        // Key code 9 = 'V'
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false) else {
            return
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
