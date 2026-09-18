//
//  ElevationTokens.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

public typealias ElevationTokens = ElevationLevel

/// Dual-layer ambient + key directional shadows.
/// Refined and ultra-subtle to eliminate muddy, dirty halos while maintaining soft physical depth.
public enum ElevationLevel: Sendable {
    case flat
    case low      // Subtle card or chip
    case medium   // Component showcase window
    case high     // Floating action button, sheet, modal
    case pressed  // Depressed state for 3D buttons

    public var ambientOpacity: Double {
        switch self {
        case .flat: return 0.0
        case .low: return 0.008
        case .medium: return 0.012
        case .high: return 0.035
        case .pressed: return 0.005
        }
    }

    public var ambientRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 3
        case .medium: return 8
        case .high: return 18
        case .pressed: return 1.5
        }
    }

    public var ambientY: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 1
        case .medium: return 2.5
        case .high: return 6
        case .pressed: return 0.5
        }
    }

    public var keyOpacity: Double {
        switch self {
        case .flat: return 0.0
        case .low: return 0.012
        case .medium: return 0.018
        case .high: return 0.045
        case .pressed: return 0.01
        }
    }

    public var keyRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 1.5
        case .medium: return 2.5
        case .high: return 6
        case .pressed: return 1
        }
    }

    public var keyY: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 1
        case .medium: return 1
        case .high: return 3
        case .pressed: return 1
        }
    }
}

public struct LayeredElevationModifier: ViewModifier {
    public let level: ElevationLevel

    public func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.black.opacity(level.ambientOpacity),
                radius: level.ambientRadius,
                x: 0,
                y: level.ambientY
            )
            .shadow(
                color: Color.black.opacity(level.keyOpacity),
                radius: level.keyRadius,
                x: 0,
                y: level.keyY
            )
    }
}

public extension View {
    func elevation(_ level: ElevationLevel) -> some View {
        self.modifier(LayeredElevationModifier(level: level))
    }
}
