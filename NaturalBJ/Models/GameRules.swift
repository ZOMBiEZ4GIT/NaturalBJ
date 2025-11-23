//
//  GameRules.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 3: Dealer Personalities & Rule Variations
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📜 GAME RULES MODEL                                                        ║
// ║                                                                            ║
// ║ Purpose: Encapsulates all blackjack rule variations in a single struct    ║
// ║ Business Context: Instead of having complex settings menus, each dealer   ║
// ║                   personality has a pre-configured rules set. This makes  ║
// ║                   rule selection intuitive - just choose your dealer!     ║
// ║                                                                            ║
// ║ Key Concepts:                                                              ║
// ║ • House Edge: Percentage advantage the casino has over the player         ║
// ║ • Soft 17: Hand with Ace counted as 11 (e.g., A-6). Some dealers hit,    ║
// ║             others stand. Hitting increases house edge ~0.2%              ║
// ║ • Penetration: How deep into shoe before reshuffle (75% = reshuffle at   ║
// ║                25% remaining). Deeper penetration favours card counters   ║
// ║ • Double Down: Double your bet for exactly one more card                  ║
// ║ • Split: Divide matching cards into two hands (costs additional bet)     ║
// ║ • Surrender: Forfeit hand and get 50% of bet back                        ║
// ║                                                                            ║
// ║ Used By: • Dealer (each dealer has a rules configuration)                 ║
// ║          • GameViewModel (enforces rules during gameplay)                 ║
// ║                                                                            ║
// ║ Related Spec: See "Dealer Personalities & Rule Sets" (lines 16-127)       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

struct GameRules: Codable, Equatable {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 DECK CONFIGURATION                                                │
    // │                                                                      │
    // │ Number of decks in the shoe affects house edge:                     │
    // │ • Single deck: Best for player (~0.17% edge reduction)              │
    // │ • 2 decks: Still favourable                                         │
    // │ • 6 decks: Casino standard (Ruby's default)                         │
    // │ • 8 decks: Higher house edge, harder to count cards                 │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Number of 52-card decks in the shoe (1-8)
    let numberOfDecks: Int

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🤖 DEALER BEHAVIOUR                                                  │
    // │                                                                      │
    // │ Dealer must follow fixed rules (no decisions):                      │
    // │ • Always hits on 16 or less                                         │
    // │ • Soft 17 rule: Stand vs Hit determines house edge                  │
    // │   - Stand on soft 17 (S17): Better for player                       │
    // │   - Hit on soft 17 (H17): Worse for player (+0.2% house edge)       │
    // └─────────────────────────────────────────────────────────────────────┘

    /// If true, dealer hits on soft 17 (A-6). If false, stands on all 17s
    let dealerHitsSoft17: Bool

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💪 DOUBLE DOWN RULES                                                 │
    // │                                                                      │
    // │ Double down = double your bet for exactly one more card             │
    // │ Strategic move when you have 10 or 11 vs dealer's weak card         │
    // └─────────────────────────────────────────────────────────────────────┘

    /// If nil, can double on any two cards. If set, can only double on these totals
    /// Example: [9, 10, 11] means can only double on 9, 10, or 11
    let doubleOnlyOn: [Int]?

    /// Can player double down after splitting a pair?
    /// Restricting this increases house edge ~0.14%
    let doubleAfterSplit: Bool

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ✂️ SPLIT RULES                                                       │
    // │                                                                      │
    // │ Splitting pairs is a key strategic option in blackjack              │
    // │ Different dealers have different restrictions                       │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Maximum number of hands after splitting (2, 3, or 4)
    /// Example: 4 means can split up to 3 times (1 hand → 2 → 3 → 4)
    let maxSplitHands: Int

    /// Can player re-split aces?
    /// Most casinos don't allow this (increases player advantage)
    let resplitAces: Bool

    /// Do split aces get only one card each?
    /// Standard rule: Yes (prevents getting multiple shots at 21)
    let splitAcesOneCardOnly: Bool

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏳️ SURRENDER RULES                                                   │
    // │                                                                      │
    // │ Surrender = Give up hand and get 50% of bet back                    │
    // │ Strategic option when you have a terrible hand (e.g., 16 vs 10)     │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Is surrender allowed at all?
    let surrenderAllowed: Bool

