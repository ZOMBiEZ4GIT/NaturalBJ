//
//  StatisticsViewModel.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 STATISTICS VIEW MODEL                                                   ║
// ║                                                                            ║
// ║ Purpose: Provides statistics data to UI views in a SwiftUI-friendly format║
// ║ Business Context: This ViewModel acts as an intermediary between          ║
// ║                   StatisticsManager (business logic) and SwiftUI views    ║
// ║                   (presentation). It formats data, handles sorting, and   ║
// ║                   provides computed properties for easy UI binding.       ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Expose StatisticsManager data as @Published properties                  ║
// ║ • Provide sorting and filtering for session history                       ║
// ║ • Calculate dealer comparisons                                            ║
// ║ • Format data for charts and visualisations                               ║
// ║ • Handle user actions (clear history, export data)                        ║
// ║                                                                            ║
// ║ Used By: StatisticsView, SessionHistoryView, DealerComparisonView         ║
// ║ Uses: StatisticsManager (data source)                                     ║
// ║                                                                            ║
// ║ Related Spec: See "Statistics & Session History" (lines 178-215)          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 STATISTICS VIEW MODEL CLASS                                             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class StatisticsViewModel: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                               │
    // │                                                                  │
    // │ These properties trigger UI updates when changed                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Overall statistics (automatically updates)
    @Published var overallStats: OverallStats

    /// All sessions (automatically updates)
    @Published var sessions: [Session]

    /// Dealer statistics for all dealers
    @Published var dealerStats: [DealerStats]

    /// Selected session for detail view (nil = none selected)
    @Published var selectedSession: Session?

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    /// Reference to statistics manager
    private var statsManager = StatisticsManager.shared

    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    /// List of known dealers (name, icon)
    private let knownDealers: [(name: String, icon: String)] = [
        ("Ruby", "♦️"),
        ("Lucky", "🍀"),
        ("Shark", "🦈"),
        ("Zen", "🧘"),
        ("Blitz", "⚡"),
        ("Maverick", "🎲"),
        ("Classic", "🎰") // Default dealer
    ]

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // │                                                                  │
    // │ Sets up initial state and subscribes to StatisticsManager       │
    // └─────────────────────────────────────────────────────────────────┘

    init() {
        // Initialize with current stats
        self.overallStats = statsManager.getOverallStats()
        self.sessions = statsManager.getAllSessions()
        self.dealerStats = statsManager.getAllDealerStats(dealers: knownDealers)

        // Subscribe to StatisticsManager changes
        setupSubscriptions()

        print("📊 StatisticsViewModel initialized")
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔔 SETUP SUBSCRIPTIONS                                           │
    // │                                                                  │
    // │ Listen for changes in StatisticsManager and update UI           │
    // └─────────────────────────────────────────────────────────────────┘

    private func setupSubscriptions() {
        // Update when current session changes
        statsManager.$currentSession
            .sink { [weak self] _ in
                self?.refreshStats()
            }
            .store(in: &cancellables)

        // Update when session history changes
        statsManager.$sessionHistory
            .sink { [weak self] _ in
                self?.refreshStats()
            }
            .store(in: &cancellables)
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔄 DATA REFRESH                                                    ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Refresh all statistics from StatisticsManager
    func refreshStats() {
        overallStats = statsManager.getOverallStats()
        sessions = statsManager.getAllSessions()
        dealerStats = statsManager.getAllDealerStats(dealers: knownDealers)
        print("📊 Statistics refreshed")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 COMPUTED PROPERTIES FOR UI                                      ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 CURRENT SESSION STATS                                         │
    // └─────────────────────────────────────────────────────────────────┘

    /// Current active session (if any)
    var currentSession: Session? {
        return statsManager.currentSession
    }

    /// Is there an active session?
    var hasActiveSession: Bool {
        return statsManager.hasActiveSession
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏆 BEST/WORST STATISTICS                                         │
    // └─────────────────────────────────────────────────────────────────┘

    /// Best session (highest profit)
    var bestSession: Session? {
        return sessions.max { $0.netProfit < $1.netProfit }
    }

    /// Worst session (biggest loss)
    var worstSession: Session? {
        return sessions.min { $0.netProfit < $1.netProfit }
    }

    /// Best dealer by win rate
    var bestDealer: DealerStats? {
        return dealerStats
            .filter { $0.totalHands > 0 }
            .max { $0.winRate < $1.winRate }
    }

    /// Worst dealer by win rate
    var worstDealer: DealerStats? {
        return dealerStats
            .filter { $0.totalHands > 0 }
            .min { $0.winRate < $1.winRate }
    }

    /// Most played dealer
    var favouriteDealer: DealerStats? {
        return dealerStats.max { $0.totalHands < $1.totalHands }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 SESSION FILTERING & SORTING                                   │
    // └─────────────────────────────────────────────────────────────────┘

    /// Get sessions for specific dealer
    func sessions(forDealer dealerName: String) -> [Session] {
        return sessions.filter { $0.dealerName == dealerName }
    }

    /// Get sessions sorted by profit (highest first)
    var sessionsByProfit: [Session] {
        return sessions.sorted { $0.netProfit > $1.netProfit }
    }

    /// Get sessions sorted by win rate (highest first)
    var sessionsByWinRate: [Session] {
        return sessions.sorted { $0.winRate > $1.winRate }
    }

    /// Get sessions sorted by duration (longest first)
    var sessionsByDuration: [Session] {
        return sessions.sorted { $0.duration > $1.duration }
    }

    /// Get recent sessions (last N sessions)
    func recentSessions(limit: Int = 10) -> [Session] {
        return Array(sessions.prefix(limit))
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 DEALER COMPARISON                                             │
    // └─────────────────────────────────────────────────────────────────┘

    /// Get dealers sorted by win rate (best first)
    var dealersByWinRate: [DealerStats] {
        return dealerStats
            .filter { $0.totalHands > 0 }
            .sorted { $0.winRate > $1.winRate }
    }

    /// Get dealers sorted by profit (most profitable first)
    var dealersByProfit: [DealerStats] {
        return dealerStats
            .filter { $0.totalHands > 0 }
            .sorted { $0.totalProfit > $1.totalProfit }
    }

    /// Get dealers sorted by play time (most played first)
    var dealersByPlayTime: [DealerStats] {
        return dealerStats
            .filter { $0.totalHands > 0 }
            .sorted { $0.totalHands > $1.totalHands }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 CHART DATA                                                    │
    // │                                                                  │
    // │ Provides data formatted for charts and visualisations           │
    // └─────────────────────────────────────────────────────────────────┘

    /// Win rate over time (for line chart)
    /// Returns array of (session number, win rate %)
    var winRateOverTime: [(sessionNumber: Int, winRate: Double)] {
        let sortedByDate = sessions.sorted { $0.startTime < $1.startTime }
        return sortedByDate.enumerated().map { (index, session) in
            (sessionNumber: index + 1, winRate: session.winRatePercentage)
        }
    }

    /// Profit over time (for line chart)
    /// Returns array of (session number, cumulative profit)
    var profitOverTime: [(sessionNumber: Int, cumulativeProfit: Double)] {
        let sortedByDate = sessions.sorted { $0.startTime < $1.startTime }
        var cumulative: Double = 0
        return sortedByDate.enumerated().map { (index, session) in
            cumulative += session.netProfit
            return (sessionNumber: index + 1, cumulativeProfit: cumulative)
        }
    }

    /// Dealer comparison chart data
    /// Returns array of (dealer name, win rate %)
    var dealerWinRateComparison: [(dealer: String, winRate: Double)] {
        return dealerStats
            .filter { $0.totalHands > 0 }
            .sorted { $0.winRate > $1.winRate }
            .map { (dealer: "\($0.dealerIcon) \($0.dealerName)", winRate: $0.winRatePercentage) }
    }

    /// Dealer profit comparison chart data
    /// Returns array of (dealer name, total profit)
    var dealerProfitComparison: [(dealer: String, profit: Double)] {
        return dealerStats
            .filter { $0.totalHands > 0 }
            .sorted { $0.totalProfit > $1.totalProfit }
            .map { (dealer: "\($0.dealerIcon) \($0.dealerName)", profit: $0.totalProfit) }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🛠️ USER ACTIONS                                                    ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🗑️ CLEAR HISTORY                                                 │
    // │                                                                  │
    // │ Business Logic: Delete all session history                      │
    // │ Called by: Settings view "Clear History" button                 │
    // └─────────────────────────────────────────────────────────────────┘

    func clearHistory() {
        statsManager.clearHistory()
        refreshStats()
        print("🗑️ History cleared")
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📤 EXPORT STATISTICS                                             │
    // │                                                                  │
    // │ Business Logic: Export all sessions as JSON string              │
    // │ Called by: Statistics view "Export" button                      │
    // │                                                                  │
    // │ Returns: JSON string for sharing/backup, or nil if failed       │
    // └─────────────────────────────────────────────────────────────────┘

    func exportStatistics() -> String? {
        return statsManager.exportSessions()
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📥 IMPORT STATISTICS                                             │
    // │                                                                  │
    // │ Business Logic: Import sessions from JSON string                │
    // │ Called by: Statistics view "Import" button                      │
    // │                                                                  │
    // │ Parameters:                                                      │
    // │ • jsonString: JSON data to import                               │
    // │                                                                  │
    // │ Returns: true if successful, false otherwise                    │
    // └─────────────────────────────────────────────────────────────────┘

    func importStatistics(from jsonString: String) -> Bool {
        let success = statsManager.importSessions(from: jsonString)
        if success {
            refreshStats()
            print("📥 Statistics imported successfully")
        }
        return success
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔍 SELECT SESSION                                                │
    // │                                                                  │
    // │ Business Logic: Select a session for detail view                │
    // │ Called by: SessionHistoryView when tapping a session            │
    // └─────────────────────────────────────────────────────────────────┘

    func selectSession(_ session: Session) {
        selectedSession = session
    }

    func deselectSession() {
        selectedSession = nil
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 DISPLAY HELPERS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Get summary string for current session
    var currentSessionSummary: String {
        guard let session = currentSession else {
            return "No active session"
        }
        return "\(session.handsPlayed) hands • \(session.formattedWinRate) • \(session.formattedNetProfit)"
    }

    /// Get overall performance rating (0-5 stars)
    var overallPerformanceRating: Int {
        let winRate = overallStats.overallWinRatePercentage
        if winRate >= 55 { return 5 }
        else if winRate >= 52 { return 4 }
        else if winRate >= 48 { return 3 }
        else if winRate >= 45 { return 2 }
        else if winRate >= 40 { return 1 }
        else { return 0 }
    }

    /// Star rating as string
    var starRating: String {
        return String(repeating: "⭐", count: overallPerformanceRating)
    }

    /// Is the player profitable overall?
    var isProfitable: Bool {
        return overallStats.totalProfit > 0
    }

    /// Performance trend (positive/negative/neutral)
    var performanceTrend: String {
        // Compare last 5 sessions to previous 5 sessions
        let recent = Array(sessions.prefix(5))
        let previous = Array(sessions.dropFirst(5).prefix(5))

        guard !recent.isEmpty && !previous.isEmpty else { return "➖" }

        let recentWinRate = recent.reduce(0.0) { $0 + $1.winRate } / Double(recent.count)
        let previousWinRate = previous.reduce(0.0) { $0 + $1.winRate } / Double(previous.count)

        if recentWinRate > previousWinRate + 0.02 { return "📈 Improving" }
        else if recentWinRate < previousWinRate - 0.02 { return "📉 Declining" }
        else { return "➖ Stable" }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ In SwiftUI View:                                                           ║
// ║   @StateObject private var viewModel = StatisticsViewModel()              ║
// ║                                                                            ║
// ║   var body: some View {                                                    ║
// ║       VStack {                                                             ║
// ║           Text("Total hands: \(viewModel.overallStats.totalHands)")       ║
// ║           Text("Win rate: \(viewModel.overallStats.formattedWinRate)")    ║
// ║           Text("Total profit: \(viewModel.overallStats.formattedTotalProfit)") ║
// ║                                                                            ║
// ║           if let best = viewModel.bestSession {                           ║
// ║               Text("Best session: \(best.formattedNetProfit)")            ║
// ║           }                                                                ║
// ║                                                                            ║
// ║           List(viewModel.sessions) { session in                           ║
// ║               SessionRow(session: session)                                ║
// ║                   .onTapGesture {                                          ║
// ║                       viewModel.selectSession(session)                    ║
// ║                   }                                                        ║
// ║           }                                                                ║
// ║                                                                            ║
// ║           Button("Clear History") {                                        ║
// ║               viewModel.clearHistory()                                    ║
// ║           }                                                                ║
// ║       }                                                                    ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
