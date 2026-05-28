## 2026-05-28 - Native Badge Modifiers for macOS Sidebars
**Learning:** SwiftUI provides a native `.badge(count)` modifier for `Label` elements that perfectly handles standard macOS pill styling, zero-hiding, and VoiceOver accessibility grouping without requiring custom layouts or manual `.accessibilityElement(children: .combine)` wrappers.
**Action:** Always prefer the native `.badge()` modifier over custom `HStack` + `Spacer` + `Text` setups when displaying counts in sidebar lists.
