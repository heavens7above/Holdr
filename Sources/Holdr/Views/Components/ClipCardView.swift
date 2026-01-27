import SwiftUI

struct ClipCardView: View {
    let item: HistoryItem
    @State private var decodedImage: NSImage?
    @State private var hasFailedDecoding = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon based on type
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if case .image = item.type {
                    if let nsImage = decodedImage {
                        Image(nsImage: nsImage)
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(maxHeight: 120)
                             .cornerRadius(8)
                    } else if hasFailedDecoding {
                        textContent
                    } else {
                        // Loading state placeholder - keeps layout stable during load
                        Color.clear.frame(height: 120)
                    }
                } else {
                    textContent
                }
                
                HStack {
                    Text(item.date, style: .time)
                    if case .link = item.type {
                        Text("• Link")
                    } else if case .image = item.type {
                        Text("• Image")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
        .task(id: item.id) {
            await loadContent()
        }
    }

    var textContent: some View {
        Text(item.content)
            .lineLimit(2)
            .font(.system(.body, design: .rounded))
            .foregroundColor(.primary)
    }
    
    var iconName: String {
        switch item.type {
        case .text: return "text.quote"
        case .link: return "link"
        case .image: return "photo"
        }
    }

    private func loadContent() async {
        guard case .image(let data) = item.type else { return }

        let key = item.id.uuidString
        if let cached = ImageCache.shared.image(forKey: key) {
            self.decodedImage = cached
            return
        }

        // Decode off main thread
        let image = await Task.detached {
            return NSImage(data: data)
        }.value

        if let image = image {
            ImageCache.shared.insert(image, forKey: key)
            self.decodedImage = image
        } else {
            self.hasFailedDecoding = true
        }
    }
}
