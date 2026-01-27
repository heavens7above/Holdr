import Foundation
import AppKit

class ImageStore {
    static let shared = ImageStore()

    private init() {}

    func save(data: Data, id: String) {
        guard let dir = PersistenceManager.shared.imagesDirectory else { return }
        let url = dir.appendingPathComponent(id)

        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print("ImageStore: Failed to save image \(id): \(error)")
        }
    }

    func load(id: String) -> Data? {
        guard let dir = PersistenceManager.shared.imagesDirectory else { return nil }
        let url = dir.appendingPathComponent(id)

        // Check if file exists to avoid error logs
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("ImageStore: Failed to load image \(id): \(error)")
            return nil
        }
    }

    func delete(id: String) {
        guard let dir = PersistenceManager.shared.imagesDirectory else { return }
        let url = dir.appendingPathComponent(id)

        try? FileManager.default.removeItem(at: url)
    }

    func url(for id: String) -> URL? {
        guard let dir = PersistenceManager.shared.imagesDirectory else { return nil }
        return dir.appendingPathComponent(id)
    }

    // Helper to clear unused images could be added later
}
