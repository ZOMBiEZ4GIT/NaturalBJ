//
//  TutorialStep.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6: Tutorial & Help System
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ TutorialStep.swift                                                            ║
// ║                                                                               ║
// ║ Defines the structure and flow of the interactive tutorial system.           ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • New players need a guided walkthrough to learn blackjack basics            ║
// ║ • Tutorial must be non-intrusive and skippable at any time                   ║
// ║ • Each step highlights a specific UI element and explains its purpose        ║
// ║ • Steps build progressively from basic concepts to advanced features         ║
// ║                                                                               ║
// ║ DESIGN PHILOSOPHY:                                                            ║
// ║ • "Show, don't tell" - Interactive learning beats passive reading            ║
// ║ • Minimal text - Keep instructions concise and actionable                    ║
// ║ • Progressive disclosure - Introduce complexity gradually                    ║
// ║ • Real gameplay - Tutorial uses actual game mechanics                        ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 🎓 TUTORIAL STEP                                                          │
// │                                                                           │
// │ Represents a single step in the tutorial flow.                           │
// │ Each step has instructions, optional UI highlighting, and validation.    │
// └──────────────────────────────────────────────────────────────────────────┘

struct TutorialStep: Identifiable, Codable, Equatable {
    let id: UUID
    let stepType: TutorialStepType
    let title: String
    let bodyText: String
    let imageName: String?
    let highlightedUIElement: UIElementIdentifier?
    let requiredAction: TutorialAction
    let nextButtonText: String

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISERS                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    init(
        id: UUID = UUID(),
        stepType: TutorialStepType,
        title: String,
        bodyText: String,
        imageName: String? = nil,
        highlightedUIElement: UIElementIdentifier? = nil,
        requiredAction: TutorialAction,
        nextButtonText: String = "Next"
    ) {
        self.id = id
        self.stepType = stepType
        self.title = title
        self.bodyText = bodyText
        self.imageName = imageName
        self.highlightedUIElement = highlightedUIElement
        self.requiredAction = requiredAction
        self.nextButtonText = nextButtonText
    }
}

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 📋 TUTORIAL STEP TYPE                                                     │
// │                                                                           │
// │ Enumeration of all tutorial steps in sequence.                           │
// │ Order matters - steps are presented in this exact order.                 │
// └──────────────────────────────────────────────────────────────────────────┘

enum TutorialStepType: String, Codable, CaseIterable {
    case welcome           // Welcome screen - introduce app
    case dealerSelection   // Guide to selecting first dealer
    case placeBet          // Explain betting mechanics
    case dealCards         // Explain initial deal
    case playerActions     // Explain Hit/Stand/Double/Split
    case dealerPlay        // Explain dealer's turn
    case results           // Explain outcomes and payouts
    case statistics        // Point out statistics tracking
    case settings          // Show settings and customisation
    case completion        // Congratulate and offer free play

