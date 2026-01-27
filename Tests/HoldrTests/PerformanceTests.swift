import XCTest
@testable import Holdr

final class PerformanceTests: XCTestCase {

    // Create a dummy image data (small red square)
    // We use lazy initialization to not affect test setup time significantly
    lazy var dummyImageData: Data = {
        let size = NSSize(width: 100, height: 100)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.red.drawSwatch(in: NSRect(origin: .zero, size: size))
        image.unlockFocus()
        return image.tiffRepresentation!
    }()

    func testPerformanceNSImageInit() {
        // Baseline: Creating NSImage from Data repeatedly
        // This simulates the behavior without caching, which happens when a view body re-evaluates
        // and re-creates NSImage(data:) synchronously.
        let data = dummyImageData
        measure {
            for _ in 0..<1000 {
                let _ = NSImage(data: data)
            }
        }
    }

    func testPerformanceImageCache() {
        // Optimized: Retrieving from Cache
        // This simulates fetching the pre-decoded image from memory.
        let key = "test-image"
        let data = dummyImageData

        if let image = NSImage(data: data) {
            ImageCache.shared.insert(image, for: key)
        }

        measure {
            for _ in 0..<1000 {
                let _ = ImageCache.shared.image(for: key)
            }
        }
    }
}
