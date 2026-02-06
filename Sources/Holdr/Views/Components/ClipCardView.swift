import SwiftUI

struct ClipCardView: View {
    let item: HistoryItem
    @State private var isHovering = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
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
        .background(
            isHovering ?
            Color(nsColor: .selectedControlColor).opacity(0.1) :
            Color(nsColor: .controlBackgroundColor)
        .background(isHovering ? Color(nsColor: .selectedControlColor).opacity(0.1) : Color(nsColor: .controlBackgroundColor))
        .background(
            isHovering ? Color(nsColor: .selectedControlColor).opacity(0.1) : Color(nsColor: .controlBackgroundColor)
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
                .stroke(
                    isHovering ? Color.accentColor.opacity(0.5) : Color(nsColor: .separatorColor),
                    lineWidth: 0.5
                )
        )
        .scaleEffect(isHovering ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        .onHover { isHovering = $0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
                .stroke(isHovering ? Color.accentColor.opacity(0.5) : Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabelString)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to copy to clipboard")
    }

    var accessibilityLabelString: String {
        var parts: [String] = []

        // Type
        switch item.type {
        case .text: parts.append("Text")
        case .link: parts.append("Link")
        case .image: parts.append("Image")
        }

        // Source App
        if let appName = item.appName {
            parts.append("from \(appName)")
        }

        // Content
        parts.append(item.content)

        // Date
        if #available(macOS 12.0, *) {
            parts.append("at " + item.date.formatted(date: .omitted, time: .shortened))
        } else {
             let formatter = DateFormatter()
             formatter.timeStyle = .short
             parts.append("at " + formatter.string(from: item.date))
        }

        return parts.joined(separator: ", ")
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Copies content to clipboard")
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

    var accessibilityLabel: String {
    var accessibilityLabelString: String {
        let typeStr: String
        switch item.type {
        case .text: typeStr = "Text"
        case .link: typeStr = "Link"
        case .image: typeStr = "Image"
        }

        var label = "\(typeStr) clip"
        if let appName = item.appName {
            label += " from \(appName)"
        }

        if case .text = item.type {
            label += ": \(item.content)"
        } else if case .link = item.type {
            label += ": \(item.content)"
        }

        // Use static formatter
        label += ". Copied at \(Self.dateFormatter.string(from: item.date))"

        return label
        return "\(typeStr) from \(item.appName ?? "Unknown application"), \(item.content)"
    var accessibilityLabel: String {
        let typeDesc: String
        switch item.type {
        case .text: typeDesc = "Text"
        case .link: typeDesc = "Link"
        case .image: typeDesc = "Image"
        }

        var label = typeDesc
        if let app = item.appName {
            label += ", from \(app)"
        }

        label += ": \(item.content)"
        return label
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
