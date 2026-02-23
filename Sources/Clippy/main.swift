import AppKit
import Foundation

// Re-launch as a background process if started from a terminal
if isatty(STDIN_FILENO) == 1 && !CommandLine.arguments.contains("--background") {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
    process.arguments = Array(CommandLine.arguments.dropFirst()) + ["--background"]
    process.standardInput = FileHandle.nullDevice
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    try? process.run()
    _exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
