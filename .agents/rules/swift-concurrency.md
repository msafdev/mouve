# Rule: Swift Concurrency & Architecture

1. **MainActor Isolation**:
   - Annotate all ViewModels, interactive controllers, and UI helper classes with `@MainActor`.
2. **Sendable Models**:
   - All data transfer objects, catalog items, and configuration structs must conform to `Sendable`.
3. **SwiftData Models**:
   - Keep SwiftData `@Model` classes isolated and pass IDs or values to child views to prevent race conditions or cross-actor faults.
