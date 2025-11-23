//
//  Hand.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🃏 HAND MODEL                                                              ║
// ║                                                                            ║
// ║ Purpose: Represents a player's or dealer's hand of cards and evaluates    ║
// ║          the total value with proper soft/hard ace handling               ║
// ║                                                                            ║
// ║ Business Context: A hand is a collection of cards. The tricky part is     ║
// ║                   handling Aces, which can be worth 1 or 11. A "soft"     ║
// ║                   hand contains an Ace counted as 11. A "hard" hand has   ║
// ║                   all Aces counted as 1 (or no Aces at all).              ║
// ║                                                                            ║
// ║ Critical Concepts:                                                         ║
// ║ • Soft Hand: Contains an Ace as 11 without busting (e.g., A-6 = Soft 17) ║
// ║ • Hard Hand: All Aces as 1, or no flexible aces (e.g., A-6-10 = Hard 17) ║
// ║ • Blackjack: Exactly 21 with first two cards (Ace + 10-value card)       ║
// ║ • Bust: Total exceeds 21                                                  ║
// ║                                                                            ║
// ║ Used By: • GameViewModel (tracks player and dealer hands)                 ║
// ║          • StrategyEngine (determines optimal play)                       ║
// ║          • GameView (displays hand total and status)                      ║
// ║                                                                            ║
// ║ Related Spec: See lines 472-498 for hand evaluation pseudocode            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

struct Hand: Identifiable, Codable {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🆔 CORE PROPERTIES                                                   │
    // └─────────────────────────────────────────────────────────────────────┘

