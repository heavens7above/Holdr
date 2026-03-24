import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private let fileManager = FileManager.default
    private let lock = NSRecursiveLock()
    private var _persistenceDirectory: URL?
    private var _historyFileURL: URL?
    private var _imagesDirectoryURL: URL?

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
        lock.lock()
        defer { lock.unlock() }

        if let existing = _historyFileURL {
            return existing
        }

        let calculated = persistenceDirectory?.appendingPathComponent("history.json")
        _historyFileURL = calculated
        return calculated
    }

    var imagesDirectoryURL: URL? {
        lock.lock()
        defer { lock.unlock() }

        if let existing = _imagesDirectoryURL {
            return existing
        }

        guard let dir = persistenceDirectory else { return nil }
        let imagesDir = dir.appendingPathComponent("images")

        if !fileManager.fileExists(atPath: imagesDir.path) {
            do {
                try fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true)
            } catch {
                print("PersistenceManager: Failed to create images directory: \(error)")
            }
        }

        _imagesDirectoryURL = imagesDir
        return imagesDir
    }
}
