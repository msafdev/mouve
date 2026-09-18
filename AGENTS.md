# AGENTS.md: Mouve Workspace Guidelines & Rules

Welcome to the **Mouve** project. Mouve is a high-craft SwiftUI component library and showcase application displaying tactile micro-components and complex macro-flows.

## Core Design Philosophy

1. **Custom & Bespoke (Strictly NO Liquid Glass)**:
   - Do NOT use generic iOS native components or blurry liquid glass materials (`.regularMaterial`, translucent blurred bars, standard `Toggle`, standard `Button`).
   - Every component (buttons, bottom bars, toggles, chips, sliders, sheets) must be custom crafted.
   - Use solid, matte, tactile surfaces, crisp micro-borders, physical depth (beveled edges, mechanical travel), and smooth solid gradients.
2. **Kinetic Physics over Linear Durations**:
   - Use natural springs (`response`, `dampingFraction`) defined in `MotionTokens`. Never use `.linear` or generic duration animations for UI interaction.
3. **Layered Shadows**:
   - Never use single-layer muddy shadows. Use dual-layer ambient + key directional shadows via `ElevationTokens`.
4. **Haptic Choreography**:
   - Pair tactile visual changes with precise haptics using `HapticEngine`.
5. **Swift 6 Concurrency**:
   - All UI code runs on `@MainActor`. All models crossing boundaries must be `Sendable`.
6. **Orientation Lock**:
   - iPhone is strictly locked to Portrait mode. Do not introduce horizontal-only layouts.

## Architecture Organization

- `Mouve/Core/DesignSystem/`: Design tokens (`ColorTokens`, `TypographyTokens`, `ShapeTokens`, `SpacingTokens`, `MotionTokens`, `ElevationTokens`).
- `Mouve/Core/Storage/`: Future-ready SwiftData models (`UserPreference`, `ComponentBookmark`, `DataContainer`).
- `Mouve/Core/Haptics/`: Tactile feedback helpers (`HapticEngine`).
- `Mouve/Components/`: Reusable micro-components (`Buttons`, `Sheets`, `Controls`).
- `Mouve/Flows/`: Complex macro-flows (`TransitioningDetail`, `SequencedOnboarding`).
- `Mouve/Catalog/`: Gallery showcase screen, category filtering chips, and interactive playground sandbox.

## Adding New Components

When implementing or editing components:
1. Always test in both Light and Dark mode using the design tokens.
2. Ensure full accessibility support (Dynamic Type, VoiceOver, and `accessibilityReduceMotion`).
3. Register the component in `CatalogModels.swift` with appropriate `windowShape` (`.rectangle` or `.square`).
