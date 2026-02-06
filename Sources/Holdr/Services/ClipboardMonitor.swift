import SwiftUI
import AppKit
import UniformTypeIdentifiers

class ClipboardMonitor: ObservableObject {
    var historyApps: [String: String] = [:]

    private func updateCache() {
        var apps: [String: String] = [:]
        for item in items {
            if let bid = item.appBundleID, apps[bid] == nil {
                apps[bid] = item.appName ?? "Unknown"
            }
        }
        historyApps = apps
    }
    @Published var items: [HistoryItem] = [] {
        didSet {
            updateCache()
            print("ClipboardMonitor: items updated, count: \(items.count)")

            // Optimization: Single pass for multiple derived data needs
            var currentImageIDs = Set<String>()
            var newAppNames: [String: String] = [:]

            for item in items {
                // 1. Collect Image IDs
                if case .image(let id) = item.type {
                    currentImageIDs.insert(id)
                }

                // 2. Collect App Names (First wins logic)
                if let bid = item.appBundleID, newAppNames[bid] == nil {
                    newAppNames[bid] = item.appName ?? "Unknown"
                }
            }

            self.appNames = newAppNames

            // Detect and cleanup removed images
            let oldImages = Set(oldValue.compactMap { item -> String? in
                if case .image(let id) = item.type { return id }
                return nil
            })

            let removedImages = oldImages.subtracting(currentImageIDs)
            for id in removedImages {
                ImageStore.shared.delete(id: id)
            }

            save()
        }
    }

    // Cache for O(1) app name lookup
    public private(set) var appNames: [String: String] = [:]
    private var changeCount = 0
    private let pasteboard = NSPasteboard.general
    private let persistenceManager = PersistenceManager.shared

    // Optimized Persistence URL
    private var persistenceURL: URL? {
        return persistenceManager.historyFileURL
    }

    // Legacy support structure for migration
    private struct LegacyHistoryItem: Codable {
        let id: UUID
        let content: String
        let type: LegacyItemType
        let date: Date
        let appBundleID: String?
        let appName: String?

        enum LegacyItemType: Codable {
            case text
            case link(URL)
            case image(Data)
        }
    }

