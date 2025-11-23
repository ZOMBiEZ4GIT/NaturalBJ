//
//  Challenge.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 9: Daily Challenges & Events System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎯 CHALLENGE MODEL                                                         ║
// ║                                                                            ║
// ║ Purpose: Represents a time-limited objective for players to complete      ║
// ║ Business Context: Challenges provide daily/weekly goals that encourage    ║
// ║                   regular play and reward specific gameplay patterns.     ║
// ║                   They create a habit loop and give players fresh         ║
// ║                   objectives every day.                                   ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Define challenge objectives and requirements                            ║
// ║ • Track progress towards completion                                       ║
// ║ • Manage time windows (start/end dates)                                   ║
// ║ • Determine availability and expiry                                       ║
// ║ • Encode/decode for persistence                                           ║
// ║                                                                            ║
// ║ Used By: ChallengeManager (manages all challenges)                        ║
// ║          ChallengeCardView (displays challenge UI)                        ║
// ║          ChallengesView (shows active challenges)                         ║
// ║                                                                            ║
// ║ Related Spec: See "Daily Challenges & Events System" Phase 9              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎯 CHALLENGE STRUCTURE                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct Challenge: Identifiable, Codable, Equatable {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 IDENTIFICATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Unique challenge identifier
    let id: String

    /// Display name of the challenge
    let name: String

    /// Description of what the player needs to do
    let description: String

    /// Icon/emoji for the challenge
    let iconName: String

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 CLASSIFICATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Challenge type (daily, weekly, special event)
    let type: ChallengeType

    /// Challenge category (gameplay, performance, exploration)
    let category: ChallengeCategory

    /// Difficulty tier
    let difficulty: ChallengeDifficulty

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎯 PROGRESS TRACKING                                             │
    // └─────────────────────────────────────────────────────────────────┘

    /// Current progress (e.g., 3 out of 5 wins)
    var currentProgress: Int

    /// Required progress to complete
    let requiredProgress: Int

    /// Whether the challenge has been completed
    var isCompleted: Bool

    /// When the challenge was completed (nil if not completed)
    var completedDate: Date?

    /// Whether rewards have been claimed
    var rewardsClaimed: Bool

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⏰ TIME WINDOW                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    /// When the challenge becomes available
    let startDate: Date

    /// When the challenge expires
    let endDate: Date

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎁 REWARDS                                                        │
    // └─────────────────────────────────────────────────────────────────┘

    /// Rewards for completing this challenge
    let rewards: [ChallengeReward]

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎮 CONTEXT (FOR TRACKING)                                        │
    // │                                                                  │
    // │ Optional parameters used for dealer-specific challenges, etc.   │
    // └─────────────────────────────────────────────────────────────────┘

    /// Dealer-specific challenge (nil if applies to all dealers)
    let dealerName: String?

    /// Action-specific challenge context
    let actionType: ChallengeActionType?

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    init(
        id: String,
        name: String,
        description: String,
        iconName: String,
        type: ChallengeType,
        category: ChallengeCategory,
        difficulty: ChallengeDifficulty,
        requiredProgress: Int,
        startDate: Date,
        endDate: Date,
        rewards: [ChallengeReward],
        dealerName: String? = nil,
        actionType: ChallengeActionType? = nil,
        currentProgress: Int = 0,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        rewardsClaimed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.type = type
        self.category = category
        self.difficulty = difficulty
        self.requiredProgress = requiredProgress
        self.startDate = startDate
        self.endDate = endDate
        self.rewards = rewards
        self.dealerName = dealerName
        self.actionType = actionType
        self.currentProgress = currentProgress
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.rewardsClaimed = rewardsClaimed
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏷️ CHALLENGE ENUMERATIONS                                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

// ┌─────────────────────────────────────────────────────────────────────┐
// │ 📅 CHALLENGE TYPE                                                    │
// │                                                                      │
// │ Determines refresh frequency and availability window                │
// └─────────────────────────────────────────────────────────────────────┘

enum ChallengeType: String, Codable, CaseIterable {
    case daily      // Refreshes every 24 hours
    case weekly     // Refreshes every 7 days
    case event      // Special time-limited events (weekend, holiday, etc.)

    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .event: return "Event"
        }
    }

    var iconName: String {
        switch self {
        case .daily: return "☀️"
        case .weekly: return "📅"
        case .event: return "🎉"
        }
    }
}

// ┌─────────────────────────────────────────────────────────────────────┐
// │ 🎯 CHALLENGE CATEGORY                                                │
// │                                                                      │
// │ Groups challenges by gameplay focus                                 │
// └─────────────────────────────────────────────────────────────────────┘

enum ChallengeCategory: String, Codable, CaseIterable {
    case gameplay       // General gameplay (play X hands, etc.)
    case performance    // Skill-based (win streaks, etc.)
    case exploration    // Try dealers, bet amounts, etc.
    case mastery        // Advanced techniques (splits, doubles, etc.)

    var displayName: String {
        switch self {
        case .gameplay: return "Gameplay"
        case .performance: return "Performance"
        case .exploration: return "Exploration"
        case .mastery: return "Mastery"
        }
    }

    var colour: String {
        switch self {
        case .gameplay: return "blue"
        case .performance: return "green"
        case .exploration: return "purple"
        case .mastery: return "orange"
        }
    }
}

// ┌─────────────────────────────────────────────────────────────────────┐
// │ 🌟 CHALLENGE DIFFICULTY                                              │
// │                                                                      │
// │ Determines XP rewards and challenge difficulty                      │
// └─────────────────────────────────────────────────────────────────────┘

