//
//  HelpTopicDetailView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6.5: Tutorial & Help System - View Layer
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ HelpTopicDetailView.swift                                                     ║
// ║                                                                               ║
// ║ Full-screen article view for help topics with markdown rendering.            ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Present help content in readable, focused format                           ║
// ║ • Markdown formatting for structure and emphasis                             ║
// ║ • Related topics for continued learning                                      ║
// ║ • Favourite toggle for quick access later                                    ║
// ║                                                                               ║
// ║ UX PRINCIPLES:                                                                ║
// ║ • Readable: Good typography, spacing, contrast                               ║
// ║ • Scannable: Bold headings, bullet points                                    ║
// ║ • Actionable: Can favourite, share, explore related                          ║
// ║ • Navigable: Back button, related topics                                     ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 📖 HELP TOPIC DETAIL VIEW                                                 │
// │                                                                           │
// │ Full article view with markdown content, favourites, and related topics. │
// └──────────────────────────────────────────────────────────────────────────┘

struct HelpTopicDetailView: View {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 PROPERTIES                                                         │
    // └──────────────────────────────────────────────────────────────────────┘

    let topic: HelpTopic
    @ObservedObject private var helpManager = HelpManager.shared
    @Environment(\.dismiss) private var dismiss

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 STATE                                                              │
    // └──────────────────────────────────────────────────────────────────────┘

    @State private var isFavourite = false

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                               │
    // └──────────────────────────────────────────────────────────────────────┘

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                header

                // Content (markdown-formatted)
                content

                // Related topics
                if !relatedTopics.isEmpty {
                    relatedSection
                }
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favouriteButton
            }
        }
        .onAppear {
            isFavourite = helpManager.isFavourite(topic)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📋 HEADER                                                             │
    // └──────────────────────────────────────────────────────────────────────┘

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            HStack(spacing: 6) {
                Image(systemName: topic.category.iconName)
                    .font(.caption)

                Text(topic.category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.darkGrey)
            .foregroundColor(.info)
            .cornerRadius(6)

            // Title
            Text(topic.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📄 CONTENT                                                            │
    // │                                                                       │
    // │ Renders markdown-formatted content.                                  │
    // │ Note: Using AttributedString for basic markdown support.             │
    // └──────────────────────────────────────────────────────────────────────┘

    private var content: some View {
        Text(markdownToAttributedString(topic.content))
            .font(.body)
            .foregroundColor(.white)
            .lineSpacing(6)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 RELATED SECTION                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(.info)

                Text("Related Topics")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            // Related topic cards
            ForEach(relatedTopics) { relatedTopic in
                NavigationLink(destination: HelpTopicDetailView(topic: relatedTopic)) {
                    relatedTopicCard(relatedTopic)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 12)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎴 RELATED TOPIC CARD                                                 │
    // └──────────────────────────────────────────────────────────────────────┘

    private func relatedTopicCard(_ relatedTopic: HelpTopic) -> some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: relatedTopic.category.iconName)
                .font(.title3)
                .foregroundColor(.info)
                .frame(width: 40)

            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text(relatedTopic.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Text(relatedTopic.category.displayName)
                    .font(.caption)
                    .foregroundColor(.mediumGrey)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.mediumGrey)
        }
        .padding(14)
        .background(Color.darkGrey)
        .cornerRadius(10)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ⭐ FAVOURITE BUTTON                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    private var favouriteButton: some View {
        Button(action: {
            helpManager.toggleFavourite(topic)
            isFavourite.toggle()
        }) {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .foregroundColor(isFavourite ? .warning : .mediumGrey)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 COMPUTED PROPERTIES                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    private var relatedTopics: [HelpTopic] {
        return helpManager.getRelatedTopics(for: topic)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📝 MARKDOWN TO ATTRIBUTED STRING                                      │
    // │                                                                       │
    // │ Convert markdown-formatted text to AttributedString.                 │
    // │ SwiftUI supports markdown in Text views natively.                    │
    // └──────────────────────────────────────────────────────────────────────┘

    private func markdownToAttributedString(_ markdown: String) -> AttributedString {
        do {
            return try AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            print("⚠️ Markdown parsing failed: \(error)")
            return AttributedString(markdown)
        }
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

#Preview("Help Topic Detail") {
    NavigationView {
        HelpTopicDetailView(topic: HelpTopic.basicRules)
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In HelpView:                                                                  ║
// ║   NavigationLink(destination: HelpTopicDetailView(topic: topic)) {            ║
// ║       TopicRow(topic: topic)                                                  ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ Or with state management:                                                     ║
// ║   @State private var selectedTopic: HelpTopic?                                ║
// ║                                                                               ║
// ║   .sheet(item: $selectedTopic) { topic in                                     ║
// ║       NavigationView {                                                        ║
// ║           HelpTopicDetailView(topic: topic)                                   ║
// ║       }                                                                        ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
