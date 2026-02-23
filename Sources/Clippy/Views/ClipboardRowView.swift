import SwiftUI

struct ClipboardRowView: View {
    let entry: ClipboardEntry
    let index: Int
    @ObservedObject var selectionState: SelectionState

    private var isSelected: Bool {
        index == selectionState.selectedIndex
    }

    var body: some View {
        HStack(spacing: 8) {
            entryIcon
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayText)
                    .font(.system(size: 13))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)

                Text(entry.relativeTimestamp)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        )
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var entryIcon: some View {
        switch entry.content {
        case .text:
            Image(systemName: "doc.on.doc")
                .foregroundColor(.secondary)
        case .image(let nsImage):
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
