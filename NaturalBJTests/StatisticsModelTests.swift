//
//  StatisticsModelTests.swift
//  BlackjackwhitejackTests
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🧪 STATISTICS MODEL TESTS                                                  ║
// ║                                                                            ║
// ║ Purpose: Test statistics models (HandResult, Session, DealerStats, etc.)  ║
// ║ Coverage: All model calculations, edge cases, and formatting              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import XCTest
@testable import Blackjackwhitejack

class StatisticsModelTests: XCTestCase {

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎴 HAND RESULT TESTS                                               ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    func testHandResultNetResult() {
        let winningHand = HandResult(
            playerCards: "K♠, 9♥",
            playerTotal: 19,
            dealerCards: "10♦, 7♣",
            dealerTotal: 17,
            betAmount: 50,
            payout: 100,
            outcome: .win
        )

        XCTAssertEqual(winningHand.netResult, 50, "Win should profit bet amount")
    }

    func testHandResultLosingHand() {
        let losingHand = HandResult(
            playerCards: "10♠, 5♥",
            playerTotal: 15,
            dealerCards: "10♦, 9♣",
            dealerTotal: 19,
            betAmount: 50,
            payout: 0,
            outcome: .loss
        )

        XCTAssertEqual(losingHand.netResult, -50, "Loss should lose bet amount")
    }

    func testHandResultBlackjackPayout() {
        let blackjack = HandResult(
            playerCards: "A♠, K♥",
            playerTotal: 21,
            dealerCards: "10♦, 8♣",
            dealerTotal: 18,
            betAmount: 100,
            payout: 250,
            outcome: .blackjack
        )

        XCTAssertEqual(blackjack.netResult, 150, "Blackjack should pay 1.5x bet")
    }

    func testHandResultPush() {
        let push = HandResult(
            playerCards: "10♠, 9♥",
            playerTotal: 19,
            dealerCards: "10♦, 9♣",
            dealerTotal: 19,
            betAmount: 50,
            payout: 50,
            outcome: .push
        )

        XCTAssertEqual(push.netResult, 0, "Push should break even")
    }

