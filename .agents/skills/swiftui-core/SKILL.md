---
name: swiftui-core
description: >-
  Mastery of modern SwiftUI architecture, view lifecycle, state management, identity, and layout systems.
  Use when designing SwiftUI view hierarchies, diagnosing unexpected re-renders, choosing between @State,
  @Binding, and @Observable, using custom Layout protocols, or working with modern layout modifiers like
  visualEffect and containerRelativeFrame.
---

# SwiftUI Core Skill Guide

This skill provides comprehensive instructions and best practices for modern SwiftUI development (iOS 17+ / iOS 18+, Swift 5.10 / Swift 6).

## 1. View Identity and Lifecycle

- **Structural vs Explicit Identity**:
  - SwiftUI uses structural identity determined by the position of a view in the view hierarchy.
  - Avoid unconditional `id(...)` resets unless deliberately tearing down state.
  - Never use random UUIDs in `.id(UUID())` inside `body` as this triggers deallocation on every render.
- **View Body Purity**:
  - `var body: some View` must be pure and free of side effects.
  - Do not trigger network requests, dispatch async tasks directly, or mutate `@State` inside `body`.
  - Use `.task(id:)`, `.onChange(of:initial:)`, and `.onAppear` for side effects.

## 2. Modern State Management

- **The Observation Framework (`@Observable`)**:
  - Use `@Observable final class MyViewModel` instead of legacy `ObservableObject` and `@Published`.
  - In views, declare as `@State private var viewModel = MyViewModel()` if the view owns the model, or pass it directly without property wrappers if passed down.
  - Use `@Bindable var viewModel = viewModel` when 2-way bindings (`$viewModel.property`) are needed.
- **Value Semantics with `@State`**:
  - Keep `@State` scoped as `private`.
  - For simple component state (e.g. `isPressed`, `isSelected`, `progress`), prefer local `@State`.
- **Environment Values**:
  - Access system environments via `@Environment(\.colorScheme)`, `@Environment(\.accessibilityReduceMotion)`, `@Environment(\.modelContext)`.
  - Create custom environments using `@Entry` macro:
    ```swift
    extension EnvironmentValues {
        @Entry var componentTheme: ComponentTheme = .standard
    }
    ```

## 3. Layout Systems & Geometries

- **Avoiding `GeometryReader` Thrashing**:
  - `GeometryReader` is greedy and consumes all available parent space, often breaking centering and flexible layouts.
  - For position-aware visual adjustments, use `.visualEffect`:
    ```swift
    .visualEffect { content, geometry in
        content.offset(y: geometry.frame(in: .global).minY * 0.1)
    }
    ```
  - For layout relative to safe areas or containers, use `.containerRelativeFrame(.horizontal)`.
- **Custom `Layout` Protocol**:
  - When Stacks (`VStack`, `HStack`, `ZStack`) cannot achieve dynamic placement (e.g. circular layouts, masonry grids, flow layouts), implement the `Layout` protocol with `sizeThatFits(proposal:subviews:cache:)` and `placeSubviews(in:proposal:subviews:cache:)`.

## 4. Swift 6 Concurrency Alignment

- All SwiftUI views execute on the `@MainActor`.
- Annotate view-related models with `@MainActor` unless explicitly handling background processing.
- Ensure all types passed across boundaries conform to `Sendable`.
