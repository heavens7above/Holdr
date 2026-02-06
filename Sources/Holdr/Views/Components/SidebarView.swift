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
        let historyApps = clipboardMonitor.historyApps

        let uniqueBundleIDs = Set(historyApps.keys).subtracting(runningBundleIDs)

        return uniqueBundleIDs.sorted().compactMap { bundleID in
            guard let name = historyApps[bundleID] else { return nil }
        let cachedApps = clipboardMonitor.appNames

        let historyBundleIDs = Set(cachedApps.keys)
        let uniqueBundleIDs = historyBundleIDs.subtracting(runningBundleIDs)

        return uniqueBundleIDs.sorted().compactMap { bundleID in
            guard let name = cachedApps[bundleID] else { return nil }
            return HistoryAppDisplay(bundleID: bundleID, name: name)
        }
    }
}
