//
//  SharingManager.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import Foundation
import SwiftUI
import UIKit

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Sharing Manager
// ═══════════════════════════════════════════════════════════════════════════════════
/// Manages social sharing of achievements, milestones, and personal bests
@MainActor
class SharingManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON                                                     │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = SharingManager()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED PROPERTIES                                          │
    // └─────────────────────────────────────────────────────────────────┘

    /// Currently pending share (for showing share view)
    @Published var pendingShare: ShareContent?

    /// Whether share view is showing
    @Published var isShowingShareView = false

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {}

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Share Methods
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Offer to share an achievement unlock
    func offerShareAchievement(_ achievement: Achievement) {
        guard let profile = ProgressionManager.shared.profile else { return }

        let content = ShareContent(
            type: .achievementUnlocked,
            title: "Achievement Unlocked!",
            message: "I just unlocked '\(achievement.title)' in Natural Blackjack!",
            details: [
                "Achievement": achievement.title,
                "Description": achievement.description,
                "Tier": achievement.tier.rawValue.capitalized,
                "XP Reward": "+\(achievement.xpReward) XP"
            ],
            iconEmoji: achievement.tier.emoji,
            playerName: profile.displayName,
            playerLevel: profile.level,
            playerRank: profile.rankTitle
        )

        presentShareOffer(content)
    }

    /// Offer to share a level up milestone
    func offerShareLevelUp(_ newLevel: Int) {
        guard let profile = ProgressionManager.shared.profile else { return }

        let content = ShareContent(
            type: .levelUp,
            title: "Level Up!",
            message: "I just reached Level \(newLevel) in Natural Blackjack!",
            details: [
                "New Level": "\(newLevel)",
                "Rank": profile.rankTitle,
                "Total XP": "\(profile.totalXPEarned)",
                "Achievements": "\(profile.achievementsUnlocked)/44"
            ],
            iconEmoji: profile.rankEmoji,
            playerName: profile.displayName,
            playerLevel: newLevel,
            playerRank: profile.rankTitle
        )

        presentShareOffer(content)
    }

    /// Offer to share a personal best
    func offerSharePersonalBest(category: LeaderboardCategory, score: Double, rank: Int?) {
        guard let profile = ProgressionManager.shared.profile else { return }

        var message = "I just set a personal best in \(category.displayName): "
        message += formatScore(score, for: category)

        if let rank = rank {
            message += " (Rank #\(rank))"
        }

        message += " in Natural Blackjack!"

        var details: [String: String] = [
            "Category": category.displayName,
            "Score": formatScore(score, for: category)
        ]

        if let rank = rank {
            details["Global Rank"] = "#\(rank)"

            if rank <= 3 {
                details["Achievement"] = "Top 3! 🏆"
            } else if rank <= 10 {
                details["Achievement"] = "Top 10! 🌟"
            } else if rank <= 100 {
                details["Achievement"] = "Top 100! ⭐"
            }
        }

        let content = ShareContent(
            type: .personalBest,
            title: "Personal Best!",
            message: message,
            details: details,
            iconEmoji: category.icon,
            playerName: profile.displayName,
            playerLevel: profile.level,
            playerRank: profile.rankTitle
        )

        presentShareOffer(content)
    }

    /// Offer to share a session highlight
    func offerShareSessionHighlight(profit: Double, winRate: Double, handsPlayed: Int) {
        guard let profile = ProgressionManager.shared.profile else { return }

        let profitStr = profit >= 0 ? "+$\(Int(profit))" : "-$\(Int(abs(profit)))"

        let content = ShareContent(
            type: .sessionHighlight,
            title: "Epic Session!",
            message: "I just had an amazing session in Natural Blackjack! \(profitStr) profit with a \(String(format: "%.1f%%", winRate)) win rate!",
            details: [
                "Profit": profitStr,
                "Win Rate": String(format: "%.1f%%", winRate),
                "Hands Played": "\(handsPlayed)",
                "Session Result": profit > 0 ? "Victory! 🎉" : "Learning Experience 📚"
            ],
            iconEmoji: profit > 0 ? "💰" : "🎴",
            playerName: profile.displayName,
            playerLevel: profile.level,
            playerRank: profile.rankTitle
        )

        presentShareOffer(content)
    }

    /// Offer to share a challenge completion
    func offerShareChallengeCompletion(_ challenge: Challenge) {
        guard let profile = ProgressionManager.shared.profile else { return }

        let content = ShareContent(
            type: .challengeCompletion,
            title: "Challenge Complete!",
            message: "I just completed the '\(challenge.title)' challenge in Natural Blackjack!",
            details: [
                "Challenge": challenge.title,
                "Difficulty": challenge.difficulty.rawValue.capitalized,
                "Type": challenge.type.displayName,
                "Reward": "+\(challenge.xpReward) XP"
            ],
            iconEmoji: challenge.difficulty == .expert ? "🏆" : "🎯",
            playerName: profile.displayName,
            playerLevel: profile.level,
            playerRank: profile.rankTitle
        )

        presentShareOffer(content)
    }

    /// Offer to share a streak milestone
    func offerShareStreakMilestone(days: Int) {
        guard let profile = ProgressionManager.shared.profile else { return }

        let content = ShareContent(
            type: .streakMilestone,
            title: "Streak Milestone!",
            message: "I've maintained a \(days)-day login streak in Natural Blackjack! 🔥",
            details: [
                "Streak": "\(days) days",
                "Dedication": getMilestoneDescription(for: days),
                "Total Sessions": "\(profile.totalSessions)",
                "Total Play Time": profile.formattedTotalPlayTime
            ],
            iconEmoji: "🔥",
            playerName: profile.displayName,
            playerLevel: profile.level,
            playerRank: profile.rankTitle
        )

        presentShareOffer(content)
    }

    /// Offer to share rank improvement
    func offerShareRankImprovement(category: LeaderboardCategory, oldRank: Int, newRank: Int) {
        guard let profile = ProgressionManager.shared.profile else { return }

        let improvement = oldRank - newRank

        let content = ShareContent(
            type: .rankImprovement,
            title: "Rank Up!",
            message: "I climbed \(improvement) positions in \(category.displayName)! Now ranked #\(newRank) in Natural Blackjack! 📈",
            details: [
                "Category": category.displayName,
                "Old Rank": "#\(oldRank)",
                "New Rank": "#\(newRank)",
                "Improvement": "+\(improvement) positions"
            ],
            iconEmoji: "📈",
            playerName: profile.displayName,
            playerLevel: profile.level,
            playerRank: profile.rankTitle
        )

        presentShareOffer(content)
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Share Image Generation
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Generate a beautiful share image
    func generateShareImage(for content: ShareContent) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080) // Square for Instagram
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            // Background gradient
            let colors = getGradientColors(for: content.type)
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: [0.0, 1.0]
            )

            if let gradient = gradient {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            // Draw content
            drawShareContent(content, in: context.cgContext, size: size)
        }

        return image
    }

    /// Draw share content on image
    private func drawShareContent(_ content: ShareContent, in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let padding: CGFloat = 60

        // Icon emoji (large, at top)
        let iconFont = UIFont.systemFont(ofSize: 120)
        let iconText = NSAttributedString(
            string: content.iconEmoji,
            attributes: [.font: iconFont]
        )
        let iconSize = iconText.size()
        iconText.draw(at: CGPoint(x: centerX - iconSize.width / 2, y: 120))

        // Title
        let titleFont = UIFont.boldSystemFont(ofSize: 64)
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.white
        ]
        let titleText = NSAttributedString(string: content.title, attributes: titleAttrs)
        let titleSize = titleText.size()
        titleText.draw(at: CGPoint(x: centerX - titleSize.width / 2, y: 280))

        // Player info
        let playerFont = UIFont.systemFont(ofSize: 36, weight: .medium)
        let playerText = "\(content.playerName) • Level \(content.playerLevel) • \(content.playerRank)"
        let playerAttrs: [NSAttributedString.Key: Any] = [
            .font: playerFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]
        let playerString = NSAttributedString(string: playerText, attributes: playerAttrs)
        let playerSize = playerString.size()
        playerString.draw(at: CGPoint(x: centerX - playerSize.width / 2, y: 380))

        // Details box
        var yOffset: CGFloat = 480
        let detailFont = UIFont.systemFont(ofSize: 32, weight: .regular)
        let detailAttrs: [NSAttributedString.Key: Any] = [
            .font: detailFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.95)
        ]

        for (key, value) in content.details {
            let detailText = "\(key): \(value)"
            let detailString = NSAttributedString(string: detailText, attributes: detailAttrs)
            let detailSize = detailString.size()
            detailString.draw(at: CGPoint(x: centerX - detailSize.width / 2, y: yOffset))
            yOffset += 50
        }

        // App branding at bottom
        let brandFont = UIFont.systemFont(ofSize: 28, weight: .semibold)
        let brandText = "🎴 Play Natural Blackjack"
        let brandAttrs: [NSAttributedString.Key: Any] = [
            .font: brandFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        let brandString = NSAttributedString(string: brandText, attributes: brandAttrs)
        let brandSize = brandString.size()
        brandString.draw(at: CGPoint(x: centerX - brandSize.width / 2, y: size.height - 100))
    }

    /// Get gradient colours for share type
    private func getGradientColors(for type: ShareType) -> [UIColor] {
        switch type {
        case .achievementUnlocked:
            return [UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1.0),
                    UIColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1.0)]
        case .levelUp:
            return [UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0),
                    UIColor(red: 0.2, green: 0.7, blue: 0.9, alpha: 1.0)]
        case .personalBest:
            return [UIColor(red: 0.9, green: 0.6, blue: 0.0, alpha: 1.0),
                    UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)]
        case .challengeCompletion:
            return [UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0),
                    UIColor(red: 0.4, green: 0.9, blue: 0.5, alpha: 1.0)]
        case .streakMilestone:
            return [UIColor(red: 0.9, green: 0.3, blue: 0.1, alpha: 1.0),
                    UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)]
        case .sessionHighlight:
            return [UIColor(red: 0.1, green: 0.6, blue: 0.4, alpha: 1.0),
                    UIColor(red: 0.2, green: 0.8, blue: 0.6, alpha: 1.0)]
        case .rankImprovement:
            return [UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 1.0),
                    UIColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 1.0)]
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Share Presentation
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Present share offer to user
    private func presentShareOffer(_ content: ShareContent) {
        pendingShare = content
        isShowingShareView = true
    }

    /// Dismiss share view
    func dismissShareView() {
        isShowingShareView = false
        pendingShare = nil
    }

    /// Actually perform the share action
    func share(_ content: ShareContent, from view: UIViewController?) {
        // Generate share image
        guard let image = generateShareImage(for: content) else {
            return
        }

        // Create share items
        let shareText = content.message
        let shareItems: [Any] = [shareText, image]

        // Present share sheet
        let activityVC = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )

        // Exclude some activities
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .openInIBooks
        ]

        // Present from view controller
        view?.present(activityVC, animated: true)
    }

    // ═══════════════════════════════════════════════════════════════════════════════════
    // MARK: - Utility Methods
    // ═══════════════════════════════════════════════════════════════════════════════════

    /// Format score for a category
    private func formatScore(_ score: Double, for category: LeaderboardCategory) -> String {
        switch category.unit {
        case "%":
            return String(format: "%.1f%%", score)
        case "$":
            return String(format: "$%.0f", score)
        default:
            return String(format: "%.0f %@", score, category.unit)
        }
    }

    /// Get milestone description for streak days
    private func getMilestoneDescription(for days: Int) -> String {
        switch days {
        case 0..<7:
            return "Great Start!"
        case 7..<30:
            return "Building Momentum!"
        case 30..<90:
            return "Dedicated Player!"
        case 90..<180:
            return "Committed Champion!"
        case 180..<365:
            return "True Devotee!"
        default:
            return "Legendary Dedication!"
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Share Content
// ═══════════════════════════════════════════════════════════════════════════════════
/// Content to be shared
struct ShareContent: Identifiable {
    let id = UUID()
    let type: ShareType
    let title: String
    let message: String
    let details: [String: String]
    let iconEmoji: String
    let playerName: String
    let playerLevel: Int
    let playerRank: String
}
