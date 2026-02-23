import AppKit

final class FloatingPanel: NSPanel {
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

        hidesOnDeactivate = false
        isMovableByWindowBackground = true

        animationBehavior = .utilityWindow
    }

    override var canBecomeKey: Bool { true }
}
