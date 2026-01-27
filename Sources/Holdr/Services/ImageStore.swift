import Foundation

class ImageStore {
    static let shared = ImageStore()

    private init() {}

    func saveImage(data: Data, id: UUID) throws -> String {
        guard let directory = PersistenceManager.shared.imagesDirectory else {
            throw ImageStoreError.directoryNotFound
        }

        let filename = id.uuidString
        let fileURL = directory.appendingPathComponent(filename)

        try data.write(to: fileURL, options: .atomic)
        return filename
    }

    func loadImage(filename: String) -> Data? {
        guard let directory = PersistenceManager.shared.imagesDirectory else { return nil }
        let fileURL = directory.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }

    func deleteImage(filename: String) {
        guard let directory = PersistenceManager.shared.imagesDirectory else { return }
        let fileURL = directory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }

    enum ImageStoreError: Error {
        case directoryNotFound
    }
}
