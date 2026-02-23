import Foundation

enum SizeLimit: Hashable {
    case limited(Int)
    case unlimited
}

final class SettingsStore: ObservableObject {
    @Published var maxItemSize: SizeLimit = .unlimited
    @Published var maxTotalSize: SizeLimit = .unlimited

    static let itemSizeOptions: [(label: String, value: SizeLimit)] = [
        ("256 KB", .limited(256 * 1024)),
        ("1 MB", .limited(1024 * 1024)),
        ("5 MB", .limited(5 * 1024 * 1024)),
        ("10 MB", .limited(10 * 1024 * 1024)),
        ("Unlimited", .unlimited),
    ]

    static let totalSizeOptions: [(label: String, value: SizeLimit)] = [
        ("10 MB", .limited(10 * 1024 * 1024)),
        ("50 MB", .limited(50 * 1024 * 1024)),
        ("100 MB", .limited(100 * 1024 * 1024)),
        ("500 MB", .limited(500 * 1024 * 1024)),
        ("Unlimited", .unlimited),
    ]

    func isWithinItemLimit(_ byteSize: Int) -> Bool {
        switch maxItemSize {
        case .unlimited:
            return true
        case .limited(let limit):
            return byteSize <= limit
        }
    }
}
