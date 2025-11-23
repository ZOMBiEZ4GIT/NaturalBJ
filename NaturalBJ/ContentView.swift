//
//  ContentView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Updated for Phase 1: Foundation Setup
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏠 CONTENT VIEW - App Entry Point                                         ║
// ║                                                                            ║
// ║ Purpose: Root view of the app, currently displays GameView                ║
// ║ Business Context: This is the entry point for the app. For Phase 1,       ║
// ║                   we're directly showing the GameView to iterate on        ║
// ║                   design. Later phases will add welcome screen, dealer     ║
// ║                   selection, etc.                                          ║
// ║                                                                            ║
// ║ Phase 1: Direct to GameView                                                ║
// ║ Phase 2+: Will add navigation, welcome screen, dealer selection           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        // For Phase 1, go straight to the game view
        // Later phases will add proper navigation structure
        GameView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
