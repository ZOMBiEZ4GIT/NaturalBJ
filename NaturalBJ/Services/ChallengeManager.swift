//
//  ChallengeManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 9: Daily Challenges & Events System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎯 CHALLENGE MANAGER SERVICE                                               ║
// ║                                                                            ║
// ║ Purpose: Central coordinator for all challenge tracking and management    ║
// ║ Business Context: This is the single source of truth for all challenges.  ║
// ║                   It manages daily/weekly/event challenge pools,          ║
// ║                   handles rotation, tracks progress, and awards rewards.  ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Define all challenge templates (30-40 total)                            ║
// ║ • Rotate daily challenges (3-5 per day)                                   ║
// ║ • Rotate weekly challenges (1-2 per week)                                 ║
// ║ • Manage special event challenges                                         ║
// ║ • Track progress for active challenges                                    ║
// ║ • Detect completion and award rewards                                     ║
// ║ • Integrate with TimeManager for refresh logic                            ║
// ║ • Persist challenge data via UserDefaults/JSON                            ║
// ║ • Track daily login streaks                                               ║
// ║                                                                            ║
// ║ Architecture Pattern: Singleton service with @Published properties        ║
// ║ Used By: GameViewModel (updates progress after hands)                     ║
// ║          ChallengesView (displays active challenges)                      ║
// ║                                                                            ║
// ║ Related Spec: See "Daily Challenges & Events System" Phase 9              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import Combine

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎯 CHALLENGE MANAGER CLASS                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

