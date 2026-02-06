import sys

file_path = 'Sources/Holdr/Views/Components/SidebarView.swift'

with open(file_path, 'r') as f:
    content = f.read()

search_text = '''    private var otherApps: [HistoryAppDisplay] {
        let runningBundleIDs = Set(appDiscovery.runningApps.map { $0.bundleID })

        // Single pass to collect bundle IDs and names
        var apps: [String: String] = [:]
        for item in clipboardMonitor.items {
            if let bid = item.appBundleID {
                // Keep the first name encountered to match original behavior
                if apps[bid] == nil {
                    apps[bid] = item.appName ?? "Unknown"
                }
            }
        }

        let historyBundleIDs = Set(apps.keys)
        let uniqueBundleIDs = historyBundleIDs.subtracting(runningBundleIDs)

        return uniqueBundleIDs.sorted().compactMap { bundleID in
            guard let name = apps[bundleID] else { return nil }
            return HistoryAppDisplay(bundleID: bundleID, name: name)
        }
    }'''

replace_text = '''    private var otherApps: [HistoryAppDisplay] {
        let runningBundleIDs = Set(appDiscovery.runningApps.map { $0.bundleID })
        let historyApps = clipboardMonitor.historyApps

        let uniqueBundleIDs = Set(historyApps.keys).subtracting(runningBundleIDs)

        return uniqueBundleIDs.sorted().compactMap { bundleID in
            guard let name = historyApps[bundleID] else { return nil }
            return HistoryAppDisplay(bundleID: bundleID, name: name)
        }
    }'''

if search_text not in content:
    print("Search text not found")
    sys.exit(1)

content = content.replace(search_text, replace_text)

with open(file_path, 'w') as f:
    f.write(content)
