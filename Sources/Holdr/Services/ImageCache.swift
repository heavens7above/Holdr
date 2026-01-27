import AppKit

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, NSImage>()

    private init() {
        cache.countLimit = 200
    }

    func image(for item: HistoryItem) -> NSImage? {
        let key = item.id.uuidString as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        if case .image(let data) = item.type, let image = NSImage(data: data) {
            cache.setObject(image, forKey: key)
            return image
        }

        return nil
    }
}
