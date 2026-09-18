//
//  DataContainer.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import Foundation
import SwiftData

@MainActor
public final class DataContainer {
    public static let shared = DataContainer(inMemory: false)
    public static let preview = DataContainer(inMemory: true)

    public let modelContainer: ModelContainer

    public init(inMemory: Bool = false) {
        let schema = Schema([
            UserPreference.self,
            ComponentBookmark.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // In case of store migration conflicts during development, fall back to in-memory store
            let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                self.modelContainer = try ModelContainer(for: schema, configurations: [fallbackConfiguration])
            } catch {
                fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
            }
        }
    }
}
