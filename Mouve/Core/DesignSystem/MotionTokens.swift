//
//  MotionTokens.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

public enum MotionTokens {
    // MARK: - Spring Curves
    /// Snappy kinetic feedback for button presses, chip selection, and toggles
    public static let snappy = Animation.spring(response: 0.28, dampingFraction: 0.76)

    /// Bouncy spring for delight, checkmark morphs, and playful triggers
    public static let bouncy = Animation.spring(response: 0.38, dampingFraction: 0.62)

    /// Smooth, critically damped spring for sheet expansions and container transitions
    public static let smooth = Animation.spring(response: 0.46, dampingFraction: 0.88)

    /// High-responsiveness spring for directly tracking drag gestures
    public static let interactive = Animation.interactiveSpring(response: 0.30, dampingFraction: 0.82)

    /// Spring specifically tuned for physical 3D button press & rebound
    public static let pressRecoil = Animation.spring(response: 0.22, dampingFraction: 0.68)

    // MARK: - Durations & Delays
    public static let stateMorphDuration: Double = 0.35
    public static let checkmarkDelay: Double = 0.15

    // MARK: - Accessibility Helpers
    /// Returns the specified animation or nil if Reduce Motion is active
    public static func adaptive(
        _ animation: Animation = snappy,
        reduceMotion: Bool
    ) -> Animation? {
        reduceMotion ? nil : animation
    }
}
