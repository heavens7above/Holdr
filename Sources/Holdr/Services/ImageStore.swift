import Foundation
import AppKit

class ImageStore {
    static let shared = ImageStore()

    private let persistenceManager = PersistenceManager.shared

    func save(data: Data) -> String? {
        guard let dir = persistenceManager.imagesDirectoryURL else { return nil }
        let id = UUID().uuidString
        let url = dir.appendingPathComponent(id)
        do {
            try data.write(to: url)
            return id
        } catch {
            print("ImageStore: Failed to save image \(error)")
            return nil
        }
    }

    func load(id: String) -> Data? {
        guard let dir = persistenceManager.imagesDirectoryURL else { return nil }
        let url = dir.appendingPathComponent(id)
        return try? Data(contentsOf: url)
    }

    func loadImage(id: String) -> NSImage? {
        guard let data = load(id: id) else { return nil }
        return NSImage(data: data)
    }

    func delete(id: String) {
        guard let dir = persistenceManager.imagesDirectoryURL else { return }
        let url = dir.appendingPathComponent(id)
        try? FileManager.default.removeItem(at: url)
    }
}
