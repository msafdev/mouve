//
//  Latching3DButton.swift
//  Mouve
//
//  Created by Salman Alfarisi on 18/09/26.
//

import SwiftUI

/// Push-to-latch 3D button that stays physically sunken when active and pops back up on release.
public struct Latching3DButton: View {
    @Binding private var isLatched: Bool
    private let title: String
    private let icon: String

    public init(_ title: String, icon: String, isLatched: Binding<Bool>) {
        self.title = title
        self.icon = icon
        self._isLatched = isLatched
    }

    public var body: some View {
        let depth: CGFloat = 5.5

        Button(action: {
            HapticEngine.selection()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                isLatched.toggle()
            }
        }) {
            HStack(spacing: SpacingTokens.xs) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
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
                    .fill(isLatched ? ColorTokens.accentDark : Color.black.opacity(0.20))
                    .offset(y: depth)
            )
            .elevation(isLatched ? .pressed : .low)
            .scaleEffect(isLatched ? 0.985 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        ColorTokens.canvasBackground.ignoresSafeArea()
        Latching3DButton("Engage Lock", icon: "lock.fill", isLatched: .constant(true))
    }
}
