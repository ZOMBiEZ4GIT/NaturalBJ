//
//  AchievementsView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 8: Achievements & Progression System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏆 ACHIEVEMENTS VIEW                                                       ║
// ║                                                                            ║
// ║ Purpose: Main screen displaying all achievements with filtering & sorting ║
// ║ Business Context: Players want to see their progress across all           ║
// ║                   achievements, filter by category, and track completion. ║
// ║                                                                            ║
// ║ Features:                                                                  ║
// ║ • Grid/list view of all achievements                                      ║
// ║ • Filter by category (All/Milestone/Performance/etc.)                     ║
// ║ • Filter by status (All/Unlocked/Locked/In Progress)                      ║
// ║ • Sort options (Newest/Progress/Difficulty)                               ║
// ║ • Progress summary header                                                  ║
// ║ • Achievement detail sheets                                               ║
// ║ • Level & XP display                                                       ║
// ║                                                                            ║
// ║ Used By: Settings menu (navigation link)                                  ║
// ║ Uses: AchievementManager, ProgressionManager, AchievementCardView         ║
// ║                                                                            ║
// ║ Related Spec: See "Achievements & Progression System" Phase 8             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏆 ACHIEVEMENTS VIEW                                                       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct AchievementsView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var progressionManager = ProgressionManager.shared

    // Filter & sort state
    @State private var selectedCategory: AchievementCategory? = nil
    @State private var filterStatus: FilterStatus = .all
    @State private var sortBy: SortOption = .newest

    // UI state
    @State private var selectedAchievement: Achievement? = nil
    @State private var showingDetail = false

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with level & XP
                progressHeader

                // Achievement summary
                achievementSummary

                // Filters
                filterControls

                // Achievement grid
                achievementGrid
            }
            .padding()
        }
        .navigationTitle("🏆 Achievements")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDetail) {
            if let achievement = selectedAchievement {
                AchievementDetailView(achievement: achievement)
            }
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎨 VIEW COMPONENTS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROGRESS HEADER                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var progressHeader: some View {
        VStack(spacing: 12) {
            // Level & rank
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(progressionManager.currentLevel)")
                        .font(.system(size: 36, weight: .bold))

                    Text(progressionManager.fullRank)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(progressionManager.formattedTotalXP)
                        .font(.system(size: 16, weight: .semibold))

                    Text("Total XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // XP progress bar
            if !progressionManager.isMaxLevel {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(progressionManager.formattedXPProgress)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(progressionManager.levelProgressText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: progressionManager.currentLevelProgress)
                        .tint(.blue)
                }
            } else {
                Text("⭐ MAX LEVEL REACHED ⭐")
                    .font(.headline)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 ACHIEVEMENT SUMMARY                                           │
    // └─────────────────────────────────────────────────────────────────┘

    private var achievementSummary: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(achievementManager.unlockedCount)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.green)

                Text("Unlocked")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()
                .frame(height: 40)

            VStack(spacing: 4) {
                Text("\(achievementManager.totalAchievements)")
                    .font(.system(size: 32, weight: .bold))

                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()
                .frame(height: 40)

            VStack(spacing: 4) {
                Text(String(format: "%.0f%%", achievementManager.completionPercentage))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.blue)

                Text("Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎛️ FILTER CONTROLS                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var filterControls: some View {
        VStack(spacing: 12) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "All" button
                    FilterButton(
                        title: "All",
                        icon: "star.fill",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }

                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        FilterButton(
                            title: category.displayName,
                            icon: category.icon,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
            }

            // Status & sort controls
            HStack {
                // Status filter
                Menu {
                    ForEach(FilterStatus.allCases, id: \.self) { status in
                        Button {
                            filterStatus = status
                        } label: {
                            HStack {
                                Text(status.displayName)
                                if filterStatus == status {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(filterStatus.displayName)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }

                Spacer()

                // Sort menu
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            sortBy = option
                        } label: {
                            HStack {
                                Text(option.displayName)
                                if sortBy == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortBy.displayName)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎯 ACHIEVEMENT GRID                                              │
    // └─────────────────────────────────────────────────────────────────┘

    private var achievementGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 12) {
            ForEach(filteredAndSortedAchievements) { achievement in
                AchievementCardView(achievement: achievement)
                    .onTapGesture {
                        selectedAchievement = achievement
                        showingDetail = true
                    }
            }
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔍 FILTERING & SORTING LOGIC                                       ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    private var filteredAndSortedAchievements: [Achievement] {
        var filtered = achievementManager.achievements

        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        // Filter by status
        switch filterStatus {
        case .all:
            break
        case .unlocked:
            filtered = filtered.filter { $0.isUnlocked }
        case .locked:
            filtered = filtered.filter { !$0.isUnlocked }
        case .inProgress:
            filtered = filtered.filter { $0.isInProgress }
        }

        // Sort
        switch sortBy {
        case .newest:
            filtered.sort { a, b in
                if a.isUnlocked && b.isUnlocked {
                    return (a.unlockedDate ?? Date.distantPast) > (b.unlockedDate ?? Date.distantPast)
                }
                return a.isUnlocked && !b.isUnlocked
            }
        case .progress:
            filtered.sort { $0.progressPercentage > $1.progressPercentage }
        case .difficulty:
            filtered.sort { a, b in
                let tierOrder: [AchievementTier] = [.platinum, .gold, .silver, .bronze]
                let aIndex = tierOrder.firstIndex(of: a.tier) ?? 999
                let bIndex = tierOrder.firstIndex(of: b.tier) ?? 999
                return aIndex < bIndex
            }
        }

        return filtered
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎨 FILTER BUTTON COMPONENT                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if icon.count == 1 {
                    // Emoji
                    Text(icon)
                } else {
                    // SF Symbol
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📋 ACHIEVEMENT DETAIL VIEW                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Large icon
                    Text(achievement.iconName)
                        .font(.system(size: 100))
                        .padding()
                        .background(
                            Circle()
                                .fill(achievement.isUnlocked ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                        )

                    // Title & tier
                    VStack(spacing: 8) {
                        Text(achievement.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 12) {
                            Text(achievement.tier.medal)
                            Text(achievement.tier.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(achievement.category.icon)
                            Text(achievement.category.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Description
                    Text(achievement.displayDescription)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    // Progress or unlock date
                    if achievement.isUnlocked {
                        VStack(spacing: 8) {
                            Text("✓ Unlocked")
                                .font(.headline)
                                .foregroundColor(.green)

                            Text(achievement.formattedUnlockDate)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("+\(achievement.xpReward) XP")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 12) {
                            Text(achievement.progressString)
                                .font(.headline)

                            ProgressView(value: achievement.progressPercentage)
                                .tint(.blue)
                                .frame(maxWidth: 200)

                            Text(achievement.unlockHint)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Text("+\(achievement.xpReward) XP when unlocked")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 FILTER & SORT ENUMS                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum FilterStatus: CaseIterable {
    case all
    case unlocked
    case locked
    case inProgress

    var displayName: String {
        switch self {
        case .all: return "All"
        case .unlocked: return "Unlocked"
        case .locked: return "Locked"
        case .inProgress: return "In Progress"
        }
    }
}

enum SortOption: CaseIterable {
    case newest
    case progress
    case difficulty

    var displayName: String {
        switch self {
        case .newest: return "Newest"
        case .progress: return "Progress"
        case .difficulty: return "Difficulty"
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview {
    NavigationView {
        AchievementsView()
    }
}
