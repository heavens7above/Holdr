import XCTest
@testable import Holdr

final class PerformanceBenchmarks: XCTestCase {

    func testResizeLogoPerformance() {
        // This measures the baseline performance of the original resizeLogo logic
        measure {
            // Emulate the repeated call in the view body
            for _ in 0..<100 {
                _ = resizeLogoBaseline()
            }
        }
    }

    // Copy of the original logic for benchmarking purposes
    private func resizeLogoBaseline() -> NSImage? {
        // Try module first (SPM), then main (App Bundle)
        var logoURL = Bundle.module.url(forResource: "menubar_icon", withExtension: "png")
        if logoURL == nil {
            logoURL = Bundle.main.url(forResource: "menubar_icon", withExtension: "png")
        }

        guard let url = logoURL else { return nil }
        guard let nsImage = NSImage(contentsOf: url) else { return nil }

        // Resize to standard menu bar icon size (e.g. 18x18 or 22x22 depending on padding)
        let size = NSSize(width: 22, height: 22)
        let resized = NSImage(size: size)

        resized.lockFocus()
        nsImage.draw(in: NSRect(origin: .zero, size: size))
        resized.unlockFocus()

        // Set template to false to keep original colors
        resized.isTemplate = false

        return resized
    }
}
