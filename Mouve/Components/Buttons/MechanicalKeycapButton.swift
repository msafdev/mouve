//
//  MechanicalKeycapButton.swift
//  Mouve
//
//  Created by Salman Alfarisi on 18/09/26.
//

import SwiftUI

/// Classic high-profile keyboard keycap with concave dish, stepped skirt, and deep mechanical travel.
public struct MechanicalKeycapButton: View {
    private let label: String
    private let sublabel: String?
    private let action: () -> Void

    public init(_ label: String, sublabel: String? = nil, action: @escaping () -> Void = {}) {
        self.label = label
        self.sublabel = sublabel
        self.action = action
    }

    @State private var isTapDepressed = false
    @State private var pressTask: Task<Void, Never>? = nil

    public var body: some View {
        Button(action: {
            pressTask?.cancel()
            withAnimation(MotionTokens.pressRecoil) {
                isTapDepressed = true
            }
            HapticEngine.buttonPress()
            pressTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 120_000_000)
                withAnimation(MotionTokens.pressRecoil) {
                    isTapDepressed = false
                }
                HapticEngine.buttonRelease()
                action()
            }
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
        .buttonStyle(KeycapButtonStyle(isExternallyDepressed: isTapDepressed))
    }
}

public struct KeycapButtonStyle: ButtonStyle {
    public var isExternallyDepressed: Bool

    public init(isExternallyDepressed: Bool = false) {
        self.isExternallyDepressed = isExternallyDepressed
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isExternallyDepressed
        let travel: CGFloat = 5.5

        ZStack {
            // Fixed Skirt Base
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color(red: 0.72, green: 0.74, blue: 0.78))
                .frame(width: 58, height: 50)
                .offset(y: travel)

            // Depressible Keycap Plunger
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

                // Concave Dish
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
        .onChange(of: isPressed) { _, pressed in
            if pressed { HapticEngine.buttonPress() }
        }
    }
}

#Preview {
    ZStack {
        ColorTokens.canvasBackground.ignoresSafeArea()
        HStack(spacing: 14) {
            MechanicalKeycapButton("Esc", sublabel: "QUIT")
            MechanicalKeycapButton("⌘", sublabel: "CMD")
            MechanicalKeycapButton("⌥", sublabel: "OPT")
            MechanicalKeycapButton("↵", sublabel: "RET")
        }
    }
}