    /// Human-readable name for logging
    var displayName: String {
        switch self {
        case .welcome: return "Welcome"
        case .dealerSelection: return "Dealer Selection"
        case .placeBet: return "Place Bet"
        case .dealCards: return "Deal Cards"
        case .playerActions: return "Player Actions"
        case .dealerPlay: return "Dealer Play"
        case .results: return "Results"
        case .statistics: return "Statistics"
        case .settings: return "Settings"
        case .completion: return "Completion"
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 🎯 UI ELEMENT IDENTIFIER                                                  │
// │                                                                           │
// │ Identifies specific UI elements to highlight during tutorial.            │
// │ These map to accessibilityIdentifier values in SwiftUI views.            │
// └──────────────────────────────────────────────────────────────────────────┘

enum UIElementIdentifier: String, Codable {
    // Dealer Selection Screen
    case dealerCards = "dealer_cards"
    case dealerInfo = "dealer_info"

    // Game Screen - Top Bar
    case bankrollDisplay = "bankroll_display"
    case helpButton = "help_button"
    case settingsButton = "settings_button"

    // Game Screen - Betting
    case betSlider = "bet_slider"
    case betPresets = "bet_presets"
    case placeBetButton = "place_bet_button"

    // Game Screen - Gameplay
    case dealerArea = "dealer_area"
    case playerArea = "player_area"
    case hitButton = "hit_button"
    case standButton = "stand_button"
    case doubleButton = "double_button"
    case splitButton = "split_button"
    case surrenderButton = "surrender_button"

    // Game Screen - Results
    case resultMessage = "result_message"
    case nextHandButton = "next_hand_button"

    // Statistics
    case statisticsSwipeIndicator = "statistics_swipe_indicator"
    case currentSessionPanel = "current_session_panel"
}

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ ✅ TUTORIAL ACTION                                                        │
// │                                                                           │
// │ Defines what the user must do to complete each tutorial step.            │
// │ TutorialManager validates these actions before advancing.                │
// └──────────────────────────────────────────────────────────────────────────┘

enum TutorialAction: Codable, Equatable {
    case tapNext              // Just tap Next button
    case selectDealer         // Select any dealer
    case setBet               // Set a bet amount
    case placeBet             // Confirm the bet
    case waitForDeal          // Wait for cards to be dealt
    case makePlayerAction     // Take any action (Hit/Stand)
    case waitForDealerPlay    // Wait for dealer to finish
    case viewResults          // View the results
    case tapNextHand          // Tap Next Hand button
    case exploreStatistics    // Swipe up to see stats (optional)
    case exploreSettings      // Open settings (optional)
    case finishTutorial       // Mark tutorial as complete
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📚 TUTORIAL STEP DEFINITIONS                                                  ║
// ║                                                                               ║
// ║ Pre-defined tutorial steps for the Natural blackjack app.                    ║
// ║ These guide new users through their first complete game.                     ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

extension TutorialStep {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎯 ALL TUTORIAL STEPS                                                 │
    // │                                                                       │
    // │ Complete ordered sequence of tutorial steps.                         │
    // │ This is the single source of truth for tutorial flow.                │
    // └──────────────────────────────────────────────────────────────────────┘

    static let allSteps: [TutorialStep] = [
        // Step 1: Welcome
        TutorialStep(
            stepType: .welcome,
            title: "Welcome to Natural",
            bodyText: "A premium blackjack experience with unique dealer personalities, comprehensive statistics, and beautiful design. Let's learn the basics!",
            requiredAction: .tapNext,
            nextButtonText: "Let's Begin"
        ),

        // Step 2: Dealer Selection
        TutorialStep(
            stepType: .dealerSelection,
            title: "Choose Your Dealer",
            bodyText: "Each dealer has a unique personality and rule variations. Ruby is beginner-friendly with standard rules. Tap any dealer to select them.",
            highlightedUIElement: .dealerCards,
            requiredAction: .selectDealer,
            nextButtonText: "Continue"
        ),

        // Step 3: Place Bet
        TutorialStep(
            stepType: .placeBet,
            title: "Place Your Bet",
            bodyText: "Use the slider to choose your bet amount. Start with the minimum bet to learn the game. Tap 'Place Bet' when ready.",
            highlightedUIElement: .betSlider,
            requiredAction: .placeBet,
            nextButtonText: "Continue"
        ),

        // Step 4: Deal Cards
        TutorialStep(
            stepType: .dealCards,
            title: "The Deal",
            bodyText: "You receive two cards face-up. The dealer gets one card face-up and one face-down (hole card). The goal: Get closer to 21 than the dealer without going over.",
            highlightedUIElement: .playerArea,
            requiredAction: .waitForDeal,
            nextButtonText: "Got It"
        ),

        // Step 5: Player Actions
        TutorialStep(
            stepType: .playerActions,
            title: "Your Turn",
            bodyText: "Hit: Take another card\nStand: Keep your current hand\nDouble: Double your bet, take one card, then stand\nSplit: If you have a pair, split into two hands\n\nTry hitting or standing!",
            highlightedUIElement: .hitButton,
            requiredAction: .makePlayerAction,
            nextButtonText: "Continue"
        ),

        // Step 6: Dealer Play
        TutorialStep(
            stepType: .dealerPlay,
            title: "Dealer's Turn",
            bodyText: "The dealer reveals their hole card and plays by fixed rules: Hit on 16 or less, stand on 17 or more. You just watch - the dealer plays automatically!",
            highlightedUIElement: .dealerArea,
            requiredAction: .waitForDealerPlay,
            nextButtonText: "Continue"
        ),

        // Step 7: Results
        TutorialStep(
            stepType: .results,
            title: "Results & Payouts",
            bodyText: "Win: Your total beats the dealer (1:1 payout)\nBlackjack: Ace + 10-value card (3:2 payout)\nPush: Tie - bet returned\nLose: Dealer beats you or you bust\n\nYour bankroll updates automatically!",
            highlightedUIElement: .resultMessage,
            requiredAction: .viewResults,
            nextButtonText: "Continue"
        ),

        // Step 8: Statistics
        TutorialStep(
            stepType: .statistics,
            title: "Track Your Progress",
            bodyText: "Swipe up from the bottom to see detailed statistics including win rate, biggest wins, and dealer comparisons. All your sessions are saved!",
            highlightedUIElement: .statisticsSwipeIndicator,
            requiredAction: .exploreStatistics,
            nextButtonText: "Continue"
        ),

        // Step 9: Settings
        TutorialStep(
            stepType: .settings,
            title: "Customise Your Experience",
            bodyText: "Tap the gear icon to customise table colours, card designs, sound effects, and more. You can replay this tutorial anytime from settings!",
            highlightedUIElement: .settingsButton,
            requiredAction: .exploreSettings,
            nextButtonText: "Continue"
        ),

        // Step 10: Completion
        TutorialStep(
            stepType: .completion,
            title: "You're Ready!",
            bodyText: "You've mastered the basics! Now try different dealers, experiment with strategy, and build your bankroll. Remember: The house always has an edge, but with smart play you can minimise it!\n\nGood luck! 🎰",
            requiredAction: .finishTutorial,
            nextButtonText: "Start Playing"
        )
    ]

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔍 STEP LOOKUP HELPERS                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Get step by type
    static func step(for type: TutorialStepType) -> TutorialStep? {
        return allSteps.first { $0.stepType == type }
    }

    /// Get step index
    static func index(of step: TutorialStep) -> Int? {
        return allSteps.firstIndex { $0.id == step.id }
    }

    /// Total number of steps
    static var totalSteps: Int {
        return allSteps.count
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ Get all tutorial steps:                                                       ║
// ║   let steps = TutorialStep.allSteps                                           ║
// ║                                                                               ║
// ║ Get specific step:                                                            ║
// ║   if let welcomeStep = TutorialStep.step(for: .welcome) {                    ║
// ║       print(welcomeStep.title)                                                ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ Find step index:                                                              ║
// ║   if let index = TutorialStep.index(of: currentStep) {                       ║
// ║       let progress = Double(index + 1) / Double(TutorialStep.totalSteps)     ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ Check required action:                                                        ║
// ║   switch step.requiredAction {                                                ║
// ║   case .tapNext:                                                              ║
// ║       // Show Next button                                                     ║
// ║   case .placeBet:                                                             ║
// ║       // Wait for user to place bet                                           ║
// ║   default:                                                                    ║
// ║       break                                                                   ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
