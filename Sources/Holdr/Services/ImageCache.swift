import AppKit

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, NSImage>()

    private init() {
        // reasonable defaults
        cache.countLimit = 100
    }

    func image(forKey key: String) -> NSImage? {
        return cache.object(forKey: key as NSString)
    }

    func insert(_ image: NSImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
