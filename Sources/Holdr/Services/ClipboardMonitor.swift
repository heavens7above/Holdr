import SwiftUI
import AppKit
import UniformTypeIdentifiers

class ClipboardMonitor: ObservableObject {
    @Published var items: [HistoryItem] = [] {
        didSet {
            print("ClipboardMonitor: items updated, count: \(items.count)")
            save()
        }
    }
    private var changeCount = 0
    private let pasteboard = NSPasteboard.general
    private let persistenceManager = PersistenceManager.shared

    init() {
        // Load existing history
        load()
        saveLogo()
        
        // Start monitoring
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForChanges()
        }
    }
    
    private func saveLogo() {
        // 1. Save logo file inside the folder (as requested previously)
        guard let folderURL = persistenceManager.rootDirectory else { return }
        let logoURL = folderURL.appendingPathComponent("logo.png")
        
        // Try module first (SPM), then main (App Bundle)
        var resourceURL = Bundle.module.url(forResource: "logo", withExtension: "png")
        if resourceURL == nil {
             resourceURL = Bundle.main.url(forResource: "logo", withExtension: "png")
        }
        
        if let bundleLogo = resourceURL,
           let appLogo = NSImage(contentsOf: bundleLogo) {
            
            // Save file
            if !FileManager.default.fileExists(atPath: logoURL.path) {
                try? appLogo.tiffRepresentation?.write(to: logoURL)
            }
            
            // 2. Set the FOLDER ICON (Minimal Style)
            // Composite the app logo onto the standard folder icon
            let folderIcon = NSWorkspace.shared.icon(for: .folder)
            let newIcon = NSImage(size: folderIcon.size)
            
            newIcon.lockFocus()
            // Draw base folder
            folderIcon.draw(in: NSRect(origin: .zero, size: folderIcon.size))
            
            // Draw logo centered and scaled (e.g. 50% size)
            // Adjust scale as needed to match standard macOS look
            let scale: CGFloat = 0.5
            let logoSize = NSSize(width: folderIcon.size.width * scale, height: folderIcon.size.height * scale)
            let logoOrigin = NSPoint(
                x: (folderIcon.size.width - logoSize.width) / 2,
                y: (folderIcon.size.height - logoSize.height) / 2
            )
            
            appLogo.draw(in: NSRect(origin: logoOrigin, size: logoSize), from: .zero, operation: .sourceOver, fraction: 1.0)
            newIcon.unlockFocus()
            
            NSWorkspace.shared.setIcon(newIcon, forFile: folderURL.path, options: [])
        }
    }
    
    private func save() {
        guard let url = persistenceManager.historyFileURL else { return }
        let itemsToSave = self.items
        DispatchQueue.global(qos: .background).async {
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
        guard let url = persistenceManager.historyFileURL else { return }
        
        // Load in background to prevent blocking main thread (CRASH FIX)
        DispatchQueue.global(qos: .userInitiated).async {
            if !FileManager.default.fileExists(atPath: url.path) { return }
            
            do {
                let data = try Data(contentsOf: url)
                // Try to decode new format
                if let loaded = try? JSONDecoder().decode([HistoryItem].self, from: data) {
                    DispatchQueue.main.async {
                        self.items = loaded
                        print("Loaded \(loaded.count) items from disk")
                    }
                    return
                }

                // Fallback: Try decoding legacy format and migrate
                let legacyItems = try JSONDecoder().decode([LegacyHistoryItem].self, from: data)
                print("Migrating \(legacyItems.count) legacy items...")

                var newItems: [HistoryItem] = []
                for legacy in legacyItems {
                    let newType: HistoryItem.ItemType
                    switch legacy.type {
                    case .text:
                        newType = .text
                    case .link(let url):
                        newType = .link(url)
                    case .image(let imageData):
                        if let id = ImageStore.shared.save(data: imageData) {
                            newType = .image(id)
                        } else {
                            continue // Skip if save failed
                        }
                    }

                    let newItem = HistoryItem(
                        content: legacy.content,
                        type: newType,
                        date: legacy.date,
                        appBundleID: legacy.appBundleID,
                        appName: legacy.appName
                    )
                    newItems.append(newItem)
                }
                
                DispatchQueue.main.async {
                    self.items = newItems
                    print("Migration complete. Loaded \(newItems.count) items.")
                    // Trigger save to update file format
                    self.save()
                }

            } catch {
                print("Failed to load history: \(error)")
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
            if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let firstURL = urls.first {
                // Is it an image file?
                if let typeID = try? firstURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
                   let utType = UTType(typeID),
                   utType.conforms(to: .image) {
                    
                    if let data = try? Data(contentsOf: firstURL) {
                         // Check duplicate
                         if let first = items.first, case .image(let id) = first.type {
                             if let oldData = ImageStore.shared.load(id: id), oldData.count == data.count {
                                 return
                             }
                         }
                         
                         if let id = ImageStore.shared.save(data: data) {
                             let newItem = HistoryItem(content: firstURL.lastPathComponent, type: .image(id), appBundleID: bundleID, appName: appName)
                             print("Detected file copy: Image from \(appName ?? "Unknown")")
                             DispatchQueue.main.async { self.items.insert(newItem, at: 0) }
                         }
                         return
                    }
                }
            }
            
            // 2. Check for Images (TIFF/PNG from apps)
            // Use readObjects(forClasses: [NSImage.self]) for better coverage
            if pasteboard.canReadObject(forClasses: [NSImage.self], options: nil),
               let images = pasteboard.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage],
               let firstImage = images.first,
               let tiffData = firstImage.tiffRepresentation {
                 
                 if let first = items.first, case .image(let id) = first.type {
                     if let oldData = ImageStore.shared.load(id: id), oldData.count == tiffData.count {
                         return
                     }
                 }
                 
                 if let id = ImageStore.shared.save(data: tiffData) {
                     let newItem = HistoryItem(content: "Image Clip", type: .image(id), appBundleID: bundleID, appName: appName)
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
            if let data = ImageStore.shared.load(id: id), let image = NSImage(data: data) {
                success = pasteboard.writeObjects([image])
            }
        }
        
        if success {
            print("Successfully wrote to clipboard")
            // Temporarily ignore next change if we want, or rely on bundle ID check
        } else {
            print("Failed to write to clipboard")
        }
    }
}
