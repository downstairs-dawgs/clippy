import AppKit
import SwiftUI

final class FloatingPanelController {
    private var panel: FloatingPanel?
    private let clipboardManager: ClipboardManager
    private let panelWidth: CGFloat = 700
    private let panelHeight: CGFloat = 450
    private var localMonitor: Any?

    /// Tracks which entry is selected via keyboard navigation.
    let selectionState = SelectionState()

    init(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
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
            onSelect: { [weak self] entry in
                self?.pasteEntry(entry)
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
