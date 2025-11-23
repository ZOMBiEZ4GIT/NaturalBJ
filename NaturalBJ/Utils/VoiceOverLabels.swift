// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ VoiceOverLabels.swift                                                         ║
// ║                                                                               ║
// ║ Comprehensive accessibility labels and hints for VoiceOver.                 ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • VoiceOver labels make the app usable for blind and low-vision users       ║
// ║ • Clear, concise descriptions improve user experience                        ║
// ║ • Hints provide guidance on interactive elements                             ║
// ║ • Essential for App Store accessibility compliance                           ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Static utility struct (no instantiation needed)                            ║
// ║ • Comprehensive labels for all game elements                                 ║
// ║ • Context-aware descriptions                                                 ║
// ║ • Consistent terminology throughout                                          ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ VoiceOverLabels                                                               │
// │                                                                               │
// │ Provides accessibility labels and hints for all game elements.              │
// └──────────────────────────────────────────────────────────────────────────────┘
struct VoiceOverLabels {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CARD LABELS                                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Get full description of a card
    /// - Parameter card: Card to describe
    /// - Returns: VoiceOver-friendly description
    static func cardDescription(_ card: Card) -> String {
        let rank = rankName(card.rank)
        let suit = suitName(card.suit)
        return "\(rank) of \(suit)"
    }

    /// Get rank name for VoiceOver
    private static func rankName(_ rank: Rank) -> String {
        switch rank {
        case .ace: return "Ace"
        case .two: return "Two"
        case .three: return "Three"
        case .four: return "Four"
        case .five: return "Five"
        case .six: return "Six"
        case .seven: return "Seven"
        case .eight: return "Eight"
        case .nine: return "Nine"
        case .ten: return "Ten"
        case .jack: return "Jack"
        case .queen: return "Queen"
        case .king: return "King"
        }
    }

    /// Get suit name for VoiceOver
    private static func suitName(_ suit: Suit) -> String {
        switch suit {
        case .hearts: return "Hearts"
        case .diamonds: return "Diamonds"
        case .clubs: return "Clubs"
        case .spades: return "Spades"
        }
    }

    /// Describe a face-down card
    static let faceDownCard = "Face down card"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ HAND LABELS                                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Describe a hand for VoiceOver
    /// - Parameter hand: Hand to describe
    /// - Returns: Full hand description
    static func handDescription(_ hand: Hand) -> String {
        let cards = hand.cards.map { cardDescription($0) }.joined(separator: ", ")
        let value = hand.isSoft ? "soft \(hand.value)" : "\(hand.value)"
        var description = "Hand with \(hand.cards.count) cards: \(cards). Value: \(value)"

        if hand.isBlackjack {
            description += ". Blackjack!"
        } else if hand.isBusted {
            description += ". Busted"
        }

        return description
    }

    /// Describe hand value
    /// - Parameters:
    ///   - value: Hand value
    ///   - isSoft: Whether value is soft
    /// - Returns: Value description
    static func handValueDescription(value: Int, isSoft: Bool) -> String {
        if isSoft {
            return "Soft \(value)"
        } else {
            return "\(value)"
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ACTION BUTTON LABELS                                                      │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let hitButton = (
        label: "Hit",
        hint: "Draw another card for your hand"
    )

    static let standButton = (
        label: "Stand",
        hint: "Keep your current hand and end your turn"
    )

    static let doubleButton = (
        label: "Double Down",
        hint: "Double your bet and receive exactly one more card"
    )

    static let splitButton = (
        label: "Split",
        hint: "Split your pair into two separate hands"
    )

    static let surrenderButton = (
        label: "Surrender",
        hint: "Forfeit half your bet and end the hand"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BETTING LABELS                                                            │
    // └──────────────────────────────────────────────────────────────────────────┘

    static func betAmountLabel(_ amount: Double) -> String {
        "Current bet: \(Int(amount)) dollars"
    }

    static let increaseBetButton = (
        label: "Increase Bet",
        hint: "Raise your bet amount by one chip"
    )

    static let decreaseBetButton = (
        label: "Decrease Bet",
        hint: "Lower your bet amount by one chip"
    )

    static let minBetButton = (
        label: "Minimum Bet",
        hint: "Set bet to table minimum"
    )

    static let maxBetButton = (
        label: "Maximum Bet",
        hint: "Set bet to table maximum"
    )

    static let dealButton = (
        label: "Deal",
        hint: "Place your bet and start the hand"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ GAME STATE LABELS                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    static func gameStateDescription(_ state: GameState) -> String {
        switch state {
        case .betting:
            return "Place your bet"
        case .dealing:
            return "Dealing cards"
        case .playerTurn:
            return "Your turn. Choose an action"
        case .dealerTurn:
            return "Dealer's turn"
        case .result:
            return "Hand complete. View results"
        case .gameOver:
            return "Game over"
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ RESULT LABELS                                                             │
    // └──────────────────────────────────────────────────────────────────────────┘

    static func resultDescription(_ result: HandOutcome, payout: Double? = nil) -> String {
        var description: String

        switch result {
        case .win:
            description = "You won"
        case .loss:
            description = "You lost"
        case .push:
            description = "Push. It's a tie"
        case .blackjack:
            description = "Blackjack! You won"
        case .bust:
            description = "Bust. You lost"
        case .surrender:
            description = "Surrendered. Half bet returned"
        }

        if let payout = payout, payout > 0 {
            description += ". Payout: \(Int(payout)) dollars"
        }

        return description
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEALER LABELS                                                             │
    // └──────────────────────────────────────────────────────────────────────────┘

    static func dealerLabel(_ dealer: Dealer) -> String {
        dealer.name
    }

    static func dealerDescription(_ dealer: Dealer) -> String {
        "\(dealer.name). \(dealer.personality). \(dealer.tagline)"
    }

    static let dealerSelectionHint = "Tap to select this dealer and view their rules"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ STATISTICS LABELS                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    static func bankrollLabel(_ bankroll: Double) -> String {
        "Bankroll: \(Int(bankroll)) dollars"
    }

    static func winRateLabel(_ winRate: Double) -> String {
        "Win rate: \(Int(winRate * 100)) percent"
    }

    static func handsPlayedLabel(_ count: Int) -> String {
        "Hands played: \(count)"
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SETTINGS LABELS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let settingsButton = (
        label: "Settings",
        hint: "Open app settings and preferences"
    )

    static let helpButton = (
        label: "Help",
        hint: "View game rules and how to play"
    )

    static let statisticsButton = (
        label: "Statistics",
        hint: "View your game statistics and history"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ VISUAL CUSTOMIZATION LABELS                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    static func tableFeltColorLabel(_ color: TableFeltColor) -> String {
        let premium = color.isPremium ? " (Premium)" : ""
        return "\(color.name) table felt\(premium)"
    }

    static func cardBackDesignLabel(_ design: CardBackDesign) -> String {
        let premium = design.isPremium ? " (Premium)" : ""
        return "\(design.name) card back\(premium)"
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ AUDIO/HAPTIC LABELS                                                       │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let soundEffectsToggle = (
        label: "Sound Effects",
        hint: "Toggle sound effects on or off"
    )

    static let hapticsToggle = (
        label: "Haptic Feedback",
        hint: "Toggle haptic feedback on or off"
    )

    static func volumeLabel(_ volume: Float) -> String {
        "Volume: \(Int(volume * 100)) percent"
    }

    static func hapticIntensityLabel(_ intensity: HapticIntensity) -> String {
        "Haptic intensity: \(intensity.rawValue)"
    }
}
