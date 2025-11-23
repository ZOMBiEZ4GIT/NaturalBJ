//
//  Dealer.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 3: Dealer Personalities & Rule Variations
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👥 DEALER MODEL                                                            ║
// ║                                                                            ║
// ║ Purpose: Represents a blackjack dealer with unique personality and rules  ║
// ║ Business Context: Each dealer is a themed avatar that encapsulates a      ║
// ║                   rule set. Instead of complex settings menus, players    ║
// ║                   choose their experience by choosing their dealer.       ║
// ║                   This makes rule selection intuitive and memorable!      ║
// ║                                                                            ║
// ║ Design Philosophy:                                                         ║
// ║ • "Play against Ruby" is more engaging than "6-deck S17 DAS"             ║
// ║ • Each dealer has distinct personality and visual identity                ║
// ║ • Players naturally learn rule differences through dealer personalities   ║
// ║ • Makes switching rule sets fun rather than tedious                       ║
// ║                                                                            ║
// ║ The Six Dealers:                                                           ║
// ║ • Ruby ♦️: Classic Vegas pro (standard rules, fair)                       ║
// ║ • Lucky 🍀: Player's friend (free doubles/splits, generous)               ║
// ║ • Shark 🦈: High roller (tough rules, high stakes)                        ║
// ║ • Zen 🧘: Teacher (optimal rules, helps learn)                            ║
// ║ • Blitz ⚡: Speed demon (fast-paced, timer in Phase 7)                    ║
// ║ • Maverick 🎲: Wild card (random rules each shoe)                         ║
// ║                                                                            ║
// ║ Used By: • GameViewModel (tracks current dealer)                          ║
// ║          • DealerSelectionView (displays available dealers)               ║
// ║          • GameView (shows dealer avatar and theme)                       ║
// ║                                                                            ║
// ║ Related Spec: See "Dealer Personalities & Rule Sets" (lines 16-127)       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI

struct Dealer: Identifiable, Codable, Equatable {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🆔 CORE PROPERTIES                                                   │
    // └─────────────────────────────────────────────────────────────────────┘

    let id: UUID
    let name: String
    let tagline: String
    let personality: String // Full description for dealer selection screen
    let avatarName: String // SF Symbol name (e.g., "suit.diamond.fill")
    let rules: GameRules

    // Theme colour is stored as RGB components for Codable conformance
    private let themeColorRed: Double
    private let themeColorGreen: Double
    private let themeColorBlue: Double

