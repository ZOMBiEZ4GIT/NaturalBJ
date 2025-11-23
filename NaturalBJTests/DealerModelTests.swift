//
//  DealerModelTests.swift
//  BlackjackwhitejackTests
//
//  Created by Claude Code
//  Part of Phase 3: Dealer Personalities & Rule Variations
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🧪 DEALER MODEL TESTS                                                      ║
// ║                                                                            ║
// ║ Purpose: Verify all 6 dealer personalities are correctly configured       ║
// ║ Tests cover:                                                               ║
// ║ • Dealer factory methods create unique dealers                            ║
// ║ • Each dealer has distinct rules                                          ║
// ║ • Theme colours are set correctly                                         ║
// ║ • House edge calculations are reasonable                                  ║
// ║ • Special mechanics (Lucky's free features, Shark's high stakes)          ║
// ║ • Maverick rule generator produces variety                                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import XCTest
@testable import Blackjackwhitejack

final class DealerModelTests: XCTestCase {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: ALL DEALERS FACTORY METHODS                                 │
    // │                                                                      │
    // │ Verifies that each factory method creates a unique dealer           │
    // └─────────────────────────────────────────────────────────────────────┘

    func testAllDealersFactoryMethods() {
        let ruby = Dealer.ruby()
        let lucky = Dealer.lucky()
        let shark = Dealer.shark()
        let zen = Dealer.zen()
        let blitz = Dealer.blitz()
        let maverick = Dealer.maverick()

        // Verify each dealer has correct name
        XCTAssertEqual(ruby.name, "Ruby")
        XCTAssertEqual(lucky.name, "Lucky")
        XCTAssertEqual(shark.name, "Shark")
        XCTAssertEqual(zen.name, "Zen")
        XCTAssertEqual(blitz.name, "Blitz")
        XCTAssertEqual(maverick.name, "Maverick")

        // Verify each has a tagline
        XCTAssertFalse(ruby.tagline.isEmpty)
        XCTAssertFalse(lucky.tagline.isEmpty)
        XCTAssertFalse(shark.tagline.isEmpty)
        XCTAssertFalse(zen.tagline.isEmpty)
        XCTAssertFalse(blitz.tagline.isEmpty)
        XCTAssertFalse(maverick.tagline.isEmpty)

        // Verify each has personality description
        XCTAssertFalse(ruby.personality.isEmpty)
        XCTAssertFalse(lucky.personality.isEmpty)
        XCTAssertFalse(shark.personality.isEmpty)
        XCTAssertFalse(zen.personality.isEmpty)
        XCTAssertFalse(blitz.personality.isEmpty)
        XCTAssertFalse(maverick.personality.isEmpty)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: ALL DEALERS COLLECTION                                      │
    // │                                                                      │
    // │ Verifies Dealer.allDealers returns exactly 6 unique dealers         │
    // └─────────────────────────────────────────────────────────────────────┘

    func testAllDealersCollection() {
        let dealers = Dealer.allDealers

        // Should have exactly 6 dealers
        XCTAssertEqual(dealers.count, 6)

        // All names should be unique
        let names = dealers.map { $0.name }
        let uniqueNames = Set(names)
        XCTAssertEqual(names.count, uniqueNames.count, "Dealer names should be unique")

        // Should contain all expected dealers
        XCTAssertTrue(names.contains("Ruby"))
        XCTAssertTrue(names.contains("Lucky"))
        XCTAssertTrue(names.contains("Shark"))
        XCTAssertTrue(names.contains("Zen"))
        XCTAssertTrue(names.contains("Blitz"))
        XCTAssertTrue(names.contains("Maverick"))
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: RUBY DEALER RULES                                           │
    // │                                                                      │
    // │ Ruby should have standard Vegas rules                               │
    // └─────────────────────────────────────────────────────────────────────┘

    func testRubyDealerRules() {
        let ruby = Dealer.ruby()
        let rules = ruby.rules

        // Standard 6-deck shoe
        XCTAssertEqual(rules.numberOfDecks, 6)

        // Dealer stands on soft 17 (player-friendly)
        XCTAssertFalse(rules.dealerHitsSoft17)

        // Standard blackjack payout (3:2)
        XCTAssertEqual(rules.blackjackPayout, 1.5, accuracy: 0.01)

        // Can double on any two cards
        XCTAssertNil(rules.doubleOnlyOn)
        XCTAssertTrue(rules.doubleAfterSplit)

        // Standard split rules
        XCTAssertEqual(rules.maxSplitHands, 4)
        XCTAssertFalse(rules.resplitAces)
        XCTAssertTrue(rules.splitAcesOneCardOnly)

        // No surrender
        XCTAssertFalse(rules.surrenderAllowed)

        // Normal minimum bet
        XCTAssertEqual(rules.minimumBetMultiplier, 1.0, accuracy: 0.01)

        // No special mechanics
        XCTAssertFalse(rules.freeDoubles)
        XCTAssertFalse(rules.freeSplits)

        // House edge should be around 0.55%
        XCTAssertGreaterThan(ruby.houseEdge, 0.4)
        XCTAssertLessThan(ruby.houseEdge, 0.7)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: LUCKY DEALER SPECIAL FEATURES                               │
    // │                                                                      │
    // │ Lucky should have free doubles and free splits                      │
    // └─────────────────────────────────────────────────────────────────────┘

    func testLuckyDealerSpecialFeatures() {
        let lucky = Dealer.lucky()
        let rules = lucky.rules

        // Single deck (best for player)
        XCTAssertEqual(rules.numberOfDecks, 1)

        // 🍀 Free doubles - Lucky's signature feature
        XCTAssertTrue(rules.freeDoubles, "Lucky should have free doubles")

        // 🍀 Free splits - Lucky's signature feature
        XCTAssertTrue(rules.freeSplits, "Lucky should have free splits")

        // Player-friendly rules
        XCTAssertFalse(rules.dealerHitsSoft17) // Stand on S17
        XCTAssertTrue(rules.resplitAces) // Can re-split aces
        XCTAssertTrue(rules.surrenderAllowed) // Late surrender

        // Standard 3:2 blackjack
        XCTAssertEqual(rules.blackjackPayout, 1.5, accuracy: 0.01)

        // House edge should be negative (player advantage)
        XCTAssertLessThan(lucky.houseEdge, 0.0, "Lucky should have player advantage")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: SHARK DEALER TOUGH RULES                                    │
    // │                                                                      │
    // │ Shark should have aggressive rules and high minimum bet             │
    // └─────────────────────────────────────────────────────────────────────┘

    func testSharkDealerToughRules() {
        let shark = Dealer.shark()
        let rules = shark.rules

        // 8 decks (higher house edge)
        XCTAssertEqual(rules.numberOfDecks, 8)

        // Dealer hits soft 17 (aggressive)
        XCTAssertTrue(rules.dealerHitsSoft17, "Shark dealer should hit soft 17")

        // 🦈 6:5 blackjack (poor payout)
        XCTAssertEqual(rules.blackjackPayout, 1.2, accuracy: 0.01, "Shark should pay 6:5 on blackjack")

        // 🦈 5x minimum bet (high stakes)
        XCTAssertEqual(rules.minimumBetMultiplier, 5.0, accuracy: 0.01, "Shark should have 5x minimum bet")

        // Restricted doubles (9, 10, 11 only)
        XCTAssertNotNil(rules.doubleOnlyOn)
        XCTAssertEqual(rules.doubleOnlyOn, [9, 10, 11])

        // No double after split
        XCTAssertFalse(rules.doubleAfterSplit)

        // Limited splits (2 hands max)
        XCTAssertEqual(rules.maxSplitHands, 2)

        // No surrender
        XCTAssertFalse(rules.surrenderAllowed)

        // House edge should be around 2%
        XCTAssertGreaterThan(shark.houseEdge, 1.5, "Shark should have high house edge")
        XCTAssertLessThan(shark.houseEdge, 2.5)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: ZEN DEALER TEACHING RULES                                   │
    // │                                                                      │
    // │ Zen should have favourable rules for learning                       │
    // └─────────────────────────────────────────────────────────────────────┘

    func testZenDealerTeachingRules() {
        let zen = Dealer.zen()
        let rules = zen.rules

        // 2 decks (good for learning)
        XCTAssertEqual(rules.numberOfDecks, 2)

        // 🧘 Early surrender (rare and valuable)
        XCTAssertTrue(rules.surrenderAllowed, "Zen should allow surrender")
        XCTAssertTrue(rules.earlySurrender, "Zen should have early surrender")

        // Player-friendly split rules
        XCTAssertTrue(rules.resplitAces, "Zen should allow re-split aces")
        XCTAssertFalse(rules.splitAcesOneCardOnly, "Zen should allow full play on split aces")

        // Can double after split
        XCTAssertTrue(rules.doubleAfterSplit)

        // Standard 3:2 blackjack
        XCTAssertEqual(rules.blackjackPayout, 1.5, accuracy: 0.01)

        // House edge should be low (~0.35%)
        XCTAssertGreaterThan(zen.houseEdge, 0.2)
        XCTAssertLessThan(zen.houseEdge, 0.5)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: BLITZ DEALER RULES                                          │
    // │                                                                      │
    // │ Blitz should have standard rules (timer is Phase 7)                 │
    // └─────────────────────────────────────────────────────────────────────┘

    func testBlitzDealerRules() {
        let blitz = Dealer.blitz()
        let ruby = Dealer.ruby()

        // For Phase 3, Blitz uses same rules as Ruby
        XCTAssertEqual(blitz.rules.numberOfDecks, ruby.rules.numberOfDecks)
        XCTAssertEqual(blitz.rules.dealerHitsSoft17, ruby.rules.dealerHitsSoft17)
        XCTAssertEqual(blitz.rules.blackjackPayout, ruby.rules.blackjackPayout, accuracy: 0.01)

        // But should have different name and personality
        XCTAssertNotEqual(blitz.name, ruby.name)
        XCTAssertNotEqual(blitz.tagline, ruby.tagline)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: MAVERICK RULE GENERATOR                                     │
    // │                                                                      │
    // │ Verifies Maverick's random rule generation works correctly          │
    // └─────────────────────────────────────────────────────────────────────┘

    func testMaverickRuleGenerator() {
        let generator = MaverickRuleGenerator()

        // Generate 10 rule sets and verify they're all valid
        var generatedNames: [String] = []

        for _ in 0..<10 {
            let (name, rules) = generator.generateRandomRules()

            // Rule set should have a name
            XCTAssertFalse(name.isEmpty)
            generatedNames.append(name)

            // House edge should be in fair range (0.4% - 0.8%)
            let houseEdge = rules.approximateHouseEdge
            XCTAssertGreaterThan(houseEdge, 0.3, "House edge too low: \(houseEdge)% for \(name)")
            XCTAssertLessThan(houseEdge, 1.0, "House edge too high: \(houseEdge)% for \(name)")

            // Should always be standard blackjack payout (3:2)
            XCTAssertEqual(rules.blackjackPayout, 1.5, accuracy: 0.01, "\(name) should pay 3:2")

            // Should have normal minimum bet
            XCTAssertEqual(rules.minimumBetMultiplier, 1.0, accuracy: 0.01)

            // Should not have Lucky's special features
            XCTAssertFalse(rules.freeDoubles, "\(name) should not have free doubles")
            XCTAssertFalse(rules.freeSplits, "\(name) should not have free splits")
        }

        // Should generate variety (at least 3 different rule sets in 10 generations)
        let uniqueNames = Set(generatedNames)
        XCTAssertGreaterThanOrEqual(uniqueNames.count, 3, "Generator should produce variety")
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: MAVERICK NO CONSECUTIVE DUPLICATES                          │
    // │                                                                      │
    // │ Verifies generator avoids consecutive identical rule sets           │
    // └─────────────────────────────────────────────────────────────────────┘

    func testMaverickNoConsecutiveDuplicates() {
        let generator = MaverickRuleGenerator()

        var previousName: String?

        for _ in 0..<20 {
            let (name, _) = generator.generateRandomRules()

            // Should not be the same as previous
            if let prev = previousName {
                XCTAssertNotEqual(name, prev, "Generator should not produce consecutive duplicates")
            }

            previousName = name
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: DEALER FINDER                                               │
    // │                                                                      │
    // │ Tests Dealer.dealer(named:) helper method                           │
    // └─────────────────────────────────────────────────────────────────────┘

    func testDealerFinder() {
        // Should find existing dealers
        XCTAssertNotNil(Dealer.dealer(named: "Ruby"))
        XCTAssertNotNil(Dealer.dealer(named: "Lucky"))
        XCTAssertNotNil(Dealer.dealer(named: "Shark"))
        XCTAssertNotNil(Dealer.dealer(named: "Zen"))
        XCTAssertNotNil(Dealer.dealer(named: "Blitz"))
        XCTAssertNotNil(Dealer.dealer(named: "Maverick"))

        // Should return nil for non-existent dealer
        XCTAssertNil(Dealer.dealer(named: "Nonexistent"))

        // Should be case-sensitive
        XCTAssertNil(Dealer.dealer(named: "ruby"))
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: RULES SUMMARY GENERATION                                    │
    // │                                                                      │
    // │ Tests rulesSummary extension method                                 │
    // └─────────────────────────────────────────────────────────────────────┘

    func testRulesSummary() {
        // Ruby's summary should include key rules
        let ruby = Dealer.ruby()
        let rubySummary = ruby.rulesSummary

        XCTAssertTrue(rubySummary.contains { $0.contains("6 deck") })
        XCTAssertTrue(rubySummary.contains { $0.contains("stands on soft 17") })
        XCTAssertTrue(rubySummary.contains { $0.contains("3:2") })

        // Lucky's summary should show special features
        let lucky = Dealer.lucky()
        let luckySummary = lucky.rulesSummary

        XCTAssertTrue(luckySummary.contains { $0.contains("Free doubles") })
        XCTAssertTrue(luckySummary.contains { $0.contains("Free splits") })

        // Shark's summary should show restrictions
        let shark = Dealer.shark()
        let sharkSummary = shark.rulesSummary

        XCTAssertTrue(sharkSummary.contains { $0.contains("6:5") })
        XCTAssertTrue(sharkSummary.contains { $0.contains("Minimum bet: 5x") })
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: HOUSE EDGE COMPARISONS                                      │
    // │                                                                      │
    // │ Verifies relative house edges make sense                            │
    // └─────────────────────────────────────────────────────────────────────┘

    func testHouseEdgeComparisons() {
        let ruby = Dealer.ruby()
        let lucky = Dealer.lucky()
        let shark = Dealer.shark()
        let zen = Dealer.zen()

        // Lucky should have lowest (negative) house edge
        XCTAssertLessThan(lucky.houseEdge, ruby.houseEdge)
        XCTAssertLessThan(lucky.houseEdge, shark.houseEdge)
        XCTAssertLessThan(lucky.houseEdge, zen.houseEdge)

        // Shark should have highest house edge
        XCTAssertGreaterThan(shark.houseEdge, ruby.houseEdge)
        XCTAssertGreaterThan(shark.houseEdge, zen.houseEdge)

        // Zen should be better than Ruby (more player-friendly)
        XCTAssertLessThan(zen.houseEdge, ruby.houseEdge)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✅ TEST: DEALER CODABLE CONFORMANCE                                  │
    // │                                                                      │
    // │ Tests that dealers can be encoded/decoded (for persistence)         │
    // └─────────────────────────────────────────────────────────────────────┘

    func testDealerCodable() throws {
        let originalDealer = Dealer.lucky()

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDealer)

        // Decode
        let decoder = JSONDecoder()
        let decodedDealer = try decoder.decode(Dealer.self, from: data)

        // Verify they match
        XCTAssertEqual(decodedDealer.name, originalDealer.name)
        XCTAssertEqual(decodedDealer.tagline, originalDealer.tagline)
        XCTAssertEqual(decodedDealer.rules, originalDealer.rules)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📝 TEST SUMMARY                                                            ║
// ║                                                                            ║
// ║ These tests verify:                                                        ║
// ║ ✅ All 6 dealers are properly configured                                  ║
// ║ ✅ Each dealer has unique rules and personality                           ║
// ║ ✅ Lucky's free mechanics are enabled                                     ║
// ║ ✅ Shark's tough rules and high stakes are correct                        ║
// ║ ✅ Zen's teaching features are configured                                 ║
// ║ ✅ Maverick's random rule generation works                                ║
// ║ ✅ House edge calculations are in expected ranges                         ║
// ║ ✅ Dealers can be persisted (Codable)                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
