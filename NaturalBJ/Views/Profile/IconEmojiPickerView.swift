//
//  IconEmojiPickerView.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Icon Emoji Picker View
// ═══════════════════════════════════════════════════════════════════════════════════
/// Emoji avatar selector with categories
struct IconEmojiPickerView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategoryIndex = 0

    private let columns = [
        GridItem(.adaptive(minimum: 60), spacing: 16)
    ]

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(white: 0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Preview section
                    previewSection

                    Divider()
                        .background(Color.gray)

                    // Category tabs
                    categoryTabs

                    // Emoji grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(currentCategoryEmojis, id: \.self) { emoji in
                                emojiButton(emoji)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 👁️ PREVIEW SECTION                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var previewSection: some View {
        VStack(spacing: 12) {
            Text("Current Avatar")
                .font(.caption)
                .foregroundColor(.gray)

            Text(selectedEmoji)
                .font(.system(size: 80))

            Text("Tap an emoji below to select")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(white: 0.1))
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📑 CATEGORY TABS                                                 │
    // └─────────────────────────────────────────────────────────────────┘

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<PlayerEmojiIcons.categories.count, id: \.self) { index in
                    let category = PlayerEmojiIcons.categories[index]

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategoryIndex = index
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(category.icon)
                                .font(.title2)

                            Text(category.name)
                                .font(.caption2)
                                .fontWeight(selectedCategoryIndex == index ? .bold : .regular)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedCategoryIndex == index ? Color.blue.opacity(0.3) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedCategoryIndex == index ? Color.blue : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(white: 0.08))
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 😀 EMOJI BUTTON                                                  │
    // └─────────────────────────────────────────────────────────────────┘

    private func emojiButton(_ emoji: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedEmoji = emoji
            }

            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            Text(emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedEmoji == emoji ? Color.blue.opacity(0.3) : Color(white: 0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            selectedEmoji == emoji ? Color.blue : Color.clear,
                            lineWidth: 2
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 COMPUTED PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    private var currentCategoryEmojis: [String] {
        guard selectedCategoryIndex < PlayerEmojiIcons.categories.count else {
            return []
        }
        return PlayerEmojiIcons.categories[selectedCategoryIndex].emojis
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    IconEmojiPickerView(selectedEmoji: .constant("🎴"))
}
