//
//  DeckModelTests.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup - Testing
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🧪 DECK / SHOE TESTS                                                       ║
// ║                                                                            ║
// ║ Purpose: Verify deck/shoe management, shuffling, and penetration tracking ║
// ║ Business Context: The deck must shuffle fairly and track penetration      ║
// ║                   correctly to provide an authentic casino experience.    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import XCTest
@testable import Blackjackwhitejack

final class DeckModelTests: XCTestCase {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📏 DECK SIZE TESTS                                                   │
    // │ Verify correct number of cards for different deck counts            │
    // └─────────────────────────────────────────────────────────────────────┘

    func testSingleDeckSize() throws {
        let deck = Deck(numberOfDecks: 1)
        XCTAssertEqual(deck.totalCards, 52, "Single deck should have 52 cards")
        XCTAssertEqual(deck.cardsRemaining, 52)
    }

    func testSixDeckShoe() throws {
        let deck = Deck(numberOfDecks: 6)
        XCTAssertEqual(deck.totalCards, 312, "6-deck shoe should have 312 cards")
        XCTAssertEqual(deck.cardsRemaining, 312)
    }

    func testEightDeckShoe() throws {
        let deck = Deck(numberOfDecks: 8)
        XCTAssertEqual(deck.totalCards, 416, "8-deck shoe should have 416 cards")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 DEALING CARDS                                                     │
    // │ Verify cards can be dealt and tracking is accurate                  │
    // └─────────────────────────────────────────────────────────────────────┘

    func testDealingCards() throws {
        let deck = Deck(numberOfDecks: 1)

        // Deal one card
        let card = deck.dealCard()
        XCTAssertNotNil(card)
        XCTAssertEqual(deck.cardsRemaining, 51)
        XCTAssertEqual(deck.cardsDealt, 1)

        // Deal 10 more cards
        for _ in 0..<10 {
            _ = deck.dealCard()
        }
        XCTAssertEqual(deck.cardsRemaining, 41)
        XCTAssertEqual(deck.cardsDealt, 11)
    }

    func testDealingEntireDeck() throws {
        let deck = Deck(numberOfDecks: 1)

        // Deal all 52 cards
        var dealtCards: [Card] = []
        for _ in 0..<52 {
            if let card = deck.dealCard() {
                dealtCards.append(card)
            }
        }

        XCTAssertEqual(dealtCards.count, 52)
        XCTAssertEqual(deck.cardsRemaining, 0)
        XCTAssertEqual(deck.cardsDealt, 52)

        // Try to deal another - should return nil
        let extraCard = deck.dealCard()
        XCTAssertNil(extraCard, "Dealing from empty deck should return nil")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔀 SHUFFLE TESTS                                                     │
    // │ Verify shuffling works and is reasonably random                     │
    // └─────────────────────────────────────────────────────────────────────┘

    func testShuffleReturnsCards() throws {
        let deck = Deck(numberOfDecks: 1)

        // Deal 20 cards
        for _ in 0..<20 {
            _ = deck.dealCard()
        }
        XCTAssertEqual(deck.cardsRemaining, 32)

        // Shuffle - should return all cards
        deck.shuffle()
        XCTAssertEqual(deck.cardsRemaining, 52)
        XCTAssertEqual(deck.cardsDealt, 0)
    }

    func testShuffleIsRandom() throws {
        // Create two decks and shuffle them
        // They should have different card orders (extremely unlikely to be same)
        let deck1 = Deck(numberOfDecks: 1)
        let deck2 = Deck(numberOfDecks: 1)

        // Deal first 5 cards from each
        var cards1: [Card] = []
        var cards2: [Card] = []

        for _ in 0..<5 {
            if let c1 = deck1.dealCard() {
                cards1.append(c1)
            }
            if let c2 = deck2.dealCard() {
                cards2.append(c2)
            }
        }

        // Check if card sequences are different
        // Note: There's a 1 in 311,875,200 chance they're identical, so effectively 0
        let sequences1 = cards1.map { "\($0.rank.rawValue)\($0.suit.rawValue)" }.joined()
        let sequences2 = cards2.map { "\($0.rank.rawValue)\($0.suit.rawValue)" }.joined()

        XCTAssertNotEqual(sequences1, sequences2, "Two shuffled decks should have different orders")
    }

    func testDeckContainsAllCards() throws {
        // Verify a shuffled deck contains exactly the right cards
        let deck = Deck(numberOfDecks: 1)

        var dealtCards: [Card] = []
        for _ in 0..<52 {
            if let card = deck.dealCard() {
                dealtCards.append(card)
            }
        }

        // Count each rank
        var rankCounts: [Rank: Int] = [:]
        var suitCounts: [Suit: Int] = [:]

        for card in dealtCards {
            rankCounts[card.rank, default: 0] += 1
            suitCounts[card.suit, default: 0] += 1
        }

        // Each rank should appear exactly 4 times (one per suit)
        for rank in Rank.allCases {
            XCTAssertEqual(rankCounts[rank], 4, "Rank \(rank) should appear 4 times")
        }

        // Each suit should appear exactly 13 times (one per rank)
        for suit in Suit.allCases {
            XCTAssertEqual(suitCounts[suit], 13, "Suit \(suit) should appear 13 times")
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 PENETRATION TRACKING                                              │
    // │ Verify penetration calculations and reshuffle triggers              │
    // └─────────────────────────────────────────────────────────────────────┘

    func testInitialPenetration() throws {
        let deck = Deck(numberOfDecks: 6)
        XCTAssertEqual(deck.currentPenetration, 0.0, accuracy: 0.01)
        XCTAssertFalse(deck.needsReshuffle)
    }

    func testPenetrationCalculation() throws {
        let deck = Deck(numberOfDecks: 1, penetrationThreshold: 0.75)

        // Deal 26 cards (50% penetration)
        for _ in 0..<26 {
            _ = deck.dealCard()
        }

        XCTAssertEqual(deck.currentPenetration, 0.5, accuracy: 0.01)
        XCTAssertFalse(deck.needsReshuffle, "Should not need reshuffle at 50% penetration")

        // Deal 13 more cards (75% penetration)
        for _ in 0..<13 {
            _ = deck.dealCard()
        }

        XCTAssertEqual(deck.currentPenetration, 0.75, accuracy: 0.01)
        XCTAssertTrue(deck.needsReshuffle, "Should need reshuffle at 75% penetration")
    }

    func testPenetrationThreshold() throws {
        // Test 6-deck shoe with 75% penetration (234 cards)
        let deck = Deck(numberOfDecks: 6, penetrationThreshold: 0.75)

        // Deal 233 cards - should not need reshuffle
        for _ in 0..<233 {
            _ = deck.dealCard()
        }
        XCTAssertFalse(deck.needsReshuffle, "Should not need reshuffle just before threshold")

        // Deal 1 more card (234 total = 75%)
        _ = deck.dealCard()
        XCTAssertTrue(deck.needsReshuffle, "Should need reshuffle at threshold")
    }

    func testCustomPenetrationThreshold() throws {
        // Test with 50% penetration threshold
        let deck = Deck(numberOfDecks: 1, penetrationThreshold: 0.5)

        // Deal 26 cards (50%)
        for _ in 0..<26 {
            _ = deck.dealCard()
        }

        XCTAssertTrue(deck.needsReshuffle, "Should need reshuffle at custom 50% threshold")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🧪 DEBUG HELPERS (Development/Testing Only)                          │
    // │ Verify testing utilities work correctly                             │
    // └─────────────────────────────────────────────────────────────────────┘

    #if DEBUG
    func testPeekNextCard() throws {
        let deck = Deck(numberOfDecks: 1)

        // Peek at next card
        let peekedCard = deck.peekNextCard()
        XCTAssertNotNil(peekedCard)

        // Deal the card
        let dealtCard = deck.dealCard()
        XCTAssertNotNil(dealtCard)

        // They should be the same card
        XCTAssertEqual(peekedCard?.rank, dealtCard?.rank)
        XCTAssertEqual(peekedCard?.suit, dealtCard?.suit)
    }

    func testForceNextCard() throws {
        let deck = Deck(numberOfDecks: 1)

        // Force an Ace of Spades to be next
        let aceOfSpades = Card(rank: .ace, suit: .spades)
        deck.forceNextCard(aceOfSpades)

        // Deal a card
        let dealtCard = deck.dealCard()
        XCTAssertNotNil(dealtCard)
        XCTAssertEqual(dealtCard?.rank, .ace)
        XCTAssertEqual(dealtCard?.suit, .spades)
    }
    #endif

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ⚡ PERFORMANCE TEST                                                  │
    // │ Verify shuffle is fast enough even for 8-deck shoes                 │
    // └─────────────────────────────────────────────────────────────────────┘

    func testShufflePerformance() throws {
        let deck = Deck(numberOfDecks: 8)  // 416 cards

        measure {
            deck.shuffle()
        }
        // Should complete in well under 0.01 seconds
    }
}
