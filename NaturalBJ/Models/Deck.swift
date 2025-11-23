//
//  Deck.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 DECK / SHOE MODEL                                                       ║
// ║                                                                            ║
// ║ Purpose: Manages the shoe of cards used in blackjack gameplay             ║
// ║ Business Context: In casino blackjack, multiple decks are combined into   ║
// ║                   a "shoe" to make card counting harder. Our app simulates ║
// ║                   this with 1-8 decks depending on the dealer's rules.    ║
// ║                                                                            ║
// ║ Key Concepts:                                                              ║
// ║ • Shoe: The container holding multiple decks (1-8 decks per dealer rules) ║
// ║ • Penetration: How many cards are dealt before reshuffling (75% standard) ║
// ║ • Cut card: Marker indicating when to reshuffle (at 75% penetration)      ║
// ║                                                                            ║
// ║ Used By: • DeckManager (service that coordinates dealing)                 ║
// ║          • GameViewModel (requests cards, checks reshuffle needs)         ║
// ║                                                                            ║
// ║ Related Spec: See "Card Logic" section, lines 461-464                     ║
// ║               "Deck Composition: 52 cards per deck, multiple decks based  ║
// ║                on dealer rules, reshuffled at 75% penetration"            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

class Deck: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📚 CORE PROPERTIES                                                   │
    // └─────────────────────────────────────────────────────────────────────┘

    /// All cards currently in the shoe (undealt)
    @Published private(set) var cards: [Card]

    /// Cards that have been dealt (for tracking/debugging)
    @Published private(set) var dealtCards: [Card] = []

    /// Number of complete 52-card decks in this shoe
    let numberOfDecks: Int

    /// Original count of cards when shoe was fresh (before any dealt)
    private let originalCount: Int

    /// Penetration threshold (0.0 to 1.0) - when to reshuffle
    /// Default: 0.75 means reshuffle when 75% of cards have been dealt
    let penetrationThreshold: Double

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                       │
    // │                                                                      │
    // │ Parameters:                                                          │
    // │ • numberOfDecks: How many 52-card decks to combine (1-8 typical)    │
    // │ • penetrationThreshold: When to reshuffle (0.75 = 75% is standard)  │
    // │                                                                      │
    // │ Business Logic: Creates a fresh shoe with all cards, then shuffles  │
    // │ Example: 6-deck shoe = 6 × 52 = 312 cards total                     │
    // └─────────────────────────────────────────────────────────────────────┘

    init(numberOfDecks: Int = 6, penetrationThreshold: Double = 0.75) {
        self.numberOfDecks = numberOfDecks
        self.penetrationThreshold = penetrationThreshold

        // Create all cards for the shoe
        var allCards: [Card] = []
        for _ in 0..<numberOfDecks {
            for rank in Rank.allCases {
                for suit in Suit.allCases {
                    allCards.append(Card(rank: rank, suit: suit))
                }
            }
        }

        self.cards = allCards
        self.originalCount = allCards.count

        // Shuffle immediately on creation
        shuffle()
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔀 SHUFFLE METHOD - Fisher-Yates Algorithm                          │
    // │                                                                      │
    // │ Business Purpose: Randomises the order of cards to ensure fair play │
    // │                                                                      │
    // │ Algorithm: Fisher-Yates (Knuth) Shuffle                             │
    // │ • Proven to be unbiased (every permutation equally likely)          │
    // │ • O(n) time complexity - efficient even for 8-deck shoes            │
    // │ • Used in professional casino shuffle machines                      │
    // │                                                                      │
    // │ When Called:                                                         │
    // │ • On deck initialisation (fresh shoe)                               │
    // │ • When penetration threshold is reached                             │
    // │ • When dealer is switched (new rules = new shoe)                    │
    // │                                                                      │
    // │ How Fisher-Yates Works:                                              │
    // │ 1. Start at the end of the array                                    │
    // │ 2. Pick a random card from 0 to current position                    │
    // │ 3. Swap the random card with the card at current position           │
    // │ 4. Move one position towards the start                              │
    // │ 5. Repeat until all cards are shuffled                              │
    // │                                                                      │
    // │ Modification: If you want to add "cut card" visual effect,          │
    // │               add animation trigger here before shuffle completes.   │
    // └─────────────────────────────────────────────────────────────────────┘

    func shuffle() {
        // Return all dealt cards to the shoe
        cards.append(contentsOf: dealtCards)
        dealtCards.removeAll()

        // Fisher-Yates shuffle algorithm
        var shuffled = cards
        for i in (1..<shuffled.count).reversed() {
            let j = Int.random(in: 0...i)
            shuffled.swapAt(i, j)
        }

        cards = shuffled
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 DEAL CARD METHOD                                                  │
    // │                                                                      │
    // │ Business Purpose: Removes and returns the top card from the shoe    │
    // │                                                                      │
    // │ Returns: Optional<Card>                                              │
    // │ • Returns nil if shoe is empty (shouldn't happen with penetration   │
    // │   tracking, but safe to handle)                                     │
    // │ • Returns the next card and moves it to dealtCards array            │
    // │                                                                      │
    // │ Used By: DeckManager service when dealing to player or dealer       │
    // │                                                                      │
    // │ Side Effects: Updates cards array and dealtCards array              │
    // └─────────────────────────────────────────────────────────────────────┘

    func dealCard() -> Card? {
        guard !cards.isEmpty else {
            return nil
        }

        let card = cards.removeFirst()
        dealtCards.append(card)
        return card
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 PENETRATION TRACKING                                              │
    // │                                                                      │
    // │ Business Purpose: Determines when to reshuffle the shoe             │
    // │                                                                      │
    // │ Casino Practice: Most casinos reshuffle when 70-80% of cards have   │
    // │ been dealt. This prevents card counters from having too much        │
    // │ information about remaining cards.                                  │
    // │                                                                      │
    // │ Our Implementation: Default 75% penetration                          │
    // │ • 6-deck shoe (312 cards): Reshuffle after ~234 cards dealt         │
    // │ • 1-deck shoe (52 cards): Reshuffle after ~39 cards dealt           │
    // │                                                                      │
    // │ Why Track This: Provides authentic casino experience and prevents   │
    // │ extreme card counting advantages for players.                       │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Returns current penetration as a percentage (0.0 to 1.0)
    var currentPenetration: Double {
        let dealtCount = dealtCards.count
        return Double(dealtCount) / Double(originalCount)
    }

    /// Returns true if penetration threshold has been reached
    /// When this returns true, GameViewModel should trigger a reshuffle
    var needsReshuffle: Bool {
        return currentPenetration >= penetrationThreshold
    }

    /// Returns number of cards remaining in shoe
    var cardsRemaining: Int {
        return cards.count
    }

    /// Returns number of cards dealt so far
    var cardsDealt: Int {
        return dealtCards.count
    }

    /// Returns total cards in shoe when full
    var totalCards: Int {
        return originalCount
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🧪 DEBUG & TESTING HELPERS                                           │
    // │                                                                      │
    // │ These methods are useful for testing specific scenarios             │
    // │ Not used in production gameplay                                     │
    // └─────────────────────────────────────────────────────────────────────┘

    #if DEBUG
    /// Forces a specific card to be next (for testing)
    func forceNextCard(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.rank == card.rank && $0.suit == card.suit }) {
            cards.swapAt(0, index)
        }
    }

    /// Returns the next card without dealing it (peek for testing)
    func peekNextCard() -> Card? {
        return cards.first
    }
    #endif
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Creating a deck:                                                           ║
// ║   let shoe = Deck(numberOfDecks: 6, penetrationThreshold: 0.75)           ║
// ║   // Creates 312-card shoe, reshuffles at 75% penetration                 ║
// ║                                                                            ║
// ║ Dealing cards:                                                             ║
// ║   if let card = shoe.dealCard() {                                          ║
// ║       print("Dealt: \(card.displayString)")                                ║
// ║   }                                                                         ║
// ║                                                                            ║
// ║ Checking for reshuffle:                                                    ║
// ║   if shoe.needsReshuffle {                                                 ║
// ║       shoe.shuffle()                                                       ║
// ║       print("Shoe reshuffled!")                                            ║
// ║   }                                                                         ║
// ║                                                                            ║
// ║ Monitoring penetration:                                                    ║
// ║   print("Penetration: \(shoe.currentPenetration * 100)%")                 ║
// ║   print("\(shoe.cardsRemaining) cards remaining")                          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
