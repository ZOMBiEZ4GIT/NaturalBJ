//
//  TutorialManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6: Tutorial & Help System
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ TutorialManager.swift                                                         ║
// ║                                                                               ║
// ║ Central coordinator for the interactive tutorial system.                     ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • New users need guided onboarding to understand blackjack rules             ║
// ║ • Tutorial reduces friction and improves retention                           ║
// ║ • Contextual hints help users discover advanced features                     ║
// ║ • Must integrate seamlessly with existing game flow                          ║
// ║                                                                               ║
// ║ DESIGN PATTERN:                                                               ║
// ║ • Singleton for global access from any view/viewmodel                        ║
// ║ • Observable for SwiftUI reactivity                                          ║
// ║ • Publishes state changes to update UI automatically                         ║
// ║                                                                               ║
// ║ INTEGRATION POINTS:                                                           ║
// ║ • GameViewModel: Monitors game actions to validate tutorial steps           ║
// ║ • GameView: Displays tutorial overlay and highlights UI elements            ║
// ║ • SettingsView: Allows replay and configuration of tutorial                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import Combine
import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 🎓 TUTORIAL MANAGER                                                       │
// │                                                                           │
// │ Singleton service managing tutorial state and flow.                      │
// │ Observable for SwiftUI views to react to state changes.                  │
// └──────────────────────────────────────────────────────────────────────────┘

