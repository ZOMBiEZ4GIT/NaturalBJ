//
//  ChallengeCardView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 9: Daily Challenges & Events System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎯 CHALLENGE CARD VIEW                                                     ║
// ║                                                                            ║
// ║ Purpose: Display a single challenge card with progress and rewards        ║
// ║ Business Context: Each challenge needs clear visual feedback about        ║
// ║                   progress, time remaining, and rewards. The card         ║
// ║                   provides all this information at a glance.              ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Display challenge name, icon, and description                           ║
// ║ • Show progress bar with count (e.g., "3/5 hands won")                    ║
// ║ • Display time remaining until expiry                                     ║
// ║ • Show reward preview (XP amount, bonus items)                            ║
// ║ • Display completion checkmark when done                                  ║
// ║ • Support tap to expand for details                                       ║
// ║                                                                            ║
// ║ Used By: ChallengesView (renders in lists)                                ║
// ║ Uses: Challenge model                                                      ║
// ║                                                                            ║
// ║ Related Spec: See "Daily Challenges & Events System" Phase 9              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct ChallengeCardView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 STATE & DEPENDENCIES                                          │
    // └─────────────────────────────────────────────────────────────────┘

    let challenge: Challenge

    @State private var isExpanded = false

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                           │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Text(challenge.iconName)
                    .font(.system(size: 40))

                // Challenge Info
                VStack(alignment: .leading, spacing: 4) {
                    // Name and Difficulty Badge
                    HStack(spacing: 8) {
                        Text(challenge.name)
                            .font(.headline)
                            .fontWeight(.semibold)

                        difficultyBadge
                    }

                    // Description
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(isExpanded ? nil : 2)
                }

                Spacer()

                // Completion Status
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }

            // Progress Bar
            if !challenge.isCompleted {
                VStack(alignment: .leading, spacing: 6) {
                    // Progress Text
                    HStack {
                        Text(challenge.formattedProgress)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(challenge.formattedTimeRemaining)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.2))

                            // Progress Fill
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [categoryColour, categoryColour.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * challenge.progressPercentage)
                        }
                    }
                    .frame(height: 8)
                }
            }

            // Rewards Preview
            if !challenge.rewards.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "gift.fill")
                        .font(.caption)
                        .foregroundColor(.purple)

                    ForEach(challenge.rewards) { reward in
                        Text(reward.shortDisplay)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                    }

                    Spacer()

                    if !isExpanded {
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Expanded Details
            if isExpanded {
                Divider()

                // Detailed Rewards
                VStack(alignment: .leading, spacing: 8) {
                    Text("REWARDS")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)

                    ForEach(challenge.rewards) { reward in
                        HStack(spacing: 8) {
                            Text(reward.type.iconName)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(reward.displayText)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text(reward.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(challenge.name), \(challenge.description), Progress: \(challenge.formattedProgress), Time remaining: \(challenge.formattedTimeRemaining)")
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 DIFFICULTY BADGE                                              │
    // └─────────────────────────────────────────────────────────────────┘

    private var difficultyBadge: some View {
        Text(challenge.difficulty.displayName)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(difficultyColour)
            .cornerRadius(4)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 COMPUTED PROPERTIES (STYLING)                                 │
    // └─────────────────────────────────────────────────────────────────┘

    private var categoryColour: Color {
        switch challenge.category {
        case .gameplay:
            return .blue
        case .performance:
            return .green
        case .exploration:
            return .purple
        case .mastery:
            return .orange
        }
    }

    private var difficultyColour: Color {
        switch challenge.difficulty {
        case .easy:
            return .gray
        case .medium:
            return .blue
        case .hard:
            return .orange
        case .expert:
            return .red
        }
    }

    private var cardBackground: Color {
        if challenge.isCompleted {
            return Color.green.opacity(0.05)
        } else if challenge.isExpired {
            return Color.red.opacity(0.05)
        } else {
            return Color(UIColor.systemBackground)
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("Active Challenge") {
    let challenge = Challenge(
        id: "test_1",
        name: "Triple Threat",
        description: "Win 3 hands in a row",
        iconName: "🔥",
        type: .daily,
        category: .performance,
        difficulty: .medium,
        requiredProgress: 3,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400),
        rewards: [.xp(100), .chips(500)],
        currentProgress: 1
    )

    return ChallengeCardView(challenge: challenge)
        .padding()
}

#Preview("Completed Challenge") {
    var challenge = Challenge(
        id: "test_2",
        name: "First Victory",
        description: "Win your first hand today",
        iconName: "🎯",
        type: .daily,
        category: .performance,
        difficulty: .easy,
        requiredProgress: 1,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400),
        rewards: [.xp(50)],
        currentProgress: 1,
        isCompleted: true
    )

    return ChallengeCardView(challenge: challenge)
        .padding()
}
