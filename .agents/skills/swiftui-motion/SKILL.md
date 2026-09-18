---
name: swiftui-motion
description: >-
  Advanced SwiftUI animations, physics-based springs, PhaseAnimator, KeyframeAnimator,
  matchedGeometryEffect, interactive gesture transitions, and dynamic rubber-banding.
  Use when crafting fluid UI transitions, tuning spring response and damping fractions,
  building multi-step sequenced animations, or connecting gestures to continuous spatial motion.
---

# SwiftUI Motion & Physics Skill Guide

This skill governs fluid, physics-driven animations, gesture choreography, and spatial transitions in SwiftUI.

## 1. Physics-Based Springs

Always prefer natural springs over artificial duration-based curves (`.easeInOut`, `.linear`).

### Parameter Formula & Mental Model
- **`response`** (Duration feel in seconds): How quickly the spring reaches the target. Lower = snappier, Higher = relaxed.
- **`dampingFraction`** (Bounciness ratio):
  - `1.0`: Critically damped (no overshoot, smooth settling). Ideal for sheets, navigation, and large layout shifts.
  - `0.75 - 0.85`: Subtle organic bounce. Great for buttons, cards, and micro-interactions.
  - `0.5 - 0.65`: Playful, energetic bounce. Great for toggles, badges, and notification popovers.
  - `< 0.5`: Highly oscillating. Use sparingly for playful accents.

### Pre-packaged Motion Tokens
```swift
extension Animation {
    /// Snappy feedback for button presses, toggles, and chips (0.28s, 0.78 damping)
    static let snappySpring = Animation.spring(response: 0.28, dampingFraction: 0.78)
    
    /// Bouncy spring for delight, success checkmarks, and badges (0.36s, 0.65 damping)
    static let bouncySpring = Animation.spring(response: 0.36, dampingFraction: 0.65)
    
    /// Smooth spring for sheets, modals, and container morphs (0.45s, 0.9 damping)
    static let smoothSpring = Animation.spring(response: 0.45, dampingFraction: 0.9)
    
    /// Continuous spring for tracking interactive gestures
    static let interactiveSpring = Animation.interactiveSpring(response: 0.32, dampingFraction: 0.82)
}
```

## 2. Multi-State Sequenced Motion

### `PhaseAnimator`
Use `PhaseAnimator` for cyclical or multi-phase state progressions:
```swift
enum ActionPhase: CaseIterable {
    case idle, pressing, loading, success
}

PhaseAnimator([ActionPhase.idle, .pressing, .loading, .success], trigger: triggerCount) { phase in
    // Render view according to phase
} animation: { phase in
    switch phase {
    case .idle: .smoothSpring
    case .pressing: .snappySpring
    case .loading: .linear(duration: 0.8).repeatForever(autoreverses: false)
    case .success: .bouncySpring
    }
}
```

### `KeyframeAnimator`
Use `KeyframeAnimator` for independent interpolation of separate channels (scale, rotation, offset, opacity) along a precise timeline.

## 3. Matched Geometry Effect (`matchedGeometryEffect`)

- **Namespace Scope**: Always create a `@Namespace private var animationNamespace` in the common ancestor view.
- **Matched Elements**:
  - Assign `.matchedGeometryEffect(id: "container", in: animationNamespace)` to both source and target containers.
  - Keep internal text/icon elements matched with distinct IDs to prevent jumping.
- **Z-Index Ordering**: Ensure the active/transitioning element has a higher `.zIndex(1)` during transitions.

## 4. Gesture-Driven Fluid Dismissal

- Track active drag displacement via `DragGesture(minimumDistance: 0)`.
- Apply rubber-banding resistance formula when dragged beyond boundaries:
  ```swift
  func rubberBand(offset: CGFloat, dimension: CGFloat, factor: CGFloat = 0.55) -> CGFloat {
      (1.0 - (1.0 / ((offset * factor / dimension) + 1.0))) * dimension
  }
  ```
- On release, evaluate velocity: if velocity > threshold OR offset > dismissThreshold, trigger dismissal; otherwise, snap back with `.interactiveSpring`.
