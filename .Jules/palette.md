## 2024-05-22 - Custom List Items Accessibility
**Learning:** Custom card views used in `ForEach` (instead of standard `List` rows) lack native hover states and accessibility traits by default.
**Action:** Always manually add `.accessibilityElement(children: .ignore)`, `.accessibilityAddTraits(.isButton)`, and a visual `.onHover` state to custom interactive list items.
