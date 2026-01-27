import XCTest
@testable import Holdr

final class PerformanceTests: XCTestCase {

    // --- Legacy Structure (Inefficient) ---
    // Mimics the old structure where Data was embedded
    struct LegacyHistoryItem: Codable {
        var id = UUID()
        let content: String
        let type: LegacyItemType
        let date: Date
        let appBundleID: String?
        let appName: String?

        enum LegacyItemType: Codable {
            case text
            case link(URL)
            case image(Data)
        }

        init(content: String, type: LegacyItemType) {
            self.content = content
            self.type = type
            self.date = Date()
            self.appBundleID = nil
            self.appName = nil
        }
    }

    func testLegacyEncodingPerformance() {
        // Create 50 items with 1MB image data each = 50MB
        let dummyData = Data(count: 1024 * 1024)
        var items: [LegacyHistoryItem] = []
        for _ in 0..<50 {
            items.append(LegacyHistoryItem(content: "Image", type: .image(dummyData)))
        }

        print("Measuring Legacy Encoding (50MB)...")
        measure {
            _ = try? JSONEncoder().encode(items)
        }
    }

    // --- Optimized Structure (Efficient) ---
    // This assumes HistoryItem has been refactored to use image(String)
    func testOptimizedEncodingPerformance() {
        // Create 50 items with just a UUID string reference
        var items: [HistoryItem] = []
        for _ in 0..<50 {
            // Note: This relies on the refactored HistoryItem init and ItemType
            // We use a dummy UUID string.
            // CAUTION: This line requires HistoryItem to be updated to .image(String)
            let type = HistoryItem.ItemType.image(UUID().uuidString)
            items.append(HistoryItem(content: "Image", type: type))
        }

        print("Measuring Optimized Encoding (Metadata only)...")
        measure {
            _ = try? JSONEncoder().encode(items)
        }
    }
}
