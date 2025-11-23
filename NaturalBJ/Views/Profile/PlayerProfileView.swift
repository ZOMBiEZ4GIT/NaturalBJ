//
//  PlayerProfileView.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Player Profile View
// ═══════════════════════════════════════════════════════════════════════════════════
/// Comprehensive player profile with stats, rankings, and customisation
struct PlayerProfileView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 STATE                                                         │
    // └─────────────────────────────────────────────────────────────────┘

    @StateObject private var progressionManager = ProgressionManager.shared
    @StateObject private var leaderboardManager = LeaderboardManager.shared
    @StateObject private var achievementManager = AchievementManager.shared

    @State private var showingIconPicker = false
    @State private var showingNameEditor = false
    @State private var showingPersonalBests = false

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(white: 0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Profile header
                        profileHeader

                        // Quick stats
                        quickStatsSection

                        // Leaderboard rankings
                        leaderboardRankingsSection

                        // Personal bests
                        personalBestsSection

                        // Recent achievements
                        recentAchievementsSection

                        // Privacy settings
                        privacySettingsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("👤 Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingIconPicker) {
            if let profile = progressionManager.profile {
                IconEmojiPickerView(selectedEmoji: Binding(
                    get: { profile.iconEmoji },
                    set: { newEmoji in
                        progressionManager.updateIconEmoji(newEmoji)
                    }
                ))
            }
        }
        .sheet(isPresented: $showingNameEditor) {
            if let profile = progressionManager.profile {
                DisplayNameEditorView(displayName: Binding(
                    get: { profile.displayName },
                    set: { newName in
                        progressionManager.updateDisplayName(newName)
                    }
                ))
            }
        }
        .sheet(isPresented: $showingPersonalBests) {
            PersonalBestsView()
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 👤 PROFILE HEADER                                                │
    // └─────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private var profileHeader: some View {
        if let profile = progressionManager.profile {
            VStack(spacing: 16) {
                // Icon (tappable)
                Button {
                    showingIconPicker = true
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Text(profile.iconEmoji)
                            .font(.system(size: 80))
                            .frame(width: 120, height: 120)
                            .background(
                                Circle()
                                    .fill(Color(white: 0.15))
                            )

                        // Edit badge
                        Image(systemName: "pencil.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.black))
                    }
                }
                .buttonStyle(.plain)

                // Display name (tappable)
                Button {
                    showingNameEditor = true
                } label: {
                    HStack(spacing: 8) {
                        Text(profile.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(.plain)

                // Rank badge
                HStack(spacing: 8) {
                    Text(profile.rankEmoji)
                    Text(profile.rankTitle)
                        .font(.headline)
                        .foregroundColor(.purple)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.purple.opacity(0.2))
                )

                // XP progress
                VStack(spacing: 8) {
                    HStack {
                        Text("Level \(profile.level)")
                            .font(.caption)
                            .fontWeight(.semibold)

                        Spacer()

                        Text("Level \(profile.level + 1)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.cyan)

                    ProgressView(value: progressionManager.progressToNextLevel)
                        .tint(.cyan)

                    Text("\(profile.experiencePoints) / \(progressionManager.xpRequiredForNextLevel) XP")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.1))
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.12))
            )
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 QUICK STATS                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private var quickStatsSection: some View {
        if let profile = progressionManager.profile {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Stats")
                    .font(.headline)
                    .foregroundColor(.white)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    statCard(
                        icon: "suit.club.fill",
                        label: "Hands Played",
                        value: "\(profile.lifetimeHandsPlayed)",
                        color: .red
                    )

                    statCard(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "Win Rate",
                        value: profile.formattedLifetimeWinRate,
                        color: .green
                    )

                    statCard(
                        icon: "dollarsign.circle.fill",
                        label: "Lifetime Profit",
                        value: profile.formattedLifetimeNetProfit,
                        color: .yellow
                    )

                    statCard(
                        icon: "trophy.fill",
                        label: "Achievements",
                        value: "\(profile.achievementsUnlocked)/44",
                        color: .purple
                    )
                }
            }
        }
    }

    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏆 LEADERBOARD RANKINGS                                          │
    // └─────────────────────────────────────────────────────────────────┘

    private var leaderboardRankingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Leaderboard Rankings")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                NavigationLink(destination: LeaderboardsView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            // Top 3 rankings
            VStack(spacing: 8) {
                let topCategories: [LeaderboardCategory] = [.level, .totalXP, .winRate]

                ForEach(topCategories, id: \.self) { category in
                    if let rank = leaderboardManager.getPlayerRank(category: category) {
                        rankingCard(category: category, rank: rank)
                    }
                }
            }
        }
    }

    private func rankingCard(category: LeaderboardCategory, rank: Int) -> some View {
        HStack {
            Text(category.icon)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.caption)
                    .foregroundColor(.white)

                Text("Rank #\(rank)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Badge for top rankings
            if rank <= 3 {
                Text("🥇 Top 3!")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .foregroundColor(.yellow)
                    .cornerRadius(8)
            } else if rank <= 10 {
                Text("⭐ Top 10")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.2))
                    .foregroundColor(.cyan)
                    .cornerRadius(8)
            } else if rank <= 100 {
                Text("Top 100")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.2))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⭐ PERSONAL BESTS                                                 │
    // └─────────────────────────────────────────────────────────────────┘

    private var personalBestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Personal Bests")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    showingPersonalBests = true
                } label: {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            let topBests = Array(leaderboardManager.getAllPersonalBests().prefix(3))

            if topBests.isEmpty {
                Text("No personal bests yet. Keep playing!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(topBests) { record in
                        personalBestCard(record: record)
                    }
                }
            }
        }
    }

    private func personalBestCard(record: PersonalBestRecord) -> some View {
        HStack {
            Text(record.category.icon)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.category.displayName)
                    .font(.caption)
                    .foregroundColor(.white)

                Text(formatScore(record.bestScore, for: record.category))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            if record.isNew {
                Text("NEW!")
                    .font(.caption2)
                    .fontWeight(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏅 RECENT ACHIEVEMENTS                                           │
    // └─────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private var recentAchievementsSection: some View {
        if let profile = progressionManager.profile {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recent Achievements")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    NavigationLink(destination: Text("Achievements View")) {
                        Text("View All")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                let recentAchievements = getRecentAchievements()

                if recentAchievements.isEmpty {
                    Text("No achievements unlocked yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    VStack(spacing: 8) {
                        ForEach(recentAchievements) { achievement in
                            achievementCard(achievement: achievement)
                        }
                    }
                }
            }
        }
    }

    private func achievementCard(achievement: Achievement) -> some View {
        HStack(spacing: 12) {
            Text(achievement.tier.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(achievement.tier.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("+\(achievement.xpReward) XP")
                .font(.caption2)
                .foregroundColor(.cyan)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔒 PRIVACY SETTINGS                                              │
    // └─────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private var privacySettingsSection: some View {
        if let profile = progressionManager.profile {
            VStack(alignment: .leading, spacing: 12) {
                Text("Privacy & Sharing")
                    .font(.headline)
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    Toggle(isOn: Binding(
                        get: { profile.shareAchievements },
                        set: { _ in progressionManager.toggleShareAchievements() }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Share Achievements")
                                .font(.caption)
                                .foregroundColor(.white)

                            Text("Allow showing achievements in leaderboards")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(.blue)

                    Divider()

                    Toggle(isOn: Binding(
                        get: { profile.shareStats },
                        set: { _ in progressionManager.toggleShareStats() }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Share Statistics")
                                .font(.caption)
                                .foregroundColor(.white)

                            Text("Allow showing stats in leaderboards")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(.blue)

                    Divider()

                    Toggle(isOn: Binding(
                        get: { profile.isAnonymous },
                        set: { _ in progressionManager.toggleAnonymousMode() }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Anonymous Mode")
                                .font(.caption)
                                .foregroundColor(.white)

                            Text("Show as 'Anonymous Player' in leaderboards")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.1))
                )
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🛠️ UTILITY METHODS                                               │
    // └─────────────────────────────────────────────────────────────────┘

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

    private func getRecentAchievements() -> [Achievement] {
        guard let profile = progressionManager.profile else { return [] }

        let unlocked = achievementManager.achievements.filter {
            profile.achievementUnlockDates[$0.id] != nil
        }

        return Array(unlocked.sorted {
            (profile.achievementUnlockDates[$0.id] ?? Date.distantPast) >
            (profile.achievementUnlockDates[$1.id] ?? Date.distantPast)
        }.prefix(5))
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    PlayerProfileView()
}
