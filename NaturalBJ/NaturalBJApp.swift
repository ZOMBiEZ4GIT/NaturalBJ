//
//  NaturalBJApp.swift
//  NaturalBJ
//
//  Created by Roland on 23/11/2025.
//

import SwiftUI
import SwiftData

@main
struct NaturalBJApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 PHASE 7: VISUAL SETTINGS MANAGER                                  │
    // │                                                                      │
    // │ Purpose: Inject visual settings into the environment for all views  │
    // │ This allows any view to access table colours, card backs, animation │
    // │ preferences, and visual effects settings                            │
    // └─────────────────────────────────────────────────────────────────────┘

    @StateObject private var visualSettings = VisualSettingsManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(visualSettings)
        }
        .modelContainer(sharedModelContainer)
    }
}
