// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ VisualSettings.swift                                                          ║
// ║                                                                               ║
// ║ User preferences for visual customisation including table felt, cards,      ║
// ║ animations, and effects.                                                     ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Visual customisation drives engagement and retention                       ║
// ║ • Settings must persist across app sessions                                  ║
// ║ • Premium visual options can drive monetisation                              ║
// ║ • Accessibility options ensure inclusive experience                          ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Codable for UserDefaults persistence                                       ║
// ║ • Sensible defaults for first-time users                                     ║
// ║ • Animation speed control for user preference                                ║
// ║ • Reduce Motion support for accessibility                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ VisualSettings                                                                │
// │                                                                               │
// │ Complete visual customisation preferences for the app.                      │
// └──────────────────────────────────────────────────────────────────────────────┘
struct VisualSettings: Codable {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CUSTOMISATION PROPERTIES                                                  │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Selected table felt colour
    var tableFeltColor: TableFeltColor

    /// Selected card back design
    var cardBackDesign: CardBackDesign

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ANIMATION PROPERTIES                                                      │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether animations are enabled (overridden by system Reduce Motion)
    var animationsEnabled: Bool

    /// Speed of animations (slow/normal/fast)
    var animationSpeed: AnimationSpeed

    /// Whether to show particle effects (confetti, sparkles, etc.)
    var showParticleEffects: Bool

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ VISUAL EFFECT PROPERTIES                                                  │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether to show card shadows for depth
    var showCardShadows: Bool

    /// Whether to show glow effects (blackjack, wins, etc.)
    var showGlowEffects: Bool

    /// Whether to use gradients or solid colours
    var useGradients: Bool

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DISPLAY PROPERTIES                                                        │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Show hand value labels
    var showHandValues: Bool

    /// Show win/loss statistics in game view
    var showStatisticsOverlay: Bool

