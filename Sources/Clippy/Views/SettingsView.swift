import SwiftUI
import AppKit
import Carbon

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            HStack {
                Text("Max item size:")
                Picker("", selection: $settings.maxItemSize) {
                    ForEach(SettingsStore.itemSizeOptions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
            }

            HStack {
                Text("Max total size:")
                Picker("", selection: $settings.maxTotalSize) {
                    ForEach(SettingsStore.totalSizeOptions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
            }

            HStack {
                Text("Shortcut:")
                ShortcutRecorderView(shortcut: $settings.shortcut)
            }
        }
        .padding()
        .frame(width: 260)
    }
}

// MARK: - ShortcutRecorderView

struct ShortcutRecorderView: NSViewRepresentable {
    @Binding var shortcut: CustomShortcut

    func makeNSView(context: Context) -> ShortcutCaptureView {
        let view = ShortcutCaptureView()
        view.shortcut = shortcut
        view.onShortcutChanged = { newShortcut in
            shortcut = newShortcut
        }
        return view
    }

    func updateNSView(_ nsView: ShortcutCaptureView, context: Context) {
        nsView.shortcut = shortcut
        nsView.needsDisplay = true
    }
}

final class ShortcutCaptureView: NSView {
    var shortcut: CustomShortcut = .default
    var onShortcutChanged: ((CustomShortcut) -> Void)?
    private var isRecording = false

    override var acceptsFirstResponder: Bool { true }

    override var intrinsicContentSize: NSSize {
        NSSize(width: 120, height: 24)
    }

    override func draw(_ dirtyRect: NSRect) {
        let bg: NSColor = isRecording ? .selectedControlColor : .controlBackgroundColor
        bg.setFill()
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), xRadius: 4, yRadius: 4)
        path.fill()

        NSColor.separatorColor.setStroke()
        path.lineWidth = 1
        path.stroke()

        let text = isRecording ? "Press shortcut..." : shortcut.displayString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: isRecording ? NSColor.selectedControlTextColor : NSColor.labelColor,
        ]
        let str = NSAttributedString(string: text, attributes: attrs)
        let size = str.size()
        let point = NSPoint(
            x: (bounds.width - size.width) / 2,
            y: (bounds.height - size.height) / 2
        )
        str.draw(at: point)
    }

    override func mouseDown(with event: NSEvent) {
        isRecording = true
        window?.makeFirstResponder(self)
        needsDisplay = true
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        // Escape cancels
        if event.keyCode == UInt16(kVK_Escape) {
            isRecording = false
            needsDisplay = true
            return
        }

        let carbonModifiers = event.carbonModifiers
        let hasModifier = (carbonModifiers & UInt32(cmdKey) != 0)
            || (carbonModifiers & UInt32(controlKey) != 0)
            || (carbonModifiers & UInt32(optionKey) != 0)

        guard hasModifier else { return }

        let newShortcut = CustomShortcut(keyCode: UInt32(event.keyCode), modifiers: carbonModifiers)
        shortcut = newShortcut
        isRecording = false
        needsDisplay = true
        onShortcutChanged?(newShortcut)
    }

    override func resignFirstResponder() -> Bool {
        isRecording = false
        needsDisplay = true
        return super.resignFirstResponder()
    }
}

// MARK: - NSEvent Carbon modifier conversion

private extension NSEvent {
    var carbonModifiers: UInt32 {
        var carbon: UInt32 = 0
        if modifierFlags.contains(.command) { carbon |= UInt32(cmdKey) }
        if modifierFlags.contains(.option) { carbon |= UInt32(optionKey) }
        if modifierFlags.contains(.control) { carbon |= UInt32(controlKey) }
        if modifierFlags.contains(.shift) { carbon |= UInt32(shiftKey) }
        return carbon
    }
}
