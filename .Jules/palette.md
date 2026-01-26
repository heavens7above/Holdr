## 2024-10-24 - Accessibility Labels for Complex List Items
**Learning:** When creating custom list items in SwiftUI (like clipboard history cards), grouping children with .accessibilityElement(children: .ignore) and providing a computed label is crucial for a clean VoiceOver experience. Simply relying on default behavior results in "chatty" interfaces where every sub-view is read separately.
**Action:** Always check complex list rows and apply grouping + custom label.
