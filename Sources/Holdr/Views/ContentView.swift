// Made and Dev by Sam
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardMonitor: ClipboardMonitor
    @EnvironmentObject var appDiscovery: AppDiscovery
    @State private var selectedCategory: HistoryItem.Category? = .all
    // We don't need separate selectedAppID now, using Category enum
    
    @State private var searchText = ""
    @State private var showCopyFeedback = false

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedCategory, clipboardMonitor: clipboardMonitor)
        } detail: {
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()
                
                if filteredItems.isEmpty {
                    if searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "clipboard")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary.opacity(0.5))
                                .accessibilityHidden(true)
                            Text("No clippings found")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("Copy text or images to see them here.")
                                .font(.callout)
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .accessibilityElement(children: .combine)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary.opacity(0.5))
                                .accessibilityHidden(true)
                            Text("No matches found")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("No clips match \"\(searchText)\"")
                                .font(.callout)
                                .foregroundColor(.secondary.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .accessibilityElement(children: .combine)
                    }
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            ClipCardView(item: item)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle()) // Improves tap area
                                .onTapGesture {
                                    copyToClipboard(item)
                                }
                                .contextMenu {
                                    Button(action: { copyToClipboard(item) }) {
                                        Label("Copy", systemImage: "doc.on.doc")
                                    }
                                    Button(action: { deleteItem(item) }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .onDrag {
                                    switch item.type {
                                    case .text, .link:
                                        return NSItemProvider(object: item.content as NSString)
                                    case .image(let id):
                                        if let data = ImageStore.shared.load(id: id) {
                                            return NSItemProvider(item: data as NSData, typeIdentifier: "public.tiff")
                                        } else {
                                            return NSItemProvider()
                                        }
                                    }
                                }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                }
                
                // Copy Feedback Toast
                if showCopyFeedback {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Copied to Clipboard")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.75))
                                .shadow(radius: 10)
                        )
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(100)
                }
            }
            .navigationTitle(selectedCategory?.rawValue ?? "All")
            .searchable(text: $searchText, placement: .toolbar)
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    var filteredItems: [HistoryItem] {
        let categoryFiltered = clipboardMonitor.items.filter { item in
            guard let category = selectedCategory else { return true }
            switch category {
            case .all: return true
            case .text: return item.category == .text
            case .link: return item.category == .link
            case .image: return item.category == .image
            case .app(let bundleID): return item.appBundleID == bundleID
            }
        }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func copyToClipboard(_ item: HistoryItem) {
        clipboardMonitor.copyItem(item)
        withAnimation(.spring()) {
            showCopyFeedback = true
        }
        
        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCopyFeedback = false
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredItems[$0] }
        clipboardMonitor.deleteItems(itemsToDelete)
    }
    
    private func deleteItem(_ item: HistoryItem) {
        clipboardMonitor.deleteItems([item])
    }
}
