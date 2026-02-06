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
import AppKit
@testable import Holdr

final class PerformanceTests: XCTestCase {
    func testImageDecodingPerformance() {
        // Generate a 1024x1024 random image
        let width = 1024
        let height = 1024
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: width * 4,
            bitsPerPixel: 32
        ) else {
            XCTFail("Failed to create bitmap rep")
            return
        }

        // Fill with some data
        if let bitmapData = rep.bitmapData {
            for i in 0..<(width * height * 4) {
                bitmapData[i] = UInt8(i % 255)
            }
        }

        guard let data = rep.representation(using: .png, properties: [:]) else {
            XCTFail("Failed to create test image data")
            return
        }

        measure {
            // Measure the cost of decoding
            let image = NSImage(data: data)
            XCTAssertNotNil(image)
@testable import Holdr

final class PerformanceTests: XCTestCase {
    func testInitializationPerformance() {
        measure {
            let _ = ClipboardMonitor()
        }
    }
}
