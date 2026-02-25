import SwiftUI

struct SidebarView: View {
    @Binding var selection: HistoryItem.Category?
    @ObservedObject var clipboardMonitor: ClipboardMonitor
    @EnvironmentObject var appDiscovery: AppDiscovery
    
    var body: some View {
        List(selection: $selection) {
            Section("Library") {
                ForEach(HistoryItem.Category.allCases) { category in
                    HStack {
                        Label(category.rawValue, systemImage: category.icon)
                        Spacer()
                        badge(count(for: category))
                    }
                    .tag(category)
                    .accessibilityElement(children: .combine)
                }
            }
            
            Section("Running Shelves") {
                ForEach(appDiscovery.runningApps) { app in
                    HStack {
                        Label {
                            Text(app.name)
                        } icon: {
                            Image(nsImage: app.icon)
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        Spacer()
                        badge(count(for: .app(app.bundleID)))
                    }
                    .tag(HistoryItem.Category.app(app.bundleID))
                    .accessibilityElement(children: .combine)
                }
            }
            
            if !otherApps.isEmpty {
                Section("Other History") {
                    ForEach(otherApps) { app in
                        HStack {
                            Label(app.name, systemImage: "clock")
                            Spacer()
                            badge(count(for: .app(app.bundleID)))
                        }
                        .tag(HistoryItem.Category.app(app.bundleID))
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Holdr")
    }
    
    // Apps that are in history but NOT currently running
    private struct HistoryAppDisplay: Hashable, Identifiable {
        var id: String { bundleID }
        let bundleID: String
        let name: String
    }

    private var otherApps: [HistoryAppDisplay] {
        let runningBundleIDs = Set(appDiscovery.runningApps.map { $0.bundleID })
        let cachedApps = clipboardMonitor.appNames

        let historyBundleIDs = Set(cachedApps.keys)
        let uniqueBundleIDs = historyBundleIDs.subtracting(runningBundleIDs)

        return uniqueBundleIDs.sorted().compactMap { bundleID in
            guard let name = cachedApps[bundleID] else { return nil }
            return HistoryAppDisplay(bundleID: bundleID, name: name)
        }
    }

    private func count(for category: HistoryItem.Category) -> Int {
        switch category {
        case .all:
            return clipboardMonitor.items.count
        case .text, .link, .image:
            return clipboardMonitor.items.filter { $0.category == category }.count
        case .app(let bundleID):
            return clipboardMonitor.items.filter { $0.appBundleID == bundleID }.count
        }
    }

    @ViewBuilder
    private func badge(_ count: Int) -> some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.secondary.opacity(0.1))
                )
                .accessibilityLabel("\(count) items")
        }
    }
}
