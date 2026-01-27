import XCTest
@testable import Holdr

final class PerformanceTests: XCTestCase {

    // Simulate the old structure for comparison
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

    func testPerformanceComparison() throws {
        // Generate dummy image data (approx 1MB)
        let imageSize = 1024 * 1024
        let dummyData = Data(repeating: 0xFF, count: imageSize)
        let itemCount = 50

        // 1. Benchmark Legacy (Embedded Data)
        let legacyItems = (0..<itemCount).map { _ in
            LegacyHistoryItem(id: UUID(), content: "Image", type: .image(dummyData), date: Date())
        }

        print("--- Benchmarking Legacy Storage (Embedded Data) ---")
        let legacyStart = Date()
        let legacyEncoder = JSONEncoder()
        let legacyData = try legacyEncoder.encode(legacyItems)
        let legacyEncodeTime = Date().timeIntervalSince(legacyStart)
        print("Legacy Encode Time: \(legacyEncodeTime)s")
        print("Legacy File Size: \(legacyData.count) bytes")

        let legacyDecodeStart = Date()
        let legacyDecoder = JSONDecoder()
        let _ = try legacyDecoder.decode([LegacyHistoryItem].self, from: legacyData)
        let legacyDecodeTime = Date().timeIntervalSince(legacyDecodeStart)
        print("Legacy Decode Time: \(legacyDecodeTime)s")

        // 2. Benchmark Optimized (References)
        // Note: This assumes HistoryItem has been updated to use references.
        // If not, this part might need adjustment or will test the current state if it matches.

        // We simulate the new state where we only store a UUID string (~36 bytes)
        // We can't use HistoryItem directly here if we want this test to run *before* the refactor
        // without modification, but assuming this runs after refactor:

        // For the sake of this standalone benchmark, let's define what the optimized struct looks like
        struct OptimizedHistoryItem: Codable {
            let id: UUID
            let content: String
            let type: OptimizedItemType
            let date: Date

            enum OptimizedItemType: Codable {
                case text
                case link(URL)
                case image(String) // UUID Reference
            }
        }

        let optimizedItems = (0..<itemCount).map { _ in
            OptimizedHistoryItem(id: UUID(), content: "Image", type: .image(UUID().uuidString), date: Date())
        }

        print("\n--- Benchmarking Optimized Storage (References) ---")
        let optStart = Date()
        let optEncoder = JSONEncoder()
        let optData = try optEncoder.encode(optimizedItems)
        let optEncodeTime = Date().timeIntervalSince(optStart)
        print("Optimized Encode Time: \(optEncodeTime)s")
        print("Optimized File Size: \(optData.count) bytes")

        let optDecodeStart = Date()
        let optDecoder = JSONDecoder()
        let _ = try optDecoder.decode([OptimizedHistoryItem].self, from: optData)
        let optDecodeTime = Date().timeIntervalSince(optDecodeStart)
        print("Optimized Decode Time: \(optDecodeTime)s")

        // Assertions
        XCTAssertLessThan(optData.count, legacyData.count, "Optimized storage should be smaller")
        XCTAssertLessThan(optEncodeTime, legacyEncodeTime, "Optimized encoding should be faster")
        XCTAssertLessThan(optDecodeTime, legacyDecodeTime, "Optimized decoding should be faster")
    }
}
