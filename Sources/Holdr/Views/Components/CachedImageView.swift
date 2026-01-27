import SwiftUI

struct CachedImageView: View {
    let imageID: String
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ZStack {
                    Color.gray.opacity(0.1)
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
        }
        .task {
            if image == nil {
                let id = imageID
                // Offload disk I/O to background thread
                let loadedImage = await Task.detached(priority: .userInitiated) {
                    if let data = ImageStore.shared.load(id: id),
                       let nsImage = NSImage(data: data) {
                        return nsImage
                    }
                    return nil
                }.value

                self.image = loadedImage
            }
        }
    }
}
