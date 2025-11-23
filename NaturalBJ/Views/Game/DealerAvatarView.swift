//
//  DealerAvatarView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Dealer Avatar Display Component
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👤 DEALER AVATAR VIEW                                                      ║
// ║                                                                            ║
// ║ Purpose: Compact dealer display for GameView top bar                      ║
// ║ Business Context: Shows current dealer personality with avatar and name   ║
// ║                   Tappable to access dealer info or selection             ║
// ║                                                                            ║
// ║ Design: Avatar (SF Symbol) + Name + Subtle accent colour                  ║
// ║ Size: Compact for top bar placement                                       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct DealerAvatarView: View {

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📊 PROPERTIES                                                        │
    // └─────────────────────────────────────────────────────────────────────┘

    let dealer: Dealer
    let size: AvatarSize

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 SIZE OPTIONS                                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    enum AvatarSize {
        case compact    // For top bar
        case standard   // For dealer selection
        case large      // For dealer info view

        var iconSize: CGFloat {
            switch self {
            case .compact: return 24
            case .standard: return 40
            case .large: return 60
            }
        }

        var fontSize: Font {
            switch self {
            case .compact: return .caption
            case .standard: return .headline
            case .large: return .title2
            }
        }

        var spacing: CGFloat {
            switch self {
            case .compact: return 6
            case .standard: return 8
            case .large: return 12
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                               │
    // └─────────────────────────────────────────────────────────────────────┘

    var body: some View {
        HStack(spacing: size.spacing) {
            // Dealer avatar icon
            Image(systemName: dealer.avatarIcon)
                .font(.system(size: size.iconSize))
                .foregroundColor(dealer.accentColor)

            // Dealer name
            if size != .compact || dealer.name.count <= 6 {
                Text(dealer.name)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, size == .compact ? 8 : 12)
        .padding(.vertical, size == .compact ? 4 : 8)
        .background(
            RoundedRectangle(cornerRadius: size == .compact ? 8 : 12)
                .fill(dealer.accentColor.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: size == .compact ? 8 : 12)
                .strokeBorder(dealer.accentColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🔧 DEALER EXTENSION - Avatar Icon Mapping                                 ║
// ║                                                                            ║
// ║ Maps each dealer personality to an SF Symbol icon                         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

extension Dealer {

    /// SF Symbol icon representing this dealer's personality
    var avatarIcon: String {
        switch name {
        case "Ruby":
            return "heart.fill"              // Classic Vegas, elegant
        case "Lucky":
            return "clover.fill"             // Player-friendly, lucky
        case "Shark":
            return "drop.triangle.fill"      // Aggressive, sharp
        case "Zen":
            return "leaf.fill"               // Calm, patient teacher
        case "Blitz":
            return "bolt.fill"               // Fast-paced, energetic
        case "Maverick":
            return "star.fill"               // Unpredictable, wild card
        default:
            return "person.circle.fill"      // Fallback
        }
    }

    /// Accent colour for this dealer (from spec lines 288-294)
    var accentColor: Color {
        switch name {
        case "Ruby":
            return Color(red: 1.0, green: 0.23, blue: 0.19)  // #FF3B30
        case "Lucky":
            return Color(red: 1.0, green: 0.84, blue: 0.0)   // #FFD700
        case "Shark":
            return Color(red: 0.04, green: 0.52, blue: 1.0)  // #0A84FF
        case "Zen":
            return Color(red: 0.69, green: 0.32, blue: 0.87) // #AF52DE
        case "Blitz":
            return Color(red: 1.0, green: 0.58, blue: 0.0)   // #FF9500
        case "Maverick":
            return Color(red: 1.0, green: 0.27, blue: 0.23)  // Rainbow gradient (using red as primary)
        default:
            return .gray
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("Compact Avatars") {
    VStack(spacing: 16) {
        ForEach(Dealer.allDealers) { dealer in
            DealerAvatarView(dealer: dealer, size: .compact)
        }
    }
    .padding()
    .background(Color.black)
}

#Preview("Standard Avatars") {
    VStack(spacing: 16) {
        ForEach(Dealer.allDealers) { dealer in
            DealerAvatarView(dealer: dealer, size: .standard)
        }
    }
    .padding()
    .background(Color.black)
}

#Preview("Large Avatars") {
    VStack(spacing: 16) {
        ForEach(Dealer.allDealers) { dealer in
            DealerAvatarView(dealer: dealer, size: .large)
        }
    }
    .padding()
    .background(Color.black)
}
