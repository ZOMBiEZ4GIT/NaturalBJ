// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ HapticType.swift                                                              ║
// ║                                                                               ║
// ║ Defines all haptic feedback patterns used throughout Natural blackjack.     ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Haptic feedback creates tactile connection with game                       ║
// ║ • Essential for premium iOS app experience                                   ║
// ║ • Paired with sounds for multi-sensory feedback                              ║
// ║ • Carefully calibrated intensity for each action                             ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Uses UIKit feedback generators for system haptics                          ║
// ║ • Three types: Impact, Notification, Selection                               ║
// ║ • Intensity varies by game event importance                                  ║
// ║ • Respects system haptic settings (auto-disabled if off)                     ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import UIKit

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ HapticType                                                                    │
// │                                                                               │
// │ Enumeration of all haptic feedback patterns with UIKit generator mapping.   │
// └──────────────────────────────────────────────────────────────────────────────┘
enum HapticType: String, CaseIterable, Identifiable {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CARD HAPTICS                                                              │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Light tap when card is dealt
    case cardDeal = "card_deal"

    /// Medium impact when card is flipped (hole card reveal)
    case cardFlip = "card_flip"

    /// Soft impact when collecting cards
    case cardCollect = "card_collect"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BETTING HAPTICS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Light tap when adjusting bet
    case betAdjust = "bet_adjust"

    /// Medium impact when placing bet
    case betPlaced = "bet_placed"

    /// Light tap for chip interaction
    case chipInteraction = "chip_interaction"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ RESULT HAPTICS                                                            │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Success notification for regular win
    case win = "win"

    /// Warning notification for loss
    case loss = "loss"

    /// Success + heavy impact for blackjack
    case blackjack = "blackjack"

    /// Light notification for push
    case push = "push"

    /// Error notification for bust
    case bust = "bust"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ACTION HAPTICS                                                            │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Selection feedback for button tap
    case buttonTap = "button_tap"

    /// Medium impact for hit action
    case hit = "hit"

    /// Medium impact for stand action
    case stand = "stand"

    /// Heavy impact for double down
    case doubleDown = "double_down"

    /// Heavy impact for split
    case split = "split"

    /// Warning notification for surrender
    case surrender = "surrender"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INTERFACE HAPTICS                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Selection feedback for dealer change
    case dealerSelect = "dealer_select"

    /// Light impact for navigation
    case navigation = "navigation"

    /// Success for action confirmation
    case confirm = "confirm"

    /// Warning for important alerts
    case warning = "warning"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PROPERTIES                                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Unique identifier for Identifiable conformance
    var id: String { rawValue }

    /// Display name for settings UI
    var displayName: String {
        switch self {
        case .cardDeal: return "Card Deal"
        case .cardFlip: return "Card Flip"
        case .cardCollect: return "Card Collect"
        case .betAdjust: return "Bet Adjust"
        case .betPlaced: return "Bet Placed"
        case .chipInteraction: return "Chip Interaction"
        case .win: return "Win"
        case .loss: return "Loss"
        case .blackjack: return "Blackjack"
        case .push: return "Push"
        case .bust: return "Bust"
        case .buttonTap: return "Button Tap"
        case .hit: return "Hit"
        case .stand: return "Stand"
        case .doubleDown: return "Double Down"
        case .split: return "Split"
        case .surrender: return "Surrender"
        case .dealerSelect: return "Dealer Select"
        case .navigation: return "Navigation"
        case .confirm: return "Confirm"
        case .warning: return "Warning"
        }
    }

    /// The type of haptic generator to use
    var generatorType: HapticGeneratorType {
        switch self {
        // Impact-based haptics (physical sensation)
        case .cardDeal, .cardCollect, .betAdjust, .chipInteraction, .navigation:
            return .impact(.light)

        case .cardFlip, .betPlaced, .hit, .stand:
            return .impact(.medium)

        case .doubleDown, .split, .blackjack:
            return .impact(.heavy)

        // Notification-based haptics (success/warning/error)
        case .win, .confirm:
            return .notification(.success)

        case .loss, .surrender, .warning:
            return .notification(.warning)

        case .bust:
            return .notification(.error)

        case .push:
            return .notification(.warning) // Neutral outcome

        // Selection-based haptics (UI interaction)
        case .buttonTap, .dealerSelect:
            return .selection
        }
    }