enum ChallengeDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
    case expert

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }

    var colour: String {
        switch self {
        case .easy: return "gray"
        case .medium: return "blue"
        case .hard: return "orange"
        case .expert: return "red"
        }
    }

    /// XP multiplier for this difficulty
    var xpMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        case .expert: return 3.0
        }
    }
}

// ┌─────────────────────────────────────────────────────────────────────┐
// │ 🎮 CHALLENGE ACTION TYPE                                             │
// │                                                                      │
// │ Specific player actions to track for challenges                     │
// └─────────────────────────────────────────────────────────────────────┘

enum ChallengeActionType: String, Codable {
    case win
    case blackjack
    case doubleDown
    case split
    case highBet        // Bet over certain amount
    case playHands      // Just play hands
    case winStreak      // Consecutive wins
    case noBust         // Play without busting
    case profit         // End with profit
    case dealerSpecific // Win against specific dealer
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 COMPUTED PROPERTIES                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Challenge {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 PROGRESS                                                      │
    // └─────────────────────────────────────────────────────────────────┘

    /// Progress as percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard requiredProgress > 0 else { return 1.0 }
        return min(Double(currentProgress) / Double(requiredProgress), 1.0)
    }

    /// Formatted progress string (e.g., "3/5")
    var formattedProgress: String {
        return "\(currentProgress)/\(requiredProgress)"
    }

    /// Is in progress (started but not completed)
    var isInProgress: Bool {
        return currentProgress > 0 && !isCompleted
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⏰ TIME STATUS                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    /// Is currently active (within time window)
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    /// Has expired
    var isExpired: Bool {
        return Date() > endDate
    }

    /// Time remaining until expiry
    var timeRemaining: TimeInterval {
        return endDate.timeIntervalSince(Date())
    }

    /// Formatted time remaining
    var formattedTimeRemaining: String {
        let interval = timeRemaining

        if interval <= 0 {
            return "Expired"
        }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours >= 24 {
            let days = hours / 24
            return "\(days)d remaining"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else {
            return "\(minutes)m remaining"
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎁 REWARDS                                                        │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total XP reward
    var totalXPReward: Int {
        return rewards
            .filter { $0.type == .xp }
            .reduce(0) { $0 + $1.value }
    }

    /// Total chip reward
    var totalChipReward: Int {
        return rewards
            .filter { $0.type == .chips }
            .reduce(0) { $0 + $1.value }
    }

    /// Has exclusive cosmetic rewards
    var hasExclusiveRewards: Bool {
        return rewards.contains {
            $0.type == .cardBack || $0.type == .tableFelt
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 DISPLAY                                                        │
    // └─────────────────────────────────────────────────────────────────┘

    /// Full display name with icon
    var displayName: String {
        return "\(iconName) \(name)"
    }

    /// Status badge text
    var statusBadge: String {
        if isCompleted {
            return rewardsClaimed ? "✓ Claimed" : "✓ Complete"
        } else if isExpired {
            return "⏰ Expired"
        } else if isActive {
            return "🎯 Active"
        } else {
            return "🔒 Locked"
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🛠️ MUTATING METHODS                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Challenge {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 UPDATE PROGRESS                                               │
    // │                                                                  │
    // │ Increments progress and checks for completion                   │
    // │ Returns true if challenge was just completed                    │
    // └─────────────────────────────────────────────────────────────────┘

    mutating func updateProgress(_ newProgress: Int) -> Bool {
        guard !isCompleted && isActive else { return false }

        currentProgress = min(newProgress, requiredProgress)

        // Check for completion
        if currentProgress >= requiredProgress && !isCompleted {
            complete()
            return true
        }

        return false
    }

    /// Increment progress by amount
    mutating func incrementProgress(by amount: Int = 1) -> Bool {
        return updateProgress(currentProgress + amount)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ✓ COMPLETE CHALLENGE                                             │
    // │                                                                  │
    // │ Marks challenge as completed with timestamp                     │
    // └─────────────────────────────────────────────────────────────────┘

    mutating func complete() {
        isCompleted = true
        completedDate = Date()
        currentProgress = requiredProgress
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎁 CLAIM REWARDS                                                 │
    // │                                                                  │
    // │ Marks rewards as claimed                                        │
    // └─────────────────────────────────────────────────────────────────┘

    mutating func claimRewards() {
        guard isCompleted && !rewardsClaimed else { return }
        rewardsClaimed = true
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔄 RESET                                                          │
    // │                                                                  │
    // │ Reset progress (used when challenge refreshes)                  │
    // └─────────────────────────────────────────────────────────────────┘

    mutating func reset() {
        currentProgress = 0
        isCompleted = false
        completedDate = nil
        rewardsClaimed = false
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create a daily challenge:                                                  ║
// ║   let challenge = Challenge(                                              ║
// ║       id: "daily_win_3",                                                  ║
// ║       name: "Triple Threat",                                              ║
// ║       description: "Win 3 hands today",                                   ║
// ║       iconName: "🎯",                                                      ║
// ║       type: .daily,                                                       ║
// ║       category: .performance,                                             ║
// ║       difficulty: .easy,                                                  ║
// ║       requiredProgress: 3,                                                ║
// ║       startDate: Date(),                                                  ║
// ║       endDate: Date().addingTimeInterval(86400), // 24 hours             ║
// ║       rewards: [ChallengeReward(type: .xp, value: 100)]                  ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Update progress:                                                           ║
// ║   if challenge.incrementProgress() {                                      ║
// ║       print("Challenge completed!")                                       ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ Check status:                                                              ║
// ║   if challenge.isActive && !challenge.isCompleted {                       ║
// ║       Text(challenge.formattedProgress)                                   ║
// ║       Text(challenge.formattedTimeRemaining)                              ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
