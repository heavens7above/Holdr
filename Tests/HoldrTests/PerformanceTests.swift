import XCTest
@testable import Holdr

final class PerformanceTests: XCTestCase {
    func testInitializationPerformance() {
        // Measure the time it takes to initialize ClipboardMonitor.
        // This baseline helps identify synchronous work on the main thread.
        measure {
            let _ = ClipboardMonitor()
        }
    }
}
