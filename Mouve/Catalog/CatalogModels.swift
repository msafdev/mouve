//
//  CatalogModels.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

public enum CategoryTag: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case button = "Button"
    case sheet = "Sheet"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .button: return "capsule.fill"
        case .sheet: return "rectangle.portrait.bottomhalf.filled"
        }
    }
}

public struct CatalogItem: Identifiable, Sendable, Hashable {
    public let id: String
    public let name: String
    public let category: CategoryTag
    public let windowShape: WindowShape
    public let description: String
    public let sourceCode: String
    public let previewBuilder: @MainActor () -> AnyView

    public static func == (lhs: CatalogItem, rhs: CatalogItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public init(
        id: String,
        name: String,
        category: CategoryTag,
        windowShape: WindowShape,
        description: String,
        sourceCode: String,
        @ViewBuilder previewBuilder: @escaping @MainActor () -> some View
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.windowShape = windowShape
        self.description = description
        self.sourceCode = sourceCode
        self.previewBuilder = { AnyView(previewBuilder()) }
    }
}

@MainActor
public enum CatalogRegistry {
    public static let items: [CatalogItem] = [
        CatalogItem(
            id: "3d-push-button",
            name: "3D Push Button",
            category: .button,
            windowShape: .rectangle,
            description: "Physical push button with real 3D extrusion compression, specular chamfer, and mechanical recoil.",
            sourceCode: """
import SwiftUI

public struct PushButton3D: View {
    public enum Style {
        case primary, accent, surface, danger
    }

    private let title: String
    private let icon: String?
    private let style: Style
    private let depth: CGFloat
    private let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        depth: CGFloat = 7.0,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.depth = depth
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticEngine.buttonRelease()
            action()
        }) {
            HStack(spacing: SpacingTokens.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(TypographyTokens.componentTitle)
            }
            .padding(.horizontal, SpacingTokens.xl)
            .padding(.vertical, SpacingTokens.md)
        }
        .buttonStyle(PushButton3DStyle(style: style, depth: depth))
    }
}

public struct PushButton3DStyle: ButtonStyle {
    public var style: PushButton3D.Style
    public var depth: CGFloat

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        configuration.label
            .foregroundColor(textColor)
            .shadow(
                color: isPressed ? Color.clear : Color.black.opacity(style == .surface ? 0.05 : 0.35),
                radius: 0,
                x: 0,
                y: isPressed ? 0 : -0.8
            )
            .background(
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [faceColor, faceGradientBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isPressed ? 0.08 : 0.45),
                                        Color.white.opacity(0.06),
                                        Color.black.opacity(0.20)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.2
                            )
                    )
            )
            .offset(y: isPressed ? (depth - 1.5) : 0)
            .background(
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(baseColor)
                    .offset(y: depth)
            )
            .elevation(isPressed ? .pressed : .low)
            .scaleEffect(isPressed ? 0.985 : 1.0)
            .animation(MotionTokens.pressRecoil, value: isPressed)
    }

    private var faceColor: Color {
        switch style {
        case .primary:
            return Color(
                light: Color(red: 0.20, green: 0.21, blue: 0.24),
                dark: Color(red: 0.26, green: 0.27, blue: 0.30)
            )
        case .accent:
            return ColorTokens.accent
        case .surface:
            return Color(
                light: Color.white,
                dark: Color(red: 0.22, green: 0.22, blue: 0.25)
            )
        case .danger:
            return ColorTokens.danger
        }
    }

    private var faceGradientBottom: Color {
        switch style {
        case .primary:
            return Color(
                light: Color(red: 0.12, green: 0.13, blue: 0.15),
                dark: Color(red: 0.16, green: 0.17, blue: 0.20)
            )
        case .accent:
            return ColorTokens.accentDark
        case .surface:
            return Color(
                light: Color(red: 0.95, green: 0.95, blue: 0.97),
                dark: Color(red: 0.16, green: 0.16, blue: 0.19)
            )
        case .danger:
            return ColorTokens.dangerDark
        }
    }

    private var baseColor: Color {
        switch style {
        case .primary:
            return Color(
                light: Color(red: 0.06, green: 0.06, blue: 0.08),
                dark: Color(red: 0.08, green: 0.08, blue: 0.10)
            )
        case .accent:
            return ColorTokens.accentBase
        case .surface:
            return ColorTokens.surfaceChassis
        case .danger:
            return ColorTokens.dangerBase
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return Color(red: 0.96, green: 0.97, blue: 0.99)
        case .accent, .danger:
            return .white
        case .surface:
            return ColorTokens.textPrimary
        }
    }
}
"""
        ) {
            Tactile3DButton("Deep Press", icon: "cube.fill", style: .primary, depth: 7.0)
        },
        CatalogItem(
            id: "mechanical-keycaps",
            name: "Mechanical Keycap Buttons",
            category: .button,
            windowShape: .rectangle,
            description: "Classic high-profile keyboard keycaps with concave dishes, stepped skirts, and deep travel.",
            sourceCode: """
import SwiftUI

public struct MechanicalKeycapButton: View {
    private let label: String
    private let sublabel: String?
    private let action: () -> Void

    public init(_ label: String, sublabel: String? = nil, action: @escaping () -> Void = {}) {
        self.label = label
        self.sublabel = sublabel
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticEngine.buttonPress()
            action()
        }) {
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 15, weight: .heavy, design: .monospaced))
                if let sublabel {
                    Text(sublabel)
                        .font(.system(size: 8.5, weight: .bold, design: .rounded))
                        .foregroundColor(ColorTokens.textTertiary)
                }
            }
            .frame(width: 58, height: 50)
        }
        .buttonStyle(KeycapButtonStyle())
    }
}

private struct KeycapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let travel: CGFloat = 5.5

        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color(red: 0.72, green: 0.74, blue: 0.78))
                .frame(width: 58, height: 50)
                .offset(y: travel)

            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.93, green: 0.94, blue: 0.96)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.10), lineWidth: 1)
                    )

                RadialGradient(
                    colors: [Color.black.opacity(0.04), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 22
                )
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                configuration.label
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.14))
                    .shadow(color: Color.white.opacity(0.8), radius: 0, x: 0, y: 0.8)
            }
            .frame(width: 54, height: 46)
            .offset(y: isPressed ? travel : 0)
        }
        .shadow(color: Color.black.opacity(isPressed ? 0.02 : 0.07), radius: isPressed ? 2 : 5, x: 0, y: isPressed ? 1 : 3)
        .animation(MotionTokens.pressRecoil, value: isPressed)
    }
}
"""
        ) {
            HStack(spacing: 14) {
                MechanicalKeycapButton("Esc", sublabel: "QUIT")
                MechanicalKeycapButton("⌘", sublabel: "CMD")
                MechanicalKeycapButton("⌥", sublabel: "OPT")
            }
        },
        CatalogItem(
            id: "latching-3d-switch",
            name: "Latching 3D Switch",
            category: .button,
            windowShape: .rectangle,
            description: "Push-to-latch 3D button that stays physically sunken when active and pops back up on release.",
            sourceCode: """
import SwiftUI

public struct Latching3DSwitch: View {
    @Binding private var isLatched: Bool
    private let title: String
    private let icon: String

    public init(_ title: String, icon: String, isLatched: Binding<Bool>) {
        self.title = title
        self.icon = icon
        self._isLatched = isLatched
    }

    public var body: some View {
        let depth: CGFloat = 5.5

        Button(action: {
            HapticEngine.selection()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                isLatched.toggle()
            }
        }) {
            HStack(spacing: SpacingTokens.xs) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                Text(title)
                    .font(TypographyTokens.componentTitle)
            }
            .foregroundColor(isLatched ? .white : ColorTokens.textPrimary)
            .padding(.horizontal, SpacingTokens.xl)
            .padding(.vertical, SpacingTokens.md)
            .background(
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(isLatched ? ColorTokens.accent : ColorTokens.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                            .strokeBorder(
                                isLatched ? Color.white.opacity(0.35) : ColorTokens.surfaceBorder,
                                lineWidth: 1.2
                            )
                    )
            )
            .offset(y: isLatched ? (depth - 1.0) : 0)
            .background(
                RoundedRectangle(cornerRadius: ShapeTokens.buttonRadius, style: .continuous)
                    .fill(isLatched ? ColorTokens.accentDark : Color.black.opacity(0.20))
                    .offset(y: depth)
            )
            .elevation(isLatched ? .pressed : .low)
            .scaleEffect(isLatched ? 0.985 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
"""
        ) {
            StatefulLatchingButtonPreview()
        },
        CatalogItem(
            id: "sequenced-action-button",
            name: "Sequenced Action Button",
            category: .button,
            windowShape: .rectangle,
            description: "Multi-state button morphing smoothly from idle to spinning progress to animated checkmark.",
            sourceCode: """
import SwiftUI

public enum ActionState: Equatable, Sendable {
    case idle, loading, success
}

public struct SequencedActionButton: View {
    private let title: String
    private let icon: String
    private let action: () async -> Bool

    @State private var state: ActionState = .idle
    @State private var rotationAngle: Double = 0
    @State private var checkmarkProgress: CGFloat = 0

    public init(
        _ title: String = "Complete Action",
        icon: String = "arrow.right",
        action: @escaping () async -> Bool = {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            return true
        }
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: triggerAction) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: state == .idle ? ShapeTokens.buttonRadius : 28,
                    style: .continuous
                )
                .fill(backgroundFill)
                .overlay(
                    RoundedRectangle(
                        cornerRadius: state == .idle ? ShapeTokens.buttonRadius : 28,
                        style: .continuous
                    )
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .elevation(.medium)

                switch state {
                case .idle:
                    HStack(spacing: SpacingTokens.xs) {
                        Text(title)
                            .font(TypographyTokens.componentTitle)
                            .foregroundColor(ColorTokens.canvasBackground)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ColorTokens.canvasBackground)
                    }
                    .padding(.horizontal, SpacingTokens.xl)

                case .loading:
                    Circle()
                        .trim(from: 0.15, to: 0.85)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }

                case .success:
                    CheckmarkShape()
                        .trim(from: 0, to: checkmarkProgress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round))
                        .frame(width: 22, height: 16)
                        .onAppear {
                            withAnimation(MotionTokens.bouncy) {
                                checkmarkProgress = 1.0
                            }
                        }
                }
            }
            .frame(
                width: state == .idle ? nil : 56,
                height: 52
            )
            .fixedSize(horizontal: state != .idle, vertical: true)
        }
        .buttonStyle(.plain)
    }
}
"""
        ) {
            SequencedActionButton("Initiate Sequence", icon: "sparkles")
        },
        CatalogItem(
            id: "bottom-sheet",
            name: "Bottom Sheet",
            category: .sheet,
            windowShape: .square,
            description: "Solid matte bottom sheet with hero illustration, confident typography, and pure mechanical slide dynamics.",
            sourceCode: """
import SwiftUI

public struct SolidBottomSheet<Content: View>: View {
    @Binding private var isPresented: Bool
    private let content: Content

    @State private var dragOffset: CGFloat = 0

    public init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(isPresented ? 0.40 * max(0, min(1, 1 - Double(dragOffset / 320))) : 0.0)
                .ignoresSafeArea()
                .allowsHitTesting(isPresented)
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                Capsule()
                    .fill(ColorTokens.textTertiary.opacity(0.38))
                    .frame(width: 38, height: 5)
                    .padding(.top, SpacingTokens.sm)
                    .padding(.bottom, SpacingTokens.lg)

                content
                    .padding(.bottom, SpacingTokens.xxxl)
            }
            .frame(maxWidth: .infinity)
            .background(
                BottomSheetShape(cornerRadius: 30, bottomExtension: 600)
                    .fill(ColorTokens.surfaceElevated)
            )
            .overlay(
                BottomSheetShape(cornerRadius: 30, bottomExtension: 600)
                    .stroke(ColorTokens.surfaceBorder, lineWidth: 1)
            )
            .elevation(.high)
            .offset(y: !isPresented ? 900 : (dragOffset < 0 ? dragOffset * 0.22 : dragOffset))
            .gesture(
                DragGesture()
                    .onChanged { gesture in dragOffset = gesture.translation.height }
                    .onEnded { gesture in
                        if gesture.translation.height > 90 || gesture.velocity.height > 600 {
                            isPresented = false
                        }
                        dragOffset = 0
                    }
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .animation(MotionTokens.smooth, value: isPresented)
    }
}
"""
        ) {
            SheetDemoWindow()
        }
    ]
}

// MARK: - Local Helper Preview Wrappers
private struct StatefulLatchingButtonPreview: View {
    @State private var isLatched = false
    var body: some View {
        Latching3DButton("Engage Lock", icon: isLatched ? "lock.fill" : "lock.open.fill", isLatched: $isLatched)
    }
}

private struct SheetDemoWindow: View {
    var body: some View {
        VStack(spacing: 16) {
            TactileFlatButton("Open Sheet", icon: "rectangle.stack.fill", style: .secondary) {
                OverlayManager.shared.presentSheet {
                    ActivityConfirmationSheetContent()
                }
            }
        }
    }
}

private struct ActivityConfirmationSheetContent: View {
    var body: some View {
        VStack(spacing: 20) {
            // 1. Hero Graphic Badge
            SheetHeroImageBadge()
                .padding(.vertical, SpacingTokens.xs)

            // 2. Bold Headline
            Text("Activity Added\nto Your Calendar")
                .font(.system(size: 25, weight: .heavy, design: .rounded))
                .foregroundColor(ColorTokens.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            // 3. Relaxed Subtitle
            Text("Activity has been successfully scheduled. We'll send you a reminder as the date approaches.")
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 300)

            // 4. Solid Tactile Action Pill Button
            Button(action: {
                HapticEngine.selection()
                OverlayManager.shared.dismissSheet()
            }) {
                Text("Got it")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(ColorTokens.canvasBackground)
                    .padding(.horizontal, SpacingTokens.xxl)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(ColorTokens.textPrimary)
                    )
            }
            .buttonStyle(TactilePillButtonStyle())
            .padding(.top, SpacingTokens.xs)
        }
        .padding(.horizontal, SpacingTokens.xl)
        .padding(.bottom, SpacingTokens.md)
    }
}
