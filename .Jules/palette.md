## 2024-10-24 - Accessibility Labels for Complex List Items
**Learning:** When creating custom list items in SwiftUI (like clipboard history cards), grouping children with .accessibilityElement(children: .ignore) and providing a computed label is crucial for a clean VoiceOver experience. Simply relying on default behavior results in "chatty" interfaces where every sub-view is read separately.
**Action:** Always check complex list rows and apply grouping + custom label.

## 2024-10-25 - Manual Hover States in SwiftUI Lists
**Learning:** Custom SwiftUI views inside a `List` with `.plain` style on macOS do not receive automatic hover effects. Adding a manual `@State` for hovering and modifying the background/border is essential for desktop-class interactivity.
**Action:** Always add `.onHover` states to interactive custom list rows on macOS.
