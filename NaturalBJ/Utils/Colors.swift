//
//  Colors.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 1: Foundation Setup
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎨 COLOUR PALETTE                                                          ║
// ║                                                                            ║
// ║ Purpose: Defines the app's dark theme colour scheme                       ║
// ║ Business Context: Consistent colours create a professional, modern look   ║
// ║                   Dark theme reduces eye strain during long play sessions ║
// ║                                                                            ║
// ║ Design Philosophy:                                                         ║
// ║ • Pure black background (#000000) for maximum contrast                    ║
// ║ • Vibrant accent colours for dealer personalities                         ║
// ║ • Standard iOS system colours where appropriate                           ║
// ║                                                                            ║
// ║ Related Spec: See "UI/UX Design Specification" section, lines 278-294     ║
// ║               Colour palette defined exactly per specification            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

extension Color {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎴 BACKGROUND & SURFACE COLOURS                                      │
    // │                                                                      │
    // │ Core colours for app backgrounds and surfaces                       │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Pure black background - the foundation of our dark theme
    /// Used for: Main app background, game table
    static let appBackground = Color(hex: "000000")

    /// Card background - pure white for maximum readability
    /// Used for: Playing cards
    static let cardBackground = Color(hex: "FFFFFF")

    /// Dark grey for UI elements
    /// Used for: Action buttons, panels, overlays
    static let darkGrey = Color(hex: "2C2C2E")

    /// Medium grey for secondary UI
    /// Used for: Disabled buttons, borders, dividers
    static let mediumGrey = Color(hex: "48484A")

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ ♠♥♦♣ CARD SUIT COLOURS                                               │
    // │                                                                      │
    // │ Standard playing card colours                                       │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Red for hearts and diamonds
    /// Slightly brighter than standard red for better visibility on dark background
    static let cardRed = Color(hex: "FF3B30")

    /// Black for spades and clubs
    static let cardBlack = Color(hex: "000000")

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 💰 BANKROLL & CHIP COLOURS                                           │
    // │                                                                      │
    // │ Gold gradient for currency display                                  │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Bright gold for chip display
    static let chipGold = Color(hex: "FFD700")

    /// Darker gold for gradient
    static let chipGoldDark = Color(hex: "FFA500")

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 👤 DEALER ACCENT COLOURS                                             │
    // │                                                                      │
    // │ Each dealer has a signature colour for visual identity              │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Ruby - Classic Vegas (Red)
    static let dealerRuby = Color(hex: "FF3B30")

    /// Lucky - Player's Friend (Gold)
    static let dealerLucky = Color(hex: "FFD700")

    /// Shark - High Roller (Blue)
    static let dealerShark = Color(hex: "0A84FF")

    /// Zen - Teacher (Purple)
    static let dealerZen = Color(hex: "AF52DE")

    /// Blitz - Speed Demon (Orange)
    static let dealerBlitz = Color(hex: "FF9500")

    /// Maverick - Wild Card (Rainbow gradient handled separately)
    static let dealerMaverickStart = Color(hex: "FF3B30")
    static let dealerMaverickEnd = Color(hex: "AF52DE")

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎯 SEMANTIC COLOURS                                                  │
    // │                                                                      │
    // │ Colours with specific meanings in gameplay                          │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Green for wins, positive actions
    static let success = Color(hex: "34C759")

    /// Red for losses, destructive actions
    static let destructive = Color(hex: "FF3B30")

    /// Yellow/Orange for warnings
    static let warning = Color(hex: "FF9500")

    /// Blue for information
    static let info = Color(hex: "0A84FF")

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🃏 SPECIAL EFFECT COLOURS                                            │
    // │                                                                      │
    // │ Colours for highlights, glows, and effects                          │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Gold highlight for blackjack
    static let blackjackGlow = Color(hex: "FFD700")

    /// Red highlight for bust
    static let bustHighlight = Color(hex: "FF3B30")

    /// Green pulse for optimal strategy hint
    static let strategyOptimal = Color(hex: "34C759")

    /// Yellow pulse for acceptable strategy
    static let strategyAcceptable = Color(hex: "FF9500")

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🛠️ HELPER FUNCTIONS                                                  │
    // │                                                                      │
    // │ Utilities for working with colours                                  │
    // └─────────────────────────────────────────────────────────────────────┘

    /// Creates a Color from a hex string (e.g., "FF3B30")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Creates a gradient suitable for chips/currency
    static var chipGradient: LinearGradient {
        LinearGradient(
            colors: [chipGold, chipGoldDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Creates Maverick's rainbow gradient
    static var maverickGradient: LinearGradient {
        LinearGradient(
            colors: [
                dealerMaverickStart,
                dealerLucky,
                dealerShark,
                dealerZen,
                dealerMaverickEnd
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Returns appropriate dealer colour based on dealer type
    static func dealerColor(for dealerName: String) -> Color {
        switch dealerName.lowercased() {
        case "ruby":
            return dealerRuby
        case "lucky":
            return dealerLucky
        case "shark":
            return dealerShark
        case "zen":
            return dealerZen
        case "blitz":
            return dealerBlitz
        case "maverick":
            return dealerMaverickStart // Use start color for solid displays
        default:
            return info
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Setting background:                                                        ║
// ║   .background(Color.appBackground)                                         ║
// ║                                                                            ║
// ║ Using dealer colour:                                                       ║
// ║   Text("Ruby").foregroundColor(.dealerRuby)                                ║
// ║                                                                            ║
// ║ Chip gradient:                                                             ║
// ║   Text("$1,000").foregroundStyle(Color.chipGradient)                       ║
// ║                                                                            ║
// ║ Custom hex colour:                                                         ║
// ║   Rectangle().fill(Color(hex: "FF3B30"))                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
