//
//  SocialNotificationManager.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import Foundation
import SwiftUI
import Combine

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Social Notification Manager
// ═══════════════════════════════════════════════════════════════════════════════════
/// Manages in-game notifications for social events (personal bests, rank improvements, etc.)
@MainActor
class SocialNotificationManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON                                                     │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = SocialNotificationManager()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED PROPERTIES                                          │
    // └─────────────────────────────────────────────────────────────────┘

    /// Currently visible notification
    @Published var currentNotification: SocialNotification?

    /// Queue of pending notifications
    @Published private(set) var notificationQueue: [SocialNotification] = []

    /// Whether notifications are enabled
    @Published var notificationsEnabled = true

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⚙️ CONFIGURATION                                                 │
    // └─────────────────────────────────────────────────────────────────┘

    private let notificationDuration: TimeInterval = 3.0 // Auto-dismiss after 3 seconds
    private var dismissTimer: Timer?

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {}

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Notification Methods
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Show a new personal best notification
    func notifyPersonalBest(category: LeaderboardCategory, score: Double, rank: Int?) {
        guard notificationsEnabled else { return }

        var message = "New personal best in \(category.displayName)!"
        if let rank = rank {
            message += " You're now ranked #\(rank)!"
        }

        let notification = SocialNotification(
            type: .personalBest,
            title: "🎉 Personal Best!",
            message: message,
            icon: category.icon,
            category: category,
            relatedData: ["score": score, "rank": rank as Any]
        )

        queueNotification(notification)
    }

    /// Show a rank improvement notification
    func notifyRankImprovement(category: LeaderboardCategory, oldRank: Int, newRank: Int) {
        guard notificationsEnabled else { return }

        let improvement = oldRank - newRank
        var message = "You moved from #\(oldRank) to #\(newRank) in \(category.displayName)!"

        // Add special messages for milestones
        if newRank <= 3 {
            message = "🏆 Top 3! " + message
        } else if newRank <= 10 {
            message = "🌟 Top 10! " + message
        } else if newRank <= 100 {
            message = "⭐ Top 100! " + message
        }

        let notification = SocialNotification(
            type: .rankImprovement,
            title: "📈 Rank Up!",
            message: message,
            icon: "📈",
            category: category,
            relatedData: ["oldRank": oldRank, "newRank": newRank, "improvement": improvement]
        )

        queueNotification(notification)
    }

    /// Show an achievement unlock notification
    func notifyAchievementUnlocked(_ achievement: Achievement) {
        guard notificationsEnabled else { return }

        let notification = SocialNotification(
            type: .achievementUnlocked,
            title: "🏆 Achievement Unlocked!",
            message: achievement.title,
            icon: achievement.tier.emoji,
            category: nil,
            relatedData: ["achievementID": achievement.id, "xpReward": achievement.xpReward]
        )

        queueNotification(notification)
    }

    /// Show a level up notification
    func notifyLevelUp(newLevel: Int, newRank: String) {
        guard notificationsEnabled else { return }

        let notification = SocialNotification(
            type: .levelUp,
            title: "⬆️ Level Up!",
            message: "You've reached Level \(newLevel) - \(newRank)!",
            icon: "⬆️",
            category: nil,
            relatedData: ["level": newLevel, "rank": newRank]
        )

        queueNotification(notification)
    }

    /// Show a challenge completion notification
    func notifyChallengeComplete(_ challenge: Challenge) {
        guard notificationsEnabled else { return }

        let notification = SocialNotification(
            type: .challengeCompletion,
            title: "✅ Challenge Complete!",
            message: challenge.title,
            icon: challenge.difficulty == .expert ? "🏆" : "🎯",
            category: nil,
            relatedData: ["challengeID": challenge.id, "xpReward": challenge.xpReward]
        )

        queueNotification(notification)
    }

    /// Show a streak milestone notification
    func notifyStreakMilestone(days: Int) {
        guard notificationsEnabled else { return }

        let notification = SocialNotification(
            type: .streakMilestone,
            title: "🔥 Streak Milestone!",
            message: "\(days)-day login streak! Keep it going!",
            icon: "🔥",
            category: nil,
            relatedData: ["days": days]
        )

        queueNotification(notification)
    }

    /// Show a session highlight notification
    func notifySessionHighlight(profit: Double, winRate: Double) {
        guard notificationsEnabled else { return }

        let profitStr = profit >= 0 ? "+$\(Int(profit))" : "-$\(Int(abs(profit)))"

        let notification = SocialNotification(
            type: .sessionHighlight,
            title: "💰 Session Highlight!",
            message: "\(profitStr) profit with \(String(format: "%.1f%%", winRate)) win rate!",
            icon: "💰",
            category: nil,
            relatedData: ["profit": profit, "winRate": winRate]
        )

        queueNotification(notification)
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Queue Management
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Add notification to queue
    private func queueNotification(_ notification: SocialNotification) {
        notificationQueue.append(notification)

        // If no notification is currently showing, show this one
        if currentNotification == nil {
            showNextNotification()
        }
    }

    /// Show next notification from queue
    private func showNextNotification() {
        guard !notificationQueue.isEmpty else {
            currentNotification = nil
            return
        }

        // Get next notification
        currentNotification = notificationQueue.removeFirst()

        // Set auto-dismiss timer
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(
            withTimeInterval: notificationDuration,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                self?.dismissCurrentNotification()
            }
        }
    }

    /// Dismiss current notification
    func dismissCurrentNotification() {
        currentNotification = nil
        dismissTimer?.invalidate()
        dismissTimer = nil

        // Show next notification after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showNextNotification()
        }
    }

    /// Clear all notifications
    func clearAll() {
        currentNotification = nil
        notificationQueue.removeAll()
        dismissTimer?.invalidate()
        dismissTimer = nil
    }

    /// Toggle notifications
    func toggleNotifications() {
        notificationsEnabled.toggle()

        if !notificationsEnabled {
            clearAll()
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Utility Methods
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Get notification history (last 10)
    private(set) var notificationHistory: [SocialNotification] = []

    /// Archive shown notification
    private func archiveNotification(_ notification: SocialNotification) {
        notificationHistory.insert(notification, at: 0)

        // Keep only last 10
        if notificationHistory.count > 10 {
            notificationHistory = Array(notificationHistory.prefix(10))
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Social Notification Extension
// ═══════════════════════════════════════════════════════════════════════════════════
extension SocialNotification {

    /// Whether notification should show a badge
    var showsBadge: Bool {
        switch type {
        case .achievementUnlocked, .levelUp, .personalBest:
            return true
        default:
            return false
        }
    }

    /// Background colour for notification
    var backgroundColor: Color {
        switch type {
        case .achievementUnlocked:
            return Color.purple.opacity(0.9)
        case .levelUp:
            return Color.blue.opacity(0.9)
        case .personalBest:
            return Color.orange.opacity(0.9)
        case .challengeCompletion:
            return Color.green.opacity(0.9)
        case .streakMilestone:
            return Color.red.opacity(0.9)
        case .sessionHighlight:
            return Color.teal.opacity(0.9)
        case .rankImprovement:
            return Color.indigo.opacity(0.9)
        }
    }

    /// Action button text (if applicable)
    var actionButtonText: String? {
        switch type {
        case .personalBest, .rankImprovement:
            return "View Leaderboard"
        case .achievementUnlocked:
            return "View Achievement"
        case .challengeCompletion:
            return "View Challenges"
        default:
            return nil
        }
    }
}
