import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private init() {}

    var persistenceURL: URL? {
        // 1. Try standard iCloud container (if entitled)
        if let iCloudDocs = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
             try? FileManager.default.createDirectory(at: iCloudDocs, withIntermediateDirectories: true)
             return iCloudDocs.appendingPathComponent("history.json")
        }

        // 2. Fallback: Explicit path to iCloud Drive (com~apple~CloudDocs) logic from Finder
        // This is often needed for ad-hoc / non-sandboxed builds to "pretend" to use iCloud Drive
        let home = FileManager.default.homeDirectoryForCurrentUser
        let iCloudDrive = home.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")

        if FileManager.default.fileExists(atPath: iCloudDrive.path) {
             let folder = iCloudDrive.appendingPathComponent("PastePalClone")
             // Ensure folder exists
             try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
             return folder.appendingPathComponent("history.json")
        }

        // 3. Final Fallback: Local Application Support
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        let bundleID = Bundle.main.bundleIdentifier ?? "com.example.PastePalClone"
        let folder = appSupport.appendingPathComponent(bundleID)

        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        return folder.appendingPathComponent("history.json")
    }

    var baseDirectory: URL? {
        return persistenceURL?.deletingLastPathComponent()
    }

    var imagesDirectory: URL? {
        guard let base = baseDirectory else { return nil }
        let imagesDir = base.appendingPathComponent("images")
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        return imagesDir
    }
}
