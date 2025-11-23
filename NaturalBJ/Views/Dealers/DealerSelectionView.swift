//
//  DealerSelectionView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 3: Dealer Personalities & Rule Variations
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👥 DEALER SELECTION VIEW                                                   ║
// ║                                                                            ║
// ║ Purpose: Displays all 6 dealers for selection                             ║
// ║ Business Context: This is how players choose their experience. Instead of ║
// ║                   navigating complex settings, they pick a personality!   ║
// ║                                                                            ║
// ║ Layout: Grid of 6 dealer cards with:                                      ║
// ║ • Dealer avatar (SF Symbol)                                               ║
// ║ • Dealer name                                                             ║
// ║ • Tagline                                                                  ║
// ║ • House edge indicator                                                     ║
// ║ • Tap to see details or select                                            ║
// ║                                                                            ║
// ║ Used By: • Game flow (initial dealer selection)                           ║
// ║          • Settings/Options (mid-session dealer switch)                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct DealerSelectionView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedDealerForInfo: Dealer?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Choose Your Dealer")
                            .font(.largeTitle)
                            .fontWeight(.bold)

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
                                isSelected: viewModel.currentDealer.name == dealer.name
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
                    Text("Current: \(viewModel.currentDealer.name)")
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
                }
            }
            .sheet(item: $selectedDealerForInfo) { dealer in
                DealerInfoView(dealer: dealer, viewModel: viewModel)
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 SELECT DEALER                                                     │
    // │                                                                      │
    // │ Business Logic: Switch to new dealer, confirm if mid-game           │
    // └─────────────────────────────────────────────────────────────────────┘

    private func selectDealer(_ dealer: Dealer) {
        if viewModel.gameState != .betting {
            // Mid-game switch - show confirmation
            // For now, just switch immediately
            viewModel.switchDealer(to: dealer)
        } else {
            viewModel.switchDealer(to: dealer)
        }

        // Close the selection view
        dismiss()
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Show dealer selection:                                                     ║
// ║   .sheet(isPresented: $showingDealerSelection) {                           ║
// ║       DealerSelectionView(viewModel: gameViewModel)                        ║
// ║   }                                                                         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
