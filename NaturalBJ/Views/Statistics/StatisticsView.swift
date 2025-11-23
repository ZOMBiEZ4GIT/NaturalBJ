//
//  StatisticsView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 STATISTICS VIEW                                                         ║
// ║                                                                            ║
// ║ Purpose: Main statistics screen showing comprehensive player performance  ║
// ║ Business Context: This is the player's dashboard - showing everything     ║
// ║                   they need to track their blackjack journey              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab picker
                Picker("View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("History").tag(1)
                    Text("Dealers").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                TabView(selection: $selectedTab) {
                    overviewTab.tag(0)
                    historyTab.tag(1)
                    dealersTab.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.refreshStats() }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        Button(role: .destructive, action: { viewModel.clearHistory() }) {
                            Label("Clear History", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    // Overview Tab
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Stats Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("📊 Overall Statistics")
                        .font(.headline)

                    HStack(spacing: 20) {
                        StatCard(icon: "🎴", value: "\(viewModel.overallStats.totalHands)", label: "Total Hands")
                        StatCard(icon: "📈", value: viewModel.overallStats.formattedWinRate, label: "Win Rate")
                        StatCard(icon: "💰", value: viewModel.overallStats.formattedTotalProfit, label: "Net Profit")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Performance Rating
                if viewModel.overallPerformanceRating > 0 {
                    Text("\(viewModel.starRating) \(viewModel.performanceTrend)")
                        .font(.title3)
                }
            }
            .padding()
        }
    }

    // History Tab
    private var historyTab: some View {
        List(viewModel.sessions) { session in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(session.dealerIcon) \(session.dealerName)")
                        .font(.headline)
                    Spacer()
                    Text(session.shortDateDisplay)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text(session.summaryLine)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // Dealers Tab
    private var dealersTab: some View {
        List(viewModel.dealersByWinRate) { dealer in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(dealer.displayName)
                        .font(.headline)
                    Spacer()
                    Text(dealer.formattedWinRate)
                        .font(.title3)
                        .bold()
                }

                Text(dealer.summaryLine)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if dealer.performanceRating > 0 {
                    Text(dealer.starRating)
                        .font(.caption)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    StatisticsView()
}
