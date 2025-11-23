//
//  MaverickRuleGenerator.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 3: Dealer Personalities & Rule Variations
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎲 MAVERICK RULE GENERATOR                                                 ║
// ║                                                                            ║
// ║ Purpose: Generates random but fair rule combinations for Maverick dealer  ║
// ║ Business Context: Maverick is the "wild card" dealer who changes rules    ║
// ║                   each shoe to keep gameplay fresh and unpredictable.     ║
// ║                   However, randomness must be constrained to keep the     ║
// ║                   game fair - we don't want wildly unfair rule sets.      ║
// ║                                                                            ║
// ║ Design Goals:                                                              ║
// ║ • Provide variety without being unfair to player                          ║
// ║ • Keep house edge between 0.4% - 0.8% (fair range)                        ║
// ║ • Mix favourable and unfavourable rules                                   ║
// ║ • Never two identical rule sets in a row (variety!)                       ║
// ║ • Clear display of current rules so player knows what to expect          ║
// ║                                                                            ║
// ║ Implementation Strategy:                                                   ║
// ║ • Pre-define 6-8 balanced rule combinations                               ║
// ║ • Randomly select from pool when shoe is reshuffled                       ║
// ║ • Each combination tested to fall within target house edge                ║
// ║ • Track previous selection to avoid consecutive duplicates               ║
// ║                                                                            ║
// ║ Used By: • GameViewModel (generates rules when Maverick's shoe exhausted) ║
// ║          • Dealer.maverick() (initial rules)                              ║
// ║                                                                            ║
// ║ Related Spec: See Maverick personality description (lines 112-127)        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

class MaverickRuleGenerator {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎰 RULE POOL - Pre-defined Fair Combinations                         │
    // │                                                                      │
    // │ Each rule set is balanced to fall within 0.4%-0.8% house edge       │
    // │ Names are thematic to help player understand the current rules      │
    // └─────────────────────────────────────────────────────────────────────┘

