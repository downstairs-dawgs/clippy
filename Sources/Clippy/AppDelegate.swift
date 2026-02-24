import AppKit
import ApplicationServices
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let settingsStore = SettingsStore()
    private var clipboardManager: ClipboardManager!
    private var hotkeyManager: HotkeyManager!
    private var panelController: FloatingPanelController!
    private var shortcutCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        promptForAccessibility()
        setupStatusItem()

        clipboardManager = ClipboardManager(settings: settingsStore)
        panelController = FloatingPanelController(
            clipboardManager: clipboardManager,
            settings: settingsStore
        )

        hotkeyManager = HotkeyManager { [weak self] in
            self?.togglePanel()
        }
        let initial = settingsStore.shortcut
        hotkeyManager.register(keyCode: initial.keyCode, modifiers: initial.modifiers)

        shortcutCancellable = settingsStore.$shortcut
            .dropFirst()
            .sink { [weak self] newShortcut in
                self?.hotkeyManager.reregister(keyCode: newShortcut.keyCode, modifiers: newShortcut.modifiers)
            }

        clipboardManager.startPolling()
    }

    /// Prompt user to grant Accessibility permission (needed for global hotkey and paste simulation).
    /// Only shows the system dialog if the app hasn't already been granted access.
    private func promptForAccessibility() {
        if AXIsProcessTrusted() { return }
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
