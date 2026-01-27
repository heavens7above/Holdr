import XCTest
@testable import Holdr

final class PerformanceTests: XCTestCase {
    func testInitializationPerformance() {
        measure {
            let _ = ClipboardMonitor()
        }
    }
}
