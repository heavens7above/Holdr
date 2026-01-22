import Foundation

struct HistoryItem: Identifiable, Hashable, Codable {
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

    init(content: String, type: ItemType, date: Date = Date(), appBundleID: String? = nil, appName: String? = nil) {
        self.content = content
        self.type = type
        self.date = date
        self.appBundleID = appBundleID
        self.appName = appName
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
        
        var rawValue: String {
            switch self {
            case .all: return "All"
            case .text: return "Text"
            case .link: return "Links"
            case .image: return "Images"
            case .app(let id): return id
            }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Category, rhs: Category) -> Bool {
            return lhs.id == rhs.id
        }
        
        // Helper for conformance to CaseIterable manually since we added associated value
        static var allCases: [Category] = [.all, .text, .link, .image]
        
        var icon: String {
            switch self {
            case .all: return "tray.full"
            case .text: return "text.alignleft"
            case .link: return "link"
            case .image: return "photo"
            case .app: return "app"
            }
        }
    }
}
