//
//  ProgressionManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 8: Achievements & Progression System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📈 PROGRESSION MANAGER SERVICE                                             ║
// ║                                                                            ║
// ║ Purpose: Manages player XP, levels, and progression rewards               ║
// ║ Business Context: Players want to see tangible progress as they play.     ║
// ║                   The progression system awards XP for various actions    ║
// ║                   and provides level-based rewards and recognition.       ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Track player XP and level                                               ║
// ║ • Award XP for gameplay actions                                           ║
// ║ • Calculate XP requirements for each level                                ║
// ║ • Detect and trigger level-ups                                            ║
// ║ • Manage PlayerProfile persistence                                        ║
// ║ • Provide progression statistics                                          ║
// ║                                                                            ║
// ║ XP Sources:                                                                ║
// ║ • Hand played: +10 XP                                                     ║
// ║ • Win: +25 XP                                                             ║
// ║ • Blackjack: +50 XP                                                       ║
// ║ • Achievement unlocked: +100-1000 XP (based on tier)                     ║
// ║ • Session completion: +50 XP                                              ║
// ║                                                                            ║
// ║ Architecture Pattern: Singleton service with @Published properties        ║
// ║ Used By: AchievementManager (awards XP), GameViewModel (tracks actions)   ║
// ║                                                                            ║
// ║ Related Spec: See "Achievements & Progression System" Phase 8             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import Combine

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📈 PROGRESSION MANAGER CLASS                                               ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

