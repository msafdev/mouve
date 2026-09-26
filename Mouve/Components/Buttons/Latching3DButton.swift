//
//  Latching3DButton.swift
//  Mouve
//
//  Created by Salman Alfarisi on 18/09/26.
//

import SwiftUI

/// Push-to-latch 3D button that stays physically sunken when active and pops back up on release.
/// Features directional icon translation (translates up from center on exit / from bottom on enter when locking;
/// reverses smoothly when unlocking) without disrupting title layout.
public struct Latching3DButton: View {
    @Binding private var isLatched: Bool
    private let title: String
    private let latchedIcon: String
    private let unlatchedIcon: String

    public init(
        _ title: String,
        icon: String = "lock.fill",
        unlatchedIcon: String? = nil,
        isLatched: Binding<Bool>
    ) {
        self.title = title
        self.latchedIcon = icon
        if let unlatchedIcon {
            self.unlatchedIcon = unlatchedIcon
        } else if icon == "lock.fill" {
            self.unlatchedIcon = "lock.open.fill"
        } else if icon == "bell.fill" {
            self.unlatchedIcon = "bell.slash.fill"
        } else {
            self.unlatchedIcon = icon
        }
        self._isLatched = isLatched
    }

    public init(
        _ title: String,
        latchedIcon: String,
        unlatchedIcon: String,
        isLatched: Binding<Bool>
    ) {
        self.title = title
        self.latchedIcon = latchedIcon
        self.unlatchedIcon = unlatchedIcon
        self._isLatched = isLatched
    }

    public var body: some View {
        let depth: CGFloat = 5.5

        Button(action: {
            HapticEngine.selection()
            withAnimation(.spring(response: 0.30, dampingFraction: 0.75)) {
                isLatched.toggle()
            }
        }) {
            HStack(spacing: SpacingTokens.xs) {
                // Directional translating icon slot (strictly scoped to icon, zero title jitter)
                ZStack {
                    if isLatched {
                        Image(systemName: latchedIcon)
                            .font(.system(size: 15, weight: .bold))
                            .transition(
                                .asymmetric(
                                    // When locking: enters from bottom (+14 -> 0)
                                    insertion: .offset(y: 14).combined(with: .opacity),
                                    // When unlocking: exits to bottom (0 -> +14)
                                    removal: .offset(y: 14).combined(with: .opacity)
                                )
                            )
                    } else {
                        Image(systemName: unlatchedIcon)
                            .font(.system(size: 15, weight: .bold))
                            .transition(
                                .asymmetric(
                                    // When unlocking: enters from top (-14 -> 0)
                                    insertion: .offset(y: -14).combined(with: .opacity),
                                    // When locking: exits to top (0 -> -14)
                                    removal: .offset(y: -14).combined(with: .opacity)
                                )
                            )
                    }
                }
                .frame(width: 18, height: 18)
                .clipped()

                Text(title)
                    .font(TypographyTokens.componentTitle)
            }
            .foregroundColor(isLatched ? .white : ColorTokens.textPrimary)
            .padding(.horizontal, SpacingTokens.xl)
            .padding(.vertical, SpacingTokens.md)
            .background(
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(isLatched ? ColorTokens.accent : ColorTokens.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                            .strokeBorder(
                                isLatched ? Color.white.opacity(0.35) : ColorTokens.surfaceBorder,
                                lineWidth: 1.2
                            )
                    )
            )
            .offset(y: isLatched ? (depth - 1.0) : 0)
            .background(
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(isLatched ? ColorTokens.accentBase : ColorTokens.surfaceChassis)
                    .offset(y: depth)
            )
            .elevation(isLatched ? .pressed : .low)
            .scaleEffect(isLatched ? 0.985 : 1.0)
            .animation(.spring(response: 0.30, dampingFraction: 0.75), value: isLatched)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StatefulLatchingPreview()
}

private struct StatefulLatchingPreview: View {
    @State private var isLatched = true
    var body: some View {
        ZStack {
            ColorTokens.canvasBackground.ignoresSafeArea()
            Latching3DButton("Engage Lock", isLatched: $isLatched)
        }
    }
}
