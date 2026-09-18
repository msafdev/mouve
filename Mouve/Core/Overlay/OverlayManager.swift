//
//  OverlayManager.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI

/// Central coordinator for presenting full-screen overlays, sheets, and dialogs
/// at the root view level, preventing child components from trapping modals in local frames.
@MainActor
@Observable
public final class OverlayManager {
    public static let shared = OverlayManager()

    // MARK: - Root Sheet State
    public var isSheetPresented: Bool = false
    public var sheetTitle: String? = nil
    public var sheetContent: AnyView? = nil

    // MARK: - Root Dialog State
    public var isDialogPresented: Bool = false
    public var dialogTitle: String = ""
    public var dialogMessage: String = ""
    public var dialogConfirmTitle: String = "Confirm"
    public var dialogConfirmAction: (() -> Void)? = nil

    public init() {}

    // MARK: - Sheet Presentation
    public func presentSheet<Content: View>(
        title: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.sheetTitle = title
        self.sheetContent = AnyView(content())
        HapticEngine.selection()
        withAnimation(MotionTokens.smooth) {
            self.isSheetPresented = true
        }
    }

    public func dismissSheet() {
        HapticEngine.selection()
        withAnimation(MotionTokens.smooth) {
            self.isSheetPresented = false
        }
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                if !self.isSheetPresented {
                    self.sheetContent = nil
                }
            }
        }
    }

    // MARK: - Dialog Presentation
    public func presentDialog(
        title: String,
        message: String,
        confirmTitle: String = "Authorize",
        onConfirm: @escaping () -> Void = {}
    ) {
        self.dialogTitle = title
        self.dialogMessage = message
        self.dialogConfirmTitle = confirmTitle
        self.dialogConfirmAction = onConfirm
        HapticEngine.selection()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            self.isDialogPresented = true
        }
    }

    public func dismissDialog() {
        HapticEngine.selection()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
            self.isDialogPresented = false
        }
    }
}

public extension EnvironmentValues {
    @Entry var overlayManager: OverlayManager = .shared
}
