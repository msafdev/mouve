//
//  UserPreference.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import Foundation
import SwiftData

@Model
public final class UserPreference {
    public var id: String
    public var reduceMotionOverride: Bool
    public var hapticsEnabled: Bool
    public var soundEnabled: Bool
    public var selectedTheme: String
    public var updatedAt: Date

    public init(
        id: String = "default",
        reduceMotionOverride: Bool = false,
        hapticsEnabled: Bool = true,
        soundEnabled: Bool = false,
        selectedTheme: String = "system",
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.reduceMotionOverride = reduceMotionOverride
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.selectedTheme = selectedTheme
        self.updatedAt = updatedAt
    }
}
