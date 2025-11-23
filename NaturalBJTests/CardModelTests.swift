//
//  CardModelTests.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup - Testing
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🧪 CARD MODEL TESTS                                                        ║
// ║                                                                            ║
// ║ Purpose: Verify that Card, Rank, Suit enums work correctly                ║
// ║ Business Context: Cards are the foundation of the game. If card values    ║
// ║                   are wrong, the entire game breaks. These tests ensure   ║
// ║                   that each card has the correct value.                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import XCTest
@testable import Blackjackwhitejack

final class CardModelTests: XCTestCase {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 NUMBER CARD VALUES (2-10)                                        │
    // │ Business Rule: Number cards are worth their face value              │
    // └─────────────────────────────────────────────────────────────────────┘

    func testNumberCardValues() throws {
        XCTAssertEqual(Card(rank: .two, suit: .spades).value, 2)
        XCTAssertEqual(Card(rank: .three, suit: .hearts).value, 3)
        XCTAssertEqual(Card(rank: .four, suit: .diamonds).value, 4)
        XCTAssertEqual(Card(rank: .five, suit: .clubs).value, 5)
        XCTAssertEqual(Card(rank: .six, suit: .spades).value, 6)
        XCTAssertEqual(Card(rank: .seven, suit: .hearts).value, 7)
        XCTAssertEqual(Card(rank: .eight, suit: .diamonds).value, 8)
        XCTAssertEqual(Card(rank: .nine, suit: .clubs).value, 9)
        XCTAssertEqual(Card(rank: .ten, suit: .spades).value, 10)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 👑 FACE CARD VALUES (J, Q, K)                                       │
    // │ Business Rule: All face cards are worth 10                          │
    // └─────────────────────────────────────────────────────────────────────┘

    func testFaceCardValues() throws {
        XCTAssertEqual(Card(rank: .jack, suit: .spades).value, 10)
        XCTAssertEqual(Card(rank: .queen, suit: .hearts).value, 10)
        XCTAssertEqual(Card(rank: .king, suit: .diamonds).value, 10)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🃏 ACE VALUE                                                         │
    // │ Business Rule: Aces return 11 from Card.value                       │
    // │ Note: Hand.swift handles the 1 vs 11 logic                          │
    // └─────────────────────────────────────────────────────────────────────┘

    func testAceValue() throws {
        let ace = Card(rank: .ace, suit: .spades)
        XCTAssertEqual(ace.value, 11, "Ace should return 11; Hand class handles soft/hard conversion")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 DISPLAY STRINGS                                                   │
    // │ Verify cards display correctly in UI                                │
    // └─────────────────────────────────────────────────────────────────────┘

    func testCardDisplayStrings() throws {
        XCTAssertEqual(Card(rank: .ace, suit: .spades).displayString, "A♠")
        XCTAssertEqual(Card(rank: .king, suit: .hearts).displayString, "K♥")
        XCTAssertEqual(Card(rank: .ten, suit: .diamonds).displayString, "10♦")
        XCTAssertEqual(Card(rank: .five, suit: .clubs).displayString, "5♣")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 SUIT COLOURS                                                      │
    // │ Verify red suits (♥♦) and black suits (♠♣) are correct              │
    // └─────────────────────────────────────────────────────────────────────┘

    func testSuitColors() throws {
        XCTAssertEqual(Suit.hearts.color, .red)
        XCTAssertEqual(Suit.diamonds.color, .red)
        XCTAssertEqual(Suit.spades.color, .black)
        XCTAssertEqual(Suit.clubs.color, .black)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🧪 TESTING HELPER - Card.from()                                      │
    // │ Verify we can create cards from shorthand notation                  │
    // └─────────────────────────────────────────────────────────────────────┘

    func testCardFromString() throws {
        let aceOfSpades = Card.from(string: "A♠")
        XCTAssertNotNil(aceOfSpades)
        XCTAssertEqual(aceOfSpades?.rank, .ace)
        XCTAssertEqual(aceOfSpades?.suit, .spades)

        let kingOfHearts = Card.from(string: "K♥")
        XCTAssertNotNil(kingOfHearts)
        XCTAssertEqual(kingOfHearts?.rank, .king)
        XCTAssertEqual(kingOfHearts?.suit, .hearts)

        let tenOfDiamonds = Card.from(string: "10♦")
        XCTAssertNotNil(tenOfDiamonds)
        XCTAssertEqual(tenOfDiamonds?.rank, .ten)
        XCTAssertEqual(tenOfDiamonds?.suit, .diamonds)

        // Invalid strings should return nil
        XCTAssertNil(Card.from(string: "invalid"))
        XCTAssertNil(Card.from(string: "Z♠"))
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📏 DECK COMPLETENESS                                                 │
    // │ Verify we have all 13 ranks and 4 suits                             │
    // └─────────────────────────────────────────────────────────────────────┘

    func testAllRanksExist() throws {
        XCTAssertEqual(Rank.allCases.count, 13, "Should have 13 ranks")
    }

    func testAllSuitsExist() throws {
        XCTAssertEqual(Suit.allCases.count, 4, "Should have 4 suits")
    }

    func testFullDeckCount() throws {
        // Creating one full deck
        var cards: [Card] = []
        for rank in Rank.allCases {
            for suit in Suit.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        XCTAssertEqual(cards.count, 52, "Full deck should have 52 cards")
    }
}
