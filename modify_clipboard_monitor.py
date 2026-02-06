import sys

file_path = 'Sources/Holdr/Services/ClipboardMonitor.swift'

with open(file_path, 'r') as f:
    content = f.read()

# 1. Insert property and method
search_class = 'class ClipboardMonitor: ObservableObject {'
insert_code = '''class ClipboardMonitor: ObservableObject {
    var historyBundleIDs: Set<String> = []

    private func rebuildBundleIDs() {
        historyBundleIDs = Set(items.compactMap { -bash.appBundleID })
    }'''

content = content.replace(search_class, insert_code)

# 2. Call method in didSet
search_print = 'print("ClipboardMonitor: items updated, count: \(items.count)")'
insert_call = '''rebuildBundleIDs()
            print("ClipboardMonitor: items updated, count: \(items.count)")'''

content = content.replace(search_print, insert_call)

with open(file_path, 'w') as f:
    f.write(content)
