//
//  ContextualHintView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6.5: Tutorial & Help System - View Layer
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ ContextualHintView.swift                                                      ║
// ║                                                                               ║
// ║ Small floating hint bubbles shown during gameplay.                           ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Help users discover optimal strategy                                       ║
// ║ • Shown post-tutorial to experienced users                                   ║
// ║ • Non-intrusive: auto-dismiss after 5 seconds                                ║
// ║ • User-controlled: can disable in settings                                   ║
// ║                                                                               ║
// ║ UX PRINCIPLES:                                                                ║
// ║ • Minimal: Short, actionable tip                                             ║
// ║ • Dismissible: Tap anywhere or wait for auto-dismiss                         ║
// ║ • Positioned: Near relevant UI element                                       ║
// ║ • Rate-limited: Don't spam hints                                             ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 💡 CONTEXTUAL HINT VIEW                                                   │
// │                                                                           │
// │ Floating hint bubble with arrow pointer.                                 │
// └──────────────────────────────────────────────────────────────────────────┘

struct ContextualHintView: View {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 PROPERTIES                                                         │
    // └──────────────────────────────────────────────────────────────────────┘

    let hint: ContextualHint
    let onDismiss: () -> Void

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 ANIMATION STATE                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    @State private var showHint = false
    @State private var dismissTimer: Timer?

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                               │
    // └──────────────────────────────────────────────────────────────────────┘

    var body: some View {
        VStack {
            Spacer()

            // Hint bubble
            hintBubble
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // Position above action buttons
                .opacity(showHint ? 1 : 0)
                .offset(y: showHint ? 0 : 20)
                .scaleEffect(showHint ? 1 : 0.9)
        }
        .onAppear {
            // Animate in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showHint = true
            }

            // Auto-dismiss after 5 seconds
            dismissTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                dismissHint()
            }
        }
        .onDisappear {
            dismissTimer?.invalidate()
        }
        .onTapGesture {
            dismissHint()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 💬 HINT BUBBLE                                                        │
    // └──────────────────────────────────────────────────────────────────────┘

    private var hintBubble: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundColor(.warning)

            // Message
            Text(hint.message)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            // Dismiss button
            Button(action: {
                dismissHint()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.mediumGrey)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.darkGrey)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎯 DISMISS HINT                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    private func dismissHint() {
        dismissTimer?.invalidate()
        withAnimation(.easeOut(duration: 0.2)) {
            showHint = false
        }
        // Delay actual dismissal to allow animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

#Preview("Contextual Hint") {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()

        ContextualHintView(
            hint: ContextualHint(
                hintType: .doubleOnEleven,
                message: "You have 11! Consider doubling down for maximum profit.",
                targetElement: .doubleButton
            ),
            onDismiss: {}
        )
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In GameView:                                                                  ║
// ║   @ObservedObject var tutorialManager = TutorialManager.shared                ║
// ║                                                                               ║
// ║   var body: some View {                                                       ║
// ║       ZStack {                                                                 ║
// ║           // Game UI                                                           ║
// ║           gameContent                                                          ║
// ║                                                                               ║
// ║           // Contextual hint                                                  ║
// ║           if let hint = tutorialManager.currentHint {                         ║
// ║               ContextualHintView(hint: hint) {                                ║
// ║                   tutorialManager.dismissHint()                               ║
// ║               }                                                                ║
// ║           }                                                                    ║
// ║       }                                                                        ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ In GameViewModel (triggering hints):                                          ║
// ║   func hit() {                                                                ║
// ║       // ... game logic ...                                                   ║
// ║                                                                               ║
// ║       // Check for hint opportunity                                           ║
// ║       if currentHand.total == 11 &&                                           ║
// ║          tutorialManager.shouldShowHint(for: .doubleOnEleven) {               ║
// ║           let hint = ContextualHint(                                          ║
// ║               hintType: .doubleOnEleven,                                      ║
// ║               message: "You have 11! Consider doubling down.",                ║
// ║               targetElement: .doubleButton                                    ║
// ║           )                                                                    ║
// ║           tutorialManager.showHint(hint)                                      ║
// ║       }                                                                        ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
