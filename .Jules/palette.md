## 2026-02-03 - Custom List Item Accessibility
**Learning:** In macOS SwiftUI, complex List items (ClipCardView) do not automatically behave as accessible buttons or show hover states. They require explicit .accessibilityAddTraits(.isButton) and manual .onHover handling to match native expectations.
**Action:** Always add .isButton trait and hover effects to interactive list rows that are not standard text cells.
## 2024-05-22 - Clip Card Interaction Pattern
**Learning:** List items in SwiftUI macOS apps often lack native hover states when customized heavily. Users expect desktop-class mouse interaction (hover highlight) to indicate interactability.
**Action:** When creating custom list items that act as buttons (especially with `onTapGesture`), manually implement `onHover` state to change background and border color. Also, ensure the custom view is treated as a single accessibility element (`.isButton`) with a consolidated label to prevent VoiceOver from reading fragmented UI parts.
# Palette's Journal

## 2024-05-22 - ClipCardView Accessibility & Interactivity
**Learning:** List items in custom SwiftUI views often lack native hover states and accessible grouping, requiring manual implementation of `.onHover` and `.accessibilityElement(children: .combine)`.
**Action:** Always wrap custom list rows in an accessibility element and add visual feedback states manually when not using standard `List` styles.
## 2026-01-30 - Custom List Item Interactivity
**Learning:** SwiftUI `List` rows using `onTapGesture` instead of `Button` lack native hover feedback and accessibility traits on macOS.
**Action:** When creating custom list items, manually implement `.onHover` for visual feedback and add `.accessibilityAddTraits(.isButton)` to ensure screen readers recognize the item as actionable.
## 2024-05-22 - Custom List Items Accessibility
**Learning:** Custom card views used in `ForEach` (instead of standard `List` rows) lack native hover states and accessibility traits by default.
**Action:** Always manually add `.accessibilityElement(children: .ignore)`, `.accessibilityAddTraits(.isButton)`, and a visual `.onHover` state to custom interactive list items.
## 2024-10-24 - Accessibility Labels for Complex List Items
**Learning:** When creating custom list items in SwiftUI (like clipboard history cards), grouping children with .accessibilityElement(children: .ignore) and providing a computed label is crucial for a clean VoiceOver experience. Simply relying on default behavior results in "chatty" interfaces where every sub-view is read separately.
**Action:** Always check complex list rows and apply grouping + custom label.

## 2024-10-25 - Custom Hover States for macOS Lists
**Learning:** Standard SwiftUI `List` selection styles often don't provide enough feedback for custom, complex rows on macOS. Users expect a hover state to indicate interactivity before clicking.
**Action:** Implement manual `.onHover` tracking with `@State` to toggle subtle background/border changes on custom list cards.
## 2024-10-25 - Manual Hover States in SwiftUI Lists
**Learning:** Custom SwiftUI views inside a `List` with `.plain` style on macOS do not receive automatic hover effects. Adding a manual `@State` for hovering and modifying the background/border is essential for desktop-class interactivity.
**Action:** Always add `.onHover` states to interactive custom list rows on macOS.

## 2024-10-25 - Smart Date Formatting
**Learning:** Absolute timestamps (e.g., "12:00 PM") without date context (e.g., "Yesterday") in history lists confuse users and screen readers about when an action occurred.
**Action:** Implement a smart date formatter that adapts based on recency (Time -> Yesterday -> Short Date) and provides a verbose accessibility label.

## 2025-05-24 - Accessibility Grouping vs Interactive Elements
**Learning:** Wrapping a container in `.accessibilityElement(children: .combine)` makes the entire container a single focusable element, which can render internal interactive elements (like Buttons) inaccessible or difficult to activate independently.
**Action:** When adding actionable controls to an informational view, keep them outside of any `.combine` accessibility groups or use `.contain` instead.

## 2026-02-04 - Accessibility Hints vs Interaction Model
**Learning:** Hardcoded accessibility hints (e.g., "Double click to copy") within child views can easily fall out of sync with the parent container's actual interaction model (e.g., a simple `Button` wrapper). This confuses users relying on screen readers.
**Action:** Verify interaction hints against the parent container's behavior, or better yet, define accessibility actions on the parent container itself to ensure consistency.

## 2026-02-05 - Transient State Accessibility
**Learning:** Visual feedback for transient actions (like "Copied to clipboard" toasts) is invisible to screen reader users unless explicitly announced.
**Action:** Always pair visual toasts with `NSAccessibilityPostNotificationWithUserInfo(..., .announcementRequested, ...)` to ensure blind users receive confirmation of the action.
