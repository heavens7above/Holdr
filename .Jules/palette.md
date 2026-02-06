## 2024-05-22 - Custom List Items Accessibility
**Learning:** Custom card views used in `ForEach` (instead of standard `List` rows) lack native hover states and accessibility traits by default.
**Action:** Always manually add `.accessibilityElement(children: .ignore)`, `.accessibilityAddTraits(.isButton)`, and a visual `.onHover` state to custom interactive list items.
## 2024-10-24 - Accessibility Labels for Complex List Items
**Learning:** When creating custom list items in SwiftUI (like clipboard history cards), grouping children with .accessibilityElement(children: .ignore) and providing a computed label is crucial for a clean VoiceOver experience. Simply relying on default behavior results in "chatty" interfaces where every sub-view is read separately.
**Action:** Always check complex list rows and apply grouping + custom label.
