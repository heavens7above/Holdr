import XCTest

final class PerformanceTests: XCTestCase {
    func testFileReadPerformance() throws {
        // Create a 50MB temporary file
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_large_file.dat")
        let dataSize = 50 * 1024 * 1024 // 50MB
        let data = Data(repeating: 0, count: dataSize)
        try data.write(to: fileURL)

        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        measure {
            // Measure the time to read the file synchronously
            _ = try? Data(contentsOf: fileURL)
        }
    }
}
