import sys

file_path = 'Sources/Holdr/Views/Components/SidebarView.swift'

with open(file_path, 'r') as f:
    content = f.read()

search_text = 'let historyBundleIDs = Set(clipboardMonitor.items.compactMap { $0.appBundleID })'
replace_text = 'let historyBundleIDs = clipboardMonitor.historyBundleIDs'

if search_text not in content:
    print("Search text not found!")
    sys.exit(1)

content = content.replace(search_text, replace_text)

with open(file_path, 'w') as f:
    f.write(content)
