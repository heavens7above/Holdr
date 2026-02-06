import SwiftUI
import AppKit
import Combine

class AppDiscovery: ObservableObject {
    @Published var runningApps: [AppInfo] = []
    private var cancellables = Set<AnyCancellable>()
    private let updateQueue = DispatchQueue(label: "com.holdr.appDiscovery.updateQueue", qos: .userInitiated)
    
    struct AppInfo: Identifiable, Hashable {
        var id: String { bundleID }
        let bundleID: String
        let name: String
        let icon: NSImage
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(bundleID)
        }
        
        static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
            return lhs.bundleID == rhs.bundleID
        }
    }
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        // Initial fetch
        updateRunningApps()
        
        // Listen for app launch/terminate notifications with debounce to avoid excessive updates
        let center = NSWorkspace.shared.notificationCenter
        center.publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .merge(with: center.publisher(for: NSWorkspace.didTerminateApplicationNotification))
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateRunningApps() }
            .store(in: &cancellables)
    }
    
    private func updateRunningApps() {
        updateQueue.async { [weak self] in
            let apps = NSWorkspace.shared.runningApplications
                .filter { $0.activationPolicy == .regular } // Only normal apps (with Dock icon)
                .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let apps = NSWorkspace.shared.runningApplications
                .filter { $0.activationPolicy == .regular } // Only normal apps (with Dock icon)
            
            let appInfos = apps.compactMap { app -> AppInfo? in
                guard let bundleID = app.bundleIdentifier,
                      let name = app.localizedName,
                      let icon = app.icon else { return nil }
                return AppInfo(bundleID: bundleID, name: name, icon: icon)
            }

            // Dedup by bundle ID
            let unique = Array(Set(appInfos)).sorted { $0.name < $1.name }

            DispatchQueue.main.async {
                self?.runningApps = unique
            }
        }
    }
}
