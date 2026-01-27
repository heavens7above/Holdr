import Foundation

struct PersistenceManager {
    static let storageDirectory: URL = {
        // 1. Try standard iCloud container (if entitled)
        if let iCloudDocs = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
             if !FileManager.default.fileExists(atPath: iCloudDocs.path) {
                 try? FileManager.default.createDirectory(at: iCloudDocs, withIntermediateDirectories: true)
             }
             return iCloudDocs
        }

        // 2. Fallback: Explicit path to iCloud Drive (com~apple~CloudDocs) logic from Finder
        let home = FileManager.default.homeDirectoryForCurrentUser
        let iCloudDrive = home.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")

        if FileManager.default.fileExists(atPath: iCloudDrive.path) {
             let folder = iCloudDrive.appendingPathComponent("PastePalClone")
             if !FileManager.default.fileExists(atPath: folder.path) {
                 try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
             }
             return folder
        }

        // 3. Final Fallback: Local Application Support
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return FileManager.default.temporaryDirectory
        }
        let bundleID = Bundle.main.bundleIdentifier ?? "com.example.PastePalClone"
        let folder = appSupport.appendingPathComponent(bundleID)

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        return folder
    }()

    static var historyFile: URL {
        return storageDirectory.appendingPathComponent("history.json")
    }
}
