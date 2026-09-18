//
//  ComponentDetailView.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

/// Dedicated Component Detail Page providing:
/// 1. Navigation bar with dismiss button, title, and light/dark appearance toggle
/// 2. Centered interactive live stage of the component
/// 3. Component details: category badge, window shape, and architectural summary
/// 4. Syntax-styled code viewer with full SwiftUI component implementation
/// 5. Prominent tactile "Copy Code" button with haptic tick and confirmation animation
public struct ComponentDetailView: View {
    private let item: CatalogItem

    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var colorSchemeOverride: ColorScheme? = nil
    @State private var hasCopied = false
    @State private var overlayManager = OverlayManager.shared
    @State private var isCodeExpanded = false

    private var effectiveColorScheme: ColorScheme {
        colorSchemeOverride ?? systemColorScheme
    }

    public init(item: CatalogItem) {
        self.item = item
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ColorTokens.canvasBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: SpacingTokens.lg) {
                    // MARK: - Bespoke Header Bar (Clean, no native toolbar gray pill artifacts)
                    customHeaderBar
                        .padding(.top, SpacingTokens.xs)

                    // MARK: - Live Interactive Stage
                    liveStageSection

                    // MARK: - Swift Implementation Code Block
                    codeSnippetSection

                    // Bottom spacing
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, SpacingTokens.screenHorizontalPadding)
            }

            // MARK: - Component-Level Sheet Overlay (Allows sheet to open inside detail page!)
            MorphingSheet(
                isPresented: Binding(
                    get: { overlayManager.isSheetPresented },
                    set: { if !$0 { overlayManager.dismissSheet() } }
                ),
                title: overlayManager.sheetTitle
            ) {
                if let content = overlayManager.sheetContent {
                    content
                }
            }
            .zIndex(100)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .environment(\.overlayManager, overlayManager)
        .preferredColorScheme(colorSchemeOverride)
    }

    // MARK: - Custom Header Bar (Eliminates all native navigation bar gray backgrounds)
    private var customHeaderBar: some View {
        HStack {
            Button(action: {
                HapticEngine.selection()
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(ColorTokens.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(ColorTokens.surface)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(ColorTokens.surfaceBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Text(item.name)
                .font(TypographyTokens.componentTitle)
                .foregroundColor(ColorTokens.textPrimary)

            Spacer()

            Button(action: toggleAppearance) {
                Image(systemName: colorSchemeOverride == .dark ? "moon.fill" : (colorSchemeOverride == .light ? "sun.max.fill" : "circle.lefthalf.filled"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(ColorTokens.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(ColorTokens.surface)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(ColorTokens.surfaceBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    // MARK: - Live Stage (No category chip or INTERACTIVE PREVIEW text)
    private var liveStageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ShapeTokens.windowRadius, style: .continuous)
                .fill(ColorTokens.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: ShapeTokens.windowRadius, style: .continuous)
                        .strokeBorder(ColorTokens.surfaceBorder, lineWidth: 1)
                )

            item.previewBuilder()
                .padding(SpacingTokens.xl)
        }
        .frame(maxWidth: .infinity)
        .frame(height: item.windowShape == .square ? 300 : 210)
        .elevation(.low)
    }

    @State private var isCodeRevealed = false

    // MARK: - Swift Code Viewer & Copy Button (Shadcn-style Monotone)
    private var codeSnippetSection: some View {
        let isDark = effectiveColorScheme == .dark
        let codeEditorBg = ColorTokens.surface
        let codeEditorBorder = ColorTokens.surfaceBorder
        let actionBtnBg = ColorTokens.chipUnselectedBackground

        return VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack {
                Text("SWIFT IMPLEMENTATION")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(ColorTokens.textTertiary)
                    .tracking(1.2)

                Spacer()

                // Copy Code Button
                Button(action: copySourceCode) {
                    HStack(spacing: 6) {
                        Image(systemName: hasCopied ? "checkmark" : "doc.on.doc.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text(hasCopied ? "Copied!" : "Copy Code")
                            .font(.system(size: 11.5, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(hasCopied ? ColorTokens.canvasBackground : ColorTokens.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(hasCopied ? ColorTokens.textPrimary : ColorTokens.surface)
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(ColorTokens.surfaceBorder, lineWidth: 1)
                    )
                    .elevation(hasCopied ? .low : .flat)
                    .animation(MotionTokens.pressRecoil, value: hasCopied)
                }
                .buttonStyle(.plain)
            }

            // Clean Monotone Code Container with Expandable Height
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    ScrollView(.horizontal, showsIndicators: isCodeExpanded) {
                        Text(CodeHighlighter.highlight(code: item.sourceCode, isDark: isDark))
                            .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                            .lineSpacing(5)
                            .textSelection(.enabled)
                            .padding(SpacingTokens.lg)
                            .padding(.bottom, isCodeExpanded ? SpacingTokens.lg : 36)
                            .fixedSize(horizontal: true, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(maxHeight: isCodeExpanded ? nil : 240, alignment: .topLeading)
                    .clipped()

                    // Bottom fade out gradient when collapsed
                    if !isCodeExpanded {
                        LinearGradient(
                            colors: [
                                codeEditorBg.opacity(0),
                                codeEditorBg.opacity(0.85),
                                codeEditorBg
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 64)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                    }
                }

                // Expand / Collapse Action Bar
                Button(action: {
                    HapticEngine.selection()
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                        isCodeExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Text(isCodeExpanded ? "Collapse Code" : "Show Full Code")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        Image(systemName: isCodeExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(ColorTokens.textPrimary.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(actionBtnBg)
                    .overlay(
                        Rectangle()
                            .fill(codeEditorBorder)
                            .frame(height: 1),
                        alignment: .top
                    )
                }
                .buttonStyle(.plain)
            }
            .background(codeEditorBg)
            .clipShape(RoundedRectangle(cornerRadius: ShapeTokens.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ShapeTokens.cardRadius, style: .continuous)
                    .strokeBorder(codeEditorBorder, lineWidth: 1)
            )
            .elevation(.low)
        }
        .opacity(isCodeRevealed ? 1.0 : 0.0)
        .blur(radius: isCodeRevealed ? 0 : 14)
        .offset(y: isCodeRevealed ? 0 : 16)
        .onAppear {
            withAnimation(.spring(response: 0.44, dampingFraction: 0.84).delay(0.06)) {
                isCodeRevealed = true
            }
        }
    }

    private func copySourceCode() {
        UIPasteboard.general.string = item.sourceCode
        HapticEngine.selection()
        withAnimation(MotionTokens.bouncy) {
            hasCopied = true
        }

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 0.25)) {
                hasCopied = false
            }
        }
    }

    private func toggleAppearance() {
        HapticEngine.selection()
        if colorSchemeOverride == nil {
            colorSchemeOverride = .dark
        } else if colorSchemeOverride == .dark {
            colorSchemeOverride = .light
        } else {
            colorSchemeOverride = nil
        }
    }
}

// MARK: - Memoized High-Performance Syntax Highlighter
@MainActor
public enum CodeHighlighter {
    private static var cache: [String: AttributedString] = [:]

    public static func highlight(code: String, isDark: Bool) -> AttributedString {
        let key = "\(code.hashValue)-\(isDark)"
        if let cached = cache[key] {
            return cached
        }
        let highlighted = render(code: code, isDark: isDark)
        cache[key] = highlighted
        return highlighted
    }

    private static func render(code: String, isDark: Bool) -> AttributedString {
        let lines = code.components(separatedBy: "\n")
        var result = AttributedString()

        let keywords: Set<String> = [
            "import", "from", "export", "default", "public", "private", "fileprivate", "internal",
            "struct", "class", "enum", "protocol", "extension", "actor",
            "var", "let", "func", "init", "case", "switch", "if", "else", "guard",
            "return", "try", "await", "async", "true", "false", "nil", "self", "Self",
            "some", "any", "where", "for", "in"
        ]

        let attributes: Set<String> = [
            "@main", "@State", "@Binding", "@Environment", "@Query", "@Model",
            "@Observable", "@MainActor", "@Sendable", "@ViewBuilder", "@Published"
        ]

        let keywordColor = isDark ? Color(red: 0.95, green: 0.35, blue: 0.38) : Color(red: 0.85, green: 0.16, blue: 0.22)
        let plainColor = isDark ? Color(white: 0.92) : Color(red: 0.12, green: 0.13, blue: 0.16)
        let commentColor = isDark ? Color(white: 0.44) : Color(red: 0.55, green: 0.58, blue: 0.62)
        let stringColor = isDark ? Color(red: 0.38, green: 0.72, blue: 0.90) : Color(red: 0.10, green: 0.45, blue: 0.75)

        for (lineIdx, line) in lines.enumerated() {
            var lineAttr = AttributedString()
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("//") {
                var commentAttr = AttributedString(line)
                commentAttr.foregroundColor = commentColor
                commentAttr.font = .system(size: 12.5, weight: .regular, design: .monospaced)
                lineAttr.append(commentAttr)
            } else {
                let chars = Array(line)
                var i = 0

                while i < chars.count {
                    if chars[i] == "/" && i + 1 < chars.count && chars[i + 1] == "/" {
                        let remainder = String(chars[i...])
                        var commentAttr = AttributedString(remainder)
                        commentAttr.foregroundColor = commentColor
                        commentAttr.font = .system(size: 12.5, weight: .regular, design: .monospaced)
                        lineAttr.append(commentAttr)
                        break
                    }

                    if chars[i] == "\"" {
                        var strLiteral = "\""
                        i += 1
                        while i < chars.count {
                            let c = chars[i]
                            strLiteral.append(c)
                            if c == "\"" && chars[i - 1] != "\\" {
                                i += 1
                                break
                            }
                            i += 1
                        }
                        var strAttr = AttributedString(strLiteral)
                        strAttr.foregroundColor = stringColor
                        strAttr.font = .system(size: 12.5, weight: .regular, design: .monospaced)
                        lineAttr.append(strAttr)
                        continue
                    }

                    if chars[i].isLetter || chars[i] == "_" || chars[i] == "@" {
                        var ident = ""
                        while i < chars.count && (chars[i].isLetter || chars[i].isNumber || chars[i] == "_" || chars[i] == "@") {
                            ident.append(chars[i])
                            i += 1
                        }

                        var wordAttr = AttributedString(ident)

                        if keywords.contains(ident) || attributes.contains(ident) {
                            wordAttr.foregroundColor = keywordColor
                            wordAttr.font = .system(size: 12.5, weight: .semibold, design: .monospaced)
                        } else {
                            wordAttr.foregroundColor = plainColor
                            wordAttr.font = .system(size: 12.5, weight: .regular, design: .monospaced)
                        }

                        lineAttr.append(wordAttr)
                        continue
                    }

                    var symbolAttr = AttributedString(String(chars[i]))
                    symbolAttr.foregroundColor = plainColor
                    symbolAttr.font = .system(size: 12.5, weight: .regular, design: .monospaced)
                    lineAttr.append(symbolAttr)
                    i += 1
                }
            }

            result.append(lineAttr)
            if lineIdx < lines.count - 1 {
                result.append(AttributedString("\n"))
            }
        }

        return result
    }
}

#Preview {
    NavigationStack {
        ComponentDetailView(item: CatalogRegistry.items[0])
    }
}