    func testHandOutcomeProperties() {
        XCTAssertTrue(HandOutcome.win.isWin)
        XCTAssertTrue(HandOutcome.blackjack.isWin)
        XCTAssertTrue(HandOutcome.dealerBust.isWin)

        XCTAssertTrue(HandOutcome.loss.isLoss)
        XCTAssertTrue(HandOutcome.bust.isLoss)
        XCTAssertTrue(HandOutcome.surrender.isLoss)

        XCTAssertTrue(HandOutcome.push.isPush)
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 SESSION TESTS                                                   ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    func testSessionWinRateCalculation() {
        var session = Session(
            dealerName: "Ruby",
            dealerIcon: "♦️",
            startingBankroll: 10000
        )

        // Add 2 wins, 1 loss, 1 push
        session.addHand(createHandResult(outcome: .win, bet: 50, payout: 100))
        session.addHand(createHandResult(outcome: .win, bet: 50, payout: 100))
        session.addHand(createHandResult(outcome: .loss, bet: 50, payout: 0))
        session.addHand(createHandResult(outcome: .push, bet: 50, payout: 50))

        // Win rate = (2 + 0.5) / 4 = 0.625 = 62.5%
        XCTAssertEqual(session.winRatePercentage, 62.5, accuracy: 0.1)
    }

    func testSessionNetProfit() {
        var session = Session(
            dealerName: "Ruby",
            dealerIcon: "♦️",
            startingBankroll: 10000,
            currentBankroll: 10500
        )

        XCTAssertEqual(session.netProfit, 500)
    }

    func testSessionHandCounts() {
        var session = Session(
            dealerName: "Ruby",
            dealerIcon: "♦️",
            startingBankroll: 10000
        )

        session.addHand(createHandResult(outcome: .win, bet: 50, payout: 100))
        session.addHand(createHandResult(outcome: .loss, bet: 50, payout: 0))
        session.addHand(createHandResult(outcome: .push, bet: 50, payout: 50))
        session.addHand(createHandResult(outcome: .blackjack, bet: 100, payout: 250))

        XCTAssertEqual(session.handsPlayed, 4)
        XCTAssertEqual(session.handsWon, 2) // win + blackjack
        XCTAssertEqual(session.handsLost, 1)
        XCTAssertEqual(session.handsPushed, 1)
    }

    func testSessionCurrentStreak() {
        var session = Session(
            dealerName: "Ruby",
            dealerIcon: "♦️",
            startingBankroll: 10000
        )

        // Win streak
        session.addHand(createHandResult(outcome: .win, bet: 50, payout: 100))
        session.addHand(createHandResult(outcome: .win, bet: 50, payout: 100))
        session.addHand(createHandResult(outcome: .win, bet: 50, payout: 100))

        XCTAssertEqual(session.currentStreak, 3, "Should have 3-win streak")

        // Add a loss
        session.addHand(createHandResult(outcome: .loss, bet: 50, payout: 0))

        XCTAssertEqual(session.currentStreak, -1, "Should have 1-loss streak")
    }

    func testSessionBiggestWin() {
        var session = Session(
            dealerName: "Ruby",
            dealerIcon: "♦️",
            startingBankroll: 10000
        )

        session.addHand(createHandResult(outcome: .win, bet: 50, payout: 100))
        session.addHand(createHandResult(outcome: .blackjack, bet: 100, payout: 250))
        session.addHand(createHandResult(outcome: .win, bet: 25, payout: 50))

        XCTAssertEqual(session.biggestWin, 150, "Biggest win should be blackjack (+150)")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎰 DEALER STATS TESTS                                              ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    func testDealerStatsFromSessions() {
        // Create two sessions with Ruby
        let session1 = createTestSession(
            dealer: "Ruby",
            icon: "♦️",
            hands: [
                createHandResult(outcome: .win, bet: 50, payout: 100),
                createHandResult(outcome: .loss, bet: 50, payout: 0)
            ]
        )

        let session2 = createTestSession(
            dealer: "Ruby",
            icon: "♦️",
            hands: [
                createHandResult(outcome: .win, bet: 50, payout: 100),
                createHandResult(outcome: .win, bet: 50, payout: 100)
            ]
        )

        let rubyStats = DealerStats.from(
            sessions: [session1, session2],
            dealerName: "Ruby",
            dealerIcon: "♦️"
        )

        XCTAssertEqual(rubyStats.totalHands, 4)
        XCTAssertEqual(rubyStats.handsWon, 3)
        XCTAssertEqual(rubyStats.handsLost, 1)
        XCTAssertEqual(rubyStats.sessionsPlayed, 2)
    }

    func testDealerStatsWinRate() {
        let session = createTestSession(
            dealer: "Lucky",
            icon: "🍀",
            hands: [
                createHandResult(outcome: .win, bet: 50, payout: 100),
                createHandResult(outcome: .win, bet: 50, payout: 100),
                createHandResult(outcome: .loss, bet: 50, payout: 0),
                createHandResult(outcome: .push, bet: 50, payout: 50)
            ]
        )

        let luckyStats = DealerStats.from(
            sessions: [session],
            dealerName: "Lucky",
            dealerIcon: "🍀"
        )

        // Win rate = (2 + 0.5) / 4 = 0.625 = 62.5%
        XCTAssertEqual(luckyStats.winRatePercentage, 62.5, accuracy: 0.1)
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📈 OVERALL STATS TESTS                                             ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    func testOverallStatsFromSessions() {
        let sessions = [
            createTestSession(
                dealer: "Ruby",
                icon: "♦️",
                hands: [
                    createHandResult(outcome: .win, bet: 50, payout: 100),
                    createHandResult(outcome: .loss, bet: 50, payout: 0)
                ]
            ),
            createTestSession(
                dealer: "Lucky",
                icon: "🍀",
                hands: [
                    createHandResult(outcome: .blackjack, bet: 100, payout: 250),
                    createHandResult(outcome: .win, bet: 50, payout: 100)
                ]
            )
        ]

        let overallStats = OverallStats.from(sessions: sessions)

        XCTAssertEqual(overallStats.totalSessions, 2)
        XCTAssertEqual(overallStats.totalHands, 4)
        XCTAssertEqual(overallStats.totalWins, 3) // 2 wins + 1 blackjack
        XCTAssertEqual(overallStats.totalLosses, 1)
    }

    func testOverallStatsLongestStreak() {
        let session = createTestSession(
            dealer: "Ruby",
            icon: "♦️",
            hands: [
                createHandResult(outcome: .win, bet: 50, payout: 100),
                createHandResult(outcome: .win, bet: 50, payout: 100),
                createHandResult(outcome: .win, bet: 50, payout: 100),
                createHandResult(outcome: .loss, bet: 50, payout: 0),
                createHandResult(outcome: .loss, bet: 50, payout: 0)
            ]
        )

        let overallStats = OverallStats.from(sessions: [session])

        XCTAssertEqual(overallStats.longestWinStreak, 3)
        XCTAssertEqual(overallStats.longestLoseStreak, 2)
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🛠️ HELPER FUNCTIONS                                                ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    private func createHandResult(outcome: HandOutcome, bet: Double, payout: Double) -> HandResult {
        return HandResult(
            playerCards: "K♠, 9♥",
            playerTotal: 19,
            dealerCards: "10♦, 7♣",
            dealerTotal: 17,
            betAmount: bet,
            payout: payout,
            outcome: outcome
        )
    }

    private func createTestSession(dealer: String, icon: String, hands: [HandResult]) -> Session {
        var session = Session(
            dealerName: dealer,
            dealerIcon: icon,
            startingBankroll: 10000
        )

        for hand in hands {
            session.addHand(hand)
        }

        return session
    }
}
