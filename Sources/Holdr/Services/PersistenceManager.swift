import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private let fileManager = FileManager.default
    private let lock = NSLock()
    private var _persistenceDirectory: URL?

    var persistenceDirectory: URL? {
        lock.lock()
        defer { lock.unlock() }

        if let existing = _persistenceDirectory {
            return existing
        }

        let calculated = computePersistenceDirectory()
        _persistenceDirectory = calculated
        return calculated
    }

    private func computePersistenceDirectory() -> URL? {
        // 1. Try standard iCloud container (if entitled)
        if let iCloudDocs = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
             try? fileManager.createDirectory(at: iCloudDocs, withIntermediateDirectories: true)
             return iCloudDocs
        }

        // 2. Fallback: Explicit path to iCloud Drive (com~apple~CloudDocs) logic from Finder
        // This is often needed for ad-hoc / non-sandboxed builds to "pretend" to use iCloud Drive
        let home = fileManager.homeDirectoryForCurrentUser
        let iCloudDrive = home.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")

        if fileManager.fileExists(atPath: iCloudDrive.path) {
             let folder = iCloudDrive.appendingPathComponent("PastePalClone")
             // Ensure folder exists
             try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
             return folder
        }

        // 3. Final Fallback: Local Application Support
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        let bundleID = Bundle.main.bundleIdentifier ?? "com.example.PastePalClone"
        let folder = appSupport.appendingPathComponent(bundleID)

        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)

        return folder
    }

    var historyFileURL: URL? {
        return persistenceDirectory?.appendingPathComponent("history.json")
    }

    var imagesDirectoryURL: URL? {
        guard let dir = persistenceDirectory else { return nil }
        let imagesDir = dir.appendingPathComponent("images")
        // Create directory if it doesn't exist
        // Optimization: We could cache this too, but for now we rely on OS caching for fileExists
        // or we can optimize it similarly if needed. The task focused on persistenceURL.
        if !fileManager.fileExists(atPath: imagesDir.path) {
            do {
                try fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true)
            } catch {
                print("PersistenceManager: Failed to create images directory: \(error)")
            }
        }
        return imagesDir
    }
}
