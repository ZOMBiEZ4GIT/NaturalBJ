//
//  DealerStats.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎰 DEALER STATISTICS MODEL                                                 ║
// ║                                                                            ║
// ║ Purpose: Aggregates performance statistics for a specific dealer          ║
// ║ Business Context: Players want to know which dealers they perform best    ║
// ║                   against. Some dealers have friendlier rules (Lucky),    ║
// ║                   while others are tougher (Shark). Tracking per-dealer   ║
// ║                   stats helps players choose their favourite dealer.      ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Aggregate all sessions/hands played against this dealer                 ║
// ║ • Calculate overall win rate vs this dealer                               ║
// ║ • Track total profit/loss against this dealer                             ║
// ║ • Identify best/worst sessions with this dealer                           ║
// ║ • Compare performance across different dealers                            ║
// ║                                                                            ║
// ║ Used By: StatisticsManager (calculates from session history)              ║
// ║          DealerComparisonView (displays comparative stats)                ║
// ║          StatisticsViewModel (finds best/worst dealers)                   ║
// ║                                                                            ║
// ║ Related Spec: See "Statistics & Session History" (lines 178-215)          ║
// ║               See "Dealer Personalities" section for dealer details       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎰 DEALER STATS STRUCTURE                                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct DealerStats: Codable, Identifiable {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 IDENTIFICATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Dealer name (e.g., "Ruby", "Lucky", "Shark", "Zen", "Blitz", "Maverick")
    let dealerName: String

    /// Dealer icon/emoji
    let dealerIcon: String

    /// Computed ID for Identifiable conformance
    var id: String { dealerName }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 SESSION TRACKING                                              │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total number of sessions played with this dealer
    var sessionsPlayed: Int

    /// Total time played with this dealer (in seconds)
    var totalTimePlayed: TimeInterval

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎴 HAND STATISTICS                                               │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total hands played against this dealer
    var totalHands: Int

    /// Total hands won
    var handsWon: Int

    /// Total hands lost
    var handsLost: Int

    /// Total pushes
    var handsPushed: Int

    /// Total blackjacks hit against this dealer
    var blackjacksCount: Int

    /// Total busts against this dealer
    var bustsCount: Int

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💰 FINANCIAL STATISTICS                                          │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total profit/loss against this dealer
    var totalProfit: Double

    /// Total amount wagered against this dealer
    var totalWagered: Double

    /// Biggest single win against this dealer
    var biggestWin: Double

    /// Biggest single loss against this dealer
    var biggestLoss: Double

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    init(
        dealerName: String,
        dealerIcon: String,
        sessionsPlayed: Int = 0,
        totalTimePlayed: TimeInterval = 0,
        totalHands: Int = 0,
        handsWon: Int = 0,
        handsLost: Int = 0,
        handsPushed: Int = 0,
        blackjacksCount: Int = 0,
        bustsCount: Int = 0,
        totalProfit: Double = 0,
        totalWagered: Double = 0,
        biggestWin: Double = 0,
        biggestLoss: Double = 0
    ) {
        self.dealerName = dealerName
        self.dealerIcon = dealerIcon
        self.sessionsPlayed = sessionsPlayed
        self.totalTimePlayed = totalTimePlayed
        self.totalHands = totalHands
        self.handsWon = handsWon
        self.handsLost = handsLost
        self.handsPushed = handsPushed
        self.blackjacksCount = blackjacksCount
        self.bustsCount = bustsCount
        self.totalProfit = totalProfit
        self.totalWagered = totalWagered
        self.biggestWin = biggestWin
        self.biggestLoss = biggestLoss
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 COMPUTED STATISTICS                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension DealerStats {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 WIN RATE CALCULATION                                          │
    // │                                                                  │
    // │ Business Logic: Win rate counts pushes as half wins             │
    // │ Same formula as Session win rate for consistency                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Win rate as decimal (0.0 to 1.0)
    var winRate: Double {
        guard totalHands > 0 else { return 0 }
        let effectiveWins = Double(handsWon) + (Double(handsPushed) * 0.5)
        return effectiveWins / Double(totalHands)
    }

    /// Win rate as percentage (0 to 100)
    var winRatePercentage: Double {
        return winRate * 100
    }

    /// Formatted win rate for display
    var formattedWinRate: String {
        return String(format: "%.1f%%", winRatePercentage)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💰 FINANCIAL CALCULATIONS                                        │
    // └─────────────────────────────────────────────────────────────────┘

    /// Average profit per session
    var averageProfitPerSession: Double {
        guard sessionsPlayed > 0 else { return 0 }
        return totalProfit / Double(sessionsPlayed)
    }

    /// Average profit per hand
    var averageProfitPerHand: Double {
        guard totalHands > 0 else { return 0 }
        return totalProfit / Double(totalHands)
    }

    /// Average bet size
    var averageBet: Double {
        guard totalHands > 0 else { return 0 }
        return totalWagered / Double(totalHands)
    }

    /// Return on investment as percentage
    var roi: Double {
        guard totalWagered > 0 else { return 0 }
        return (totalProfit / totalWagered) * 100
    }

    /// Formatted ROI
    var formattedROI: String {
        let prefix = roi >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", roi))%"
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⏱️ TIME STATISTICS                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Average session duration in seconds
    var averageSessionDuration: TimeInterval {
        guard sessionsPlayed > 0 else { return 0 }
        return totalTimePlayed / Double(sessionsPlayed)
    }

    /// Formatted total time played
    var formattedTotalTime: String {
        let totalMinutes = Int(totalTimePlayed / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Formatted average session duration
    var formattedAverageSessionDuration: String {
        let totalMinutes = Int(averageSessionDuration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PERFORMANCE METRICS                                           │
    // └─────────────────────────────────────────────────────────────────┘

    /// Hands per session average
    var handsPerSession: Double {
        guard sessionsPlayed > 0 else { return 0 }
        return Double(totalHands) / Double(sessionsPlayed)
    }

    /// Bust rate as percentage
    var bustRate: Double {
        guard totalHands > 0 else { return 0 }
        return (Double(bustsCount) / Double(totalHands)) * 100
    }

    /// Blackjack rate as percentage
    var blackjackRate: Double {
        guard totalHands > 0 else { return 0 }
        return (Double(blackjacksCount) / Double(totalHands)) * 100
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 DISPLAY HELPERS                                               │
    // └─────────────────────────────────────────────────────────────────┘

    /// Formatted total profit
    var formattedTotalProfit: String {
        let prefix = totalProfit >= 0 ? "+" : ""
        return "\(prefix)$\(String(format: "%.2f", totalProfit))"
    }

    /// Formatted biggest win
    var formattedBiggestWin: String {
        return "$\(String(format: "%.2f", biggestWin))"
    }

    /// Formatted biggest loss
    var formattedBiggestLoss: String {
        return "$\(String(format: "%.2f", abs(biggestLoss)))"
    }

    /// Summary line for comparison view
    var summaryLine: String {
        return "\(formattedWinRate) win rate, \(formattedTotalProfit) (\(totalHands) hands)"
    }

    /// Display name with icon
    var displayName: String {
        return "\(dealerIcon) \(dealerName)"
    }

    /// Performance rating (0-5 stars based on win rate and profit)
    var performanceRating: Int {
        // Rating based on win rate primarily, with profit as tiebreaker
        let winRateScore = winRatePercentage
        let profitScore = totalProfit > 0 ? 1.0 : (totalProfit == 0 ? 0.5 : 0.0)

        // 5 stars: >55% win rate
        // 4 stars: >52% win rate
        // 3 stars: >48% win rate
        // 2 stars: >45% win rate
        // 1 star: >40% win rate
        // 0 stars: ≤40% win rate

        if winRateScore >= 55 { return 5 }
        else if winRateScore >= 52 { return 4 }
        else if winRateScore >= 48 { return 3 }
        else if winRateScore >= 45 { return 2 }
        else if winRateScore >= 40 { return 1 }
        else { return 0 }
    }

    /// Star rating as string
    var starRating: String {
        return String(repeating: "⭐", count: performanceRating)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🛠️ STATS MANAGEMENT EXTENSIONS                                            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension DealerStats {

    /// Create dealer stats from a collection of sessions
    static func from(sessions: [Session], dealerName: String, dealerIcon: String) -> DealerStats {
        // Filter sessions for this dealer
        let dealerSessions = sessions.filter { $0.dealerName == dealerName }

        guard !dealerSessions.isEmpty else {
            return DealerStats(dealerName: dealerName, dealerIcon: dealerIcon)
        }

        // Aggregate all hands from all sessions
        let allHands = dealerSessions.flatMap { $0.hands }

        // Calculate aggregates
        let sessionsCount = dealerSessions.count
        let totalTime = dealerSessions.reduce(0.0) { $0 + $1.duration }
        let totalHandsCount = allHands.count
        let wins = allHands.filter { $0.outcome.isWin }.count
        let losses = allHands.filter { $0.outcome.isLoss }.count
        let pushes = allHands.filter { $0.outcome.isPush }.count
        let blackjacks = allHands.filter { $0.outcome == .blackjack }.count
        let busts = allHands.filter { $0.outcome == .bust }.count
        let profit = dealerSessions.reduce(0.0) { $0 + $1.netProfit }
        let wagered = allHands.reduce(0.0) { $0 + $1.betAmount }
        let maxWin = allHands.map { $0.netResult }.max() ?? 0
        let minLoss = allHands.map { $0.netResult }.min() ?? 0

        return DealerStats(
            dealerName: dealerName,
            dealerIcon: dealerIcon,
            sessionsPlayed: sessionsCount,
            totalTimePlayed: totalTime,
            totalHands: totalHandsCount,
            handsWon: wins,
            handsLost: losses,
            handsPushed: pushes,
            blackjacksCount: blackjacks,
            bustsCount: busts,
            totalProfit: profit,
            totalWagered: wagered,
            biggestWin: maxWin,
            biggestLoss: minLoss
        )
    }

    /// Update stats with a new session
    mutating func addSession(_ session: Session) {
        guard session.dealerName == dealerName else { return }

        sessionsPlayed += 1
        totalTimePlayed += session.duration
        totalHands += session.handsPlayed
        handsWon += session.handsWon
        handsLost += session.handsLost
        handsPushed += session.handsPushed
        blackjacksCount += session.blackjacksCount
        bustsCount += session.bustsCount
        totalProfit += session.netProfit
        totalWagered += session.totalWagered
        biggestWin = max(biggestWin, session.biggestWin)
        biggestLoss = min(biggestLoss, session.biggestLoss)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create dealer stats from sessions:                                         ║
// ║   let rubyStat = DealerStats.from(                                         ║
// ║       sessions: allSessions,                                              ║
// ║       dealerName: "Ruby",                                                 ║
// ║       dealerIcon: "♦️"                                                     ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Compare dealers:                                                           ║
// ║   let dealers = ["Ruby", "Lucky", "Shark", "Zen"]                         ║
// ║   let stats = dealers.map { name in                                       ║
// ║       DealerStats.from(sessions: sessions, dealerName: name, ...)         ║
// ║   }                                                                        ║
// ║   let bestDealer = stats.max { $0.winRate < $1.winRate }                 ║
// ║                                                                            ║
// ║ Display stats:                                                             ║
// ║   print("\(rubyStats.displayName):")                                      ║
// ║   print("  Win rate: \(rubyStats.formattedWinRate)")                      ║
// ║   print("  Total profit: \(rubyStats.formattedTotalProfit)")              ║
// ║   print("  Rating: \(rubyStats.starRating)")                              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
