import AppKit

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, NSImage>()

    private init() {
        cache.countLimit = 50 // Keep 50 decoded images in memory

    private let cache = NSCache<NSString, NSImage>()

    private init() {
        // reasonable defaults
        cache.countLimit = 100
    }

    func image(forKey key: String) -> NSImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: NSImage, forKey key: String) {
    func insert(_ image: NSImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
