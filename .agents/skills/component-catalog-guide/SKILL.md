---
name: component-catalog-guide
description: >-
  Runbook for authoring, cataloging, and showcasing micro-components and macro-flows in Mouve.
  Use when adding a new component to the library, writing its interactive playground,
  or updating catalog categories and metadata.
---

# Component Catalog Runbook

This guide details how to build and register new components in `Mouve`.

## Design Philosophy: Custom, Bespoke & Tactile (No Liquid Glass)

- **Anti-Liquid Glass**: Do not use standard iOS translucent glass materials (`.regularMaterial`, blurry liquid glass).
- **Physical & Solid Surfaces**: Use solid, rich matte surfaces with crisp micro-borders, physical elevation, beveled highlights, and mechanical travel.
- **Custom Everything**: Buttons, bottom bars, toggles, chips, and sliders must be bespoke SwiftUI implementations.

## Steps to Add a New Component

1. **Implement Component in `Components/` or `Flows/`**:
   - Provide clean public API with customizable parameters.
   - Use `DesignTokens` for colors, typography, shapes, and motion springs.
   - Include custom haptic feedback using `HapticEngine`.
   - Provide an independent `#Preview` demonstrating states.

2. **Register in `CatalogModels.swift`**:
   - Assign a unique ID, human-readable title, description, category (`.buttons`, `.sheets`, `.navigation`, `.controls`, `.flows`).
   - Specify `windowShape`: `.rectangle` (for wide/horizontal components) or `.square` (for large/3D components or flows).
   - Provide the destination view builder.

3. **Provide Interactive Playground Config**:
   - Expose tweakable parameters (e.g. depth, bounce, color variant) in `ComponentPlaygroundView` so users can test interactions dynamically.
