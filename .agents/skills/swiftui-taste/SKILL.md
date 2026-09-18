---
name: swiftui-taste
description: >-
  Apple design craft, micro-interactions, delight, depth perception, layered shadows,
  specular highlights, haptic choreography, and physical metaphors in SwiftUI.
  Use when elevating standard UI into award-winning, tactile, and highly polished experiences.
---

# SwiftUI Taste & Craft Skill Guide

This skill is the design compass for `Mouve`. It dictates what separates standard functional UI from exquisite, tactile Apple-grade design.

## 1. Physical Metaphors & Tactility

- **Real Objects Have Weight and Friction**:
  - Elements should never move at a constant linear speed unless representing a synthetic ticker.
  - Buttons should exhibit perceptible depth (bevels, bottom rim shading, and physical travel distance on press).
- **Press Down Dynamics (Tactile 3D Buttons)**:
  - Default state: Raised elevation with key shadow below and crisp bottom bezel edge.
  - Pressed state: Scale down slightly (`0.97 - 0.98`), compress vertical offset (`y: +3pt`), collapse bottom bevel, and reduce shadow radius.
  - Recoil: Snap back immediately upon release with slight organic overshoot.

## 2. Layered Shadow System (Ambient + Key)

Single-layer black shadows look muddy and amateurish. Realistic lighting requires two layers:

1. **Ambient Shadow**: Broad, diffuse, low-opacity shadow representing ambient occlusion.
   - Example: `.shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)`
2. **Key Shadow**: Tight, sharper, directional shadow cast directly from the primary light source.
   - Example: `.shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)`

```swift
struct LayeredElevationModifier: ViewModifier {
    var level: ElevationLevel

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(level.ambientOpacity), radius: level.ambientRadius, x: 0, y: level.ambientY)
            .shadow(color: Color.black.opacity(level.keyOpacity), radius: level.keyRadius, x: 0, y: level.keyY)
    }
}
```

## 3. Specular Highlights & Hairlines

- Add an inner border or overlay hairline using an angled gradient:
  ```swift
  .overlay(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
          .strokeBorder(
              LinearGradient(
                  colors: [.white.opacity(0.35), .white.opacity(0.05), .black.opacity(0.1)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
              ),
              lineWidth: 1
          )
  )
  ```
- This simulates light catching the beveled edge of physical glass, metal, or acrylic.

## 4. Haptic Choreography

Haptics must be married precisely to visual inflection points:
- **On Touch Down**: Subtle light/selection haptic (`UIImpactFeedbackGenerator(style: .rigid)` or `.sensoryFeedback(.impact(weight: .light))`).
- **On State Completion**: Success haptic (`.sensoryFeedback(.success)`).
- **On Boundary Hit / Snap**: Selection click (`.sensoryFeedback(.selection)`).
- Never spam haptics on continuous gesture updates; throttle to milestone ticks.

## 5. Optical Balancing

- Math alignment often looks visually off-center.
- Arrow icons in buttons need `+1pt` or `+2pt` horizontal optical nudge.
- Center typography relative to the cap-height of the font, not the bounding box.
