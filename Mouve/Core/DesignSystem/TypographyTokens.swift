//
//  TypographyTokens.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

public enum TypographyTokens {
    // MARK: - Font Sizes
    public static let sizeDisplay: CGFloat = 34
    public static let sizeTitle1: CGFloat = 26
    public static let sizeTitle2: CGFloat = 20
    public static let sizeHeadline: CGFloat = 17
    public static let sizeBody: CGFloat = 15
    public static let sizeChip: CGFloat = 13.5
    public static let sizeCaption: CGFloat = 12
    public static let sizeCode: CGFloat = 12.5

    // MARK: - Semantic Fonts
    /// Gallery top title / large headers
    public static let display = Font.system(size: sizeDisplay, weight: .bold, design: .rounded)

    /// Component showcase labels (centered under window)
    public static let componentTitle = Font.system(size: sizeHeadline, weight: .semibold, design: .rounded)

    /// Category chip labels
    public static let chip = Font.system(size: sizeChip, weight: .medium, design: .rounded)

    /// Body narrative text
    public static let body = Font.system(size: sizeBody, weight: .regular, design: .default)

    /// Secondary descriptions
    public static let caption = Font.system(size: sizeCaption, weight: .medium, design: .default)

    /// Code snippets and technical values
    public static let code = Font.system(size: sizeCode, weight: .regular, design: .monospaced)
}
