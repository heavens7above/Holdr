- **App**: Main entry point and configuration
- **Models**: Data structures and business entities
- **Services**: Business logic and background processes
- **Views**: UI components and screens
- **Utilities**: Helper functions and extensions
- **Resources**: Assets and localization

## Data Flow

1. `ClipboardMonitor` observes system pasteboard changes
2. Changes are processed and converted into `HistoryItem` models
3. Types are persisted to disk (JSON)
4. UI observes `ClipboardMonitor` via `@Published` properties
5. `AppDiscovery` provides context about running applications

## Persistence

Data is stored in JSON format in the user's `Documents` directory (iCloud synced if enabled) or Application Support.
