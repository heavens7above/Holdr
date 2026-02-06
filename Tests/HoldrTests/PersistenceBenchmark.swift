import XCTest
@testable import Holdr

final class PersistenceBenchmark: XCTestCase {

    func testPersistenceDirectoryAccessPerformance() {
        // Measure the time it takes to access the persistenceDirectory property 1000 times.
        // Before optimization, this would trigger file system checks 1000 times.
        // After optimization, it should be near-instant (cached).

        measure {
            for _ in 0..<1000 {
                _ = PersistenceManager.shared.persistenceDirectory
            }
        }
    }
}
