//
//  GalleryScreenView.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI
import SwiftData

/// The primary home screen conforming to the user wireframe:
/// 1. Top Category chips for filtering components
/// 2. Vertical list of components with configurable `.rectangle` vs `.square` windows
/// 3. Centered title under each window
/// 4. Bottom bar with smooth fading gradient effect
/// 5. Root overlay host for full-screen sheets & dialogs
public struct GalleryScreenView: View {
    @Query private var bookmarks: [ComponentBookmark]
    @State private var selectedCategory: CategoryTag = .all
    @State private var displayedCategory: CategoryTag = .all
    @State private var overlayManager = OverlayManager.shared
    @State private var selectedDetailItem: CatalogItem?

    // Active bottom dock mode (0 = Gallery, 1 = Bookmarks, 2 = Info/Settings)
    @State private var activeDockTab: Int = 0
    @State private var displayedDockTab: Int = 0

    // Sequential Transition Phase
    @State private var isContentExiting: Bool = false
    @State private var transitionTask: Task<Void, Never>?

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // LAYER 0: Canvas Background (Extends edge-to-edge)
                ColorTokens.canvasBackground
                    .ignoresSafeArea()

                // LAYER 1: Main Scrollable Component Feed (No clipping, natural smooth scroll)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Top Category Chips
                        categoryChipsBar
                            .padding(.top, SpacingTokens.sm)
                            .padding(.bottom, SpacingTokens.xl)

