//
//  ContentView.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        GalleryScreenView()
            .background(ColorTokens.canvasBackground.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
        .modelContainer(DataContainer.preview.modelContainer)
}
