import SwiftUI
import AppKit

struct CachedImageView<Fallback: View>: View {
    let id: UUID
    let imageData: Data
    let fallback: Fallback

    init(id: UUID, imageData: Data, @ViewBuilder fallback: () -> Fallback) {
        self.id = id
        self.imageData = imageData
        self.fallback = fallback()
    }

    @State private var loadStatus: LoadStatus = .loading

    enum LoadStatus {
        case loading
        case loaded(NSImage)
        case failed
    }

    var body: some View {
        Group {
            switch loadStatus {
            case .loaded(let image):
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 120)
                    .cornerRadius(8)
            case .failed:
                fallback
            case .loading:
                // Placeholder to prevent layout collapse
                Color.clear
                    .frame(height: 120)
            }
        }
        .task {
            await loadImage()
        }
        .onChange(of: id) { _ in
            // Reset status and reload if ID changes
            loadStatus = .loading
            Task {
                await loadImage()
            }
        }
    }

    private func loadImage() async {
        let key = id.uuidString

        // 1. Check cache
        if let cached = ImageCache.shared.image(for: key) {
            self.loadStatus = .loaded(cached)
            return
        }

        // 2. Decode
        // Perform decoding. Since NSImage(data:) is generally fast enough for small images
        // and actually decodes lazily, doing it here ensures we have the object.
        // If we wanted to force decoding off-thread, we could use a detached task,
        // but that might be overkill for this optimization step.
        if let nsImage = NSImage(data: imageData) {
            ImageCache.shared.insert(nsImage, for: key)
            self.loadStatus = .loaded(nsImage)
        } else {
            self.loadStatus = .failed
        }
    }
}
