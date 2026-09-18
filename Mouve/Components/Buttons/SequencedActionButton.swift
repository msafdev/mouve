//
//  SequencedActionButton.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

public enum ActionState: Equatable, Sendable {
    case idle
    case loading
    case success
}

/// A bespoke multi-state button that morphs fluidly between idle, spinning progress,
/// and an animated checkmark confirmation.
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
                // Background morphing capsule
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

                // State content
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
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))

                case .loading:
                    Circle()
                        .trim(from: 0.15, to: 0.85)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.7)))

                case .success:
                    CheckmarkShape()
                        .trim(from: 0, to: checkmarkProgress)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: 22, height: 16)
                        .onAppear {
                            withAnimation(MotionTokens.bouncy) {
                                checkmarkProgress = 1.0
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.5)))
                }
            }
            .frame(
                width: state == .idle ? 256 : 56,
                height: 54
            )
        }
        .disabled(state != .idle)
        .animation(MotionTokens.snappy, value: state)
    }

    private var backgroundFill: Color {
        switch state {
        case .idle:
            return ColorTokens.textPrimary
        case .loading:
            return ColorTokens.accent
        case .success:
            return ColorTokens.success
        }
    }

    private func triggerAction() {
        guard state == .idle else { return }
        HapticEngine.buttonPress()

        withAnimation(MotionTokens.snappy) {
            state = .loading
        }

        Task {
            let succeeded = await action()
            await MainActor.run {
                if succeeded {
                    HapticEngine.success()
                    withAnimation(MotionTokens.bouncy) {
                        state = .success
                    }

                    // Reset after delay
                    Task {
                        try? await Task.sleep(nanoseconds: 1_800_000_000)
                        await MainActor.run {
                            checkmarkProgress = 0
                            rotationAngle = 0
                            withAnimation(MotionTokens.smooth) {
                                state = .idle
                            }
                        }
                    }
                } else {
                    HapticEngine.warning()
                    withAnimation(MotionTokens.snappy) {
                        state = .idle
                    }
                }
            }
        }
    }
}

private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY * 1.05))
        path.addLine(to: CGPoint(x: rect.width * 0.38, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

#Preview {
    ZStack {
        ColorTokens.canvasBackground.ignoresSafeArea()
        SequencedActionButton("Initiate Sequence", icon: "sparkles")
    }
}
