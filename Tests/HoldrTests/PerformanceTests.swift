import XCTest
@testable import Holdr

final class PerformanceTests: XCTestCase {

    // Legacy Structure (Embedded Data)
    struct LegacyHistoryItem: Codable {
        let id: UUID
        let content: String
        let type: LegacyItemType
        let date: Date

        enum LegacyItemType: Codable {
            case text
            case link(URL)
            case image(Data)
        }
    }

    // Optimized Structure (Reference)
    struct OptimizedHistoryItem: Codable {
        let id: UUID
        let content: String
        let type: OptimizedItemType
        let date: Date

        enum OptimizedItemType: Codable {
            case text
            case link(URL)
            case image(String) // Reference ID
        }
    }

    func testLegacyEncodingPerformance() throws {
        // Create 50 large items (e.g. 1MB each)
        // 50MB total data
        let data = Data(repeating: 0, count: 1_000_000) // 1MB
        let items = (0..<50).map { _ in
            LegacyHistoryItem(id: UUID(), content: "Image", type: .image(data), date: Date())
        }

        print("Measuring Legacy Encoding (50MB)...")
        measure {
            do {
                _ = try JSONEncoder().encode(items)
            } catch {
                XCTFail("Encoding failed: \(error)")
            }
        }
    }

    func testOptimizedEncodingPerformance() throws {
        // Create 50 items with references
        // Negligible size
        let items = (0..<50).map { _ in
            OptimizedHistoryItem(id: UUID(), content: "Image", type: .image(UUID().uuidString), date: Date())
        }

        print("Measuring Optimized Encoding (Refs)...")
        measure {
            do {
                _ = try JSONEncoder().encode(items)
            } catch {
                XCTFail("Encoding failed: \(error)")
            }
        }
    }
}
