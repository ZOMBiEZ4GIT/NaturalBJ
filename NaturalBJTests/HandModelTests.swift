//
//  HandModelTests.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup - Testing
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🧪 HAND EVALUATION TESTS                                                   ║
// ║                                                                            ║
// ║ Purpose: Verify hand evaluation logic, especially soft/hard ace handling  ║
// ║ Business Context: Hand evaluation is THE most critical piece of blackjack ║
// ║                   logic. If this is wrong, the game is unplayable. These  ║
// ║                   tests cover all edge cases including multiple aces.     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import XCTest
@testable import Blackjackwhitejack

final class HandModelTests: XCTestCase {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 BASIC HAND TOTALS (No Aces)                                      │
    // │ Simple cases where total is just the sum of card values             │
    // └─────────────────────────────────────────────────────────────────────┘

    func testSimpleHardHands() throws {
        // 10 + 5 = 15
        let hand1 = Hand.from(["10♠", "5♥"])
        XCTAssertEqual(hand1.total, 15)
        XCTAssertFalse(hand1.isSoft)
        XCTAssertFalse(hand1.isBlackjack)

        // K + 9 = 19
        let hand2 = Hand.from(["K♦", "9♣"])
        XCTAssertEqual(hand2.total, 19)
        XCTAssertFalse(hand2.isSoft)

        // 7 + 8 = 15
        let hand3 = Hand.from(["7♠", "8♥"])
        XCTAssertEqual(hand3.total, 15)
        XCTAssertFalse(hand3.isSoft)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🃏 SOFT HANDS (Ace as 11)                                           │
    // │ Hands where ace can be counted as 11 without busting               │
    // └─────────────────────────────────────────────────────────────────────┘

    func testSoftHands() throws {
        // A + 6 = Soft 17 (ace is 11)
        let hand1 = Hand.from(["A♠", "6♥"])
        XCTAssertEqual(hand1.total, 17)
        XCTAssertTrue(hand1.isSoft, "A-6 should be soft 17")
        XCTAssertFalse(hand1.isBlackjack)

        // A + 2 = Soft 13
        let hand2 = Hand.from(["A♦", "2♣"])
        XCTAssertEqual(hand2.total, 13)
        XCTAssertTrue(hand2.isSoft, "A-2 should be soft 13")

        // A + 8 = Soft 19
        let hand3 = Hand.from(["A♠", "8♥"])
        XCTAssertEqual(hand3.total, 19)
        XCTAssertTrue(hand3.isSoft, "A-8 should be soft 19")

        // A + 9 = Soft 20
        let hand4 = Hand.from(["A♦", "9♣"])
        XCTAssertEqual(hand4.total, 20)
        XCTAssertTrue(hand4.isSoft, "A-9 should be soft 20")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💎 BLACKJACK (Natural 21)                                           │
    // │ Exactly 21 with first two cards = special payout                    │
    // └─────────────────────────────────────────────────────────────────────┘

    func testBlackjack() throws {
        // A + K = Blackjack!
        let hand1 = Hand.from(["A♠", "K♥"])
        XCTAssertEqual(hand1.total, 21)
        XCTAssertTrue(hand1.isBlackjack, "A-K should be blackjack")
        XCTAssertTrue(hand1.isSoft)

        // A + Q = Blackjack!
        let hand2 = Hand.from(["A♦", "Q♣"])
        XCTAssertEqual(hand2.total, 21)
        XCTAssertTrue(hand2.isBlackjack)

        // A + 10 = Blackjack!
        let hand3 = Hand.from(["A♠", "10♥"])
        XCTAssertEqual(hand3.total, 21)
        XCTAssertTrue(hand3.isBlackjack)

        // 7 + 7 + 7 = 21 but NOT blackjack (three cards)
        let hand4 = Hand.from(["7♠", "7♥", "7♦"])
        XCTAssertEqual(hand4.total, 21)
        XCTAssertFalse(hand4.isBlackjack, "Three-card 21 is not blackjack")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔄 ACE CONVERSION (Soft to Hard)                                    │
    // │ When hitting on soft hands causes total to exceed 21, ace becomes 1 │
    // └─────────────────────────────────────────────────────────────────────┘

    func testAceConversion() throws {
        // A + 6 + K = 17 (hard)
        // Ace must convert from 11→1: 1+6+10=17
        let hand1 = Hand.from(["A♠", "6♥", "K♦"])
        XCTAssertEqual(hand1.total, 17)
        XCTAssertFalse(hand1.isSoft, "A-6-K should be hard 17")

        // A + 5 + 10 = 16 (hard)
        let hand2 = Hand.from(["A♦", "5♣", "10♠"])
        XCTAssertEqual(hand2.total, 16)
        XCTAssertFalse(hand2.isSoft)

        // A + 8 + 5 = 14 (hard)
        let hand3 = Hand.from(["A♠", "8♥", "5♦"])
        XCTAssertEqual(hand3.total, 14)
        XCTAssertFalse(hand3.isSoft)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🃏🃏 MULTIPLE ACES                                                    │
    // │ The trickiest case: multiple aces in one hand                       │
    // └─────────────────────────────────────────────────────────────────────┘

    func testMultipleAces() throws {
        // A + A = 12 (soft) - one ace is 11, other is 1
        let hand1 = Hand.from(["A♠", "A♥"])
        XCTAssertEqual(hand1.total, 12)
        XCTAssertTrue(hand1.isSoft, "A-A should be soft 12")

        // A + A + 9 = 21 (hard) - both aces must be 1: 1+1+9=21
        let hand2 = Hand.from(["A♦", "A♣", "9♠"])
        XCTAssertEqual(hand2.total, 21)
        XCTAssertFalse(hand2.isSoft, "A-A-9 should be hard 21")
        XCTAssertFalse(hand2.isBlackjack, "Three cards is not blackjack")

        // A + A + 8 = 20 (soft) - one ace is 11, other is 1: 11+1+8=20
        let hand3 = Hand.from(["A♠", "A♥", "8♦"])
        XCTAssertEqual(hand3.total, 20)
        XCTAssertTrue(hand3.isSoft, "A-A-8 should be soft 20")

        // A + A + A + 8 = 21 (hard) - all aces are 1: 1+1+1+8=11, wait that's not right
        // Actually: 11+1+1+8=21 with one soft ace, OR if that busts: 1+1+1+8=11
        // Let's trace: start with 11+11+11+8=41, convert: 31, convert: 21, still one ace as 11
        let hand4 = Hand.from(["A♦", "A♣", "A♠", "8♥"])
        XCTAssertEqual(hand4.total, 21)
        XCTAssertTrue(hand4.isSoft, "A-A-A-8 should be soft 21 (one ace as 11)")

        // A + A + A + 9 = 12 (hard) - all aces must be 1: 1+1+1+9=12
        let hand5 = Hand.from(["A♠", "A♥", "A♦", "9♣"])
        XCTAssertEqual(hand5.total, 12)
        XCTAssertFalse(hand5.isSoft, "A-A-A-9 should be hard 12")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💥 BUST HANDS (Total > 21)                                          │
    // │ Verify that hands over 21 are detected as bust                      │
    // └─────────────────────────────────────────────────────────────────────┘

    func testBustHands() throws {
        // K + Q + 5 = 25 (bust)
        let hand1 = Hand.from(["K♠", "Q♥", "5♦"])
        XCTAssertEqual(hand1.total, 25)
        XCTAssertTrue(hand1.isBust)

        // 10 + 9 + 8 = 27 (bust)
        let hand2 = Hand.from(["10♦", "9♣", "8♠"])
        XCTAssertEqual(hand2.total, 27)
        XCTAssertTrue(hand2.isBust)

        // A + 6 + K + 5 = 22 (bust)
        // Even with an ace, this busts: 1+6+10+5=22
        let hand3 = Hand.from(["A♠", "6♥", "K♦", "5♣"])
        XCTAssertEqual(hand3.total, 22)
        XCTAssertTrue(hand3.isBust)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 RULE CHECKS (Split, Double, etc.)                                │
    // │ Verify that gameplay rules are correctly identified                 │
    // └─────────────────────────────────────────────────────────────────────┘

    func testCanSplit() throws {
        // Pair of 8s - can split
        let hand1 = Hand.from(["8♠", "8♥"])
        XCTAssertTrue(hand1.canSplit())

        // Pair of aces - can split
        let hand2 = Hand.from(["A♦", "A♣"])
        XCTAssertTrue(hand2.canSplit())
        XCTAssertTrue(hand2.isPairOfAces())

        // K + Q = both worth 10, but different ranks - CANNOT split
        let hand3 = Hand.from(["K♠", "Q♥"])
        XCTAssertFalse(hand3.canSplit(), "K-Q should not be splittable (different ranks)")

        // Three cards - cannot split
        let hand4 = Hand.from(["7♠", "7♥", "7♦"])
        XCTAssertFalse(hand4.canSplit())
    }

    func testCanDouble() throws {
        // Two cards - can double
        let hand1 = Hand.from(["9♠", "2♥"])
        XCTAssertTrue(hand1.canDouble())

        // Three cards - cannot double
        let hand2 = Hand.from(["5♦", "3♣", "2♠"])
        XCTAssertFalse(hand2.canDouble())
    }

    func testContainsAce() throws {
        let hand1 = Hand.from(["A♠", "6♥"])
        XCTAssertTrue(hand1.containsAce())

        let hand2 = Hand.from(["K♦", "Q♣"])
        XCTAssertFalse(hand2.containsAce())
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 DISPLAY STRINGS                                                   │
    // │ Verify UI strings are formatted correctly                           │
    // └─────────────────────────────────────────────────────────────────────┘

    func testDisplayStrings() throws {
        // Regular hard hand
        let hand1 = Hand.from(["K♠", "9♥"])
        XCTAssertEqual(hand1.displayString, "19")

        // Soft hand
        let hand2 = Hand.from(["A♦", "6♣"])
        XCTAssertEqual(hand2.displayString, "Soft 17")

        // Blackjack
        let hand3 = Hand.from(["A♠", "K♥"])
        XCTAssertEqual(hand3.displayString, "Blackjack!")

        // Bust
        let hand4 = Hand.from(["K♦", "Q♣", "5♠"])
        XCTAssertEqual(hand4.displayString, "BUST")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🧪 EDGE CASES                                                        │
    // │ Test unusual but possible scenarios                                 │
    // └─────────────────────────────────────────────────────────────────────┘

    func testEmptyHand() throws {
        let hand = Hand()
        XCTAssertEqual(hand.total, 0)
        XCTAssertFalse(hand.isSoft)
        XCTAssertFalse(hand.isBlackjack)
        XCTAssertTrue(hand.isEmpty)
    }

    func testFiveCardCharlie() throws {
        // Not a standard rule, but test we can have 5+ cards
        let hand = Hand.from(["2♠", "2♥", "2♦", "2♣", "3♠"])
        XCTAssertEqual(hand.total, 11)
        XCTAssertEqual(hand.count, 5)
    }

    func testMaxPossibleHand() throws {
        // Four aces + seven cards = 11 cards without busting
        // A+A+A+A+2+2+2+2+2+2+2 = 4 + 14 = 18
        var hand = Hand()
        hand.addCard(Card(rank: .ace, suit: .spades))
        hand.addCard(Card(rank: .ace, suit: .hearts))
        hand.addCard(Card(rank: .ace, suit: .diamonds))
        hand.addCard(Card(rank: .ace, suit: .clubs))
        hand.addCard(Card(rank: .two, suit: .spades))
        hand.addCard(Card(rank: .two, suit: .hearts))
        hand.addCard(Card(rank: .two, suit: .diamonds))

        XCTAssertEqual(hand.total, 18)
        XCTAssertFalse(hand.isBust)
    }
}
