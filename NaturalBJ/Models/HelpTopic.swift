//
//  HelpTopic.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6: Tutorial & Help System
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ HelpTopic.swift                                                               ║
// ║                                                                               ║
// ║ Defines the structure for help articles and knowledge base content.          ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Players need quick access to blackjack rules and strategy                  ║
// ║ • Help content should be searchable and well-organised                       ║
// ║ • Topics should link to related content for deeper learning                  ║
// ║ • Content must be accurate, concise, and beginner-friendly                   ║
// ║                                                                               ║
// ║ CONTENT PHILOSOPHY:                                                           ║
// ║ • "Just enough" - Provide what's needed without overwhelming                 ║
// ║ • Scannable - Use bullet points, bold text, and clear headings               ║
// ║ • Actionable - Every topic should help players make better decisions         ║
// ║ • Offline-first - All content bundled with app (no internet required)        ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 📚 HELP TOPIC                                                             │
// │                                                                           │
// │ Represents a single help article in the knowledge base.                  │
// │ Supports Markdown formatting for rich content.                           │
// └──────────────────────────────────────────────────────────────────────────┘

struct HelpTopic: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let category: HelpCategory
    let title: String
    let content: String  // Markdown-formatted text
    let relatedTopics: [UUID]  // IDs of related topics
    let searchKeywords: [String]  // Additional keywords for search

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISERS                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    init(
        id: UUID = UUID(),
        category: HelpCategory,
        title: String,
        content: String,
        relatedTopics: [UUID] = [],
        searchKeywords: [String] = []
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.content = content
        self.relatedTopics = relatedTopics
        self.searchKeywords = searchKeywords
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔨 HASHABLE CONFORMANCE                                               │
    // └──────────────────────────────────────────────────────────────────────┘

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 📂 HELP CATEGORY                                                          │
// │                                                                           │
// │ Top-level organisation of help content.                                  │
// │ Users can browse by category or search across all categories.            │
// └──────────────────────────────────────────────────────────────────────────┘

enum HelpCategory: String, Codable, CaseIterable {
    case rules        // Basic blackjack rules
    case strategy     // When to hit, stand, double, split
    case dealers      // Dealer personalities and rules
    case statistics   // Understanding stats and metrics
    case settings     // App customisation
    case terminology  // Glossary of blackjack terms

    /// Human-readable category name
    var displayName: String {
        switch self {
        case .rules: return "Rules"
        case .strategy: return "Strategy"
        case .dealers: return "Dealers"
        case .statistics: return "Statistics"
        case .settings: return "Settings"
        case .terminology: return "Terminology"
        }
    }

    /// Category icon (SF Symbol)
    var iconName: String {
        switch self {
        case .rules: return "book.fill"
        case .strategy: return "brain.head.profile"
        case .dealers: return "person.3.fill"
        case .statistics: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        case .terminology: return "character.book.closed.fill"
        }
    }

    /// Short description of category
    var description: String {
        switch self {
        case .rules: return "How to play blackjack"
        case .strategy: return "Tips to improve your game"
        case .dealers: return "Learn about each dealer"
        case .statistics: return "Track your performance"
        case .settings: return "Customise the app"
        case .terminology: return "Blackjack glossary"
        }
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 PRE-DEFINED HELP TOPICS                                                    ║
// ║                                                                               ║
// ║ Core help content for Natural blackjack app.                                 ║
// ║ HelpManager will load these topics on initialisation.                        ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

extension HelpTopic {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📋 RULES CATEGORY                                                     │
    // └──────────────────────────────────────────────────────────────────────┘

    static let basicRules = HelpTopic(
        category: .rules,
        title: "Basic Blackjack Rules",
        content: """
        **Objective:** Get a hand value closer to 21 than the dealer without going over.

        **Card Values:**
        • Number cards (2-10): Face value
        • Face cards (J, Q, K): 10 points
        • Ace: 1 or 11 (whichever is better)

        **Gameplay:**
        1. Place your bet
        2. Receive 2 cards face-up
        3. Dealer gets 1 face-up, 1 face-down
        4. Choose your action (Hit, Stand, Double, Split)
        5. Dealer reveals hole card and plays
        6. Compare hands - closest to 21 wins!

        **Important:** Going over 21 is a "bust" - you lose immediately.
        """,
        searchKeywords: ["how to play", "basics", "beginner", "start", "learn"]
    )

    static let cardValues = HelpTopic(
        category: .rules,
        title: "Understanding Card Values",
        content: """
        **Number Cards (2-10):**
        Worth their face value. A 7 is worth 7 points.

        **Face Cards (Jack, Queen, King):**
        All worth 10 points each.

        **Aces - The Flexible Card:**
        • Worth 11 by default
        • Automatically becomes 1 if 11 would bust you
        • A hand with an Ace counting as 11 is "soft"
        • A hand with an Ace counting as 1 is "hard"

        **Example:**
        Ace + 6 = Soft 17 (Ace counts as 11)
        Ace + 6 + 9 = Hard 16 (Ace must count as 1)
        """,
        searchKeywords: ["ace", "values", "soft", "hard", "face card"]
    )

    static let winningConditions = HelpTopic(
        category: .rules,
        title: "Winning, Losing & Push",
        content: """
        **You Win (1:1 payout) when:**
        • Your total beats the dealer's total
        • Dealer busts and you don't

        **Blackjack (3:2 payout) when:**
        • You have Ace + 10-value card (21 in 2 cards)
        • This beats a regular 21
        • Note: Some dealers pay 6:5 instead

        **Push (bet returned) when:**
        • You tie with the dealer
        • Both have same total
        • Both have blackjack

        **You Lose when:**
        • You bust (go over 21)
        • Dealer's total beats yours
        • Dealer has blackjack, you don't
        """,
        searchKeywords: ["win", "lose", "payout", "blackjack", "push", "tie"]
    )

    static let dealerRules = HelpTopic(
        category: .rules,
        title: "How the Dealer Plays",
        content: """
        **Dealer Has No Choices:**
        The dealer must follow fixed rules with no decisions.

        **Standard Rules:**
        • Must hit on 16 or less
        • Must stand on 17 or more
        • No doubling or splitting

        **Soft 17 Variation:**
        • **Stand on Soft 17** (player-friendly): Dealer stands on Ace-6
        • **Hit on Soft 17** (house-friendly): Dealer hits on Ace-6

        **Hole Card:**
        The dealer's face-down card is revealed only after all players finish their turns.

        **Dealer Advantage:**
        If you bust, you lose immediately - even if the dealer later busts too!
        """,
        searchKeywords: ["dealer", "how dealer plays", "soft 17", "hole card", "dealer rules"]
    )

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎯 STRATEGY CATEGORY                                                  │
    // └──────────────────────────────────────────────────────────────────────┘

    static let basicStrategy = HelpTopic(
        category: .strategy,
        title: "Basic Strategy Overview",
        content: """
        **What is Basic Strategy?**
        The mathematically optimal way to play every hand based on your cards and the dealer's upcard.

        **Why It Matters:**
        • Reduces house edge to ~0.5%
        • Without strategy, house edge is ~2-3%
        • Can save thousands of dollars long-term

        **Core Principles:**
        1. **Always assume** dealer's hole card is 10
        2. **Never take insurance** (it's a sucker bet)
        3. **Hit on 12-16** when dealer shows 7 or higher
        4. **Stand on 17+** (never hit hard 17)
        5. **Double on 11** when dealer shows 2-10
        6. **Split Aces and 8s** always
        7. **Never split 10s or 5s**

        **Remember:** Basic strategy minimises losses, it doesn't guarantee wins!
        """,
        searchKeywords: ["strategy", "basic strategy", "optimal play", "house edge", "mathematics"]
    )

    static let whenToHit = HelpTopic(
        category: .strategy,
        title: "When to Hit",
        content: """
        **Always Hit:**
        • Hard 5-11 (impossible to bust)
        • Hard 12 vs dealer 2-3
        • Hard 12-16 vs dealer 7-Ace
        • Soft 13-17 (Ace + 2-6)

        **Why Hit Hard 12-16 vs High Cards?**
        Dealer showing 7+ likely has 17+. You need to improve or you'll lose anyway.

        **Safe Hitting:**
        Below hard 12, you cannot bust on one card. Hit aggressively!

        **Risky Hitting:**
        Hard 12-16: High bust risk, but sometimes necessary when dealer is strong.

        **Never Hit:**
        • Hard 17+ (too risky)
        • Soft 19+ (already excellent)
        • After doubling down
        """,
        searchKeywords: ["hit", "when to hit", "hitting strategy", "hard hand", "soft hand"]
    )

    static let whenToStand = HelpTopic(
        category: .strategy,
        title: "When to Stand",
        content: """
        **Always Stand:**
        • Hard 17 or higher
        • Soft 19 or higher (A-8, A-9)
        • Hard 13-16 vs dealer 2-6

        **Why Stand on 13-16 vs Low Cards?**
        Dealer is likely to bust when showing 2-6. Let them take the risk!

        **Dealer Bust Probabilities:**
        • Dealer showing 6: ~42% bust chance
        • Dealer showing 5: ~41% bust chance
        • Dealer showing 4: ~40% bust chance

        **Golden Rule:**
        If dealer shows 2-6, they're in "bust territory". Stand pat and let them bust!

        **Never Stand:**
        • Hard 11 or less (take another card!)
        • Soft hands below 19 (can't bust, keep improving)
        """,
        searchKeywords: ["stand", "when to stand", "standing strategy", "dealer bust", "weak dealer"]
    )

    static let whenToDouble = HelpTopic(
        category: .strategy,
        title: "When to Double Down",
        content: """
        **What is Doubling Down?**
        Double your bet, receive exactly one more card, then automatically stand.

        **Best Doubling Situations:**
        • **Hard 11 vs dealer 2-10** (best opportunity!)
        • **Hard 10 vs dealer 2-9**
        • **Hard 9 vs dealer 3-6**
        • **Soft 16-18 vs dealer 4-6** (advanced)

        **Why Double on 11?**
        40% chance to get a 10-value card = instant 21!

        **Risk vs Reward:**
        Doubling locks you into one card. Only do it when odds favour a strong hand.

        **Dealer Rule Variations:**
        • Some dealers restrict doubles to 9/10/11 only
        • Most allow doubling after split
        • Lucky offers free doubles!

        **Common Mistake:**
        Don't double on 12+ (too risky) or against dealer 10/Ace (dealer too strong).
        """,
        searchKeywords: ["double", "double down", "doubling strategy", "when to double", "hard 11"]
    )

    static let whenToSplit = HelpTopic(
        category: .strategy,
        title: "When to Split Pairs",
        content: """
        **What is Splitting?**
        When you have a pair, split them into two separate hands. Each hand gets a second card and you play them individually.

        **Always Split:**
        • **Aces** - Two chances at blackjack!
        • **8s** - Escape from hard 16

        **Never Split:**
        • **10s** - You already have 20!
        • **5s** - Better to double on 10
        • **4s** - Two weak hands, keep one mediocre hand

        **Sometimes Split:**
        • **2s, 3s, 7s** vs dealer 2-7
        • **6s** vs dealer 2-6
        • **9s** vs dealer 2-6, 8-9 (stand vs 7)

        **Split Aces Rule:**
        Usually you get only ONE card per Ace after splitting (house rule).

        **Cost:**
        Splitting doubles your bet! Make sure you can afford it.
        """,
        searchKeywords: ["split", "splitting", "when to split", "pair", "aces", "eights"]
    )

    static let whenToSurrender = HelpTopic(
        category: .strategy,
        title: "When to Surrender",
        content: """
        **What is Surrender?**
        Give up your hand and get half your bet back. Only available as first action on initial hand.

        **When to Surrender:**
        • **Hard 16 vs dealer 9, 10, or Ace**
        • **Hard 15 vs dealer 10**
        • Pair of 8s vs dealer 10 (some players)

        **Why Surrender?**
        These are terrible situations where you're likely to lose anyway. Better to save half than lose it all!

        **Types:**
        • **Late Surrender** (common): After dealer checks for blackjack
        • **Early Surrender** (rare): Before dealer checks - much better for player!

        **Availability:**
        Not all dealers offer surrender:
        • Lucky: Late surrender
        • Zen: Early surrender
        • Others: No surrender

        **Use Sparingly:**
        Surrender is mathematically correct in only a few situations. Don't overuse it!
        """,
        searchKeywords: ["surrender", "when to surrender", "give up", "forfeit", "hard 16"]
    )

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 👥 DEALERS CATEGORY                                                   │
    // └──────────────────────────────────────────────────────────────────────┘

    static let dealerPersonalities = HelpTopic(
        category: .dealers,
        title: "Dealer Personalities",
        content: """
        Natural features six unique dealers, each with different rule variations and personalities:

        **Ruby** 💎 - The Classic
        Standard Vegas rules. Best for beginners!

        **Shark** 🦈 - The Ruthless
        Tougher rules: Hits soft 17, 6:5 blackjack, restricted doubles.

        **Lucky** 🍀 - The Generous
        Player-friendly bonuses: Free doubles, free splits, surrender.

        **Zen** 🧘 - The Balanced
        Fair rules with early surrender option.

        **Blitz** ⚡ - The High Roller
        High stakes, high rewards. 4-deck shoe.

        **Maverick** 🎲 - The Wild Card
        Rules change randomly every shoe! Unpredictable and exciting.

        Tap any dealer to see their full rule set before playing!
        """,
        searchKeywords: ["dealers", "ruby", "shark", "lucky", "zen", "blitz", "maverick", "personalities"]
    )

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📊 STATISTICS CATEGORY                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    static let understandingStats = HelpTopic(
        category: .statistics,
        title: "Understanding Your Statistics",
        content: """
        **Session Stats:**
        Track your current playing session from first bet to when you switch dealers or close the app.

        **Key Metrics:**
        • **Win Rate**: Percentage of hands won
        • **Hands Played**: Total number of hands
        • **Biggest Win**: Largest single-hand profit
        • **Current Streak**: Consecutive wins/losses
        • **Net Profit**: Total winnings minus losses

        **Dealer Comparison:**
        Compare your performance across different dealers to find which rules work best for you!

        **Action Breakdown:**
        See how often you hit, stand, double, split, or surrender. Useful for refining strategy!

        **Bankroll Chart:**
        Visual graph of your bankroll over time within a session.

        Swipe up from the game screen to access stats anytime!
        """,
        searchKeywords: ["statistics", "stats", "win rate", "metrics", "performance", "tracking"]
    )

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 SETTINGS CATEGORY                                                  │
    // └──────────────────────────────────────────────────────────────────────┘

    static let customisation = HelpTopic(
        category: .settings,
        title: "Customising Your Experience",
        content: """
        **Visual Settings:**
        • **Table Felt Colour**: Classic green, midnight blue, burgundy, charcoal
        • **Card Back Design**: Several designs to choose from
        • **Theme**: Light or dark mode support

        **Audio Settings:**
        • **Sound Effects**: Card dealing, chip sounds, win/loss
        • **Master Volume**: Control overall volume
        • **Mute**: Quickly silence all sounds

        **Haptic Feedback:**
        • **Vibrations**: Feel card deals and wins
        • **Intensity**: Light, medium, or strong

        **Gameplay:**
        • **Tutorial Hints**: Enable/disable contextual hints
        • **Replay Tutorial**: Start tutorial from beginning
        • **Reset Statistics**: Clear all saved stats

        Access settings via the gear icon in the top-right corner of the game screen!
        """,
        searchKeywords: ["settings", "customise", "customize", "options", "preferences", "theme", "sound"]
    )

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📖 TERMINOLOGY CATEGORY                                               │
    // └──────────────────────────────────────────────────────────────────────┘

    static let glossaryHit = HelpTopic(
        category: .terminology,
        title: "Hit",
        content: """
        **Hit**: Request another card from the dealer.

        You can hit as many times as you want until you stand or bust.

        **Example:**
        You have 14, you tap "Hit", dealer gives you a 5. Now you have 19.
        """,
        searchKeywords: ["hit", "take card", "another card", "draw"]
    )

    static let glossaryStand = HelpTopic(
        category: .terminology,
        title: "Stand",
        content: """
        **Stand**: Keep your current hand and end your turn.

        The dealer will then play their hand.

        **Example:**
        You have 18, you tap "Stand", it's now the dealer's turn.
        """,
        searchKeywords: ["stand", "stay", "hold", "keep hand"]
    )

    static let glossaryBust = HelpTopic(
        category: .terminology,
        title: "Bust",
        content: """
        **Bust**: When a hand's total exceeds 21.

        **For Players:** Instant loss, even if dealer later busts
        **For Dealers:** All remaining players win

        **Example:**
        You have 18, hit and get a 7 = 25. You bust and lose immediately.
        """,
        searchKeywords: ["bust", "over 21", "lose", "exceed"]
    )

    static let glossaryPush = HelpTopic(
        category: .terminology,
        title: "Push",
        content: """
        **Push**: A tie between player and dealer.

        Your bet is returned - you neither win nor lose.

        **Example:**
        You have 19, dealer has 19 = Push. Your bet comes back.
        """,
        searchKeywords: ["push", "tie", "draw", "same total"]
    )

    static let glossaryBlackjack = HelpTopic(
        category: .terminology,
        title: "Blackjack / Natural",
        content: """
        **Blackjack** (also called **Natural**): Ace + 10-value card in your first two cards.

        **Payout:** Usually 3:2 (some dealers pay 6:5)
        **Beats:** Regular 21 (three or more cards)
        **Best Hand:** In the entire game!

        **Example:**
        Ace + King = Blackjack = Instant win (unless dealer also has blackjack)
        """,
        searchKeywords: ["blackjack", "natural", "21", "ace ten", "best hand"]
    )

    static let glossarySoft = HelpTopic(
        category: .terminology,
        title: "Soft Hand",
        content: """
        **Soft Hand**: A hand containing an Ace counted as 11.

        **Advantage:** Cannot bust on one card!
        **Example:** Ace-6 = Soft 17

        If you hit soft 17 and get a 9:
        • Ace now counts as 1
        • New total: 1+6+9 = 16 (now "hard")

        Soft hands are safer to hit because the Ace is flexible!
        """,
        searchKeywords: ["soft", "soft hand", "ace eleven", "flexible"]
    )

    static let glossaryHard = HelpTopic(
        category: .terminology,
        title: "Hard Hand",
        content: """
        **Hard Hand**: A hand with no Ace, or an Ace counting as 1.

        **Risk:** Can bust on next card
        **Example:** 10-6 = Hard 16, or Ace-5-10 = Hard 16

        Hard hands are riskier to hit because you can't adjust the Ace value!
        """,
        searchKeywords: ["hard", "hard hand", "no ace", "risky"]
    )

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📚 ALL TOPICS COLLECTION                                              │
    // └──────────────────────────────────────────────────────────────────────┘

    static let allTopics: [HelpTopic] = [
        // Rules
        basicRules,
        cardValues,
        winningConditions,
        dealerRules,

        // Strategy
        basicStrategy,
        whenToHit,
        whenToStand,
        whenToDouble,
        whenToSplit,
        whenToSurrender,

        // Dealers
        dealerPersonalities,

        // Statistics
        understandingStats,

        // Settings
        customisation,

        // Terminology
        glossaryHit,
        glossaryStand,
        glossaryBust,
        glossaryPush,
        glossaryBlackjack,
        glossarySoft,
        glossaryHard
    ]
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ Get all topics:                                                               ║
// ║   let topics = HelpTopic.allTopics                                            ║
// ║                                                                               ║
// ║ Filter by category:                                                           ║
// ║   let strategyTopics = HelpTopic.allTopics.filter {                          ║
// ║       $0.category == .strategy                                                ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ Search topics:                                                                ║
// ║   let searchResults = HelpTopic.allTopics.filter {                           ║
// ║       $0.title.lowercased().contains("hit") ||                               ║
// ║       $0.content.lowercased().contains("hit") ||                             ║
// ║       $0.searchKeywords.contains("hit")                                       ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
