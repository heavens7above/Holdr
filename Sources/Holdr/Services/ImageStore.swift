import Foundation

class ImageStore {
    static let shared = ImageStore()

    private init() {}

    private var imagesDirectory: URL {
        let dir = PersistenceManager.storageDirectory.appendingPathComponent("images")
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func save(data: Data) -> String? {
        let uuid = UUID().uuidString
        let url = imagesDirectory.appendingPathComponent(uuid)
        do {
            try data.write(to: url)
            return uuid
        } catch {
            print("ImageStore: Failed to save image \(uuid): \(error)")
            return nil
        }
    }

    func load(uuid: String) -> Data? {
        let url = imagesDirectory.appendingPathComponent(uuid)
        return try? Data(contentsOf: url)
    }

    func delete(uuid: String) {
        let url = imagesDirectory.appendingPathComponent(uuid)
        try? FileManager.default.removeItem(at: url)
    }
}
