import sys

filepath = "Sources/Holdr/Views/Components/SidebarView.swift"
bad_text = "let runningBundleIDs = Set(appDiscovery.runningApps.map { -bash.bundleID })"
good_text = "let runningBundleIDs = Set(appDiscovery.runningApps.map { $0.bundleID })"

with open(filepath, 'r') as f:
    content = f.read()

if bad_text in content:
    new_content = content.replace(bad_text, good_text)
    with open(filepath, 'w') as f:
        f.write(new_content)
    print("Fixed typo in SidebarView.swift")
else:
    print("Could not find bad text")
    if "-bash.bundleID" in content:
        print("Found -bash.bundleID but not exact line match")
        # Try a more generic replace
        new_content = content.replace("-bash.bundleID", "$0.bundleID")
        with open(filepath, 'w') as f:
            f.write(new_content)
        print("Fixed generic -bash.bundleID")
