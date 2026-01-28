# Palette's UX Journal

## 2026-01-28 - List Items as Action Buttons
**Learning:** In SwiftUI, using `.onTapGesture` on a `List` item overrides standard selection behavior but leaves the item feeling static. Users (especially those using VoiceOver) expect actionable items to announce themselves as buttons and visual users expect hover feedback.
**Action:** Always add `.accessibilityAddTraits(.isButton)` and a visual hover state (like a background tint) to custom list items that perform actions.
