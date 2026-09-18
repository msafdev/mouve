# GEMINI.md: Rules for Antigravity

This file provides project-level instructions for AI pairing in Mouve.

- **Design Tenet**: Custom, tactile, physical aesthetic. Strict prohibition against generic iOS liquid glass or blurry native chrome.
- **Component Anatomy**: Every component must have:
  - Custom visual style (press dynamics, depth, tactile response).
  - Design tokens usage for colors, typography, shapes, and motions.
  - Dedicated `#Preview` block.
  - Category and `WindowShape` registration in `CatalogModels.swift`.
- **Concurrency**: Strict Swift 6 compliance. Views and UI-bound models use `@MainActor`.
- **Platform**: iOS 17+ / iOS 18+, iPhone Portrait only.
