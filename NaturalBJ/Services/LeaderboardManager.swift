//
//  LeaderboardManager.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import Foundation
import Combine

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Leaderboard Manager
// ═══════════════════════════════════════════════════════════════════════════════════
/// Manages leaderboards, rankings, and personal bests
/// Uses procedurally generated AI players for realistic competition
@MainActor
class LeaderboardManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON                                                     │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = LeaderboardManager()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED PROPERTIES                                          │
    // └─────────────────────────────────────────────────────────────────┘

    /// Generated AI players for leaderboards
    @Published private(set) var aiPlayers: [String: AIPlayer] = [:]

    /// Personal best records indexed by category
    @Published private(set) var personalBests: [LeaderboardCategory: PersonalBestRecord] = [:]

    /// Recent rank improvements
    @Published private(set) var recentRankImprovements: [RankImprovement] = []

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💾 PERSISTENCE                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    private let userDefaults = UserDefaults.standard
    private let aiPlayersKey = "leaderboard_ai_players"
    private let personalBestsKey = "leaderboard_personal_bests"
    private let lastRefreshKey = "leaderboard_last_refresh"

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⚙️ CONFIGURATION                                                 │
    // └─────────────────────────────────────────────────────────────────┘

    private let totalAIPlayers = 500 // Total AI players in leaderboards
    private let refreshInterval: TimeInterval = 3600 // 1 hour

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {
        loadAIPlayers()
        loadPersonalBests()
        refreshIfNeeded()
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - AI Player Management
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Load or generate AI players
    private func loadAIPlayers() {
        if let data = userDefaults.data(forKey: aiPlayersKey),
           let decoded = try? JSONDecoder().decode([String: AIPlayer].self, from: data) {
            aiPlayers = decoded
        } else {
            generateAIPlayers()
        }
    }

    /// Generate procedural AI players
    private func generateAIPlayers() {
        aiPlayers.removeAll()

        for _ in 0..<totalAIPlayers {
            let player = AIPlayer.generateRandom()
            aiPlayers[player.id] = player
        }

        saveAIPlayers()
    }

    /// Save AI players to UserDefaults
    private func saveAIPlayers() {
        if let encoded = try? JSONEncoder().encode(aiPlayers) {
            userDefaults.set(encoded, forKey: aiPlayersKey)
        }
    }

    /// Refresh AI player stats (simulate progression)
    func refreshIfNeeded() {
        let lastRefresh = userDefaults.double(forKey: lastRefreshKey)
        let now = Date().timeIntervalSince1970

        if now - lastRefresh > refreshInterval {
            refreshAIPlayers()
            userDefaults.set(now, forKey: lastRefreshKey)
        }
    }

    /// Simulate AI player progression
    private func refreshAIPlayers() {
        for (id, var player) in aiPlayers {
            // Small random changes to make leaderboards feel alive
            player.level += Int.random(in: 0...2)
            player.totalXP = ProgressionManager.shared.calculateTotalXPForLevel(player.level)
            player.dailyChallengesCompleted += Int.random(in: 0...3)

            aiPlayers[id] = player
        }

        saveAIPlayers()
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Leaderboard Generation
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Get leaderboard for a specific category and timeframe
    func getLeaderboard(
        category: LeaderboardCategory,
        timeframe: LeaderboardTimeframe = .allTime,
        limit: Int = 100
    ) -> [LeaderboardEntry] {

        // Get player's current stats
        guard let progressionManager = ProgressionManager.shared.profile else {
            return []
        }

        // Build all entries (AI + player)
        var entries: [LeaderboardEntry] = []

        // Add player entry
        if let playerEntry = createPlayerEntry(for: category, profile: progressionManager) {
            entries.append(playerEntry)
        }

        // Add AI entries
        for aiPlayer in aiPlayers.values {
            if let aiEntry = createAIEntry(for: category, aiPlayer: aiPlayer) {
                entries.append(aiEntry)
            }
        }

        // Sort by score (descending)
        entries.sort { $0.score > $1.score }

        // Assign ranks
        entries = entries.enumerated().map { index, entry in
            var updated = entry
            updated = LeaderboardEntry(
                id: entry.id,
                rank: index + 1,
                playerID: entry.playerID,
                playerName: entry.playerName,
                playerLevel: entry.playerLevel,
                playerRank: entry.playerRank,
                score: entry.score,
                achievementCount: entry.achievementCount,
                iconEmoji: entry.iconEmoji,
                timestamp: entry.timestamp,
                isCurrentPlayer: entry.isCurrentPlayer
            )
            return updated
        }

        // Apply limit
        return Array(entries.prefix(limit))
    }

    /// Create leaderboard entry for current player
    private func createPlayerEntry(
        for category: LeaderboardCategory,
        profile: PlayerProfile
    ) -> LeaderboardEntry? {

        let score = getPlayerScore(for: category, profile: profile)

        // Check if player qualifies
        if score < category.minimumQualifyingValue {
            return nil
        }

        return LeaderboardEntry(
            id: "current_player",
            rank: 0, // Will be assigned later
            playerID: profile.playerID.uuidString,
            playerName: profile.leaderboardDisplayName,
            playerLevel: profile.level,
            playerRank: profile.rankTitle,
            score: score,
            achievementCount: profile.achievementsUnlocked,
            iconEmoji: profile.iconEmoji,
            timestamp: Date(),
            isCurrentPlayer: true
        )
    }

    /// Create leaderboard entry for AI player
    private func createAIEntry(
        for category: LeaderboardCategory,
        aiPlayer: AIPlayer
    ) -> LeaderboardEntry? {

        let score = getAIPlayerScore(for: category, aiPlayer: aiPlayer)

        // Check if AI player qualifies
        if score < category.minimumQualifyingValue {
            return nil
        }

        return LeaderboardEntry(
            id: aiPlayer.id,
            rank: 0, // Will be assigned later
            playerID: aiPlayer.id,
            playerName: aiPlayer.name,
            playerLevel: aiPlayer.level,
            playerRank: aiPlayer.rankTitle,
            score: score,
            achievementCount: aiPlayer.achievementCount,
            iconEmoji: aiPlayer.iconEmoji,
            timestamp: Date(),
            isCurrentPlayer: false
        )
    }

    /// Get player's score for a category
    private func getPlayerScore(for category: LeaderboardCategory, profile: PlayerProfile) -> Double {
        switch category {
        case .level:
            return Double(profile.level)
        case .totalXP:
            return Double(profile.totalXPEarned)
        case .winRate:
            return profile.lifetimeWinRate * 100 // Convert to percentage
        case .biggestProfit:
            return profile.biggestSessionProfit
        case .longestWinStreak:
            return Double(profile.longestWinStreak)
        case .mostAchievements:
            return Double(profile.achievementsUnlocked)
        case .dailyChallengeMaster:
            return Double(profile.dailyChallengesCompleted)
        case .loginStreakChampion:
            return Double(profile.longestLoginStreak)
        default:
            // Dealer-specific categories - return 0 for now
            // These will be populated from StatisticsManager in integration phase
            return 0
        }
    }

    /// Get AI player's score for a category
    private func getAIPlayerScore(for category: LeaderboardCategory, aiPlayer: AIPlayer) -> Double {
        switch category {
        case .level:
            return Double(aiPlayer.level)
        case .totalXP:
            return Double(aiPlayer.totalXP)
        case .winRate:
            return aiPlayer.winRate
        case .biggestProfit:
            return aiPlayer.biggestProfit
        case .longestWinStreak:
            return Double(aiPlayer.longestWinStreak)
        case .mostAchievements:
            return Double(aiPlayer.achievementCount)
        case .dailyChallengeMaster:
            return Double(aiPlayer.dailyChallengesCompleted)
        case .loginStreakChampion:
            return Double(aiPlayer.loginStreak)
        default:
            return aiPlayer.dealerStats[category.rawValue] ?? 0
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Player Ranking
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Get player's current rank in a category
    func getPlayerRank(category: LeaderboardCategory) -> Int? {
        let leaderboard = getLeaderboard(category: category, limit: totalAIPlayers)
        return leaderboard.first(where: { $0.isCurrentPlayer })?.rank
    }

    /// Get players near the current player's rank
    func getNearbyPlayers(
        category: LeaderboardCategory,
        range: Int = 5
    ) -> [LeaderboardEntry] {

        let fullLeaderboard = getLeaderboard(category: category, limit: totalAIPlayers)

        guard let playerRank = fullLeaderboard.first(where: { $0.isCurrentPlayer })?.rank else {
            return []
        }

        let startIndex = max(0, playerRank - range - 1)
        let endIndex = min(fullLeaderboard.count, playerRank + range)

        return Array(fullLeaderboard[startIndex..<endIndex])
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Personal Bests
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Update personal best for a category
    /// Returns true if this is a new personal best
    @discardableResult
    func updatePersonalBest(category: LeaderboardCategory, score: Double) -> Bool {

        let categoryKey = category.rawValue
        let previousRecord = personalBests[category]
        let previousBest = previousRecord?.bestScore ?? 0

        if score > previousBest {
            let record = PersonalBestRecord(
                id: categoryKey,
                category: category,
                bestScore: score,
                previousBest: previousBest,
                achievedDate: Date(),
                bestRank: getPlayerRank(category: category)
            )

            personalBests[category] = record
            savePersonalBests()

            // Track rank improvement
            if let oldRank = previousRecord?.bestRank,
               let newRank = record.bestRank,
               newRank < oldRank {
                let improvement = RankImprovement(
                    category: category,
                    oldRank: oldRank,
                    newRank: newRank,
                    date: Date()
                )
                recentRankImprovements.append(improvement)
            }

            return true
        }

        return false
    }

    /// Get all personal bests sorted by score
    func getAllPersonalBests() -> [PersonalBestRecord] {
        return Array(personalBests.values).sorted { $0.achievedDate > $1.achievedDate }
    }

    /// Get personal best for a category
    func getPersonalBest(category: LeaderboardCategory) -> PersonalBestRecord? {
        return personalBests[category]
    }

    /// Load personal bests from UserDefaults
    private func loadPersonalBests() {
        if let data = userDefaults.data(forKey: personalBestsKey),
           let decoded = try? JSONDecoder().decode([String: PersonalBestRecord].self, from: data) {
            // Convert string keys back to enum keys
            for (key, record) in decoded {
                if let category = LeaderboardCategory(rawValue: key) {
                    personalBests[category] = record
                }
            }
        }
    }

    /// Save personal bests to UserDefaults
    private func savePersonalBests() {
        // Convert enum keys to string keys for encoding
        let encodable = personalBests.reduce(into: [String: PersonalBestRecord]()) { result, pair in
            result[pair.key.rawValue] = pair.value
        }

        if let encoded = try? JSONEncoder().encode(encodable) {
            userDefaults.set(encoded, forKey: personalBestsKey)
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Dealer Leaderboards
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Get leaderboard for a specific dealer
    func getDealerLeaderboard(dealerName: String) -> [LeaderboardEntry] {
        // Map dealer name to appropriate category
        let category: LeaderboardCategory

        switch dealerName.lowercased() {
        case "ruby":
            category = .mostHandsVsRuby
        case "lucky":
            category = .mostHandsVsLucky
        case "shark":
            category = .mostHandsVsShark
        case "zen":
            category = .mostHandsVsZen
        case "maverick":
            category = .mostHandsVsMaverick
        default:
            return []
        }

        return getLeaderboard(category: category)
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Utility Methods
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Reset all leaderboard data (for testing)
    func resetAllData() {
        aiPlayers.removeAll()
        personalBests.removeAll()
        recentRankImprovements.removeAll()

        userDefaults.removeObject(forKey: aiPlayersKey)
        userDefaults.removeObject(forKey: personalBestsKey)
        userDefaults.removeObject(forKey: lastRefreshKey)

        generateAIPlayers()
    }

    /// Force refresh AI players
    func forceRefresh() {
        refreshAIPlayers()
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - AI Player Model
// ═══════════════════════════════════════════════════════════════════════════════════
/// Represents an AI-generated player for leaderboards
struct AIPlayer: Codable, Identifiable {
    let id: String
    let name: String
    let iconEmoji: String
    var level: Int
    var totalXP: Int
    var winRate: Double // Percentage (0-100)
    var biggestProfit: Double
    var longestWinStreak: Int
    var achievementCount: Int
    var dailyChallengesCompleted: Int
    var loginStreak: Int
    var dealerStats: [String: Double] // Dealer-specific stats

    /// Rank title based on level
    var rankTitle: String {
        switch level {
        case 1...5: return "Novice"
        case 6...10: return "Amateur"
        case 11...20: return "Intermediate"
        case 21...30: return "Advanced"
        case 31...40: return "Expert"
        case 41...50: return "Master"
        case 51...75: return "Grandmaster"
        case 76...99: return "Legend"
        case 100...: return "Immortal"
        default: return "Player"
        }
    }

    /// Generate a random AI player with realistic stats
    static func generateRandom() -> AIPlayer {
        let level = weightedRandomLevel()
        let totalXP = ProgressionManager.shared.calculateTotalXPForLevel(level)

        // Stats are correlated with level
        let skillFactor = Double(level) / 100.0

        // Win rate: Higher level = better win rate (but not perfect)
        let baseWinRate = 35.0 // Base win rate
        let winRate = min(baseWinRate + (skillFactor * 25), 65.0) + Double.random(in: -5...5)

        // Profit scales with level
        let biggestProfit = Double(level) * Double.random(in: 50...500)

        // Streak correlates with level
        let longestWinStreak = max(1, Int(Double(level) * Double.random(in: 0.5...2.0)))

        // Achievements correlate with level (out of 44 total)
        let achievementCount = min(44, Int(Double(level) * 0.44 * Double.random(in: 0.8...1.2)))

        // Challenges correlate with level
        let dailyChallengesCompleted = Int(Double(level) * Double.random(in: 0.3...1.5))

        // Login streak is more random
        let loginStreak = Int.random(in: 1...min(365, level * 2))

        // Generate dealer stats
        var dealerStats: [String: Double] = [:]
        for category in LeaderboardCategory.allCases where category.isDealerSpecific {
            dealerStats[category.rawValue] = Double.random(in: 0...Double(level * 10))
        }

        return AIPlayer(
            id: UUID().uuidString,
            name: MockPlayerNameGenerator.generate(),
            iconEmoji: PlayerEmojiIcons.random(),
            level: level,
            totalXP: totalXP,
            winRate: winRate,
            biggestProfit: biggestProfit,
            longestWinStreak: longestWinStreak,
            achievementCount: achievementCount,
            dailyChallengesCompleted: dailyChallengesCompleted,
            loginStreak: loginStreak,
            dealerStats: dealerStats
        )
    }

    /// Generate a level using weighted distribution (bell curve)
    /// More players at mid-levels, fewer at extremes
    static func weightedRandomLevel() -> Int {
        // Use normal distribution approximation
        let mean = 30.0
        let stdDev = 20.0

        // Box-Muller transform for normal distribution
        let u1 = Double.random(in: 0.001...0.999)
        let u2 = Double.random(in: 0.001...0.999)
        let z = sqrt(-2.0 * log(u1)) * cos(2.0 * .pi * u2)

        let level = Int(mean + z * stdDev)

        // Clamp to 1-100
        return max(1, min(100, level))
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Rank Improvement
// ═══════════════════════════════════════════════════════════════════════════════════
/// Tracks when a player improves their ranking
struct RankImprovement: Identifiable, Codable {
    let id: String
    let category: LeaderboardCategory
    let oldRank: Int
    let newRank: Int
    let date: Date

    init(category: LeaderboardCategory, oldRank: Int, newRank: Int, date: Date) {
        self.id = UUID().uuidString
        self.category = category
        self.oldRank = oldRank
        self.newRank = newRank
        self.date = date
    }

    /// Positions improved
    var improvement: Int {
        return oldRank - newRank
    }

    /// Description of improvement
    var description: String {
        return "Moved up \(improvement) positions in \(category.displayName)"
    }
}
