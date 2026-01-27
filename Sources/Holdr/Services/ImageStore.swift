import Foundation

class ImageStore {
    static let shared = ImageStore()

    private init() {}

    private var imagesDirectory: URL? {
        return PersistenceManager.shared.imagesDirectoryURL
    }

    func save(data: Data) -> String? {
        guard let dir = imagesDirectory else { return nil }
        let id = UUID().uuidString
        let url = dir.appendingPathComponent(id)
        do {
            try data.write(to: url, options: .atomic)
            return id
        } catch {
            print("ImageStore: Failed to save image \(error)")
            return nil
        }
    }

    func load(id: String) -> Data? {
        guard let dir = imagesDirectory else { return nil }
        let url = dir.appendingPathComponent(id)
        return try? Data(contentsOf: url)
    }

    func delete(id: String) {
        guard let dir = imagesDirectory else { return }
        let url = dir.appendingPathComponent(id)
        try? FileManager.default.removeItem(at: url)
    }

    func url(for id: String) -> URL? {
        return imagesDirectory?.appendingPathComponent(id)
    }
}
