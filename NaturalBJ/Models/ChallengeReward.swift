//
//  ChallengeReward.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 9: Daily Challenges & Events System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎁 CHALLENGE REWARD MODEL                                                  ║
// ║                                                                            ║
// ║ Purpose: Represents rewards given for completing challenges               ║
// ║ Business Context: Rewards motivate players to complete challenges and     ║
// ║                   provide tangible benefits (XP, chips, cosmetics).       ║
// ║                   Multiple reward types encourage different play styles.  ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Define reward types and values                                          ║
// ║ • Provide display formatting                                              ║
// ║ • Support encoding/decoding for persistence                               ║
// ║                                                                            ║
// ║ Used By: Challenge (contains reward array)                                ║
// ║          ChallengeManager (distributes rewards)                           ║
// ║          ChallengeCardView (displays reward preview)                      ║
// ║          ChallengeCompletionView (shows rewards earned)                   ║
// ║                                                                            ║
// ║ Related Spec: See "Daily Challenges & Events System" Phase 9              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎁 CHALLENGE REWARD STRUCTURE                                              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct ChallengeReward: Codable, Equatable, Identifiable {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 IDENTIFICATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Unique ID for SwiftUI List
    var id: UUID = UUID()

    /// Type of reward
    let type: RewardType

    /// Value of reward (interpretation depends on type)
    let value: Int

    /// Optional identifier for cosmetic rewards
    let identifier: String?

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    init(
        type: RewardType,
        value: Int,
        identifier: String? = nil
    ) {
        self.type = type
        self.value = value
        self.identifier = identifier
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏷️ REWARD TYPE ENUMERATION                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum RewardType: String, Codable, CaseIterable {
    case xp                     // Experience points
    case xpMultiplier           // XP multiplier (e.g., 2x for 1 hour)
    case chips                  // Bonus chips/bankroll boost
    case cardBack               // Exclusive card back unlock
    case tableFelt              // Exclusive table felt unlock
    case achievementBoost       // Progress boost for achievements
    case streakProtection       // Insurance against breaking streaks

    var displayName: String {
        switch self {
        case .xp:
            return "XP"
        case .xpMultiplier:
            return "XP Multiplier"
        case .chips:
            return "Chips"
        case .cardBack:
            return "Card Back"
        case .tableFelt:
            return "Table Felt"
        case .achievementBoost:
            return "Achievement Boost"
        case .streakProtection:
            return "Streak Protection"
        }
    }

    var iconName: String {
        switch self {
        case .xp:
            return "⭐"
        case .xpMultiplier:
            return "✨"
        case .chips:
            return "💰"
        case .cardBack:
            return "🃏"
        case .tableFelt:
            return "🎨"
        case .achievementBoost:
            return "🚀"
        case .streakProtection:
            return "🛡️"
        }
    }

    var colour: String {
        switch self {
        case .xp:
            return "blue"
        case .xpMultiplier:
            return "purple"
        case .chips:
            return "green"
        case .cardBack:
            return "orange"
        case .tableFelt:
            return "pink"
        case .achievementBoost:
            return "yellow"
        case .streakProtection:
            return "red"
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 COMPUTED PROPERTIES                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension ChallengeReward {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 DISPLAY FORMATTING                                            │
    // └─────────────────────────────────────────────────────────────────┘

    /// Formatted display text
    var displayText: String {
        switch type {
        case .xp:
            return "+\(value) XP"
        case .xpMultiplier:
            return "\(value)x XP Boost"
        case .chips:
            return "+$\(value)"
        case .cardBack:
            return identifier ?? "Exclusive Card Back"
        case .tableFelt:
            return identifier ?? "Exclusive Table Felt"
        case .achievementBoost:
            return "\(value)% Achievement Boost"
        case .streakProtection:
            return "Streak Shield"
        }
    }

    /// Short display (for compact views)
    var shortDisplay: String {
        switch type {
        case .xp:
            return "\(value) XP"
        case .xpMultiplier:
            return "\(value)x XP"
        case .chips:
            return "$\(value)"
        case .cardBack:
            return "🃏 Card"
        case .tableFelt:
            return "🎨 Felt"
        case .achievementBoost:
            return "\(value)% Boost"
        case .streakProtection:
            return "🛡️ Shield"
        }
    }

    /// Full display with icon
    var fullDisplay: String {
        return "\(type.iconName) \(displayText)"
    }

    /// Is cosmetic reward (card back, table felt)
    var isCosmetic: Bool {
        return type == .cardBack || type == .tableFelt
    }

    /// Is temporary boost
    var isTemporary: Bool {
        return type == .xpMultiplier || type == .achievementBoost || type == .streakProtection
    }

    /// Description of the reward
    var description: String {
        switch type {
        case .xp:
            return "Earn \(value) experience points towards your next level"
        case .xpMultiplier:
            return "Multiply all XP earned by \(value)x for the next hour"
        case .chips:
            return "Receive $\(value) bonus chips added to your bankroll"
        case .cardBack:
            return "Unlock an exclusive card back design: \(identifier ?? "Mystery")"
        case .tableFelt:
            return "Unlock an exclusive table felt colour: \(identifier ?? "Mystery")"
        case .achievementBoost:
            return "Gain \(value)% extra progress towards all achievements"
        case .streakProtection:
            return "Protect your win streak from breaking once"
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏭 FACTORY METHODS                                                         ║
// ║                                                                            ║
// ║ Convenience methods for creating common reward types                      ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension ChallengeReward {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏭 COMMON REWARD FACTORIES                                       │
    // └─────────────────────────────────────────────────────────────────┘

    /// Create XP reward
    static func xp(_ amount: Int) -> ChallengeReward {
        return ChallengeReward(type: .xp, value: amount)
    }

    /// Create chip reward
    static func chips(_ amount: Int) -> ChallengeReward {
        return ChallengeReward(type: .chips, value: amount)
    }

    /// Create XP multiplier (value = multiplier, e.g., 2 for 2x)
    static func xpBoost(multiplier: Int) -> ChallengeReward {
        return ChallengeReward(type: .xpMultiplier, value: multiplier)
    }

    /// Create card back unlock
    static func cardBack(named name: String) -> ChallengeReward {
        return ChallengeReward(type: .cardBack, value: 1, identifier: name)
    }

    /// Create table felt unlock
    static func tableFelt(named name: String) -> ChallengeReward {
        return ChallengeReward(type: .tableFelt, value: 1, identifier: name)
    }

    /// Create achievement boost (value = percentage, e.g., 25 for 25%)
    static func achievementBoost(percent: Int) -> ChallengeReward {
        return ChallengeReward(type: .achievementBoost, value: percent)
    }

    /// Create streak protection
    static func streakProtection() -> ChallengeReward {
        return ChallengeReward(type: .streakProtection, value: 1)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📦 REWARD BUNDLES                                                          ║
// ║                                                                            ║
// ║ Pre-defined reward combinations for different difficulty tiers            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Array where Element == ChallengeReward {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📦 STANDARD DAILY REWARD BUNDLES                                 │
    // └─────────────────────────────────────────────────────────────────┘

    /// Easy daily challenge rewards (50-75 XP)
    static func easyDaily() -> [ChallengeReward] {
        return [.xp(50)]
    }

    /// Medium daily challenge rewards (100-150 XP)
    static func mediumDaily() -> [ChallengeReward] {
        return [.xp(100)]
    }

    /// Hard daily challenge rewards (200-250 XP)
    static func hardDaily() -> [ChallengeReward] {
        return [.xp(200)]
    }

    /// Expert daily challenge rewards (300+ XP)
    static func expertDaily() -> [ChallengeReward] {
        return [.xp(300)]
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📦 WEEKLY REWARD BUNDLES                                         │
    // └─────────────────────────────────────────────────────────────────┘

    /// Easy weekly challenge rewards (500 XP)
    static func easyWeekly() -> [ChallengeReward] {
        return [.xp(500)]
    }

    /// Medium weekly challenge rewards (750 XP)
    static func mediumWeekly() -> [ChallengeReward] {
        return [.xp(750), .chips(1000)]
    }

    /// Hard weekly challenge rewards (1000 XP + bonus)
    static func hardWeekly() -> [ChallengeReward] {
        return [.xp(1000), .chips(2500)]
    }

    /// Expert weekly challenge rewards (1500 XP + cosmetic)
    static func expertWeekly(cosmetic: String) -> [ChallengeReward] {
        return [.xp(1500), .chips(5000), .cardBack(named: cosmetic)]
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📦 SPECIAL EVENT BUNDLES                                         │
    // └─────────────────────────────────────────────────────────────────┘

    /// Weekend warrior rewards (2x XP)
    static func weekendWarrior() -> [ChallengeReward] {
        return [.xpBoost(multiplier: 2)]
    }

    /// Holiday special rewards
    static func holidaySpecial(cosmetic: String) -> [ChallengeReward] {
        return [.xp(1000), .chips(10000), .tableFelt(named: cosmetic)]
    }

    /// Streak milestone rewards
    static func streakMilestone(days: Int) -> [ChallengeReward] {
        switch days {
        case 7:
            return [.xp(500), .cardBack(named: "7-Day Streak")]
        case 14:
            return [.xp(1000), .chips(2500)]
        case 30:
            return [.xp(2500), .tableFelt(named: "30-Day Streak")]
        case 60:
            return [.xp(5000), .chips(10000), .cardBack(named: "60-Day Legend")]
        case 90:
            return [.xp(10000), .chips(25000), .tableFelt(named: "90-Day Champion"), .streakProtection()]
        default:
            return [.xp(100 * days)]
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create rewards using factory methods:                                      ║
// ║   let xpReward = ChallengeReward.xp(100)                                  ║
// ║   let chipReward = ChallengeReward.chips(500)                             ║
// ║   let cardReward = ChallengeReward.cardBack(named: "Diamond Elite")       ║
// ║                                                                            ║
// ║ Create reward bundles:                                                     ║
// ║   let dailyRewards: [ChallengeReward] = .mediumDaily()                    ║
// ║   let weeklyRewards: [ChallengeReward] = .hardWeekly()                    ║
// ║                                                                            ║
// ║ Display rewards:                                                           ║
// ║   ForEach(rewards) { reward in                                            ║
// ║       Text(reward.fullDisplay)                                            ║
// ║       Text(reward.description)                                            ║
// ║           .font(.caption)                                                 ║
// ║           .foregroundColour(.secondary)                                    ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ Check reward properties:                                                   ║
// ║   if reward.isCosmetic {                                                  ║
// ║       // Show special cosmetic unlock animation                           ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
