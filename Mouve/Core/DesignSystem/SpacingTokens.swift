//
//  SpacingTokens.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

public enum SpacingTokens {
    public static let xxxs: CGFloat = 2
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 20
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
    public static let xxxl: CGFloat = 44

    // MARK: - Component-Specific Layout Constants
    /// Horizontal screen margin for the gallery feed
    public static let screenHorizontalPadding: CGFloat = 20

    /// Vertical space between component preview window and its centered title
    public static let windowToTitleSpacing: CGFloat = 14

    /// Vertical space between consecutive showcase items
    public static let itemToItemSpacing: CGFloat = 32

    /// Category chip horizontal internal padding
    public static let chipPaddingHorizontal: CGFloat = 14
    public static let chipPaddingVertical: CGFloat = 8
}
