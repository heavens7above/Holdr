import SwiftUI
import AppKit
import Combine

class AppDiscovery: ObservableObject {
    @Published var runningApps: [AppInfo] = []
    private var cancellables = Set<AnyCancellable>()
    
    struct AppInfo: Identifiable, Hashable {
        let id = UUID()
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
        
        // Listen for app launch/terminate notifications
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .sink { [weak self] _ in self?.updateRunningApps() }
            .store(in: &cancellables)
            
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didTerminateApplicationNotification)
            .sink { [weak self] _ in self?.updateRunningApps() }
            .store(in: &cancellables)
    }
    
    private func updateRunningApps() {
        let apps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular } // Only normal apps (with Dock icon)
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
            
        let appInfos = apps.compactMap { app -> AppInfo? in
            guard let bundleID = app.bundleIdentifier,
                  let name = app.localizedName,
                  let icon = app.icon else { return nil }
            return AppInfo(bundleID: bundleID, name: name, icon: icon)
        }
        
        // Dedup by bundle ID
        let unique = Array(Set(appInfos)).sorted { $0.name < $1.name }
        
        DispatchQueue.main.async {
            self.runningApps = unique
        }
    }
}