@MainActor
class ChallengeManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON PATTERN                                             │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = ChallengeManager()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                               │
    // │                                                                  │
    // │ These properties trigger UI updates when changed                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Currently active daily challenges
    @Published private(set) var activeDailyChallenges: [Challenge] = []

    /// Currently active weekly challenges
    @Published private(set) var activeWeeklyChallenges: [Challenge] = []

    /// Currently active special event challenges
    @Published private(set) var activeEventChallenges: [Challenge] = []

    /// Queue of recently completed challenges (for displaying popups)
    @Published var completedChallengeQueue: [Challenge] = []

    /// Current daily login streak
    @Published private(set) var dailyLoginStreak: Int = 0

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    /// UserDefaults key for persistence
    private let challengesKey = "active_challenges"

    /// Time manager for refresh logic
    private let timeManager = TimeManager.shared

    /// Statistics manager for checking challenge conditions
    private let statsManager = StatisticsManager.shared

    /// Progression manager for awarding XP
    private let progressionManager = ProgressionManager.shared

    /// Challenge template pool (all possible challenges)
    private var challengeTemplates: [ChallengeTemplate] = []

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // │                                                                  │
    // │ Private to enforce singleton pattern                            │
    // │ Initialises challenge pool and loads saved progress             │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {
        print("🎯 ChallengeManager initialising...")
        initialiseChallengeTemplates()
        loadChallenges()
        checkForRefresh()
        updateDailyLoginStreak()
        print("🎯 ChallengeManager ready (\(activeDailyChallenges.count) daily, \(activeWeeklyChallenges.count) weekly)")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎲 CHALLENGE TEMPLATE DEFINITIONS                                  ║
    // ║                                                                    ║
    // ║ All 30-40 possible challenges defined here                        ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    private func initialiseChallengeTemplates() {
        challengeTemplates = [
            // ═══════════════════════════════════════════════════════════
            // EASY DAILY CHALLENGES (50-75 XP)
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "daily_first_win",
                name: "First Victory",
                description: "Win your first hand today",
                iconName: "🎯",
                type: .daily,
                category: .performance,
                difficulty: .easy,
                requiredProgress: 1,
                rewards: .easyDaily(),
                actionType: .win
            ),
            ChallengeTemplate(
                id: "daily_play_5",
                name: "Getting Started",
                description: "Play 5 hands today",
                iconName: "🎴",
                type: .daily,
                category: .gameplay,
                difficulty: .easy,
                requiredProgress: 5,
                rewards: .easyDaily(),
                actionType: .playHands
            ),
            ChallengeTemplate(
                id: "daily_blackjack_1",
                name: "Natural Winner",
                description: "Get 1 blackjack today",
                iconName: "🎰",
                type: .daily,
                category: .performance,
                difficulty: .easy,
                requiredProgress: 1,
                rewards: [.xp(75)],
                actionType: .blackjack
            ),
            ChallengeTemplate(
                id: "daily_dealer_play",
                name: "Dealer's Choice",
                description: "Play 3 hands with any dealer",
                iconName: "🎪",
                type: .daily,
                category: .exploration,
                difficulty: .easy,
                requiredProgress: 3,
                rewards: .easyDaily(),
                actionType: .playHands
            ),

            // ═══════════════════════════════════════════════════════════
            // MEDIUM DAILY CHALLENGES (100-150 XP)
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "daily_win_streak_3",
                name: "Triple Threat",
                description: "Win 3 hands in a row",
                iconName: "🔥",
                type: .daily,
                category: .performance,
                difficulty: .medium,
                requiredProgress: 3,
                rewards: .mediumDaily(),
                actionType: .winStreak
            ),
            ChallengeTemplate(
                id: "daily_double_3",
                name: "Double Down Master",
                description: "Win 3 double down hands",
                iconName: "💪",
                type: .daily,
                category: .mastery,
                difficulty: .medium,
                requiredProgress: 3,
                rewards: [.xp(150)],
                actionType: .doubleDown
            ),
            ChallengeTemplate(
                id: "daily_profitable",
                name: "Profitable Session",
                description: "End the day with profit",
                iconName: "📈",
                type: .daily,
                category: .performance,
                difficulty: .medium,
                requiredProgress: 1,
                rewards: [.xp(125)],
                actionType: .profit
            ),
            ChallengeTemplate(
                id: "daily_high_stakes_3",
                name: "High Stakes",
                description: "Bet $1000+ on 3 hands",
                iconName: "💰",
                type: .daily,
                category: .exploration,
                difficulty: .medium,
                requiredProgress: 3,
                rewards: [.xp(150)],
                actionType: .highBet
            ),
            ChallengeTemplate(
                id: "daily_consistent_20",
                name: "Consistency",
                description: "Play 20 hands today",
                iconName: "⏱️",
                type: .daily,
                category: .gameplay,
                difficulty: .medium,
                requiredProgress: 20,
                rewards: [.xp(100)],
                actionType: .playHands
            ),
            ChallengeTemplate(
                id: "daily_split_3",
                name: "Split Success",
                description: "Win 3 split hands",
                iconName: "✂️",
                type: .daily,
                category: .mastery,
                difficulty: .medium,
                requiredProgress: 3,
                rewards: [.xp(150)],
                actionType: .split
            ),

            // ═══════════════════════════════════════════════════════════
            // HARD DAILY CHALLENGES (200-250 XP)
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "daily_perfect_5",
                name: "Perfect Start",
                description: "Win your first 5 hands today",
                iconName: "🌟",
                type: .daily,
                category: .performance,
                difficulty: .hard,
                requiredProgress: 5,
                rewards: .hardDaily(),
                actionType: .win
            ),
            ChallengeTemplate(
                id: "daily_blackjack_3",
                name: "Blackjack Hunter",
                description: "Get 3 blackjacks today",
                iconName: "🎯",
                type: .daily,
                category: .performance,
                difficulty: .hard,
                requiredProgress: 3,
                rewards: [.xp(200)],
                actionType: .blackjack
            ),
            ChallengeTemplate(
                id: "daily_no_bust_15",
                name: "No Bust Challenge",
                description: "Play 15 hands without busting",
                iconName: "🛡️",
                type: .daily,
                category: .mastery,
                difficulty: .hard,
                requiredProgress: 15,
                rewards: [.xp(200)],
                actionType: .noBust
            ),
            ChallengeTemplate(
                id: "daily_win_streak_5",
                name: "Streak Master",
                description: "Achieve a 5-hand win streak",
                iconName: "⚡",
                type: .daily,
                category: .performance,
                difficulty: .hard,
                requiredProgress: 5,
                rewards: [.xp(250)],
                actionType: .winStreak
            ),
            ChallengeTemplate(
                id: "daily_dealer_ruby_10",
                name: "Ruby's Challenger",
                description: "Win 10 hands against Ruby",
                iconName: "♦️",
                type: .daily,
                category: .exploration,
                difficulty: .hard,
                requiredProgress: 10,
                rewards: [.xp(200)],
                actionType: .dealerSpecific,
                dealerName: "Ruby"
            ),
            ChallengeTemplate(
                id: "daily_dealer_shark_5",
                name: "Shark Hunter",
                description: "Win 5 hands against Shark",
                iconName: "🦈",
                type: .daily,
                category: .exploration,
                difficulty: .hard,
                requiredProgress: 5,
                rewards: [.xp(250)],
                actionType: .dealerSpecific,
                dealerName: "Shark"
            ),

            // ═══════════════════════════════════════════════════════════
            // EXPERT DAILY CHALLENGES (300+ XP)
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "daily_win_streak_10",
                name: "Unstoppable",
                description: "Win 10 hands in a row",
                iconName: "💫",
                type: .daily,
                category: .performance,
                difficulty: .expert,
                requiredProgress: 10,
                rewards: .expertDaily(),
                actionType: .winStreak
            ),
            ChallengeTemplate(
                id: "daily_blackjack_5",
                name: "Blackjack Bonanza",
                description: "Get 5 blackjacks today",
                iconName: "💎",
                type: .daily,
                category: .performance,
                difficulty: .expert,
                requiredProgress: 5,
                rewards: [.xp(300)],
                actionType: .blackjack
            ),

            // ═══════════════════════════════════════════════════════════
            // EASY WEEKLY CHALLENGES (500 XP)
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "weekly_play_50",
                name: "Weekly Grind",
                description: "Play 50 hands this week",
                iconName: "🎮",
                type: .weekly,
                category: .gameplay,
                difficulty: .easy,
                requiredProgress: 50,
                rewards: .easyWeekly(),
                actionType: .playHands
            ),
            ChallengeTemplate(
                id: "weekly_win_25",
                name: "Weekly Winner",
                description: "Win 25 hands this week",
                iconName: "🏆",
                type: .weekly,
                category: .performance,
                difficulty: .easy,
                requiredProgress: 25,
                rewards: .easyWeekly(),
                actionType: .win
            ),

            // ═══════════════════════════════════════════════════════════
            // MEDIUM WEEKLY CHALLENGES (750 XP + Bonus)
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "weekly_warrior_100",
                name: "Weekly Warrior",
                description: "Play 100 hands this week",
                iconName: "⚔️",
                type: .weekly,
                category: .gameplay,
                difficulty: .medium,
                requiredProgress: 100,
                rewards: .mediumWeekly(),
                actionType: .playHands
            ),
            ChallengeTemplate(
                id: "weekly_blackjack_10",
                name: "Natural Collection",
                description: "Get 10 blackjacks this week",
                iconName: "🎰",
                type: .weekly,
                category: .performance,
                difficulty: .medium,
                requiredProgress: 10,
                rewards: .mediumWeekly(),
                actionType: .blackjack
            ),
            ChallengeTemplate(
                id: "weekly_profit_5000",
                name: "Profit Target",
                description: "Earn $5,000 net profit this week",
                iconName: "💵",
                type: .weekly,
                category: .performance,
                difficulty: .medium,
                requiredProgress: 1,
                rewards: [.xp(750), .chips(2000)],
                actionType: .profit
            ),

            // ═══════════════════════════════════════════════════════════
            // HARD WEEKLY CHALLENGES (1000 XP + Bonus)
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "weekly_dealer_domination",
                name: "Dealer Domination",
                description: "Win 25 hands against each dealer",
                iconName: "👑",
                type: .weekly,
                category: .exploration,
                difficulty: .hard,
                requiredProgress: 125, // 25 * 5 dealers
                rewards: .hardWeekly(),
                actionType: .win
            ),
            ChallengeTemplate(
                id: "weekly_profit_10000",
                name: "Profit King",
                description: "Earn $10,000 net profit this week",
                iconName: "🤑",
                type: .weekly,
                category: .performance,
                difficulty: .hard,
                requiredProgress: 1,
                rewards: [.xp(1000), .chips(5000)],
                actionType: .profit
            ),
            ChallengeTemplate(
                id: "weekly_blackjack_15",
                name: "Blackjack Bonanza",
                description: "Get 15 blackjacks this week",
                iconName: "♠️",
                type: .weekly,
                category: .performance,
                difficulty: .hard,
                requiredProgress: 15,
                rewards: .hardWeekly(),
                actionType: .blackjack
            ),
            ChallengeTemplate(
                id: "weekly_big_spender",
                name: "Big Spender",
                description: "Wager $50,000 total this week",
                iconName: "💸",
                type: .weekly,
                category: .exploration,
                difficulty: .hard,
                requiredProgress: 50000,
                rewards: .hardWeekly(),
                actionType: .highBet
            ),

            // ═══════════════════════════════════════════════════════════
            // EXPERT WEEKLY CHALLENGES (1500 XP + Exclusive)
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "weekly_perfect_week",
                name: "Perfect Week",
                description: "Complete all daily challenges this week",
                iconName: "🏅",
                type: .weekly,
                category: .mastery,
                difficulty: .expert,
                requiredProgress: 7, // 7 days of dailies
                rewards: .expertWeekly(cosmetic: "Perfect Week Card Back"),
                actionType: .playHands
            ),
            ChallengeTemplate(
                id: "weekly_master_200",
                name: "Marathon Master",
                description: "Play 200 hands this week",
                iconName: "🔥",
                type: .weekly,
                category: .gameplay,
                difficulty: .expert,
                requiredProgress: 200,
                rewards: [.xp(1500), .chips(7500), .cardBack(named: "Marathon Elite")],
                actionType: .playHands
            ),

            // ═══════════════════════════════════════════════════════════
            // SPECIAL EVENT CHALLENGES
            // ═══════════════════════════════════════════════════════════
            ChallengeTemplate(
                id: "event_weekend_warrior",
                name: "Weekend Warrior",
                description: "Play during the weekend for 2x XP",
                iconName: "🎉",
                type: .event,
                category: .gameplay,
                difficulty: .medium,
                requiredProgress: 1,
                rewards: .weekendWarrior(),
                actionType: .playHands
            ),
            ChallengeTemplate(
                id: "event_weekend_blackjack",
                name: "Weekend Blackjack Fever",
                description: "Get 5 blackjacks this weekend",
                iconName: "🎊",
                type: .event,
                category: .performance,
                difficulty: .medium,
                requiredProgress: 5,
                rewards: [.xp(500), .chips(2500)],
                actionType: .blackjack
            ),

            // Additional dealer-specific daily challenges
            ChallengeTemplate(
                id: "daily_dealer_lucky_10",
                name: "Feeling Lucky",
                description: "Win 10 hands against Lucky",
                iconName: "🍀",
                type: .daily,
                category: .exploration,
                difficulty: .hard,
                requiredProgress: 10,
                rewards: [.xp(200)],
                actionType: .dealerSpecific,
                dealerName: "Lucky"
            ),
            ChallengeTemplate(
                id: "daily_dealer_zen_10",
                name: "Zen Master",
                description: "Win 10 hands against Zen",
                iconName: "☯️",
                type: .daily,
                category: .exploration,
                difficulty: .hard,
                requiredProgress: 10,
                rewards: [.xp(200)],
                actionType: .dealerSpecific,
                dealerName: "Zen"
            ),
            ChallengeTemplate(
                id: "daily_dealer_maverick_10",
                name: "Taming Maverick",
                description: "Win 10 hands against Maverick",
                iconName: "🎭",
                type: .daily,
                category: .exploration,
                difficulty: .hard,
                requiredProgress: 10,
                rewards: [.xp(200)],
                actionType: .dealerSpecific,
                dealerName: "Maverick"
            ),

            // More varied challenges
            ChallengeTemplate(
                id: "daily_win_10",
                name: "Ten in the Bag",
                description: "Win 10 hands today",
                iconName: "🎯",
                type: .daily,
                category: .performance,
                difficulty: .medium,
                requiredProgress: 10,
                rewards: [.xp(125)],
                actionType: .win
            ),
            ChallengeTemplate(
                id: "daily_play_30",
                name: "Dedicated Player",
                description: "Play 30 hands today",
                iconName: "💪",
                type: .daily,
                category: .gameplay,
                difficulty: .hard,
                requiredProgress: 30,
                rewards: [.xp(200)],
                actionType: .playHands
            ),
            ChallengeTemplate(
                id: "weekly_double_15",
                name: "Double Down Dynasty",
                description: "Win 15 double downs this week",
                iconName: "💸",
                type: .weekly,
                category: .mastery,
                difficulty: .hard,
                requiredProgress: 15,
                rewards: .hardWeekly(),
                actionType: .doubleDown
            ),
            ChallengeTemplate(
                id: "weekly_split_10",
                name: "Split Specialist",
                description: "Win 10 split hands this week",
                iconName: "✂️",
                type: .weekly,
                category: .mastery,
                difficulty: .medium,
                requiredProgress: 10,
                rewards: .mediumWeekly(),
                actionType: .split
            ),
        ]

        print("🎲 Initialised \(challengeTemplates.count) challenge templates")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔄 CHALLENGE REFRESH LOGIC                                         ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔄 CHECK FOR REFRESH                                             │
    // │                                                                  │
    // │ Business Logic: Check if challenges need to refresh             │
    // │ Called on: App launch and periodic checks                       │
    // └─────────────────────────────────────────────────────────────────┘

    func checkForRefresh() {
        if timeManager.needsDailyRefresh() {
            refreshDailyChallenges()
            timeManager.recordDailyRefresh()
        }

        if timeManager.needsWeeklyRefresh() {
            refreshWeeklyChallenges()
            timeManager.recordWeeklyRefresh()
        }

        // Check for weekend events
        if timeManager.isWeekend() && activeEventChallenges.isEmpty {
            refreshEventChallenges()
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔄 REFRESH DAILY CHALLENGES                                      │
    // │                                                                  │
    // │ Business Logic: Generate new daily challenges                   │
    // │ Strategy: Pick 3-5 random challenges from daily pool            │
    // │          Ensure variety (different categories/difficulties)     │
    // └─────────────────────────────────────────────────────────────────┘

    func refreshDailyChallenges() {
        print("🔄 Refreshing daily challenges...")

        // Get daily templates
        let dailyTemplates = challengeTemplates.filter { $0.type == .daily }

        // Pick 4 random challenges (1 easy, 2 medium, 1 hard)
        let easyTemplates = dailyTemplates.filter { $0.difficulty == .easy }
        let mediumTemplates = dailyTemplates.filter { $0.difficulty == .medium }
        let hardTemplates = dailyTemplates.filter { $0.difficulty == .hard }

        var selectedTemplates: [ChallengeTemplate] = []

        if let easy = easyTemplates.randomElement() {
            selectedTemplates.append(easy)
        }
        selectedTemplates.append(contentsOf: mediumTemplates.shuffled().prefix(2))
        if let hard = hardTemplates.randomElement() {
            selectedTemplates.append(hard)
        }

        // Generate challenges from templates
        let (start, end) = timeManager.getDailyChallengeWindow()
        activeDailyChallenges = selectedTemplates.map { $0.createChallenge(start: start, end: end) }

        saveChallenges()
        print("✅ Daily challenges refreshed (\(activeDailyChallenges.count) challenges)")
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔄 REFRESH WEEKLY CHALLENGES                                     │
    // │                                                                  │
    // │ Business Logic: Generate new weekly challenges                  │
    // │ Strategy: Pick 2 challenges from weekly pool                    │
    // └─────────────────────────────────────────────────────────────────┘

    func refreshWeeklyChallenges() {
        print("🔄 Refreshing weekly challenges...")

        // Get weekly templates
        let weeklyTemplates = challengeTemplates.filter { $0.type == .weekly }

        // Pick 2 random challenges
        let selectedTemplates = weeklyTemplates.shuffled().prefix(2)

        // Generate challenges from templates
        let (start, end) = timeManager.getWeeklyChallengeWindow()
        activeWeeklyChallenges = selectedTemplates.map { $0.createChallenge(start: start, end: end) }

        saveChallenges()
        print("✅ Weekly challenges refreshed (\(activeWeeklyChallenges.count) challenges)")
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎉 REFRESH EVENT CHALLENGES                                      │
    // │                                                                  │
    // │ Business Logic: Activate special event challenges               │
    // │ Strategy: Weekend events, holiday events, etc.                  │
    // └─────────────────────────────────────────────────────────────────┘

    func refreshEventChallenges() {
        print("🎉 Activating event challenges...")

        // Get event templates
        let eventTemplates = challengeTemplates.filter { $0.type == .event }

        // Weekend event
        if timeManager.isWeekend() {
            let (start, end) = timeManager.getEventChallengeWindow(durationDays: 2)
            activeEventChallenges = eventTemplates.prefix(2).map { $0.createChallenge(start: start, end: end) }
        }

        saveChallenges()
        print("✅ Event challenges activated (\(activeEventChallenges.count) challenges)")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 PROGRESS TRACKING                                               ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Update challenge progress after a hand
    func updateChallengeProgress(
        action: ChallengeActionType,
        context: ChallengeContext
    ) {
        // Update all active challenges
        var allChallenges = activeDailyChallenges + activeWeeklyChallenges + activeEventChallenges

        for index in allChallenges.indices {
            var challenge = allChallenges[index]

            // Skip completed or expired challenges
            guard !challenge.isCompleted && challenge.isActive else { continue }

            // Check if challenge matches this action
            guard challenge.actionType == action else { continue }

            // Check dealer-specific challenges
            if let requiredDealer = challenge.dealerName,
               requiredDealer != context.dealerName {
                continue
            }

            // Update progress based on action type
            let progressIncrement: Int
            switch action {
            case .win, .blackjack, .doubleDown, .split:
                progressIncrement = 1
            case .playHands:
                progressIncrement = 1
            case .winStreak:
                progressIncrement = max(context.currentStreak, challenge.currentProgress)
            case .highBet:
                progressIncrement = context.betAmount >= 1000 ? 1 : 0
            case .noBust:
                progressIncrement = !context.didBust ? 1 : 0
            case .profit:
                // Check at end of session
                progressIncrement = 0
            case .dealerSpecific:
                progressIncrement = 1
            }

            if challenge.updateProgress(challenge.currentProgress + progressIncrement) {
                // Challenge completed!
                print("🎉 Challenge completed: \(challenge.name)")
                completedChallengeQueue.append(challenge)
                distributeRewards(for: challenge)
            }

            allChallenges[index] = challenge
        }

        // Update active challenges
        activeDailyChallenges = allChallenges.filter { $0.type == .daily }
        activeWeeklyChallenges = allChallenges.filter { $0.type == .weekly }
        activeEventChallenges = allChallenges.filter { $0.type == .event }

        saveChallenges()
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎁 DISTRIBUTE REWARDS                                            │
    // │                                                                  │
    // │ Business Logic: Award rewards for completing a challenge        │
    // └─────────────────────────────────────────────────────────────────┘

    private func distributeRewards(for challenge: Challenge) {
        for reward in challenge.rewards {
            switch reward.type {
            case .xp:
                progressionManager.addExperience(reward.value, source: "Challenge: \(challenge.name)")
            case .chips:
                // Would need to integrate with GameViewModel to add chips
                print("💰 Rewarded \(reward.value) chips")
            case .cardBack, .tableFelt:
                // Would unlock in VisualSettingsManager
                print("🎨 Unlocked \(reward.displayText)")
            case .xpMultiplier, .achievementBoost, .streakProtection:
                // Would need temporary buff system
                print("✨ Activated \(reward.displayText)")
            }
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔥 DAILY LOGIN STREAK                                              ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    func recordDailyLogin() {
        dailyLoginStreak = timeManager.recordDailyLogin()
    }

    func updateDailyLoginStreak() {
        dailyLoginStreak = timeManager.getDailyLoginStreak()
    }

    func getDailyLoginStreak() -> Int {
        return dailyLoginStreak
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 💾 PERSISTENCE                                                     ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    private func saveChallenges() {
        do {
            let allChallenges = activeDailyChallenges + activeWeeklyChallenges + activeEventChallenges
            let encoder = JSONEncoder()
            let data = try encoder.encode(allChallenges)
            UserDefaults.standard.set(data, forKey: challengesKey)
            print("💾 Challenges saved")
        } catch {
            print("❌ Failed to save challenges: \(error)")
        }
    }

    private func loadChallenges() {
        guard let data = UserDefaults.standard.data(forKey: challengesKey) else {
            print("📂 No saved challenges - will generate new ones")
            return
        }

        do {
            let decoder = JSONDecoder()
            let loadedChallenges = try decoder.decode([Challenge].self, from: data)

            // Split by type
            activeDailyChallenges = loadedChallenges.filter { $0.type == .daily && !$0.isExpired }
            activeWeeklyChallenges = loadedChallenges.filter { $0.type == .weekly && !$0.isExpired }
            activeEventChallenges = loadedChallenges.filter { $0.type == .event && !$0.isExpired }

            print("📂 Challenges loaded (\(activeDailyChallenges.count) daily, \(activeWeeklyChallenges.count) weekly, \(activeEventChallenges.count) event)")
        } catch {
            print("❌ Failed to load challenges: \(error)")
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔍 QUERY METHODS                                                   ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    func getAllActiveChallenges() -> [Challenge] {
        return activeDailyChallenges + activeWeeklyChallenges + activeEventChallenges
    }

    func getCompletedChallenges() -> [Challenge] {
        return getAllActiveChallenges().filter { $0.isCompleted }
    }

    func getInProgressChallenges() -> [Challenge] {
        return getAllActiveChallenges().filter { $0.isInProgress }
    }

    func getNextCompletedChallenge() -> Challenge? {
        guard !completedChallengeQueue.isEmpty else { return nil }
        return completedChallengeQueue.removeFirst()
    }

    func clearCompletionQueue() {
        completedChallengeQueue.removeAll()
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🏭 CHALLENGE TEMPLATE                                                      ║
// ║                                                                            ║
// ║ Factory pattern for creating challenges from templates                    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct ChallengeTemplate {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let type: ChallengeType
    let category: ChallengeCategory
    let difficulty: ChallengeDifficulty
    let requiredProgress: Int
    let rewards: [ChallengeReward]
    let actionType: ChallengeActionType?
    let dealerName: String?

    init(
        id: String,
        name: String,
        description: String,
        iconName: String,
        type: ChallengeType,
        category: ChallengeCategory,
        difficulty: ChallengeDifficulty,
        requiredProgress: Int,
        rewards: [ChallengeReward],
        actionType: ChallengeActionType? = nil,
        dealerName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.type = type
        self.category = category
        self.difficulty = difficulty
        self.requiredProgress = requiredProgress
        self.rewards = rewards
        self.actionType = actionType
        self.dealerName = dealerName
    }

    func createChallenge(start: Date, end: Date) -> Challenge {
        return Challenge(
            id: id,
            name: name,
            description: description,
            iconName: iconName,
            type: type,
            category: category,
            difficulty: difficulty,
            requiredProgress: requiredProgress,
            startDate: start,
            endDate: end,
            rewards: rewards,
            dealerName: dealerName,
            actionType: actionType
        )
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📋 CHALLENGE CONTEXT                                                       ║
// ║                                                                            ║
// ║ Context passed from GameViewModel when updating challenge progress        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct ChallengeContext {
    let dealerName: String
    let betAmount: Int
    let currentStreak: Int
    let didBust: Bool
    let netProfit: Double
}
