import SwiftUI

struct ClipboardListView: View {
    let entries: [ClipboardEntry]
    @ObservedObject var selectionState: SelectionState
    let onSelect: (ClipboardEntry) -> Void
    let onDelete: (ClipboardEntry) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        ClipboardRowView(entry: entry, index: index, selectionState: selectionState)
                            .id(entry.id)
                            .contextMenu {
                                Button("Delete") {
                                    onDelete(entry)
                                }
                            }
                            .onTapGesture(count: 2) {
                                onSelect(entry)
                            }
                            .onTapGesture(count: 1) {
                                selectionState.selectedIndex = index
                            }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
            }
            .onChange(of: selectionState.selectedIndex) { newIndex in
                guard newIndex >= 0 && newIndex < entries.count else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    proxy.scrollTo(entries[newIndex].id, anchor: .center)
                }
            }
        }
    }
}
