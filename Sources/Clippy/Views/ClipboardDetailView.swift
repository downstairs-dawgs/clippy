import SwiftUI

struct ClipboardDetailView: View {
    let entry: ClipboardEntry?

    var body: some View {
        Group {
            if let entry = entry {
                detailContent(for: entry)
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }

    @ViewBuilder
    private func detailContent(for entry: ClipboardEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                switch entry.content {
                case .text(let string):
                    Text(string)
                        .font(.system(size: 13, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case .image(let image):
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(12)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clipboard")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text("No entry selected")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}
