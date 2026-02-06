import sys

filepath = "Sources/Holdr/Services/ClipboardMonitor.swift"

search_text = """    @Published var items: [HistoryItem] = [] {
        didSet {
            print("ClipboardMonitor: items updated, count: \(items.count)")

            // Detect and cleanup removed images
            let oldImages = Set(oldValue.compactMap { item -> String? in
                if case .image(let id) = item.type { return id }
                return nil
            })
            let newImages = Set(items.compactMap { item -> String? in
                if case .image(let id) = item.type { return id }
                return nil
            })

            let removedImages = oldImages.subtracting(newImages)
            for id in removedImages {
                ImageStore.shared.delete(id: id)
            }

            save()
        }
    }"""

replace_text = """    @Published var items: [HistoryItem] = [] {
        didSet {
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
    public private(set) var appNames: [String: String] = [:]"""

with open(filepath, 'r') as f:
    content = f.read()

if search_text in content:
    new_content = content.replace(search_text, replace_text)
    with open(filepath, 'w') as f:
        f.write(new_content)
    print("Successfully updated ClipboardMonitor.swift")
else:
    print("Could not find search text in ClipboardMonitor.swift")
    # Print a snippet of what we found to debug
    start_idx = content.find("@Published var items")
    if start_idx != -1:
        print("Found start at index", start_idx)
        print("Snippet:", content[start_idx:start_idx+200])
    else:
        print("Could not even find @Published var items")
