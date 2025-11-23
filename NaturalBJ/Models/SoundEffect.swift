// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ SoundEffect.swift                                                             ║
// ║                                                                               ║
// ║ Defines all sound effects used throughout the Natural blackjack app.        ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Audio feedback is crucial for premium app feel                             ║
// ║ • Each game action should have corresponding sound                           ║
// ║ • Volume levels carefully calibrated for pleasant experience                 ║
// ║ • Sounds paired with haptics for multi-sensory feedback                      ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • CaseIterable for settings UI (enable/disable individual sounds)           ║
// ║ • Each sound has recommended volume level                                    ║
// ║ • Haptic pairing flag for coordinated feedback                              ║
// ║ • Filename mapping for asset loading                                         ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ SoundEffect                                                                   │
// │                                                                               │
// │ Enumeration of all sound effects with metadata for playback.                │
// └──────────────────────────────────────────────────────────────────────────────┘
enum SoundEffect: String, CaseIterable, Identifiable {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CARD SOUNDS                                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Shuffle sound when starting new shoe
    case cardShuffle = "card_shuffle"

    /// Quick whoosh when dealing a card
    case cardDeal = "card_deal"

    /// Crisp snap when flipping a card (hole card reveal)
    case cardFlip = "card_flip"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BETTING SOUNDS                                                            │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Satisfying ceramic chip clink when placing bet
    case chipClink = "chip_clink"

    /// Chips sliding on table (bet confirmation)
    case chipSlide = "chip_slide"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ RESULT SOUNDS                                                             │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Bright celebratory chime for regular win
    case win = "win"

    /// Muted, non-harsh thud for loss
    case loss = "loss"

    /// Special premium sound for blackjack
    case blackjack = "blackjack"

    /// Subtle tone for push (tie)
    case push = "push"

    /// Alert tone for bust
    case bust = "bust"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INTERFACE SOUNDS                                                          │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Subtle click for button tap
    case buttonTap = "button_tap"

    /// Smooth slide for dealer selection
    case dealerSelect = "dealer_select"

    /// Confirmation tone for actions
    case confirm = "confirm"

    /// Warning tone for important actions (surrender, etc.)
    case warning = "warning"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PROPERTIES                                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Unique identifier for Identifiable conformance
    var id: String { rawValue }

    /// Display name for settings UI
    var displayName: String {
        switch self {
        case .cardShuffle: return "Card Shuffle"
        case .cardDeal: return "Card Deal"
        case .cardFlip: return "Card Flip"
        case .chipClink: return "Chip Clink"
        case .chipSlide: return "Chip Slide"
        case .win: return "Win"
        case .loss: return "Loss"
        case .blackjack: return "Blackjack"
        case .push: return "Push"
        case .bust: return "Bust"
        case .buttonTap: return "Button Tap"
        case .dealerSelect: return "Dealer Select"
        case .confirm: return "Confirm"
        case .warning: return "Warning"
        }
    }

    /// Filename without extension (matches asset name)
    var filename: String {
        rawValue
    }

    /// File extension for audio file
    var fileExtension: String {
        "mp3" // Using MP3 for compatibility and small file size
    }

    /// Recommended volume level (0.0 - 1.0)
    /// Carefully calibrated for pleasant, non-jarring experience
    var defaultVolume: Float {
        switch self {
        case .cardShuffle: return 0.25 // Subtle background
        case .cardDeal: return 0.3    // Quick and quiet
        case .cardFlip: return 0.35   // Crisp but not loud
        case .chipClink: return 0.4   // Satisfying
        case .chipSlide: return 0.3   // Smooth
        case .win: return 0.5         // Celebratory but not overwhelming
        case .loss: return 0.3        // Subdued
        case .blackjack: return 0.6   // Special moment!
        case .push: return 0.35       // Neutral
        case .bust: return 0.4        // Alert but not harsh
        case .buttonTap: return 0.2   // Very subtle
        case .dealerSelect: return 0.35 // Smooth transition
        case .confirm: return 0.4     // Clear feedback
        case .warning: return 0.45    // Attention-grabbing
        }
    }

    /// Whether this sound should trigger haptic feedback
    /// Creates multi-sensory experience for important events
    var shouldTriggerHaptic: Bool {
        switch self {
        case .cardShuffle: return false
        case .cardDeal: return true   // Light tap per card
        case .cardFlip: return true   // Medium impact for reveal
        case .chipClink: return true  // Tactile chip placement
        case .chipSlide: return false
        case .win: return true        // Success celebration
        case .loss: return true       // Acknowledge outcome
        case .blackjack: return true  // Special celebration
        case .push: return false
        case .bust: return true       // Alert feedback
        case .buttonTap: return true  // Tactile button press
        case .dealerSelect: return true // Selection confirmation
        case .confirm: return true    // Action confirmation
        case .warning: return true    // Warning attention
        }
    }

    /// Category for organizational purposes
    var category: SoundCategory {
        switch self {
        case .cardShuffle, .cardDeal, .cardFlip:
            return .cards
        case .chipClink, .chipSlide:
            return .betting
        case .win, .loss, .blackjack, .push, .bust:
            return .results
        case .buttonTap, .dealerSelect, .confirm, .warning:
            return .interface
        }
    }

    /// Sound description for accessibility
    var accessibilityDescription: String {
        switch self {
        case .cardShuffle: return "Cards shuffling"
        case .cardDeal: return "Card dealt"
        case .cardFlip: return "Card flipped"
        case .chipClink: return "Chip placed"
        case .chipSlide: return "Chips sliding"
        case .win: return "You won"
        case .loss: return "You lost"
        case .blackjack: return "Blackjack!"
        case .push: return "Push - tie"
        case .bust: return "Bust"
        case .buttonTap: return "Button pressed"
        case .dealerSelect: return "Dealer selected"
        case .confirm: return "Confirmed"
        case .warning: return "Warning"
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ SoundCategory                                                                 │
// │                                                                               │
// │ Groups sounds for settings organization and batch control.                   │
// └──────────────────────────────────────────────────────────────────────────────┘
enum SoundCategory: String, CaseIterable {
    case cards = "Card Sounds"
    case betting = "Betting Sounds"
    case results = "Result Sounds"
    case interface = "Interface Sounds"

    /// All sound effects in this category
    var sounds: [SoundEffect] {
        SoundEffect.allCases.filter { $0.category == self }
    }

    /// Display description for settings
    var description: String {
        switch self {
        case .cards:
            return "Sounds for card dealing, shuffling, and flipping"
        case .betting:
            return "Sounds for placing bets and chip movements"
        case .results:
            return "Sounds for game outcomes and results"
        case .interface:
            return "Sounds for buttons and navigation"
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ AUDIO CONFIGURATION                                                           │
// │                                                                               │
// │ Global audio settings and constants.                                         │
// └──────────────────────────────────────────────────────────────────────────────┘
struct AudioConfiguration {

    /// Master volume (0.0 - 1.0)
    static let defaultMasterVolume: Float = 0.7

    /// Fade in/out duration for background music
    static let fadeDuration: TimeInterval = 1.0

    /// Maximum simultaneous sounds to prevent audio clipping
    static let maxConcurrentSounds: Int = 5

    /// Audio session category for game audio
    static let audioSessionCategory = "AVAudioSessionCategoryAmbient"

    /// Whether to duck other audio (false = mix with other apps)
    static let shouldDuckOtherAudio = false
}
