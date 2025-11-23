//
//  AchievementCardView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 8: Achievements & Progression System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 ACHIEVEMENT CARD VIEW                                                   ║
// ║                                                                            ║
// ║ Purpose: Displays individual achievement as a card in the grid            ║
// ║ Business Context: Players need a quick visual representation of each      ║
// ║                   achievement showing unlock status, progress, and tier.  ║
// ║                                                                            ║
// ║ Features:                                                                  ║
// ║ • Badge icon (full colour if unlocked, grayscale if locked)              ║
// ║ • Achievement name and tier medal                                         ║
// ║ • Progress bar for in-progress achievements                               ║
// ║ • Unlock date for completed achievements                                  ║
// ║ • Difficulty tier indicator                                               ║
// ║ • Tap to expand detail                                                    ║
// ║                                                                            ║
// ║ Used By: AchievementsView (grid display)                                  ║
// ║                                                                            ║
// ║ Related Spec: See "Achievements & Progression System" Phase 8             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 ACHIEVEMENT CARD VIEW                                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct AchievementCardView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    let achievement: Achievement

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        VStack(spacing: 0) {
            // Icon and tier badge
            iconSection

            // Name and status
            infoSection

            // Progress bar (if not unlocked)
            if !achievement.isUnlocked {
                progressSection
            }
        }
        .background(cardBackground)
        .cornerRadius(12)
        .shadow(color: shadowColor, radius: achievement.isUnlocked ? 8 : 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎨 VIEW COMPONENTS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎯 ICON SECTION                                                  │
    // └─────────────────────────────────────────────────────────────────┘

    private var iconSection: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            achievement.isUnlocked ? tierColor : Color(.systemGray5)

            // Icon
            Text(achievement.iconName)
                .font(.system(size: 50))
                .grayscale(achievement.isUnlocked ? 0 : 1)
                .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                .padding()

            // Tier badge
            Text(achievement.tier.medal)
                .font(.system(size: 20))
                .padding(6)
                .background(
                    Circle()
                        .fill(Color(.systemBackground))
                        .shadow(radius: 2)
                )
                .padding(8)
        }
        .frame(height: 100)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📝 INFO SECTION                                                  │
    // └─────────────────────────────────────────────────────────────────┘

    private var infoSection: some View {
        VStack(spacing: 6) {
            // Name
            Text(achievement.displayName)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)

            // Status
            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)

                    Text("Unlocked")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            } else {
                Text(achievement.progressString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Category icon
            HStack(spacing: 4) {
                Text(achievement.category.icon)
                    .font(.caption)

                Text(achievement.category.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROGRESS SECTION                                              │
    // └─────────────────────────────────────────────────────────────────┘

    private var progressSection: some View {
        VStack(spacing: 4) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color(.systemGray5))

                    // Progress fill
                    Rectangle()
                        .fill(tierColor)
                        .frame(width: geometry.size.width * achievement.progressPercentage)
                }
            }
            .frame(height: 4)

            // Percentage text
            if achievement.isInProgress {
                Text("\(achievement.progressPercentageInt)%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎨 STYLING HELPERS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Card background colour
    private var cardBackground: some View {
        Color(.systemBackground)
    }

    /// Shadow colour (more prominent when unlocked)
    private var shadowColor: Color {
        if achievement.isUnlocked {
            return tierColor.opacity(0.4)
        }
        return Color.black.opacity(0.1)
    }

    /// Tier-based colour
    private var tierColor: Color {
        switch achievement.tier {
        case .bronze:
            return Color.orange
        case .silver:
            return Color.gray
        case .gold:
            return Color.yellow
        case .platinum:
            return Color.cyan
        }
    }

    /// Accessibility label
    private var accessibilityLabel: String {
        var label = "\(achievement.tier.displayName) achievement: \(achievement.displayName). "

        if achievement.isUnlocked {
            label += "Unlocked. "
        } else {
            label += "Locked. Progress: \(achievement.progressString). "
            label += achievement.unlockHint
        }

        return label
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 COMPACT ACHIEVEMENT CARD (For Lists)                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct CompactAchievementCardView: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Text(achievement.iconName)
                .font(.system(size: 40))
                .grayscale(achievement.isUnlocked ? 0 : 1)
                .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(achievement.isUnlocked ? tierColor.opacity(0.2) : Color(.systemGray6))
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                // Name and tier
                HStack {
                    Text(achievement.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(achievement.tier.medal)
                        .font(.caption)
                }

                // Description or progress
                if achievement.isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)

                        Text(achievement.formattedUnlockDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.progressString)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ProgressView(value: achievement.progressPercentage)
                            .tint(tierColor)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return .orange
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEWS                                                                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("Unlocked Achievement") {
    var achievement = Achievement(
        id: "test_unlocked",
        name: "First Victory",
        description: "Win your first hand",
        unlockHint: "Beat the dealer",
        category: .performance,
        tier: .gold,
        requiredProgress: 1,
        iconName: "🎉"
    )
    achievement.unlock()

    return AchievementCardView(achievement: achievement)
        .frame(width: 180, height: 220)
        .padding()
}

#Preview("Locked Achievement") {
    let achievement = Achievement(
        id: "test_locked",
        name: "Blackjack Master",
        description: "Get 100 blackjacks",
        unlockHint: "Get 100 natural 21s",
        category: .performance,
        tier: .platinum,
        currentProgress: 0,
        requiredProgress: 100,
        iconName: "💎"
    )

    return AchievementCardView(achievement: achievement)
        .frame(width: 180, height: 220)
        .padding()
}

#Preview("In Progress Achievement") {
    let achievement = Achievement(
        id: "test_progress",
        name: "Century Club",
        description: "Play 100 hands",
        unlockHint: "Keep playing",
        category: .milestone,
        tier: .silver,
        currentProgress: 50,
        requiredProgress: 100,
        iconName: "💯"
    )

    return AchievementCardView(achievement: achievement)
        .frame(width: 180, height: 220)
        .padding()
}

#Preview("Compact Card") {
    var achievement = Achievement(
        id: "test_compact",
        name: "First Hand",
        description: "Play your first hand",
        unlockHint: "Place a bet",
        category: .milestone,
        tier: .bronze,
        currentProgress: 50,
        requiredProgress: 100,
        iconName: "🎴"
    )

    return CompactAchievementCardView(achievement: achievement)
        .padding()
}
