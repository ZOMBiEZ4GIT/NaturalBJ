//
//  Leaderboard.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import Foundation

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Leaderboard Category
// ═══════════════════════════════════════════════════════════════════════════════════
/// Defines the different types of leaderboard rankings available
enum LeaderboardCategory: String, CaseIterable, Codable {
    // Global Leaderboards
    case level = "level"
    case totalXP = "total_xp"
    case winRate = "win_rate"
    case biggestProfit = "biggest_profit"
    case longestWinStreak = "longest_win_streak"
    case mostAchievements = "most_achievements"
    case dailyChallengeMaster = "daily_challenge_master"
    case loginStreakChampion = "login_streak_champion"

    // Dealer-Specific Leaderboards
    case mostHandsVsRuby = "most_hands_vs_ruby"
    case mostHandsVsLucky = "most_hands_vs_lucky"
    case mostHandsVsShark = "most_hands_vs_shark"
    case mostHandsVsZen = "most_hands_vs_zen"
    case mostHandsVsMaverick = "most_hands_vs_maverick"
    case bestWinRateVsShark = "best_win_rate_vs_shark"
    case highestProfitVsRuby = "highest_profit_vs_ruby"
    case highestProfitVsLucky = "highest_profit_vs_lucky"
    case highestProfitVsShark = "highest_profit_vs_shark"
    case highestProfitVsZen = "highest_profit_vs_zen"
    case highestProfitVsMaverick = "highest_profit_vs_maverick"

    /// Display name for the category
    var displayName: String {
        switch self {
        case .level: return "Highest Level"
        case .totalXP: return "Total XP"
        case .winRate: return "Win Rate"
        case .biggestProfit: return "Biggest Profit"
        case .longestWinStreak: return "Longest Win Streak"
        case .mostAchievements: return "Most Achievements"
        case .dailyChallengeMaster: return "Daily Challenge Master"
        case .loginStreakChampion: return "Login Streak Champion"
        case .mostHandsVsRuby: return "Most Hands vs Ruby"
        case .mostHandsVsLucky: return "Most Hands vs Lucky"
        case .mostHandsVsShark: return "Most Hands vs Shark"
        case .mostHandsVsZen: return "Most Hands vs Zen"
        case .mostHandsVsMaverick: return "Most Hands vs Maverick"
        case .bestWinRateVsShark: return "Best Win Rate vs Shark"
        case .highestProfitVsRuby: return "Highest Profit vs Ruby"
        case .highestProfitVsLucky: return "Highest Profit vs Lucky"
        case .highestProfitVsShark: return "Highest Profit vs Shark"
        case .highestProfitVsZen: return "Highest Profit vs Zen"
        case .highestProfitVsMaverick: return "Highest Profit vs Maverick"
        }
    }

    /// Icon emoji for the category
    var icon: String {
        switch self {
        case .level: return "🏆"
        case .totalXP: return "⭐"
        case .winRate: return "📊"
        case .biggestProfit: return "💰"
        case .longestWinStreak: return "🔥"
        case .mostAchievements: return "🏅"
        case .dailyChallengeMaster: return "🎯"
        case .loginStreakChampion: return "📅"
        case .mostHandsVsRuby, .mostHandsVsLucky, .mostHandsVsShark, .mostHandsVsZen, .mostHandsVsMaverick:
            return "🎴"
        case .bestWinRateVsShark:
            return "🦈"
        case .highestProfitVsRuby, .highestProfitVsLucky, .highestProfitVsShark, .highestProfitVsZen, .highestProfitVsMaverick:
            return "💎"
        }
    }

    /// Unit/format for displaying scores
    var unit: String {
        switch self {
        case .level: return "Level"
        case .totalXP: return "XP"
        case .winRate, .bestWinRateVsShark: return "%"
        case .biggestProfit, .highestProfitVsRuby, .highestProfitVsLucky, .highestProfitVsShark, .highestProfitVsZen, .highestProfitVsMaverick:
            return "$"
        case .longestWinStreak: return "wins"
        case .mostAchievements: return "achievements"
        case .dailyChallengeMaster: return "challenges"
        case .loginStreakChampion: return "days"
        case .mostHandsVsRuby, .mostHandsVsLucky, .mostHandsVsShark, .mostHandsVsZen, .mostHandsVsMaverick:
            return "hands"
        }
    }

