## 2026-01-27 - Grouping Complex List Items
**Learning:** Complex SwiftUI list rows (icon + text + metadata) cause navigation fatigue for VoiceOver users if not grouped.
**Action:** Use `.accessibilityElement(children: .ignore)` on the container and provide a computed `.accessibilityLabel` and `.accessibilityValue` to summarize the content into a single focusable node.