    /// Theme colour for UI elements
    var themeColor: Color {
        return Color(red: themeColorRed, green: themeColorGreen, blue: themeColorBlue)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 COMPUTED PROPERTIES                                               │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Approximate house edge percentage (for display)
    var houseEdge: Double {
        return rules.approximateHouseEdge
    }

    /// House edge formatted as string
    var houseEdgeString: String {
        let edge = houseEdge
        if edge < 0 {
            return String(format: "%.2f%% (Player Advantage!)", abs(edge))
        } else {
            return String(format: "%.2f%%", edge)
        }
    }

    /// Minimum bet (applied to base minimum)
    var minimumBetDescription: String {
        if rules.minimumBetMultiplier == 1.0 {
            return "Standard"
        } else {
            return "\(Int(rules.minimumBetMultiplier))x Standard"
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                       │
    // │                                                                      │
    // │ Note: Private init - use factory methods below instead              │
    // └─────────────────────────────────────────────────────────────────────┘

    private init(
        id: UUID = UUID(),
        name: String,
        tagline: String,
        personality: String,
        avatarName: String,
        themeColor: Color,
        rules: GameRules
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.personality = personality
        self.avatarName = avatarName
        self.rules = rules

        // Convert Color to RGB for Codable
        let uiColor = UIColor(themeColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        self.themeColorRed = Double(red)
        self.themeColorGreen = Double(green)
        self.themeColorBlue = Double(blue)
    }

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║ 🏭 FACTORY METHODS - THE SIX DEALERS                                       ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ♦️ RUBY - THE VEGAS CLASSIC                                          │
    // │                                                                      │
    // │ Personality: Professional, by-the-book, classic Vegas energy        │
    // │ House Edge: ~0.55%                                                   │
    // │                                                                      │
    // │ Ruby is the default dealer. She's professional, reliable, and fair. │
    // │ Think classic Las Vegas - glamorous but serious about the game.     │
    // │ She doesn't offer any special deals, but she doesn't try to take    │
    // │ advantage either. Perfect for players who want authentic casino     │
    // │ blackjack with standard rules.                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    static func ruby() -> Dealer {
        return Dealer(
            name: "Ruby",
            tagline: "Let's keep it traditional",
            personality: "Professional and by-the-book. Ruby brings classic Vegas energy with standard casino rules. Fair, glamorous, and serious about the game.",
            avatarName: "suit.diamond.fill",
            themeColor: Color(red: 1.0, green: 0.23, blue: 0.19), // #FF3B30
            rules: .ruby
        )
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🍀 LUCKY - THE PLAYER'S FRIEND                                       │
    // │                                                                      │
    // │ Personality: Generous, laid-back, rooting for you                   │
    // │ House Edge: ~-0.5% (Player advantage!)                              │
    // │                                                                      │
    // │ Lucky is the most player-friendly dealer. He actually wants you     │
    // │ to win! Free doubles and splits mean you can make aggressive        │
    // │ strategic moves without risking extra money. This is the dealer     │
    // │ for players who want to feel like the house is on their side.       │
    // │ Perfect for learning or building confidence.                        │
    // │                                                                      │
    // │ Special Features:                                                    │
    // │ • Free doubles: Double down costs nothing (still get one card)      │
    // │ • Free splits: Split costs nothing, cards dealt as normal           │
    // │ • Single deck: Better odds for player                               │
    // │ • Re-split aces allowed                                             │
    // │ • Late surrender available                                          │
    // └─────────────────────────────────────────────────────────────────────┘

    static func lucky() -> Dealer {
        return Dealer(
            name: "Lucky",
            tagline: "I'm on your side!",
            personality: "Generous and laid-back. Lucky genuinely wants you to win. Free doubles and splits make every hand an opportunity. Perfect for learning and having fun!",
            avatarName: "clover.fill",
            themeColor: Color(red: 1.0, green: 0.84, blue: 0.0), // #FFD700 (gold)
            rules: .lucky
        )
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🦈 SHARK - THE HIGH ROLLER                                           │
    // │                                                                      │
    // │ Personality: Aggressive, confident, high stakes                     │
    // │ House Edge: ~2.0%                                                    │
    // │                                                                      │
    // │ Shark is for high rollers who want intense action. The rules are    │
    // │ tougher and the house edge is higher, but the minimum bet forces    │
    // │ you to play big. Every hand matters. This dealer appeals to         │
    // │ experienced players who want to feel the pressure and excitement    │
    // │ of high-stakes gambling.                                            │
    // │                                                                      │
    // │ Special Features:                                                    │
    // │ • 5x minimum bet (if base is $10, Shark's is $50)                   │
    // │ • 6:5 blackjack payout (controversial but part of persona)          │
    // │ • Dealer hits soft 17 (more aggressive)                             │
    // │ • Restricted doubles (9, 10, 11 only)                               │
    // │ • Single split only (2 hands max)                                   │
    // │ • 8-deck shoe (harder to count)                                     │
    // └─────────────────────────────────────────────────────────────────────┘

    static func shark() -> Dealer {
        return Dealer(
            name: "Shark",
            tagline: "Big risks, big rewards",
            personality: "Aggressive and intimidating. Shark plays for high stakes with tough rules. The house edge is steep, but so are the thrills. Are you ready to swim with the sharks?",
            avatarName: "triangle.fill", // Represents shark fin
            themeColor: Color(red: 0.04, green: 0.52, blue: 1.0), // #0A84FF (sharp blue)
            rules: .shark
        )
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🧘 ZEN - THE TEACHER                                                 │
    // │                                                                      │
    // │ Personality: Calm, patient, educational                             │
    // │ House Edge: ~0.35%                                                   │
    // │                                                                      │
    // │ Zen is the teacher. She's patient, never rushes you, and actively   │
    // │ helps you learn optimal strategy. Her rules are player-friendly     │
    // │ (early surrender, re-split aces), making her perfect for beginners  │
    // │ or players who want to improve their game. She's calm and           │
    // │ encouraging, never judgmental.                                       │
    // │                                                                      │
    // │ Special Features:                                                    │
    // │ • Early surrender (rare and valuable - can surrender before dealer  │
    // │   checks for blackjack)                                             │
    // │ • Re-split aces allowed                                             │
    // │ • 2-deck shoe (better for learning card counting)                   │
    // │ • Basic strategy hints (Phase 8 feature)                            │
    // │ • Hand probabilities on request (Phase 8 feature)                   │
    // └─────────────────────────────────────────────────────────────────────┘

    static func zen() -> Dealer {
        return Dealer(
            name: "Zen",
            tagline: "Learn the way",
            personality: "Calm and patient teacher. Zen helps you learn optimal blackjack strategy with favourable rules and encouraging guidance. Perfect for improving your game.",
            avatarName: "circle.fill",
            themeColor: Color(red: 0.69, green: 0.32, blue: 0.87), // #AF52DE (purple/zen)
            rules: .zen
        )
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ⚡ BLITZ - THE SPEED DEMON                                           │
    // │                                                                      │
    // │ Personality: Fast-paced, energetic, quick decisions                 │
    // │ House Edge: ~0.55% (same as Ruby)                                    │
    // │                                                                      │
    // │ Blitz is for players who want rapid-fire action. No time to         │
    // │ overthink - trust your instincts! The 5-second timer adds pressure  │
    // │ but also excitement. Quick decisions lead to bonus payouts,         │
    // │ encouraging fast play. Perfect for experienced players who find     │
    // │ normal blackjack too slow.                                          │
    // │                                                                      │
    // │ Special Features (Phase 7):                                         │
    // │ • 5-second decision timer on each action                            │
    // │ • Speed multiplier - faster wins = bigger bonuses                   │
    // │ • Streak bonuses for consecutive quick wins                         │
    // │                                                                      │
    // │ Phase 3 Note: Timer features are Phase 7. For now, Blitz uses       │
    // │ standard rules (same as Ruby) but with speed-themed personality.    │
    // └─────────────────────────────────────────────────────────────────────┘

    static func blitz() -> Dealer {
        return Dealer(
            name: "Blitz",
            tagline: "Let's go! No time to waste!",
            personality: "High-energy speed demon. Blitz keeps the game moving at lightning pace. Quick decisions, fast action, and exciting gameplay for experienced players.",
            avatarName: "bolt.fill",
            themeColor: Color(red: 1.0, green: 0.58, blue: 0.0), // #FF9500 (orange/lightning)
            rules: .blitz
        )
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎲 MAVERICK - THE WILD CARD                                          │
    // │                                                                      │
    // │ Personality: Unpredictable, fun, experimental                       │
    // │ House Edge: 0.4% - 0.8% (varies by shoe)                            │
    // │                                                                      │
    // │ Maverick is chaos incarnate - in a fun way! You never know what     │
    // │ rules you'll get each shoe. One shoe might have super favourable    │
    // │ rules, the next might be tougher. Keeps gameplay fresh and          │
    // │ surprising. Perfect for players who get bored with standard         │
    // │ blackjack. Maverick has a playful, mischievous personality -        │
    // │ always mixing things up.                                            │
    // │                                                                      │
    // │ Special Features:                                                    │
    // │ • Rules randomise each shoe (75% penetration)                       │
    // │ • Always fair (house edge kept between 0.4% - 0.8%)                 │
    // │ • Current rules displayed prominently                               │
    // │ • Wild rules possible (Phase 6):                                    │
    // │   - 5-card charlie (automatic win with 5 cards)                     │
    // │   - Suited blackjack pays 2:1                                       │
    // │   - 777 bonus pays 3:1                                              │
    // │ • Mystery bonus rounds (Phase 6)                                    │
    // │                                                                      │
    // │ Phase 3 Note: Maverick starts with standard rules. MaverickRule-    │
    // │ Generator will randomise rules when shoe is reshuffled.             │
    // └─────────────────────────────────────────────────────────────────────┘

    static func maverick() -> Dealer {
        return Dealer(
            name: "Maverick",
            tagline: "Expect the unexpected",
            personality: "Unpredictable wild card. Maverick changes the rules each shoe, keeping you on your toes. Never boring, always fair, and full of surprises!",
            avatarName: "dice.fill",
            themeColor: Color(red: 0.5, green: 0.0, blue: 0.5), // Purple (will use gradient in UI)
            rules: .maverickBase // Will be randomised by MaverickRuleGenerator
        )
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📚 ALL DEALERS COLLECTION                                            │
    // │                                                                      │
    // │ Returns array of all 6 dealers for selection screen                 │
    // └─────────────────────────────────────────────────────────────────────┘

    static var allDealers: [Dealer] {
        return [
            ruby(),
            lucky(),
            shark(),
            zen(),
            blitz(),
            maverick()
        ]
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔍 FIND DEALER BY NAME                                               │
    // │                                                                      │
    // │ Convenience method for restoring dealer from UserDefaults           │
    // └─────────────────────────────────────────────────────────────────────┘

    static func dealer(named name: String) -> Dealer? {
        return allDealers.first { $0.name == name }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📜 DEALER RULE SUMMARY HELPER                                              ║
// ║                                                                            ║
// ║ Extension to generate human-readable rule summaries for UI display        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Dealer {
    /// Returns formatted list of key rules for display
    var rulesSummary: [String] {
        var summary: [String] = []

        // Deck count
        summary.append("\(rules.numberOfDecks) deck\(rules.numberOfDecks > 1 ? "s" : "")")

        // Dealer behaviour
        summary.append(rules.dealerHitsSoft17 ? "Dealer hits soft 17" : "Dealer stands on soft 17")

        // Blackjack payout
        if rules.blackjackPayout == 1.5 {
            summary.append("Blackjack pays 3:2")
        } else if rules.blackjackPayout == 1.2 {
            summary.append("Blackjack pays 6:5")
        }

        // Double rules
        if let restrictedTotals = rules.doubleOnlyOn {
            summary.append("Double on \(restrictedTotals.map(String.init).joined(separator: ", ")) only")
        } else {
            summary.append("Double on any two cards")
        }

        if rules.doubleAfterSplit {
            summary.append("Double after split allowed")
        }

        // Split rules
        summary.append("Split up to \(rules.maxSplitHands) hands")

        if rules.resplitAces {
            summary.append("Re-split aces allowed")
        }

        if rules.splitAcesOneCardOnly {
            summary.append("Split aces get one card each")
        }

        // Surrender
        if rules.surrenderAllowed {
            if rules.earlySurrender {
                summary.append("Early surrender allowed")
            } else {
                summary.append("Late surrender allowed")
            }
        } else {
            summary.append("No surrender")
        }

        // Special features
        if rules.freeDoubles {
            summary.append("🍀 Free doubles")
        }

        if rules.freeSplits {
            summary.append("🍀 Free splits")
        }

        if rules.minimumBetMultiplier > 1.0 {
            summary.append("🦈 Minimum bet: \(Int(rules.minimumBetMultiplier))x")
        }

        return summary
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Get Ruby dealer:                                                           ║
// ║   let ruby = Dealer.ruby()                                                 ║
// ║   print(ruby.name)        // "Ruby"                                        ║
// ║   print(ruby.tagline)     // "Let's keep it traditional"                   ║
// ║   print(ruby.houseEdge)   // ~0.55                                         ║
// ║                                                                            ║
// ║ Get all dealers:                                                           ║
// ║   let dealers = Dealer.allDealers                                          ║
// ║   // [Ruby, Lucky, Shark, Zen, Blitz, Maverick]                            ║
// ║                                                                            ║
// ║ Display dealer rules:                                                      ║
// ║   let lucky = Dealer.lucky()                                               ║
// ║   for rule in lucky.rulesSummary {                                         ║
// ║       print("• \(rule)")                                                   ║
// ║   }                                                                         ║
// ║   // • 1 deck                                                              ║
// ║   // • Dealer stands on soft 17                                            ║
// ║   // • Blackjack pays 3:2                                                  ║
// ║   // • 🍀 Free doubles                                                     ║
// ║   // • 🍀 Free splits                                                      ║
// ║                                                                            ║
// ║ Use in SwiftUI:                                                            ║
// ║   @State private var currentDealer = Dealer.ruby()                         ║
// ║                                                                            ║
// ║   var body: some View {                                                    ║
// ║       VStack {                                                             ║
// ║           Image(systemName: currentDealer.avatarName)                      ║
// ║               .foregroundColor(currentDealer.themeColor)                   ║
// ║           Text(currentDealer.name)                                         ║
// ║           Text(currentDealer.tagline)                                      ║
// ║       }                                                                     ║
// ║   }                                                                         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
