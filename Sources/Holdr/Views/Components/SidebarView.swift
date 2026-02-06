import SwiftUI

struct SidebarView: View {
    @Binding var selection: HistoryItem.Category?
    @ObservedObject var clipboardMonitor: ClipboardMonitor
    @EnvironmentObject var appDiscovery: AppDiscovery
    
    var body: some View {
        List(selection: $selection) {
            Section("Library") {
                ForEach(HistoryItem.Category.allCases) { category in
                    Label(category.rawValue, systemImage: category.icon)
                        .tag(category)
                }
            }
            
            Section("Running Shelves") {
                ForEach(appDiscovery.runningApps) { app in
                    HStack {
                        Image(nsImage: app.icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(app.name)
                    }
                    .tag(HistoryItem.Category.app(app.bundleID))
                }
            }
            
            if !otherApps.isEmpty {
                Section("Other History") {
                    ForEach(otherApps) { app in
                        Label(app.name, systemImage: "clock")
                            .tag(HistoryItem.Category.app(app.bundleID))
                    }
                }
            }
            
            Section("Debug Info") {
                Text("Clips: \(clipboardMonitor.items.count)")
                Text("Apps: \(appDiscovery.runningApps.count)")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("PastePal")
    }
    
    // Apps that are in history but NOT currently running
    private struct HistoryAppDisplay: Hashable, Identifiable {
        var id: String { bundleID }
        let bundleID: String
        let name: String
    }

    private var otherApps: [HistoryAppDisplay] {
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
    }
}
