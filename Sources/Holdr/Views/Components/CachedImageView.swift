import SwiftUI

struct CachedImageView: View {
    let filename: String
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
            } else {
                ZStack {
                    Color(nsColor: .controlBackgroundColor)
                    ProgressView()
                }
            }
        }
        .task {
            // Check cache first
            if let cached = ImageCache.shared.image(forKey: filename) {
                self.image = cached
                return
            }

            // Load from disk asynchronously
            await loadFromDisk()
        }
    }

    private func loadFromDisk() async {
        let loadedImage = await Task.detached(priority: .userInitiated) { () -> NSImage? in
            if let data = ImageStore.shared.loadImage(filename: filename),
               let nsImage = NSImage(data: data) {
                return nsImage
            }
            return nil
        }.value

        if let loadedImage = loadedImage {
            ImageCache.shared.setImage(loadedImage, forKey: filename)
            self.image = loadedImage
        }
    }
}
