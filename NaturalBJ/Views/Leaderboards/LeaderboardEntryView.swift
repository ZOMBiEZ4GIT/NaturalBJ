//
//  LeaderboardEntryView.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Leaderboard Entry View
// ═══════════════════════════════════════════════════════════════════════════════════
/// Individual leaderboard entry card displaying player ranking
struct LeaderboardEntryView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    let entry: LeaderboardEntry
    let category: LeaderboardCategory

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        HStack(spacing: 16) {
            // Rank number or medal
            rankView

            // Player icon
            Text(entry.iconEmoji)
                .font(.title2)

            // Player info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.playerName)
                        .font(.headline)
                        .fontWeight(entry.isCurrentPlayer ? .bold : .semibold)
                        .foregroundColor(.white)

                    if entry.isCurrentPlayer {
                        Text("YOU")
                            .font(.caption2)
                            .fontWeight(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }

                HStack(spacing: 8) {
                    // Level
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption2)
                        Text("Lv \(entry.playerLevel)")
                            .font(.caption)
                    }
                    .foregroundColor(.cyan)

                    Text("•")
                        .foregroundColor(.gray)

                    // Rank title
                    Text(entry.playerRank)
                        .font(.caption)
                        .foregroundColor(.purple)

                    Text("•")
                        .foregroundColor(.gray)

                    // Achievement count
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption2)
                        Text("\(entry.achievementCount)")
                            .font(.caption)
                    }
                    .foregroundColor(.yellow)
                }
            }

            Spacer()

            // Score
            scoreView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: entry.isCurrentPlayer ? 3 : 1)
        )
        .shadow(
            color: entry.isCurrentPlayer ? Color.blue.opacity(0.3) : Color.clear,
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏆 RANK VIEW                                                     │
    // └─────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private var rankView: some View {
        if let medal = entry.medalEmoji {
            // Top 3 - show medal
            VStack(spacing: 2) {
                Text(medal)
                    .font(.title)

                Text("#\(entry.rank)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 50)
        } else {
            // Regular rank number
            Text("#\(entry.rank)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(entry.isCurrentPlayer ? .blue : .gray)
                .frame(width: 50)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 SCORE VIEW                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    private var scoreView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(entry.formattedScore(for: category))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(category.unit.isEmpty ? "" : category.unit)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 COMPUTED PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    private var backgroundColor: Color {
        if entry.isCurrentPlayer {
            return Color.blue.opacity(0.15)
        } else if entry.isTopThree {
            return Color.yellow.opacity(0.08)
        } else {
            return Color(white: 0.12)
        }
    }

    private var borderColor: Color {
        if entry.isCurrentPlayer {
            return .blue
        } else if entry.rank == 1 {
            return .yellow
        } else if entry.rank == 2 {
            return .gray
        } else if entry.rank == 3 {
            return .orange
        } else {
            return Color(white: 0.2)
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 12) {
            // First place
            LeaderboardEntryView(
                entry: LeaderboardEntry(
                    id: "1",
                    rank: 1,
                    playerID: "player1",
                    playerName: "CardMaster99",
                    playerLevel: 87,
                    playerRank: "Legend",
                    score: 50000,
                    achievementCount: 42,
                    iconEmoji: "👑",
                    timestamp: Date(),
                    isCurrentPlayer: false
                ),
                category: .totalXP
            )

            // Current player
            LeaderboardEntryView(
                entry: LeaderboardEntry(
                    id: "2",
                    rank: 42,
                    playerID: "current",
                    playerName: "You",
                    playerLevel: 35,
                    playerRank: "Expert",
                    score: 15000,
                    achievementCount: 28,
                    iconEmoji: "🎴",
                    timestamp: Date(),
                    isCurrentPlayer: true
                ),
                category: .totalXP
            )

            // Regular entry
            LeaderboardEntryView(
                entry: LeaderboardEntry(
                    id: "3",
                    rank: 156,
                    playerID: "player3",
                    playerName: "LuckyPlayer",
                    playerLevel: 22,
                    playerRank: "Intermediate",
                    score: 8500,
                    achievementCount: 15,
                    iconEmoji: "🍀",
                    timestamp: Date(),
                    isCurrentPlayer: false
                ),
                category: .totalXP
            )
        }
        .padding()
    }
}
