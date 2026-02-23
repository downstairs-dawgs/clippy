# Clippy

A native macOS clipboard history manager. Lives in the menu bar, tracks everything you copy, and lets you quickly paste previous entries with a global hotkey.

## Features

- **Global hotkey** — Cmd+Shift+V opens a floating panel
- **Split-view UI** — scrollable entry list on the left, full preview on the right
- **Search** — filter clipboard history by text content
- **Keyboard navigation** — arrow keys to browse, Enter to paste, Escape to dismiss
- **Text & image support** — captures both plain text and images
- **Non-activating panel** — doesn't steal focus from your current app
- **Paste-back** — selected entry is written to the pasteboard and pasted into the frontmost app automatically
- **Deduplication** — re-copying the same text moves it to the top instead of creating a duplicate
- **100 entry cap** — oldest entries are trimmed automatically
- **In-memory only** — history is cleared when the app quits

## Requirements

- macOS 13+
- Swift 5.9+

## Build & Run

```
swift build
swift run Clippy
```

## Permissions

On first launch, macOS will prompt for:

- **Input Monitoring** — required for the global Cmd+Shift+V hotkey
- **Accessibility** — required for simulating Cmd+V paste-back

Grant both in System Settings → Privacy & Security.

## Usage

1. Launch Clippy — a paperclip icon appears in the menu bar
2. Copy text or images as usual — they appear in Clippy's history
3. Press **Cmd+Shift+V** to open the clipboard panel
4. Use **↑/↓** arrow keys or click to select an entry
5. Press **Enter** or double-click to paste the selected entry
6. Press **Escape** to dismiss the panel

Right-click the menu bar icon to clear history or quit.
