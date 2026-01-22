// Made and Dev by Sam
import SwiftUI

@main
struct HoldrApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @StateObject private var appDiscovery = AppDiscovery()
    @Environment(\.openWindow) var openWindow

    var body: some Scene {
        // Main History Window
        WindowGroup("History", id: "history") {
            ContentView()
                .environmentObject(clipboardMonitor)
                .environmentObject(appDiscovery)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Standard commands (Quit, etc)
            CommandGroup(replacing: .newItem) { }
        }
        
        // Menu Bar Icon
        MenuBarExtra {
            Button("Show History") {
                openWindow(id: "history")
                NSApp.activate(ignoringOtherApps: true)
            }
            Divider()
            Button("Clear History") {
                clipboardMonitor.items.removeAll()
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            if let logo = resizeLogo() {
                Image(nsImage: logo)
            } else {
                Image(systemName: "doc.on.clipboard")
            }
        }
    }
    
    private func resizeLogo() -> NSImage? {
        // Try module first (SPM), then main (App Bundle)
        var logoURL = Bundle.module.url(forResource: "menubar_icon", withExtension: "png")
        if logoURL == nil {
            logoURL = Bundle.main.url(forResource: "menubar_icon", withExtension: "png")
        }
        
        guard let url = logoURL else { return nil }
        guard let nsImage = NSImage(contentsOf: url) else { return nil }
        
        // Resize to standard menu bar icon size (e.g. 18x18 or 22x22 depending on padding)
        let size = NSSize(width: 22, height: 22)
        let resized = NSImage(size: size)
        
        resized.lockFocus()
        nsImage.draw(in: NSRect(origin: .zero, size: size))
        resized.unlockFocus()
        
        // Set template to false to keep original colors
        resized.isTemplate = false 
        
        return resized
    }
}
