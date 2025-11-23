//
//  Achievement.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 8: Achievements & Progression System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏆 ACHIEVEMENT MODEL                                                       ║
// ║                                                                            ║
// ║ Purpose: Represents unlockable achievements and milestones                ║
// ║ Business Context: Players want recognition for their accomplishments.     ║
// ║                   Achievements provide goals, track progress, and reward  ║
// ║                   players with XP and visual badges for engagement.       ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Define achievement categories and difficulty tiers                      ║
// ║ • Track achievement progress (current/required)                           ║
// ║ • Store unlock status and date                                            ║
// ║ • Provide display strings and badge identifiers                           ║
// ║ • Calculate completion percentage                                         ║
// ║                                                                            ║
// ║ Used By: AchievementManager (defines and tracks all achievements)         ║
// ║          AchievementsView (displays achievement progress)                 ║
// ║          AchievementCardView (shows individual achievement cards)         ║
// ║                                                                            ║
// ║ Related Spec: See "Achievements & Progression System" Phase 8             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎯 ACHIEVEMENT CATEGORY ENUMERATION                                        ║
// ║                                                                            ║
// ║ Categorises achievements for filtering and organisation                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum AchievementCategory: String, Codable, CaseIterable {
    case milestone      // Hands played, sessions completed
    case performance    // Win streaks, blackjack count
    case mastery        // Perfect strategy plays, advanced techniques
    case discovery      // Try all dealers, unlock all features
    case special        // Rare events, Easter eggs

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 DISPLAY PROPERTIES                                            │
    // └─────────────────────────────────────────────────────────────────┘

    /// Display name for UI
    var displayName: String {
        switch self {
        case .milestone: return "Milestones"
        case .performance: return "Performance"
        case .mastery: return "Mastery"
        case .discovery: return "Discovery"
        case .special: return "Special"
        }
    }

    /// Icon for category
    var icon: String {
        switch self {
        case .milestone: return "🎯"
        case .performance: return "🏆"
        case .mastery: return "🎓"
        case .discovery: return "🔍"
        case .special: return "⭐"
        }
    }

    /// Description of category
    var description: String {
        switch self {
        case .milestone: return "Reach significant play milestones"
        case .performance: return "Demonstrate exceptional gameplay"
        case .mastery: return "Master advanced blackjack techniques"
        case .discovery: return "Explore all game features and dealers"
        case .special: return "Unlock rare and unique achievements"
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 💎 ACHIEVEMENT DIFFICULTY TIER                                             ║
// ║                                                                            ║
// ║ Defines difficulty levels for achievements                                ║
// ║ Higher tiers award more XP and have more prestigious badges                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum AchievementTier: String, Codable, CaseIterable {
    case bronze
    case silver
    case gold
    case platinum

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 DISPLAY PROPERTIES                                            │
    // └─────────────────────────────────────────────────────────────────┘

    /// Display name
    var displayName: String {
        rawValue.capitalized
    }

    /// Medal emoji
    var medal: String {
        switch self {
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🥇"
        case .platinum: return "💎"
        }
    }

    /// XP reward for unlocking this tier
    var xpReward: Int {
        switch self {
        case .bronze: return 100
        case .silver: return 250
        case .gold: return 500
        case .platinum: return 1000
        }
    }

    /// Colour for UI (SwiftUI colour name)
    var colourName: String {
        switch self {
        case .bronze: return "orange"
        case .silver: return "gray"
        case .gold: return "yellow"
        case .platinum: return "cyan"
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏆 ACHIEVEMENT STRUCTURE                                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct Achievement: Codable, Identifiable, Equatable {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 IDENTIFICATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Unique identifier (used for tracking progress)
    let id: String

    /// Achievement name
    let name: String

    /// Detailed description
    let description: String

    /// Hint for how to unlock (shown when locked)
    let unlockHint: String

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎯 CATEGORISATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Category for filtering
    let category: AchievementCategory

    /// Difficulty tier
    let tier: AchievementTier

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROGRESS TRACKING                                             │
    // └─────────────────────────────────────────────────────────────────┘

    /// Current progress (e.g., 50 hands played)
    var currentProgress: Int

    /// Required progress to unlock (e.g., 100 hands needed)
    let requiredProgress: Int

    /// Is this achievement unlocked?
    var isUnlocked: Bool

    /// Date/time when unlocked (nil if still locked)
    var unlockedDate: Date?

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 VISUAL PROPERTIES                                             │
    // └─────────────────────────────────────────────────────────────────┘

    /// Icon/badge identifier (emoji or system image name)
    let iconName: String

    /// Whether this is a hidden achievement (show ??? until unlocked)
    let isHidden: Bool

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    init(
        id: String,
        name: String,
        description: String,
        unlockHint: String,
        category: AchievementCategory,
        tier: AchievementTier,
        currentProgress: Int = 0,
        requiredProgress: Int,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil,
        iconName: String,
        isHidden: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.unlockHint = unlockHint
        self.category = category
        self.tier = tier
        self.currentProgress = currentProgress
        self.requiredProgress = requiredProgress
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.iconName = iconName
        self.isHidden = isHidden
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 COMPUTED PROPERTIES                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Achievement {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 PROGRESS CALCULATION                                          │
    // └─────────────────────────────────────────────────────────────────┘

    /// Progress as percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard requiredProgress > 0 else { return isUnlocked ? 1.0 : 0.0 }
        return min(Double(currentProgress) / Double(requiredProgress), 1.0)
    }

    /// Progress as percentage (0 to 100)
    var progressPercentageInt: Int {
        return Int(progressPercentage * 100)
    }

    /// Formatted progress string (e.g., "50/100")
    var progressString: String {
        if isUnlocked {
            return "✓ Unlocked"
        }
        return "\(currentProgress)/\(requiredProgress)"
    }

    /// Is this achievement in progress (some progress but not unlocked)?
    var isInProgress: Bool {
        return !isUnlocked && currentProgress > 0
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 DISPLAY HELPERS                                               │
    // └─────────────────────────────────────────────────────────────────┘

    /// Display name (hidden achievements show ??? until unlocked)
    var displayName: String {
        if isHidden && !isUnlocked {
            return "???"
        }
        return name
    }

    /// Display description (hidden achievements show hint until unlocked)
    var displayDescription: String {
        if isHidden && !isUnlocked {
            return "Hidden Achievement"
        }
        return description
    }

    /// Formatted unlock date
    var formattedUnlockDate: String {
        guard let date = unlockedDate else {
            return "Locked"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// XP reward for this achievement
    var xpReward: Int {
        return tier.xpReward
    }

    /// Full title with tier (e.g., "🥇 Blackjack Master")
    var fullTitle: String {
        return "\(tier.medal) \(displayName)"
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🛠️ MUTATING METHODS                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Achievement {

    /// Update progress towards this achievement
    /// Returns true if this update unlocked the achievement
    mutating func updateProgress(_ newProgress: Int) -> Bool {
        // Don't update if already unlocked
        guard !isUnlocked else { return false }

        currentProgress = newProgress

        // Check if we should unlock
        if currentProgress >= requiredProgress {
            unlock()
            return true
        }

        return false
    }

    /// Increment progress by specified amount
    /// Returns true if this increment unlocked the achievement
    mutating func incrementProgress(by amount: Int = 1) -> Bool {
        return updateProgress(currentProgress + amount)
    }

    /// Manually unlock this achievement
    mutating func unlock() {
        guard !isUnlocked else { return }

        isUnlocked = true
        currentProgress = requiredProgress
        unlockedDate = Date()
    }

    /// Reset achievement (for testing/debugging)
    mutating func reset() {
        isUnlocked = false
        currentProgress = 0
        unlockedDate = nil
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create an achievement:                                                     ║
// ║   var achievement = Achievement(                                           ║
// ║       id: "first_hand",                                                    ║
// ║       name: "First Hand",                                                 ║
// ║       description: "Play your first hand of blackjack",                   ║
// ║       unlockHint: "Place a bet and play a hand",                          ║
// ║       category: .milestone,                                               ║
// ║       tier: .bronze,                                                      ║
// ║       requiredProgress: 1,                                                ║
// ║       iconName: "🎴"                                                       ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Update progress:                                                           ║
// ║   if achievement.incrementProgress() {                                    ║
// ║       print("Achievement unlocked! +\(achievement.xpReward) XP")          ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ Check progress:                                                            ║
// ║   print("Progress: \(achievement.progressString)")                        ║
// ║   print("\(achievement.progressPercentageInt)% complete")                 ║
// ║                                                                            ║
// ║ Display in UI:                                                             ║
// ║   Text(achievement.fullTitle)                                             ║
// ║   Text(achievement.displayDescription)                                    ║
// ║   ProgressView(value: achievement.progressPercentage)                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
