//
//  Session.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 SESSION MODEL                                                           ║
// ║                                                                            ║
// ║ Purpose: Represents a single playing session from start to finish         ║
// ║ Business Context: A session is a continuous period of play. Players       ║
// ║                   want to track each session separately to see if they're ║
// ║                   improving over time and which dealers work best for them║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Track session start/end times and duration                              ║
// ║ • Record starting and ending bankroll                                     ║
// ║ • Aggregate all hand results for this session                             ║
// ║ • Calculate session statistics (win rate, net profit, etc.)               ║
// ║ • Store dealer information                                                ║
// ║                                                                            ║
// ║ Used By: StatisticsManager (creates and stores sessions)                  ║
// ║          StatisticsViewModel (displays session data)                      ║
// ║          SessionHistoryView (shows list of past sessions)                 ║
// ║                                                                            ║
// ║ Related Spec: See "Statistics & Session History" (lines 178-215)          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 SESSION STRUCTURE                                                       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct Session: Codable, Identifiable {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 IDENTIFICATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Unique identifier for this session
    let id: UUID

    /// When the session started
    let startTime: Date

    /// When the session ended (nil if session is still active)
    var endTime: Date?

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎰 DEALER INFORMATION                                            │
    // └─────────────────────────────────────────────────────────────────┘

    /// Name of dealer for this session (e.g., "Ruby", "Lucky", "Shark")
    let dealerName: String

    /// Dealer emoji/icon (e.g., "♦️", "🍀", "🦈")
    let dealerIcon: String

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💰 FINANCIAL TRACKING                                            │
    // └─────────────────────────────────────────────────────────────────┘

    /// Bankroll at start of session
    let startingBankroll: Double

    /// Current/final bankroll
    var currentBankroll: Double

    /// Net profit/loss for this session
    var netProfit: Double {
        return currentBankroll - startingBankroll
    }

    /// Return on investment as percentage
    var roi: Double {
        guard startingBankroll > 0 else { return 0 }
        return (netProfit / startingBankroll) * 100
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎴 HAND TRACKING                                                 │
    // └─────────────────────────────────────────────────────────────────┘

    /// All hands played in this session
    var hands: [HandResult]

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        dealerName: String,
        dealerIcon: String,
        startingBankroll: Double,
        currentBankroll: Double? = nil,
        hands: [HandResult] = []
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.dealerName = dealerName
        self.dealerIcon = dealerIcon
        self.startingBankroll = startingBankroll
        self.currentBankroll = currentBankroll ?? startingBankroll
        self.hands = hands
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 COMPUTED STATISTICS                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Session {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⏱️ TIME TRACKING                                                  │
    // └─────────────────────────────────────────────────────────────────┘

    /// Duration of session in seconds
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    /// Formatted duration (e.g., "1h 23m", "45m", "2h 5m")
    var formattedDuration: String {
        let totalMinutes = Int(duration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Is this session currently active?
    var isActive: Bool {
        return endTime == nil
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎴 HAND STATISTICS                                               │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total number of hands played
    var handsPlayed: Int {
        return hands.count
    }

    /// Number of hands won (excluding pushes)
    var handsWon: Int {
        return hands.filter { $0.outcome.isWin }.count
    }

    /// Number of hands lost
    var handsLost: Int {
        return hands.filter { $0.outcome.isLoss }.count
    }

    /// Number of pushes
    var handsPushed: Int {
        return hands.filter { $0.outcome.isPush }.count
    }

    /// Number of blackjacks hit
    var blackjacksCount: Int {
        return hands.filter { $0.outcome == .blackjack }.count
    }

    /// Number of busts
    var bustsCount: Int {
        return hands.filter { $0.outcome == .bust }.count
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📈 WIN RATE CALCULATION                                          │
    // │                                                                  │
    // │ Business Logic: Win rate counts pushes as half wins             │
    // │ This gives a more accurate picture of performance               │
    // │ Formula: (wins + pushes * 0.5) / total hands                    │
    // └─────────────────────────────────────────────────────────────────┘

    /// Win rate as decimal (0.0 to 1.0)
    var winRate: Double {
        guard handsPlayed > 0 else { return 0 }
        let effectiveWins = Double(handsWon) + (Double(handsPushed) * 0.5)
        return effectiveWins / Double(handsPlayed)
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
    // │ 💰 FINANCIAL STATISTICS                                          │
    // └─────────────────────────────────────────────────────────────────┘

    /// Total amount wagered across all hands
    var totalWagered: Double {
        return hands.reduce(0) { $0 + $1.betAmount }
    }

    /// Average bet size
    var averageBet: Double {
        guard handsPlayed > 0 else { return 0 }
        return totalWagered / Double(handsPlayed)
    }

    /// Biggest single win in session
    var biggestWin: Double {
        return hands.map { $0.netResult }.max() ?? 0
    }

    /// Biggest single loss in session
    var biggestLoss: Double {
        return hands.map { $0.netResult }.min() ?? 0
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔥 STREAK TRACKING                                               │
    // │                                                                  │
    // │ Business Logic: Calculate current winning/losing streak         │
    // │ Looks at most recent hands to find consecutive wins/losses      │
    // └─────────────────────────────────────────────────────────────────┘

    /// Current win/loss streak (positive = wins, negative = losses, 0 = ended on push)
    var currentStreak: Int {
        guard !hands.isEmpty else { return 0 }

        var streak = 0
        var lastOutcomeType: String? = nil // "win", "loss", or "push"

        // Walk backwards through hands
        for hand in hands.reversed() {
            if hand.outcome.isPush {
                // Push breaks streak but doesn't count
                break
            }

            let isWin = hand.outcome.isWin
            let currentType = isWin ? "win" : "loss"

            if lastOutcomeType == nil {
                // First hand - start streak
                lastOutcomeType = currentType
                streak = isWin ? 1 : -1
            } else if lastOutcomeType == currentType {
                // Continue streak
                streak += isWin ? 1 : -1
            } else {
                // Streak broken
                break
            }
        }

        return streak
    }

    /// Formatted streak for display
    var formattedStreak: String {
        if currentStreak > 0 {
            return "🔥 \(currentStreak) win\(currentStreak == 1 ? "" : "s")"
        } else if currentStreak < 0 {
            return "❄️ \(abs(currentStreak)) loss\(currentStreak == -1 ? "" : "es")"
        } else {
            return "No streak"
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 DISPLAY HELPERS                                               │
    // └─────────────────────────────────────────────────────────────────┘

    /// Formatted net profit/loss
    var formattedNetProfit: String {
        let prefix = netProfit >= 0 ? "+" : ""
        return "\(prefix)$\(String(format: "%.2f", netProfit))"
    }

    /// Formatted ROI
    var formattedROI: String {
        let prefix = roi >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.1f", roi))%"
    }

    /// Summary line for list display
    var summaryLine: String {
        return "\(handsPlayed) hands, \(formattedWinRate) win, \(formattedNetProfit)"
    }

    /// Session title for display (e.g., "Today, 2:47 PM - Ruby")
    var displayTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(dealerName) \(dealerIcon)"
    }

    /// Short date display (e.g., "Today, 2:47 PM" or "Nov 19, 3:22 PM")
    var shortDateDisplay: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(startTime) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: startTime))"
        } else if calendar.isDateInYesterday(startTime) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: startTime))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: startTime)
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🛠️ SESSION MANAGEMENT EXTENSIONS                                          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Session {

    /// Add a hand result to this session
    mutating func addHand(_ hand: HandResult) {
        hands.append(hand)
        // Note: Bankroll is updated separately by GameViewModel
    }

    /// End this session
    mutating func endSession(finalBankroll: Double) {
        self.endTime = Date()
        self.currentBankroll = finalBankroll
    }

    /// Update current bankroll (for active sessions)
    mutating func updateBankroll(_ newBankroll: Double) {
        self.currentBankroll = newBankroll
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create a new session:                                                      ║
// ║   var session = Session(                                                   ║
// ║       dealerName: "Ruby",                                                 ║
// ║       dealerIcon: "♦️",                                                    ║
// ║       startingBankroll: 10000                                             ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Add hands as they're played:                                               ║
// ║   let hand = HandResult(...)                                               ║
// ║   session.addHand(hand)                                                    ║
// ║   session.updateBankroll(10050)                                           ║
// ║                                                                            ║
// ║ Check statistics:                                                          ║
// ║   print("Win rate: \(session.formattedWinRate)")                          ║
// ║   print("Net profit: \(session.formattedNetProfit)")                      ║
// ║   print("Current streak: \(session.formattedStreak)")                     ║
// ║                                                                            ║
// ║ End session:                                                               ║
// ║   session.endSession(finalBankroll: 10500)                                ║
// ║   print("Session lasted \(session.formattedDuration)")                    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
