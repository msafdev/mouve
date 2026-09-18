//
//  HapticEngine.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
public enum HapticEngine {
    #if canImport(UIKit)
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let selectionFeedback = UISelectionFeedbackGenerator()
    private static let notificationFeedback = UINotificationFeedbackGenerator()
    #endif

    public static func buttonPress() {
        #if canImport(UIKit)
        rigidImpact.prepare()
        rigidImpact.impactOccurred(intensity: 0.85)
        #endif
    }

    public static func buttonRelease() {
        #if canImport(UIKit)
        lightImpact.prepare()
        lightImpact.impactOccurred(intensity: 0.5)
        #endif
    }

    public static func selection() {
        #if canImport(UIKit)
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
        #endif
    }

    public static func success() {
        #if canImport(UIKit)
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
        #endif
    }

    public static func warning() {
        #if canImport(UIKit)
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.warning)
        #endif
    }

    public static func sliderTick() {
        #if canImport(UIKit)
        softImpact.prepare()
        softImpact.impactOccurred(intensity: 0.6)
        #endif
    }
}
