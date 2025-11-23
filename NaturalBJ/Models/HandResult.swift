//
//  HandResult.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 HAND RESULT MODEL                                                       ║
// ║                                                                            ║
// ║ Purpose: Records the outcome of a single blackjack hand                   ║
// ║ Business Context: Players want to review past hands to learn from         ║
// ║                   mistakes and celebrate wins. Each hand result captures  ║
// ║                   all the details needed to recreate what happened.       ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Record player cards, dealer cards, and final totals                     ║
// ║ • Track bet amount and payout                                             ║
// ║ • Store outcome (win/loss/push/blackjack/bust)                            ║
// ║ • Record player actions taken (hit, stand, double, split, surrender)      ║
// ║ • Calculate net profit/loss for this hand                                 ║
// ║                                                                            ║
// ║ Used By: Session (aggregates multiple HandResults)                        ║
// ║          StatisticsManager (tracks hand history)                          ║
// ║                                                                            ║
// ║ Related Spec: See "Statistics & Session History" (lines 178-215)          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ┌─────────────────────────────────────────────────────────────────────┐
// │ 🏆 HAND OUTCOME ENUMERATION                                          │
// │                                                                      │
// │ All possible outcomes for a blackjack hand                          │
// │ Used for filtering and statistics calculations                      │
// └─────────────────────────────────────────────────────────────────────┘

enum HandOutcome: String, Codable {
    case win              // Player beats dealer (standard win)
    case loss             // Dealer beats player
    case push             // Tie - bet returned
    case blackjack        // Natural 21 (3:2 payout)
    case bust             // Player went over 21
    case dealerBust       // Dealer busts, player wins
    case surrender        // Player surrendered (loses half bet)

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎯 OUTCOME PROPERTIES                                            │
    // └─────────────────────────────────────────────────────────────────┘

    /// Is this outcome a win for the player?
    var isWin: Bool {
        return self == .win || self == .blackjack || self == .dealerBust
    }

    /// Is this outcome a loss for the player?
    var isLoss: Bool {
        return self == .loss || self == .bust || self == .surrender
    }

    /// Is this outcome neutral (no money won/lost except original bet)?
    var isPush: Bool {
        return self == .push
    }

    /// Display string for UI
    var displayString: String {
        switch self {
        case .win: return "Win"
        case .loss: return "Loss"
        case .push: return "Push"
        case .blackjack: return "Blackjack!"
        case .bust: return "Bust"
        case .dealerBust: return "Dealer Bust"
        case .surrender: return "Surrender"
        }
    }

    /// Emoji for UI display
    var emoji: String {
        switch self {
        case .win, .dealerBust: return "✅"
        case .loss, .bust: return "❌"
        case .push: return "🤝"
        case .blackjack: return "🎉"
        case .surrender: return "🏳️"
        }
    }
}

// ┌─────────────────────────────────────────────────────────────────────┐
// │ 🎯 PLAYER ACTION ENUMERATION                                         │
// │                                                                      │
// │ Records what actions the player took during the hand                │
// │ Used for strategy analysis and learning                             │
// └─────────────────────────────────────────────────────────────────────┘

enum PlayerAction: String, Codable {
    case hit
    case stand
    case doubleDown
    case split
    case surrender
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 HAND RESULT STRUCTURE                                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct HandResult: Codable, Identifiable {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 IDENTIFICATION                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Unique identifier for this hand
    let id: UUID

    /// Timestamp when hand was played
    let timestamp: Date

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎴 CARDS & TOTALS                                                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Player's final cards (stored as simple strings like "A♠, K♥")
    let playerCards: String

    /// Player's final hand total
    let playerTotal: Int

    /// Dealer's final cards
    let dealerCards: String

    /// Dealer's final hand total
    let dealerTotal: Int

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💰 FINANCIAL DETAILS                                             │
    // └─────────────────────────────────────────────────────────────────┘

    /// Amount bet on this hand
    let betAmount: Double

    /// Amount paid out (includes original bet if won)
    /// Win: 2x bet, Blackjack: 2.5x bet, Push: 1x bet, Loss: 0
    let payout: Double

    /// Net profit/loss for this hand (payout - betAmount)
    var netResult: Double {
        return payout - betAmount
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎯 OUTCOME & ACTIONS                                             │
    // └─────────────────────────────────────────────────────────────────┘

    /// Final outcome of the hand
    let outcome: HandOutcome

    /// Actions player took during the hand (in order)
    let actions: [PlayerAction]

    /// Was this hand part of a split?
    let wasSplit: Bool

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        playerCards: String,
        playerTotal: Int,
        dealerCards: String,
        dealerTotal: Int,
        betAmount: Double,
        payout: Double,
        outcome: HandOutcome,
        actions: [PlayerAction] = [],
        wasSplit: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.playerCards = playerCards
        self.playerTotal = playerTotal
        self.dealerCards = dealerCards
        self.dealerTotal = dealerTotal
        self.betAmount = betAmount
        self.payout = payout
        self.outcome = outcome
        self.actions = actions
        self.wasSplit = wasSplit
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🛠️ EXTENSIONS                                                              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension HandResult {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 DISPLAY HELPERS                                               │
    // └─────────────────────────────────────────────────────────────────┘

    /// Formatted net result for display (e.g., "+$50.00" or "-$25.00")
    var formattedNetResult: String {
        let prefix = netResult >= 0 ? "+" : ""
        return "\(prefix)$\(String(format: "%.2f", netResult))"
    }

    /// Formatted bet amount
    var formattedBet: String {
        return "$\(String(format: "%.2f", betAmount))"
    }

    /// Formatted payout
    var formattedPayout: String {
        return "$\(String(format: "%.2f", payout))"
    }

    /// Short summary for list display
    var shortSummary: String {
        return "\(outcome.emoji) \(outcome.displayString): \(formattedNetResult)"
    }

    /// Actions taken as comma-separated string
    var actionsString: String {
        if actions.isEmpty {
            return "Stand"
        }
        return actions.map { $0.rawValue.capitalized }.joined(separator: ", ")
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Create a winning hand:                                                     ║
// ║   let hand = HandResult(                                                   ║
// ║       playerCards: "K♠, 9♥",                                              ║
// ║       playerTotal: 19,                                                    ║
// ║       dealerCards: "10♦, 7♣",                                             ║
// ║       dealerTotal: 17,                                                    ║
// ║       betAmount: 50.0,                                                    ║
// ║       payout: 100.0,                                                      ║
// ║       outcome: .win,                                                      ║
// ║       actions: [.stand]                                                   ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Create a blackjack hand:                                                   ║
// ║   let bj = HandResult(                                                     ║
// ║       playerCards: "A♠, K♥",                                              ║
// ║       playerTotal: 21,                                                    ║
// ║       dealerCards: "10♦, 8♣",                                             ║
// ║       dealerTotal: 18,                                                    ║
// ║       betAmount: 100.0,                                                   ║
// ║       payout: 250.0,          // 3:2 payout                              ║
// ║       outcome: .blackjack,                                                ║
// ║       actions: []             // No actions on natural blackjack          ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Check if profitable:                                                       ║
// ║   if hand.netResult > 0 {                                                 ║
// ║       print("Won \(hand.formattedNetResult)!")                            ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
