//
//  GameView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎮 GAME VIEW - Main Gameplay Screen                                       ║
// ║                                                                            ║
// ║ Purpose: The primary interface where blackjack gameplay happens           ║
// ║ Business Context: This is where players spend 95% of their time. It must  ║
// ║                   be clean, intuitive, and distraction-free.              ║
// ║                                                                            ║
// ║ Layout Structure:                                                          ║
// ║ • Top Bar: Bankroll display, dealer info, settings                        ║
// ║ • Dealer Area: Dealer's hand and avatar                                   ║
// ║ • Player Area: Player's hand(s)                                           ║
// ║ • Bottom: Action buttons (Hit, Stand, Double, Split)                      ║
// ║ • Swipe-up: Statistics panel                                              ║
// ║                                                                            ║
// ║ Phase 1: Basic structure and card display                                 ║
// ║ Phase 2: Will add full game logic and interactions                        ║
// ║                                                                            ║
// ║ Related Spec: See "Layout Structure" section, lines 306-323               ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct GameView: View {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 STATE PROPERTIES                                                  │
    // │                                                                      │
    // │ Phase 2: GameViewModel is now the single source of truth            │
    // │ All game logic, state, and data flows through this view model       │
    // └─────────────────────────────────────────────────────────────────────┘

    @StateObject private var viewModel = GameViewModel(
        numberOfDecks: 6,          // Ruby dealer default (Phase 3 will make this dynamic)
        startingBankroll: 10000,   // $10,000 AUD default
        minimumBet: 10             // $10 AUD minimum
    )

    // UI state for betting slider
    @State private var betSliderValue: Double = 10

    // Phase 6: Tutorial and Help system
    @ObservedObject private var tutorialManager = TutorialManager.shared
    @State private var showWelcome = TutorialManager.shared.shouldShowWelcome
    @State private var showHelp = false
    @State private var showSettings = false

    // Phase 8: Achievement and progression system
    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var progressionManager = ProgressionManager.shared
    @State private var showingAchievementUnlock: Achievement? = nil
    @State private var showingLevelUp: (newLevel: Int, oldLevel: Int)? = nil

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 PHASE 7: VISUAL SETTINGS                                          │
    // │                                                                      │
    // │ Purpose: Access visual customisation settings (table colour, card   │
    // │          backs, animation preferences, visual effects)              │
    // └─────────────────────────────────────────────────────────────────────┘

    @EnvironmentObject var visualSettings: VisualSettingsManager

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY - Main Layout                                                │
    // └─────────────────────────────────────────────────────────────────────┘

    var body: some View {
        ZStack {
            // ┌─────────────────────────────────────────────────────────────────┐
            // │ 🎨 PHASE 7: CUSTOMISABLE TABLE BACKGROUND                        │
            // │                                                                  │
            // │ Applies selected table felt colour with optional gradient       │
            // │ Settings controlled via VisualSettingsManager                   │
            // └─────────────────────────────────────────────────────────────────┘

            // Table felt background
            if visualSettings.settings.useGradients {
                visualSettings.settings.tableFeltColor.gradient
                    .ignoresSafeArea()
            } else {
                visualSettings.settings.tableFeltColor.color
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Top bar with bankroll and controls
                topBar

                Spacer()

                // Conditional content based on game state
                switch viewModel.gameState {
                case .betting, .gameOver:
                    bettingArea
                case .dealing, .playerTurn, .dealerTurn:
                    // Show game in progress
                    VStack {
                        Spacer()
                        dealerArea
                        Spacer()
                        playerArea
                        Spacer()
                    }
                case .result:
                    // Show result and next hand button
                    VStack {
                        Spacer()
                        dealerArea
                        Spacer()
                        playerArea
                        Spacer()
                        resultArea
                    }
                }

                Spacer()

                // Action buttons (shown during player's turn)
                if viewModel.gameState == .playerTurn {
                    actionButtonsArea
                }

                // Swipe indicator
                swipeIndicator
            }
            .padding()

            // Phase 6: Tutorial overlay
            if tutorialManager.isTutorialActive {
                TutorialOverlayView()
            }

            // Phase 6: Contextual hints
            if let hint = tutorialManager.currentHint {
                ContextualHintView(hint: hint) {
                    tutorialManager.dismissHint()
                }
            }
        }
        .fullScreenCover(isPresented: $showWelcome) {
            TutorialWelcomeView(isPresented: $showWelcome)
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        // Phase 8: Achievement unlock overlay
        .overlay {
            if let achievement = showingAchievementUnlock {
                AchievementUnlockView(achievement: achievement) {
                    showingAchievementUnlock = nil
                    checkForNextUnlock()
                }
            }
        }
        // Phase 8: Level up overlay
        .overlay {
            if let levelUp = showingLevelUp {
                LevelUpView(
                    newLevel: levelUp.newLevel,
                    rankTitle: progressionManager.rankTitle,
                    rankEmoji: progressionManager.rankEmoji
                ) {
                    showingLevelUp = nil
                    checkForNextUnlock()
                }
            }
        }
        // Phase 8: Check for unlocked achievements
        .onAppear {
            checkForNextUnlock()
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏆 PHASE 8: ACHIEVEMENT UNLOCK CHECKING                              │
    // │                                                                      │
    // │ Purpose: Check for newly unlocked achievements or level-ups         │
    // │ Shows celebration overlays when achievements or levels are earned   │
    // └─────────────────────────────────────────────────────────────────────┘

    private func checkForNextUnlock() {
        // Priority: Show level-ups first, then achievements
        if let levelUp = progressionManager.getNextLevelUp() {
            showingLevelUp = levelUp
        } else if let achievement = achievementManager.getNextUnlockedAchievement() {
            showingAchievementUnlock = achievement
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📱 TOP BAR - Bankroll, Dealer Info, Settings                        │
    // │                                                                      │
    // │ Business Logic: Bankroll is always visible in large, readable       │
    // │ format. Gold gradient makes it feel valuable and important.         │
    // └─────────────────────────────────────────────────────────────────────┘

    private var topBar: some View {
        HStack {
            // Bankroll display - left side
            bankrollDisplay

            Spacer()

            // Help button (Phase 6)
            Button(action: {
                showHelp = true
            }) {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(.info)
            }
            .tutorialSpotlight(.helpButton)

            // Settings button (Phase 6)
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.mediumGrey)
            }
            .tutorialSpotlight(.settingsButton)
        }
        .padding(.top, 8)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💰 BANKROLL DISPLAY                                                  │
    // │                                                                      │
    // │ Business Logic: Shows current balance with gold gradient            │
    // │ Format: $10,250 (comma thousands separator, no decimals)            │
    // │ "AUD" label clarifies currency for Australian market                │
    // └─────────────────────────────────────────────────────────────────────┘

    private var bankrollDisplay: some View {
        HStack(spacing: 8) {
            // Chip icon
            Image(systemName: "dollarsign.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.chipGradient)

            VStack(alignment: .leading, spacing: 2) {
                // Amount
                Text(formatCurrency(viewModel.bankroll))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.chipGradient)

                // Currency label
                Text("AUD")
                    .font(.caption)
                    .foregroundColor(.mediumGrey)
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 DEALER AREA                                                       │
    // │                                                                      │
    // │ Business Logic: Shows dealer's cards and hand total                 │
    // │ During gameplay, one card is face-down (hole card)                  │
    // └─────────────────────────────────────────────────────────────────────┘

    private var dealerArea: some View {
        VStack(spacing: 12) {
            // Hand total (or "?" if hole card hidden)
            Text(dealerDisplayTotal)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            // Dealer's cards
            HStack(spacing: -30) {
                // Visible card(s)
                ForEach(viewModel.dealerHand.cards) { card in
                    CardView(card: card, size: .standard)
                }

                // Hole card (face down during player turn)
                if viewModel.gameState == .playerTurn || viewModel.gameState == .dealing,
                   let holeCard = viewModel.dealerHoleCard {
                    CardView(card: holeCard, isFaceDown: true, size: .standard)
                }
            }

            // "Dealer" label
            Text("Dealer")
                .font(.headline)
                .foregroundColor(.mediumGrey)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 PLAYER AREA                                                       │
    // │                                                                      │
    // │ Business Logic: Shows player's cards and hand total                 │
    // │ Highlights blackjack in gold, bust in red                           │
    // └─────────────────────────────────────────────────────────────────────┘

    private var playerArea: some View {
        VStack(spacing: 12) {
            // "Your Hand" label (or "Hand 1 of 3" for splits)
            Text(playerHandLabel)
                .font(.headline)
                .foregroundColor(.mediumGrey)

            // Player's cards
            HStack(spacing: -30) {
                ForEach(viewModel.currentHand.cards) { card in
                    CardView(card: card, size: .standard)
                }
            }

            // Hand total
            Text(viewModel.currentHand.displayString)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(handTotalColor)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 ACTION BUTTONS AREA                                               │
    // │                                                                      │
    // │ Placeholder for Phase 2 - will contain Hit, Stand, Double, Split    │
    // └─────────────────────────────────────────────────────────────────────┘

    private var actionButtonsArea: some View {
        VStack(spacing: 16) {
            // Primary row: Hit, Stand, Double
            HStack(spacing: 12) {
                if viewModel.canHit {
                    actionButton(title: "Hit", color: .success) {
                        viewModel.hit()
                    }
                }

                if viewModel.canStand {
                    actionButton(title: "Stand", color: .info) {
                        viewModel.stand()
                    }
                }

                if viewModel.canDoubleDown {
                    actionButton(title: "Double", color: .warning) {
                        viewModel.doubleDown()
                    }
                }
            }

            // Secondary row: Split, Surrender
            HStack(spacing: 12) {
                if viewModel.canSplit {
                    actionButton(title: "Split", color: .info) {
                        viewModel.split()
                    }
                }

                if viewModel.canSurrender {
                    actionButton(title: "Surrender", color: .bustHighlight) {
                        viewModel.surrender()
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔼 SWIPE INDICATOR                                                   │
    // │                                                                      │
    // │ Visual cue that user can swipe up for statistics panel              │
    // └─────────────────────────────────────────────────────────────────────┘

    private var swipeIndicator: some View {
        VStack(spacing: 4) {
            Rectangle()
                .fill(Color.mediumGrey)
                .frame(width: 40, height: 4)
                .cornerRadius(2)

            Text("Swipe up for stats")
                .font(.caption2)
                .foregroundColor(.mediumGrey)
        }
        .padding(.bottom, 8)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💰 BETTING AREA - Bet Selection Interface                           │
    // │                                                                      │
    // │ Business Logic: Player selects bet amount before each hand          │
    // │ Shows: Slider, bet presets, confirm button                          │
    // │ Special case: Game over shows bankruptcy message and reset button   │
    // └─────────────────────────────────────────────────────────────────────┘

    private var bettingArea: some View {
        VStack(spacing: 24) {
            if viewModel.gameState == .gameOver {
                // Bankruptcy screen
                VStack(spacing: 16) {
                    Text("💸 Bankrupt!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.bustHighlight)

                    Text("Your balance ($\(formatCurrency(viewModel.bankroll))) is below the minimum bet ($\(formatCurrency(viewModel.minimumBet)))")
                        .font(.body)
                        .foregroundColor(.mediumGrey)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: {
                        viewModel.resetBankroll(to: 10000)
                    }) {
                        Text("Reset Bankroll to $10,000")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: 280)
                            .padding(.vertical, 16)
                            .background(Color.success)
                            .cornerRadius(12)
                    }
                }
            } else {
                // Normal betting screen
                VStack(spacing: 24) {
                    // Bet amount display
                    Text("$\(formatCurrency(betSliderValue))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.chipGradient)

                    // Bet slider
                    VStack(spacing: 8) {
                        Slider(value: $betSliderValue,
                               in: viewModel.minimumBet...viewModel.bankroll,
                               step: 5)
                            .accentColor(Color.info)

                        HStack {
                            Text("$\(formatCurrency(viewModel.minimumBet))")
                                .font(.caption)
                                .foregroundColor(.mediumGrey)
                            Spacer()
                            Text("$\(formatCurrency(viewModel.bankroll))")
                                .font(.caption)
                                .foregroundColor(.mediumGrey)
                        }
                    }
                    .padding(.horizontal)

                    // Bet presets
                    HStack(spacing: 12) {
                        betPresetButton(title: "Min", amount: viewModel.minimumBet)
                        betPresetButton(title: "25%", amount: viewModel.bankroll * 0.25)
                        betPresetButton(title: "50%", amount: viewModel.bankroll * 0.5)
                        betPresetButton(title: "Max", amount: viewModel.bankroll)
                    }
                    .padding(.horizontal)

                    // Confirm bet button
                    Button(action: {
                        viewModel.placeBet(betSliderValue)
                    }) {
                        Text("Place Bet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(betSliderValue >= viewModel.minimumBet ? Color.success : Color.darkGrey)
                            .cornerRadius(12)
                    }
                    .disabled(betSliderValue < viewModel.minimumBet)
                    .padding(.horizontal)
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏆 RESULT AREA - Win/Loss Display & Next Hand                       │
    // │                                                                      │
    // │ Business Logic: Shows outcome message and allows starting next hand │
    // └─────────────────────────────────────────────────────────────────────┘

    private var resultArea: some View {
        VStack(spacing: 16) {
            // Result message
            Text(viewModel.resultMessage)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()

            // Next hand button
            Button(action: {
                // Reset bet slider to last bet
                betSliderValue = viewModel.lastBet
                viewModel.nextHand()
            }) {
                Text("Next Hand")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 16)
                    .background(Color.info)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 HELPER VIEWS                                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    private func betPresetButton(title: String, amount: Double) -> some View {
        Button(action: {
            betSliderValue = min(amount, viewModel.bankroll)
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.darkGrey)
                .cornerRadius(8)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 PHASE 7: ACTION BUTTON WITH FEEDBACK                              │
    // │                                                                      │
    // │ Purpose: Styled button with audio/haptic feedback on tap            │
    // │ All game action buttons trigger multi-sensory feedback              │
    // └─────────────────────────────────────────────────────────────────────┘

    private func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            // Phase 7: Play button tap feedback (audio + haptic)
            GameAnimationCoordinator().buttonTapFeedback()

            // Execute the action
            action()
        } label: {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .cornerRadius(12)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🧮 COMPUTED PROPERTIES                                               │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Returns appropriate colour for hand total display
    private var handTotalColor: Color {
        if viewModel.currentHand.isBlackjack {
            return .blackjackGlow
        } else if viewModel.currentHand.isBust {
            return .bustHighlight
        } else if viewModel.currentHand.isSoft {
            return .info
        } else {
            return .white
        }
    }

    /// Dealer display total (shows "?" when hole card is hidden)
    private var dealerDisplayTotal: String {
        if viewModel.gameState == .playerTurn || viewModel.gameState == .dealing {
            // Only show upcard value during player's turn
            if let upcard = viewModel.dealerUpcard {
                return "\(upcard.value)"
            }
            return "?"
        } else {
            // Show full hand total after player's turn
            return viewModel.dealerHand.displayString
        }
    }

    /// Player hand label (shows hand number for splits)
    private var playerHandLabel: String {
        if viewModel.playerHands.count > 1 {
            return "Hand \(viewModel.currentHandIndex + 1) of \(viewModel.playerHands.count)"
        } else {
            return "Your Hand"
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🛠️ UTILITY FUNCTIONS                                                 │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Formats currency with AUD symbol and comma separators
    /// Example: 10250 → "$10,250"
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                 ║
// ║                                                                            ║
// ║ Xcode preview for design iteration                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("Game View - Betting State") {
    GameView()
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ ✅ PHASE 2 COMPLETE                                                        ║
// ║                                                                            ║
// ║ Implemented in Phase 2:                                                   ║
// ║ ✅ GameViewModel integration with @StateObject                            ║
// ║ ✅ Action button logic (Hit, Stand, Double, Split, Surrender)             ║
// ║ ✅ Betting UI with slider and presets                                     ║
// ║ ✅ Win/loss result display with next hand flow                            ║
// ║ ✅ Handle multiple hands (split support)                                  ║
// ║ ✅ Bankruptcy handling with reset option                                  ║
// ║ ✅ State-based UI (betting → playing → result)                            ║
// ║                                                                            ║
// ║ Phase 3+ Features:                                                         ║
// ║ • Dealer avatars and personality-based rules                              ║
// ║ • Card dealing animations                                                 ║
// ║ • Dealer card flip animation for hole card reveal                         ║
// ║ • Swipe-up gesture for statistics panel                                   ║
// ║ • Strategy hints (green/yellow pulses on buttons)                         ║
// ║ • Sound effects and haptic feedback                                       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
