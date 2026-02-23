import SwiftUI

struct ClipboardListView: View {
    let entries: [ClipboardEntry]
    @Binding var selectedIndex: Int
    let onSelect: (ClipboardEntry) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        ClipboardRowView(entry: entry, isSelected: index == selectedIndex)
                            .id(entry.id)
                            .onTapGesture(count: 2) {
                                onSelect(entry)
                            }
                            .onTapGesture(count: 1) {
                                selectedIndex = index
                            }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
            }
            .onChange(of: selectedIndex) { newIndex in
                guard newIndex >= 0 && newIndex < entries.count else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    proxy.scrollTo(entries[newIndex].id, anchor: .center)
                }
            }
        }
    }
}
