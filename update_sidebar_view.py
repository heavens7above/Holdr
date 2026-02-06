import sys

filepath = "Sources/Holdr/Views/Components/SidebarView.swift"

search_text = """    private var otherApps: [HistoryAppDisplay] {
        let runningBundleIDs = Set(appDiscovery.runningApps.map { -bash.bundleID })

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
    }"""

replace_text = """    private var otherApps: [HistoryAppDisplay] {
        let runningBundleIDs = Set(appDiscovery.runningApps.map { -bash.bundleID })
        let cachedApps = clipboardMonitor.appNames

        let historyBundleIDs = Set(cachedApps.keys)
        let uniqueBundleIDs = historyBundleIDs.subtracting(runningBundleIDs)

        return uniqueBundleIDs.sorted().compactMap { bundleID in
            guard let name = cachedApps[bundleID] else { return nil }
            return HistoryAppDisplay(bundleID: bundleID, name: name)
        }
    }"""

with open(filepath, 'r') as f:
    content = f.read()

if search_text in content:
    new_content = content.replace(search_text, replace_text)
    with open(filepath, 'w') as f:
        f.write(new_content)
    print("Successfully updated SidebarView.swift")
else:
    print("Could not find search text in SidebarView.swift")