class TutorialManager: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏢 SINGLETON INSTANCE                                                 │
    // └──────────────────────────────────────────────────────────────────────┘

    static let shared = TutorialManager()

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                                    │
    // │                                                                       │
    // │ These properties trigger UI updates when changed                     │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Current tutorial step (nil if tutorial not active)
    @Published private(set) var currentTutorialStep: TutorialStep?

    /// Is tutorial currently active?
    @Published private(set) var isTutorialActive: Bool = false

    /// Tutorial progress tracker
    @Published private(set) var tutorialProgress: TutorialProgress

    /// Should show welcome screen? (first-time users)
    @Published private(set) var shouldShowWelcome: Bool = false

    /// Current contextual hint to display (if any)
    @Published private(set) var currentHint: ContextualHint?

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Hints that have been dismissed (to avoid showing repeatedly)
    private var dismissedHints: Set<HintType> = []

    /// Last time a hint was shown (rate limiting)
    private var lastHintTime: Date?

    /// Minimum time between hints (seconds)
    private let hintCooldown: TimeInterval = 10.0

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                        │
    // └──────────────────────────────────────────────────────────────────────┘

    private init() {
        // Load saved progress
        self.tutorialProgress = TutorialProgress.load()

        // Check if we should auto-start tutorial
        if tutorialProgress.shouldAutoStartTutorial {
            self.shouldShowWelcome = true
            print("👋 First-time user detected - showing welcome screen")
        }

        // Load current step if tutorial is in progress
        if let stepType = tutorialProgress.currentStepType {
            self.currentTutorialStep = TutorialStep.step(for: stepType)
            self.isTutorialActive = true
            print("📖 Resuming tutorial at step: \(stepType.displayName)")
        }

        print("🎓 TutorialManager initialised")
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎬 TUTORIAL FLOW CONTROL                                                  ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ▶️ START TUTORIAL                                                     │
    // │                                                                       │
    // │ Begin tutorial from first step.                                      │
    // │ Called from welcome screen or settings "Replay Tutorial".            │
    // └──────────────────────────────────────────────────────────────────────┘

    func startTutorial() {
        print("🎓 Starting tutorial")

        // Update progress
        tutorialProgress.startTutorial()
        tutorialProgress.save()

        // Load first step
        if let firstStep = TutorialStep.allSteps.first {
            currentTutorialStep = firstStep
            isTutorialActive = true
            shouldShowWelcome = false

            print("▶️ Tutorial started with step: \(firstStep.stepType.displayName)")
        } else {
            print("❌ No tutorial steps available!")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⏭️ ADVANCE TO NEXT STEP                                               │
    // │                                                                       │
    // │ Move to next step in tutorial sequence.                              │
    // │ Called when user completes required action or taps Next.             │
    // └──────────────────────────────────────────────────────────────────────┘

    func advanceToNextStep() {
        guard let currentStep = currentTutorialStep else {
            print("⚠️ Cannot advance - no active tutorial step")
            return
        }

        print("➡️ Advancing from step: \(currentStep.stepType.displayName)")

        // Update progress
        tutorialProgress.advanceToNextStep()
        tutorialProgress.save()

        // Check if tutorial is complete
        if tutorialProgress.hasCompletedTutorial {
            print("🎉 Tutorial complete!")
            completeTutorial()
            return
        }

        // Load next step
        if let nextStepType = tutorialProgress.currentStepType,
           let nextStep = TutorialStep.step(for: nextStepType) {
            currentTutorialStep = nextStep
            print("▶️ Advanced to step: \(nextStep.stepType.displayName)")
        } else {
            // Shouldn't happen, but handle gracefully
            print("⚠️ No next step found - completing tutorial")
            completeTutorial()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⏭️ SKIP TUTORIAL                                                      │
    // │                                                                       │
    // │ Allow user to skip tutorial entirely.                                │
    // │ Marks tutorial as complete and returns to normal gameplay.           │
    // └──────────────────────────────────────────────────────────────────────┘

    func skipTutorial() {
        print("⏭️ User skipped tutorial")

        tutorialProgress.skipTutorial()
        tutorialProgress.save()

        currentTutorialStep = nil
        isTutorialActive = false
        shouldShowWelcome = false
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏁 COMPLETE TUTORIAL                                                  │
    // │                                                                       │
    // │ Finish tutorial successfully.                                        │
    // │ Internal method called when last step is completed.                  │
    // └──────────────────────────────────────────────────────────────────────┘

    private func completeTutorial() {
        print("🎉 Tutorial completed!")

        tutorialProgress.completeTutorial()
        tutorialProgress.save()

        currentTutorialStep = nil
        isTutorialActive = false
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔄 RESET TUTORIAL                                                     │
    // │                                                                       │
    // │ Reset progress for replay.                                           │
    // │ Called from settings "Replay Tutorial" option.                       │
    // └──────────────────────────────────────────────────────────────────────┘

    func resetTutorial() {
        print("🔄 Resetting tutorial for replay")

        tutorialProgress.resetTutorial()
        tutorialProgress.save()

        currentTutorialStep = nil
        isTutorialActive = false
        shouldShowWelcome = true
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ ✅ ACTION VALIDATION                                                      ║
    // ║                                                                           ║
    // ║ Methods called by GameViewModel to validate tutorial step completion     ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ✅ NOTIFY ACTION COMPLETED                                            │
    // │                                                                       │
    // │ Called by GameViewModel when user performs an action.                │
    // │ Validates if action satisfies current tutorial step requirement.     │
    // └──────────────────────────────────────────────────────────────────────┘

    func notifyActionCompleted(_ action: TutorialAction) {
        guard isTutorialActive,
              let currentStep = currentTutorialStep else {
            return
        }

        print("🎯 Action completed: \(action)")

        // Check if this action satisfies the current step
        if currentStep.requiredAction == action {
            print("✅ Tutorial step requirement satisfied")
            advanceToNextStep()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ✅ CAN ADVANCE TO NEXT STEP?                                          │
    // │                                                                       │
    // │ Check if conditions are met to advance tutorial.                     │
    // │ Used by TutorialOverlayView to enable/disable Next button.           │
    // └──────────────────────────────────────────────────────────────────────┘

    func canAdvanceToNextStep() -> Bool {
        guard let currentStep = currentTutorialStep else {
            return false
        }

        // Some steps auto-advance, others require user to tap Next
        switch currentStep.requiredAction {
        case .tapNext:
            return true
        default:
            // Action must be completed to advance
            return false
        }
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 💡 CONTEXTUAL HINTS                                                       ║
    // ║                                                                           ║
    // ║ Show helpful tips during regular gameplay (post-tutorial)                ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 💡 SHOULD SHOW HINT?                                                  │
    // │                                                                       │
    // │ Determine if a contextual hint should appear based on game state.    │
    // │ Called by GameViewModel during gameplay.                             │
    // └──────────────────────────────────────────────────────────────────────┘

    func shouldShowHint(for hintType: HintType) -> Bool {
        // Don't show hints if disabled
        guard tutorialProgress.showContextualHints else {
            return false
        }

        // Don't show during active tutorial
        guard !isTutorialActive else {
            return false
        }

        // Don't show if hint was already dismissed
        guard !dismissedHints.contains(hintType) else {
            return false
        }

        // Rate limiting - don't show hints too frequently
        if let lastHint = lastHintTime,
           Date().timeIntervalSince(lastHint) < hintCooldown {
            return false
        }

        return true
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 💡 SHOW HINT                                                          │
    // │                                                                       │
    // │ Display a contextual hint to the user.                               │
    // └──────────────────────────────────────────────────────────────────────┘

    func showHint(_ hint: ContextualHint) {
        currentHint = hint
        lastHintTime = Date()
        print("💡 Showing hint: \(hint.hintType.rawValue)")
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 💡 DISMISS HINT                                                       │
    // │                                                                       │
    // │ User acknowledged hint - don't show again.                           │
    // └──────────────────────────────────────────────────────────────────────┘

    func dismissHint() {
        if let hint = currentHint {
            dismissedHints.insert(hint.hintType)
            print("✓ Hint dismissed: \(hint.hintType.rawValue)")
        }
        currentHint = nil
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ ⚙️ SETTINGS                                                                ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⚙️ TOGGLE TUTORIAL HINTS                                              │
    // └──────────────────────────────────────────────────────────────────────┘

    func setTutorialHintsEnabled(_ enabled: Bool) {
        tutorialProgress.setTutorialHintsEnabled(enabled)
        tutorialProgress.save()
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⚙️ TOGGLE CONTEXTUAL HINTS                                            │
    // └──────────────────────────────────────────────────────────────────────┘

    func setContextualHintsEnabled(_ enabled: Bool) {
        tutorialProgress.setContextualHintsEnabled(enabled)
        tutorialProgress.save()

        if !enabled {
            // Clear current hint
            currentHint = nil
        }
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 📊 PROGRESS INFO                                                          ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    /// Get current step number (1-indexed)
    var currentStepNumber: Int {
        guard let currentStep = currentTutorialStep,
              let index = TutorialStep.index(of: currentStep) else {
            return 0
        }
        return index + 1
    }

    /// Total number of tutorial steps
    var totalSteps: Int {
        return TutorialStep.totalSteps
    }

    /// Progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStepNumber) / Double(totalSteps)
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 💡 CONTEXTUAL HINT                                                            ║
// ║                                                                               ║
// ║ Represents a helpful tip shown during regular gameplay                       ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

struct ContextualHint: Identifiable {
    let id = UUID()
    let hintType: HintType
    let message: String
    let targetElement: UIElementIdentifier?

    init(hintType: HintType, message: String, targetElement: UIElementIdentifier? = nil) {
        self.hintType = hintType
        self.message = message
        self.targetElement = targetElement
    }
}

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 💡 HINT TYPE                                                              │
// │                                                                           │
// │ Types of contextual hints that can be shown.                             │
// └──────────────────────────────────────────────────────────────────────────┘

enum HintType: String {
    case doubleOnEleven = "double_on_eleven"
    case splitAces = "split_aces"
    case splitEights = "split_eights"
    case standOn17 = "stand_on_17"
    case dealerBustProbability = "dealer_bust_probability"
    case checkStatistics = "check_statistics"
    case tryDifferentDealer = "try_different_dealer"
    case bankrollManagement = "bankroll_management"
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In GameViewModel:                                                             ║
// ║   let tutorialManager = TutorialManager.shared                                ║
// ║                                                                               ║
// ║   // Check if tutorial is active                                              ║
// ║   if tutorialManager.isTutorialActive {                                       ║
// ║       // Modify game flow for tutorial                                        ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║   // Notify action completed                                                  ║
// ║   func placeBet(_ amount: Double) {                                           ║
// ║       // ... place bet logic ...                                              ║
// ║       tutorialManager.notifyActionCompleted(.placeBet)                        ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║   // Show contextual hint                                                     ║
// ║   if hand.total == 11 && tutorialManager.shouldShowHint(for: .doubleOnEleven) {║
// ║       let hint = ContextualHint(                                              ║
// ║           hintType: .doubleOnEleven,                                          ║
// ║           message: "You have 11! Consider doubling down.",                    ║
// ║           targetElement: .doubleButton                                        ║
// ║       )                                                                        ║
// ║       tutorialManager.showHint(hint)                                          ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ In TutorialOverlayView:                                                       ║
// ║   @StateObject var tutorialManager = TutorialManager.shared                   ║
// ║                                                                               ║
// ║   var body: some View {                                                       ║
// ║       if let step = tutorialManager.currentTutorialStep {                    ║
// ║           // Show tutorial overlay                                            ║
// ║       }                                                                        ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ In SettingsView:                                                              ║
// ║   Button("Replay Tutorial") {                                                 ║
// ║       tutorialManager.resetTutorial()                                         ║
// ║       tutorialManager.startTutorial()                                         ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
