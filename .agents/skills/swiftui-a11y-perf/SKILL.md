---
name: swiftui-a11y-perf
description: >-
  Accessibility (VoiceOver, Dynamic Type, Reduce Motion) and performance optimization
  for SwiftUI applications. Use when verifying 120 FPS ProMotion smoothness, eliminating
  unnecessary view invalidations, auditing high contrast, or respecting system motion preferences.
---

# SwiftUI Accessibility & Performance Skill Guide

This skill ensures `Mouve` components are universally accessible and maintain rock-solid 120 FPS performance.

## 1. Respecting System Motion Preferences

Any motion-heavy component must support the system's "Reduce Motion" setting:
```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

var activeAnimation: Animation? {
    reduceMotion ? nil : .snappySpring
}
```
- When `reduceMotion` is `true`, replace dramatic scale/slide transforms with simple crossfades or instantaneous value updates.

## 2. Dynamic Type & Scalable Layouts

- Avoid hardcoded view heights on elements containing user-facing text.
- Use `@ScaledMetric` for padding and icon dimensions that must scale proportionally with text:
  ```swift
  @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 20
  ```
- Use `.lineLimit(1...)` and `.minimumScaleFactor(...)` carefully without truncating critical UI labels.

## 3. Performance Optimization & 120 FPS ProMotion

- **Eliminating View Invalidation Cascades**:
  - Keep `@State` as close to the leaf nodes that actually render the changing value as possible.
  - With `@Observable`, SwiftUI only invalidates views that read the specific property mutated.
- **Efficient Drawing**:
  - Use `.drawingGroup()` for complex canvas-rendered vector graphics or particle systems.
  - Avoid large Gaussian blur radii in rapidly animating views; use `.ultraThinMaterial` or pre-computed backgrounds.
  - Prefer `.visualEffect` over `GeometryReader` whenever reading local geometry to prevent layout re-computation cycles.
- **Accessibility Actions**:
  - Provide custom `.accessibilityAction(named:)` for gesture-only interactions so VoiceOver and Switch Control users can activate them.
