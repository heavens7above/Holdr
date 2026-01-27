# Performance Analysis: SidebarView Optimization

## Issue
The original implementation of `SidebarView` contained an N+1 performance issue in the `otherApps` logic and its rendering.

### Original Code Analysis
1. **`otherApps` Calculation**:
   - Iterates over `clipboardMonitor.items` to collect all `appBundleID`s (O(M)).
   - Performs set subtraction against running apps.
   - Sorts the result.
   - Returns a list of `bundleID` strings (Size N).

2. **Rendering Loop**:
   - The view iterates over `otherApps` (N times).
   - For each item, it calls `appName(for: bundleID)`.

3. **`appName(for:)`**:
   - This function performs `clipboardMonitor.items.first(where: ...)` which is a linear scan O(M).

**Total Complexity**: O(M) + O(N * M).
Since N (number of unique apps in history) can scale with M (history size), this approaches O(M^2) in the worst case (e.g., if history is full of unique apps).

## Optimization
We replace the separate lookup with a single pass aggregation.

### Optimized Code Analysis
1. **`otherApps` Calculation**:
   - Iterates over `clipboardMonitor.items` ONCE (O(M)).
   - During iteration, it builds a dictionary `[String: String]` mapping `bundleID` to the first encountered `appName`.
   - Computes the set of keys from this dictionary.
   - Performs set subtraction.
   - Sorts the result.
   - Maps the resulting bundle IDs to a struct `HistoryAppDisplay` using the dictionary (O(1) lookup).

2. **Rendering Loop**:
   - The view iterates over the returned `[HistoryAppDisplay]`.
   - Property access is O(1).

**Total Complexity**: O(M + N).

## Conclusion
This change reduces the complexity from quadratic O(N*M) to linear O(M), which is a significant improvement for large history sizes.
