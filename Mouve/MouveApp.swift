//
//  MouveApp.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI
import SwiftData

@main
struct MouveApp: App {
    private let dataContainer = DataContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(ColorTokens.canvasBackground.ignoresSafeArea())
        }
        .modelContainer(dataContainer.modelContainer)
    }
}
