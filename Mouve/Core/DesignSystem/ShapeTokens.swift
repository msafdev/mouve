//
//  ShapeTokens.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

public enum WindowShape: String, CaseIterable, Sendable {
    case rectangle
    case square

    /// Height factor or aspect ratio for the preview container
    public var aspectRatio: CGFloat {
        switch self {
        case .rectangle:
            return 1.55 // Wide window for buttons, sliders, action bars
        case .square:
            return 1.0  // 1:1 Square window for larger cards, sheets, 3D morphs
        }
    }

    /// Approximate baseline height on standard phone screens
    public var defaultHeight: CGFloat {
        switch self {
        case .rectangle:
            return 210
        case .square:
            return 330
        }
    }
}

public enum ShapeTokens {
    // MARK: - Corner Radii
    public static let windowRadius: CGFloat = 28
    public static let cardRadius: CGFloat = 22
    public static let buttonRadius: CGFloat = 16
    public static let controlRadius: CGFloat = 12
    public static let pillRadius: CGFloat = 100

    // MARK: - Shapes
    public static var windowShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: windowRadius, style: .continuous)
    }

    public static var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
    }

    public static var buttonShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: buttonRadius, style: .continuous)
    }

    public static var pillShape: Capsule {
        Capsule()
    }
}
