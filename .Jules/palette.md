# Palette's Journal

## 2024-05-22 - ClipCardView Accessibility & Interactivity
**Learning:** List items in custom SwiftUI views often lack native hover states and accessible grouping, requiring manual implementation of `.onHover` and `.accessibilityElement(children: .combine)`.
**Action:** Always wrap custom list rows in an accessibility element and add visual feedback states manually when not using standard `List` styles.
