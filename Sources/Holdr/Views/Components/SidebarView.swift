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
                    ForEach(otherApps, id: \.self) { bundleID in
                        Label(appName(for: bundleID), systemImage: "clock")
                            .tag(HistoryItem.Category.app(bundleID))
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
    var otherApps: [String] {
        let historyBundleIDs = Set(clipboardMonitor.items.compactMap { $0.appBundleID })
        let runningBundleIDs = Set(appDiscovery.runningApps.map { $0.bundleID })
        return Array(historyBundleIDs.subtracting(runningBundleIDs)).sorted()
    }
    
    func appName(for bundleID: String) -> String {
        return clipboardMonitor.items.first(where: { $0.appBundleID == bundleID })?.appName ?? "Unknown"
    }
}