    /// Whether this is a global leaderboard category
    var isGlobal: Bool {
        switch self {
        case .level, .totalXP, .winRate, .biggestProfit, .longestWinStreak, .mostAchievements, .dailyChallengeMaster, .loginStreakChampion:
            return true
        default:
            return false
        }
    }

    /// Whether this is a dealer-specific category
    var isDealerSpecific: Bool {
        return !isGlobal
    }

    /// Minimum value required to appear on leaderboard (e.g., 100 hands for win rate)
    var minimumQualifyingValue: Double {
        switch self {
        case .winRate, .bestWinRateVsShark:
            return 100.0 // Minimum 100 hands played
        default:
            return 0.0
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Leaderboard Timeframe
// ═══════════════════════════════════════════════════════════════════════════════════
/// Time period for leaderboard rankings
enum LeaderboardTimeframe: String, CaseIterable, Codable {
    case thisWeek = "this_week"
    case thisMonth = "this_month"
    case allTime = "all_time"

    var displayName: String {
        switch self {
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .allTime: return "All Time"
        }
    }

    var icon: String {
        switch self {
        case .thisWeek: return "📅"
        case .thisMonth: return "📆"
        case .allTime: return "🏆"
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Leaderboard Entry
// ═══════════════════════════════════════════════════════════════════════════════════
/// Represents a single entry on a leaderboard
struct LeaderboardEntry: Identifiable, Codable, Hashable {
    let id: String
    let rank: Int
    let playerID: String
    let playerName: String
    let playerLevel: Int
    let playerRank: String
    let score: Double
    let achievementCount: Int
    let iconEmoji: String
    let timestamp: Date
    let isCurrentPlayer: Bool

    /// Formatted score string based on category
    func formattedScore(for category: LeaderboardCategory) -> String {
        switch category.unit {
        case "%":
            return String(format: "%.1f%%", score)
        case "$":
            return String(format: "$%.0f", score)
        default:
            return String(format: "%.0f %@", score, category.unit)
        }
    }

    /// Medal emoji for top 3 ranks
    var medalEmoji: String? {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return nil
        }
    }

    /// Whether this entry is in the top 3
    var isTopThree: Bool {
        return rank <= 3
    }

    /// Whether this entry is in the top 10
    var isTopTen: Bool {
        return rank <= 10
    }

    /// Whether this entry is in the top 100
    var isTopHundred: Bool {
        return rank <= 100
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Personal Best Record
// ═══════════════════════════════════════════════════════════════════════════════════
/// Tracks a player's personal best in a specific category
struct PersonalBestRecord: Codable, Identifiable {
    let id: String
    let category: LeaderboardCategory
    var bestScore: Double
    var previousBest: Double
    var achievedDate: Date
    var bestRank: Int?

    /// Whether this is a new personal best
    var isNew: Bool {
        return Date().timeIntervalSince(achievedDate) < 86400 // Within last 24 hours
    }

    /// Improvement from previous best
    var improvement: Double {
        return bestScore - previousBest
    }

    /// Percentage improvement
    var improvementPercentage: Double {
        guard previousBest > 0 else { return 0 }
        return (improvement / previousBest) * 100
    }

    /// Formatted improvement string
    var improvementString: String {
        if improvement > 0 {
            return String(format: "+%.1f", improvement)
        } else {
            return String(format: "%.1f", improvement)
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Share Type
// ═══════════════════════════════════════════════════════════════════════════════════
/// Types of content that can be shared
enum ShareType: String, CaseIterable {
    case achievementUnlocked = "achievement_unlocked"
    case levelUp = "level_up"
    case personalBest = "personal_best"
    case challengeCompletion = "challenge_completion"
    case streakMilestone = "streak_milestone"
    case sessionHighlight = "session_highlight"
    case rankImprovement = "rank_improvement"

    var displayName: String {
        switch self {
        case .achievementUnlocked: return "Achievement Unlocked"
        case .levelUp: return "Level Up"
        case .personalBest: return "Personal Best"
        case .challengeCompletion: return "Challenge Complete"
        case .streakMilestone: return "Streak Milestone"
        case .sessionHighlight: return "Session Highlight"
        case .rankImprovement: return "Rank Improvement"
        }
    }

    var icon: String {
        switch self {
        case .achievementUnlocked: return "🏆"
        case .levelUp: return "⬆️"
        case .personalBest: return "⭐"
        case .challengeCompletion: return "✅"
        case .streakMilestone: return "🔥"
        case .sessionHighlight: return "💰"
        case .rankImprovement: return "📈"
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Social Notification
// ═══════════════════════════════════════════════════════════════════════════════════
/// In-game notification for social events
struct SocialNotification: Identifiable {
    let id: String
    let type: ShareType
    let title: String
    let message: String
    let icon: String
    let timestamp: Date
    let category: LeaderboardCategory?
    let relatedData: [String: Any]?

    init(id: String = UUID().uuidString, type: ShareType, title: String, message: String, icon: String? = nil, category: LeaderboardCategory? = nil, relatedData: [String: Any]? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.icon = icon ?? type.icon
        self.timestamp = Date()
        self.category = category
        self.relatedData = relatedData
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Mock Player Names
// ═══════════════════════════════════════════════════════════════════════════════════
/// Word lists for generating procedural player names
struct MockPlayerNameGenerator {
    // Card/Casino themed prefixes
    static let prefixes = [
        "Card", "Ace", "King", "Queen", "Jack", "Dealer", "Lucky", "Royal", "Chip", "Deck",
        "Shuffle", "Deal", "Bet", "High", "Wild", "Split", "Double", "Hit", "Stand", "Bust",
        "Natural", "Sharp", "Pro", "Master", "Expert", "Elite", "Prime", "Ultra", "Mega", "Super",
        "Alpha", "Omega", "Turbo", "Power", "Blitz", "Flash", "Quick", "Swift", "Rapid", "Fast"
    ]

    // Card/Casino themed suffixes
    static let suffixes = [
        "Player", "Hunter", "Master", "Champion", "Winner", "Shark", "Legend", "Bane", "Slayer", "King",
        "Queen", "Ace", "Pro", "Star", "Hero", "Boss", "Chief", "Lord", "Baron", "Duke",
        "Ninja", "Wizard", "Guru", "Sage", "Sensei", "Captain", "Commander", "General", "Admiral", "Major"
    ]

    /// Generate a random player name
    static func generate() -> String {
        let prefix = prefixes.randomElement() ?? "Card"
        let suffix = suffixes.randomElement() ?? "Player"
        let number = Int.random(in: 1...999)

        // 50% chance to include number
        if Bool.random() {
            return "\(prefix)\(suffix)\(number)"
        } else {
            return "\(prefix)\(suffix)"
        }
    }

    /// Generate a unique set of names
    static func generateUnique(count: Int) -> [String] {
        var names = Set<String>()
        while names.count < count {
            names.insert(generate())
        }
        return Array(names)
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Mock Player Emojis
// ═══════════════════════════════════════════════════════════════════════════════════
/// Available emoji icons for player avatars
struct PlayerEmojiIcons {
    // Cards & Gaming
    static let cardsAndGaming = ["♠️", "♥️", "♦️", "♣️", "🎰", "🎲", "🃏", "🎴", "🎯", "🎪"]

    // Faces
    static let faces = ["😎", "🤓", "🥳", "😇", "🤠", "🤩", "😈", "👻", "🤖", "👾"]

    // Animals
    static let animals = ["🦈", "🐯", "🦅", "🐺", "🦊", "🦁", "🐉", "🦖", "🐙", "🦂"]

    // Achievements
    static let achievements = ["👑", "💎", "🏅", "⭐", "🔥", "💫", "✨", "🌟", "💥", "⚡"]

    // Symbols
    static let symbols = ["🎭", "🎨", "🎪", "⚡", "💫", "🌈", "🔮", "💀", "☠️", "🗿"]

    /// All available emojis
    static var all: [String] {
        return cardsAndGaming + faces + animals + achievements + symbols
    }

    /// Get a random emoji
    static func random() -> String {
        return all.randomElement() ?? "🎴"
    }

    /// Categories for emoji picker
    static var categories: [(name: String, icon: String, emojis: [String])] {
        return [
            ("Cards & Gaming", "🎴", cardsAndGaming),
            ("Faces", "😀", faces),
            ("Animals", "🐾", animals),
            ("Achievements", "🏆", achievements),
            ("Symbols", "🎭", symbols)
        ]
    }
}
