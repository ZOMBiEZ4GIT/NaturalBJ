//
//  AchievementManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 8: Achievements & Progression System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏆 ACHIEVEMENT MANAGER SERVICE                                             ║
// ║                                                                            ║
// ║ Purpose: Central coordinator for all achievement tracking and management  ║
// ║ Business Context: This is the single source of truth for achievements.    ║
// ║                   It defines all achievements, tracks progress, detects   ║
// ║                   unlocks, and persists data.                             ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Define all 40+ achievements                                             ║
// ║ • Track progress for each achievement                                     ║
// ║ • Detect and trigger achievement unlocks                                  ║
// ║ • Integrate with StatisticsManager for data                               ║
// ║ • Persist achievement data via UserDefaults/JSON                          ║
// ║ • Provide filtered/sorted achievement lists                               ║
// ║                                                                            ║
// ║ Architecture Pattern: Singleton service with @Published properties        ║
// ║ Used By: GameViewModel (checks achievements after actions)                ║
// ║          AchievementsView (displays achievement progress)                 ║
// ║                                                                            ║
// ║ Related Spec: See "Achievements & Progression System" Phase 8             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import Combine

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏆 ACHIEVEMENT MANAGER CLASS                                               ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

@MainActor
class AchievementManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON PATTERN                                             │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = AchievementManager()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                               │
    // │                                                                  │
    // │ These properties trigger UI updates when changed                │
    // └─────────────────────────────────────────────────────────────────┘

    /// All achievements in the game
    @Published private(set) var achievements: [Achievement] = []

    /// Queue of recently unlocked achievements (for displaying popups)
    @Published var unlockedAchievementQueue: [Achievement] = []

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    /// UserDefaults key for persistence
    private let achievementsKey = "player_achievements"

    /// Statistics manager for checking achievement conditions
    private let statsManager = StatisticsManager.shared

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // │                                                                  │
    // │ Private to enforce singleton pattern                            │
    // │ Initialises all achievements and loads saved progress           │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {
        print("🏆 AchievementManager initialising...")
        initializeAchievements()
        loadProgress()
        print("🏆 AchievementManager ready (\(achievements.count) achievements loaded)")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎯 ACHIEVEMENT DEFINITIONS                                         ║
    // ║                                                                    ║
    // ║ All 40+ achievements defined here                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    private func initializeAchievements() {
        achievements = [
            // ═══════════════════════════════════════════════════════════
            // MILESTONE ACHIEVEMENTS (Hands & Sessions)
            // ═══════════════════════════════════════════════════════════
            Achievement(
                id: "first_hand",
                name: "First Hand",
                description: "Play your first hand of blackjack",
                unlockHint: "Place a bet and play a hand",
                category: .milestone,
                tier: .bronze,
                requiredProgress: 1,
                iconName: "🎴"
            ),
            Achievement(
                id: "getting_started",
                name: "Getting Started",
                description: "Play 10 hands",
                unlockHint: "Keep playing to reach 10 hands",
                category: .milestone,
                tier: .bronze,
                requiredProgress: 10,
                iconName: "🎯"
            ),
            Achievement(
                id: "half_century",
                name: "Half Century",
                description: "Play 50 hands",
                unlockHint: "Play 50 hands total",
                category: .milestone,
                tier: .bronze,
                requiredProgress: 50,
                iconName: "5️⃣0️⃣"
            ),
            Achievement(
                id: "century_club",
                name: "Century Club",
                description: "Play 100 hands",
                unlockHint: "Play 100 hands total",
                category: .milestone,
                tier: .silver,
                requiredProgress: 100,
                iconName: "💯"
            ),
            Achievement(
                id: "seasoned_player",
                name: "Seasoned Player",
                description: "Play 500 hands",
                unlockHint: "Play 500 hands total",
                category: .milestone,
                tier: .silver,
                requiredProgress: 500,
                iconName: "🎰"
            ),
            Achievement(
                id: "high_roller",
                name: "High Roller",
                description: "Play 1,000 hands",
                unlockHint: "Play 1,000 hands total",
                category: .milestone,
                tier: .gold,
                requiredProgress: 1000,
                iconName: "🎲"
            ),
            Achievement(
                id: "blackjack_veteran",
                name: "Blackjack Veteran",
                description: "Play 5,000 hands",
                unlockHint: "Play 5,000 hands total",
                category: .milestone,
                tier: .gold,
                requiredProgress: 5000,
                iconName: "🏅"
            ),
            Achievement(
                id: "blackjack_legend",
                name: "Blackjack Legend",
                description: "Play 10,000 hands",
                unlockHint: "Play 10,000 hands total",
                category: .milestone,
                tier: .platinum,
                requiredProgress: 10000,
                iconName: "👑"
            ),

            // ═══════════════════════════════════════════════════════════
            // PERFORMANCE ACHIEVEMENTS (Win Streaks & Blackjacks)
            // ═══════════════════════════════════════════════════════════
            Achievement(
                id: "first_win",
                name: "First Victory",
                description: "Win your first hand",
                unlockHint: "Beat the dealer",
                category: .performance,
                tier: .bronze,
                requiredProgress: 1,
                iconName: "🎉"
            ),
            Achievement(
                id: "lucky_streak",
                name: "Lucky Streak",
                description: "Win 3 hands in a row",
                unlockHint: "Win 3 consecutive hands",
                category: .performance,
                tier: .bronze,
                requiredProgress: 3,
                iconName: "🔥"
            ),
            Achievement(
                id: "hot_hand",
                name: "Hot Hand",
                description: "Win 5 hands in a row",
                unlockHint: "Win 5 consecutive hands",
                category: .performance,
                tier: .silver,
                requiredProgress: 5,
                iconName: "🌟"
            ),
            Achievement(
                id: "blazing_streak",
                name: "Blazing Streak",
                description: "Win 10 hands in a row",
                unlockHint: "Win 10 consecutive hands",
                category: .performance,
                tier: .gold,
                requiredProgress: 10,
                iconName: "💫"
            ),
            Achievement(
                id: "unstoppable",
                name: "Unstoppable",
                description: "Win 20 hands in a row",
                unlockHint: "Win 20 consecutive hands",
                category: .performance,
                tier: .platinum,
                requiredProgress: 20,
                iconName: "⚡"
            ),
            Achievement(
                id: "first_blackjack",
                name: "Natural Winner",
                description: "Get your first blackjack",
                unlockHint: "Be dealt a natural 21",
                category: .performance,
                tier: .bronze,
                requiredProgress: 1,
                iconName: "🎰"
            ),
            Achievement(
                id: "blackjack_collector",
                name: "Blackjack Collector",
                description: "Get 10 blackjacks",
                unlockHint: "Get 10 natural 21s",
                category: .performance,
                tier: .silver,
                requiredProgress: 10,
                iconName: "🃏"
            ),
            Achievement(
                id: "natural_expert",
                name: "Natural Expert",
                description: "Get 50 blackjacks",
                unlockHint: "Get 50 natural 21s",
                category: .performance,
                tier: .gold,
                requiredProgress: 50,
                iconName: "♠️"
            ),
            Achievement(
                id: "blackjack_master",
                name: "Blackjack Master",
                description: "Get 100 blackjacks",
                unlockHint: "Get 100 natural 21s",
                category: .performance,
                tier: .platinum,
                requiredProgress: 100,
                iconName: "💎"
            ),
            Achievement(
                id: "winning_ways",
                name: "Winning Ways",
                description: "Win 100 hands total",
                unlockHint: "Accumulate 100 winning hands",
                category: .performance,
                tier: .silver,
                requiredProgress: 100,
                iconName: "✅"
            ),
            Achievement(
                id: "champion",
                name: "Champion",
                description: "Win 500 hands total",
                unlockHint: "Accumulate 500 winning hands",
                category: .performance,
                tier: .gold,
                requiredProgress: 500,
                iconName: "🏆"
            ),

            // ═══════════════════════════════════════════════════════════
            // MASTERY ACHIEVEMENTS (Advanced Play)
            // ═══════════════════════════════════════════════════════════
            Achievement(
                id: "double_down_debut",
                name: "Double Down Debut",
                description: "Successfully win your first double down",
                unlockHint: "Win a hand after doubling down",
                category: .mastery,
                tier: .bronze,
                requiredProgress: 1,
                iconName: "💪"
            ),
            Achievement(
                id: "double_down_master",
                name: "Double Down Master",
                description: "Win 25 double downs",
                unlockHint: "Win 25 hands after doubling down",
                category: .mastery,
                tier: .gold,
                requiredProgress: 25,
                iconName: "💸"
            ),
            Achievement(
                id: "split_decision",
                name: "Split Decision",
                description: "Win your first split hand",
                unlockHint: "Split a pair and win",
                category: .mastery,
                tier: .bronze,
                requiredProgress: 1,
                iconName: "✂️"
            ),
            Achievement(
                id: "split_specialist",
                name: "Split Specialist",
                description: "Win 20 split hands",
                unlockHint: "Win 20 hands after splitting",
                category: .mastery,
                tier: .gold,
                requiredProgress: 20,
                iconName: "🪓"
            ),
            Achievement(
                id: "strategic_retreat",
                name: "Strategic Retreat",
                description: "Successfully surrender 10 hands",
                unlockHint: "Use surrender 10 times",
                category: .mastery,
                tier: .silver,
                requiredProgress: 10,
                iconName: "🏳️"
            ),
            Achievement(
                id: "high_stakes",
                name: "High Stakes",
                description: "Win a hand with a bet of $1,000 or more",
                unlockHint: "Bet big and win",
                category: .mastery,
                tier: .gold,
                requiredProgress: 1,
                iconName: "💰"
            ),

            // ═══════════════════════════════════════════════════════════
            // DISCOVERY ACHIEVEMENTS (Dealers & Features)
            // ═══════════════════════════════════════════════════════════
            Achievement(
                id: "meet_ruby",
                name: "Ruby's Acquaintance",
                description: "Play 10 hands with Ruby",
                unlockHint: "Play hands with Ruby",
                category: .discovery,
                tier: .bronze,
                requiredProgress: 10,
                iconName: "♦️"
            ),
            Achievement(
                id: "rubys_friend",
                name: "Ruby's Friend",
                description: "Play 100 hands with Ruby",
                unlockHint: "Play many hands with Ruby",
                category: .discovery,
                tier: .silver,
                requiredProgress: 100,
                iconName: "💎"
            ),
            Achievement(
                id: "meet_lucky",
                name: "Lucky's Acquaintance",
                description: "Play 10 hands with Lucky",
                unlockHint: "Play hands with Lucky",
                category: .discovery,
                tier: .bronze,
                requiredProgress: 10,
                iconName: "🍀"
            ),
            Achievement(
                id: "luckys_friend",
                name: "Lucky's Friend",
                description: "Play 100 hands with Lucky",
                unlockHint: "Play many hands with Lucky",
                category: .discovery,
                tier: .silver,
                requiredProgress: 100,
                iconName: "🎰"
            ),
            Achievement(
                id: "meet_shark",
                name: "Shark's Acquaintance",
                description: "Play 10 hands with Shark",
                unlockHint: "Play hands with Shark",
                category: .discovery,
                tier: .bronze,
                requiredProgress: 10,
                iconName: "🦈"
            ),
            Achievement(
                id: "shark_survivor",
                name: "Shark Survivor",
                description: "Win 25 hands against Shark",
                unlockHint: "Beat Shark 25 times",
                category: .discovery,
                tier: .gold,
                requiredProgress: 25,
                iconName: "🎣"
            ),
            Achievement(
                id: "meet_zen",
                name: "Zen's Acquaintance",
                description: "Play 10 hands with Zen",
                unlockHint: "Play hands with Zen",
                category: .discovery,
                tier: .bronze,
                requiredProgress: 10,
                iconName: "☯️"
            ),
            Achievement(
                id: "zens_friend",
                name: "Zen's Friend",
                description: "Play 100 hands with Zen",
                unlockHint: "Play many hands with Zen",
                category: .discovery,
                tier: .silver,
                requiredProgress: 100,
                iconName: "🧘"
            ),
            Achievement(
                id: "meet_maverick",
                name: "Maverick's Acquaintance",
                description: "Play 10 hands with Maverick",
                unlockHint: "Play hands with Maverick",
                category: .discovery,
                tier: .bronze,
                requiredProgress: 10,
                iconName: "🎭"
            ),
            Achievement(
                id: "meet_the_dealers",
                name: "Meet the Dealers",
                description: "Play at least one hand with all 5 dealers",
                unlockHint: "Try all dealers",
                category: .discovery,
                tier: .silver,
                requiredProgress: 5,
                iconName: "🎪"
            ),
            Achievement(
                id: "style_explorer",
                name: "Style Explorer",
                description: "Try all 8 table felt colours",
                unlockHint: "Change table colours in settings",
                category: .discovery,
                tier: .bronze,
                requiredProgress: 8,
                iconName: "🎨"
            ),
            Achievement(
                id: "card_collector",
                name: "Card Collector",
                description: "Try all 8 card back designs",
                unlockHint: "Change card designs in settings",
                category: .discovery,
                tier: .bronze,
                requiredProgress: 8,
                iconName: "🃏"
            ),

            // ═══════════════════════════════════════════════════════════
            // SPECIAL ACHIEVEMENTS (Financial & Rare Events)
            // ═══════════════════════════════════════════════════════════
            Achievement(
                id: "breaking_even",
                name: "Breaking Even",
                description: "Finish a session at exactly your starting bankroll",
                unlockHint: "End a session with no profit or loss",
                category: .special,
                tier: .bronze,
                requiredProgress: 1,
                iconName: "⚖️"
            ),
            Achievement(
                id: "profitable_session",
                name: "Profitable Session",
                description: "End a session with profit",
                unlockHint: "Win more than you lose in a session",
                category: .special,
                tier: .bronze,
                requiredProgress: 1,
                iconName: "📈"
            ),
            Achievement(
                id: "big_winner",
                name: "Big Winner",
                description: "Reach a bankroll of $50,000",
                unlockHint: "Build your bankroll to $50,000",
                category: .special,
                tier: .gold,
                requiredProgress: 1,
                iconName: "💵"
            ),
            Achievement(
                id: "whale",
                name: "Whale",
                description: "Reach a bankroll of $100,000",
                unlockHint: "Build your bankroll to $100,000",
                category: .special,
                tier: .platinum,
                requiredProgress: 1,
                iconName: "🐋"
            ),
            Achievement(
                id: "bankrupt_recovery",
                name: "Phoenix Rising",
                description: "Recover from bankruptcy",
                unlockHint: "Reset your bankroll after going broke",
                category: .special,
                tier: .silver,
                requiredProgress: 1,
                iconName: "🔥"
            ),
            Achievement(
                id: "perfect_21",
                name: "Perfect 21",
                description: "Get 21 with exactly three 7s",
                unlockHint: "Get three 7s for exactly 21",
                category: .special,
                tier: .platinum,
                requiredProgress: 1,
                isHidden: true,
                iconName: "🎰"
            ),
            Achievement(
                id: "marathon_session",
                name: "Marathon Player",
                description: "Play a session lasting 2+ hours",
                unlockHint: "Play for an extended period",
                category: .special,
                tier: .gold,
                requiredProgress: 1,
                iconName: "⏱️"
            ),
            Achievement(
                id: "dedicated_player",
                name: "Dedicated Player",
                description: "Complete 50 sessions",
                unlockHint: "Start and end 50 sessions",
                category: .special,
                tier: .gold,
                requiredProgress: 50,
                iconName: "📅"
            ),
        ]
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 💾 PERSISTENCE                                                     ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Save achievement progress to UserDefaults
    func saveProgress() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(achievements)
            UserDefaults.standard.set(data, forKey: achievementsKey)
            print("💾 Achievement progress saved")
        } catch {
            print("❌ Failed to save achievements: \(error)")
        }
    }

    /// Load achievement progress from UserDefaults
    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: achievementsKey) else {
            print("📂 No saved achievement progress found - starting fresh")
            return
        }

        do {
            let decoder = JSONDecoder()
            let loadedAchievements = try decoder.decode([Achievement].self, from: data)

            // Merge loaded progress with current achievement definitions
            // This allows us to add new achievements without losing old progress
            for (index, achievement) in achievements.enumerated() {
                if let savedAchievement = loadedAchievements.first(where: { $0.id == achievement.id }) {
                    achievements[index].currentProgress = savedAchievement.currentProgress
                    achievements[index].isUnlocked = savedAchievement.isUnlocked
                    achievements[index].unlockedDate = savedAchievement.unlockedDate
                }
            }

            print("📂 Achievement progress loaded (\(achievements.filter { $0.isUnlocked }.count) unlocked)")
        } catch {
            print("❌ Failed to load achievements: \(error)")
        }
    }

    /// Clear all progress (for testing/debugging)
    func resetAllProgress() {
        for index in achievements.indices {
            achievements[index].reset()
        }
        unlockedAchievementQueue.removeAll()
        saveProgress()
        print("🔄 All achievement progress reset")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 PROGRESS TRACKING                                               ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Update progress for a specific achievement
    /// Returns the achievement if it was unlocked by this update
    @discardableResult
    func updateProgress(achievementID: String, progress: Int) -> Achievement? {
        guard let index = achievements.firstIndex(where: { $0.id == achievementID }) else {
            print("⚠️ Achievement not found: \(achievementID)")
            return nil
        }

        let wasUnlocked = achievements[index].updateProgress(progress)

        if wasUnlocked {
            let achievement = achievements[index]
            print("🎉 Achievement unlocked: \(achievement.name) (+\(achievement.xpReward) XP)")
            unlockedAchievementQueue.append(achievement)

            // Award XP via ProgressionManager
            ProgressionManager.shared.addExperience(achievement.xpReward, source: "Achievement: \(achievement.name)")

            saveProgress()
            return achievement
        }

        // Save periodically (every 10 updates)
        if progress % 10 == 0 {
            saveProgress()
        }

        return nil
    }

    /// Increment progress for a specific achievement
    @discardableResult
    func incrementProgress(achievementID: String, by amount: Int = 1) -> Achievement? {
        guard let index = achievements.firstIndex(where: { $0.id == achievementID }) else {
            return nil
        }

        let newProgress = achievements[index].currentProgress + amount
        return updateProgress(achievementID: achievementID, progress: newProgress)
    }

    /// Manually unlock an achievement
    func unlockAchievement(_ achievementID: String) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementID }) else {
            return
        }

        guard !achievements[index].isUnlocked else {
            return
        }

        achievements[index].unlock()
        let achievement = achievements[index]

        print("🎉 Achievement manually unlocked: \(achievement.name)")
        unlockedAchievementQueue.append(achievement)

        // Award XP
        ProgressionManager.shared.addExperience(achievement.xpReward, source: "Achievement: \(achievement.name)")

        saveProgress()
    }

    /// Clear the unlock queue (after showing notification)
    func clearUnlockQueue() {
        unlockedAchievementQueue.removeAll()
    }

    /// Get next achievement from queue
    func getNextUnlockedAchievement() -> Achievement? {
        guard !unlockedAchievementQueue.isEmpty else { return nil }
        return unlockedAchievementQueue.removeFirst()
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔍 QUERY METHODS                                                   ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Get all unlocked achievements
    func getUnlockedAchievements() -> [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }

    /// Get all locked achievements
    func getLockedAchievements() -> [Achievement] {
        return achievements.filter { !$0.isUnlocked }
    }

    /// Get achievements in progress (some progress but not unlocked)
    func getInProgressAchievements() -> [Achievement] {
        return achievements.filter { $0.isInProgress }
    }

    /// Get achievements by category
    func getAchievements(category: AchievementCategory) -> [Achievement] {
        return achievements.filter { $0.category == category }
    }

    /// Get achievements by tier
    func getAchievements(tier: AchievementTier) -> [Achievement] {
        return achievements.filter { $0.tier == tier }
    }

    /// Get achievement progress
    func getProgress(achievementID: String) -> (current: Int, required: Int)? {
        guard let achievement = achievements.first(where: { $0.id == achievementID }) else {
            return nil
        }
        return (achievement.currentProgress, achievement.requiredProgress)
    }

    /// Get total achievement count
    var totalAchievements: Int {
        return achievements.count
    }

    /// Get unlocked achievement count
    var unlockedCount: Int {
        return achievements.filter { $0.isUnlocked }.count
    }

    /// Get completion percentage
    var completionPercentage: Double {
        guard totalAchievements > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalAchievements) * 100
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎮 ACHIEVEMENT CHECKING (Called by GameViewModel)                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Check achievements after a hand is played
    func checkAchievementsAfterHand(
        handResult: HandOutcome,
        wasBlackjack: Bool,
        wasSplit: Bool,
        wasDoubleDown: Bool,
        wasSurrender: Bool,
        betAmount: Double,
        dealerName: String,
        currentStreak: Int,
        currentBankroll: Double,
        cards: [String]
    ) {
        let stats = statsManager.getOverallStats()

        // Milestone: Hands played
        updateProgress(achievementID: "first_hand", progress: stats.totalHandsPlayed)
        updateProgress(achievementID: "getting_started", progress: stats.totalHandsPlayed)
        updateProgress(achievementID: "half_century", progress: stats.totalHandsPlayed)
        updateProgress(achievementID: "century_club", progress: stats.totalHandsPlayed)
        updateProgress(achievementID: "seasoned_player", progress: stats.totalHandsPlayed)
        updateProgress(achievementID: "high_roller", progress: stats.totalHandsPlayed)
        updateProgress(achievementID: "blackjack_veteran", progress: stats.totalHandsPlayed)
        updateProgress(achievementID: "blackjack_legend", progress: stats.totalHandsPlayed)

        // Performance: Wins
        if handResult.isWin {
            updateProgress(achievementID: "first_win", progress: 1)
            updateProgress(achievementID: "winning_ways", progress: stats.totalHandsWon)
            updateProgress(achievementID: "champion", progress: stats.totalHandsWon)
        }

        // Performance: Win streaks
        if currentStreak > 0 {
            updateProgress(achievementID: "lucky_streak", progress: max(currentStreak, getProgress(achievementID: "lucky_streak")?.current ?? 0))
            updateProgress(achievementID: "hot_hand", progress: max(currentStreak, getProgress(achievementID: "hot_hand")?.current ?? 0))
            updateProgress(achievementID: "blazing_streak", progress: max(currentStreak, getProgress(achievementID: "blazing_streak")?.current ?? 0))
            updateProgress(achievementID: "unstoppable", progress: max(currentStreak, getProgress(achievementID: "unstoppable")?.current ?? 0))
        }

        // Performance: Blackjacks
        if wasBlackjack {
            updateProgress(achievementID: "first_blackjack", progress: 1)
            updateProgress(achievementID: "blackjack_collector", progress: stats.totalBlackjacks)
            updateProgress(achievementID: "natural_expert", progress: stats.totalBlackjacks)
            updateProgress(achievementID: "blackjack_master", progress: stats.totalBlackjacks)
        }

        // Mastery: Double downs
        if wasDoubleDown && handResult.isWin {
            incrementProgress(achievementID: "double_down_debut")
            incrementProgress(achievementID: "double_down_master")
        }

        // Mastery: Splits
        if wasSplit && handResult.isWin {
            incrementProgress(achievementID: "split_decision")
            incrementProgress(achievementID: "split_specialist")
        }

        // Mastery: Surrender
        if wasSurrender {
            incrementProgress(achievementID: "strategic_retreat")
        }

        // Mastery: High stakes
        if betAmount >= 1000 && handResult.isWin {
            updateProgress(achievementID: "high_stakes", progress: 1)
        }

        // Discovery: Dealer-specific (track by dealer name)
        checkDealerAchievements(dealerName: dealerName, won: handResult.isWin)

        // Special: Perfect 21 (three 7s)
        checkPerfect21(cards: cards)

        // Special: Bankroll milestones
        if currentBankroll >= 50000 {
            updateProgress(achievementID: "big_winner", progress: 1)
        }
        if currentBankroll >= 100000 {
            updateProgress(achievementID: "whale", progress: 1)
        }
    }

    /// Check achievements after a session ends
    func checkAchievementsAfterSession(
        duration: TimeInterval,
        netProfit: Double,
        startingBankroll: Double,
        wasBankrupt: Bool
    ) {
        let stats = statsManager.getOverallStats()

        // Special: Session milestones
        updateProgress(achievementID: "dedicated_player", progress: stats.totalSessions)

        // Special: Breaking even
        if abs(netProfit) < 0.01 { // Within a penny
            updateProgress(achievementID: "breaking_even", progress: 1)
        }

        // Special: Profitable session
        if netProfit > 0 {
            updateProgress(achievementID: "profitable_session", progress: 1)
        }

        // Special: Marathon session (2+ hours)
        if duration >= 7200 { // 2 hours in seconds
            updateProgress(achievementID: "marathon_session", progress: 1)
        }

        // Special: Bankruptcy recovery
        if wasBankrupt {
            updateProgress(achievementID: "bankrupt_recovery", progress: 1)
        }
    }

    /// Track when visual settings are changed
    func checkVisualSettingAchievements(feltColoursUsed: Int, cardBacksUsed: Int) {
        updateProgress(achievementID: "style_explorer", progress: feltColoursUsed)
        updateProgress(achievementID: "card_collector", progress: cardBacksUsed)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎰 DEALER-SPECIFIC ACHIEVEMENT CHECKING                          │
    // └─────────────────────────────────────────────────────────────────┘

    private func checkDealerAchievements(dealerName: String, won: Bool) {
        // Get hands played with each dealer from stats
        let stats = statsManager.getOverallStats()

        // Track hands per dealer (we'll need to add this to statistics later)
        // For now, use basic achievements

        switch dealerName {
        case "Ruby":
            incrementProgress(achievementID: "meet_ruby")
            incrementProgress(achievementID: "rubys_friend")
        case "Lucky":
            incrementProgress(achievementID: "meet_lucky")
            incrementProgress(achievementID: "luckys_friend")
        case "Shark":
            incrementProgress(achievementID: "meet_shark")
            if won {
                incrementProgress(achievementID: "shark_survivor")
            }
        case "Zen":
            incrementProgress(achievementID: "meet_zen")
            incrementProgress(achievementID: "zens_friend")
        case "Maverick":
            incrementProgress(achievementID: "meet_maverick")
        default:
            break
        }

        // Check if played with all dealers
        let dealersPlayed = [
            getProgress(achievementID: "meet_ruby")?.current ?? 0 > 0,
            getProgress(achievementID: "meet_lucky")?.current ?? 0 > 0,
            getProgress(achievementID: "meet_shark")?.current ?? 0 > 0,
            getProgress(achievementID: "meet_zen")?.current ?? 0 > 0,
            getProgress(achievementID: "meet_maverick")?.current ?? 0 > 0
        ]

        let dealersPlayedCount = dealersPlayed.filter { $0 }.count
        updateProgress(achievementID: "meet_the_dealers", progress: dealersPlayedCount)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎰 SPECIAL CARD COMBINATION CHECKING                            │
    // └─────────────────────────────────────────────────────────────────┘

    private func checkPerfect21(cards: [String]) {
        // Check for three 7s (777)
        guard cards.count == 3 else { return }

        let allSevens = cards.allSatisfy { card in
            card.starts(with: "7")
        }

        if allSevens {
            updateProgress(achievementID: "perfect_21", progress: 1)
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Get achievement manager:                                                   ║
// ║   let manager = AchievementManager.shared                                 ║
// ║                                                                            ║
// ║ Check achievements after hand:                                             ║
// ║   manager.checkAchievementsAfterHand(                                     ║
// ║       handResult: .win,                                                   ║
// ║       wasBlackjack: false,                                                ║
// ║       wasSplit: false,                                                    ║
// ║       wasDoubleDown: false,                                               ║
// ║       wasSurrender: false,                                                ║
// ║       betAmount: 50,                                                      ║
// ║       dealerName: "Ruby",                                                 ║
// ║       currentStreak: 5,                                                   ║
// ║       currentBankroll: 12000,                                             ║
// ║       cards: ["K♠", "9♥"]                                                 ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Get unlocked achievements:                                                 ║
// ║   let unlocked = manager.getUnlockedAchievements()                        ║
// ║   print("\(unlocked.count) achievements unlocked")                        ║
// ║                                                                            ║
// ║ Check for new unlocks:                                                     ║
// ║   if let newAchievement = manager.getNextUnlockedAchievement() {          ║
// ║       // Show achievement popup                                           ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
