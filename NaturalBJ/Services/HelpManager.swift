//
//  HelpManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6: Tutorial & Help System
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ HelpManager.swift                                                             ║
// ║                                                                               ║
// ║ Manages help content, search, and user preferences for help articles.        ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Players need fast access to blackjack rules and strategy                   ║
// ║ • Search must be accurate and relevant                                       ║
// ║ • Help system works offline (all content bundled)                            ║
// ║ • Recent and favourite topics improve discoverability                        ║
// ║                                                                               ║
// ║ DESIGN PATTERN:                                                               ║
// ║ • Singleton for global access                                                ║
// ║ • Observable for SwiftUI reactivity                                          ║
// ║ • Pre-populated content from HelpTopic static definitions                    ║
// ║                                                                               ║
// ║ SEARCH ALGORITHM:                                                             ║
// ║ • Full-text search across title, content, and keywords                       ║
// ║ • Relevance scoring based on match location and frequency                    ║
// ║ • Case-insensitive, handles partial matches                                  ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import Combine

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 📚 HELP MANAGER                                                           │
// │                                                                           │
// │ Singleton service managing help content and search.                      │
// │ Observable for SwiftUI views to react to state changes.                  │
// └──────────────────────────────────────────────────────────────────────────┘

class HelpManager: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏢 SINGLETON INSTANCE                                                 │
    // └──────────────────────────────────────────────────────────────────────┘

    static let shared = HelpManager()

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    /// All available help topics (pre-populated)
    @Published private(set) var allHelpTopics: [HelpTopic]

    /// Recently viewed topics (most recent first)
    @Published private(set) var recentTopics: [HelpTopic] = []

    /// User's favourite topics
    @Published private(set) var favouriteTopics: [HelpTopic] = []

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Recent topic IDs (for persistence)
    private var recentTopicIDs: [UUID] = []

    /// Favourite topic IDs (for persistence)
    private var favouriteTopicIDs: Set<UUID> = []

    /// Maximum recent topics to track
    private let maxRecentTopics = 10

    /// UserDefaults keys
    private let recentTopicsKey = "com.natural.blackjack.recentHelpTopics"
    private let favouriteTopicsKey = "com.natural.blackjack.favouriteHelpTopics"

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                        │
    // └──────────────────────────────────────────────────────────────────────┘

    private init() {
        // Load all help topics
        self.allHelpTopics = HelpTopic.allTopics

        // Load user preferences
        loadRecentTopics()
        loadFavouriteTopics()

        print("📚 HelpManager initialised with \(allHelpTopics.count) topics")
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 🔍 BROWSING & FILTERING                                                   ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📂 GET TOPICS BY CATEGORY                                             │
    // │                                                                       │
    // │ Filter topics by category for browsing.                              │
    // └──────────────────────────────────────────────────────────────────────┘

    func getHelpTopics(for category: HelpCategory) -> [HelpTopic] {
        return allHelpTopics.filter { $0.category == category }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📖 GET TOPIC BY ID                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    func getTopic(by id: UUID) -> HelpTopic? {
        return allHelpTopics.first { $0.id == id }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 GET RELATED TOPICS                                                 │
    // │                                                                       │
    // │ Find topics related to a given topic.                                │
    // │ Uses pre-defined relationships in HelpTopic.relatedTopics.           │
    // └──────────────────────────────────────────────────────────────────────┘

    func getRelatedTopics(for topic: HelpTopic) -> [HelpTopic] {
        return topic.relatedTopics.compactMap { id in
            getTopic(by: id)
        }
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 🔍 SEARCH                                                                 ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔍 SEARCH HELP                                                        │
    // │                                                                       │
    // │ Full-text search across all help content.                            │
    // │ Returns results sorted by relevance score.                           │
    // └──────────────────────────────────────────────────────────────────────┘

    func searchHelp(query: String) -> [HelpTopic] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty query returns no results
        guard !trimmedQuery.isEmpty else {
            return []
        }

        let lowercaseQuery = trimmedQuery.lowercased()
        print("🔍 Searching for: \"\(trimmedQuery)\"")

        // Score each topic by relevance
        let scoredTopics: [(topic: HelpTopic, score: Int)] = allHelpTopics.compactMap { topic in
            let score = calculateRelevanceScore(for: topic, query: lowercaseQuery)
            return score > 0 ? (topic, score) : nil
        }

        // Sort by score (highest first) and return topics
        let results = scoredTopics
            .sorted { $0.score > $1.score }
            .map { $0.topic }

        print("   Found \(results.count) results")
        return results
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎯 CALCULATE RELEVANCE SCORE                                          │
    // │                                                                       │
    // │ Score a topic based on how well it matches the search query.         │
    // │ Higher score = more relevant.                                        │
    // │                                                                       │
    // │ Scoring:                                                              │
    // │ • Title exact match: +100                                            │
    // │ • Title contains: +50                                                │
    // │ • Keyword exact match: +30                                           │
    // │ • Content contains: +10 per occurrence (max 50)                      │
    // └──────────────────────────────────────────────────────────────────────┘

    private func calculateRelevanceScore(for topic: HelpTopic, query: String) -> Int {
        var score = 0
        let lowercaseTitle = topic.title.lowercased()
        let lowercaseContent = topic.content.lowercased()

        // Title matches (highest priority)
        if lowercaseTitle == query {
            score += 100
        } else if lowercaseTitle.contains(query) {
            score += 50
        }

        // Keyword matches
        for keyword in topic.searchKeywords {
            if keyword.lowercased() == query {
                score += 30
                break
            } else if keyword.lowercased().contains(query) {
                score += 15
            }
        }

        // Content matches (count occurrences, cap at 5)
        let contentMatches = lowercaseContent.components(separatedBy: query).count - 1
        score += min(contentMatches * 10, 50)

        return score
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 📚 RECENT TOPICS                                                          ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📖 MARK AS RECENT                                                     │
    // │                                                                       │
    // │ Add topic to recent history when viewed.                             │
    // │ Most recent topics appear first.                                     │
    // └──────────────────────────────────────────────────────────────────────┘

    func markAsRecent(_ topic: HelpTopic) {
        // Remove if already in list
        recentTopicIDs.removeAll { $0 == topic.id }

        // Add to front
        recentTopicIDs.insert(topic.id, at: 0)

        // Limit to max recent topics
        if recentTopicIDs.count > maxRecentTopics {
            recentTopicIDs = Array(recentTopicIDs.prefix(maxRecentTopics))
        }

        // Update published array
        recentTopics = recentTopicIDs.compactMap { id in
            getTopic(by: id)
        }

        // Save to UserDefaults
        saveRecentTopics()

        print("📖 Marked as recent: \(topic.title)")
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🗑️ CLEAR RECENT TOPICS                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    func clearRecentTopics() {
        recentTopicIDs = []
        recentTopics = []
        saveRecentTopics()
        print("🗑️ Recent topics cleared")
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ ⭐ FAVOURITE TOPICS                                                       ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⭐ TOGGLE FAVOURITE                                                    │
    // │                                                                       │
    // │ Add or remove topic from favourites.                                 │
    // └──────────────────────────────────────────────────────────────────────┘

    func toggleFavourite(_ topic: HelpTopic) {
        if favouriteTopicIDs.contains(topic.id) {
            // Remove from favourites
            favouriteTopicIDs.remove(topic.id)
            print("⭐ Removed from favourites: \(topic.title)")
        } else {
            // Add to favourites
            favouriteTopicIDs.insert(topic.id)
            print("⭐ Added to favourites: \(topic.title)")
        }

        // Update published array
        favouriteTopics = favouriteTopicIDs.compactMap { id in
            getTopic(by: id)
        }

        // Save to UserDefaults
        saveFavouriteTopics()
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⭐ IS FAVOURITE?                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    func isFavourite(_ topic: HelpTopic) -> Bool {
        return favouriteTopicIDs.contains(topic.id)
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 💾 PERSISTENCE                                                            ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 💾 SAVE RECENT TOPICS                                                 │
    // └──────────────────────────────────────────────────────────────────────┘

    private func saveRecentTopics() {
        let uuidStrings = recentTopicIDs.map { $0.uuidString }
        UserDefaults.standard.set(uuidStrings, forKey: recentTopicsKey)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📂 LOAD RECENT TOPICS                                                 │
    // └──────────────────────────────────────────────────────────────────────┘

    private func loadRecentTopics() {
        guard let uuidStrings = UserDefaults.standard.array(forKey: recentTopicsKey) as? [String] else {
            return
        }

        recentTopicIDs = uuidStrings.compactMap { UUID(uuidString: $0) }

        // Populate recent topics array
        recentTopics = recentTopicIDs.compactMap { id in
            getTopic(by: id)
        }

        print("📂 Loaded \(recentTopics.count) recent topics")
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 💾 SAVE FAVOURITE TOPICS                                              │
    // └──────────────────────────────────────────────────────────────────────┘

    private func saveFavouriteTopics() {
        let uuidStrings = Array(favouriteTopicIDs).map { $0.uuidString }
        UserDefaults.standard.set(uuidStrings, forKey: favouriteTopicsKey)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📂 LOAD FAVOURITE TOPICS                                              │
    // └──────────────────────────────────────────────────────────────────────┘

    private func loadFavouriteTopics() {
        guard let uuidStrings = UserDefaults.standard.array(forKey: favouriteTopicsKey) as? [String] else {
            return
        }

        favouriteTopicIDs = Set(uuidStrings.compactMap { UUID(uuidString: $0) })

        // Populate favourite topics array
        favouriteTopics = favouriteTopicIDs.compactMap { id in
            getTopic(by: id)
        }

        print("📂 Loaded \(favouriteTopics.count) favourite topics")
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ Get topics by category:                                                       ║
// ║   let helpManager = HelpManager.shared                                        ║
// ║   let strategyTopics = helpManager.getHelpTopics(for: .strategy)              ║
// ║                                                                               ║
// ║ Search help:                                                                  ║
// ║   let results = helpManager.searchHelp(query: "hit")                          ║
// ║                                                                               ║
// ║ Mark topic as recently viewed:                                                ║
// ║   helpManager.markAsRecent(topic)                                             ║
// ║                                                                               ║
// ║ Toggle favourite:                                                             ║
// ║   helpManager.toggleFavourite(topic)                                          ║
// ║                                                                               ║
// ║ Check if topic is favourite:                                                  ║
// ║   let isFav = helpManager.isFavourite(topic)                                  ║
// ║                                                                               ║
// ║ Get related topics:                                                           ║
// ║   let related = helpManager.getRelatedTopics(for: topic)                      ║
// ║                                                                               ║
// ║ Access recent/favourite topics:                                               ║
// ║   let recent = helpManager.recentTopics                                       ║
// ║   let favourites = helpManager.favouriteTopics                                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
