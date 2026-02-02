## 2024-05-22 - Clip Card Interaction Pattern
**Learning:** List items in SwiftUI macOS apps often lack native hover states when customized heavily. Users expect desktop-class mouse interaction (hover highlight) to indicate interactability.
**Action:** When creating custom list items that act as buttons (especially with `onTapGesture`), manually implement `onHover` state to change background and border color. Also, ensure the custom view is treated as a single accessibility element (`.isButton`) with a consolidated label to prevent VoiceOver from reading fragmented UI parts.
