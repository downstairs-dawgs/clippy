import SwiftUI

struct ClipboardPanelView: View {
    @ObservedObject var clipboardManager: ClipboardManager
    @ObservedObject var selectionState: SelectionState
    let onSelect: (ClipboardEntry) -> Void
    let onDismiss: () -> Void

    private var filteredEntries: [ClipboardEntry] {
        clipboardManager.filteredEntries(searchText: selectionState.searchText)
    }

    private var selectedEntry: ClipboardEntry? {
        let entries = filteredEntries
        guard selectionState.selectedIndex >= 0 && selectionState.selectedIndex < entries.count else {
            return nil
        }
        return entries[selectionState.selectedIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(searchText: $selectionState.searchText)
                .onChange(of: selectionState.searchText) { _ in
                    selectionState.selectedIndex = 0
                }

            Divider()
                .padding(.horizontal, 12)

            if filteredEntries.isEmpty {
                emptyState
            } else {
                HStack(spacing: 0) {
                    ClipboardListView(
                        entries: filteredEntries,
                        selectionState: selectionState,
                        onSelect: onSelect
                    )
                    .frame(width: 260)

                    Divider()

                    ClipboardDetailView(entry: selectedEntry)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        .cornerRadius(12)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clipboard")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text(selectionState.searchText.isEmpty ? "Clipboard history is empty" : "No matches found")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Text(selectionState.searchText.isEmpty ? "Copy something to get started" : "Try a different search term")
                .font(.system(size: 12))
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// NSVisualEffectView wrapper for vibrancy / blur behind the panel.
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
