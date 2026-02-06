import XCTest
import AppKit
@testable import Holdr

final class PerformanceBenchmarkTests: XCTestCase {

    // Minimal 1x1 PNG data
    let pngData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==")!

    func testImageDecodingPerformance() {
        // Create an item
        let item = HistoryItem(content: "img", type: .image(pngData))

        // Measure Raw Decoding
        let startTimeRaw = CFAbsoluteTimeGetCurrent()
        for _ in 0..<1000 {
            if case .image(let data) = item.type {
                _ = NSImage(data: data)
            }
        }
        let timeRaw = CFAbsoluteTimeGetCurrent() - startTimeRaw
        print("Raw Decoding (1000 iter): \(timeRaw) seconds")

        // Measure Cached Access
        // First access primes the cache
        _ = ImageCache.shared.image(for: item)

        let startTimeCached = CFAbsoluteTimeGetCurrent()
        for _ in 0..<1000 {
            _ = ImageCache.shared.image(for: item)
        }
        let timeCached = CFAbsoluteTimeGetCurrent() - startTimeCached
        print("Cached Access (1000 iter): \(timeCached) seconds")

        // Prevent division by zero if cached is 0.0 (unlikely but possible with very low precision/fast machine)
        if timeCached > 0 {
            print("Speedup: \(timeRaw / timeCached)x")
        } else {
             print("Speedup: Infinite (cached time was 0)")
        }

        XCTAssert(timeCached < timeRaw, "Cached access should be faster than raw decoding")
    }
}
