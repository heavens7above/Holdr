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
            .accessibilityHidden(true)
            
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
        .background(
            ZStack {
                Color(nsColor: .controlBackgroundColor)
                if isHovering {
                    Color.primary.opacity(0.05)
                }
            }
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabelString)
        .accessibilityHint("Double tap to copy content to clipboard")
        .accessibilityAddTraits(.isButton)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    var iconName: String {
        switch item.type {
        case .text: return "text.quote"
        case .link: return "link"
        case .image: return "photo"
        }
    }

    var accessibilityLabelString: String {
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
            contentDescription = "captured image"
        }

        return "\(typeString): \(contentDescription), captured at \(item.date.formatted(date: .omitted, time: .shortened))"
    }
}
