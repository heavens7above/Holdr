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
            .accessibilityHidden(true)
            
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
                .accessibilityHidden(true)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint("Double tap to copy to clipboard")
        .accessibilityAddTraits(.isButton)
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
        let contentDescription: String

        switch item.type {
        case .text:
            typeString = "Text"
            contentDescription = item.content
        case .link:
            typeString = "Link"
            contentDescription = item.content
        case .image:
            typeString = "Image"
            contentDescription = ""
        }

        let appString = item.appName.map { ", from \($0)" } ?? ""
        let timeString = item.date.formatted(date: .omitted, time: .shortened)

        // Truncate long content for accessibility
        let truncatedContent = contentDescription.prefix(100)
        let ellipsis = contentDescription.count > 100 ? "..." : ""
        let contentPart = contentDescription.isEmpty ? "" : ". \(truncatedContent)\(ellipsis)"

        return "\(typeString)\(appString)\(contentPart). Copied at \(timeString)"
    }
}