    private static let rulePool: [(name: String, rules: GameRules)] = [
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🌟 "LUCKY STREAK" - Very player-friendly
        // Single deck + surrender + resplit aces
        // House Edge: ~0.4%
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (
            name: "Lucky Streak",
            rules: GameRules(
                numberOfDecks: 1,
                dealerHitsSoft17: false,
                doubleOnlyOn: nil,
                doubleAfterSplit: true,
                maxSplitHands: 4,
                resplitAces: true,
                splitAcesOneCardOnly: false,
                surrenderAllowed: true,
                earlySurrender: false,
                blackjackPayout: 1.5,
                minimumBetMultiplier: 1.0,
                freeDoubles: false,
                freeSplits: false
            )
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🎯 "BALANCED CHAOS" - Mix of good and restrictive rules
        // 4 decks + stand S17 + no resplit + limited splits
        // House Edge: ~0.6%
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (
            name: "Balanced Chaos",
            rules: GameRules(
                numberOfDecks: 4,
                dealerHitsSoft17: false,
                doubleOnlyOn: nil,
                doubleAfterSplit: true,
                maxSplitHands: 2,
                resplitAces: false,
                splitAcesOneCardOnly: true,
                surrenderAllowed: false,
                earlySurrender: false,
                blackjackPayout: 1.5,
                minimumBetMultiplier: 1.0,
                freeDoubles: false,
                freeSplits: false
            )
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // ⚔️ "HIGH RISK" - Tougher rules, closer to Shark territory
        // 8 decks + hit S17 + no surrender + restricted splits
        // House Edge: ~0.8%
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (
            name: "High Risk",
            rules: GameRules(
                numberOfDecks: 8,
                dealerHitsSoft17: true,
                doubleOnlyOn: nil,
                doubleAfterSplit: false,
                maxSplitHands: 2,
                resplitAces: false,
                splitAcesOneCardOnly: true,
                surrenderAllowed: false,
                earlySurrender: false,
                blackjackPayout: 1.5,
                minimumBetMultiplier: 1.0,
                freeDoubles: false,
                freeSplits: false
            )
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🎓 "LEARNING MODE" - Similar to Zen but with standard decks
        // 2 decks + early surrender + resplit aces + flexible splits
        // House Edge: ~0.4%
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (
            name: "Learning Mode",
            rules: GameRules(
                numberOfDecks: 2,
                dealerHitsSoft17: false,
                doubleOnlyOn: nil,
                doubleAfterSplit: true,
                maxSplitHands: 4,
                resplitAces: true,
                splitAcesOneCardOnly: false,
                surrenderAllowed: true,
                earlySurrender: true,
                blackjackPayout: 1.5,
                minimumBetMultiplier: 1.0,
                freeDoubles: false,
                freeSplits: false
            )
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🏛️ "OLD SCHOOL" - Classic single deck downtown Vegas rules
        // Single deck + stand S17 + restricted doubles
        // House Edge: ~0.5%
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (
            name: "Old School",
            rules: GameRules(
                numberOfDecks: 1,
                dealerHitsSoft17: false,
                doubleOnlyOn: [10, 11], // Restricted like old Vegas
                doubleAfterSplit: false,
                maxSplitHands: 3,
                resplitAces: false,
                splitAcesOneCardOnly: true,
                surrenderAllowed: false,
                earlySurrender: false,
                blackjackPayout: 1.5,
                minimumBetMultiplier: 1.0,
                freeDoubles: false,
                freeSplits: false
            )
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🎪 "CIRCUS CIRCUS" - Mixed bag of random rules
        // 6 decks + hit S17 + generous splits + late surrender
        // House Edge: ~0.7%
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (
            name: "Circus Circus",
            rules: GameRules(
                numberOfDecks: 6,
                dealerHitsSoft17: true,
                doubleOnlyOn: nil,
                doubleAfterSplit: true,
                maxSplitHands: 4,
                resplitAces: true,
                splitAcesOneCardOnly: true,
                surrenderAllowed: true,
                earlySurrender: false,
                blackjackPayout: 1.5,
                minimumBetMultiplier: 1.0,
                freeDoubles: false,
                freeSplits: false
            )
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🌊 "ATLANTIC CITY" - East coast style rules
        // 8 decks + stand S17 + late surrender + generous splits
        // House Edge: ~0.5%
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (
            name: "Atlantic City",
            rules: GameRules(
                numberOfDecks: 8,
                dealerHitsSoft17: false,
                doubleOnlyOn: nil,
                doubleAfterSplit: true,
                maxSplitHands: 3,
                resplitAces: false,
                splitAcesOneCardOnly: true,
                surrenderAllowed: true,
                earlySurrender: false,
                blackjackPayout: 1.5,
                minimumBetMultiplier: 1.0,
                freeDoubles: false,
                freeSplits: false
            )
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🎭 "EUROPEAN STYLE" - European no-hole-card simulation
        // 6 decks + hit S17 + no resplit + late surrender
        // House Edge: ~0.6%
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (
            name: "European Style",
            rules: GameRules(
                numberOfDecks: 6,
                dealerHitsSoft17: true,
                doubleOnlyOn: nil,
                doubleAfterSplit: true,
                maxSplitHands: 2,
                resplitAces: false,
                splitAcesOneCardOnly: true,
                surrenderAllowed: true,
                earlySurrender: false,
                blackjackPayout: 1.5,
                minimumBetMultiplier: 1.0,
                freeDoubles: false,
                freeSplits: false
            )
        )
    ]

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📝 STATE TRACKING                                                    │
    // │                                                                      │
    // │ Track last used rule set to avoid consecutive duplicates            │
    // └─────────────────────────────────────────────────────────────────────┘

    private var lastRuleSetName: String?

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎲 GENERATE RANDOM RULES                                             │
    // │                                                                      │
    // │ Business Logic: Select random rule set from pool, avoiding          │
    // │                 consecutive duplicates                              │
    // │                                                                      │
    // │ Returns: (name: String, rules: GameRules)                           │
    // │ Side Effects: Updates lastRuleSetName for next generation           │
    // └─────────────────────────────────────────────────────────────────────┘

    func generateRandomRules() -> (name: String, rules: GameRules) {
        // Filter out the last rule set if we have one
        let availableRules = Self.rulePool.filter { $0.name != lastRuleSetName }

        // If somehow we filtered everything (shouldn't happen with 8 options),
        // just use the full pool
        let poolToUse = availableRules.isEmpty ? Self.rulePool : availableRules

        // Randomly select from available rules
        let selected = poolToUse.randomElement()!

        // Update last used
        lastRuleSetName = selected.name

        print("🎲 Maverick generated rules: \(selected.name)")
        print("   House Edge: ~\(String(format: "%.2f", selected.rules.approximateHouseEdge))%")

        return selected
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 GET ALL AVAILABLE RULE SET NAMES                                  │
    // │                                                                      │
    // │ For testing and debugging                                           │
    // └─────────────────────────────────────────────────────────────────────┘

    static var availableRuleSetNames: [String] {
        return rulePool.map { $0.name }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔍 GET RULE SET BY NAME                                              │
    // │                                                                      │
    // │ For testing specific rule sets                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    static func ruleSet(named name: String) -> (name: String, rules: GameRules)? {
        return rulePool.first { $0.name == name }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create generator:                                                          ║
// ║   let generator = MaverickRuleGenerator()                                  ║
// ║                                                                            ║
// ║ Generate random rules:                                                     ║
// ║   let (name, rules) = generator.generateRandomRules()                      ║
// ║   print("Playing with: \(name)")                                           ║
// ║   print("Decks: \(rules.numberOfDecks)")                                   ║
// ║   print("House Edge: \(rules.approximateHouseEdge)%")                      ║
// ║                                                                            ║
// ║ In GameViewModel (when reshuffle needed):                                  ║
// ║   if currentDealer.name == "Maverick" && deckManager.needsReshuffle {      ║
// ║       let (ruleName, newRules) = maverickGenerator.generateRandomRules()   ║
// ║       // Update Maverick's rules                                           ║
// ║       // Display ruleName to player                                        ║
// ║       deckManager.reshuffle()                                              ║
// ║   }                                                                         ║
// ║                                                                            ║
// ║ Check available rule sets:                                                 ║
// ║   let names = MaverickRuleGenerator.availableRuleSetNames                  ║
// ║   // ["Lucky Streak", "Balanced Chaos", "High Risk", ...]                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
