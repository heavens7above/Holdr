import Foundation

struct LegacyHistoryItem: Identifiable, Hashable, Codable {
    var id = UUID()
    let content: String
    let type: ItemType
    let date: Date
    let appBundleID: String?
    let appName: String?

    // Auto-computed category for sidebar
    var category: Category {
        switch type {
        case .text: return .text
        case .link: return .link
        case .image: return .image
        }
    }

    enum ItemType: Hashable, Codable {
        case text
        case link(URL)
        case image(Data)
    }

    enum Category: Hashable, Identifiable {
        case all
        case text
        case link
        case image
        case app(String) // Bundle ID

        var id: String {
            switch self {
            case .all: return "All"
            case .text: return "Text"
            case .link: return "Links"
            case .image: return "Images"
            case .app(let id): return "App_\(id)"
            }
        }
    }
}
