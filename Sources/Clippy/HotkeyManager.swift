import AppKit

final class HotkeyManager {
    private let handler: () -> Void
    private var globalMonitor: Any?
    private var localMonitor: Any?

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func register() {
        // Global monitor: fires when another app is frontmost
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleEvent(event)
        }

        // Local monitor: fires when our own app is frontmost
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleEvent(event) == true {
                return nil // Consume the event
            }
            return event
        }
    }

    func unregister() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    @discardableResult
    private func handleEvent(_ event: NSEvent) -> Bool {
        // Cmd+Shift+V
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isCmd = flags.contains(.command)
        let isShift = flags.contains(.shift)
        let isV = event.keyCode == 9 // 'V' key

        if isCmd && isShift && isV {
            DispatchQueue.main.async { [weak self] in
                self?.handler()
            }
            return true
        }
        return false
    }

    deinit {
        unregister()
    }
}
