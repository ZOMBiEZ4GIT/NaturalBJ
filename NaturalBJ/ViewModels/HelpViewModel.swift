//
//  HelpViewModel.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6: Tutorial & Help System
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ HelpViewModel.swift                                                           ║
// ║                                                                               ║
// ║ View model for help/knowledge base UI components.                            ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Players need fast, intuitive access to help content                        ║
// ║ • Search must be responsive and relevant                                     ║
// ║ • Categorised browsing helps users explore related topics                    ║
// ║ • Recent/favourite topics improve discoverability                            ║
// ║                                                                               ║
// ║ RESPONSIBILITIES:                                                             ║
// ║ • Manage search query and debounce for performance                           ║
// ║ • Filter topics by category                                                  ║
// ║ • Coordinate with HelpManager for data operations                            ║
// ║ • Provide computed properties for UI display                                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 📚 HELP VIEW MODEL                                                        │
// │                                                                           │
// │ ObservableObject for help UI state and search.                           │
// └──────────────────────────────────────────────────────────────────────────┘

class HelpViewModel: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 DEPENDENCIES                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Help manager (business logic)
    private let helpManager = HelpManager.shared

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Current search query
    @Published var searchQuery: String = ""

    /// Selected category filter (nil = all categories)
    @Published var selectedCategory: HelpCategory?

    /// Filtered topics based on search and category
    @Published private(set) var filteredTopics: [HelpTopic] = []

    /// Currently selected topic (for detail view)
    @Published var selectedTopic: HelpTopic?

    /// Is searching? (debounce indicator)
    @Published private(set) var isSearching: Bool = false

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    /// Debounce timer for search
    private let searchDebounceInterval: TimeInterval = 0.3

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                        │
    // └──────────────────────────────────────────────────────────────────────┘

    init() {
        // Set up search debouncing
        setupSearchDebounce()

        // Initial load - show all topics
        updateFilteredTopics()

        print("📚 HelpViewModel initialised")
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⏱️ SETUP SEARCH DEBOUNCE                                              │
    // │                                                                       │
    // │ Debounce search input to avoid searching on every keystroke.         │
    // │ Wait for user to pause typing before executing search.               │
    // └──────────────────────────────────────────────────────────────────────┘

    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .seconds(searchDebounceInterval), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)

        print("⏱️ Search debounce configured")
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 🔍 SEARCH                                                                 ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔍 PERFORM SEARCH                                                     │
    // │                                                                       │
    // │ Execute search and update filtered topics.                           │
    // │ Called automatically after debounce delay.                           │
    // └──────────────────────────────────────────────────────────────────────┘

    private func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        print("🔍 Performing search: \"\(trimmedQuery)\"")
        isSearching = true

        if trimmedQuery.isEmpty {
            // Empty search - show all topics (or filtered by category)
            updateFilteredTopics()
        } else {
            // Execute search
            let results = helpManager.searchHelp(query: trimmedQuery)

            // Apply category filter if selected
            if let category = selectedCategory {
                filteredTopics = results.filter { $0.category == category }
            } else {
                filteredTopics = results
            }
        }

        isSearching = false
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🗑️ CLEAR SEARCH                                                       │
    // │                                                                       │
    // │ Reset search query and show all topics.                              │
    // └──────────────────────────────────────────────────────────────────────┘

    func clearSearch() {
        print("🗑️ Clearing search")
        searchQuery = ""
        updateFilteredTopics()
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 📂 CATEGORY FILTERING                                                     ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📂 SELECT CATEGORY                                                    │
    // │                                                                       │
    // │ Filter topics by category.                                           │
    // └──────────────────────────────────────────────────────────────────────┘

    func selectCategory(_ category: HelpCategory?) {
        print("📂 Selected category: \(category?.displayName ?? "All")")
        selectedCategory = category
        updateFilteredTopics()
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔄 UPDATE FILTERED TOPICS                                             │
    // │                                                                       │
    // │ Refresh filtered topics based on current search and category.        │
    // └──────────────────────────────────────────────────────────────────────┘

    private func updateFilteredTopics() {
        if let category = selectedCategory {
            // Show topics for selected category
            filteredTopics = helpManager.getHelpTopics(for: category)
        } else {
            // Show all topics
            filteredTopics = helpManager.allHelpTopics
        }

        print("📊 Filtered topics updated: \(filteredTopics.count) topics")
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🗑️ RESET FILTERS                                                      │
    // │                                                                       │
    // │ Clear both search and category filter.                               │
    // └──────────────────────────────────────────────────────────────────────┘

    func resetFilters() {
        print("🗑️ Resetting all filters")
        searchQuery = ""
        selectedCategory = nil
        updateFilteredTopics()
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 📖 TOPIC SELECTION                                                        ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📖 SELECT TOPIC                                                       │
    // │                                                                       │
    // │ Open topic detail view and mark as recently viewed.                  │
    // └──────────────────────────────────────────────────────────────────────┘

    func selectTopic(_ topic: HelpTopic) {
        print("📖 Selected topic: \(topic.title)")
        selectedTopic = topic

        // Mark as recently viewed
        helpManager.markAsRecent(topic)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔙 CLOSE TOPIC                                                        │
    // │                                                                       │
    // │ Close detail view and return to topic list.                          │
    // └──────────────────────────────────────────────────────────────────────┘

    func closeTopic() {
        print("🔙 Closing topic detail")
        selectedTopic = nil
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ ⭐ FAVOURITES                                                             ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⭐ TOGGLE FAVOURITE                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    func toggleFavourite(_ topic: HelpTopic) {
        helpManager.toggleFavourite(topic)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⭐ IS FAVOURITE?                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    func isFavourite(_ topic: HelpTopic) -> Bool {
        return helpManager.isFavourite(topic)
    }

    // ╔══════════════════════════════════════════════════════════════════════════╗
    // ║ 📊 COMPUTED PROPERTIES                                                    ║
    // ╚══════════════════════════════════════════════════════════════════════════╝

    /// Are there search results?
    var hasSearchResults: Bool {
        return !filteredTopics.isEmpty
    }

    /// Is search query active?
    var hasActiveSearch: Bool {
        return !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Recent topics from manager
    var recentTopics: [HelpTopic] {
        return helpManager.recentTopics
    }

    /// Favourite topics from manager
    var favouriteTopics: [HelpTopic] {
        return helpManager.favouriteTopics
    }

    /// Has recent topics?
    var hasRecentTopics: Bool {
        return !recentTopics.isEmpty
    }

    /// Has favourite topics?
    var hasFavouriteTopics: Bool {
        return !favouriteTopics.isEmpty
    }

    /// All categories (for category picker)
    var allCategories: [HelpCategory] {
        return HelpCategory.allCases
    }

    /// Topic count for current filter
    var topicCount: Int {
        return filteredTopics.count
    }

    /// Search results text (e.g., "12 results for 'hit'")
    var searchResultsText: String {
        guard hasActiveSearch else { return "" }

        let count = filteredTopics.count
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        if count == 0 {
            return "No results for '\(query)'"
        } else if count == 1 {
            return "1 result for '\(query)'"
        } else {
            return "\(count) results for '\(query)'"
        }
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In HelpView:                                                                  ║
// ║   @StateObject var viewModel = HelpViewModel()                                ║
// ║                                                                               ║
// ║   var body: some View {                                                       ║
// ║       NavigationView {                                                        ║
// ║           VStack {                                                             ║
// ║               // Search bar                                                   ║
// ║               TextField("Search help", text: $viewModel.searchQuery)          ║
// ║                                                                               ║
// ║               // Category tabs                                                ║
// ║               ScrollView(.horizontal) {                                       ║
// ║                   HStack {                                                     ║
// ║                       ForEach(viewModel.allCategories, id: \.self) { cat in  ║
// ║                           Button(cat.displayName) {                           ║
// ║                               viewModel.selectCategory(cat)                   ║
// ║                           }                                                    ║
// ║                       }                                                        ║
// ║                   }                                                            ║
// ║               }                                                                ║
// ║                                                                               ║
// ║               // Topic list                                                   ║
// ║               List(viewModel.filteredTopics) { topic in                       ║
// ║                   Button(action: {                                            ║
// ║                       viewModel.selectTopic(topic)                            ║
// ║                   }) {                                                         ║
// ║                       HStack {                                                 ║
// ║                           Text(topic.title)                                   ║
// ║                           Spacer()                                             ║
// ║                           if viewModel.isFavourite(topic) {                   ║
// ║                               Image(systemName: "star.fill")                  ║
// ║                           }                                                    ║
// ║                       }                                                        ║
// ║                   }                                                            ║
// ║               }                                                                ║
// ║           }                                                                    ║
// ║           .navigationTitle("Help")                                            ║
// ║       }                                                                        ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
