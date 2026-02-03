import SwiftUI

struct ClipCardView: View {
    let item: HistoryItem
    @State private var isHovering = false
    
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
                if case .image(let data) = item.type, let nsImage = NSImage(data: data) {
                     Image(nsImage: nsImage)
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(maxHeight: 120)
                         .cornerRadius(8)
                } else {
                    Text(item.content)
                        .lineLimit(2)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.primary)
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
        .background(isHovering ? Color(nsColor: .selectedControlColor).opacity(0.1) : Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHovering ? Color.accentColor.opacity(0.5) : Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
        .onHover { isHovering = $0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabelString)
        .accessibilityHint("Click to copy to clipboard")
        .accessibilityAddTraits(.isButton)
    }

    var accessibilityLabelString: String {
        let typeString: String
        switch item.type {
        case .text: typeString = "Text"
        case .link: typeString = "Link"
        case .image: typeString = "Image"
        }

        return "\(typeString) from \(item.appName ?? "Unknown App"). \(item.content)"
    }
    
    var iconName: String {
        switch item.type {
        case .text: return "text.quote"
        case .link: return "link"
        case .image: return "photo"
        }
    }
}
