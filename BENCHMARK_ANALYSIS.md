# Benchmark Analysis: Async File Loading

## Optimization Description

The original implementation of `ClipboardMonitor.checkForChanges` performed synchronous file I/O on the main thread when an image file URL was detected on the clipboard.

```swift
if let data = try? Data(contentsOf: firstURL) { // BLOCKS MAIN THREAD
    // ...
}
```

This caused potential UI hangs, especially if the file was large or located on a slow volume (e.g., network drive).

The optimization offloads this operation to a background queue:

```swift
DispatchQueue.global(qos: .userInitiated).async {
    if let data = try? Data(contentsOf: firstURL) {
        // ...
        DispatchQueue.main.async {
             // Update UI
        }
    }
}
```

## Performance Impact

### Theoretical Improvement
- **Blocking Time:** Reduced from `O(file_size)` to near-zero (dispatch overhead).
- **UI Responsiveness:** The main thread remains free to handle events while the file is being read.

### Verification Strategy
Due to the current development environment lacking the `swift` executable and `xcodebuild`, live benchmarking (e.g., using `XCTest` or a standalone script) is not possible.

However, the performance benefit is structurally guaranteed by moving blocking I/O off the main thread.

### Logic Verification
- **Correctness:** The code captures `self` weakly to prevent retain cycles.
- **Thread Safety:** `items` array is only accessed and modified on the main thread.
- **Ordering:** The logic preserves the duplicate check against the current state of `items` at the time of insertion.
- **Race Conditions:** By returning immediately after dispatching, we avoid processing the same clipboard change as both a file and another type (e.g., text), maintaining original behavior intent.