                        // Components Showcase List with Sequential Fade-Blur Exit & Slide-Up Entrance
                        VStack(spacing: SpacingTokens.itemToItemSpacing) {
                            if filteredItems.isEmpty {
                                VStack(spacing: SpacingTokens.md) {
                                    Image(systemName: displayedDockTab == 1 ? "bookmark" : "square.grid.2x2")
                                        .font(.system(size: 32, weight: .light))
                                        .foregroundColor(ColorTokens.textTertiary)
                                        .padding(.top, 40)

                                    Text(displayedDockTab == 1 ? "No Bookmarks Yet" : "No Components")
                                        .font(TypographyTokens.componentTitle)
                                        .foregroundColor(ColorTokens.textPrimary)

                                    Text(displayedDockTab == 1 ? "Bookmark components from their detail screen to collect them here." : "No components found in this category.")
                                        .font(TypographyTokens.body)
                                        .foregroundColor(ColorTokens.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, SpacingTokens.xl)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, SpacingTokens.xl)
                            } else {
                                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                    StaggeredCardItemView(
                                        item: item,
                                        index: index,
                                        onTapDetail: {
                                            selectedDetailItem = item
                                        }
                                    )
                                }
                            }
                        }
                        .id("\(displayedCategory.rawValue)-\(displayedDockTab)")
                        .padding(.horizontal, SpacingTokens.screenHorizontalPadding)
                        .opacity(isContentExiting ? 0.0 : 1.0)
                        .blur(radius: isContentExiting ? 14 : 0)
                        .scaleEffect(isContentExiting ? 0.96 : 1.0)
                        .offset(y: isContentExiting ? -8 : 0)

                        // Clearance so the last card scrolls comfortably above the bottom dock
                        Color.clear
                            .frame(height: 170)
                    }
                }

                // LAYER 2: Bottom Fade & Dock (Anchored seamlessly to physical bottom)
                bottomFadeAndDock

                // LAYER 3: Root-Level Sheet Overlay (Full-screen scrim + pure physical slide)
                MorphingSheet(
                    isPresented: Binding(
                        get: { overlayManager.isSheetPresented },
                        set: { if !$0 { overlayManager.dismissSheet() } }
                    ),
                    title: overlayManager.sheetTitle
                ) {
                    if let content = overlayManager.sheetContent {
                        content
                    }
                }
                .zIndex(100)

                // LAYER 4: Root-Level Centered Dialog Overlay
                if overlayManager.isDialogPresented {
                    dialogOverlay
                        .zIndex(200)
                }
            }
            .background(ColorTokens.canvasBackground.ignoresSafeArea())
            .ignoresSafeArea(.all, edges: .bottom)
            .navigationDestination(item: $selectedDetailItem) { item in
                ComponentDetailView(item: item)
            }
        }
        .environment(\.overlayManager, overlayManager)
    }

    // MARK: - Category Chips
    private var categoryChipsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpacingTokens.xs) {
                ForEach(CategoryTag.allCases) { category in
                    let isSelected = selectedCategory == category
                    Button(action: {
                        selectCategory(category)
                    }) {
                        HStack(spacing: SpacingTokens.xxs) {
                            Image(systemName: category.iconName)
                                .font(.system(size: 13, weight: .semibold))
                            Text(category.rawValue)
                                .font(TypographyTokens.chip)
                        }
                        .foregroundColor(
                            isSelected ? ColorTokens.chipSelectedText : ColorTokens.chipUnselectedText
                        )
                        .padding(.horizontal, SpacingTokens.chipPaddingHorizontal)
                        .padding(.vertical, SpacingTokens.chipPaddingVertical)
                        .background(
                            Capsule()
                                .fill(
                                    isSelected ? ColorTokens.chipSelectedBackground : ColorTokens.chipUnselectedBackground
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            isSelected ? Color.clear : ColorTokens.surfaceBorder,
                                            lineWidth: 1
                                        )
                                 )
                        )
                        .elevation(isSelected ? .low : .flat)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, SpacingTokens.screenHorizontalPadding)
        }
    }

    private func selectCategory(_ category: CategoryTag) {
        guard category != selectedCategory else { return }
        HapticEngine.selection()

        // 1. Immediately highlight the selected chip with snappy spring
        withAnimation(MotionTokens.snappy) {
            selectedCategory = category
        }

        // 2. Perform sequential choreographed transition:
        //    Phase 1: Fade & blur the unpicked category items out smoothly
        //    Phase 2: Switch displayed category, then slide up new category items smoothly
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeOut(duration: 0.15)) {
                isContentExiting = true
            }

            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }

            displayedCategory = category

            withAnimation(.easeOut(duration: 0.04)) {
                isContentExiting = false
            }
        }
    }

    // MARK: - Filtered Component List
    private var filteredItems: [CatalogItem] {
        if displayedDockTab == 1 {
            // Bookmarked components
            let bookmarkedIds = Set(bookmarks.map { $0.componentId })
            return CatalogRegistry.items.filter { bookmarkedIds.contains($0.id) }
        }

        if displayedCategory == .all {
            return CatalogRegistry.items
        } else {
            return CatalogRegistry.items.filter { $0.category == displayedCategory }
        }
    }

    // MARK: - Bottom Bar + Seamless Fader
    private var bottomFadeAndDock: some View {
        VStack(spacing: 0) {
            // Smooth gradient dissolving the scroll content
            LinearGradient(
                stops: [
                    .init(color: ColorTokens.canvasBackground.opacity(0.0), location: 0.0),
                    .init(color: ColorTokens.canvasBackground.opacity(0.40), location: 0.25),
                    .init(color: ColorTokens.canvasBackground.opacity(0.90), location: 0.65),
                    .init(color: ColorTokens.canvasBackground, location: 0.85),
                    .init(color: ColorTokens.canvasBackground, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 110)
            .allowsHitTesting(false)

            // Solid canvas shelf behind dock and extending through home indicator safe area
            ZStack(alignment: .top) {
                ColorTokens.canvasBackground
                    .frame(height: 70)

                floatingDock
                    .offset(y: -24)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var floatingDock: some View {
        HStack(spacing: SpacingTokens.lg) {
            dockIconButton(icon: "square.grid.2x2.fill", tag: 0)
            dockIconButton(icon: "bookmark.fill", tag: 1, badgeCount: bookmarks.count)
            dockIconButton(icon: "slider.horizontal.3", tag: 2)
        }
        .padding(.horizontal, SpacingTokens.lg)
        .padding(.vertical, SpacingTokens.xs + 2)
        .background(
            Capsule()
                .fill(ColorTokens.surfaceElevated)
                .overlay(
                    Capsule()
                        .strokeBorder(ColorTokens.surfaceBorder, lineWidth: 1)
                )
        )
        .elevation(.medium)
    }

    private func dockIconButton(icon: String, tag: Int, badgeCount: Int = 0) -> some View {
        let isSelected = activeDockTab == tag
        return Button(action: {
            HapticEngine.selection()
            if tag == 2 {
                // Open info / preferences sheet at the root overlay!
                overlayManager.presentSheet {
                    VStack(spacing: 20) {
                        // Icon Badge
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(ColorTokens.chipUnselectedBackground)
                                .frame(width: 68, height: 68)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .strokeBorder(ColorTokens.surfaceBorder, lineWidth: 1)
                                )
                                .elevation(.low)

                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(ColorTokens.textPrimary)
                        }
                        .padding(.top, SpacingTokens.xs)

                        // Title & Subtitle
                        VStack(spacing: 6) {
                            Text("Mouve Engine")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(ColorTokens.textPrimary)

                            Text("A high-craft SwiftUI component showcase built with physical depth and natural springs.")
                                .font(TypographyTokens.body)
                                .foregroundColor(ColorTokens.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .frame(maxWidth: 300)
                        }

                        // Stat Chips
                        HStack(spacing: SpacingTokens.md) {
                            HStack(spacing: SpacingTokens.xs) {
                                Text("Total Components")
                                    .font(TypographyTokens.caption)
                                    .foregroundColor(ColorTokens.textSecondary)
                                Text("\(CatalogRegistry.items.count)")
                                    .font(TypographyTokens.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(ColorTokens.textPrimary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(ColorTokens.chipUnselectedBackground)
                            .clipShape(Capsule())

                            HStack(spacing: SpacingTokens.xs) {
                                Text("Bookmarked")
                                    .font(TypographyTokens.caption)
                                    .foregroundColor(ColorTokens.textSecondary)
                                Text("\(bookmarks.count)")
                                    .font(TypographyTokens.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(ColorTokens.textPrimary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(ColorTokens.chipUnselectedBackground)
                            .clipShape(Capsule())
                        }

                        // Action Button
                        Button(action: {
                            HapticEngine.selection()
                            overlayManager.dismissSheet()
                        }) {
                            Text("Got it")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(ColorTokens.canvasBackground)
                                .padding(.horizontal, SpacingTokens.xxl)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(ColorTokens.textPrimary)
                                )
                        }
                        .buttonStyle(TactilePillButtonStyle())
                        .padding(.top, SpacingTokens.xs)
                    }
                    .padding(.horizontal, SpacingTokens.xl)
                    .padding(.bottom, SpacingTokens.md)
                }
            } else {
                selectDockTab(tag)
            }
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? ColorTokens.textPrimary : ColorTokens.textTertiary)
                    .frame(width: 44, height: 36)

                if badgeCount > 0 && tag == 1 {
                    Circle()
                        .fill(ColorTokens.accent)
                        .frame(width: 7, height: 7)
                        .offset(x: -6, y: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func selectDockTab(_ tag: Int) {
        guard tag != activeDockTab else { return }
        HapticEngine.selection()

        withAnimation(MotionTokens.snappy) {
            activeDockTab = tag
        }

        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeOut(duration: 0.15)) {
                isContentExiting = true
            }

            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }

            displayedDockTab = tag

            withAnimation(.easeOut(duration: 0.04)) {
                isContentExiting = false
            }
        }
    }

    // MARK: - Root Dialog Overlay
    private var dialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    overlayManager.dismissDialog()
                }

            VStack(spacing: SpacingTokens.md) {
                HStack(spacing: SpacingTokens.xs) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ColorTokens.warning)

                    Text(overlayManager.dialogTitle)
                        .font(TypographyTokens.componentTitle)
                        .foregroundColor(ColorTokens.textPrimary)

                    Spacer()
                }

                Text(overlayManager.dialogMessage)
                    .font(TypographyTokens.body)
                    .foregroundColor(ColorTokens.textSecondary)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)

                HStack(spacing: SpacingTokens.sm) {
                    TactileFlatButton("Cancel", style: .secondary) {
                        overlayManager.dismissDialog()
                    }

                    TactileFlatButton(overlayManager.dialogConfirmTitle, icon: "checkmark", style: .accent) {
                        let action = overlayManager.dialogConfirmAction
                        overlayManager.dismissDialog()
                        action?()
                    }
                }
                .padding(.top, SpacingTokens.xs)
            }
            .padding(SpacingTokens.xl)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: ShapeTokens.windowRadius, style: .continuous)
                    .fill(ColorTokens.surfaceElevated)
                    .overlay(
                    RoundedRectangle(cornerRadius: ShapeTokens.windowRadius, style: .continuous)
                        .strokeBorder(ColorTokens.surfaceBorder, lineWidth: 1)
                )
            )
            .elevation(.high)
            .transition(.scale(scale: 0.94).combined(with: .opacity))
        }
        .animation(.spring(response: 0.30, dampingFraction: 0.85), value: overlayManager.isDialogPresented)
    }
}

// MARK: - Staggered Card Container with Smooth Blur & Entrance Physics
private struct StaggeredCardItemView: View {
    let item: CatalogItem
    let index: Int
    let onTapDetail: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        ComponentWindowView(item: item, onTapDetail: onTapDetail)
            .opacity(isVisible || reduceMotion ? 1.0 : 0.0)
            .blur(radius: isVisible || reduceMotion ? 0 : 8)
            .offset(y: isVisible || reduceMotion ? 0 : 28)
            .onAppear {
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(
                        .spring(response: 0.44, dampingFraction: 0.82)
                        .delay(Double(index) * 0.05)
                    ) {
                        isVisible = true
                    }
                }
            }
    }
}

#Preview {
    GalleryScreenView()
        .modelContainer(DataContainer.preview.modelContainer)
}
