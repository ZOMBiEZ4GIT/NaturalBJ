//
//  TutorialViewModel.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6: Tutorial & Help System
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ TutorialViewModel.swift                                                       ║
// ║                                                                               ║
// ║ View model for tutorial UI components (overlay, welcome screen).             ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Tutorial overlay needs reactive state for SwiftUI views                    ║
// ║ • Manages UI-specific logic (progress display, button states)                ║
// ║ • Coordinates with TutorialManager for business logic                        ║
// ║                                                                               ║
// ║ RESPONSIBILITIES:                                                             ║
// ║ • Provide computed properties for UI display                                 ║
// ║ • Handle user interactions (Next, Skip, Finish buttons)                      ║
// ║ • Format tutorial progress for presentation                                  ║
// ║ • Manage skip confirmation dialog state                                      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 🎓 TUTORIAL VIEW MODEL                                                    │
// │                                                                           │
// │ ObservableObject for tutorial UI state and interactions.                 │
// └──────────────────────────────────────────────────────────────────────────┘

class TutorialViewModel: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 DEPENDENCIES                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Tutorial manager (business logic)
    private let tutorialManager = TutorialManager.shared

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Should show skip confirmation dialog?
    @Published var showSkipConfirmation: Bool = false

    /// Is tutorial overlay animating in/out?
    @Published var isAnimating: Bool = false

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                        │
    // └──────────────────────────────────────────────────────────────────────┘

    init() {
        print("🎓 TutorialViewModel initialised")
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 📊 COMPUTED PROPERTIES - UI DISPLAY                                       ║
    // ║                                                                           ║
    // ║ These properties derive values from TutorialManager for UI presentation  ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    /// Current tutorial step (from manager)
    var currentStep: TutorialStep? {
        return tutorialManager.currentTutorialStep
    }

    /// Current step number (1-indexed for display)
    var stepNumber: Int {
        return tutorialManager.currentStepNumber
    }

    /// Total number of steps
    var totalSteps: Int {
        return tutorialManager.totalSteps
    }

    /// Progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        return tutorialManager.progressPercentage
    }

    /// Progress text for display (e.g., "Step 3 of 10")
    var progressText: String {
        guard tutorialManager.isTutorialActive else {
            return ""
        }
        return "Step \(stepNumber) of \(totalSteps)"
    }

    /// Can user advance to next step?
    var canAdvance: Bool {
        return tutorialManager.canAdvanceToNextStep()
    }

    /// Is this the last step?
    var isLastStep: Bool {
        return stepNumber >= totalSteps
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎬 USER ACTIONS                                                           ║
    // ║                                                                           ║
    // ║ Methods called by UI when user interacts with tutorial                   ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ▶️ START TUTORIAL                                                     │
    // │                                                                       │
    // │ Called from welcome screen when user taps "Start Tutorial".          │
    // └──────────────────────────────────────────────────────────────────────┘

    func startTutorial() {
        print("🎓 Starting tutorial from ViewModel")
        withAnimation {
            tutorialManager.startTutorial()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ➡️ NEXT STEP                                                          │
    // │                                                                       │
    // │ Advance to next tutorial step.                                       │
    // │ Called when user taps "Next" button.                                 │
    // └──────────────────────────────────────────────────────────────────────┘

    func nextStep() {
        guard canAdvance else {
            print("⚠️ Cannot advance - waiting for required action")
            return
        }

        print("➡️ Advancing to next step from ViewModel")
        withAnimation {
            tutorialManager.advanceToNextStep()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⬅️ PREVIOUS STEP (Not implemented - tutorial is forward-only)        │
    // │                                                                       │
    // │ Note: Tutorial flow is designed to be forward-only for simplicity.   │
    // │ Users can skip or restart, but not go back.                          │
    // └──────────────────────────────────────────────────────────────────────┘

    func previousStep() {
        // Tutorial is forward-only by design
        // If we ever implement backwards navigation, add logic here
        print("⚠️ Previous step not implemented - tutorial is forward-only")
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⏭️ SKIP TUTORIAL                                                      │
    // │                                                                       │
    // │ Show confirmation dialog before skipping.                            │
    // │ Called when user taps "Skip Tutorial" button.                        │
    // └──────────────────────────────────────────────────────────────────────┘

    func skipTutorial() {
        print("⏭️ Skip tutorial requested - showing confirmation")
        showSkipConfirmation = true
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ✅ CONFIRM SKIP                                                       │
    // │                                                                       │
    // │ User confirmed they want to skip tutorial.                           │
    // │ Called from skip confirmation dialog.                                │
    // └──────────────────────────────────────────────────────────────────────┘

    func confirmSkip() {
        print("✅ Skip confirmed - ending tutorial")
        showSkipConfirmation = false

        withAnimation {
            tutorialManager.skipTutorial()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ❌ CANCEL SKIP                                                        │
    // │                                                                       │
    // │ User cancelled skip - return to tutorial.                            │
    // └──────────────────────────────────────────────────────────────────────┘

    func cancelSkip() {
        print("❌ Skip cancelled - continuing tutorial")
        showSkipConfirmation = false
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏁 FINISH TUTORIAL                                                    │
    // │                                                                       │
    // │ Complete tutorial successfully.                                      │
    // │ Called when user completes final step.                               │
    // └──────────────────────────────────────────────────────────────────────┘

    func finishTutorial() {
        print("🏁 Tutorial finished from ViewModel")
        withAnimation {
            tutorialManager.notifyActionCompleted(.finishTutorial)
        }
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎬 TUTORIAL STEP VALIDATION                                               ║
    // ║                                                                           ║
    // ║ Methods to validate user has completed required actions                  ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ✅ HANDLE STEP ACTION                                                 │
    // │                                                                       │
    // │ Called when user performs an action that might satisfy step          │
    // │ requirement (e.g., places bet, selects dealer, etc.)                 │
    // │                                                                       │
    // │ This is called by GameViewModel or other components when actions     │
    // │ occur during tutorial mode.                                          │
    // └──────────────────────────────────────────────────────────────────────┘

    func handleStepAction(_ action: TutorialAction) {
        guard let currentStep = currentStep else { return }

        print("🎯 Action performed: \(action)")

        // Check if this action satisfies current step requirement
        if currentStep.requiredAction == action {
            print("✅ Step requirement satisfied - advancing")
            nextStep()
        }
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎨 UI HELPERS                                                             ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 GET BUTTON TEXT                                                    │
    // │                                                                       │
    // │ Returns appropriate text for Next button based on step state.        │
    // └──────────────────────────────────────────────────────────────────────┘

    var nextButtonText: String {
        guard let step = currentStep else {
            return "Next"
        }

        // Use custom button text from step, or default based on state
        if isLastStep {
            return step.nextButtonText == "Next" ? "Finish" : step.nextButtonText
        } else {
            return step.nextButtonText
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 SHOULD SHOW NEXT BUTTON?                                           │
    // │                                                                       │
    // │ Determine if Next button should be visible.                          │
    // │ Some steps auto-advance, others require user to tap Next.            │
    // └──────────────────────────────────────────────────────────────────────┘

    var shouldShowNextButton: Bool {
        guard let step = currentStep else {
            return false
        }

        // Show Next button for tap-to-advance steps
        switch step.requiredAction {
        case .tapNext:
            return true
        default:
            // Auto-advance steps don't show Next button
            return false
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 GET INSTRUCTION TEXT                                               │
    // │                                                                       │
    // │ Returns instruction text with dynamic values if needed.              │
    // └──────────────────────────────────────────────────────────────────────┘

    var instructionText: String {
        guard let step = currentStep else {
            return ""
        }

        return step.bodyText
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In TutorialOverlayView:                                                       ║
// ║   @StateObject var viewModel = TutorialViewModel()                            ║
// ║                                                                               ║
// ║   var body: some View {                                                       ║
// ║       VStack {                                                                 ║
// ║           Text(viewModel.progressText)                                        ║
// ║           Text(viewModel.instructionText)                                     ║
// ║                                                                               ║
// ║           if viewModel.shouldShowNextButton {                                 ║
// ║               Button(viewModel.nextButtonText) {                              ║
// ║                   viewModel.nextStep()                                        ║
// ║               }                                                                ║
// ║               .disabled(!viewModel.canAdvance)                                ║
// ║           }                                                                    ║
// ║                                                                               ║
// ║           Button("Skip Tutorial") {                                           ║
// ║               viewModel.skipTutorial()                                        ║
// ║           }                                                                    ║
// ║       }                                                                        ║
// ║       .alert("Skip Tutorial?",                                                ║
// ║              isPresented: $viewModel.showSkipConfirmation) {                  ║
// ║           Button("Yes, Skip") {                                               ║
// ║               viewModel.confirmSkip()                                         ║
// ║           }                                                                    ║
// ║           Button("Continue Tutorial") {                                       ║
// ║               viewModel.cancelSkip()                                          ║
// ║           }                                                                    ║
// ║       }                                                                        ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ Progress bar:                                                                 ║
// ║   ProgressView(value: viewModel.progressPercentage)                           ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
