//
//  OverallStats.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 OVERALL STATISTICS MODEL                                                ║
// ║                                                                            ║
// ║ Purpose: Aggregates all-time player performance across all sessions       ║
// ║ Business Context: Players want to see their overall progress and          ║
// ║                   achievements across their entire blackjack journey.     ║
// ║                   This provides motivation and helps track improvement.   ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Aggregate statistics from all sessions ever played                      ║
// ║ • Track lifetime achievements (biggest win, best streak, etc.)            ║
// ║ • Calculate all-time win rate and profit/loss                             ║
// ║ • Identify favourite dealer and best session                              ║
// ║ • Track milestones (1000 hands, $10k profit, etc.)                        ║
// ║                                                                            ║
// ║ Used By: StatisticsViewModel (calculates from all sessions)               ║
// ║          StatisticsView (displays overall performance)                    ║
// ║                                                                            ║
// ║ Related Spec: See "Statistics & Session History" (lines 178-215)          ║
// ║               Specifically "All-Time Stats" (lines 188-193)               ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 OVERALL STATS STRUCTURE                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct OverallStats: Codable {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 SESSION TOTALS                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total number of sessions played all-time
    var totalSessions: Int

    /// Total time played across all sessions (in seconds)
    var totalTimePlayed: TimeInterval

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎴 HAND TOTALS                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total hands played all-time
    var totalHands: Int

    /// Total hands won
    var totalWins: Int

    /// Total hands lost
    var totalLosses: Int

    /// Total pushes
    var totalPushes: Int

    /// Total blackjacks hit
    var totalBlackjacks: Int

    /// Total busts
    var totalBusts: Int

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💰 FINANCIAL TOTALS                                              │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total profit/loss across all sessions
    var totalProfit: Double

    /// Total amount wagered across all hands
    var totalWagered: Double

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏆 ACHIEVEMENTS & RECORDS                                        │
    // └─────────────────────────────────────────────────────────────────┘

    /// Biggest single hand win ever
    var biggestHandWin: Double

    /// Biggest single hand loss ever
    var biggestHandLoss: Double

    /// Best session profit ever
    var bestSessionProfit: Double

    /// Best session ID (for navigation)
    var bestSessionId: UUID?

    /// Worst session loss ever
    var worstSessionLoss: Double

    /// Longest winning streak (number of consecutive wins)
    var longestWinStreak: Int

    /// Longest losing streak (number of consecutive losses)
    var longestLoseStreak: Int

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎰 DEALER PREFERENCES                                            │
    // └─────────────────────────────────────────────────────────────────┘

    /// Name of dealer played most often
    var favouriteDealer: String?

    /// Name of dealer with best win rate
    var mostSuccessfulDealer: String?

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    init(
        totalSessions: Int = 0,
        totalTimePlayed: TimeInterval = 0,
        totalHands: Int = 0,
        totalWins: Int = 0,
        totalLosses: Int = 0,
        totalPushes: Int = 0,
        totalBlackjacks: Int = 0,
        totalBusts: Int = 0,
        totalProfit: Double = 0,
        totalWagered: Double = 0,
        biggestHandWin: Double = 0,
        biggestHandLoss: Double = 0,
        bestSessionProfit: Double = 0,
        bestSessionId: UUID? = nil,
        worstSessionLoss: Double = 0,
        longestWinStreak: Int = 0,
        longestLoseStreak: Int = 0,
        favouriteDealer: String? = nil,
        mostSuccessfulDealer: String? = nil
    ) {
        self.totalSessions = totalSessions
        self.totalTimePlayed = totalTimePlayed
        self.totalHands = totalHands
        self.totalWins = totalWins
        self.totalLosses = totalLosses
        self.totalPushes = totalPushes
        self.totalBlackjacks = totalBlackjacks
        self.totalBusts = totalBusts
        self.totalProfit = totalProfit
        self.totalWagered = totalWagered
        self.biggestHandWin = biggestHandWin
        self.biggestHandLoss = biggestHandLoss
        self.bestSessionProfit = bestSessionProfit
        self.bestSessionId = bestSessionId
        self.worstSessionLoss = worstSessionLoss
        self.longestWinStreak = longestWinStreak
        self.longestLoseStreak = longestLoseStreak
        self.favouriteDealer = favouriteDealer
        self.mostSuccessfulDealer = mostSuccessfulDealer
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 COMPUTED STATISTICS                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension OverallStats {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 WIN RATE CALCULATION                                          │
    // └─────────────────────────────────────────────────────────────────┘

    /// Overall win rate as decimal (0.0 to 1.0)
    var overallWinRate: Double {
        guard totalHands > 0 else { return 0 }
        let effectiveWins = Double(totalWins) + (Double(totalPushes) * 0.5)
        return effectiveWins / Double(totalHands)
    }

    /// Overall win rate as percentage (0 to 100)
    var overallWinRatePercentage: Double {
        return overallWinRate * 100
    }

    /// Formatted overall win rate
    var formattedWinRate: String {
        return String(format: "%.1f%%", overallWinRatePercentage)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💰 FINANCIAL CALCULATIONS                                        │
    // └─────────────────────────────────────────────────────────────────┘

    /// Average profit per session
    var averageProfitPerSession: Double {
        guard totalSessions > 0 else { return 0 }
        return totalProfit / Double(totalSessions)
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

    /// Formatted total profit
    var formattedTotalProfit: String {
        let prefix = totalProfit >= 0 ? "+" : ""
        return "\(prefix)$\(String(format: "%.2f", totalProfit))"
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
        guard totalSessions > 0 else { return 0 }
        return totalTimePlayed / Double(totalSessions)
    }

    /// Formatted total time played (e.g., "24h 35m" or "3h 12m")
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
        guard totalSessions > 0 else { return 0 }
        return Double(totalHands) / Double(totalSessions)
    }

    /// Bust rate as percentage
    var bustRate: Double {
        guard totalHands > 0 else { return 0 }
        return (Double(totalBusts) / Double(totalHands)) * 100
    }

    /// Formatted bust rate
    var formattedBustRate: String {
        return String(format: "%.1f%%", bustRate)
    }

    /// Blackjack rate as percentage (how often player gets natural 21)
    var blackjackRate: Double {
        guard totalHands > 0 else { return 0 }
        return (Double(totalBlackjacks) / Double(totalHands)) * 100
    }

    /// Formatted blackjack rate
    var formattedBlackjackRate: String {
        return String(format: "%.1f%%", blackjackRate)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 ACHIEVEMENT FORMATTING                                        │
    // └─────────────────────────────────────────────────────────────────┘

    /// Formatted biggest hand win
    var formattedBiggestHandWin: String {
        return "$\(String(format: "%.2f", biggestHandWin))"
    }

    /// Formatted biggest hand loss
    var formattedBiggestHandLoss: String {
        return "$\(String(format: "%.2f", abs(biggestHandLoss)))"
    }

    /// Formatted best session profit
    var formattedBestSessionProfit: String {
        return "$\(String(format: "%.2f", bestSessionProfit))"
    }

    /// Formatted worst session loss
    var formattedWorstSessionLoss: String {
        return "$\(String(format: "%.2f", abs(worstSessionLoss)))"
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🛠️ STATS CALCULATION EXTENSIONS                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension OverallStats {

    /// Calculate overall stats from a collection of sessions
    static func from(sessions: [Session]) -> OverallStats {
        guard !sessions.isEmpty else {
            return OverallStats()
        }

        // Aggregate basic counts
        let sessionsCount = sessions.count
        let totalTime = sessions.reduce(0.0) { $0 + $1.duration }

        // Aggregate all hands
        let allHands = sessions.flatMap { $0.hands }
        let handsCount = allHands.count
        let wins = allHands.filter { $0.outcome.isWin }.count
        let losses = allHands.filter { $0.outcome.isLoss }.count
        let pushes = allHands.filter { $0.outcome.isPush }.count
        let blackjacks = allHands.filter { $0.outcome == .blackjack }.count
        let busts = allHands.filter { $0.outcome == .bust }.count

        // Financial aggregates
        let profit = sessions.reduce(0.0) { $0 + $1.netProfit }
        let wagered = allHands.reduce(0.0) { $0 + $1.betAmount }

        // Records
        let biggestWin = allHands.map { $0.netResult }.max() ?? 0
        let biggestLoss = allHands.map { $0.netResult }.min() ?? 0
        let bestSession = sessions.max { $0.netProfit < $1.netProfit }
        let bestProfit = bestSession?.netProfit ?? 0
        let bestSessionID = bestSession?.id
        let worstSession = sessions.min { $0.netProfit < $1.netProfit }
        let worstLoss = worstSession?.netProfit ?? 0

        // Calculate longest streaks across all hands
        let (longestWin, longestLose) = calculateLongestStreaks(from: allHands)

        // Find favourite dealer (most played)
        let dealerCounts = Dictionary(grouping: sessions) { $0.dealerName }
            .mapValues { $0.count }
        let favDealer = dealerCounts.max { $0.value < $1.value }?.key

        // Find most successful dealer (best win rate)
        let dealerNames = Set(sessions.map { $0.dealerName })
        var bestWinRate = 0.0
        var mostSuccessful: String? = nil

        for dealer in dealerNames {
            let dealerSessions = sessions.filter { $0.dealerName == dealer }
            let dealerHands = dealerSessions.flatMap { $0.hands }
            guard !dealerHands.isEmpty else { continue }

            let dealerWins = Double(dealerHands.filter { $0.outcome.isWin }.count)
            let dealerPushes = Double(dealerHands.filter { $0.outcome.isPush }.count)
            let dealerWinRate = (dealerWins + dealerPushes * 0.5) / Double(dealerHands.count)

            if dealerWinRate > bestWinRate {
                bestWinRate = dealerWinRate
                mostSuccessful = dealer
            }
        }

        return OverallStats(
            totalSessions: sessionsCount,
            totalTimePlayed: totalTime,
            totalHands: handsCount,
            totalWins: wins,
            totalLosses: losses,
            totalPushes: pushes,
            totalBlackjacks: blackjacks,
            totalBusts: busts,
            totalProfit: profit,
            totalWagered: wagered,
            biggestHandWin: biggestWin,
            biggestHandLoss: biggestLoss,
            bestSessionProfit: bestProfit,
            bestSessionId: bestSessionID,
            worstSessionLoss: worstLoss,
            longestWinStreak: longestWin,
            longestLoseStreak: longestLose,
            favouriteDealer: favDealer,
            mostSuccessfulDealer: mostSuccessful
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔥 CALCULATE LONGEST STREAKS                                     │
    // │                                                                  │
    // │ Business Logic: Find longest winning and losing streaks         │
    // │ across all hands ever played                                    │
    // └─────────────────────────────────────────────────────────────────┘

    private static func calculateLongestStreaks(from hands: [HandResult]) -> (wins: Int, losses: Int) {
        guard !hands.isEmpty else { return (0, 0) }

        var maxWinStreak = 0
        var maxLoseStreak = 0
        var currentWinStreak = 0
        var currentLoseStreak = 0

        for hand in hands {
            if hand.outcome.isPush {
                // Push doesn't count for streaks
                continue
            } else if hand.outcome.isWin {
                // Win - increment win streak, reset lose streak
                currentWinStreak += 1
                currentLoseStreak = 0
                maxWinStreak = max(maxWinStreak, currentWinStreak)
            } else {
                // Loss - increment lose streak, reset win streak
                currentLoseStreak += 1
                currentWinStreak = 0
                maxLoseStreak = max(maxLoseStreak, currentLoseStreak)
            }
        }

        return (maxWinStreak, maxLoseStreak)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Calculate overall stats from all sessions:                                 ║
// ║   let allSessions = StatisticsManager.shared.getAllSessions()             ║
// ║   let overallStats = OverallStats.from(sessions: allSessions)             ║
// ║                                                                            ║
// ║ Display overall statistics:                                                ║
// ║   print("Total hands: \(overallStats.totalHands)")                        ║
// ║   print("Win rate: \(overallStats.formattedWinRate)")                     ║
// ║   print("Total profit: \(overallStats.formattedTotalProfit)")             ║
// ║   print("Time played: \(overallStats.formattedTotalTime)")                ║
// ║                                                                            ║
// ║ Show achievements:                                                         ║
// ║   print("Biggest win: \(overallStats.formattedBiggestHandWin)")           ║
// ║   print("Longest win streak: \(overallStats.longestWinStreak) hands")    ║
// ║   if let dealer = overallStats.favouriteDealer {                          ║
// ║       print("Favourite dealer: \(dealer)")                                ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