    init() {
        // Load existing history
        load()
        // Save logo in background to avoid blocking main thread initialization
        DispatchQueue.global(qos: .utility).async {
            self.saveLogo()
        }
        
        // Start monitoring
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForChanges()
        }
    }
    
    private func saveLogo() {
        DispatchQueue.global(qos: .utility).async {
            // 1. Save logo file inside the folder (as requested previously)
            guard let folderURL = PersistenceManager.shared.persistenceDirectory else { return }
            let logoURL = folderURL.appendingPathComponent("logo.png")
            
            // Try module first (SPM), then main (App Bundle)
            var resourceURL = Bundle.module.url(forResource: "logo", withExtension: "png")
            if resourceURL == nil {
                 resourceURL = Bundle.main.url(forResource: "logo", withExtension: "png")
            }
            
            // 2. Set the FOLDER ICON (Minimal Style)
            // Composite the app logo onto the standard folder icon
            let folderIcon = NSWorkspace.shared.icon(for: .folder)
            let newIcon = NSImage(size: folderIcon.size)
            
            newIcon.lockFocus()
            // Draw base folder
            folderIcon.draw(in: NSRect(origin: .zero, size: folderIcon.size))
            
            // Draw logo centered and scaled
            let scale: CGFloat = 0.6
            let logoSize = NSSize(width: folderIcon.size.width * scale, height: folderIcon.size.height * scale)
            let logoOrigin = NSPoint(
                x: (folderIcon.size.width - logoSize.width) / 2,
                y: (folderIcon.size.height - logoSize.height) / 2
            )
            
            appLogo.draw(in: NSRect(origin: logoOrigin, size: logoSize), from: .zero, operation: .sourceOver, fraction: 1.0)
            newIcon.unlockFocus()
            
            // Set icon on main thread as it's a UI operation
            DispatchQueue.main.async {
                NSWorkspace.shared.setIcon(newIcon, forFile: folderURL.path, options: [])
            }
        }
    }
    
    private func save() {
        let itemsToSave = self.items
        DispatchQueue.global(qos: .background).async {
            guard let url = self.persistenceURL else { return }
            do {
                let data = try JSONEncoder().encode(itemsToSave)
                // Atomic write prevents corruption if app crashes during write
                try data.write(to: url, options: .atomic)
                print("Saved \(itemsToSave.count) items to disk")
            } catch {
                print("Failed to save history: \(error)")
            }
        }
    }
    
    // Legacy support for migration
    private struct LegacyHistoryItem: Codable {
        let content: String
        let type: LegacyItemType
        let date: Date
        let appBundleID: String?
        let appName: String?

        enum LegacyItemType: Codable {
            case text
            case link(URL)
            case image(Data)
        }
    }

    private func load() {
        // Load in background to prevent blocking main thread (CRASH FIX)
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = self.persistenceURL else { return }

            if !FileManager.default.fileExists(atPath: url.path) { return }
            
            do {
                let data = try Data(contentsOf: url)
                
                // 1. Try decoding current format
                if let loaded = try? JSONDecoder().decode([HistoryItem].self, from: data) {
                    DispatchQueue.main.async {
                        self.items = loaded
                        print("Loaded \(loaded.count) items from disk")
                    }
                    return
                }

                // 2. Try decoding legacy format and migrate
                print("Attempting migration from legacy format...")
                let legacyLoaded = try JSONDecoder().decode([LegacyHistoryItem].self, from: data)

                var migratedItems: [HistoryItem] = []
                for legacy in legacyLoaded {
                    let type: HistoryItem.ItemType
                    switch legacy.type {
                    case .text:
                        type = .text
                    case .link(let url):
                        type = .link(url)
                    case .image(let imageData):
                        // Save image to new store
                        if let id = ImageStore.shared.save(data: imageData) {
                            type = .image(id)
                        } else {
                            // Fallback if save fails, skip or handle error
                            print("Migration: Failed to save image for item \(legacy.id)")
                            continue
                        }
                    }
                    var item = HistoryItem(content: legacy.content, type: type, date: legacy.date, appBundleID: legacy.appBundleID, appName: legacy.appName)
                    item.id = legacy.id
                    migratedItems.append(item)
                }

                DispatchQueue.main.async {
                    self.items = migratedItems
                    print("Migrated and loaded \(migratedItems.count) items from disk")
                    // Trigger save to persist migration (will save new small JSON)
                    self.save()
                }

            } catch {
                print("Failed to load new format, trying legacy: \(error)")
                // 2. Try legacy format
                do {
                    let data = try Data(contentsOf: url)
                    let legacyItems = try JSONDecoder().decode([LegacyHistoryItem].self, from: data)
                    print("Found \(legacyItems.count) legacy items. Migrating...")

                    var newItems: [HistoryItem] = []
                    for item in legacyItems {
                        let newType: HistoryItem.ItemType
                        switch item.type {
                        case .text:
                            newType = .text
                        case .link(let url):
                            newType = .link(url)
                        case .image(let data):
                            guard let uuid = ImageStore.shared.save(data: data) else { continue }
                            newType = .image(uuid)
                        }

                        let newItem = HistoryItem(
                            content: item.content,
                            type: newType,
                            date: item.date,
                            appBundleID: item.appBundleID,
                            appName: item.appName
                        )
                        var finalItem = newItem
                        finalItem.id = item.id
                        newItems.append(finalItem)
                    }

                    // Update UI and Save converted
                    DispatchQueue.main.async {
                        self.items = newItems
                        print("Migrated \(newItems.count) items to new format")
                        self.save()
                    }
                } catch {
                    print("Failed to load history (legacy): \(error)")
                }
            }
        }
    }

    func checkForChanges() {
        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount
            
            // Capture source app
            let frontmost = NSWorkspace.shared.frontmostApplication
            let bundleID = frontmost?.bundleIdentifier
            let appName = frontmost?.localizedName
            
            // Ignore our own pasteboard changes
            if bundleID == Bundle.main.bundleIdentifier {
                return
            }
            
            // 1. Check for Files (Finder)
            var handledAsFile = false
            if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let firstURL = urls.first {
                // Is it an image file?
                // OPTIMIZATION: Check extension first to avoid main thread I/O
                let ext = firstURL.pathExtension
                if !ext.isEmpty, let utType = UTType(filenameExtension: ext), utType.conforms(to: .image) {
                    
                    // Load in background to avoid blocking main thread
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Double check with resource values (robust check off main thread)
                        guard let typeID = try? firstURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
                              let fileType = UTType(typeID),
                              fileType.conforms(to: .image) else { return }

                        if let data = try? Data(contentsOf: firstURL) {
                            DispatchQueue.main.async {
                                // Check duplicate
                                if let first = self.items.first, case .image(let oldData) = first.type, oldData.count == data.count { return }

                                let newItem = HistoryItem(content: firstURL.lastPathComponent, type: .image(data), appBundleID: bundleID, appName: appName)
                                print("Detected file copy: Image from \(appName ?? "Unknown")")
                                self.items.insert(newItem, at: 0)
                            }
                        }
                    }
                    return
                }
            }
            
            if handledAsFile { return }

            // 2. Check for Images (TIFF/PNG from apps)
            // Use readObjects(forClasses: [NSImage.self]) for better coverage
            if pasteboard.canReadObject(forClasses: [NSImage.self], options: nil),
               let images = pasteboard.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage],
               let firstImage = images.first,
               let tiffData = firstImage.tiffRepresentation {
                 
                 // Check duplicate by loading old data
                 if let first = items.first, case .image(let oldID) = first.type,
                    let oldData = ImageStore.shared.load(id: oldID),
                    oldData.count == tiffData.count { return }
                 
                 if let imageID = ImageStore.shared.save(data: tiffData) {
                     let newItem = HistoryItem(content: "Image Clip", type: .image(imageID), appBundleID: bundleID, appName: appName)
                     print("Detected image copy from \(appName ?? "Unknown")")
                     DispatchQueue.main.async { self.items.insert(newItem, at: 0) }
                 }
                 return
            }

        // 3. Check for Strings/URLs
        if let str = pasteboard.string(forType: .string) {
            if let first = items.first, first.content == str { return }

            let type: HistoryItem.ItemType
            if let url = URL(string: str), url.scheme != nil, url.host != nil {
                type = .link(url)
            } else {
                type = .text
            }

            let newItem = HistoryItem(content: str, type: type, appBundleID: bundleID, appName: appName)
            print("Detected text/link copy from \(appName ?? "Unknown")")
            DispatchQueue.main.async { self.items.insert(newItem, at: 0) }
        }
    }
    
    }
    func copyItem(_ item: HistoryItem) {
        pasteboard.clearContents()
        var success = false
        
        switch item.type {
        case .text, .link:
            success = pasteboard.writeObjects([item.content as NSString])
        case .image(let id):
            if let data = ImageStore.shared.load(id: id),
               let image = NSImage(data: data) {
                success = pasteboard.writeObjects([image])
            }
        }
        
        if success {
            print("Successfully wrote to clipboard")
            // Update local changeCount to match the new pasteboard state
            // to avoid detecting our own write as a new change.
            // Update changeCount to ignore this self-induced change
            self.changeCount = pasteboard.changeCount
        } else {
            print("Failed to write to clipboard")
        }
    }
    func deleteItems(_ itemsToDelete: [HistoryItem]) {
        let idsToDelete = Set(itemsToDelete.map { $0.id })
        items.removeAll { idsToDelete.contains($0.id) }
    }

}

// Legacy structure for migration
private struct LegacyHistoryItem: Codable {
    let content: String
    let type: LegacyItemType
    let date: Date
    let appBundleID: String?
    let appName: String?

    enum LegacyItemType: Codable {
        case text
        case link(URL)
        case image(Data)
    }
}
