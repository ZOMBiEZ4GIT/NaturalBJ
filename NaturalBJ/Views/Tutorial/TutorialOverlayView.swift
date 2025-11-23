//
//  TutorialOverlayView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6.5: Tutorial & Help System - View Layer
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ TutorialOverlayView.swift                                                     ║
// ║                                                                               ║
// ║ Interactive tutorial overlay that appears over gameplay.                     ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Guides users through first complete blackjack hand                         ║
// ║ • Highlights relevant UI elements for each step                              ║
// ║ • Non-blocking: user can skip at any time                                    ║
// ║ • Progressive disclosure: one concept at a time                              ║
// ║                                                                               ║
// ║ UX PRINCIPLES:                                                                ║
// ║ • Spotlight effect: dim everything except target element                     ║
// ║ • Speech bubble: clear, concise instructions                                 ║
// ║ • Progress indicator: "Step 3 of 10"                                          ║
// ║ • Always visible: Skip button for user control                               ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 🎓 TUTORIAL OVERLAY VIEW                                                  │
// │                                                                           │
// │ Full-screen overlay with dimmed background and instruction bubble.       │
// └──────────────────────────────────────────────────────────────────────────┘

struct TutorialOverlayView: View {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 DEPENDENCIES                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    @StateObject private var viewModel = TutorialViewModel()
    @ObservedObject private var tutorialManager = TutorialManager.shared

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 ANIMATION STATE                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    @State private var showContent = false

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                               │
    // └──────────────────────────────────────────────────────────────────────┘

    var body: some View {
        ZStack {
            // Only show if tutorial is active
            if tutorialManager.isTutorialActive, let currentStep = viewModel.currentStep {
                // Semi-transparent dimming layer
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack {
                    Spacer()

                    // Instruction bubble
                    instructionBubble(for: currentStep)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: tutorialManager.isTutorialActive)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                showContent = true
            }
        }
        .alert("Skip Tutorial?", isPresented: $viewModel.showSkipConfirmation) {
            Button("Continue Tutorial", role: .cancel) {
                viewModel.cancelSkip()
            }
            Button("Yes, Skip", role: .destructive) {
                viewModel.confirmSkip()
            }
        } message: {
            Text("You can replay the tutorial anytime from Settings.")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 💬 INSTRUCTION BUBBLE                                                 │
    // │                                                                       │
    // │ Card-style bubble containing tutorial instructions.                  │
    // └──────────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private func instructionBubble(for step: TutorialStep) -> some View {
        VStack(spacing: 20) {
            // Progress indicator
            progressIndicator

            // Step content
            VStack(spacing: 16) {
                // Title
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Body text
                Text(step.bodyText)
                    .font(.body)
                    .foregroundColor(.mediumGrey)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)

            // Action buttons
            actionButtons
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.darkGrey)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📊 PROGRESS INDICATOR                                                 │
    // └──────────────────────────────────────────────────────────────────────┘

    private var progressIndicator: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appBackground)
                        .frame(height: 8)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.chipGradient)
                        .frame(
                            width: geometry.size.width * viewModel.progressPercentage,
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            // Step counter
            Text(viewModel.progressText)
                .font(.caption)
                .foregroundColor(.mediumGrey)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎯 ACTION BUTTONS                                                     │
    // └──────────────────────────────────────────────────────────────────────┘

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Next/Continue button (when available)
            if viewModel.shouldShowNextButton {
                Button(action: {
                    viewModel.nextStep()
                }) {
                    Text(viewModel.nextButtonText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            viewModel.canAdvance ? Color.success : Color.darkGrey.opacity(0.5)
                        )
                        .cornerRadius(12)
                }
                .disabled(!viewModel.canAdvance)
            }

            // Skip button (always available)
            Button(action: {
                viewModel.skipTutorial()
            }) {
                Text("Skip Tutorial")
                    .font(.subheadline)
                    .foregroundColor(.mediumGrey)
            }
            .padding(.top, 4)
        }
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 🎨 SPOTLIGHT MODIFIER (For highlighting UI elements)                         ║
// ║                                                                               ║
// ║ Custom ViewModifier to add accessibility identifier for tutorial spotlights  ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

extension View {
    /// Mark view as tutorial spotlight target
    func tutorialSpotlight(_ identifier: UIElementIdentifier) -> some View {
        self.accessibilityIdentifier(identifier.rawValue)
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

#Preview("Tutorial Overlay") {
    ZStack {
        // Mock game view background
        Color.appBackground
            .ignoresSafeArea()

        // Tutorial overlay
        TutorialOverlayView()
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In GameView:                                                                  ║
// ║   var body: some View {                                                       ║
// ║       ZStack {                                                                 ║
// ║           // Game UI                                                           ║
// ║           gameContent                                                          ║
// ║                                                                               ║
// ║           // Tutorial overlay                                                 ║
// ║           if TutorialManager.shared.isTutorialActive {                        ║
// ║               TutorialOverlayView()                                           ║
// ║           }                                                                    ║
// ║       }                                                                        ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ Adding spotlight identifiers to UI elements:                                  ║
// ║   Button("Hit") {                                                             ║
// ║       viewModel.hit()                                                         ║
// ║   }                                                                            ║
// ║   .tutorialSpotlight(.hitButton)                                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
