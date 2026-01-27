import AppKit

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, NSImage>()

    private init() {
        cache.countLimit = 100 // Cache up to 100 images
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB limit
    }

    func image(forKey key: String) -> NSImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: NSImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
