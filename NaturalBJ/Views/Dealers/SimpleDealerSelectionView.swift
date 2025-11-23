//
//  SimpleDealerSelectionView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Lightweight Dealer Selection (Settings Integration)
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👥 SIMPLE DEALER SELECTION VIEW                                           ║
// ║                                                                            ║
// ║ Purpose: Lightweight dealer selection for Settings integration            ║
// ║ Business Context: Allows dealer switching without GameViewModel dependency║
// ║                   Used from SettingsView and onboarding flows             ║
// ║                                                                            ║
// ║ Difference from DealerSelectionView: No GameViewModel required            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct SimpleDealerSelectionView: View {

    let currentDealer: Dealer
    let onDealerSelected: (Dealer) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var selectedDealerForInfo: Dealer? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Choose Your Dealer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Each dealer has unique rules and personality")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Dealer Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Dealer.allDealers) { dealer in
                            DealerCardView(
                                dealer: dealer,
                                isSelected: currentDealer.name == dealer.name
                            )
                            .onTapGesture {
                                selectDealer(dealer)
                            }
                            .onLongPressGesture {
                                selectedDealerForInfo = dealer
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Current dealer indicator
                    Text("Current: \(currentDealer.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.info)
                }
            }
            .sheet(item: $selectedDealerForInfo) { dealer in
                SimpleDealerInfoView(dealer: dealer)
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 SELECT DEALER                                                     │
    // └─────────────────────────────────────────────────────────────────────┘

    private func selectDealer(_ dealer: Dealer) {
        onDealerSelected(dealer)
        AudioManager.shared.playSoundEffect(.dealerSwitch)
        HapticManager.shared.impact(.medium)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📄 SIMPLE DEALER INFO VIEW                                                 ║
// ║                                                                            ║
// ║ Standalone dealer info without GameViewModel dependency                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct SimpleDealerInfoView: View {

    let dealer: Dealer
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Dealer header with avatar
                    VStack(spacing: 12) {
                        DealerAvatarView(dealer: dealer, size: .large)

                        Text(dealer.tagline)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Rules summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Rules")
                            .font(.headline)
                            .foregroundColor(.white)

                        ruleRow(icon: "suit.spade.fill", title: "Decks", value: "\(dealer.rules.numberOfDecks)")
                        ruleRow(icon: "hand.raised.fill", title: "Dealer", value: dealer.rules.dealerHitsSoft17 ? "Hits Soft 17" : "Stands Soft 17")
                        ruleRow(icon: "arrow.up.arrow.down", title: "Double Down", value: dealer.rules.canDoubleOnAnyTwoCards ? "Any Two Cards" : "9, 10, 11 Only")
                        ruleRow(icon: "arrow.triangle.2.circlepath", title: "Split", value: dealer.rules.canDoubleAfterSplit ? "Double After Split OK" : "No Double After Split")
                        ruleRow(icon: "flag.fill", title: "Surrender", value: dealer.rules.surrenderAllowed ? "Allowed" : "Not Allowed")
                        ruleRow(icon: "dollarsign.circle.fill", title: "Blackjack Pays", value: dealer.rules.blackjackPayout == 1.5 ? "3:2" : "6:5")
                        ruleRow(icon: "percent", title: "House Edge", value: "~\(String(format: "%.2f", dealer.rules.estimatedHouseEdge))%")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(dealer.accentColor.opacity(0.1))
                    )
                    .padding(.horizontal)

                    // Special features (if any)
                    if !dealer.specialFeatures.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Special Features")
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(dealer.specialFeatures, id: \.self) { feature in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(dealer.accentColor)

                                    Text(feature)
                                        .font(.subheadline)
                                        .foregroundColor(.mediumGrey)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.darkGrey.opacity(0.3))
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
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

    private func ruleRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(dealer.accentColor)
                .frame(width: 30)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundColor(.mediumGrey)
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🔧 DEALER EXTENSION - Special Features                                    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Dealer {
    var specialFeatures: [String] {
        var features: [String] = []

        if rules.isFreeDouble {
            features.append("Free doubles - no extra bet required")
        }
        if rules.isFreeSplit {
            features.append("Free splits - no extra bet required")
        }
        if name == "Zen" {
            features.append("Basic strategy hints always enabled")
            features.append("Hand probability calculations available")
        }
        if name == "Blitz" {
            features.append("5-second decision timer")
            features.append("Speed multiplier bonuses")
        }
        if name == "Maverick" {
            features.append("Rules randomise each shoe")
            features.append("Mystery bonus rounds")
        }

        return features
    }
}
