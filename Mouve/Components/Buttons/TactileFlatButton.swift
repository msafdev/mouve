//
//  TactileFlatButton.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

/// A clean, refined non-3D tactile button for sheets, dialogs, and secondary controls.
/// Has a solid matte surface, crisp micro-border, gentle press scale (0.975), and subtle haptics.
public struct TactileFlatButton: View {
    public enum Style {
        case primary
        case secondary
        case destructive
        case accent
    }

    private let title: String
    private let icon: String?
    private let style: Style
    private let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticEngine.selection()
            action()
        }) {
            HStack(spacing: SpacingTokens.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                }
                Text(title)
                    .font(TypographyTokens.componentTitle)
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.vertical, SpacingTokens.sm + 2)
        }
        .buttonStyle(TactileFlatButtonStyle(style: style))
    }
}

public struct TactileFlatButtonStyle: ButtonStyle {
    public var style: TactileFlatButton.Style

    public init(style: TactileFlatButton.Style = .primary) {
        self.style = style
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        configuration.label
            .foregroundColor(textColor)
            .background(
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                            .strokeBorder(borderColor, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.975 : 1.0)
            .opacity(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.80), value: isPressed)
            .onChange(of: isPressed) { _, pressed in
                if pressed {
                    HapticEngine.buttonPress()
                }
            }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return ColorTokens.textPrimary
        case .secondary: return ColorTokens.chipUnselectedBackground
        case .accent: return ColorTokens.accent
        case .destructive: return ColorTokens.danger
        }
    }

    private var textColor: Color {
        switch style {
        case .primary: return ColorTokens.canvasBackground
        case .secondary: return ColorTokens.textPrimary
        case .accent, .destructive: return .white
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return Color.clear
        case .secondary: return ColorTokens.surfaceBorder
        case .accent: return Color.white.opacity(0.20)
        case .destructive: return Color.white.opacity(0.15)
        }
    }
}

#Preview {
    ZStack {
        ColorTokens.canvasBackground.ignoresSafeArea()
        HStack(spacing: 12) {
            TactileFlatButton("Dismiss", icon: "xmark", style: .secondary)
            TactileFlatButton("Apply Changes", icon: "checkmark", style: .primary)
        }
    }
}
