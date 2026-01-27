import SwiftUI
import AppKit

struct CachedImageView: View {
    let item: HistoryItem
    @State private var image: NSImage?
    @State private var failedToDecode = false

    init(item: HistoryItem) {
        self.item = item
        // Initialize with cached image to avoid flicker
        if let cached = ImageCache.shared.image(forKey: item.id.uuidString) {
            _image = State(initialValue: cached)
        }
    }

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 120)
                    .cornerRadius(8)
            } else if failedToDecode {
                // Fallback to text content if image decoding fails
                Text(item.content)
                    .lineLimit(2)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.primary)
            } else {
                // Loading placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 100)
                    ProgressView()
                        .controlSize(.small)
                }
                .task(id: item.id) {
                    await loadImage()
                }
            }
        }
    }

    private func loadImage() async {
        // If already loaded (e.g. via init), do nothing
        if image != nil { return }

        let key = item.id.uuidString

        // 1. Check Cache again (in case it was populated since init)
        if let cached = ImageCache.shared.image(forKey: key) {
            self.image = cached
            return
        }

        // 2. Decode off main thread
        if case .image(let data) = item.type {
            let decoded = await Task.detached {
                return NSImage(data: data)
            }.value

            // Check cancellation or just update
            if !Task.isCancelled {
                await MainActor.run {
                    if let decoded = decoded {
                        ImageCache.shared.setImage(decoded, forKey: key)
                        self.image = decoded
                    } else {
                        self.failedToDecode = true
                    }
                }
            }
        } else {
            self.failedToDecode = true
        }
    }
}
