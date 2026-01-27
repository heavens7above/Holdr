import XCTest
@testable import Holdr

final class BenchmarkTests: XCTestCase {

    func testInitializationPerformance() {
        // Measure the time it takes to initialize ClipboardMonitor.
        // This baseline includes synchronous file I/O (persistenceURL access, saveLogo).
        // Optimization goal: Move these off the main thread so init returns immediately.

        let options = XCTMeasureOptions()
        options.iterationCount = 10

        measure(options: options) {
            let _ = ClipboardMonitor()
        }
    }
}
