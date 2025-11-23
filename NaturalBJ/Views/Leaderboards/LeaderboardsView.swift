//
//  LeaderboardsView.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Leaderboards View
// ═══════════════════════════════════════════════════════════════════════════════════
/// Main leaderboards screen with category/timeframe selection and rankings
struct LeaderboardsView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 STATE                                                         │
    // └─────────────────────────────────────────────────────────────────┘

    @StateObject private var leaderboardManager = LeaderboardManager.shared
    @State private var selectedCategory: LeaderboardCategory = .level
    @State private var selectedTimeframe: LeaderboardTimeframe = .allTime
    @State private var isRefreshing = false
    @State private var showingPersonalBests = false
    @State private var selectedTab: LeaderboardTab = .global

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

                VStack(spacing: 0) {
                    // Tab selector
                    tabSelector

                    // Category picker (for global tab)
                    if selectedTab == .global {
                        LeaderboardCategoryPicker(
                            selectedCategory: $selectedCategory,
                            categories: LeaderboardCategory.allCases.filter { $0.isGlobal }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }

                    // Timeframe picker
                    timeframePicker
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                    // Content
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if selectedTab == .global {
                                globalLeaderboardContent
                            } else {
                                dealerLeaderboardContent
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await refreshLeaderboards()
                    }
                }
            }
            .navigationTitle("🏆 Leaderboards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPersonalBests = true
                    } label: {
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingPersonalBests) {
                PersonalBestsView()
            }
        }
        .preferredColorScheme(.dark)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 TAB SELECTOR                                                  │
    // └─────────────────────────────────────────────────────────────────┘

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(LeaderboardTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                        // Reset to default category for dealer tab
                        if tab == .dealers {
                            selectedCategory = .mostHandsVsRuby
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(tab.icon)
                            .font(.title2)

                        Text(tab.rawValue)
                            .font(.caption)
                            .fontWeight(selectedTab == tab ? .bold : .regular)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == tab
                            ? Color.blue.opacity(0.2)
                            : Color.clear
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(selectedTab == tab ? .blue : .clear),
                        alignment: .bottom
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(white: 0.1))
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⏰ TIMEFRAME PICKER                                              │
    // └─────────────────────────────────────────────────────────────────┘

    private var timeframePicker: some View {
        HStack(spacing: 8) {
            ForEach(LeaderboardTimeframe.allCases, id: \.self) { timeframe in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTimeframe = timeframe
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(timeframe.icon)
                        Text(timeframe.displayName)
                            .font(.caption)
                            .fontWeight(selectedTimeframe == timeframe ? .bold : .regular)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        selectedTimeframe == timeframe
                            ? Color.blue
                            : Color(white: 0.15)
                    )
                    .foregroundColor(
                        selectedTimeframe == timeframe
                            ? .white
                            : .gray
                    )
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🌍 GLOBAL LEADERBOARD CONTENT                                    │
    // └─────────────────────────────────────────────────────────────────┘

    private var globalLeaderboardContent: some View {
        let leaderboard = leaderboardManager.getLeaderboard(
            category: selectedCategory,
            timeframe: selectedTimeframe
        )

        return Group {
            // Header with category info
            categoryHeader

            // Top 3 podium
            if leaderboard.count >= 3 {
                podiumView(leaderboard: Array(leaderboard.prefix(3)))
                    .padding(.bottom, 16)
            }

            // Full leaderboard
            VStack(spacing: 8) {
                ForEach(leaderboard) { entry in
                    LeaderboardEntryView(
                        entry: entry,
                        category: selectedCategory
                    )
                }
            }

            // Empty state
            if leaderboard.isEmpty {
                emptyStateView
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎴 DEALER LEADERBOARD CONTENT                                    │
    // └─────────────────────────────────────────────────────────────────┘

    private var dealerLeaderboardContent: some View {
        VStack(spacing: 16) {
            // Dealer selector
            dealerPicker

            // Dealer leaderboard
            let leaderboard = leaderboardManager.getLeaderboard(
                category: selectedCategory,
                timeframe: selectedTimeframe
            )

            VStack(spacing: 8) {
                ForEach(leaderboard) { entry in
                    LeaderboardEntryView(
                        entry: entry,
                        category: selectedCategory
                    )
                }
            }

            if leaderboard.isEmpty {
                emptyStateView
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎴 DEALER PICKER                                                 │
    // └─────────────────────────────────────────────────────────────────┘

    private var dealerPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Dealer")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    dealerButton(name: "Ruby", category: .mostHandsVsRuby)
                    dealerButton(name: "Lucky", category: .mostHandsVsLucky)
                    dealerButton(name: "Shark", category: .mostHandsVsShark)
                    dealerButton(name: "Zen", category: .mostHandsVsZen)
                    dealerButton(name: "Maverick", category: .mostHandsVsMaverick)
                }
            }
        }
    }

    private func dealerButton(name: String, category: LeaderboardCategory) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedCategory = category
            }
        } label: {
            VStack(spacing: 4) {
                Text(getDealerEmoji(name))
                    .font(.largeTitle)

                Text(name)
                    .font(.caption)
                    .fontWeight(selectedCategory == category ? .bold : .regular)
            }
            .frame(width: 80, height: 80)
            .background(
                selectedCategory == category
                    ? Color.blue.opacity(0.3)
                    : Color(white: 0.15)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        selectedCategory == category ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 CATEGORY HEADER                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var categoryHeader: some View {
        VStack(spacing: 8) {
            Text(selectedCategory.icon)
                .font(.system(size: 60))

            Text(selectedCategory.displayName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Global Challenge Rankings")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.1))
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏆 PODIUM VIEW                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    private func podiumView(leaderboard: [LeaderboardEntry]) -> some View {
        HStack(alignment: .bottom, spacing: 12) {
            // 2nd place
            if leaderboard.count > 1 {
                podiumPlace(entry: leaderboard[1], height: 120)
            }

            // 1st place (taller)
            if leaderboard.count > 0 {
                podiumPlace(entry: leaderboard[0], height: 160)
            }

            // 3rd place
            if leaderboard.count > 2 {
                podiumPlace(entry: leaderboard[2], height: 100)
            }
        }
        .padding()
    }

    private func podiumPlace(entry: LeaderboardEntry, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            // Medal
            if let medal = entry.medalEmoji {
                Text(medal)
                    .font(.system(size: 40))
            }

            // Player icon
            Text(entry.iconEmoji)
                .font(.system(size: 32))

            // Player name
            Text(entry.playerName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(1)

            // Score
            Text(entry.formattedScore(for: selectedCategory))
                .font(.caption2)
                .foregroundColor(.gray)

            Spacer()

            // Rank number
            Text("#\(entry.rank)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    entry.rank == 1 ? Color.yellow.opacity(0.2) :
                    entry.rank == 2 ? Color.gray.opacity(0.2) :
                    Color.orange.opacity(0.2)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    entry.rank == 1 ? Color.yellow :
                    entry.rank == 2 ? Color.gray :
                    Color.orange,
                    lineWidth: entry.isCurrentPlayer ? 3 : 1
                )
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📭 EMPTY STATE                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Rankings Yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Play more to qualify for this leaderboard!")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔄 REFRESH                                                       │
    // └─────────────────────────────────────────────────────────────────┘

    private func refreshLeaderboards() async {
        isRefreshing = true

        // Simulate network delay for realism
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        leaderboardManager.refreshIfNeeded()

        isRefreshing = false
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 UTILITY                                                       │
    // └─────────────────────────────────────────────────────────────────┘

    private func getDealerEmoji(_ name: String) -> String {
        switch name {
        case "Ruby": return "💎"
        case "Lucky": return "🍀"
        case "Shark": return "🦈"
        case "Zen": return "🧘"
        case "Maverick": return "🤠"
        default: return "🎴"
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Leaderboard Tab
// ═══════════════════════════════════════════════════════════════════════════════════
enum LeaderboardTab: String, CaseIterable {
    case global = "Global"
    case dealers = "Dealers"

    var icon: String {
        switch self {
        case .global: return "🌍"
        case .dealers: return "🎴"
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    LeaderboardsView()
}
