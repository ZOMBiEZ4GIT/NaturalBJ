//
//  CardView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎴 CARD VIEW COMPONENT                                                     ║
// ║                                                                            ║
// ║ Purpose: Displays a single playing card with proper styling and animations║
// ║ Business Context: Cards are the primary visual element in blackjack.      ║
// ║                   They must be large, readable, and attractive.           ║
// ║                                                                            ║
// ║ Features:                                                                  ║
// ║ • Large, readable rank and suit symbols                                   ║
// ║ • Proper red/black colouring for suits                                    ║
// ║ • Face-down card state for dealer hole card                               ║
// ║ • Smooth flip animation (3D rotation)                                     ║
// ║ • Shadow and border for depth                                             ║
// ║                                                                            ║
// ║ Used By: • GameView (displays player and dealer hands)                    ║
// ║          • HandView (groups of cards)                                     ║
// ║                                                                            ║
// ║ Related Spec: See "Card Display & Dealing" section, lines 133-140         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct CardView: View {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 PROPERTIES                                                        │
    // └─────────────────────────────────────────────────────────────────────┘

    let card: Card
    let isFaceDown: Bool
    let size: CardSize

    // Animation state for flip effect
    @State private var isFlipped: Bool = false

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                       │
    // └─────────────────────────────────────────────────────────────────────┘

    init(card: Card, isFaceDown: Bool = false, size: CardSize = .standard) {
        self.card = card
        self.isFaceDown = isFaceDown
        self.size = size
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY - Main View                                                  │
    // └─────────────────────────────────────────────────────────────────────┘

    var body: some View {
        ZStack {
            if isFaceDown {
                // Back of card - decorative pattern
                cardBack
            } else {
                // Front of card - rank and suit
                cardFront
            }
        }
        .frame(width: size.width, height: size.height)
        .background(Color.cardBackground)
        .cornerRadius(size.cornerRadius)
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 CARD FRONT - Rank & Suit Display                                 │
    // │                                                                      │
    // │ Business Logic: Shows the card's rank and suit in large, readable   │
    // │ format. Rank appears in top-left and bottom-right corners.          │
    // │ Large centered symbol for quick recognition.                        │
    // └─────────────────────────────────────────────────────────────────────┘

    private var cardFront: some View {
        ZStack {
            // Main card background
            Rectangle()
                .fill(Color.cardBackground)

            VStack(spacing: 0) {
                // Top-left corner
                HStack {
                    cornerLabel
                    Spacer()
                }
                .padding(size.padding)

                Spacer()

                // Large centered suit symbol
                Text(card.suit.symbol)
                    .font(.system(size: size.centerSymbolSize, weight: .regular))
                    .foregroundColor(suitColor)

                Spacer()

                // Bottom-right corner (rotated 180°)
                HStack {
                    Spacer()
                    cornerLabel
                        .rotationEffect(.degrees(180))
                }
                .padding(size.padding)
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 CARD BACK - Decorative Pattern                                   │
    // │                                                                      │
    // │ Business Logic: Shows when card is face-down (dealer's hole card)   │
    // │ Simple pattern that doesn't distract from gameplay                  │
    // └─────────────────────────────────────────────────────────────────────┘

    private var cardBack: some View {
        ZStack {
            // Base colour
            Color.dealerShark
                .opacity(0.8)

            // Diamond pattern
            VStack(spacing: 8) {
                ForEach(0..<5) { _ in
                    HStack(spacing: 8) {
                        ForEach(0..<3) { _ in
                            Diamond()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🏷️ CORNER LABEL - Rank & Small Suit                                 │
    // │                                                                      │
    // │ Appears in top-left and bottom-right (rotated) corners              │
    // └─────────────────────────────────────────────────────────────────────┘

    private var cornerLabel: some View {
        VStack(spacing: 2) {
            // Rank (A, 2, 3, ..., K)
            Text(card.rank.symbol)
                .font(.system(size: size.rankFontSize, weight: .bold))
                .foregroundColor(suitColor)

            // Small suit symbol
            Text(card.suit.symbol)
                .font(.system(size: size.suitFontSize, weight: .regular))
                .foregroundColor(suitColor)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 COMPUTED PROPERTIES                                               │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Returns red or black based on suit
    private var suitColor: Color {
        switch card.color {
        case .red:
            return .cardRed
        case .black:
            return .cardBlack
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📏 CARD SIZE CONFIGURATION                                                 ║
// ║                                                                            ║
// ║ Purpose: Defines standard card sizes for different contexts               ║
// ║ Business Context: Cards need to be large enough to read but not so large  ║
// ║                   that they dominate the screen. Standard size is for     ║
// ║                   main gameplay, small is for history/stats.              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

enum CardSize {
    case small
    case standard
    case large

    var width: CGFloat {
        switch self {
        case .small: return 50
        case .standard: return 80
        case .large: return 100
        }
    }

    var height: CGFloat {
        return width * 1.4 // Standard playing card ratio
    }

    var cornerRadius: CGFloat {
        return width * 0.1
    }

    var padding: CGFloat {
        return width * 0.1
    }

    var rankFontSize: CGFloat {
        return width * 0.3
    }

    var suitFontSize: CGFloat {
        return width * 0.25
    }

    var centerSymbolSize: CGFloat {
        return width * 0.6
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🔷 DIAMOND SHAPE                                                           ║
// ║                                                                            ║
// ║ Purpose: Creates a diamond shape for card back pattern                    ║
// ║ Simple geometric shape used in decorative pattern                         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎬 ANIMATION EXTENSIONS                                                    ║
// ║                                                                            ║
// ║ Purpose: Provides animation methods for card effects                      ║
// ║ Used for: Dealing, flipping, highlighting                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension CardView {
    /// Flips the card from face-down to face-up with animation
    func flip(duration: Double = 0.4) {
        withAnimation(.easeInOut(duration: duration)) {
            isFlipped.toggle()
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                 ║
// ║                                                                            ║
// ║ Xcode preview for design iteration                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("Face Up Cards") {
    VStack(spacing: 20) {
        HStack(spacing: 15) {
            CardView(card: Card(rank: .ace, suit: .spades), size: .standard)
            CardView(card: Card(rank: .king, suit: .hearts), size: .standard)
            CardView(card: Card(rank: .ten, suit: .diamonds), size: .standard)
        }

        HStack(spacing: 15) {
            CardView(card: Card(rank: .seven, suit: .clubs), size: .small)
            CardView(card: Card(rank: .queen, suit: .hearts), size: .small)
        }
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Face Down Card") {
    CardView(
        card: Card(rank: .ace, suit: .spades),
        isFaceDown: true,
        size: .standard
    )
    .padding()
    .background(Color.appBackground)
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Display a card:                                                            ║
// ║   CardView(card: myCard)                                                   ║
// ║                                                                            ║
// ║ Display dealer's hole card (face down):                                    ║
// ║   CardView(card: dealerHoleCard, isFaceDown: true)                         ║
// ║                                                                            ║
// ║ Small card for stats display:                                              ║
// ║   CardView(card: historyCard, size: .small)                                ║
// ║                                                                            ║
// ║ Flip animation:                                                            ║
// ║   let cardView = CardView(card: myCard, isFaceDown: true)                  ║
// ║   cardView.flip()  // Flips from back to front                             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
