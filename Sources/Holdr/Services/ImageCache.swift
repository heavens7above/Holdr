import SwiftUI
import AppKit

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, NSImage>()

    private init() {
        // Set limits to prevent memory pressure
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    func image(for key: String) -> NSImage? {
        return cache.object(forKey: key as NSString)
    }

    func insert(_ image: NSImage, for key: String) {
        // Estimate cost: width * height * 4 bytes per pixel
        // Note: NSImage.size is in points, but for cost estimation this is a reasonable proxy
        // for relative size, even if not exact byte count on Retina displays.
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    func remove(for key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func clear() {
        cache.removeAllObjects()
    }
}
