//
//  ColorTokens.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

public enum ColorTokens {
    // MARK: - Canvas & Background
    /// Main app canvas background (clean crisp studio white/off-white in light, deep matte obsidian in dark)
    public static let canvasBackground = Color(
        light: Color(red: 0.975, green: 0.978, blue: 0.982),
        dark: Color(red: 0.075, green: 0.075, blue: 0.09)
    )

    // MARK: - Surfaces (Solid, matte surfaces - strictly no liquid glass)
    /// Surface for component showcase windows and cards (pure white in light mode)
    public static let surface = Color(
        light: Color.white,
        dark: Color(red: 0.13, green: 0.13, blue: 0.155)
    )

    /// Elevated surface for floating pills, sheets, and popovers
    public static let surfaceElevated = Color(
        light: Color.white,
        dark: Color(red: 0.165, green: 0.165, blue: 0.195)
    )

    /// Subtle hairline border for defining surfaces cleanly without heavy shadows
    public static let surfaceBorder = Color(
        light: Color.black.opacity(0.045),
        dark: Color.white.opacity(0.075)
    )

    /// Beveled specular highlight rim for tactile 3D elements
    public static let specularHighlight = Color(
        light: Color.white.opacity(0.7),
        dark: Color.white.opacity(0.18)
    )

    // MARK: - Typography
    public static let textPrimary = Color(
        light: Color(red: 0.08, green: 0.08, blue: 0.10),
        dark: Color(red: 0.96, green: 0.96, blue: 0.98)
    )

    public static let textSecondary = Color(
        light: Color(red: 0.45, green: 0.46, blue: 0.50),
        dark: Color(red: 0.55, green: 0.56, blue: 0.60)
    )

    public static let textTertiary = Color(
        light: Color(red: 0.68, green: 0.69, blue: 0.72),
        dark: Color(red: 0.38, green: 0.39, blue: 0.43)
    )

    // MARK: - Chips (Category Filter)
    public static let chipSelectedBackground = Color(
        light: Color(red: 0.08, green: 0.08, blue: 0.10),
        dark: Color(red: 0.96, green: 0.96, blue: 0.98)
    )

    public static let chipSelectedText = Color(
        light: Color(red: 0.98, green: 0.98, blue: 0.99),
        dark: Color(red: 0.08, green: 0.08, blue: 0.10)
    )

    public static let chipUnselectedBackground = Color(
        light: Color(red: 0.90, green: 0.90, blue: 0.92),
        dark: Color(red: 0.14, green: 0.14, blue: 0.16)
    )

    public static let chipUnselectedText = Color(
        light: Color(red: 0.20, green: 0.20, blue: 0.24),
        dark: Color(red: 0.85, green: 0.85, blue: 0.88)
    )

    // MARK: - Accents & States
    public static let accent = Color(red: 0.24, green: 0.42, blue: 0.98)
    public static let accentDark = Color(red: 0.16, green: 0.32, blue: 0.82)
    public static let success = Color(red: 0.18, green: 0.80, blue: 0.44)
    public static let warning = Color(red: 0.98, green: 0.68, blue: 0.18)
    public static let danger = Color(red: 0.95, green: 0.26, blue: 0.28)
}

private extension Color {
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
        #else
        self = dark
        #endif
    }
}