    /// Intensity multiplier for user preference (0.0 - 1.0)
    /// Some haptics should be stronger than others
    var intensityMultiplier: Float {
        switch self {
        case .cardDeal, .cardCollect, .betAdjust, .chipInteraction:
            return 0.6 // Subtle

        case .cardFlip, .betPlaced, .hit, .stand, .buttonTap, .dealerSelect, .navigation:
            return 0.8 // Standard

        case .win, .loss, .push, .bust, .confirm, .warning:
            return 1.0 // Full strength for important feedback

        case .blackjack, .doubleDown, .split, .surrender:
            return 1.0 // Maximum impact for significant actions
        }
    }

    /// Category for grouping in settings
    var category: HapticCategory {
        switch self {
        case .cardDeal, .cardFlip, .cardCollect:
            return .cards
        case .betAdjust, .betPlaced, .chipInteraction:
            return .betting
        case .win, .loss, .blackjack, .push, .bust:
            return .results
        case .hit, .stand, .doubleDown, .split, .surrender:
            return .actions
        case .buttonTap, .dealerSelect, .navigation, .confirm, .warning:
            return .interface
        }
    }

    /// Accessibility description
    var accessibilityDescription: String {
        switch self {
        case .cardDeal: return "Light tap - card dealt"
        case .cardFlip: return "Medium tap - card flipped"
        case .cardCollect: return "Light tap - cards collected"
        case .betAdjust: return "Light tap - bet adjusted"
        case .betPlaced: return "Medium tap - bet placed"
        case .chipInteraction: return "Light tap - chip interaction"
        case .win: return "Success vibration - you won"
        case .loss: return "Warning vibration - you lost"
        case .blackjack: return "Strong success - blackjack!"
        case .push: return "Neutral vibration - push"
        case .bust: return "Error vibration - bust"
        case .buttonTap: return "Selection tap - button pressed"
        case .hit: return "Medium tap - hit"
        case .stand: return "Medium tap - stand"
        case .doubleDown: return "Strong tap - double down"
        case .split: return "Strong tap - split"
        case .surrender: return "Warning vibration - surrender"
        case .dealerSelect: return "Selection tap - dealer selected"
        case .navigation: return "Light tap - navigation"
        case .confirm: return "Success vibration - confirmed"
        case .warning: return "Warning vibration - alert"
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ HapticGeneratorType                                                           │
// │                                                                               │
// │ Maps to UIKit feedback generator types with specific styles.                │
// └──────────────────────────────────────────────────────────────────────────────┘
enum HapticGeneratorType {
    /// Impact feedback with specific style (light/medium/heavy)
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)

    /// Notification feedback (success/warning/error)
    case notification(UINotificationFeedbackGenerator.FeedbackType)

    /// Selection feedback (UI element selection)
    case selection
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ HapticCategory                                                                │
// │                                                                               │
// │ Groups haptics for settings organization and batch control.                 │
// └──────────────────────────────────────────────────────────────────────────────┘
enum HapticCategory: String, CaseIterable {
    case cards = "Card Haptics"
    case betting = "Betting Haptics"
    case results = "Result Haptics"
    case actions = "Action Haptics"
    case interface = "Interface Haptics"

    /// All haptic types in this category
    var haptics: [HapticType] {
        HapticType.allCases.filter { $0.category == self }
    }

    /// Display description for settings
    var description: String {
        switch self {
        case .cards:
            return "Haptic feedback for card dealing and handling"
        case .betting:
            return "Haptic feedback for betting actions"
        case .results:
            return "Haptic feedback for game outcomes"
        case .actions:
            return "Haptic feedback for player actions"
        case .interface:
            return "Haptic feedback for UI interactions"
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ HapticIntensity                                                               │
// │                                                                               │
// │ User-selectable intensity levels for haptic feedback.                       │
// └──────────────────────────────────────────────────────────────────────────────┘
enum HapticIntensity: String, CaseIterable, Codable {
    case light = "Light"
    case medium = "Medium"
    case heavy = "Heavy"

    /// Multiplier applied to base haptic intensity (0.0 - 1.0)
    var multiplier: Float {
        switch self {
        case .light: return 0.5
        case .medium: return 0.8
        case .heavy: return 1.0
        }
    }

    /// Display description
    var description: String {
        switch self {
        case .light: return "Subtle haptic feedback"
        case .medium: return "Balanced haptic feedback"
        case .heavy: return "Strong haptic feedback"
        }
    }
}
