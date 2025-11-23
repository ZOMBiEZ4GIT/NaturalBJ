//
//  AppStateManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Core App State Management
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎯 APP STATE MANAGER                                                       ║
// ║                                                                            ║
// ║ Purpose: Centralized app-level state management                           ║
// ║ Business Context: Manages dealer selection, first launch state, and       ║
// ║                   other app-wide configuration that needs to persist       ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Track first launch state                                                ║
// ║ • Persist selected dealer                                                 ║
// ║ • Manage app-level user preferences                                       ║
// ║ • Coordinate state between views                                          ║
// ║                                                                            ║
// ║ Architecture: Singleton with @Published properties for SwiftUI binding    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI

@MainActor
class AppStateManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON INSTANCE                                                │
    // └─────────────────────────────────────────────────────────────────────┘

    static let shared = AppStateManager()

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                                   │
    // │                                                                      │
    // │ These properties trigger SwiftUI view updates when changed          │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Currently selected dealer personality
    @Published var selectedDealer: Dealer {
        didSet {
            saveSelectedDealer()
        }
    }

    /// Whether this is the user's first launch of the app
    @Published var isFirstLaunch: Bool {
        didSet {
            UserDefaults.standard.set(isFirstLaunch, forKey: UserDefaultsKeys.isFirstLaunch)
        }
    }

    /// Whether the user has completed onboarding
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔑 USERDEFAULTS KEYS                                                 │
    // └─────────────────────────────────────────────────────────────────────┘

    private enum UserDefaultsKeys {
        static let selectedDealerName = "selectedDealerName"
        static let isFirstLaunch = "isFirstLaunch"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALIZER                                                       │
    // │                                                                      │
    // │ Loads persisted state from UserDefaults                             │
    // └─────────────────────────────────────────────────────────────────────┘

    private init() {
        // Load first launch state (defaults to true if never set)
        self.isFirstLaunch = UserDefaults.standard.object(forKey: UserDefaultsKeys.isFirstLaunch) as? Bool ?? true

        // Load onboarding completion state
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)

        // Load selected dealer (defaults to Ruby)
        if let dealerName = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedDealerName),
           let dealer = Dealer.allDealers.first(where: { $0.name == dealerName }) {
            self.selectedDealer = dealer
        } else {
            // Default to Ruby (Vegas Classic) for first-time users
            self.selectedDealer = .ruby()
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💾 PERSISTENCE METHODS                                               │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Saves the currently selected dealer to UserDefaults
    private func saveSelectedDealer() {
        UserDefaults.standard.set(selectedDealer.name, forKey: UserDefaultsKeys.selectedDealerName)
    }

    /// Updates the selected dealer and persists the change
    func setDealer(_ dealer: Dealer) {
        selectedDealer = dealer
    }

    /// Marks first launch as complete
    func completeFirstLaunch() {
        isFirstLaunch = false
    }

    /// Marks onboarding as complete
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    /// Resets app state (for testing or user-initiated reset)
    func resetAppState() {
        isFirstLaunch = true
        hasCompletedOnboarding = false
        selectedDealer = .ruby()
    }
}