    let id: UUID
    private(set) var cards: [Card]

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISERS                                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    init(cards: [Card] = []) {
        self.id = UUID()
        self.cards = cards
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 CARD MANAGEMENT                                                   │
    // │                                                                      │
    // │ Methods to add cards to the hand during gameplay                    │
    // └─────────────────────────────────────────────────────────────────────┘

    mutating func addCard(_ card: Card) {
        cards.append(card)
    }

    mutating func addCards(_ newCards: [Card]) {
        cards.append(contentsOf: newCards)
    }

    mutating func clear() {
        cards.removeAll()
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 HAND EVALUATION - The Heart of Blackjack Logic                   │
    // │                                                                      │
    // │ Purpose: Calculates the hand's value with proper ace handling       │
    // │                                                                      │
    // │ Algorithm:                                                           │
    // │ 1. Start by counting all aces as 11 (their default value in Card)   │
    // │ 2. Add up all card values                                           │
    // │ 3. If total > 21 and we have aces, convert aces from 11→1 one at a  │
    // │    time until we're ≤21 or out of aces                              │
    // │ 4. A hand is "soft" if it has an ace still counted as 11            │
    // │                                                                      │
    // │ Examples:                                                            │
    // │ • A♠ 6♥ = 17 (soft) - Ace is 11, can still hit without busting      │
    // │ • A♠ 6♥ K♦ = 17 (hard) - Ace becomes 1, total is 1+6+10=17          │
    // │ • A♠ A♥ 9♣ = 21 (hard) - One ace=11, one ace=1, total is 11+1+9=21  │
    // │ • K♠ Q♥ = 20 (hard) - No aces, just 10+10                           │
    // │ • A♠ K♥ = 21 (blackjack) - Natural 21 with two cards                │
    // │                                                                      │
    // │ Returns: (total: Int, isSoft: Bool, isBlackjack: Bool)              │
    // │                                                                      │
    // │ Modification: If adding new card types or rules, adjust logic here  │
    // └─────────────────────────────────────────────────────────────────────┘

    var evaluation: (total: Int, isSoft: Bool, isBlackjack: Bool) {
        guard !cards.isEmpty else {
            return (0, false, false)
        }

        var total = 0
        var aceCount = 0

        // First pass: sum all card values, count aces
        for card in cards {
            total += card.value  // Remember: Card.value returns 11 for aces
            if card.rank == .ace {
                aceCount += 1
            }
        }

        // Second pass: convert aces from 11 to 1 if needed to avoid bust
        // Each conversion reduces total by 10 (11-1=10)
        while total > 21 && aceCount > 0 {
            total -= 10
            aceCount -= 1
        }

        // Determine if hand is soft:
        // A hand is soft if it contains an ace still counted as 11
        // (indicated by aceCount > 0 after our conversions)
        let isSoft = (aceCount > 0 && total <= 21)

        // Blackjack is exactly 21 with first two cards
        let isBlackjack = (cards.count == 2 && total == 21)

        return (total, isSoft, isBlackjack)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 CONVENIENT COMPUTED PROPERTIES                                    │
    // │                                                                      │
    // │ These extract specific values from the evaluation tuple             │
    // │ Makes code more readable: hand.total vs hand.evaluation.total       │
    // └─────────────────────────────────────────────────────────────────────┘

    var total: Int {
        return evaluation.total
    }

    var isSoft: Bool {
        return evaluation.isSoft
    }

    var isBlackjack: Bool {
        return evaluation.isBlackjack
    }

    var isBust: Bool {
        return total > 21
    }

    var isEmpty: Bool {
        return cards.isEmpty
    }

    var count: Int {
        return cards.count
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎮 GAMEPLAY RULE CHECKS                                              │
    // │                                                                      │
    // │ These methods determine which actions are available to the player   │
    // │ Based on standard blackjack rules + dealer-specific variations      │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Can this hand be split?
    /// Rule: Two cards of the same rank (e.g., 8♠ 8♥ or K♠ Q♦)
    /// Note: Some dealers allow re-splitting, others don't - checked elsewhere
    func canSplit() -> Bool {
        guard cards.count == 2 else { return false }
        return cards[0].rank == cards[1].rank
    }

    /// Can the player double down on this hand?
    /// Rule: Typically allowed on first two cards only
    /// Some dealers restrict to totals of 9, 10, or 11 only - checked elsewhere
    func canDouble() -> Bool {
        return cards.count == 2
    }

    /// Is this a pair of aces?
    /// Special case: Many dealers have special rules for splitting aces
    func isPairOfAces() -> Bool {
        guard cards.count == 2 else { return false }
        return cards[0].rank == .ace && cards[1].rank == .ace
    }

    /// Does this hand contain an ace?
    /// Useful for strategy calculations
    func containsAce() -> Bool {
        return cards.contains { $0.rank == .ace }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 DISPLAY HELPERS                                                   │
    // │                                                                      │
    // │ Methods to generate user-friendly strings for the UI                │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Returns display string for hand total
    /// Examples: "21", "Soft 17", "Blackjack!", "BUST"
    var displayString: String {
        if isBust {
            return "BUST"
        } else if isBlackjack {
            return "Blackjack!"
        } else if isSoft {
            return "Soft \(total)"
        } else {
            return "\(total)"
        }
    }

    /// Returns just the cards as a string (for debugging)
    /// Example: "A♠ 6♥" or "K♦ Q♣ 5♠"
    var cardsString: String {
        return cards.map { $0.displayString }.joined(separator: " ")
    }

    /// Full description combining cards and total
    /// Example: "A♠ 6♥ (Soft 17)"
    var description: String {
        return "\(cardsString) (\(displayString))"
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🧪 TESTING HELPERS                                                         ║
// ║                                                                            ║
// ║ Convenience methods for unit tests                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Hand {
    #if DEBUG
    /// Creates a hand from shorthand notation
    /// Example: Hand.from(["A♠", "6♥"]) creates Ace of Spades + 6 of Hearts
    static func from(_ strings: [String]) -> Hand {
        let cards = strings.compactMap { Card.from(string: $0) }
        return Hand(cards: cards)
    }
    #endif
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Creating a hand:                                                           ║
// ║   var hand = Hand()                                                        ║
// ║   hand.addCard(Card(rank: .ace, suit: .spades))                           ║
// ║   hand.addCard(Card(rank: .six, suit: .hearts))                           ║
// ║                                                                            ║
// ║ Evaluating a hand:                                                         ║
// ║   print(hand.total)         // 17                                          ║
// ║   print(hand.isSoft)        // true                                        ║
// ║   print(hand.displayString) // "Soft 17"                                   ║
// ║                                                                            ║
// ║ Checking rules:                                                            ║
// ║   if hand.canDouble() {                                                    ║
// ║       // Show double down button                                           ║
// ║   }                                                                         ║
// ║                                                                            ║
// ║ Testing:                                                                   ║
// ║   let testHand = Hand.from(["A♠", "A♥", "9♣"])                             ║
// ║   print(testHand.total)  // 21                                             ║
// ║   print(testHand.isSoft) // false (one ace is 11, other is 1)             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
