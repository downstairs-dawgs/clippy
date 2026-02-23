import AppKit
import SwiftUI

final class FloatingPanelController {
    private var panel: FloatingPanel?
    private let clipboardManager: ClipboardManager
    private let settings: SettingsStore
    private let panelWidth: CGFloat = 700
    private let panelHeight: CGFloat = 450
    private var localMonitor: Any?

    /// Tracks which entry is selected via keyboard navigation.
    let selectionState = SelectionState()

    init(clipboardManager: ClipboardManager, settings: SettingsStore) {
        self.clipboardManager = clipboardManager
        self.settings = settings
    }

    var isVisible: Bool {
        panel?.isVisible ?? false
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        if panel == nil {
            createPanel()
        }

        guard let panel = panel else { return }

        positionPanel(panel)
        selectionState.selectedIndex = 0
        selectionState.searchText = ""

        installKeyMonitor()
        panel.makeKeyAndOrderFront(nil)

        // Focus the search field after the SwiftUI view is laid out
        DispatchQueue.main.async {
            self.focusSearchField()
        }
    }

    func hide() {
        removeKeyMonitor()
        panel?.orderOut(nil)
    }

    // MARK: - Key event monitor

    /// Local event monitor intercepts key events before the responder chain,
    /// so Escape/arrows/Enter work even when the search field has focus.
    private func installKeyMonitor() {
        removeKeyMonitor()
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, self.isVisible else { return event }
            if self.handleKeyDown(event) {
                return nil // consumed
            }
            return event
        }
    }

    private func removeKeyMonitor() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    // MARK: - Panel setup

    private func createPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)
        let floatingPanel = FloatingPanel(contentRect: contentRect)

        let rootView = ClipboardPanelView(
            clipboardManager: clipboardManager,
            selectionState: selectionState,
            settings: settings,
            onSelect: { [weak self] entry in
                self?.pasteEntry(entry)
            },
            onDelete: { [weak self] entry in
                self?.deleteEntry(entry)
            },
            onDismiss: { [weak self] in
                self?.hide()
            }
        )

        floatingPanel.contentView = NSHostingView(rootView: rootView)
        self.panel = floatingPanel
    }

    private func positionPanel(_ panel: FloatingPanel) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - panelWidth / 2
        let y = screenFrame.midY - panelHeight / 2
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func pasteEntry(_ entry: ClipboardEntry) {
        hide()
        PasteHelper.paste(entry: entry, clipboardManager: clipboardManager)
    }

    private func deleteEntry(_ entry: ClipboardEntry) {
        clipboardManager.deleteEntry(id: entry.id)
        let remaining = clipboardManager.filteredEntries(searchText: selectionState.searchText)
        if selectionState.selectedIndex >= remaining.count && remaining.count > 0 {
            selectionState.selectedIndex = remaining.count - 1
        }
    }

    private func focusSearchField() {
        guard let contentView = panel?.contentView else { return }
        // Find the NSTextField inside the SwiftUI hosting view
        func findTextField(in view: NSView) -> NSTextField? {
            if let tf = view as? NSTextField, tf.isEditable { return tf }
            for sub in view.subviews {
                if let found = findTextField(in: sub) { return found }
            }
            return nil
        }
        if let textField = findTextField(in: contentView) {
            panel?.makeFirstResponder(textField)
        }
    }

    // MARK: - Key handling

    private func handleKeyDown(_ event: NSEvent) -> Bool {
        let filtered = clipboardManager.filteredEntries(searchText: selectionState.searchText)

        switch Int(event.keyCode) {
        case 53: // Escape
            hide()
            return true
        case 126: // Up arrow
            if selectionState.selectedIndex > 0 {
                selectionState.selectedIndex -= 1
            }
            return true
        case 125: // Down arrow
            if selectionState.selectedIndex < filtered.count - 1 {
                selectionState.selectedIndex += 1
            }
            return true
        case 36: // Return/Enter
            if selectionState.selectedIndex >= 0 && selectionState.selectedIndex < filtered.count {
                pasteEntry(filtered[selectionState.selectedIndex])
            }
            return true
        case 51 where event.modifierFlags.contains(.command): // Cmd+Backspace
            if selectionState.selectedIndex >= 0 && selectionState.selectedIndex < filtered.count {
                deleteEntry(filtered[selectionState.selectedIndex])
            }
            return true
        default:
            return false
        }
    }
}

/// Observable state for keyboard selection, shared between the controller and SwiftUI views.
final class SelectionState: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var searchText: String = ""
}
