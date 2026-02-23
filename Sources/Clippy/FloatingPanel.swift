import AppKit

/// Custom key event handler for the panel.
protocol FloatingPanelKeyHandler: AnyObject {
    func handleKeyDown(_ event: NSEvent) -> Bool
}

final class FloatingPanel: NSPanel {
    weak var keyHandler: FloatingPanelKeyHandler?

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        // Don't steal focus from the frontmost app
        hidesOnDeactivate = false
        isMovableByWindowBackground = true

        // Allow key events even though we're non-activating
        becomesKeyOnlyIfNeeded = true

        animationBehavior = .utilityWindow
    }

    // Allow this panel to become key so it receives keyboard events
    override var canBecomeKey: Bool { true }

    override func keyDown(with event: NSEvent) {
        if let handler = keyHandler, handler.handleKeyDown(event) {
            return
        }
        super.keyDown(with: event)
    }
}
