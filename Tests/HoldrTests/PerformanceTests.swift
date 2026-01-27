import XCTest

final class PerformanceTests: XCTestCase {

    // MOCK: Old Structure (Embedding Data)
    struct LegacyHistoryItem: Codable {
        let content: String
        let type: LegacyItemType
        enum LegacyItemType: Codable {
            case image(Data)
        }
    }

    // MOCK: New Structure (Referencing File)
    struct OptimizedHistoryItem: Codable {
        let content: String
        let type: OptimizedItemType
        enum OptimizedItemType: Codable {
            case image(String)
        }
    }

    func testPerformanceComparison() throws {
        // Create 5MB image data
        let largeData = Data(repeating: 0, count: 5 * 1024 * 1024)
        let count = 20

        print("--- Performance Benchmark ---")
        print("Simulating saving \(count) items with 5MB images each (100MB total)")

        // 1. Baseline
        let legacyItems = (0..<count).map { _ in
            LegacyHistoryItem(content: "Image", type: .image(largeData))
        }

        let startLegacy = Date()
        let encodedLegacy = try JSONEncoder().encode(legacyItems)
        let endLegacy = Date()
        let durationLegacy = endLegacy.timeIntervalSince(startLegacy)
        print("Legacy (Embedded Data) Encoding Time: \(String(format: "%.4f", durationLegacy)) seconds. Size: \(encodedLegacy.count / 1024 / 1024) MB")

        // 2. Optimized
        let optimizedItems = (0..<count).map { _ in
            OptimizedHistoryItem(content: "Image", type: .image(UUID().uuidString))
        }

        let startOpt = Date()
        let encodedOpt = try JSONEncoder().encode(optimizedItems)
        let endOpt = Date()
        let durationOpt = endOpt.timeIntervalSince(startOpt)
        print("Optimized (File References) Encoding Time: \(String(format: "%.4f", durationOpt)) seconds. Size: \(encodedOpt.count) bytes")

        let improvement = durationLegacy / durationOpt
        print("Speedup: \(String(format: "%.2f", improvement))x")
        print("-----------------------------")
    }
}
