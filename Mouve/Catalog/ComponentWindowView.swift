//
//  ComponentWindowView.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

/// Renders a single showcase item matching the user's wireframe design:
/// - A solid "window" card (either `.rectangle` or `.square` for bigger components)
/// - The live interactive component centered inside
/// - Centered component name typography below the window
public struct ComponentWindowView: View {
    private let item: CatalogItem
    private let onTapDetail: (() -> Void)?
    
    public init(item: CatalogItem, onTapDetail: (() -> Void)? = nil) {
        self.item = item
        self.onTapDetail = onTapDetail
    }
    
    public var body: some View {
        VStack(spacing: SpacingTokens.windowToTitleSpacing) {
            // MARK: - The Window (Live Component Stage)
            ZStack {
                // Background & Border (Strictly solid matte, no liquid glass)
                RoundedRectangle(cornerRadius: ShapeTokens.windowRadius, style: .continuous)
                    .fill(ColorTokens.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: ShapeTokens.windowRadius, style: .continuous)
                            .strokeBorder(ColorTokens.surfaceBorder, lineWidth: 1)
                    )
                
                // Live Interactive Component
                item.previewBuilder()
                    .padding(SpacingTokens.lg)
            }
            .frame(maxWidth: .infinity)
            .frame(height: item.windowShape.defaultHeight)
            .elevation(.low)
            
            // MARK: - Centered Component Title & Code Navigation Trigger
            Button(action: {
                HapticEngine.selection()
                onTapDetail?()
            }) {
                HStack(spacing: 12) {
                    Text(item.name)
                        .font(TypographyTokens.componentTitle)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ZStack {
        ColorTokens.canvasBackground.ignoresSafeArea()
        ComponentWindowView(item: CatalogRegistry.items[0])
            .padding(20)
    }
}
