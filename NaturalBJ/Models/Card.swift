//
//  Card.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 CARD MODEL                                                              ║
// ║                                                                            ║
// ║ Purpose: Represents a single playing card in the blackjack game           ║
// ║ Business Context: Cards are the core unit of gameplay. Each card has a    ║
// ║                   rank (2-Ace), suit (♠♥♦♣), and calculated value for     ║
// ║                   hand evaluation. Aces can be 1 or 11 (handled by Hand). ║
// ║                                                                            ║
// ║ Used By: • Deck (creates and manages cards)                               ║
// ║          • Hand (evaluates totals)                                        ║
// ║          • GameViewModel (displays to player)                             ║
// ║          • CardView (renders visual representation)                       ║
// ║                                                                            ║
// ║ Related Spec: See "Card Logic" section in blackjack_app_spec.md          ║
// ║               Lines 459-498 define card values and evaluation logic       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

struct Card: Identifiable, Codable, Equatable, Hashable {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🆔 CORE PROPERTIES                                                   │
    // │ These define the card's identity in the deck                        │
    // └─────────────────────────────────────────────────────────────────────┘

    let id: UUID
    let rank: Rank
    let suit: Suit

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                       │
    // │                                                                      │
    // │ Creates a new card with specified rank and suit                     │
    // │ Generates a unique ID for SwiftUI list rendering                    │
    // └─────────────────────────────────────────────────────────────────────┘

    init(rank: Rank, suit: Suit) {
        self.id = UUID()
        self.rank = rank
        self.suit = suit
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 COMPUTED VALUE                                                    │
    // │                                                                      │
    // │ Business Logic: Returns numerical value for hand calculation        │
    // │ • Number cards (2-10): Face value                                   │
    // │ • Face cards (J, Q, K): Always 10                                   │
    // │ • Aces: Always returns 11 here; Hand class handles soft/hard logic  │
    // │                                                                      │
    // │ Why 11 for Aces? The Hand evaluation algorithm (in Hand.swift)      │
    // │ starts with all aces as 11, then converts them to 1 as needed       │
    // │ to avoid busting. This simplifies the evaluation logic.             │
    // │                                                                      │
    // │ Modification Note: Don't change ace value here. If you need to      │
    // │ adjust soft/hard ace handling, modify Hand.evaluateHand() instead.  │
    // └─────────────────────────────────────────────────────────────────────┘

    var value: Int {
        switch rank {
        case .two:   return 2
        case .three: return 3
        case .four:  return 4
        case .five:  return 5
        case .six:   return 6
        case .seven: return 7
        case .eight: return 8
        case .nine:  return 9
        case .ten, .jack, .queen, .king: return 10
        case .ace:   return 11  // Soft/hard ace handling is in Hand evaluation
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 DISPLAY PROPERTIES                                                │
    // │                                                                      │
    // │ Provides user-friendly strings for UI rendering                     │
    // │ Used by CardView to display rank and suit symbols                   │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Display string for the card (e.g., "A♠", "K♥", "10♦")
    var displayString: String {
        return "\(rank.symbol)\(suit.symbol)"
    }

    /// Colour for rendering (red for hearts/diamonds, black for spades/clubs)
    var color: CardColor {
        return suit.color
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🃏 RANK ENUMERATION                                                        ║
// ║                                                                            ║
// ║ Purpose: Defines all possible card ranks in blackjack                     ║
// ║ Business Context: Standard 52-card deck has 13 ranks. We use CaseIterable ║
// ║                   to easily generate all cards when creating a deck.      ║
// ║                                                                            ║
// ║ Modification: If you want to add jokers or special cards for a variant,  ║
// ║               add new cases here and update value computation in Card.    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum Rank: String, Codable, CaseIterable {
    case two   = "2"
    case three = "3"
    case four  = "4"
    case five  = "5"
    case six   = "6"
    case seven = "7"
    case eight = "8"
    case nine  = "9"
    case ten   = "10"
    case jack  = "J"
    case queen = "Q"
    case king  = "K"
    case ace   = "A"

    /// Symbol for display in UI
    var symbol: String {
        return self.rawValue
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 SUIT ENUMERATION                                                        ║
// ║                                                                            ║
// ║ Purpose: Defines the four suits in a standard deck                        ║
// ║ Business Context: Suits don't affect gameplay in blackjack (unlike poker),║
// ║                   but we track them for visual variety and potential      ║
// ║                   future features (e.g., "suited blackjack pays 2:1"      ║
// ║                   bonus rule in Maverick dealer).                         ║
// ║                                                                            ║
// ║ Australian English Note: "Spades" not "Shovels", "Clubs" not "Clovers"   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum Suit: String, Codable, CaseIterable {
    case spades   = "♠"
    case hearts   = "♥"
    case diamonds = "♦"
    case clubs    = "♣"

    /// Unicode symbol for display
    var symbol: String {
        return self.rawValue
    }

    /// Color for rendering the suit
    var color: CardColor {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .spades, .clubs:
            return .black
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎨 CARD COLOR                                                              ║
// ║                                                                            ║
// ║ Purpose: Defines the two card colors for rendering                        ║
// ║ Business Context: Used by CardView to set text color on cards.            ║
// ║                   Red suits (♥♦) are rendered in red (#FF3B30 per spec),  ║
// ║                   black suits (♠♣) in black.                              ║
// ║                                                                            ║
// ║ Color Blind Mode: Future enhancement could add high-contrast patterns     ║
// ║                   instead of relying solely on color distinction.         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum CardColor {
    case red
    case black
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🧪 CONVENIENCE EXTENSIONS                                                  ║
// ║                                                                            ║
// ║ Purpose: Helper methods for testing and debugging                         ║
// ║ Business Context: These make it easier to create specific cards in tests  ║
// ║                   and to describe cards in logs/debugging.                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Card {
    /// Creates a card from shorthand notation (e.g., "A♠", "K♥")
    /// Used primarily in unit tests for easy card creation
    static func from(string: String) -> Card? {
        guard string.count >= 2 else { return nil }

        let rankString = String(string.dropLast())
        let suitString = String(string.last!)

        guard let rank = Rank.allCases.first(where: { $0.rawValue == rankString }),
              let suit = Suit.allCases.first(where: { $0.rawValue == suitString }) else {
            return nil
        }

        return Card(rank: rank, suit: suit)
    }

    /// Human-readable description for debugging
    var description: String {
        return displayString
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Creating a card:                                                           ║
// ║   let aceOfSpades = Card(rank: .ace, suit: .spades)                       ║
// ║   print(aceOfSpades.value)         // 11                                  ║
// ║   print(aceOfSpades.displayString) // "A♠"                                ║
// ║                                                                            ║
// ║ Testing helper:                                                            ║
// ║   let card = Card.from(string: "K♥")  // King of Hearts                   ║
// ║                                                                            ║
// ║ Iteration for deck creation:                                              ║
// ║   for rank in Rank.allCases {                                             ║
// ║       for suit in Suit.allCases {                                         ║
// ║           let card = Card(rank: rank, suit: suit)                         ║
// ║           // Creates all 52 cards                                         ║
// ║       }                                                                    ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
