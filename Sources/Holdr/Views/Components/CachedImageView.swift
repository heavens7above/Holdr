import SwiftUI

struct CachedImageView: View {
    let uuid: String
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 120)
                    .cornerRadius(8)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 120)
                    ProgressView()
                }
            }
        }
        .task {
            // Check cache first
            if let cached = ImageCache.shared.image(for: uuid) {
                self.image = cached
                return
            }

            // Load from disk in background
            if let data = ImageStore.shared.load(uuid: uuid),
               let nsImage = NSImage(data: data) {
                ImageCache.shared.insert(nsImage, for: uuid)
                self.image = nsImage
            }
        }
    }
}
