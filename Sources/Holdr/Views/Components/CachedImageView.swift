import SwiftUI

struct CachedImageView: View {
    let data: Data
    let cacheKey: String
    let fallbackText: String

    @State private var image: NSImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if !isLoading {
                // Fallback to text if image loading fails
                Text(fallbackText)
                    .lineLimit(2)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.primary)
            } else {
                // Loading state
                ZStack {
                    Color.secondary.opacity(0.1)
                    ProgressView()
                        .scaleEffect(0.5)
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .task(id: cacheKey) {
            await loadImage()
        }
    }

    private func loadImage() async {
        // Check cache first
        if let cached = ImageCache.shared.image(forKey: cacheKey) {
            self.image = cached
            self.isLoading = false
            return
        }

        // Decode off-main-thread
        // We capture 'data' explicitly.
        // Note: Creating a Task.detached ensures we don't block the main actor if this was called from one,
        // although .task is already async. But NSImage(data:) is synchronous and CPU heavy.
        let loadedImage = await Task.detached(priority: .userInitiated) {
            return NSImage(data: data)
        }.value

        // Update state on Main Actor
        if let loadedImage = loadedImage {
            ImageCache.shared.setImage(loadedImage, forKey: cacheKey)
            self.image = loadedImage
        }

        self.isLoading = false
    }
}
