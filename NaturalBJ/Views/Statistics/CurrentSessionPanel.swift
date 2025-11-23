//
//  CurrentSessionPanel.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 CURRENT SESSION PANEL VIEW                                              ║
// ║                                                                            ║
// ║ Purpose: Displays live statistics during active gameplay                  ║
// ║ Business Context: Players want instant feedback on their performance      ║
// ║                   during a session. This compact panel shows key stats    ║
// ║                   without obscuring the game table.                       ║
// ║                                                                            ║
// ║ Displays:                                                                  ║
// ║ • Hands played                                                             ║
// ║ • Win rate %                                                               ║
// ║ • Net profit/loss                                                          ║
// ║ • Current streak (optional)                                               ║
// ║ • Session duration (optional)                                             ║
// ║                                                                            ║
// ║ UI Positioning: Compact bar at top or bottom of GameView                  ║
// ║                 Subtle, non-intrusive design                              ║
// ║                                                                            ║
// ║ Used By: GameView (overlayed on game table)                               ║
// ║                                                                            ║
// ║ Related Spec: See "Statistics & Session History" (lines 178-215)          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 CURRENT SESSION PANEL VIEW                                              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct CurrentSessionPanel: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 VIEW PROPERTIES                                               │
    // └─────────────────────────────────────────────────────────────────┘

    /// Current session data (passed from parent)
    let session: Session

    /// Compact mode (shows fewer stats)
    var compact: Bool = false

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        if compact {
            compactView
        } else {
            fullView
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎨 COMPACT VIEW (MINIMAL STATS)                                    ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    private var compactView: some View {
        HStack(spacing: 16) {
            // Hands played
            StatItem(
                icon: "🎴",
                value: "\(session.handsPlayed)",
                label: "Hands"
            )

            Divider()
                .frame(height: 20)

            // Win rate
            StatItem(
                icon: "📈",
                value: session.formattedWinRate,
                label: "Win Rate",
                color: winRateColor
            )

            Divider()
                .frame(height: 20)

            // Net profit
            StatItem(
                icon: profitIcon,
                value: session.formattedNetProfit,
                label: "Profit",
                color: profitColor
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎨 FULL VIEW (ALL STATS)                                           ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    private var fullView: some View {
        VStack(spacing: 12) {
            // Top row: Hands, Win Rate, Profit
            HStack(spacing: 20) {
                StatCard(
                    icon: "🎴",
                    value: "\(session.handsPlayed)",
                    label: "Hands Played"
                )

                StatCard(
                    icon: "📈",
                    value: session.formattedWinRate,
                    label: "Win Rate",
                    color: winRateColor
                )

                StatCard(
                    icon: profitIcon,
                    value: session.formattedNetProfit,
                    label: "Net Profit",
                    color: profitColor
                )
            }

            // Bottom row: Streak, Duration, Biggest Win
            HStack(spacing: 20) {
                StatCard(
                    icon: streakIcon,
                    value: abs(session.currentStreak) > 0 ? "\(abs(session.currentStreak))" : "-",
                    label: streakLabel,
                    color: streakColor
                )

                StatCard(
                    icon: "⏱️",
                    value: session.formattedDuration,
                    label: "Duration"
                )

                StatCard(
                    icon: "💰",
                    value: session.biggestWin > 0 ? "$\(Int(session.biggestWin))" : "-",
                    label: "Biggest Win",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎨 COMPUTED PROPERTIES FOR STYLING                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Win rate colour (green if >50%, red if <45%, yellow otherwise)
    private var winRateColor: Color {
        if session.winRatePercentage >= 50 { return .green }
        else if session.winRatePercentage < 45 { return .red }
        else { return .yellow }
    }

    /// Profit colour (green if positive, red if negative, gray if zero)
    private var profitColor: Color {
        if session.netProfit > 0 { return .green }
        else if session.netProfit < 0 { return .red }
        else { return .gray }
    }

    /// Profit icon (up arrow if positive, down arrow if negative)
    private var profitIcon: String {
        if session.netProfit > 0 { return "📈" }
        else if session.netProfit < 0 { return "📉" }
        else { return "💵" }
    }

    /// Streak icon
    private var streakIcon: String {
        if session.currentStreak > 0 { return "🔥" }
        else if session.currentStreak < 0 { return "❄️" }
        else { return "➖" }
    }

    /// Streak label
    private var streakLabel: String {
        if session.currentStreak > 0 { return "Win Streak" }
        else if session.currentStreak < 0 { return "Loss Streak" }
        else { return "Streak" }
    }

    /// Streak colour
    private var streakColor: Color {
        if session.currentStreak > 0 { return .green }
        else if session.currentStreak < 0 { return .red }
        else { return .gray }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 STAT ITEM (COMPACT)                                                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = .white

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 14))
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 STAT CARD (FULL VIEW)                                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = .white

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("Compact View") {
    let sampleSession = Session(
        dealerName: "Ruby",
        dealerIcon: "♦️",
        startingBankroll: 10000,
        currentBankroll: 10450,
        hands: [
            HandResult(
                playerCards: "K♠, 9♥",
                playerTotal: 19,
                dealerCards: "10♦, 7♣",
                dealerTotal: 17,
                betAmount: 50,
                payout: 100,
                outcome: .win
            ),
            HandResult(
                playerCards: "A♠, K♥",
                playerTotal: 21,
                dealerCards: "10♦, 8♣",
                dealerTotal: 18,
                betAmount: 100,
                payout: 250,
                outcome: .blackjack
            ),
            HandResult(
                playerCards: "10♠, 5♥, 9♦",
                playerTotal: 24,
                dealerCards: "9♦, 7♣",
                dealerTotal: 16,
                betAmount: 50,
                payout: 0,
                outcome: .bust
            )
        ]
    )

    return ZStack {
        Color.green.opacity(0.3).ignoresSafeArea()

        CurrentSessionPanel(session: sampleSession, compact: true)
            .padding()
    }
}

#Preview("Full View") {
    let sampleSession = Session(
        dealerName: "Ruby",
        dealerIcon: "♦️",
        startingBankroll: 10000,
        currentBankroll: 10450,
        hands: [
            HandResult(
                playerCards: "K♠, 9♥",
                playerTotal: 19,
                dealerCards: "10♦, 7♣",
                dealerTotal: 17,
                betAmount: 50,
                payout: 100,
                outcome: .win
            ),
            HandResult(
                playerCards: "A♠, K♥",
                playerTotal: 21,
                dealerCards: "10♦, 8♣",
                dealerTotal: 18,
                betAmount: 100,
                payout: 250,
                outcome: .blackjack
            ),
            HandResult(
                playerCards: "10♠, 5♥, 9♦",
                playerTotal: 24,
                dealerCards: "9♦, 7♣",
                dealerTotal: 16,
                betAmount: 50,
                payout: 0,
                outcome: .bust
            )
        ]
    )

    return ZStack {
        Color.green.opacity(0.3).ignoresSafeArea()

        CurrentSessionPanel(session: sampleSession, compact: false)
            .padding()
    }
}
