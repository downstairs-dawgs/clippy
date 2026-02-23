import AppKit
import ApplicationServices
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let clipboardManager = ClipboardManager()
    private var hotkeyManager: HotkeyManager!
    private var panelController: FloatingPanelController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        promptForAccessibility()
        setupStatusItem()

        panelController = FloatingPanelController(clipboardManager: clipboardManager)

        hotkeyManager = HotkeyManager { [weak self] in
            self?.togglePanel()
        }
        hotkeyManager.register()

        clipboardManager.startPolling()
    }

    /// Prompt user to grant Accessibility permission (needed for global hotkey and paste simulation).
    private func promptForAccessibility() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "Clippy")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Clipboard History", action: #selector(showPanel), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Clippy", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func togglePanel() {
        panelController.toggle()
    }

    @objc private func showPanel() {
        panelController.show()
    }

    @objc private func clearHistory() {
        clipboardManager.entries.removeAll()
    }

    @objc private func quitApp() {
        clipboardManager.stopPolling()
        NSApp.terminate(nil)
    }
}
