//
//  HelpView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6.5: Tutorial & Help System - View Layer
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ HelpView.swift                                                                ║
// ║                                                                               ║
// ║ Main help/knowledge base browser with search and categories.                 ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Players need quick access to rules and strategy                            ║
// ║ • Search must be fast and relevant                                           ║
// ║ • Categorised browsing helps discovery                                       ║
// ║ • Recent/favourite topics improve efficiency                                 ║
// ║                                                                               ║
// ║ UX PRINCIPLES:                                                                ║
// ║ • Search-first: Prominent search bar at top                                  ║
// ║ • Category tabs: Easy filtering by topic type                                ║
// ║ • Quick access: Recent and favourite sections                                ║
// ║ • Clean layout: iOS-native design patterns                                   ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 📚 HELP VIEW                                                              │
// │                                                                           │
// │ Main help browser with search, categories, and topic list.               │
// └──────────────────────────────────────────────────────────────────────────┘

struct HelpView: View {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 DEPENDENCIES                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    @StateObject private var viewModel = HelpViewModel()
    @Environment(\.dismiss) private var dismiss

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                               │
    // └──────────────────────────────────────────────────────────────────────┘

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Category tabs
                categoryTabs

                // Content
                contentArea
            }
            .background(Color.appBackground)
            .navigationTitle("Help & Rules")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.info)
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔍 SEARCH BAR                                                         │
    // └──────────────────────────────────────────────────────────────────────┘

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.mediumGrey)

            TextField("Search help...", text: $viewModel.searchQuery)
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if viewModel.hasActiveSearch {
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.mediumGrey)
                }
            }
        }
        .padding(12)
        .background(Color.darkGrey)
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📂 CATEGORY TABS                                                      │
    // └──────────────────────────────────────────────────────────────────────┘

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" category
                CategoryTab(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectCategory(nil)
                }

                // Category tabs
                ForEach(viewModel.allCategories, id: \.self) { category in
                    CategoryTab(
                        title: category.displayName,
                        icon: category.iconName,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📄 CONTENT AREA                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.hasActiveSearch {
            // Search results
            searchResults
        } else {
            // Browse mode
            browseContent
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔍 SEARCH RESULTS                                                     │
    // └──────────────────────────────────────────────────────────────────────┘

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Results count
            if !viewModel.searchResultsText.isEmpty {
                Text(viewModel.searchResultsText)
                    .font(.caption)
                    .foregroundColor(.mediumGrey)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }

            // Results list
            if viewModel.hasSearchResults {
                topicList
            } else {
                emptyState(message: "No results found")
            }
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📖 BROWSE CONTENT                                                     │
    // └──────────────────────────────────────────────────────────────────────┘

    private var browseContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recent topics
                if viewModel.hasRecentTopics {
                    sectionHeader(title: "Recent", icon: "clock.fill")
                    ForEach(viewModel.recentTopics.prefix(5)) { topic in
                        topicRow(topic)
                    }
                    Divider()
                        .padding(.horizontal, 16)
                }

                // Favourite topics
                if viewModel.hasFavouriteTopics {
                    sectionHeader(title: "Favourites", icon: "star.fill")
                    ForEach(viewModel.favouriteTopics) { topic in
                        topicRow(topic)
                    }
                    Divider()
                        .padding(.horizontal, 16)
                }

                // All topics
                sectionHeader(
                    title: viewModel.selectedCategory?.displayName ?? "All Topics",
                    icon: viewModel.selectedCategory?.iconName ?? "book.fill"
                )
                ForEach(viewModel.filteredTopics) { topic in
                    topicRow(topic)
                }
            }
            .padding(.vertical, 12)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📋 TOPIC LIST                                                         │
    // └──────────────────────────────────────────────────────────────────────┘

    private var topicList: some View {
        List(viewModel.filteredTopics) { topic in
            topicRow(topic)
                .listRowBackground(Color.appBackground)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📄 TOPIC ROW                                                          │
    // └──────────────────────────────────────────────────────────────────────┘

    @ViewBuilder
    private func topicRow(_ topic: HelpTopic) -> some View {
        Button(action: {
            viewModel.selectTopic(topic)
        }) {
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: topic.category.iconName)
                    .font(.title3)
                    .foregroundColor(.info)
                    .frame(width: 32)

                // Title
                Text(topic.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                // Favourite indicator
                if viewModel.isFavourite(topic) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.warning)
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.mediumGrey)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.darkGrey)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📑 SECTION HEADER                                                     │
    // └──────────────────────────────────────────────────────────────────────┘

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.info)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🚫 EMPTY STATE                                                        │
    // └──────────────────────────────────────────────────────────────────────┘

    private func emptyState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.mediumGrey)

            Text(message)
                .font(.body)
                .foregroundColor(.mediumGrey)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 🏷️ CATEGORY TAB COMPONENT                                                │
// └──────────────────────────────────────────────────────────────────────────┘

struct CategoryTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.info : Color.darkGrey)
            .foregroundColor(isSelected ? .white : .mediumGrey)
            .cornerRadius(8)
        }
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

#Preview("Help View") {
    HelpView()
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In GameView or SettingsView:                                                  ║
// ║   @State private var showHelp = false                                         ║
// ║                                                                               ║
// ║   Button("Help") {                                                            ║
// ║       showHelp = true                                                         ║
// ║   }                                                                            ║
// ║   .sheet(isPresented: $showHelp) {                                            ║
// ║       HelpView()                                                              ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
