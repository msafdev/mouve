---
name: swiftui-architecture
description: >-
  Component library design patterns, design token systems, showcase and catalog architectures,
  interactive playground sandboxes, and Swift Package Manager (SPM) modularization.
  Use when architecting reusable UI libraries, designing clean component APIs, or structuring design systems.
---

# SwiftUI Architecture & Library Design Skill Guide

This skill governs the structural architecture of the `Mouve` component library and showcase application.

## 1. Design Tokens System

A design token system acts as the single source of truth across the library:
- **`ColorTokens`**: Semantic colors (`surface`, `surfaceBorder`, `canvasBackground`, `accent`).
- **`TypographyTokens`**: System-adaptive typography scale with optical line-heights and kerning.
- **`ShapeTokens`**: Continuous corner radii (`RoundedRectangle(cornerRadius: ..., style: .continuous)`).
- **`SpacingTokens`**: 4pt/8pt harmonic grid scale (`xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`).
- **`MotionTokens`**: Scientifically tuned spring curves for cohesive kinetic feel.
- **`ElevationTokens`**: Ambient + key dual-layer shadows.

## 2. Component API Ergonomics

- **Custom Button Styles over View Wrappers**:
  - Prefer `ButtonStyle` or `PrimitiveButtonStyle` for button components (`.buttonStyle(Tactile3DButtonStyle())`).
  - This preserves accessibility, label styling, disabled states, and SwiftUI standard button behavior.
- **Progressive Configuration**:
  - Provide sensible defaults for all visual parameters.
  - Allow overrides via view modifiers or builder methods (`.tactileDepth(4)`, `.tactileRecoil(true)`).

## 3. The Showcase & Gallery Architecture

- **Window View (`ComponentWindowView`)**:
  - Reusable container presenting the live preview of a component.
  - Configurable shape prop:
    - `.rectangle`: Aspect ratio ~16:10 for wide micro-components (buttons, sliders, segmented pickers).
    - `.square`: Aspect ratio 1:1 for larger cards, sheets, 3D components, or multi-step flows.
  - Subtle border, clean background, and centered title underneath.
- **Component Playground Sandbox**:
  - Real-time parameter tweaking panel.
  - Color scheme switcher (Dark / Light mode).
  - Code snippet preview for copying implementation code into client apps.
