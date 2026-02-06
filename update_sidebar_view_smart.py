import sys

filepath = "Sources/Holdr/Views/Components/SidebarView.swift"

with open(filepath, 'r') as f:
    lines = f.readlines()

start_index = -1
end_index = -1

for i, line in enumerate(lines):
    if "private var otherApps: [HistoryAppDisplay] {" in line:
        start_index = i
        break

if start_index != -1:
    # Find the closing brace. Counting braces.
    brace_count = 0
    for i in range(start_index, len(lines)):
        brace_count += lines[i].count('{')
        brace_count -= lines[i].count('}')
        if brace_count == 0:
            end_index = i
            break

if start_index != -1 and end_index != -1:
    new_lines = [
        "    private var otherApps: [HistoryAppDisplay] {\n",
        "        let runningBundleIDs = Set(appDiscovery.runningApps.map { -bash.bundleID })\n",
        "        let cachedApps = clipboardMonitor.appNames\n",
        "\n",
        "        let historyBundleIDs = Set(cachedApps.keys)\n",
        "        let uniqueBundleIDs = historyBundleIDs.subtracting(runningBundleIDs)\n",
        "\n",
        "        return uniqueBundleIDs.sorted().compactMap { bundleID in\n",
        "            guard let name = cachedApps[bundleID] else { return nil }\n",
        "            return HistoryAppDisplay(bundleID: bundleID, name: name)\n",
        "        }\n",
        "    }\n"
    ]

    final_lines = lines[:start_index] + new_lines + lines[end_index+1:]

    with open(filepath, 'w') as f:
        f.writelines(final_lines)
    print("Successfully updated SidebarView.swift")
else:
    print(f"Could not find start/end indices: {start_index}, {end_index}")
