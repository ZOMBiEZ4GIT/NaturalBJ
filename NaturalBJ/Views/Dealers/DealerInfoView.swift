//
//  DealerInfoView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 3: Dealer Personalities & Rule Variations
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ ℹ️ DEALER INFO VIEW                                                        ║
// ║                                                                            ║
// ║ Purpose: Shows detailed information about a dealer                        ║
// ║ Business Context: Helps players understand rule differences               ║
// ║                                                                            ║
// ║ Displays:                                                                  ║
// ║ • Dealer avatar and name                                                  ║
// ║ • Full personality description                                            ║
// ║ • Complete rules list                                                      ║
// ║ • House edge explanation                                                   ║
// ║ • "Select This Dealer" button                                             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct DealerInfoView: View {
    let dealer: Dealer
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: dealer.avatarName)
                            .font(.system(size: 80))
                            .foregroundColor(dealer.themeColor)

                        Text(dealer.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(dealer.tagline)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()

                    // Personality
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Personality", systemImage: "person.fill")
                            .font(.headline)
                            .foregroundColor(dealer.themeColor)

                        Text(dealer.personality)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // House Edge
                    VStack(alignment: .leading, spacing: 8) {
                        Label("House Edge", systemImage: "chart.bar.fill")
                            .font(.headline)
                            .foregroundColor(dealer.themeColor)

                        Text(dealer.houseEdgeString)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(houseEdgeColor)

                        Text(houseEdgeExplanation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // Rules
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Rules", systemImage: "list.bullet")
                            .font(.headline)
                            .foregroundColor(dealer.themeColor)

                        ForEach(dealer.rulesSummary, id: \.self) { rule in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(dealer.themeColor)
                                    .font(.caption)

                                Text(rule)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Special Features
                    if dealer.name == "Lucky" {
                        specialFeaturesView(
                            title: "Lucky's Special Features",
                            features: [
                                "🍀 Free Doubles: Double down without additional cost",
                                "🍀 Free Splits: Split pairs without additional cost",
                                "🍀 Single Deck: Better odds for card counting"
                            ]
                        )
                    } else if dealer.name == "Shark" {
                        specialFeaturesView(
                            title: "Shark's High Stakes",
                            features: [
                                "🦈 5x Minimum Bet: High roller territory",
                                "🦈 6:5 Blackjack: Lower payout on blackjack",
                                "🦈 8 Decks: Harder to count cards"
                            ]
                        )
                    } else if dealer.name == "Zen" {
                        specialFeaturesView(
                            title: "Zen's Teaching Features",
                            features: [
                                "🧘 Early Surrender: Rare and valuable option",
                                "🧘 Strategy Hints: Coming in Phase 8",
                                "🧘 Probability Display: Coming in Phase 8"
                            ]
                        )
                    } else if dealer.name == "Maverick" {
                        specialFeaturesView(
                            title: "Maverick's Chaos",
                            features: [
                                "🎲 Random Rules: Changes each shoe",
                                "🎲 Always Fair: House edge 0.4% - 0.8%",
                                "🎲 Mystery Bonuses: Coming in Phase 6"
                            ]
                        )
                    }

                    // Select Button
                    Button {
                        viewModel.switchDealer(to: dealer)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Select \(dealer.name)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(dealer.themeColor)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 SPECIAL FEATURES VIEW                                             │
    // └─────────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private func specialFeaturesView(title: String, features: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "star.fill")
                .font(.headline)
                .foregroundColor(dealer.themeColor)

            ForEach(features, id: \.self) { feature in
                Text(feature)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 HOUSE EDGE COLOR AND EXPLANATION                                  │
    // └─────────────────────────────────────────────────────────────────────┘

    private var houseEdgeColor: Color {
        let edge = dealer.houseEdge
        if edge < 0 {
            return .green
        } else if edge < 0.6 {
            return .yellow
        } else if edge < 1.0 {
            return .orange
        } else {
            return .red
        }
    }

    private var houseEdgeExplanation: String {
        let edge = dealer.houseEdge
        if edge < 0 {
            return "Player advantage! The odds are in your favour with \(dealer.name)."
        } else if edge < 0.6 {
            return "Very player-friendly. One of the best odds you'll find."
        } else if edge < 1.0 {
            return "Fair and balanced. Standard casino odds."
        } else {
            return "House has significant advantage. High stakes, high risk!"
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎨 PREVIEW                                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview {
    DealerInfoView(dealer: .lucky(), viewModel: GameViewModel())
}
