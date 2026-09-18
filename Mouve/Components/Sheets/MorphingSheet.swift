//
//  MorphingSheet.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

/// An authentic, high-craft tactile solid bottom sheet.
/// Uses 100% pure physical translation from off-screen with ZERO opacity fade on the sheet body.
public struct MorphingSheet<Content: View>: View {
    @Binding private var isPresented: Bool
    private let title: String?
    private let subtitle: String?
    private let content: Content

    @State private var dragOffset: CGFloat = 0

    public init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Ambient Background Scrim (Tracks presentation & downward drag)
            Color.black
                .opacity(isPresented ? 0.40 * max(0, min(1, 1 - Double(dragOffset / 320))) : 0.0)
                .ignoresSafeArea()
                .allowsHitTesting(isPresented)
                .onTapGesture {
                    dismiss()
                }

            // 2. Authentic Sheet Body (100% PURE PHYSICAL TRANSLATION, ZERO OPACITY FADE)
            VStack(spacing: 0) {
                // Tactile Drag Grab Handle
                Capsule()
                    .fill(ColorTokens.textTertiary.opacity(0.38))
                    .frame(width: 38, height: 5)
                    .padding(.top, SpacingTokens.sm)
                    .padding(.bottom, title != nil && !title!.isEmpty ? SpacingTokens.md : SpacingTokens.lg)

                // Optional Clean Header (Only displayed when title is provided)
                if let title, !title.isEmpty {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(title)
                                .font(TypographyTokens.componentTitle)
                                .foregroundColor(ColorTokens.textPrimary)

                            if let subtitle {
                                Text(subtitle)
                                    .font(TypographyTokens.caption)
                                    .foregroundColor(ColorTokens.textTertiary)
                            }
                        }

                        Spacer()

                        // Circular Close Button
                        Button(action: dismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ColorTokens.textSecondary)
                                .frame(width: 32, height: 32)
                                .background(ColorTokens.chipUnselectedBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, SpacingTokens.xl)
                    .padding(.bottom, SpacingTokens.md)

                    Divider()
                        .background(ColorTokens.surfaceBorder)
                        .padding(.bottom, SpacingTokens.md)
                }

                // Body Content
                content
                    .padding(.bottom, SpacingTokens.xxxl)
            }
            .frame(maxWidth: .infinity)
            .background(
                BottomSheetShape(cornerRadius: 30, bottomExtension: 600)
                    .fill(ColorTokens.surfaceElevated)
            )
            .overlay(
                BottomSheetShape(cornerRadius: 30, bottomExtension: 600)
                    .stroke(ColorTokens.surfaceBorder, lineWidth: 1)
            )
            .elevation(.high)
            .offset(y: sheetCurrentY)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation.height
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > 90 || gesture.velocity.height > 600 {
                            dismiss()
                        } else {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .animation(MotionTokens.smooth, value: isPresented)
    }

    private var sheetCurrentY: CGFloat {
        if !isPresented {
            return 900 // Placed completely off-screen below viewport
        }
        if dragOffset < 0 {
            return dragOffset * 0.22 // Rubber-band upward resistance
        }
        return dragOffset
    }

    private func dismiss() {
        HapticEngine.selection()
        withAnimation(MotionTokens.smooth) {
            isPresented = false
            dragOffset = 0
        }
    }
}

// MARK: - Helper Button Style for Tactile Pill Actions
public struct TactilePillButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.90 : 1.0)
            .animation(MotionTokens.pressRecoil, value: configuration.isPressed)
    }
}

// MARK: - Helper Shape for Top Rounded Sheet with Bottom Extension
private struct BottomSheetShape: Shape {
    var cornerRadius: CGFloat = 30
    var bottomExtension: CGFloat = 600

    func path(in rect: CGRect) -> Path {
        #if canImport(UIKit)
        let extendedRect = CGRect(
            x: rect.origin.x,
            y: rect.origin.y,
            width: rect.width,
            height: rect.height + bottomExtension
        )
        let bezier = UIBezierPath(
            roundedRect: extendedRect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(bezier.cgPath)
        #else
        var path = Path()
        path.addRect(rect)
        return path
        #endif
    }
}

// MARK: - Sheet Hero Image Badge
public struct SheetHeroImageBadge: View {
    public init() {}

    public var body: some View {
        Image("placeholder")
            .resizable()
            .scaledToFill()
            .frame(width: 130, height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ZStack {
        ColorTokens.canvasBackground.ignoresSafeArea()
        MorphingSheet(isPresented: .constant(true)) {
            VStack(spacing: 20) {
                SheetHeroImageBadge()
                    .padding(.top, SpacingTokens.xs)

                Text("Activity Added\nto Your Calendar")
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                    .foregroundColor(ColorTokens.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text("Activity has been successfully scheduled. We'll send you a reminder as the date approaches.")
                    .font(TypographyTokens.body)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: 300)

                Button(action: {}) {
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
        }
    }
}
