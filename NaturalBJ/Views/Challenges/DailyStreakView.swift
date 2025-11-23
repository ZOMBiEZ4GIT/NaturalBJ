//
//  DailyStreakView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 9: Daily Challenges & Events System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🔥 DAILY STREAK VIEW                                                       ║
// ║                                                                            ║
// ║ Purpose: Widget displaying player's daily login streak                    ║
// ║ Business Context: Daily login streaks encourage habit formation and       ║
// ║                   reward consistent play. This widget shows streak        ║
// ║                   progress and milestone rewards.                         ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Display current streak count (e.g., "5-day streak 🔥")                  ║
// ║ • Show calendar view of login days                                        ║
// ║ • Display streak milestone rewards (7, 14, 30, 60, 90 days)               ║
// ║ • Show streak protection status                                           ║
// ║ • Preview next milestone                                                  ║
// ║                                                                            ║
// ║ Used By: ChallengesView (top widget)                                      ║
// ║ Uses: TimeManager (streak tracking)                                       ║
// ║                                                                            ║
// ║ Related Spec: See "Daily Challenges & Events System" Phase 9              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct DailyStreakView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 STATE & DEPENDENCIES                                          │
    // └─────────────────────────────────────────────────────────────────┘

    @StateObject private var timeManager = TimeManager.shared
    @StateObject private var challengeManager = ChallengeManager.shared

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                           │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        VStack(spacing: 16) {
            // Streak Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔥 Daily Login Streak")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(streakMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Current Streak Count
                VStack(spacing: 4) {
                    Text("\(challengeManager.dailyLoginStreak)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.orange)

                    Text("DAYS")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Milestones
            milestonesView

            // Next Milestone Preview
            if let nextMilestone = getNextMilestone() {
                nextMilestoneView(milestone: nextMilestone)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.orange.opacity(0.1), .red.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎯 MILESTONES VIEW                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var milestonesView: some View {
        HStack(spacing: 12) {
            ForEach(streakMilestones.prefix(5), id: \.days) { milestone in
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(milestoneBackground(milestone: milestone))
                            .frame(width: 40, height: 40)

                        if challengeManager.dailyLoginStreak >= milestone.days {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        } else {
                            Text(milestone.icon)
                                .font(.caption)
                        }
                    }

                    Text("\(milestone.days)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(challengeManager.dailyLoginStreak >= milestone.days ? .orange : .secondary)
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎁 NEXT MILESTONE VIEW                                           │
    // └─────────────────────────────────────────────────────────────────┘

    private func nextMilestoneView(milestone: StreakMilestone) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("NEXT MILESTONE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(milestone.days - challengeManager.dailyLoginStreak) days to go")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            HStack(spacing: 8) {
                Text(milestone.icon)
                    .font(.title3)

                Text("\(milestone.days) Day Streak")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(milestone.reward)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 COMPUTED PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    private var streakMessage: String {
        let streak = challengeManager.dailyLoginStreak

        if streak == 0 {
            return "Log in daily to build your streak!"
        } else if streak == 1 {
            return "Great start! Come back tomorrow"
        } else if streak < 7 {
            return "Keep it going!"
        } else if streak < 30 {
            return "You're on fire!"
        } else {
            return "Legendary dedication!"
        }
    }

    private func milestoneBackground(milestone: StreakMilestone) -> Color {
        if challengeManager.dailyLoginStreak >= milestone.days {
            return .orange
        } else {
            return Color.secondary.opacity(0.2)
        }
    }

    private func getNextMilestone() -> StreakMilestone? {
        return streakMilestones.first { $0.days > challengeManager.dailyLoginStreak }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 STREAK MILESTONE DATA                                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct StreakMilestone {
    let days: Int
    let icon: String
    let reward: String
}

let streakMilestones: [StreakMilestone] = [
    StreakMilestone(days: 7, icon: "🎯", reward: "+500 XP"),
    StreakMilestone(days: 14, icon: "🏅", reward: "+1000 XP, $2500"),
    StreakMilestone(days: 30, icon: "👑", reward: "+2500 XP, Exclusive Felt"),
    StreakMilestone(days: 60, icon: "💎", reward: "+5000 XP, $10K"),
    StreakMilestone(days: 90, icon: "🔥", reward: "+10K XP, Streak Shield")
]

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("5 Day Streak") {
    DailyStreakView()
        .padding()
}
