import AppKit

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, NSImage>()

    private init() {
        cache.countLimit = 50 // Keep max 50 images in memory
    }

    func image(for uuid: String) -> NSImage? {
        return cache.object(forKey: uuid as NSString)
    }

    func insert(_ image: NSImage, for uuid: String) {
        cache.setObject(image, forKey: uuid as NSString)
    }

    func remove(for uuid: String) {
        cache.removeObject(forKey: uuid as NSString)
    }
}
