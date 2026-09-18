//
//  Tactile3DButton.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

// MARK: - Physical 3D Push Button (True Extrusion Compression)
/// A high-travel physical 3D button. Sized strictly to its label content.
/// Features a real physical lower extrusion wall (7pt) and beveled face.
/// When pressed, the face travels downward, compressing the extrusion wall to 1.5pt with mechanical recoil.
public struct Tactile3DButton: View {
    public enum Style {
        case primary
        case accent
        case surface
        case danger
    }

    private let title: String
    private let icon: String?
    private let style: Style
    private let depth: CGFloat
    private let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        depth: CGFloat = 7.0,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.depth = depth
        self.action = action
    }

    @State private var isTapDepressed = false
    @State private var pressTask: Task<Void, Never>? = nil

    public var body: some View {
        Button(action: {
            // Guarantee a minimum visual 3D depression on quick taps
            pressTask?.cancel()
            withAnimation(MotionTokens.pressRecoil) {
                isTapDepressed = true
            }
            HapticEngine.buttonPress()
            pressTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 120_000_000) // 120ms physical stroke hold
                withAnimation(MotionTokens.pressRecoil) {
                    isTapDepressed = false
                }
                HapticEngine.buttonRelease()
                action()
            }
        }) {
            HStack(spacing: SpacingTokens.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(TypographyTokens.componentTitle)
            }
            .padding(.horizontal, SpacingTokens.xl)
            .padding(.vertical, SpacingTokens.md)
        }
        .buttonStyle(Tactile3DButtonStyle(style: style, depth: depth, isExternallyDepressed: isTapDepressed))
    }
}

public struct Tactile3DButtonStyle: ButtonStyle {
    public var style: Tactile3DButton.Style
    public var depth: CGFloat
    public var isExternallyDepressed: Bool

    public init(style: Tactile3DButton.Style = .primary, depth: CGFloat = 7.0, isExternallyDepressed: Bool = false) {
        self.style = style
        self.depth = depth
        self.isExternallyDepressed = isExternallyDepressed
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isExternallyDepressed

        // Sized strictly to configuration.label! Never expands to fill parent.
        configuration.label
            .foregroundColor(textColor)
            .shadow(
                color: isPressed ? Color.clear : Color.black.opacity(style == .surface ? 0.05 : 0.35),
                radius: 0,
                x: 0,
                y: isPressed ? 0 : -0.8
            )
            .background(
                // 1. Depressible Cap Surface
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [faceColor, faceGradientBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        // Specular Light Rim catching upper chamfer
                        RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isPressed ? 0.08 : 0.45),
                                        Color.white.opacity(0.06),
                                        Color.black.opacity(0.20)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.2
                            )
                    )
            )
            .offset(y: isPressed ? (depth - 1.5) : 0)
            .background(
                // 2. Fixed Physical Lower Extrusion Chassis Wall
                // Anchored directly behind the label, never filling container
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(baseColor)
                    .offset(y: depth)
            )
            .elevation(isPressed ? .pressed : .low)
            .scaleEffect(isPressed ? 0.985 : 1.0)
            .animation(MotionTokens.pressRecoil, value: isPressed)
            .onChange(of: isPressed) { _, pressed in
                if pressed {
                    HapticEngine.buttonPress()
                }
            }
    }

    private var faceColor: Color {
        switch style {
        case .primary: return ColorTokens.textPrimary
        case .accent: return ColorTokens.accent
        case .surface: return ColorTokens.surfaceElevated
        case .danger: return ColorTokens.danger
        }
    }

    private var faceGradientBottom: Color {
        switch style {
        case .primary: return Color(red: 0.12, green: 0.12, blue: 0.14)
        case .accent: return ColorTokens.accentDark
        case .surface: return Color(red: 0.94, green: 0.94, blue: 0.96)
        case .danger: return Color(red: 0.80, green: 0.20, blue: 0.22)
        }
    }

    private var baseColor: Color {
        switch style {
        case .primary: return Color.black.opacity(0.92)
        case .accent: return Color(red: 0.08, green: 0.16, blue: 0.52)
        case .surface: return Color.black.opacity(0.22)
        case .danger: return Color(red: 0.45, green: 0.08, blue: 0.10)
        }
    }

    private var textColor: Color {
        switch style {
        case .primary: return ColorTokens.canvasBackground
        case .accent, .danger: return .white
        case .surface: return ColorTokens.textPrimary
        }
    }
}

#Preview {
    ZStack {
        ColorTokens.canvasBackground.ignoresSafeArea()
        VStack(spacing: 24) {
            Tactile3DButton("Deep Press", icon: "cube.fill", style: .accent)
            Tactile3DButton("System Primary", icon: "arrow.right", style: .primary)
            Tactile3DButton("Surface Mode", icon: "slider.horizontal.3", style: .surface)
            Tactile3DButton("Danger Action", icon: "trash.fill", style: .danger)
        }
    }
}
