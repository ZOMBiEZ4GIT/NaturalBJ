//
//  PersonalBestsView.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Personal Bests View
// ═══════════════════════════════════════════════════════════════════════════════════
/// Displays player's personal best records across all categories
struct PersonalBestsView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 STATE                                                         │
    // └─────────────────────────────────────────────────────────────────┘

    @StateObject private var leaderboardManager = LeaderboardManager.shared
    @StateObject private var sharingManager = SharingManager.shared
    @Environment(\.dismiss) private var dismiss

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
                        // Header
                        headerView

                        // Personal bests list
                        personalBestsSection

                        // Empty state
                        if leaderboardManager.personalBests.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("⭐ Personal Bests")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 HEADER                                                        │
    // └─────────────────────────────────────────────────────────────────┘

    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("Your Best Achievements")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Track your personal records across all categories")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.1))
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏆 PERSONAL BESTS SECTION                                        │
    // └─────────────────────────────────────────────────────────────────┘

    private var personalBestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All-Time Records")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            ForEach(leaderboardManager.getAllPersonalBests()) { record in
                PersonalBestCard(
                    record: record,
                    onShare: {
                        sharePersonalBest(record)
                    }
                )
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📭 EMPTY STATE                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Personal Bests Yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Keep playing to set your first personal best!")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📤 SHARE                                                         │
    // └─────────────────────────────────────────────────────────────────┘

    private func sharePersonalBest(_ record: PersonalBestRecord) {
        sharingManager.offerSharePersonalBest(
            category: record.category,
            score: record.bestScore,
            rank: record.bestRank
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Personal Best Card
// ═══════════════════════════════════════════════════════════════════════════════════
private struct PersonalBestCard: View {

    let record: PersonalBestRecord
    let onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack {
                Text(record.category.icon)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(record.category.displayName)
                        .font(.headline)
                        .foregroundColor(.white)

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

                Spacer()

                // Share button
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }

            // Score
            HStack(alignment: .bottom, spacing: 8) {
                Text(formatScore(record.bestScore, for: record.category))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                if record.previousBest > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.caption2)
                            Text(record.improvementString)
                                .font(.caption)
                        }
                        .foregroundColor(.green)

                        Text("from \(formatScore(record.previousBest, for: record.category))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }

            // Rank info
            if let rank = record.bestRank {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)

                    Text("Global Rank: #\(rank)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if rank <= 3 {
                        Text("Top 3! 🏆")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    } else if rank <= 10 {
                        Text("Top 10! 🌟")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                    } else if rank <= 100 {
                        Text("Top 100! ⭐")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                }
            }

            // Date achieved
            Text("Achieved \(formatDate(record.achievedDate))")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    record.isNew ? Color.green : Color(white: 0.2),
                    lineWidth: record.isNew ? 2 : 1
                )
        )
    }

    // Format score based on category
    private func formatScore(_ score: Double, for category: LeaderboardCategory) -> String {
        switch category.unit {
        case "%":
            return String(format: "%.1f%%", score)
        case "$":
            return String(format: "$%.0f", score)
        default:
            let scoreStr = String(format: "%.0f", score)
            return category.unit.isEmpty ? scoreStr : "\(scoreStr) \(category.unit)"
        }
    }

    // Format date
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    PersonalBestsView()
}
