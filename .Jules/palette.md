## 2026-02-03 - Custom List Item Accessibility
**Learning:** In macOS SwiftUI, complex List items (ClipCardView) do not automatically behave as accessible buttons or show hover states. They require explicit .accessibilityAddTraits(.isButton) and manual .onHover handling to match native expectations.
**Action:** Always add .isButton trait and hover effects to interactive list rows that are not standard text cells.