@MainActor
class ProgressionManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON PATTERN                                             │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = ProgressionManager()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                               │
    // │                                                                  │
    // │ These properties trigger UI updates when changed                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Player profile (contains XP, level, and lifetime stats)
    @Published var profile: PlayerProfile

    /// Queue of level-up events (for displaying notifications)
    @Published var levelUpQueue: [(newLevel: Int, oldLevel: Int)] = []

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    /// UserDefaults key for persistence
    private let profileKey = "player_profile"

    /// Maximum level supported
    private let maxLevel = 100

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // │                                                                  │
    // │ Private to enforce singleton pattern                            │
    // │ Loads saved profile or creates new one                          │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {
        print("📈 ProgressionManager initialising...")

        // Load saved profile or create new one
        if let savedProfile = ProgressionManager.loadProfile() {
            self.profile = savedProfile
            print("📈 ProgressionManager loaded (Level \(savedProfile.level), \(savedProfile.experiencePoints) XP)")
        } else {
            self.profile = PlayerProfile()
            print("📈 ProgressionManager created new profile")
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 💾 PERSISTENCE                                                     ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Save profile to UserDefaults
    func saveProfile() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(profile)
            UserDefaults.standard.set(data, forKey: profileKey)
            print("💾 Player profile saved")
        } catch {
            print("❌ Failed to save profile: \(error)")
        }
    }

    /// Load profile from UserDefaults
    private static func loadProfile() -> PlayerProfile? {
        guard let data = UserDefaults.standard.data(forKey: "player_profile") else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PlayerProfile.self, from: data)
        } catch {
            print("❌ Failed to load profile: \(error)")
            return nil
        }
    }

    /// Reset profile (for testing/debugging)
    func resetProfile() {
        profile.resetProgress()
        levelUpQueue.removeAll()
        saveProfile()
        print("🔄 Player profile reset")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 XP & LEVEL CALCULATIONS                                         ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 XP REQUIRED FOR LEVEL                                         │
    // │                                                                  │
    // │ Formula: baseXP * level^1.5                                     │
    // │ This creates exponential growth that keeps players engaged      │
    // │                                                                  │
    // │ Examples:                                                        │
    // │ Level 1→2: 100 XP                                               │
    // │ Level 2→3: 283 XP                                               │
    // │ Level 5→6: 1,118 XP                                             │
    // │ Level 10→11: 3,162 XP                                           │
    // │ Level 20→21: 8,944 XP                                           │
    // │ Level 50→51: 35,355 XP                                          │
    // └─────────────────────────────────────────────────────────────────┘

    func xpRequiredForLevel(_ level: Int) -> Int {
        guard level > 1 else { return 0 }

        let baseXP = 100.0
        let exponent = 1.5

        return Int(baseXP * pow(Double(level), exponent))
    }

    /// Total XP needed to reach a level from level 1
    func totalXpForLevel(_ level: Int) -> Int {
        var total = 0
        for lvl in 2...level {
            total += xpRequiredForLevel(lvl)
        }
        return total
    }

    /// XP needed to reach next level from current XP
    var xpToNextLevel: Int {
        let currentLevelTotalXP = totalXpForLevel(profile.level)
        let nextLevelTotalXP = totalXpForLevel(profile.level + 1)
        return nextLevelTotalXP - profile.totalXPEarned
    }

    /// XP progress within current level (0.0 to 1.0)
    var currentLevelProgress: Double {
        guard profile.level < maxLevel else { return 1.0 }

        let currentLevelTotalXP = totalXpForLevel(profile.level)
        let nextLevelTotalXP = totalXpForLevel(profile.level + 1)
        let xpInCurrentLevel = profile.totalXPEarned - currentLevelTotalXP
        let xpNeededForLevel = nextLevelTotalXP - currentLevelTotalXP

        guard xpNeededForLevel > 0 else { return 0 }

        return Double(xpInCurrentLevel) / Double(xpNeededForLevel)
    }

    /// Current level progress as percentage (0-100)
    var currentLevelProgressPercentage: Int {
        return Int(currentLevelProgress * 100)
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎯 XP AWARD METHODS                                                ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Add XP to player profile
    /// Returns true if player leveled up
    @discardableResult
    func addExperience(_ amount: Int, source: String = "Action") -> Bool {
        guard amount > 0 else { return false }

        let oldLevel = profile.level
        let oldTotalXP = profile.totalXPEarned

        // Add XP
        profile.experiencePoints += amount
        profile.totalXPEarned += amount

        print("✨ +\(amount) XP from \(source) (Total: \(profile.totalXPEarned) XP)")

        // Check for level up
        var leveledUp = false
        while profile.level < maxLevel && profile.totalXPEarned >= totalXpForLevel(profile.level + 1) {
            profile.levelUp()
            leveledUp = true

            print("🎉 Level up! Now level \(profile.level)")

            // Add to level-up queue for notification
            levelUpQueue.append((newLevel: profile.level, oldLevel: oldLevel))
        }

        // Save progress
        saveProfile()

        return leveledUp
    }

    /// Award XP for hand played
    func awardHandPlayedXP() {
        addExperience(10, source: "Hand played")
    }

    /// Award XP for winning a hand
    func awardWinXP() {
        addExperience(25, source: "Win")
    }

    /// Award XP for blackjack
    func awardBlackjackXP() {
        addExperience(50, source: "Blackjack")
    }

    /// Award XP for session completion
    func awardSessionCompletionXP() {
        addExperience(50, source: "Session completed")
    }

    /// Award XP for perfect strategy play (future feature)
    func awardPerfectStrategyXP() {
        addExperience(5, source: "Perfect strategy")
    }

    /// Clear level-up queue (after showing notification)
    func clearLevelUpQueue() {
        levelUpQueue.removeAll()
    }

    /// Get next level-up from queue
    func getNextLevelUp() -> (newLevel: Int, oldLevel: Int)? {
        guard !levelUpQueue.isEmpty else { return nil }
        return levelUpQueue.removeFirst()
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 LIFETIME STATISTICS TRACKING                                    ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Record a hand result in lifetime stats
    func recordHand(won: Bool, wasBlackjack: Bool, netProfit: Double) {
        profile.recordHand(won: won, wasBlackjack: wasBlackjack, netProfit: netProfit)

        // Award XP
        awardHandPlayedXP()
        if won {
            awardWinXP()
        }
        if wasBlackjack {
            awardBlackjackXP()
        }

        saveProfile()
    }

    /// Update longest win streak if current is higher
    func updateLongestStreak(_ currentStreak: Int) {
        profile.updateLongestStreak(currentStreak)
        saveProfile()
    }

    /// Record session completion
    func recordSession(duration: TimeInterval) {
        profile.recordSession(duration: duration)
        awardSessionCompletionXP()
        saveProfile()
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🏆 ACHIEVEMENT INTEGRATION                                         ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Record achievement unlock in profile
    func recordAchievementUnlock(achievementID: String, xpReward: Int) {
        profile.unlockAchievement(achievementID: achievementID, xpReward: xpReward)
        saveProfile()
    }

    /// Update achievement progress in profile
    func recordAchievementProgress(achievementID: String, progress: Int) {
        profile.updateAchievementProgress(achievementID: achievementID, progress: progress)
        saveProfile()
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔍 QUERY METHODS                                                   ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Get current level
    var currentLevel: Int {
        return profile.level
    }

    /// Get current XP
    var currentXP: Int {
        return profile.experiencePoints
    }

    /// Get total XP earned
    var totalXP: Int {
        return profile.totalXPEarned
    }

    /// Get rank title
    var rankTitle: String {
        return profile.rankTitle
    }

    /// Get rank emoji
    var rankEmoji: String {
        return profile.rankEmoji
    }

    /// Get full rank (emoji + title)
    var fullRank: String {
        return profile.fullRank
    }

    /// Is player at max level?
    var isMaxLevel: Bool {
        return profile.level >= maxLevel
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📈 DISPLAY HELPERS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Formatted XP progress (e.g., "1,234 / 5,000 XP")
    var formattedXPProgress: String {
        let current = profile.totalXPEarned - totalXpForLevel(profile.level)
        let required = xpRequiredForLevel(profile.level + 1)
        return "\(formatNumber(current)) / \(formatNumber(required)) XP"
    }

    /// Formatted total XP (e.g., "12,345 XP")
    var formattedTotalXP: String {
        return "\(formatNumber(profile.totalXPEarned)) XP"
    }

    /// Format number with comma separators
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    /// Level progress bar text (e.g., "75%")
    var levelProgressText: String {
        if isMaxLevel {
            return "MAX"
        }
        return "\(currentLevelProgressPercentage)%"
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 👤 PHASE 10: SOCIAL & PROFILE METHODS                              ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Update player display name
    func updateDisplayName(_ name: String) {
        profile.updateDisplayName(name)
        saveProfile()
    }

    /// Update player icon emoji
    func updateIconEmoji(_ emoji: String) {
        profile.updateIconEmoji(emoji)
        saveProfile()
    }

    /// Toggle share achievements privacy setting
    func toggleShareAchievements() {
        profile.toggleShareAchievements()
        saveProfile()
    }

    /// Toggle share stats privacy setting
    func toggleShareStats() {
        profile.toggleShareStats()
        saveProfile()
    }

    /// Toggle anonymous mode
    func toggleAnonymousMode() {
        profile.toggleAnonymousMode()
        saveProfile()
    }

    /// Update personal best for a category
    func updatePersonalBest(category: LeaderboardCategory, score: Double) {
        let isNewBest = profile.updatePersonalBest(category: category.rawValue, score: score)
        saveProfile()

        // Update leaderboard manager
        if isNewBest {
            LeaderboardManager.shared.updatePersonalBest(category: category, score: score)

            // Notify social notification manager
            if let rank = LeaderboardManager.shared.getPlayerRank(category: category) {
                SocialNotificationManager.shared.notifyPersonalBest(
                    category: category,
                    score: score,
                    rank: rank
                )
            }
        }
    }

    /// Update login streak (call on app launch)
    func updateLoginStreak() {
        profile.updateLoginStreak()
        saveProfile()

        // Check for streak milestones
        let streak = profile.currentLoginStreak
        if streak == 7 || streak == 30 || streak == 60 || streak == 90 || streak == 180 || streak == 365 {
            SocialNotificationManager.shared.notifyStreakMilestone(days: streak)
        }
    }

    /// Record daily challenge completion
    func recordDailyChallengeCompletion() {
        profile.recordDailyChallengeCompletion()
        saveProfile()

        // Update personal best for daily challenges
        updatePersonalBest(category: .dailyChallengeMaster, score: Double(profile.dailyChallengesCompleted))
    }

    /// Calculate total XP for a given level (used by leaderboard AI)
    func calculateTotalXPForLevel(_ level: Int) -> Int {
        return totalXpForLevel(level)
    }

    /// Progress to next level (0.0-1.0)
    var progressToNextLevel: Double {
        return currentLevelProgress
    }

    /// XP required for next level
    var xpRequiredForNextLevel: Int {
        return xpRequiredForLevel(profile.level + 1)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Get progression manager:                                                   ║
// ║   let manager = ProgressionManager.shared                                 ║
// ║                                                                            ║
// ║ Award XP:                                                                  ║
// ║   manager.addExperience(100, source: "Achievement")                       ║
// ║                                                                            ║
// ║ Record hand:                                                               ║
// ║   manager.recordHand(                                                     ║
// ║       won: true,                                                          ║
// ║       wasBlackjack: false,                                                ║
// ║       netProfit: 50.0                                                     ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Check for level up:                                                        ║
// ║   if let levelUp = manager.getNextLevelUp() {                             ║
// ║       print("Leveled up from \(levelUp.oldLevel) to \(levelUp.newLevel)")║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ Display in UI:                                                             ║
// ║   Text("Level \(manager.currentLevel) - \(manager.fullRank)")            ║
// ║   ProgressView(value: manager.currentLevelProgress)                       ║
// ║   Text(manager.formattedXPProgress)                                       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
