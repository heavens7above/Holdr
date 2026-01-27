import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private let fileManager = FileManager.default

    var rootDirectory: URL? {
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
             let folder = iCloudDrive.appendingPathComponent("PastePalClone") // Keeping the original folder name for compatibility
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
        return rootDirectory?.appendingPathComponent("history.json")
    }

    var imagesDirectoryURL: URL? {
        guard let root = rootDirectory else { return nil }
        let imagesDir = root.appendingPathComponent("images")
        if !fileManager.fileExists(atPath: imagesDir.path) {
            try? fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        return imagesDir
    }
}
