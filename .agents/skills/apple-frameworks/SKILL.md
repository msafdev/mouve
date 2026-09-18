---
name: apple-frameworks
description: >-
  Integration with Apple platform frameworks: SwiftData, CoreHaptics, Metal Shaders in SwiftUI,
  and Observation. Use when configuring SwiftData ModelContainers, crafting dynamic haptics,
  or writing custom Metal shader visual effects.
---

# Apple Frameworks Integration Skill Guide

This skill guides deep integration of native Apple technologies into SwiftUI applications.

## 1. SwiftData Architecture

- **Clean Container Initialization**:
  - Encapsulate `ModelContainer` creation in a dedicated factory or singleton (`DataContainer`).
  - Provide an in-memory instance for Xcode Previews and tests (`isStoredInMemoryOnly: true`).
  - Gracefully handle schema migration errors during development without fatal crashing.

```swift
@MainActor
public final class DataContainer {
    public static let shared = DataContainer(inMemory: false)
    public static let preview = DataContainer(inMemory: true)

    public let container: ModelContainer

    public init(inMemory: Bool = false) {
        let schema = Schema([
            UserPreference.self,
            ComponentBookmark.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            self.container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Fallback to in-memory on error to prevent total launch crash
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            self.container = (try? ModelContainer(for: schema, configurations: [fallbackConfig]))!
        }
    }
}
```

## 2. CoreHaptics & Sensory Feedback

- Use SwiftUI's declarative `.sensoryFeedback(trigger:)` for discrete events:
  ```swift
  .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isPressed)
  ```
- For continuous spatial gestures (elastic sliders, dial rotators), use prepared `UIImpactFeedbackGenerator`:
  ```swift
  let generator = UIImpactFeedbackGenerator(style: .rigid)
  generator.prepare()
  generator.impactOccurred(intensity: 0.7)
  ```

## 3. Metal Shaders in SwiftUI (iOS 17+)

Leverage SwiftUI Metal shader functions:
- `.colorEffect(ShaderLibrary.gradientGlow(...))`
- `.distortionEffect(ShaderLibrary.wave(...), maxSampleOffset: CGSize(width: 10, height: 10))`
- `.layerEffect(ShaderLibrary.frostedGlass(...), maxSampleOffset: .zero)`

Keep shaders optimized with minimal texture samples to maintain 120 FPS ProMotion.
