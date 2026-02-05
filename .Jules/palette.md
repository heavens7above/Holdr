## 2024-10-24 - Accessibility Labels for Complex List Items
**Learning:** When creating custom list items in SwiftUI (like clipboard history cards), grouping children with .accessibilityElement(children: .ignore) and providing a computed label is crucial for a clean VoiceOver experience. Simply relying on default behavior results in "chatty" interfaces where every sub-view is read separately.
**Action:** Always check complex list rows and apply grouping + custom label.

## 2024-10-25 - Custom Hover States for macOS Lists
**Learning:** Standard SwiftUI `List` selection styles often don't provide enough feedback for custom, complex rows on macOS. Users expect a hover state to indicate interactivity before clicking.
**Action:** Implement manual `.onHover` tracking with `@State` to toggle subtle background/border changes on custom list cards.
