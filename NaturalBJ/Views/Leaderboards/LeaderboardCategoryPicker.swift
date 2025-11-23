//
//  LeaderboardCategoryPicker.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Leaderboard Category Picker
// ═══════════════════════════════════════════════════════════════════════════════════
/// Horizontal carousel for selecting leaderboard categories
struct LeaderboardCategoryPicker: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    @Binding var selectedCategory: LeaderboardCategory
    let categories: [LeaderboardCategory]

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Category Button
// ═══════════════════════════════════════════════════════════════════════════════════
private struct CategoryButton: View {

    let category: LeaderboardCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon
                Text(category.icon)
                    .font(.title2)

                // Name
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 100, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color(white: 0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
            )
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        LeaderboardCategoryPicker(
            selectedCategory: .constant(.level),
            categories: LeaderboardCategory.allCases.filter { $0.isGlobal }
        )
        .padding()
    }
}