    /// Early vs Late surrender:
    /// • Early: Can surrender before dealer checks for blackjack (rare)
    /// • Late: Can only surrender after dealer checks (standard)
    /// Early surrender reduces house edge significantly (~0.6%)
    let earlySurrender: Bool

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💰 PAYOUT CONFIGURATION                                              │
    // │                                                                      │
    // │ Blackjack payout is THE most important rule for house edge          │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Blackjack payout multiplier:
    /// • 1.5 = 3:2 payout (standard, fair) - Bet $10, win $25 total
    /// • 1.2 = 6:5 payout (poor, avoid) - Bet $10, win $22 total
    /// 6:5 blackjack increases house edge by ~1.4% - huge difference!
    let blackjackPayout: Double

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎰 SPECIAL MECHANICS                                                 │
    // │                                                                      │
    // │ Unique features for specific dealers                                │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Minimum bet multiplier (1.0 = normal, 5.0 = Shark's high roller stakes)
    /// Applied to base minimum bet when dealer is selected
    let minimumBetMultiplier: Double

    /// Lucky's special: Double down doesn't cost additional bet
    /// (Still pays out as if you bet double though!)
    let freeDoubles: Bool

    /// Lucky's special: Splits don't cost additional bet
    /// (Still pays out as if you bet on both hands though!)
    let freeSplits: Bool

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 HOUSE EDGE CALCULATION                                            │
    // │                                                                      │
    // │ Approximates the house edge based on rules                          │
    // │ Formula from "The Theory of Blackjack" by Peter Griffin            │
    // │                                                                      │
    // │ Base: ~0.5%                                                          │
    // │ Single deck: -0.17%                                                  │
    // │ Each additional deck: +0.03%                                         │
    // │ H17 (hit soft 17): +0.22%                                            │
    // │ 6:5 blackjack: +1.39%                                                │
    // │ No resplit: +0.03%                                                   │
    // │ No double after split: +0.14%                                        │
    // │ Late surrender: -0.08%                                               │
    // │ Early surrender: -0.62%                                              │
    // └─────────────────────────────────────────────────────────────────────┘