    /// Card size preference
    var cardSize: CardSizePreference

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INITIALISER                                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    init(
        tableFeltColor: TableFeltColor = .default,
        cardBackDesign: CardBackDesign = .default,
        animationsEnabled: Bool = true,
        animationSpeed: AnimationSpeed = .normal,
        showParticleEffects: Bool = true,
        showCardShadows: Bool = true,
        showGlowEffects: Bool = true,
        useGradients: Bool = true,
        showHandValues: Bool = true,
        showStatisticsOverlay: Bool = false,
        cardSize: CardSizePreference = .standard
    ) {
        self.tableFeltColor = tableFeltColor
        self.cardBackDesign = cardBackDesign
        self.animationsEnabled = animationsEnabled
        self.animationSpeed = animationSpeed
        self.showParticleEffects = showParticleEffects
        self.showCardShadows = showCardShadows
        self.showGlowEffects = showGlowEffects
        self.useGradients = useGradients
        self.showHandValues = showHandValues
        self.showStatisticsOverlay = showStatisticsOverlay
        self.cardSize = cardSize
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEFAULT SETTINGS                                                          │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Factory default settings
    static var `default`: VisualSettings {
        VisualSettings()
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ AnimationSpeed                                                                │
// │                                                                               │
// │ User preference for animation speed.                                         │
// └──────────────────────────────────────────────────────────────────────────────┘
enum AnimationSpeed: String, Codable, CaseIterable {
    case slow = "Slow"
    case normal = "Normal"
    case fast = "Fast"

    /// Duration multiplier (slower = longer duration)
    var durationMultiplier: Double {
        switch self {
        case .slow: return 1.5    // 50% slower
        case .normal: return 1.0  // Standard speed
        case .fast: return 0.7    // 30% faster
        }
    }

    /// Delay multiplier for sequential animations
    var delayMultiplier: Double {
        durationMultiplier
    }

    /// Description for UI
    var description: String {
        switch self {
        case .slow: return "Slower, more deliberate animations"
        case .normal: return "Standard animation speed"
        case .fast: return "Quicker, snappier animations"
        }
    }

    /// Icon for settings UI
    var iconName: String {
        switch self {
        case .slow: return "tortoise.fill"
        case .normal: return "speedometer"
        case .fast: return "hare.fill"
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ CardSizePreference                                                            │
// │                                                                               │
// │ User preference for card display size.                                      │
// └──────────────────────────────────────────────────────────────────────────────┘
enum CardSizePreference: String, Codable, CaseIterable {
    case small = "Small"
    case standard = "Standard"
    case large = "Large"

    /// Scale multiplier for card size
    var scale: CGFloat {
        switch self {
        case .small: return 0.8
        case .standard: return 1.0
        case .large: return 1.2
        }
    }

    /// Description for UI
    var description: String {
        switch self {
        case .small: return "Compact card display"
        case .standard: return "Default card size"
        case .large: return "Larger, easier to read cards"
        }
    }

    /// Accessibility benefit
    var accessibilityBenefit: String {
        switch self {
        case .small: return "More cards visible at once"
        case .standard: return "Balanced visibility and readability"
        case .large: return "Enhanced readability for accessibility"
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ANIMATION DURATION HELPERS                                                    │
// │                                                                               │
// │ Computed animation durations based on user preferences.                     │
// └──────────────────────────────────────────────────────────────────────────────┘
extension VisualSettings {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CARD ANIMATION DURATIONS                                                  │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Duration for card deal animation
    var cardDealDuration: Double {
        0.4 * animationSpeed.durationMultiplier
    }

    /// Duration for card flip animation
    var cardFlipDuration: Double {
        0.3 * animationSpeed.durationMultiplier
    }

    /// Duration for card collect animation
    var cardCollectDuration: Double {
        0.5 * animationSpeed.durationMultiplier
    }

    /// Delay between sequential card deals
    var cardDealDelay: Double {
        0.2 * animationSpeed.delayMultiplier
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CHIP ANIMATION DURATIONS                                                  │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Duration for chip placement animation
    var chipPlaceDuration: Double {
        0.3 * animationSpeed.durationMultiplier
    }

    /// Duration for win/loss chip animation
    var chipMoveDuration: Double {
        0.6 * animationSpeed.durationMultiplier
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ RESULT ANIMATION DURATIONS                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Duration for result display animation
    var resultDisplayDuration: Double {
        0.5 * animationSpeed.durationMultiplier
    }

    /// Duration for particle effects
    var particleEffectDuration: Double {
        2.0 * animationSpeed.durationMultiplier
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ STATE TRANSITION DURATIONS                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Duration for game state transitions
    var stateTransitionDuration: Double {
        0.3 * animationSpeed.durationMultiplier
    }

    /// Duration for fade animations
    var fadeDuration: Double {
        0.25 * animationSpeed.durationMultiplier
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ACCESSIBILITY INTEGRATION                                                     │
// │                                                                               │
// │ Respect system accessibility settings.                                      │
// └──────────────────────────────────────────────────────────────────────────────┘
extension VisualSettings {

    /// Whether animations should actually play (considers Reduce Motion)
    var shouldPlayAnimations: Bool {
        guard animationsEnabled else { return false }

        // Check system Reduce Motion setting
        if UIAccessibility.isReduceMotionEnabled {
            return false
        }

        return true
    }

    /// Whether to show particle effects (respects user + system settings)
    var shouldShowParticleEffects: Bool {
        shouldPlayAnimations && showParticleEffects
    }

    /// Get appropriate animation based on Reduce Motion
    /// - Parameter normalAnimation: The animation to use when motion is allowed
    /// - Returns: Either the normal animation or a simple fade
    func animation(_ normalAnimation: Animation) -> Animation {
        shouldPlayAnimations ? normalAnimation : .easeInOut(duration: 0.1)
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ PREVIEW HELPERS                                                               │
// │                                                                               │
// │ Sample configurations for testing and previews.                             │
// └──────────────────────────────────────────────────────────────────────────────┘
extension VisualSettings {

    /// Minimal visual settings (reduced effects)
    static var minimal: VisualSettings {
        VisualSettings(
            animationsEnabled: true,
            animationSpeed: .fast,
            showParticleEffects: false,
            showCardShadows: false,
            showGlowEffects: false,
            useGradients: false
        )
    }

    /// Maximum visual settings (all effects enabled)
    static var maximum: VisualSettings {
        VisualSettings(
            tableFeltColor: .royalPurple,
            cardBackDesign: .goldLuxury,
            animationsEnabled: true,
            animationSpeed: .normal,
            showParticleEffects: true,
            showCardShadows: true,
            showGlowEffects: true,
            useGradients: true
        )
    }

    /// Accessibility-focused settings (slow, clear, reduced motion)
    static var accessibility: VisualSettings {
        VisualSettings(
            animationsEnabled: false,
            animationSpeed: .slow,
            showParticleEffects: false,
            showCardShadows: true,
            showGlowEffects: false,
            useGradients: false,
            cardSize: .large
        )
    }
}
