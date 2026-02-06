import sys

file_path = 'Sources/Holdr/Services/ClipboardMonitor.swift'

with open(file_path, 'r') as f:
    content = f.read()

content = content.replace('-bash.appBundleID', '$0.appBundleID')

with open(file_path, 'w') as f:
    f.write(content)
