//
//  ProgressView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Phase 8-10 Feature Hub
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📈 PROGRESS VIEW - Achievements, Challenges, Social                       ║
// ║                                                                            ║
// ║ Purpose: Consolidated view for progression and social features            ║
// ║ Business Context: Separates advanced features from core settings          ║
// ║                   Makes Settings cleaner and more focused                 ║
// ║                                                                            ║
// ║ Features:                                                                  ║
// ║ • Achievements & Level progression (Phase 8)                              ║
// ║ • Daily/Weekly Challenges (Phase 9)                                       ║
// ║ • Leaderboards & Social (Phase 10)                                        ║
// ║ • Player profile customization                                            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct ProgressView: View {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔗 DEPENDENCIES                                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var progressionManager = ProgressionManager.shared
    @StateObject private var challengeManager = ChallengeManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Section", selection: $selectedTab) {
                    Text("Progress").tag(0)
                    Text("Achievements").tag(1)
                    Text("Challenges").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                TabView(selection: $selectedTab) {
                    // Tab 0: Progress & Levels
                    progressTab
                        .tag(0)

                    // Tab 1: Achievements
                    achievementsTab
                        .tag(1)

                    // Tab 2: Challenges
                    challengesTab
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color.appBackground)
            .navigationTitle("Progress & Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.info)
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 PROGRESS TAB                                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    private var progressTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Level & XP Card
                VStack(spacing: 16) {
                    // Level badge
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.info, Color.info.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        VStack(spacing: 4) {
                            Text("LEVEL")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))

                            Text("\(progressionManager.currentLevel)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 24)

                    // Rank title
                    VStack(spacing: 4) {
                        Text(progressionManager.fullRank)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(progressionManager.rankEmoji)
                            .font(.largeTitle)
                    }

                    // XP Progress bar
                    if !progressionManager.isMaxLevel {
                        VStack(spacing: 8) {
                            HStack {
                                Text("XP Progress")
                                    .font(.caption)
                                    .foregroundColor(.mediumGrey)

                                Spacer()

                                Text(progressionManager.levelProgressText)
                                    .font(.caption)
                                    .foregroundColor(.info)
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.darkGrey)
                                        .frame(height: 12)

                                    // Progress
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.info)
                                        .frame(
                                            width: geometry.size.width * progressionManager.levelProgress,
                                            height: 12
                                        )
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding(.horizontal, 24)
                    }

                    // Total XP
                    Text("Total XP: \(progressionManager.formattedTotalXP)")
                        .font(.caption)
                        .foregroundColor(.mediumGrey)
                        .padding(.bottom, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.darkGrey.opacity(0.3))
                )
                .padding(.horizontal)
                .padding(.top)

                // Stats summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        progressStatRow(
                            icon: "trophy.fill",
                            title: "Achievements",
                            value: "\(achievementManager.unlockedCount)/\(achievementManager.totalAchievements)",
                            colour: .yellow
                        )

                        progressStatRow(
                            icon: "target",
                            title: "Challenges Completed",
                            value: "\(challengeManager.completedChallengesCount)",
                            colour: .orange
                        )

                        progressStatRow(
                            icon: "flame.fill",
                            title: "Login Streak",
                            value: "\(challengeManager.dailyLoginStreak) days",
                            colour: .red
                        )

                        progressStatRow(
                            icon: "gamecontroller.fill",
                            title: "Total Hands Played",
                            value: "\(StatisticsManager.shared.allTimeHandsPlayed)",
                            colour: .blue
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.darkGrey.opacity(0.3))
                    )
                    .padding(.horizontal)
                }

                // Next milestone
                if let nextMilestone = progressionManager.nextMilestone {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Next Milestone")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        HStack {
                            Image(systemName: "star.circle.fill")
                                .font(.title)
                                .foregroundColor(.yellow)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(nextMilestone.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Text(nextMilestone.description)
                                    .font(.caption)
                                    .foregroundColor(.mediumGrey)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.darkGrey.opacity(0.3))
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 32)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏆 ACHIEVEMENTS TAB                                                  │
    // └─────────────────────────────────────────────────────────────────────┘

    private var achievementsTab: some View {
        AchievementsView()
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 CHALLENGES TAB                                                    │
    // └─────────────────────────────────────────────────────────────────────┘

    private var challengesTab: some View {
        ChallengesView()
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 HELPER VIEWS                                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    private func progressStatRow(icon: String, title: String, value: String, colour: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(colour)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.mediumGrey)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Spacer()
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🔧 PROGRESSION MANAGER EXTENSION                                          ║
// ║                                                                            ║
// ║ Computed properties for display formatting                                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension ProgressionManager {
    var levelProgress: Double {
        guard !isMaxLevel else { return 1.0 }
        let xpInCurrentLevel = Double(currentXPInLevel)
        let xpNeeded = Double(xpForNextLevel)
        return xpInCurrentLevel / xpNeeded
    }

    struct Milestone {
        let title: String
        let description: String
    }

    var nextMilestone: Milestone? {
        if currentLevel < 10 {
            return Milestone(
                title: "Reach Level 10",
                description: "Unlock the 'Apprentice' rank and special card backs"
            )
        } else if currentLevel < 25 {
            return Milestone(
                title: "Reach Level 25",
                description: "Unlock the 'Professional' rank and exclusive table felts"
            )
        } else if currentLevel < 50 {
            return Milestone(
                title: "Reach Level 50",
                description: "Unlock the 'Master' rank and premium features"
            )
        } else if !isMaxLevel {
            return Milestone(
                title: "Reach Level 100",
                description: "Achieve max level and unlock legendary status"
            )
        }
        return nil
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview {
    ProgressView()
}
