//
//  DealerCardView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 3: Dealer Personalities & Rule Variations
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 DEALER CARD VIEW                                                        ║
// ║                                                                            ║
// ║ Purpose: Displays a single dealer in a card format for selection          ║
// ║ Business Context: Visual representation of each dealer personality        ║
// ║                                                                            ║
// ║ Layout:                                                                    ║
// ║ • Dealer avatar (SF Symbol with theme colour)                             ║
// ║ • Dealer name                                                             ║
// ║ • Tagline                                                                  ║
// ║ • House edge indicator (color-coded: green=good, red=bad)                 ║
// ║ • Selected state highlighting                                             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct DealerCardView: View {
    let dealer: Dealer
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            // Avatar
            Image(systemName: dealer.avatarName)
                .font(.system(size: 50))
                .foregroundColor(dealer.themeColor)
                .frame(height: 60)

            // Name
            Text(dealer.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Tagline
            Text(dealer.tagline)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // House Edge
            HStack(spacing: 4) {
                Image(systemName: houseEdgeIcon)
                    .font(.caption)
                    .foregroundColor(houseEdgeColor)

                Text(dealer.houseEdgeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? dealer.themeColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                )
        )
        .shadow(color: isSelected ? dealer.themeColor.opacity(0.3) : .clear, radius: 10)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 HOUSE EDGE INDICATOR                                              │
    // │                                                                      │
    // │ Visual feedback on how favourable the dealer is                     │
    // │ Green = player advantage/low edge                                   │
    // │ Yellow = moderate                                                    │
    // │ Red = high house edge                                               │
    // └─────────────────────────────────────────────────────────────────────┘

    private var houseEdgeColor: Color {
        let edge = dealer.houseEdge
        if edge < 0 {
            return .green // Player advantage (Lucky)
        } else if edge < 0.6 {
            return .yellow // Low edge (Zen, Ruby)
        } else if edge < 1.0 {
            return .orange // Moderate (Maverick)
        } else {
            return .red // High edge (Shark)
        }
    }

    private var houseEdgeIcon: String {
        let edge = dealer.houseEdge
        if edge < 0 {
            return "arrow.down.circle.fill" // Player advantage
        } else if edge < 1.0 {
            return "equal.circle.fill" // Fair
        } else {
            return "arrow.up.circle.fill" // House advantage
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎨 PREVIEW                                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview {
    VStack(spacing: 20) {
        DealerCardView(dealer: .ruby(), isSelected: false)
        DealerCardView(dealer: .lucky(), isSelected: true)
        DealerCardView(dealer: .shark(), isSelected: false)
    }
    .padding()
    .background(Color.black)
}
