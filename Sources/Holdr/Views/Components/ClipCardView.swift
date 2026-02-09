import SwiftUI
import AppKit

struct ClipCardView: View {
    let item: HistoryItem
    @State private var isHovering = false

    @State private var decodedImage: NSImage?
    @State private var hasFailedDecoding = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 18))
            }
            .accessibilityHidden(true)
            
            // Content
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
                        Color.clear.frame(height: 120) // Placeholder
                    }
                } else {
                    textContent
                }
                
                // Metadata
                HStack {
                    Text(item.date.smartDateString())
                    if case .link = item.type {
                        Text("• Link")
                    } else if case .image = item.type {
                        Text("• Image")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            ZStack {
                Color(nsColor: .controlBackgroundColor)
                if isHovering {
                    Color(nsColor: .selectedControlColor).opacity(0.1)
                }
            }
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHovering ? Color.accentColor.opacity(0.5) : Color(nsColor: .separatorColor), lineWidth: isHovering ? 2 : 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .scaleEffect(isHovering ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        .onHover { isHovering = $0 }
        // Accessibility
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint("Double click to copy to clipboard")
        // Image loading
        .task {
            if case .image(let id) = item.type {
                if let image = ImageStore.shared.loadImage(id: id) {
                    self.decodedImage = image
                } else {
                    self.hasFailedDecoding = true
                }
            }
        }
    }

    var textContent: some View {
        Text(item.content)
            .font(.body)
            .lineLimit(3)
            .foregroundColor(.primary)
            .help(item.content)
    }

    var iconName: String {
        switch item.type {
        case .text: return "text.quote"
        case .link: return "link"
        case .image: return "photo"
        }
    }

    private var accessibilityLabelText: String {
        let typeString: String
        switch item.type {
        case .text: typeString = "Text"
        case .link: typeString = "Link"
        case .image: typeString = "Image"
        }

        let appString = item.appName.map { ", from \($0)" } ?? ""

        let contentDescription: String
        if case .image = item.type {
            contentDescription = ""
        } else {
            contentDescription = ": \(item.content)"
        }

        return "\(typeString)\(appString)\(contentDescription). Copied \(item.date.accessibilityDateDescription())"
    }
}
