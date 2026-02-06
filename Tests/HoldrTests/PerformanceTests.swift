import XCTest
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
