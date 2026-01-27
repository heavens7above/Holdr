import XCTest
@testable import Holdr

final class AppDiscoveryTests: XCTestCase {
    func testInitialization() {
        let discovery = AppDiscovery()
        XCTAssertNotNil(discovery)
        // We cannot easily test runningApps count without a mocked NSWorkspace,
        // but this ensures the class initializes and the startMonitoring method runs without crashing.
    }
}
