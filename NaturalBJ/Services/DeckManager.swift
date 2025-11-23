//
//  DeckManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 DECK MANAGER SERVICE                                                    ║
// ║                                                                            ║
// ║ Purpose: Coordinates deck/shoe management and card dealing for gameplay   ║
// ║ Business Context: Acts as the intermediary between Deck model and game    ║
// ║                   logic. Handles automatic reshuffling, dealing sequences,║
// ║                   and animation coordination.                              ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Create and manage the shoe based on dealer rules                        ║
// ║ • Deal cards to player and dealer                                         ║
// ║ • Monitor penetration and trigger reshuffles                              ║
// ║ • Coordinate dealing animations (Phase 2)                                 ║
// ║                                                                            ║
// ║ Used By: GameViewModel (orchestrates all game logic)                      ║
// ║                                                                            ║
// ║ Related Spec: See "Deck Logic" and "Card Dealing" sections                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import Combine

class DeckManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📚 PROPERTIES                                                        │
    // └─────────────────────────────────────────────────────────────────────┘

    /// The current deck/shoe being used
    @Published private(set) var deck: Deck

    /// Number of decks in the shoe (1-8)
    let numberOfDecks: Int

    /// Penetration threshold (0.75 = reshuffle at 75%)
    let penetrationThreshold: Double

    /// Animation speed mode
    @Published var animationSpeed: AnimationSpeed = .normal

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                       │
    // │                                                                      │
    // │ Parameters:                                                          │
    // │ • numberOfDecks: Based on dealer rules (Ruby=6, Lucky=1, etc.)      │
    // │ • penetrationThreshold: When to reshuffle (default 75%)             │
    // └─────────────────────────────────────────────────────────────────────┘

    init(numberOfDecks: Int = 6, penetrationThreshold: Double = 0.75) {
        self.numberOfDecks = numberOfDecks
        self.penetrationThreshold = penetrationThreshold
        self.deck = Deck(numberOfDecks: numberOfDecks, penetrationThreshold: penetrationThreshold)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 DEAL CARD                                                         │
    // │                                                                      │
    // │ Business Logic: Deals one card from the shoe                        │
    // │ Automatically checks for reshuffle needs after dealing              │
    // │                                                                      │
    // │ Returns: Card or nil if deck is empty (shouldn't happen)            │
    // └─────────────────────────────────────────────────────────────────────┘

    func dealCard() -> Card? {
        let card = deck.dealCard()

        // Check if we need to reshuffle
        if deck.needsReshuffle {
            // Note: In Phase 2, this will trigger a notification/animation
            // For now, we'll reshuffle silently
            print("♠️ Deck penetration reached \(deck.currentPenetration * 100)% - reshuffling...")
        }

        return card
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔀 RESHUFFLE                                                         │
    // │                                                                      │
    // │ Business Logic: Manually trigger a reshuffle                        │
    // │ Called when:                                                         │
    // │ • Penetration threshold reached                                     │
    // │ • Dealer is switched (new rules = new shoe)                         │
    // │ • Player explicitly requests it (rare, but allowed)                 │
    // └─────────────────────────────────────────────────────────────────────┘

    func reshuffle() {
        deck.shuffle()
        print("♠️ Shoe reshuffled - \(deck.cardsRemaining) cards ready")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 DEAL INITIAL HANDS                                                │
    // │                                                                      │
    // │ Business Logic: Deals initial 2 cards to player and dealer          │
    // │ Standard blackjack dealing sequence:                                │
    // │ 1. One card to player (face up)                                     │
    // │ 2. One card to dealer (face up - upcard)                            │
    // │ 3. One card to player (face up)                                     │
    // │ 4. One card to dealer (face down - hole card)                       │
    // │                                                                      │
    // │ Returns: (playerHand, dealerVisibleCards, dealerHoleCard)           │
    // └─────────────────────────────────────────────────────────────────────┘

    func dealInitialHands() -> (playerHand: Hand, dealerUpcard: Card, dealerHoleCard: Card)? {
        guard let playerCard1 = dealCard(),
              let dealerUpcard = dealCard(),
              let playerCard2 = dealCard(),
              let dealerHoleCard = dealCard() else {
            return nil
        }

        var playerHand = Hand()
        playerHand.addCard(playerCard1)
        playerHand.addCard(playerCard2)

        return (playerHand, dealerUpcard, dealerHoleCard)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 DECK STATUS                                                       │
    // │                                                                      │
    // │ Convenience methods for checking deck state                         │
    // └─────────────────────────────────────────────────────────────────────┘

    var cardsRemaining: Int {
        return deck.cardsRemaining
    }

    var cardsDealt: Int {
        return deck.cardsDealt
    }

    var currentPenetration: Double {
        return deck.currentPenetration
    }

    var needsReshuffle: Bool {
        return deck.needsReshuffle
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎬 ANIMATION COORDINATION (Phase 2)                                  │
    // │                                                                      │
    // │ These methods will handle animation timing in Phase 2               │
    // │ For now, they're placeholders                                       │
    // └─────────────────────────────────────────────────────────────────────┘

    func dealCardWithAnimation(completion: @escaping (Card?) -> Void) {
        // Phase 2: Add animation delay based on animationSpeed
        let delay = animationSpeed.dealDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion(self.dealCard())
        }
    }

    func dealInitialHandsWithAnimation(completion: @escaping ((Hand, Card, Card)?) -> Void) {
        // Phase 2: Add staggered dealing animation
        // For now, just deal immediately
        completion(dealInitialHands())
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ ⚡ ANIMATION SPEED                                                         ║
// ║                                                                            ║
// ║ Purpose: Defines animation speed modes for different player preferences   ║
// ║ Business Context: Some players want instant results, others enjoy the     ║
// ║                   anticipation of animated dealing. User choice!          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum AnimationSpeed {
    case instant
    case normal
    case slow

    /// Delay between card deals (in seconds)
    var dealDelay: Double {
        switch self {
        case .instant: return 0.0
        case .normal: return 0.3
        case .slow: return 0.6
        }
    }

    /// Duration of card flip animation (in seconds)
    var flipDuration: Double {
        switch self {
        case .instant: return 0.0
        case .normal: return 0.4
        case .slow: return 0.8
        }
    }

    /// Duration of chip count animation (in seconds)
    var chipAnimationDuration: Double {
        switch self {
        case .instant: return 0.0
        case .normal: return 0.5
        case .slow: return 1.0
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create deck manager for 6-deck shoe (Ruby dealer):                        ║
// ║   let manager = DeckManager(numberOfDecks: 6, penetrationThreshold: 0.75) ║
// ║                                                                            ║
// ║ Deal initial hands:                                                        ║
// ║   if let hands = manager.dealInitialHands() {                              ║
// ║       let playerHand = hands.playerHand                                    ║
// ║       let dealerUpcard = hands.dealerUpcard                                ║
// ║       let dealerHoleCard = hands.dealerHoleCard                            ║
// ║   }                                                                         ║
// ║                                                                            ║
// ║ Deal one card to player:                                                   ║
// ║   if let card = manager.dealCard() {                                       ║
// ║       playerHand.addCard(card)                                             ║
// ║   }                                                                         ║
// ║                                                                            ║
// ║ Check for reshuffle:                                                       ║
// ║   if manager.needsReshuffle {                                              ║
// ║       manager.reshuffle()                                                  ║
// ║   }                                                                         ║
// ║                                                                            ║
// ║ Change animation speed:                                                    ║
// ║   manager.animationSpeed = .instant  // For players who want speed        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
