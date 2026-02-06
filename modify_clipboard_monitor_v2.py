import sys

file_path = 'Sources/Holdr/Services/ClipboardMonitor.swift'

with open(file_path, 'r') as f:
    content = f.read()

# 1. Replace property/method
search_def = '''    var historyBundleIDs: Set<String> = []

    private func rebuildBundleIDs() {
        historyBundleIDs = Set(items.compactMap { $0.appBundleID })
    }'''

replace_def = '''    var historyApps: [String: String] = [:]

    private func updateCache() {
        var apps: [String: String] = [:]
        for item in items {
            if let bid = item.appBundleID, apps[bid] == nil {
                apps[bid] = item.appName ?? "Unknown"
            }
        }
        historyApps = apps
    }'''

if search_def not in content:
    print("Definition block not found")
    sys.exit(1)

content = content.replace(search_def, replace_def)

# 2. Replace call
content = content.replace('rebuildBundleIDs()', 'updateCache()')

with open(file_path, 'w') as f:
    f.write(content)
