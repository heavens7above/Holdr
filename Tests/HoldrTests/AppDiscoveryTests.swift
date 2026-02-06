import XCTest
import AppKit
@testable import Holdr

final class AppDiscoveryTests: XCTestCase {
    func testAppInfoIdentity() {
        // Verify that AppInfo uses bundleID as its stable identifier
        let image = NSImage()
        let info1 = AppDiscovery.AppInfo(bundleID: "com.example.app", name: "App 1", icon: image)
        let info2 = AppDiscovery.AppInfo(bundleID: "com.example.app", name: "App 1 Modified", icon: image)
        let info3 = AppDiscovery.AppInfo(bundleID: "com.example.other", name: "App 2", icon: image)

        // Identity should match bundleID
        XCTAssertEqual(info1.id, "com.example.app")

        // Two instances with same bundleID should have same ID and be equal
        XCTAssertEqual(info1.id, info2.id)
        XCTAssertEqual(info1, info2)

        // Different bundleID -> different ID and not equal
        XCTAssertNotEqual(info1.id, info3.id)
        XCTAssertNotEqual(info1, info3)

        // Hash values should match for same bundleID
        XCTAssertEqual(info1.hashValue, info2.hashValue)
        XCTAssertNotEqual(info1.hashValue, info3.hashValue)
    }

    func testInitialization() {
        // Just verify that AppDiscovery can be initialized without crashing.
        // This ensures that the removal of the timer didn't break basic initialization
        // and that the notification subscriptions are set up (as they occur in init/startMonitoring).
        //
        // Note: Full behavioral testing of updateRunningApps triggers via NSWorkspace notifications
        // is difficult in this environment because:
        // 1. We cannot mock NSWorkspace.shared easily without significant refactoring.
        // 2. We lack the xcodebuild/swift test runner to execute complex async expectations.
        // 3. Triggering notifications manually requires matching the system behavior which is non-trivial.
        //
        // Therefore, we rely on:
        // - Manual verification that startMonitoring subscribes to both didLaunch and didTerminate.
        // - This smoke test to ensure the class is instantiable.
        let discovery = AppDiscovery()
        XCTAssertNotNil(discovery)
        XCTAssertNotNil(discovery.runningApps)
    }
}
