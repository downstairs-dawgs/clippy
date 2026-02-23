import SwiftUI

struct ClipboardListView: View {
    let entries: [ClipboardEntry]
    @Binding var selectedIndex: Int
    let onSelect: (ClipboardEntry) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        ClipboardRowView(entry: entry, isSelected: index == selectedIndex)
                            .id(index)
                            .onTapGesture {
                                selectedIndex = index
                            }
                            .onTapGesture(count: 2) {
                                onSelect(entry)
                            }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
            }
            .onChange(of: selectedIndex) { newIndex in
                withAnimation(.easeInOut(duration: 0.15)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
}