    var approximateHouseEdge: Double {
        var edge = 0.5 // Base house edge with standard rules

        // Deck count effect
        if numberOfDecks == 1 {
            edge -= 0.17
        } else if numberOfDecks == 2 {
            edge -= 0.10
        } else if numberOfDecks >= 6 {
            edge += 0.03 * Double(numberOfDecks - 6)
        }

        // Dealer hits soft 17
        if dealerHitsSoft17 {
            edge += 0.22
        }

        // Blackjack payout
        if blackjackPayout < 1.5 {
            edge += 1.39 // 6:5 blackjack penalty
        }

        // Double restrictions
        if doubleOnlyOn != nil {
            edge += 0.10 // Restricting doubles hurts player
        }
        if !doubleAfterSplit {
            edge += 0.14
        }

        // Split restrictions
        if maxSplitHands < 4 {
            edge += 0.03
        }
        if !resplitAces {
            edge += 0.03
        }

        // Surrender benefit
        if surrenderAllowed {
            if earlySurrender {
                edge -= 0.62
            } else {
                edge -= 0.08
            }
        }

        // Lucky's free mechanics (HUGE player advantage)
        if freeDoubles {
            edge -= 1.5 // Free doubles is incredibly valuable
        }
        if freeSplits {
            edge -= 0.5 // Free splits is also very valuable
        }

        return edge
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏭 FACTORY METHODS - PRE-CONFIGURED RULE SETS                        │
    // │                                                                      │
    // │ These create the standard rule configurations                       │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Standard Las Vegas rules (Ruby's defaults)
    static var standard: GameRules {
        return GameRules(
            numberOfDecks: 6,
            dealerHitsSoft17: false,
            doubleOnlyOn: nil, // Can double on any two cards
            doubleAfterSplit: true,
            maxSplitHands: 4,
            resplitAces: false,
            splitAcesOneCardOnly: true,
            surrenderAllowed: false,
            earlySurrender: false,
            blackjackPayout: 1.5, // 3:2
            minimumBetMultiplier: 1.0,
            freeDoubles: false,
            freeSplits: false
        )
    }

    /// Ruby's rules - Classic Vegas (same as standard)
    static var ruby: GameRules {
        return .standard
    }

    /// Lucky's rules - Player-friendly with free doubles and splits
    static var lucky: GameRules {
        return GameRules(
            numberOfDecks: 1, // Single deck
            dealerHitsSoft17: false,
            doubleOnlyOn: nil,
            doubleAfterSplit: true,
            maxSplitHands: 4,
            resplitAces: true, // Can re-split aces
            splitAcesOneCardOnly: false, // Split aces get normal play
            surrenderAllowed: true, // Late surrender
            earlySurrender: false,
            blackjackPayout: 1.5,
            minimumBetMultiplier: 1.0,
            freeDoubles: true, // 🍀 Lucky's special!
            freeSplits: true   // 🍀 Lucky's special!
        )
    }

    /// Shark's rules - Aggressive high roller rules
    static var shark: GameRules {
        return GameRules(
            numberOfDecks: 8, // More decks = higher house edge
            dealerHitsSoft17: true, // Dealer more aggressive
            doubleOnlyOn: [9, 10, 11], // Restricted doubles
            doubleAfterSplit: false, // No double after split
            maxSplitHands: 2, // Can only split once
            resplitAces: false,
            splitAcesOneCardOnly: true,
            surrenderAllowed: false,
            earlySurrender: false,
            blackjackPayout: 1.2, // 6:5 (ouch!)
            minimumBetMultiplier: 5.0, // 🦈 High stakes only!
            freeDoubles: false,
            freeSplits: false
        )
    }

    /// Zen's rules - Favourable rules for learning
    static var zen: GameRules {
        return GameRules(
            numberOfDecks: 2,
            dealerHitsSoft17: false,
            doubleOnlyOn: nil,
            doubleAfterSplit: true,
            maxSplitHands: 4,
            resplitAces: true, // Can re-split aces
            splitAcesOneCardOnly: false, // More flexible
            surrenderAllowed: true,
            earlySurrender: true, // 🧘 Early surrender (rare and valuable)
            blackjackPayout: 1.5,
            minimumBetMultiplier: 1.0,
            freeDoubles: false,
            freeSplits: false
        )
    }

    /// Blitz's rules - Same as Ruby for now (timer is Phase 7)
    static var blitz: GameRules {
        return .standard
    }

    /// Maverick's base rules - Will be randomised each shoe
    /// This is just a placeholder; actual rules generated by MaverickRuleGenerator
    static var maverickBase: GameRules {
        return .standard
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create standard rules:                                                     ║
// ║   let rules = GameRules.standard                                           ║
// ║   print(rules.approximateHouseEdge)  // ~0.55%                             ║
// ║                                                                            ║
// ║ Create Lucky's rules:                                                      ║
// ║   let luckyRules = GameRules.lucky                                         ║
// ║   print(luckyRules.freeDoubles)  // true                                   ║
// ║   print(luckyRules.approximateHouseEdge)  // ~-0.5% (player advantage!)    ║
// ║                                                                            ║
// ║ Create Shark's rules:                                                      ║
// ║   let sharkRules = GameRules.shark                                         ║
// ║   print(sharkRules.blackjackPayout)  // 1.2 (6:5)                          ║
// ║   print(sharkRules.minimumBetMultiplier)  // 5.0                           ║
// ║   print(sharkRules.approximateHouseEdge)  // ~2.0%                         ║
// ║                                                                            ║
// ║ Check rule in gameplay:                                                    ║
// ║   if rules.dealerHitsSoft17 && dealerHand.isSoft && dealerHand.total == 17 {                                                                            ║
// ║       // Dealer must hit                                                   ║
// ║   }                                                                         ║
// ║                                                                            ║
// ║   if let restrictedTotals = rules.doubleOnlyOn {                           ║
// ║       if restrictedTotals.contains(playerHand.total) {                     ║
// ║           // Can double                                                    ║
// ║       }                                                                     ║
// ║   }                                                                         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
