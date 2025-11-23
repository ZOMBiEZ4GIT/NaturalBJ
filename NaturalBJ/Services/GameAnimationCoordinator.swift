// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ GameAnimationCoordinator.swift                                                ║
// ║                                                                               ║
// ║ Orchestrates all animations for complete game flow sequences.               ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Coordinated animations create professional, polished game flow             ║
// ║ • Proper sequencing prevents visual chaos and confusion                      ║
// ║ • Audio + haptics + visuals must synchronise perfectly                       ║
// ║ • Animations tell the story of each game action                              ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Singleton pattern for global coordination                                  ║
// ║ • Async/await for sequential animation flows                                 ║
// ║ • Completion handlers for game state transitions                             ║
// ║ • Coordinates: CardAnimationManager, ChipAnimationManager, TransitionManager ║
// ║ • Triggers: AudioManager, HapticManager for multi-sensory feedback           ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ GameAnimationCoordinator                                                      │
// │                                                                               │
// │ Orchestrates all game animations in proper sequence.                        │
// └──────────────────────────────────────────────────────────────────────────────┘
@MainActor
class GameAnimationCoordinator: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ MANAGERS                                                                  │
    // └──────────────────────────────────────────────────────────────────────────┘

    private let cardAnimationManager = CardAnimationManager.shared
    private let chipAnimationManager = ChipAnimationManager.shared
    private let transitionManager = TransitionManager.shared
    private let audioManager = AudioManager.shared
    private let hapticManager = HapticManager.shared
    private let visualSettings = VisualSettingsManager.shared

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUBLISHED STATE                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether animation sequence is in progress
    @Published private(set) var isAnimating: Bool = false

    /// Current animation stage (for debugging)
    @Published private(set) var currentStage: String = ""

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEAL SEQUENCE                                                             │
    // │                                                                            │
    // │ Coordinate initial deal: player, dealer, player, dealer (hole card)      │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Animate initial deal sequence
    /// - Parameter completion: Called when deal completes
    func animateDeal(completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Dealing"

        Task {
            // Get deal sequence from card animation manager
            let dealSequence = cardAnimationManager.initialDealSequence()

            // Play shuffle sound if needed
            audioManager.playSoundEffect(.cardShuffle)

            // Animate each card in sequence
            for (index, task) in dealSequence.enumerated() {
                // Wait for delay
                try? await Task.sleep(nanoseconds: UInt64(task.delay * 1_000_000_000))

                // Play card deal sound
                audioManager.playCardDeal()

                // Play card deal haptic
                hapticManager.playCardDeal()

                // Card appears (actual visual handled by view)
                print("📇 Dealt card \(index + 1) to \(task.position)")
            }

            // Wait for final card animation to complete
            let finalDelay = visualSettings.settings.cardDealDuration
            try? await Task.sleep(nanoseconds: UInt64(finalDelay * 1_000_000_000))

            // Complete
            isAnimating = false
            completion()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PLAYER ACTION ANIMATIONS                                                  │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Animate player hit action
    /// - Parameters:
    ///   - cardID: ID of new card
    ///   - completion: Called when animation completes
    func animateHit(cardID: UUID, completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Hit"

        // Play sound and haptic
        audioManager.playCardDeal()
        hapticManager.playHit()

        // Animate card
        withAnimation(cardAnimationManager.standardDealAnimation(cardID: cardID)) {
            // Card appears (handled by view)
        }

        // Complete after animation duration
        let duration = visualSettings.settings.cardDealDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isAnimating = false
            completion()
        }
    }

    /// Animate player stand action
    /// - Parameter completion: Called when animation completes
    func animateStand(completion: @escaping () -> Void) {
        currentStage = "Stand"

        // Play sound and haptic
        audioManager.playSoundEffect(.confirm)
        hapticManager.playStand()

        // Immediate completion (no visual animation for stand)
        completion()
    }

    /// Animate double down action
    /// - Parameters:
    ///   - cardID: ID of new card
    ///   - completion: Called when animation completes
    func animateDoubleDown(cardID: UUID, completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Double Down"

        // Play sounds and haptics
        audioManager.playSoundEffect(.chipClink)
        audioManager.playCardDeal()
        hapticManager.playDoubleDown()

        // Animate bet increase and card deal
        withAnimation(chipAnimationManager.placeBetAnimation(amount: 0)) {
            // Bet doubles (handled by view)
        }

        // Then deal card
        let chipDuration = visualSettings.settings.chipPlaceDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + chipDuration) {
            withAnimation(self.cardAnimationManager.standardDealAnimation(cardID: cardID)) {
                // Card appears
            }
        }

        // Complete
        let totalDuration = chipDuration + visualSettings.settings.cardDealDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            self.isAnimating = false
            completion()
        }
    }

    /// Animate split action
    /// - Parameter completion: Called when animation completes
    func animateSplit(completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Split"

        // Play sounds and haptics
        audioManager.playSoundEffect(.chipClink)
        hapticManager.playSplit()

        // Animate hands separating
        withAnimation(transitionManager.splitHandAnimation()) {
            // Hands separate (handled by view)
        }

        // Complete
        let duration = visualSettings.settings.stateTransitionDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isAnimating = false
            completion()
        }
    }

    /// Animate surrender action
    /// - Parameter completion: Called when animation completes
    func animateSurrender(completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Surrender"

        // Play sound and haptic
        audioManager.playSoundEffect(.warning)
        hapticManager.playHaptic(.surrender)

        // Animate chip collection (half bet returned)
        withAnimation(chipAnimationManager.pushAnimation()) {
            // Chips returned
        }

        // Complete
        let duration = visualSettings.settings.chipMoveDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isAnimating = false
            completion()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEALER TURN ANIMATION                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Animate dealer turn
    /// - Parameters:
    ///   - dealerCardIDs: IDs of cards dealer draws
    ///   - completion: Called when animation completes
    func animateDealerTurn(dealerCardIDs: [UUID], completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Dealer Turn"

        Task {
            // First, flip hole card
            audioManager.playCardFlip()
            hapticManager.playCardFlip()

            withAnimation(cardAnimationManager.flipCardAnimation()) {
                // Hole card flips (handled by view)
            }

            // Wait for flip to complete
            try? await Task.sleep(nanoseconds: UInt64(visualSettings.settings.cardFlipDuration * 1_000_000_000))

            // Then deal additional cards if any
            for (index, cardID) in dealerCardIDs.enumerated() {
                // Delay between cards
                if index > 0 {
                    let delay = visualSettings.settings.cardDealDelay
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }

                // Deal card
                audioManager.playCardDeal()
                hapticManager.playCardDeal()

                withAnimation(cardAnimationManager.standardDealAnimation(cardID: cardID)) {
                    // Card appears
                }

                // Wait for card animation
                try? await Task.sleep(nanoseconds: UInt64(visualSettings.settings.cardDealDuration * 1_000_000_000))
            }

            // Complete
            isAnimating = false
            completion()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ RESULT ANIMATIONS                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Animate win result
    /// - Parameters:
    ///   - payout: Payout amount
    ///   - completion: Called when animation completes
    func animateWin(payout: Double, completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Win"

        // Play sound and haptic
        audioManager.playWin()
        hapticManager.playWin()

        // Animate chips to player
        withAnimation(chipAnimationManager.winAnimation(payout: payout)) {
            // Chips move to player
        }

        // Show result message
        withAnimation(transitionManager.showWinResultAnimation()) {
            // Result appears (handled by view)
        }

        // Complete
        let duration = visualSettings.settings.chipMoveDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isAnimating = false
            completion()
        }
    }

    /// Animate loss result
    /// - Parameter completion: Called when animation completes
    func animateLoss(completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Loss"

        // Play sound and haptic
        audioManager.playLoss()
        hapticManager.playLoss()

        // Animate chips to dealer
        withAnimation(chipAnimationManager.lossAnimation()) {
            // Chips move to dealer
        }

        // Show result message
        withAnimation(transitionManager.showLossResultAnimation()) {
            // Result appears
        }

        // Complete
        let duration = visualSettings.settings.chipMoveDuration * 0.8
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isAnimating = false
            completion()
        }
    }

    /// Animate blackjack result (special!)
    /// - Parameters:
    ///   - payout: Blackjack payout (3:2)
    ///   - completion: Called when animation completes
    func animateBlackjack(payout: Double, completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Blackjack"

        // Play special sound and haptic pattern
        audioManager.playBlackjack()
        hapticManager.playTriplePulse() // Special triple pulse!

        // Animate chips with special blackjack animation
        withAnimation(chipAnimationManager.blackjackPayoutAnimation(payout: payout)) {
            // Chips move to player
        }

        // Show blackjack result
        withAnimation(transitionManager.showBlackjackResultAnimation()) {
            // Result appears with glow
        }

        // Complete
        let duration = visualSettings.settings.chipMoveDuration * 1.2 // Slightly longer for celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isAnimating = false
            completion()
        }
    }

    /// Animate push result
    /// - Parameter completion: Called when animation completes
    func animatePush(completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Push"

        // Play sound and haptic
        audioManager.playSoundEffect(.push)
        hapticManager.playHaptic(.push)

        // Animate chips returning (pulse)
        withAnimation(chipAnimationManager.pushAnimation()) {
            // Chips pulse
        }

        // Show result message
        withAnimation(transitionManager.showPushResultAnimation()) {
            // Result appears
        }

        // Complete
        let duration = visualSettings.settings.stateTransitionDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isAnimating = false
            completion()
        }
    }

    /// Animate bust result
    /// - Parameter completion: Called when animation completes
    func animateBust(completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Bust"

        // Play sound and haptic
        audioManager.playSoundEffect(.bust)
        hapticManager.playBust()

        // Animate chips to dealer
        withAnimation(chipAnimationManager.lossAnimation()) {
            // Chips move to dealer
        }

        // Show bust message
        withAnimation(transitionManager.showLossResultAnimation()) {
            // Result appears
        }

        // Complete
        let duration = visualSettings.settings.chipMoveDuration * 0.8
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isAnimating = false
            completion()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ NEXT HAND PREPARATION                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Animate transition to next hand
    /// - Parameter completion: Called when animation completes
    func animateNextHand(completion: @escaping () -> Void) {
        isAnimating = true
        currentStage = "Next Hand"

        Task {
            // Collect cards
            withAnimation(transitionManager.transitionToBettingAnimation()) {
                // Cards collect (handled by view)
            }

            // Wait for collection
            try? await Task.sleep(nanoseconds: UInt64(visualSettings.settings.cardCollectDuration * 1_000_000_000))

            // Clear table
            // (Reset handled by game logic)

            // Complete
            isAnimating = false
            completion()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BETTING ANIMATIONS                                                        │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Animate bet placement
    /// - Parameters:
    ///   - amount: Bet amount
    ///   - completion: Called when animation completes
    func animatePlaceBet(amount: Double, completion: @escaping () -> Void) {
        // Play sound and haptic
        audioManager.playChipClink()
        hapticManager.playBetPlaced()

        // Animate chips
        withAnimation(chipAnimationManager.placeBetAnimation(amount: amount)) {
            // Chips appear
        }

        // Animate bet amount count-up
        chipAnimationManager.animateBetAmount(from: 0, to: amount)

        // Complete
        let duration = visualSettings.settings.chipPlaceDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }

    /// Animate bet adjustment (increase/decrease)
    /// - Parameters:
    ///   - from: Old amount
    ///   - to: New amount
    func animateBetAdjustment(from oldAmount: Double, to newAmount: Double) {
        // Play button tap sound
        audioManager.playButtonTap()
        hapticManager.playHaptic(.betAdjust)

        // Animate bet amount change
        chipAnimationManager.animateBetAmount(from: oldAmount, to: newAmount)
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEALER SELECTION ANIMATION                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Animate dealer change
    /// - Parameter completion: Called when animation completes
    func animateDealerChange(completion: @escaping () -> Void) {
        // Play sound and haptic
        audioManager.playSoundEffect(.dealerSelect)
        hapticManager.playHaptic(.dealerSelect)

        // Animate transition
        withAnimation(transitionManager.changeDealerAnimation()) {
            // Dealer changes (handled by view)
        }

        // Complete
        let duration = visualSettings.settings.stateTransitionDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ UTILITY METHODS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Cancel all ongoing animations
    func cancelAll() {
        isAnimating = false
        currentStage = ""
        cardAnimationManager.clearQueue()
        chipAnimationManager.reset()
    }

    /// Reset coordinator
    func reset() {
        cancelAll()
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ BUTTON FEEDBACK                                                               │
// │                                                                               │
// │ Quick feedback for UI interactions.                                         │
// └──────────────────────────────────────────────────────────────────────────────┘
extension GameAnimationCoordinator {

    /// Provide button tap feedback
    func buttonTapFeedback() {
        audioManager.playButtonTap()
        hapticManager.playButtonTap()
    }

    /// Provide button press animation
    func buttonPressAnimation() -> Animation {
        transitionManager.buttonPressAnimation()
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ DEBUGGING                                                                     │
// └──────────────────────────────────────────────────────────────────────────────┘
extension GameAnimationCoordinator {

    /// Print current state
    func printState() {
        print("🎬 Animation Coordinator State:")
        print("   Is Animating: \(isAnimating)")
        print("   Current Stage: \(currentStage)")
        print("   Card Animations: \(cardAnimationManager.hasActiveAnimations)")
        print("   Chip Animations: \(chipAnimationManager.isAnimating)")
        print("   Transitions: \(transitionManager.isTransitioning)")
    }
}
