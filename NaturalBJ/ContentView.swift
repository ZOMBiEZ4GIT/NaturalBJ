//
//  ContentView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  REFACTOR: Now implements proper navigation and onboarding
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏠 CONTENT VIEW - App Entry Point & Navigation Controller                ║
// ║                                                                            ║
// ║ Purpose: Root view with navigation and onboarding logic                   ║
// ║ Business Context: Determines first-time vs returning user flow            ║
// ║                   Shows welcome/onboarding for new users                  ║
// ║                   Routes to game for returning users                      ║
// ║                                                                            ║
// ║ Flow:                                                                      ║
// ║ • First Launch: Welcome → Dealer Selection → Game                         ║
// ║ • Returning: Direct to Game                                               ║
// ║                                                                            ║
// ║ Related Spec: Lines 532-541 (First Launch Flow)                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI
import SwiftData

struct ContentView: View {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔑 APP STATE                                                         │
    // │                                                                      │
    // │ Observes AppStateManager to determine onboarding needs              │
    // └─────────────────────────────────────────────────────────────────────┘

    @ObservedObject private var appState = AppStateManager.shared
    @State private var showWelcome = false

    var body: some View {
        ZStack {
            // Main game view (always rendered)
            GameView()

            // Welcome/onboarding overlay for first launch
            if showWelcome {
                WelcomeView(isPresented: $showWelcome)
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
        .onAppear {
            // Check if this is first launch
            if appState.isFirstLaunch && !appState.hasCompletedOnboarding {
                // Small delay for smooth presentation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showWelcome = true
                    appState.completeFirstLaunch()
                }
            }
        }
    }
}

#Preview("Returning User") {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

#Preview("First Launch") {
    let preview = ContentView()
    AppStateManager.shared.isFirstLaunch = true
    AppStateManager.shared.hasCompletedOnboarding = false
    return preview
        .modelContainer(for: Item.self, inMemory: true)
}
