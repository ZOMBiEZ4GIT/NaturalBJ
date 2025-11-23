//
//  ChallengesView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 9: Daily Challenges & Events System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎯 CHALLENGES VIEW                                                         ║
// ║                                                                            ║
// ║ Purpose: Main screen for viewing all active challenges                    ║
// ║ Business Context: Players want to see their daily/weekly goals and        ║
// ║                   track progress towards rewards. This view provides      ║
// ║                   a clear overview of all challenges and time remaining.  ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Display daily challenges section                                        ║
// ║ • Display weekly challenges section                                       ║
// ║ • Display special event challenges (when active)                          ║
// ║ • Show daily login streak widget                                          ║
// ║ • Display countdown timers for refresh                                    ║
// ║ • Filter by status (Active/Completed)                                     ║
// ║                                                                            ║
// ║ Used By: Main navigation from Settings or ContentView                     ║
// ║ Uses: ChallengeManager (observes challenges)                              ║
// ║       ChallengeCardView (renders individual challenges)                   ║
// ║       DailyStreakView (displays login streak)                             ║
// ║                                                                            ║
// ║ Related Spec: See "Daily Challenges & Events System" Phase 9              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct ChallengesView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 STATE & DEPENDENCIES                                          │
    // └─────────────────────────────────────────────────────────────────┘

    @StateObject private var challengeManager = ChallengeManager.shared
    @StateObject private var timeManager = TimeManager.shared

    @State private var selectedFilter: ChallengeFilter = .all
    @State private var showCompletedOnly = false

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                           │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Daily Login Streak Widget
                DailyStreakView()
                    .padding(.horizontal)

                // Special Events Banner (if active)
                if !challengeManager.activeEventChallenges.isEmpty {
                    eventBanner
                }

                // Daily Challenges Section
                dailyChallengesSection

                // Weekly Challenges Section
                weeklyChallengesSection

                // Completed Challenges History
                if !completedChallenges.isEmpty {
                    completedSection
                }

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .navigationTitle("🎯 Challenges")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            challengeManager.checkForRefresh()
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎉 EVENT BANNER                                                  │
    // └─────────────────────────────────────────────────────────────────┘

    private var eventBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🎉 SPECIAL EVENT")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text(timeManager.isWeekend() ? "Weekend Bonus" : "Limited Time")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }

            ForEach(challengeManager.activeEventChallenges) { challenge in
                ChallengeCardView(challenge: challenge)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ☀️ DAILY CHALLENGES SECTION                                      │
    // └─────────────────────────────────────────────────────────────────┘

    private var dailyChallengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("☀️ Daily Challenges")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Resets in: \(timeManager.formattedTimeUntilMidnight())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            // Challenge Cards
            if filteredDailyChallenges.isEmpty {
                emptyState(message: "No daily challenges available")
            } else {
                ForEach(filteredDailyChallenges) { challenge in
                    ChallengeCardView(challenge: challenge)
                        .padding(.horizontal)
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📅 WEEKLY CHALLENGES SECTION                                     │
    // └─────────────────────────────────────────────────────────────────┘

    private var weeklyChallengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📅 Weekly Challenges")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Resets in: \(timeManager.formattedTimeUntilWeeklyReset())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            // Challenge Cards
            if filteredWeeklyChallenges.isEmpty {
                emptyState(message: "No weekly challenges available")
            } else {
                ForEach(filteredWeeklyChallenges) { challenge in
                    ChallengeCardView(challenge: challenge)
                        .padding(.horizontal)
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ✅ COMPLETED CHALLENGES SECTION                                  │
    // └─────────────────────────────────────────────────────────────────┘

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("✅ Recently Completed")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            ForEach(completedChallenges.prefix(5)) { challenge in
                ChallengeCardView(challenge: challenge)
                    .padding(.horizontal)
                    .opacity(0.7)
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📭 EMPTY STATE                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    private func emptyState(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔍 COMPUTED PROPERTIES (FILTERING)                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var filteredDailyChallenges: [Challenge] {
        return challengeManager.activeDailyChallenges.filter { challenge in
            if showCompletedOnly {
                return challenge.isCompleted
            } else {
                return !challenge.isCompleted
            }
        }
    }

    private var filteredWeeklyChallenges: [Challenge] {
        return challengeManager.activeWeeklyChallenges.filter { challenge in
            if showCompletedOnly {
                return challenge.isCompleted
            } else {
                return !challenge.isCompleted
            }
        }
    }

    private var completedChallenges: [Challenge] {
        return challengeManager.getAllActiveChallenges().filter { $0.isCompleted }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏷️ CHALLENGE FILTER ENUM                                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum ChallengeFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview {
    NavigationView {
        ChallengesView()
    }
}
