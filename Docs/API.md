# API Reference

## Services

### ClipboardMonitor

Observes the system pasteboard and manages history.

- `items`: Published array of `HistoryItem`
- `checkForChanges()`: Manually trigger a check
- `copyItem(_ item: HistoryItem)`: Write item back to pasteboard

### AppDiscovery

Tracks running applications to provide context.

- `runningApps`: List of currently active apps

## Models

### HistoryItem

Represents a single clipboard entry.

- `id`: Unique identifier
- `content`: String representation
- `type`: `text`, `link`, or `image`
- `date`: Creation timestamp
