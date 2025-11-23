//
//  GameViewModel.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 2: Core Gameplay
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎮 GAME VIEW MODEL - The Brain of Blackjack                               ║
// ║                                                                            ║
// ║ Purpose: Orchestrates all gameplay state, logic, and flow                 ║
// ║ Business Context: This is the single source of truth for the entire game. ║
// ║                   It coordinates the deck, hands, bets, and game flow,    ║
// ║                   implementing a state machine that guides the player     ║
// ║                   from betting → dealing → playing → dealer turn → result.║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Manage game state transitions (betting → dealing → playing → result)    ║
// ║ • Coordinate with DeckManager for card dealing                            ║
// ║ • Track player hand(s) and dealer hand                                    ║
// ║ • Process player actions (Hit, Stand, Double, Split, Surrender)           ║
// ║ • Implement dealer AI logic                                               ║
// ║ • Calculate payouts and update bankroll                                   ║
// ║ • Handle edge cases (bust, blackjack, push, bankruptcy)                   ║
// ║                                                                            ║
// ║ Used By: GameView (observes @Published properties for UI updates)         ║
// ║ Uses: DeckManager, Hand, Card, Player models                              ║
// ║                                                                            ║
// ║ Related Spec: See "Core Gameplay Mechanics" section (lines 130-170)       ║
// ║               and "Typical Game Flow" (lines 543-551)                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE PROPERTIES                                        │
    // │                                                                      │
    // │ These properties trigger UI updates when changed                    │
    // │ GameView observes these to stay in sync with game state             │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Current dealer personality (Phase 3: Dealer Personalities)
    /// Determines all game rules, theme, and playing experience
    @Published var currentDealer: Dealer

    /// Current Maverick rule set name (for display when playing Maverick)
    @Published private(set) var currentMaverickRuleName: String?

    /// Current game state - drives UI display and available actions
    @Published private(set) var gameState: GameState = .betting

    /// Player's current hand(s) - array supports splits (up to 4 hands)
    @Published private(set) var playerHands: [Hand] = [Hand()]

    /// Index of currently active player hand (important for splits)
    @Published private(set) var currentHandIndex: Int = 0

    /// Dealer's visible card (the "upcard")
    @Published private(set) var dealerUpcard: Card?

    /// Dealer's hidden card (revealed during dealer's turn)
    @Published private(set) var dealerHoleCard: Card?

    /// All dealer cards (built as hole card is revealed)
    @Published private(set) var dealerHand: Hand = Hand()

    /// Current bet amount (in AUD)
    @Published var currentBet: Double = 0

    /// Player's bankroll (in AUD)
    @Published var bankroll: Double = 10000 // Default starting balance

    /// Last bet amount (used to remember bet between hands)
    @Published private(set) var lastBet: Double = 10

    /// Base minimum bet (before dealer multiplier)
    private let baseMinimumBet: Double = 10

    /// Minimum bet allowed (based on dealer rules)
    @Published var minimumBet: Double = 10

    /// Result message to display to player
    @Published private(set) var resultMessage: String = ""

    /// Whether reshuffle is needed (visual indicator for player)
    @Published private(set) var needsReshuffle: Bool = false

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                               │
    // │                                                                      │
    // │ These are used internally but don't need to trigger UI updates      │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Deck manager handles shoe management and dealing
    private var deckManager: DeckManager

    /// Bets for each hand (needed for splits where each hand can have different bets)
    private var handBets: [Double] = []

    /// Maverick rule generator (for randomising Maverick's rules each shoe)
    private var maverickGenerator = MaverickRuleGenerator()

    /// Statistics manager for tracking gameplay (Phase 4)
    private var statsManager = StatisticsManager.shared

    /// Tutorial manager for interactive tutorial (Phase 6)
    private var tutorialManager = TutorialManager.shared

    /// Actions taken during current hand (for statistics tracking - Phase 4)
    private var currentHandActions: [[PlayerAction]] = [[]]

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 PHASE 7: ANIMATION, AUDIO & HAPTIC MANAGERS                       │
    // │                                                                      │
    // │ Purpose: Provide premium multi-sensory feedback for all game actions│
    // │ Integration: Called throughout game actions to trigger animations,  │
    // │             sound effects, and haptic feedback                      │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Audio manager for sound effects (Phase 7)
    private let audioManager = AudioManager.shared

    /// Haptic manager for tactile feedback (Phase 7)
    private let hapticManager = HapticManager.shared

    /// Animation coordinator for orchestrating all animations (Phase 7)
    private let animationCoordinator = GameAnimationCoordinator()

    /// Visual settings manager for visual customisation (Phase 7)
    private let visualSettings = VisualSettingsManager.shared

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏆 PHASE 8: ACHIEVEMENT & PROGRESSION MANAGERS                       │
    // │                                                                      │
    // │ Purpose: Track achievements and player progression                  │
    // │ Integration: Called after hand results and session completion       │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Achievement manager for tracking achievements (Phase 8)
    private let achievementManager = AchievementManager.shared

    /// Progression manager for XP and levels (Phase 8)
    private let progressionManager = ProgressionManager.shared

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 PHASE 9: CHALLENGE MANAGER                                        │
    // │                                                                      │
    // │ Purpose: Track daily/weekly challenges and events                   │
    // │ Integration: Called after each hand to update challenge progress    │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Challenge manager for tracking challenges (Phase 9)
    private let challengeManager = ChallengeManager.shared

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📜 CURRENT RULES                                                     │
    // │                                                                      │
    // │ Computed property that returns current dealer's rules               │
    // │ All game logic should reference this, not hardcoded values          │
    // └─────────────────────────────────────────────────────────────────────┘

    var rules: GameRules {
        return currentDealer.rules
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                       │
    // │                                                                      │
    // │ Phase 3 Update: Now takes dealer instead of individual parameters   │
    // │                                                                      │
    // │ Parameters:                                                          │
    // │ • dealer: Dealer personality (default: Ruby)                        │
    // │ • startingBankroll: Initial player balance (default $10,000 AUD)    │
    // └─────────────────────────────────────────────────────────────────────┘

    init(dealer: Dealer = .ruby(), startingBankroll: Double = 10000) {
        self.currentDealer = dealer
        self.deckManager = DeckManager(
            numberOfDecks: dealer.rules.numberOfDecks,
            penetrationThreshold: 0.75
        )
        self.bankroll = startingBankroll

        // Calculate minimum bet from dealer rules
        self.minimumBet = self.baseMinimumBet * dealer.rules.minimumBetMultiplier
        self.lastBet = self.minimumBet
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔄 SWITCH DEALER                                                     │
    // │                                                                      │
    // │ Business Logic: Change dealers mid-session                          │
    // │ Called when: Player selects new dealer from dealer selection screen │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Creates new deck manager with new dealer's deck count             │
    // │ • Updates minimum bet based on dealer's multiplier                  │
    // │ • Resets current game state to betting                              │
    // │ • Clears hands and bets                                             │
    // │ • For Maverick: Generates initial random rules                      │
    // └─────────────────────────────────────────────────────────────────────┘

    func switchDealer(to newDealer: Dealer) {
        print("🔄 Switching from \(currentDealer.name) to \(newDealer.name)")

        // End current statistics session (Phase 4)
        endStatisticsSession()

        // Phase 7: Animate dealer change
        animationCoordinator.animateDealerChange { [weak self] in
            guard let self = self else { return }

            // Update dealer
            self.currentDealer = newDealer

            // Create new deck manager with new dealer's deck count
            self.deckManager = DeckManager(
                numberOfDecks: newDealer.rules.numberOfDecks,
                penetrationThreshold: 0.75
            )

            // Update minimum bet
            self.minimumBet = self.baseMinimumBet * newDealer.rules.minimumBetMultiplier
            self.lastBet = self.minimumBet

            // If switching to Maverick, generate initial random rules
            if newDealer.name == "Maverick" {
                let (ruleName, newRules) = self.maverickGenerator.generateRandomRules()
                self.currentMaverickRuleName = ruleName
                // Update dealer's rules (we'll need to make dealer mutable for this)
                print("🎲 Maverick starting with: \(ruleName)")
            }

            // Reset game state
            self.playerHands = [Hand()]
            self.dealerHand = Hand()
            self.dealerUpcard = nil
            self.dealerHoleCard = nil
            self.currentHandIndex = 0
            self.currentBet = 0
            self.handBets = []
            self.resultMessage = ""
            self.needsReshuffle = false
            self.gameState = .betting

            print("✅ Dealer switch complete")
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎰 BETTING PHASE                                                           ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💰 PLACE BET                                                         │
    // │                                                                      │
    // │ Business Logic: Player commits to a bet amount to start a new hand  │
    // │ Called when: Player confirms bet via BettingView UI                 │
    // │                                                                      │
    // │ Validation:                                                          │
    // │ • Bet must be >= minimumBet                                         │
    // │ • Bet must be <= current bankroll                                   │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Deducts bet from bankroll                                         │
    // │ • Transitions to .dealing state                                     │
    // │ • Remembers bet as lastBet                                          │
    // │ • Triggers initial deal                                             │
    // └─────────────────────────────────────────────────────────────────────┘

    func placeBet(_ amount: Double) {
        // Validate bet
        guard amount >= minimumBet else {
            print("⚠️ Bet too low: \(amount) < \(minimumBet)")
            return
        }

        guard amount <= bankroll else {
            print("⚠️ Insufficient funds: \(amount) > \(bankroll)")
            return
        }

        guard gameState == .betting else {
            print("⚠️ Cannot place bet in \(gameState) state")
            return
        }

        // Commit bet
        currentBet = amount
        lastBet = amount
        bankroll -= amount

        // Set up single hand with this bet
        handBets = [amount]

        print("💰 Bet placed: $\(amount) AUD (Bankroll: $\(bankroll))")

        // Start statistics session if this is the first bet
        if !statsManager.hasActiveSession {
            statsManager.startSession(
                dealerName: currentDealer.name,
                dealerIcon: currentDealer.icon,
                startingBankroll: bankroll + amount // Add back bet we just deducted
            )
        }

        // Reset hand actions tracking
        currentHandActions = [[]]

        // Notify tutorial manager (Phase 6)
        tutorialManager.notifyActionCompleted(.placeBet)

        // Phase 7: Animate bet placement with multi-sensory feedback
        animationCoordinator.animatePlaceBet(amount: amount) { [weak self] in
            guard let self = self else { return }

            // Transition to dealing after bet animation completes
            self.gameState = .dealing

            // Start dealing sequence
            self.dealInitialCards()
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎴 DEALING PHASE                                                           ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 DEAL INITIAL CARDS                                                │
    // │                                                                      │
    // │ Business Logic: Deals 2 cards to player, 2 to dealer (one hidden)   │
    // │ Standard casino sequence:                                            │
    // │ 1. Player card (face up)                                            │
    // │ 2. Dealer card (face up - upcard)                                   │
    // │ 3. Player card (face up)                                            │
    // │ 4. Dealer card (face down - hole card)                              │
    // │                                                                      │
    // │ After dealing:                                                       │
    // │ • Check for player blackjack                                        │
    // │ • Check for dealer blackjack                                        │
    // │ • If both: Push (tie)                                               │
    // │ • If only player: Instant win 3:2                                   │
    // │ • If only dealer: Instant loss                                      │
    // │ • Otherwise: Transition to player's turn                            │
    // └─────────────────────────────────────────────────────────────────────┘

    private func dealInitialCards() {
        // Check for reshuffle before dealing
        if deckManager.needsReshuffle {
            needsReshuffle = true
            deckManager.reshuffle()
            needsReshuffle = false

            // Phase 7: Play shuffle sound
            audioManager.playCardShuffle()
        }

        // Deal cards using DeckManager
        guard let initialDeal = deckManager.dealInitialHands() else {
            print("❌ Failed to deal cards - deck exhausted?")
            return
        }

        // Set up player hand
        playerHands = [initialDeal.playerHand]
        currentHandIndex = 0

        // Set up dealer cards
        dealerUpcard = initialDeal.dealerUpcard
        dealerHoleCard = initialDeal.dealerHoleCard

        // Build dealer's visible hand (just upcard for now)
        dealerHand = Hand()
        dealerHand.addCard(initialDeal.dealerUpcard)

        print("🎴 Cards dealt:")
        print("   Player: \(playerHands[0].description)")
        print("   Dealer: \(dealerUpcard!.displayString) + [hidden]")

        // Phase 7: Animate initial deal sequence with audio/haptic feedback
        animationCoordinator.animateDeal { [weak self] in
            guard let self = self else { return }

            // Check for blackjacks after animation
            let playerHasBlackjack = self.playerHands[0].isBlackjack

            // For blackjack check, we need to peek at dealer's full hand
            var dealerFullHand = Hand()
            dealerFullHand.addCard(initialDeal.dealerUpcard)
            dealerFullHand.addCard(initialDeal.dealerHoleCard)
            let dealerHasBlackjack = dealerFullHand.isBlackjack

            if playerHasBlackjack || dealerHasBlackjack {
                // Instant resolution - reveal dealer hole card
                self.revealDealerHoleCard()

                if playerHasBlackjack && dealerHasBlackjack {
                    // Push - both have blackjack
                    self.resultMessage = "Push - Both Blackjack!"
                    self.bankroll += self.currentBet // Return bet
                    print("🤝 Push - Both have blackjack")

                    // Phase 7: Animate push
                    self.animationCoordinator.animatePush { [weak self] in
                        self?.gameState = .result
                    }
                } else if playerHasBlackjack {
                    // Phase 3: Player wins - payout per dealer rules
                    let payout = self.currentBet * (1 + self.rules.blackjackPayout)
                    self.bankroll += payout

                    let payoutRatio = self.rules.blackjackPayout == 1.5 ? "3:2" : "6:5"
                    self.resultMessage = "Blackjack (\(payoutRatio))! You win $\(self.formatCurrency(payout - self.currentBet))!"
                    print("🎉 Player blackjack (\(payoutRatio))! Payout: $\(self.formatCurrency(payout))")

                    // Phase 7: Animate blackjack celebration
                    self.animationCoordinator.animateBlackjack(payout: payout) { [weak self] in
                        self?.gameState = .result
                    }
                } else {
                    // Dealer wins
                    self.resultMessage = "Dealer Blackjack - You lose"
                    print("😔 Dealer blackjack - player loses")

                    // Phase 7: Animate loss
                    self.animationCoordinator.animateLoss { [weak self] in
                        self?.gameState = .result
                    }
                }
            } else {
                // Normal play - transition to player's turn
                self.gameState = .playerTurn
                print("▶️ Player's turn")
            }
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎯 PLAYER ACTION PHASE                                                     ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 HIT - Take Another Card                                           │
    // │                                                                      │
    // │ Business Logic: Deal one card to player's current hand              │
    // │ Called when: Player taps "Hit" button during their turn             │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Adds card to current hand                                         │
    // │ • If bust: End player's turn, move to dealer turn                   │
    // │ • If 21: Auto-stand (optional rule, implementing for UX)            │
    // │ • If split scenario: May advance to next hand                       │
    // └─────────────────────────────────────────────────────────────────────┘

    func hit() {
        guard gameState == .playerTurn else {
            print("⚠️ Cannot hit in \(gameState) state")
            return
        }

        guard let card = deckManager.dealCard() else {
            print("❌ No cards remaining to deal")
            return
        }

        // Track action for statistics
        currentHandActions[currentHandIndex].append(.hit)

        // Notify tutorial manager (Phase 6)
        tutorialManager.notifyActionCompleted(.makePlayerAction)

        print("🎴 Player hits: \(card.displayString)")

        // Phase 7: Animate hit with multi-sensory feedback
        animationCoordinator.animateHit(cardID: card.id) { [weak self] in
            guard let self = self else { return }

            // Add card to current hand after animation
            self.playerHands[self.currentHandIndex].addCard(card)
            let hand = self.playerHands[self.currentHandIndex]

            print("   → \(hand.description)")

            // Check for bust
            if hand.isBust {
                print("💥 Player busts with \(hand.total)")

                // Phase 7: Animate bust
                self.animationCoordinator.animateBust { [weak self] in
                    guard let self = self else { return }

                    // If this was the last/only hand, move to dealer turn
                    if self.currentHandIndex == self.playerHands.count - 1 {
                        // All hands complete - dealer's turn
                        self.gameState = .dealerTurn
                        self.playDealerHand()
                    } else {
                        // Move to next split hand
                        self.currentHandIndex += 1
                        print("▶️ Moving to hand \(self.currentHandIndex + 1) of \(self.playerHands.count)")
                    }
                }
            } else if hand.total == 21 {
                // Auto-stand on 21 for better UX
                print("✓ Hand reaches 21 - auto-standing")
                self.stand()
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✋ STAND - End Current Hand                                          │
    // │                                                                      │
    // │ Business Logic: Player is satisfied with current hand                │
    // │ Called when: Player taps "Stand" button during their turn           │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • If more split hands: Move to next hand                            │
    // │ • If all hands complete: Transition to dealer turn                  │
    // └─────────────────────────────────────────────────────────────────────┘

    func stand() {
        guard gameState == .playerTurn else {
            print("⚠️ Cannot stand in \(gameState) state")
            return
        }

        let hand = playerHands[currentHandIndex]

        // Track action for statistics
        currentHandActions[currentHandIndex].append(.stand)

        // Notify tutorial manager (Phase 6)
        tutorialManager.notifyActionCompleted(.makePlayerAction)

        print("✋ Player stands on \(hand.displayString)")

        // Phase 7: Animate stand confirmation with audio/haptic feedback
        animationCoordinator.animateStand { [weak self] in
            guard let self = self else { return }

            // Check if there are more split hands
            if self.currentHandIndex < self.playerHands.count - 1 {
                // Move to next split hand
                self.currentHandIndex += 1
                print("▶️ Moving to hand \(self.currentHandIndex + 1) of \(self.playerHands.count)")
            } else {
                // All hands complete - dealer's turn
                self.gameState = .dealerTurn
                self.playDealerHand()
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💪 DOUBLE DOWN - Double Bet, Take One Card, Auto-Stand              │
    // │                                                                      │
    // │ Phase 3 Updates:                                                     │
    // │ • Shark restricts doubles to 9/10/11 only                           │
    // │ • Lucky offers free doubles (no additional cost!)                   │
    // │ • Check double after split rules                                    │
    // │                                                                      │
    // │ Business Logic: Risky move - double your bet for exactly one card   │
    // │ Called when: Player taps "Double" button (only available on 2 cards)│
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Deducts additional bet from bankroll (unless Lucky's free double) │
    // │ • Deals exactly one card                                            │
    // │ • Automatically stands (no more actions allowed)                    │
    // └─────────────────────────────────────────────────────────────────────┘

    func doubleDown() {
        guard gameState == .playerTurn else {
            print("⚠️ Cannot double in \(gameState) state")
            return
        }

        let hand = playerHands[currentHandIndex]

        guard hand.canDouble() else {
            print("⚠️ Cannot double - hand has \(hand.count) cards")
            return
        }

        // Phase 3: Check if this hand came from a split
        let isAfterSplit = playerHands.count > 1

        // Check double after split rule
        if isAfterSplit && !rules.doubleAfterSplit {
            print("⚠️ Cannot double after split (dealer rule)")
            return
        }

        // Phase 3: Check restricted double totals (Shark: 9/10/11 only)
        if let restrictedTotals = rules.doubleOnlyOn {
            if !restrictedTotals.contains(hand.total) {
                print("⚠️ Cannot double on \(hand.total) - only allowed on \(restrictedTotals)")
                return
            }
        }

        let additionalBet = handBets[currentHandIndex]

        // Phase 3: Lucky's free doubles - don't require bankroll
        if !rules.freeDoubles {
            // Normal double - need bankroll
            guard bankroll >= additionalBet else {
                print("⚠️ Insufficient funds to double - need $\(additionalBet), have $\(bankroll)")
                return
            }

            // Deduct additional bet
            bankroll -= additionalBet
            print("💪 Player doubles down - bet now $\(handBets[currentHandIndex] * 2)")
        } else {
            // 🍀 Lucky's free double!
            print("🍀 Lucky's free double - no additional cost!")
        }

        // Update bet tracking (same either way for payout calculation)
        handBets[currentHandIndex] *= 2
        currentBet += additionalBet

        // Track action for statistics (Phase 4)
        currentHandActions[currentHandIndex].append(.doubleDown)

        print("💪 Player doubles down - bet now $\(handBets[currentHandIndex])")

        // Deal exactly one card
        guard let card = deckManager.dealCard() else {
            print("❌ No cards remaining to deal")
            return
        }

        print("🎴 Double down card: \(card.displayString)")

        // Phase 7: Animate double down (bet doubling + card deal)
        animationCoordinator.animateDoubleDown(cardID: card.id) { [weak self] in
            guard let self = self else { return }

            // Add card to hand after animation
            self.playerHands[self.currentHandIndex].addCard(card)
            let updatedHand = self.playerHands[self.currentHandIndex]

            print("   → \(updatedHand.description)")

            // Automatically stand (even if bust)
            if self.currentHandIndex < self.playerHands.count - 1 {
                // More split hands to play
                self.currentHandIndex += 1
                print("▶️ Moving to hand \(self.currentHandIndex + 1) of \(self.playerHands.count)")
            } else {
                // All hands complete - dealer's turn
                self.gameState = .dealerTurn
                self.playDealerHand()
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✂️ SPLIT - Split Pair Into Two Hands                                │
    // │                                                                      │
    // │ Phase 3 Updates:                                                     │
    // │ • Shark limits to 2 hands max (single split)                        │
    // │ • Split aces rules: one card only vs full play (dealer-specific)    │
    // │ • Re-split aces rules (most dealers don't allow)                    │
    // │ • Lucky offers free splits (no additional cost!)                    │
    // │                                                                      │
    // │ Business Logic: Split matching cards into two separate hands        │
    // │ Called when: Player taps "Split" button on a pair                   │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Deducts second bet from bankroll (unless Lucky's free split)      │
    // │ • Creates two hands from one                                        │
    // │ • Deals one card to each hand                                       │
    // │ • For split aces with one-card rule: Auto-stands both hands         │
    // │ • Otherwise: Player continues with first hand                       │
    // └─────────────────────────────────────────────────────────────────────┘

    func split() {
        guard gameState == .playerTurn else {
            print("⚠️ Cannot split in \(gameState) state")
            return
        }

        let hand = playerHands[currentHandIndex]

        guard hand.canSplit() else {
            print("⚠️ Cannot split - not a pair")
            return
        }

        // Phase 3: Check max split hands rule (Shark = 2, most others = 4)
        guard playerHands.count < rules.maxSplitHands else {
            print("⚠️ Cannot split - already have \(rules.maxSplitHands) hands (max for \(currentDealer.name))")
            return
        }

        // Phase 3: Check if this is a pair of aces
        let isSplittingAces = hand.isPairOfAces()

        // Phase 3: Check re-split aces rule
        if isSplittingAces && playerHands.count > 1 && !rules.resplitAces {
            print("⚠️ Cannot re-split aces (dealer rule)")
            return
        }

        let splitBet = handBets[currentHandIndex]

        // Phase 3: Lucky's free splits - don't require bankroll
        if !rules.freeSplits {
            // Normal split - need bankroll
            guard bankroll >= splitBet else {
                print("⚠️ Insufficient funds to split - need $\(splitBet), have $\(bankroll)")
                return
            }

            // Deduct second bet
            bankroll -= splitBet
            print("✂️ Player splits pair - creating 2 hands at $\(splitBet) each")
        } else {
            // 🍀 Lucky's free split!
            print("🍀 Lucky's free split - no additional cost!")
        }

        currentBet += splitBet

        // Track action for statistics (Phase 4)
        currentHandActions[currentHandIndex].append(.split)

        print("✂️ Player splits pair - creating 2 hands at $\(splitBet) each")

        // Phase 7: Animate split with multi-sensory feedback
        animationCoordinator.animateSplit { [weak self] in
            guard let self = self else { return }

            // Split the hand after animation
            let cards = hand.cards
            var hand1 = Hand(cards: [cards[0]])
            var hand2 = Hand(cards: [cards[1]])

            // Phase 3: Split aces special handling
            if isSplittingAces && self.rules.splitAcesOneCardOnly {
                print("   ✂️ Splitting aces - one card each (standard rule)")

                // Deal one card to each hand
                if let card1 = self.deckManager.dealCard() {
                    hand1.addCard(card1)
                    print("   Hand 1: \(hand1.description)")
                }

                if let card2 = self.deckManager.dealCard() {
                    hand2.addCard(card2)
                    print("   Hand 2: \(hand2.description)")
                }

                // Replace current hand and insert new hand
                self.playerHands[self.currentHandIndex] = hand1
                self.playerHands.insert(hand2, at: self.currentHandIndex + 1)
                self.handBets.insert(splitBet, at: self.currentHandIndex + 1)

                // Add actions array for second split hand (Phase 4)
                self.currentHandActions.insert([], at: self.currentHandIndex + 1)

                // Auto-stand both hands (split aces one card rule)
                print("   ✋ Split aces complete - both hands stand")

                // Move to dealer turn (no more player actions)
                self.gameState = .dealerTurn
                self.playDealerHand()

            } else {
                // Normal split or split aces with full play (Lucky, Zen)
                print("   ✂️ Splitting pair - normal play")

                // Deal one card to each hand
                if let card1 = self.deckManager.dealCard() {
                    hand1.addCard(card1)
                    print("   Hand 1: \(hand1.description)")
                }

                if let card2 = self.deckManager.dealCard() {
                    hand2.addCard(card2)
                    print("   Hand 2: \(hand2.description)")
                }

                // Replace current hand and insert new hand
                self.playerHands[self.currentHandIndex] = hand1
                self.playerHands.insert(hand2, at: self.currentHandIndex + 1)
                self.handBets.insert(splitBet, at: self.currentHandIndex + 1)

                // Continue playing first split hand
                print("▶️ Playing hand 1 of \(self.playerHands.count)")

                // Check for instant 21 on first hand (auto-stand)
                if hand1.total == 21 {
                    print("✓ First split hand is 21 - auto-standing")
                    self.stand()
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏳️ SURRENDER - Forfeit Half Bet, End Hand                           │
    // │                                                                      │
    // │ Phase 3 Updates:                                                     │
    // │ • Check if surrender is allowed (dealer-specific)                   │
    // │ • Early surrender (Zen): Before dealer checks for blackjack         │
    // │ • Late surrender (Lucky): After dealer checks for blackjack         │
    // │                                                                      │
    // │ Business Logic: Give up and get half your bet back                  │
    // │ Called when: Player taps "Surrender" button (dealer-specific)       │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Returns half bet to bankroll                                      │
    // │ • Immediately ends hand (no dealer play needed)                     │
    // │ • Transitions to result state                                       │
    // └─────────────────────────────────────────────────────────────────────┘

    func surrender() {
        guard gameState == .playerTurn else {
            print("⚠️ Cannot surrender in \(gameState) state")
            return
        }

        // Phase 3: Check if surrender is allowed for this dealer
        guard rules.surrenderAllowed else {
            print("⚠️ \(currentDealer.name) doesn't allow surrender")
            return
        }

        let hand = playerHands[currentHandIndex]

        // Can only surrender as first action (2-card hand)
        guard hand.count == 2 else {
            print("⚠️ Cannot surrender - already took action")
            return
        }

        // Phase 3: Early vs Late surrender
        // Early surrender (Zen): Can surrender before checking dealer blackjack
        // Late surrender (Lucky): Can only surrender after checking (already done in dealInitialCards)
        // This implementation assumes late surrender is default
        // Early surrender would need to be checked in dealInitialCards before blackjack check

        let surrenderType = rules.earlySurrender ? "early" : "late"
        print("🏳️ Player surrenders (\(surrenderType) surrender)")

        let bet = handBets[currentHandIndex]
        let refund = bet * 0.5

        bankroll += refund
        currentBet -= refund

        // Track action for statistics (Phase 4)
        currentHandActions[currentHandIndex].append(.surrender)

        print("   Refunding $\(formatCurrency(refund)) (half of $\(formatCurrency(bet)))")

        resultMessage = "Surrendered - $\(formatCurrency(refund)) returned"

        // Phase 7: Animate surrender with chip return
        animationCoordinator.animateSurrender { [weak self] in
            guard let self = self else { return }

            // Record surrender in statistics (Phase 4)
            self.recordSurrenderHand()

            self.gameState = .result
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎰 DEALER TURN                                                             ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🤖 DEALER AI - Automated Dealer Play                                │
    // │                                                                      │
    // │ Business Logic: Dealer follows fixed rules (no decisions)           │
    // │ Standard Rules:                                                      │
    // │ • Reveal hole card                                                  │
    // │ • Hit on 16 or less                                                 │
    // │ • Stand on 17 or more                                               │
    // │                                                                      │
    // │ Dealer-Specific Variations (Phase 3):                               │
    // │ • Ruby: Stand on soft 17                                            │
    // │ • Shark: Hit on soft 17                                             │
    // │                                                                      │
    // │ Optimisation: If all player hands bust, dealer doesn't play         │
    // │ (house wins automatically)                                           │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Reveals hole card                                                 │
    // │ • Deals cards to dealer until stand/bust                            │
    // │ • Transitions to result state                                       │
    // └─────────────────────────────────────────────────────────────────────┘

    private func playDealerHand() {
        guard gameState == .dealerTurn else {
            print("⚠️ Cannot play dealer hand in \(gameState) state")
            return
        }

        // Optimisation: If all player hands bust, dealer wins automatically
        let allPlayerHandsBust = playerHands.allSatisfy { $0.isBust }

        if allPlayerHandsBust {
            print("🎰 All player hands bust - dealer wins without playing")
            revealDealerHoleCard()
            evaluateResults()
            return
        }

        // Reveal hole card
        revealDealerHoleCard()

        print("🎰 Dealer plays: \(dealerHand.description)")

        // Collect dealer card IDs for animation
        var dealerCardIDs: [String] = []

        // ┌─────────────────────────────────────────────────────────────────────┐
        // │ 🤖 DEALER AI - Phase 3: Soft 17 Rule Implementation                 │
        // │                                                                      │
        // │ Dealer must follow fixed rules:                                     │
        // │ • Always hit on 16 or less                                          │
        // │ • Soft 17 rule (dealer-specific):                                   │
        // │   - If dealerHitsSoft17 == false: Stand on all 17s (Ruby, Lucky)   │
        // │   - If dealerHitsSoft17 == true: Hit soft 17, stand hard 17 (Shark)│
        // │                                                                      │
        // │ Example: Dealer has A-6 (soft 17)                                   │
        // │ • Ruby: Stands (player-friendly)                                    │
        // │ • Shark: Hits (more aggressive, higher house edge)                  │
        // └─────────────────────────────────────────────────────────────────────┘

        while dealerHand.total < 17 ||
              (dealerHand.total == 17 && dealerHand.isSoft && rules.dealerHitsSoft17) {
            // Dealer hits if:
            // 1. Total < 17, OR
            // 2. Soft 17 AND rules say to hit soft 17

            guard let card = deckManager.dealCard() else {
                print("❌ No cards remaining for dealer")
                break
            }

            dealerHand.addCard(card)
            dealerCardIDs.append(card.id)
            print("   Dealer hits: \(card.displayString) → \(dealerHand.description)")

            if dealerHand.isBust {
                print("   💥 Dealer busts with \(dealerHand.total)")
                break
            }
        }

        if !dealerHand.isBust {
            let handType = dealerHand.isSoft ? "soft" : "hard"
            print("   ✋ Dealer stands on \(handType) \(dealerHand.total)")
        }

        // Phase 7: Animate dealer turn with all cards
        animationCoordinator.animateDealerTurn(dealerCardIDs: dealerCardIDs) { [weak self] in
            guard let self = self else { return }

            // Evaluate all results after dealer turn animation
            self.evaluateResults()
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔓 REVEAL DEALER HOLE CARD                                           │
    // │                                                                      │
    // │ Business Logic: Flip dealer's hidden card face-up                   │
    // │ Called when: Dealer's turn begins or instant blackjack resolution   │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Adds hole card to dealer's visible hand                           │
    // │ • Clears hole card property (no longer hidden)                      │
    // │ • Triggers flip animation in UI (Phase 2.8)                         │
    // └─────────────────────────────────────────────────────────────────────┘

    private func revealDealerHoleCard() {
        guard let holeCard = dealerHoleCard else {
            print("⚠️ No hole card to reveal")
            return
        }

        dealerHand.addCard(holeCard)
        print("🔓 Dealer reveals hole card: \(holeCard.displayString) → \(dealerHand.description)")

        // Clear hole card (no longer hidden)
        // Note: We keep the property for animation - UI checks gameState to show/hide
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🏆 RESULT EVALUATION & PAYOUT                                              ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏆 EVALUATE RESULTS - Determine Winner & Calculate Payout           │
    // │                                                                      │
    // │ Business Logic: Compare each player hand to dealer hand             │
    // │                                                                      │
    // │ Win Conditions:                                                      │
    // │ • Player blackjack beats dealer 21: 3:2 payout                      │
    // │ • Player blackjack vs dealer blackjack: Push (return bet)           │
    // │ • Player total > dealer total (both ≤21): 1:1 payout                │
    // │ • Dealer bust, player ≤21: 1:1 payout                               │
    // │ • Player total = dealer total: Push (return bet)                    │
    // │ • Player bust: Lose (already deducted)                              │
    // │ • Dealer total > player total: Lose (already deducted)              │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Updates bankroll with payouts                                     │
    // │ • Sets result message for UI                                        │
    // │ • Transitions to result state                                       │
    // │ • Checks for bankruptcy                                             │
    // └─────────────────────────────────────────────────────────────────────┘

    private func evaluateResults() {
        let dealerTotal = dealerHand.total
        let dealerBust = dealerHand.isBust

        var totalPayout: Double = 0
        var outcomes: [String] = []

        // Evaluate each player hand
        for (index, hand) in playerHands.enumerated() {
            let bet = handBets[index]
            let handNum = playerHands.count > 1 ? " (Hand \(index + 1))" : ""

            if hand.isBust {
                // Player bust - already lost bet
                outcomes.append("Bust\(handNum): -$\(formatCurrency(bet))")
                print("   Hand \(index + 1): Bust - lose $\(bet)")

            } else if dealerBust {
                // Dealer bust, player didn't - player wins 1:1
                let payout = bet * 2 // Return bet + winnings
                totalPayout += payout
                outcomes.append("Win\(handNum): +$\(formatCurrency(bet))")
                print("   Hand \(index + 1): Dealer bust - win $\(bet)")

            } else if hand.isBlackjack && !dealerHand.isBlackjack {
                // Phase 3: Player blackjack beats dealer 21 - pays per dealer rules
                // Ruby/Lucky/Zen/Blitz: 3:2 (1.5x) → bet * 2.5 total
                // Shark: 6:5 (1.2x) → bet * 2.2 total
                let payout = bet * (1 + rules.blackjackPayout) // Bet + winnings
                totalPayout += payout

                // Display payout ratio
                let payoutRatio = rules.blackjackPayout == 1.5 ? "3:2" : "6:5"
                outcomes.append("Blackjack\(handNum): +$\(formatCurrency(payout - bet)) (\(payoutRatio))")
                print("   Hand \(index + 1): Blackjack (\(payoutRatio)) - win $\(formatCurrency(payout - bet))")

            } else if hand.total > dealerTotal {
                // Player total higher - wins 1:1
                let payout = bet * 2
                totalPayout += payout
                outcomes.append("Win\(handNum): +$\(formatCurrency(bet))")
                print("   Hand \(index + 1): \(hand.total) > \(dealerTotal) - win $\(bet)")

            } else if hand.total == dealerTotal {
                // Push - return bet
                let payout = bet
                totalPayout += payout
                outcomes.append("Push\(handNum)")
                print("   Hand \(index + 1): \(hand.total) = \(dealerTotal) - push")

            } else {
                // Dealer wins
                outcomes.append("Lose\(handNum): -$\(formatCurrency(bet))")
                print("   Hand \(index + 1): \(hand.total) < \(dealerTotal) - lose $\(bet)")
            }
        }

        // Apply payouts to bankroll
        bankroll += totalPayout

        // Generate result message
        let netResult = totalPayout - currentBet
        if netResult > 0 {
            resultMessage = "You Win! +$\(formatCurrency(netResult))\n" + outcomes.joined(separator: "\n")
        } else if netResult == 0 {
            resultMessage = "Push - Bet Returned\n" + outcomes.joined(separator: "\n")
        } else {
            resultMessage = "Dealer Wins -$\(formatCurrency(-netResult))\n" + outcomes.joined(separator: "\n")
        }

        print("🏆 Results: \(resultMessage.replacingOccurrences(of: "\n", with: " | "))")
        print("💰 Bankroll: $\(bankroll)")

        // Record hands in statistics
        recordHandResults()

        // Phase 7: Animate result based on outcome
        if netResult > 0 {
            // Player wins
            animationCoordinator.animateWin(payout: totalPayout) { [weak self] in
                guard let self = self else { return }
                self.checkBankruptcyAndTransition()
            }
        } else if netResult == 0 {
            // Push
            animationCoordinator.animatePush { [weak self] in
                guard let self = self else { return }
                self.checkBankruptcyAndTransition()
            }
        } else {
            // Dealer wins
            animationCoordinator.animateLoss { [weak self] in
                guard let self = self else { return }
                self.checkBankruptcyAndTransition()
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏦 CHECK BANKRUPTCY AND TRANSITION                                   │
    // │                                                                      │
    // │ Helper method to check bankruptcy after result animation completes  │
    // │ Phase 7: Separated from evaluateResults to call after animations    │
    // └─────────────────────────────────────────────────────────────────────┘

    private func checkBankruptcyAndTransition() {
        // Check for bankruptcy
        if bankroll < minimumBet {
            print("💸 Bankrupt! Balance ($\(bankroll)) < minimum bet ($\(minimumBet))")
            gameState = .gameOver
        } else {
            gameState = .result
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🔄 GAME FLOW CONTROL                                                       ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ▶️ NEXT HAND - Start New Round                                       │
    // │                                                                      │
    // │ Business Logic: Reset for next hand, return to betting              │
    // │ Called when: Player taps "Next Hand" after result                   │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Clears all hands                                                  │
    // │ • Resets current bet to 0                                           │
    // │ • Checks for reshuffle needs                                        │
    // │ • Returns to betting state                                          │
    // └─────────────────────────────────────────────────────────────────────┘

    func nextHand() {
        guard gameState == .result else {
            print("⚠️ Cannot start next hand from \(gameState) state")
            return
        }

        // Phase 7: Animate transition to next hand
        animationCoordinator.animateNextHand { [weak self] in
            guard let self = self else { return }

            // Clear hands
            self.playerHands = [Hand()]
            self.dealerHand = Hand()
            self.dealerUpcard = nil
            self.dealerHoleCard = nil
            self.currentHandIndex = 0

            // Reset bets
            self.currentBet = 0
            self.handBets = []

            // Clear result message
            self.resultMessage = ""

            // Check for reshuffle
            if self.deckManager.needsReshuffle {
                print("♠️ Shuffle indicator - will reshuffle before next deal")
                self.needsReshuffle = true
            }

            print("▶️ Ready for next hand")
            self.gameState = .betting
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔄 RESET BANKROLL - Bankruptcy Recovery                             │
    // │                                                                      │
    // │ Business Logic: Reset bankroll to starting amount                   │
    // │ Called when: Player bankrupt and confirms reset                     │
    // │                                                                      │
    // │ Side Effects:                                                        │
    // │ • Resets bankroll to starting amount (default $10,000)              │
    // │ • Returns to betting state                                          │
    // │ • Reshuffles deck for fresh start                                   │
    // └─────────────────────────────────────────────────────────────────────┘

    func resetBankroll(to amount: Double = 10000) {
        bankroll = amount
        lastBet = minimumBet

        // Clear any ongoing game
        playerHands = [Hand()]
        dealerHand = Hand()
        dealerUpcard = nil
        dealerHoleCard = nil
        currentHandIndex = 0
        currentBet = 0
        handBets = []
        resultMessage = ""

        // Fresh shoe
        deckManager.reshuffle()
        needsReshuffle = false

        print("🔄 Bankroll reset to $\(amount)")
        gameState = .betting
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎯 COMPUTED PROPERTIES - Convenience Accessors                             ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    /// Current active hand (for UI display)
    var currentHand: Hand {
        return playerHands[currentHandIndex]
    }

    /// Can player hit? (not bust, not stood, not 21)
    var canHit: Bool {
        return gameState == .playerTurn && !currentHand.isBust && currentHand.total < 21
    }

    /// Can player stand?
    var canStand: Bool {
        return gameState == .playerTurn && !currentHand.isBust
    }

    /// Phase 3: Can player double down?
    /// Now checks dealer-specific rules
    var canDoubleDown: Bool {
        guard gameState == .playerTurn && currentHand.canDouble() else {
            return false
        }

        // Check if this hand came from a split
        let isAfterSplit = playerHands.count > 1
        if isAfterSplit && !rules.doubleAfterSplit {
            return false // Dealer doesn't allow double after split
        }

        // Check restricted double totals (Shark: 9/10/11 only)
        if let restrictedTotals = rules.doubleOnlyOn {
            if !restrictedTotals.contains(currentHand.total) {
                return false // Hand total not in allowed list
            }
        }

        // Check bankroll (unless Lucky's free double)
        if !rules.freeDoubles {
            return bankroll >= handBets[currentHandIndex]
        }

        return true
    }

    /// Phase 3: Can player split?
    /// Now checks dealer-specific max split hands and bankroll
    var canSplit: Bool {
        guard gameState == .playerTurn && currentHand.canSplit() else {
            return false
        }

        // Check max split hands (Shark = 2, others = 4)
        if playerHands.count >= rules.maxSplitHands {
            return false
        }

        // Check if splitting aces and re-split aces not allowed
        if currentHand.isPairOfAces() && playerHands.count > 1 && !rules.resplitAces {
            return false
        }

        // Check bankroll (unless Lucky's free split)
        if !rules.freeSplits {
            return bankroll >= handBets[currentHandIndex]
        }

        return true
    }

    /// Phase 3: Can player surrender?
    /// Now checks if dealer allows surrender
    var canSurrender: Bool {
        return gameState == .playerTurn &&
               currentHand.count == 2 &&
               playerHands.count == 1 &&
               rules.surrenderAllowed
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 📊 STATISTICS TRACKING                                                     ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 RECORD HAND RESULTS                                           │
    // │                                                                  │
    // │ Business Logic: Convert game results to HandResult objects      │
    // │ and record them in StatisticsManager                            │
    // │                                                                  │
    // │ Called by: evaluateResults() after all hands are resolved       │
    // └─────────────────────────────────────────────────────────────────┘

    private func recordHandResults() {
        let dealerTotal = dealerHand.total
        let dealerBust = dealerHand.isBust
        let dealerCardsString = dealerHand.cards.map { $0.displayString }.joined(separator: ", ")

        // Record each player hand
        for (index, hand) in playerHands.enumerated() {
            let bet = handBets[index]
            let playerCardsString = hand.cards.map { $0.displayString }.joined(separator: ", ")
            let actions = currentHandActions.count > index ? currentHandActions[index] : []
            let wasSplit = playerHands.count > 1

            // Determine outcome
            let outcome: HandOutcome
            let payout: Double

            if hand.isBust {
                outcome = .bust
                payout = 0
            } else if dealerBust {
                outcome = .dealerBust
                payout = bet * 2
            } else if hand.isBlackjack && !dealerHand.isBlackjack {
                outcome = .blackjack
                payout = bet * 2.5
            } else if hand.total > dealerTotal {
                outcome = .win
                payout = bet * 2
            } else if hand.total == dealerTotal {
                outcome = .push
                payout = bet
            } else {
                outcome = .loss
                payout = 0
            }

            // Create HandResult
            let handResult = HandResult(
                playerCards: playerCardsString,
                playerTotal: hand.total,
                dealerCards: dealerCardsString,
                dealerTotal: dealerTotal,
                betAmount: bet,
                payout: payout,
                outcome: outcome,
                actions: actions,
                wasSplit: wasSplit
            )

            // Record in statistics manager
            statsManager.recordHand(handResult, newBankroll: bankroll)

            // Phase 8: Check achievements for this hand
            let currentSession = statsManager.currentSession
            let currentStreak = currentSession?.currentStreak ?? 0

            achievementManager.checkAchievementsAfterHand(
                handResult: outcome,
                wasBlackjack: outcome == .blackjack,
                wasSplit: wasSplit,
                wasDoubleDown: actions.contains(.doubleDown),
                wasSurrender: false,
                betAmount: bet,
                dealerName: currentDealer.name,
                currentStreak: currentStreak,
                currentBankroll: bankroll,
                cards: hand.cards.map { $0.displayString }
            )

            // Phase 8: Record hand in progression system
            progressionManager.recordHand(
                won: outcome.isWin,
                wasBlackjack: outcome == .blackjack,
                netProfit: payout - bet
            )

            // Phase 8: Update longest streak
            if currentStreak > 0 {
                progressionManager.updateLongestStreak(currentStreak)
            }

            // Phase 9: Update challenge progress for this hand
            updateChallengeProgress(
                handResult: outcome,
                wasBlackjack: outcome == .blackjack,
                wasSplit: wasSplit,
                wasDoubleDown: actions.contains(.doubleDown),
                betAmount: bet,
                currentStreak: currentStreak
            )
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏳️ RECORD SURRENDER HAND                                         │
    // │                                                                  │
    // │ Business Logic: Record surrender as special case                │
    // │ Called by: surrender() immediately when player surrenders       │
    // └─────────────────────────────────────────────────────────────────┘

    private func recordSurrenderHand() {
        let hand = playerHands[currentHandIndex]
        let bet = handBets[currentHandIndex]
        let playerCardsString = hand.cards.map { $0.displayString }.joined(separator: ", ")
        let dealerCardsString = dealerUpcard?.displayString ?? "?"
        let actions = currentHandActions[currentHandIndex]

        let handResult = HandResult(
            playerCards: playerCardsString,
            playerTotal: hand.total,
            dealerCards: dealerCardsString + " + [hidden]",
            dealerTotal: 0, // Not revealed
            betAmount: bet,
            payout: bet * 0.5, // Half bet back
            outcome: .surrender,
            actions: actions,
            wasSplit: false
        )

        statsManager.recordHand(handResult, newBankroll: bankroll)

        // Phase 8: Check achievements for surrender
        let currentSession = statsManager.currentSession
        let currentStreak = currentSession?.currentStreak ?? 0

        achievementManager.checkAchievementsAfterHand(
            handResult: .surrender,
            wasBlackjack: false,
            wasSplit: false,
            wasDoubleDown: false,
            wasSurrender: true,
            betAmount: bet,
            dealerName: currentDealer.name,
            currentStreak: currentStreak,
            currentBankroll: bankroll,
            cards: hand.cards.map { $0.displayString }
        )

        // Phase 8: Record surrender in progression
        progressionManager.recordHand(
            won: false,
            wasBlackjack: false,
            netProfit: -(bet * 0.5)
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔚 END STATISTICS SESSION                                        │
    // │                                                                  │
    // │ Business Logic: End current stats session (e.g., when changing  │
    // │ dealers or quitting)                                            │
    // │                                                                  │
    // │ Public method for GameView or settings to call                  │
    // └─────────────────────────────────────────────────────────────────┘

    func endStatisticsSession() {
        if statsManager.hasActiveSession {
            // Get session data before ending
            let session = statsManager.currentSession!
            let duration = session.duration
            let netProfit = session.netProfit
            let startingBankroll = session.startingBankroll
            let wasBankrupt = bankroll < minimumBet

            // End the session
            statsManager.endSession(finalBankroll: bankroll)
            print("📊 Statistics session ended")

            // Phase 8: Check session-based achievements
            achievementManager.checkAchievementsAfterSession(
                duration: duration,
                netProfit: netProfit,
                startingBankroll: startingBankroll,
                wasBankrupt: wasBankrupt
            )

            // Phase 8: Record session in progression
            progressionManager.recordSession(duration: duration)
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🎯 CHALLENGE PROGRESS TRACKING (PHASE 9)                                   ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎯 UPDATE CHALLENGE PROGRESS                                     │
    // │                                                                  │
    // │ Business Logic: Update relevant challenges after a hand         │
    // │ Called by: recordHandResults() after each hand                  │
    // └─────────────────────────────────────────────────────────────────┘

    private func updateChallengeProgress(
        handResult: HandOutcome,
        wasBlackjack: Bool,
        wasSplit: Bool,
        wasDoubleDown: Bool,
        betAmount: Double,
        currentStreak: Int
    ) {
        // Create challenge context
        let context = ChallengeContext(
            dealerName: currentDealer.name,
            betAmount: Int(betAmount),
            currentStreak: currentStreak,
            didBust: handResult == .bust,
            netProfit: 0 // Would need session profit calculation
        )

        // Update based on hand result
        if handResult.isWin {
            challengeManager.updateChallengeProgress(action: .win, context: context)
        }

        if wasBlackjack {
            challengeManager.updateChallengeProgress(action: .blackjack, context: context)
        }

        if wasDoubleDown && handResult.isWin {
            challengeManager.updateChallengeProgress(action: .doubleDown, context: context)
        }

        if wasSplit && handResult.isWin {
            challengeManager.updateChallengeProgress(action: .split, context: context)
        }

        if betAmount >= 1000 {
            challengeManager.updateChallengeProgress(action: .highBet, context: context)
        }

        if !playerHands[currentHandIndex].isBust {
            challengeManager.updateChallengeProgress(action: .noBust, context: context)
        }

        if currentStreak > 0 {
            challengeManager.updateChallengeProgress(action: .winStreak, context: context)
        }

        // Always update play hands count
        challengeManager.updateChallengeProgress(action: .playHands, context: context)

        // Dealer-specific challenges
        challengeManager.updateChallengeProgress(action: .dealerSpecific, context: context)
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🛠️ UTILITY FUNCTIONS                                                       ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    /// Format currency for display
    private func formatCurrency(_ amount: Double) -> String {
        return String(format: "%.2f", amount)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎮 GAME STATE ENUMERATION                                                  ║
// ║                                                                            ║
// ║ Purpose: Defines all possible states in the game flow                     ║
// ║ Business Context: The game is a state machine. Each state determines      ║
// ║                   what UI is shown and what actions are available.        ║
// ║                                                                            ║
// ║ State Transitions:                                                         ║
// ║ .betting → .dealing → .playerTurn → .dealerTurn → .result → .betting     ║
// ║                                              ↓                             ║
// ║                                         .gameOver (if bankrupt)            ║
// ║                                                                            ║
// ║ UI Implications:                                                           ║
// ║ • .betting: Show betting slider and confirm button                        ║
// ║ • .dealing: Show card dealing animation                                   ║
// ║ • .playerTurn: Show action buttons (Hit, Stand, Double, Split)           ║
// ║ • .dealerTurn: Show dealer playing automatically                          ║
// ║ • .result: Show win/loss message and "Next Hand" button                   ║
// ║ • .gameOver: Show bankruptcy message and "Reset Bankroll" button          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum GameState {
    case betting      // Player selects bet amount
    case dealing      // Cards being dealt (animation state)
    case playerTurn   // Player making decisions (Hit, Stand, Double, Split)
    case dealerTurn   // Dealer playing automatically
    case result       // Showing outcome and payout
    case gameOver     // Bankrupt - needs reset
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create game view model:                                                    ║
// ║   let gameVM = GameViewModel(numberOfDecks: 6,                             ║
// ║                              startingBankroll: 10000,                     ║
// ║                              minimumBet: 10)                              ║
// ║                                                                            ║
// ║ Place a bet:                                                               ║
// ║   gameVM.placeBet(50.0)  // Automatically deals cards                     ║
// ║                                                                            ║
// ║ Player actions:                                                            ║
// ║   if gameVM.canHit {                                                       ║
// ║       gameVM.hit()                                                         ║
// ║   }                                                                        ║
// ║   if gameVM.canDoubleDown {                                               ║
// ║       gameVM.doubleDown()                                                 ║
// ║   }                                                                        ║
// ║   gameVM.stand()  // Triggers dealer play automatically                   ║
// ║                                                                            ║
// ║ Start next hand:                                                           ║
// ║   if gameVM.gameState == .result {                                        ║
// ║       gameVM.nextHand()  // Returns to betting                            ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ Handle bankruptcy:                                                         ║
// ║   if gameVM.gameState == .gameOver {                                      ║
// ║       gameVM.resetBankroll(to: 10000)                                     ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ In SwiftUI View:                                                           ║
// ║   @StateObject var viewModel = GameViewModel()                            ║
// ║                                                                            ║
// ║   var body: some View {                                                    ║
// ║       Text("Bankroll: $\(viewModel.bankroll)")                            ║
// ║       Button("Hit") {                                                      ║
// ║           viewModel.hit()                                                  ║
// ║       }                                                                    ║
// ║       .disabled(!viewModel.canHit)                                        ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
