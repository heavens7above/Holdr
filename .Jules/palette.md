## 2026-01-30 - Custom List Item Interactivity
**Learning:** SwiftUI `List` rows using `onTapGesture` instead of `Button` lack native hover feedback and accessibility traits on macOS.
**Action:** When creating custom list items, manually implement `.onHover` for visual feedback and add `.accessibilityAddTraits(.isButton)` to ensure screen readers recognize the item as actionable.
