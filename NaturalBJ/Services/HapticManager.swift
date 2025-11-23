// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ HapticManager.swift                                                           ║
// ║                                                                               ║
// ║ Complete haptic feedback system for tactile game interactions.              ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Haptic feedback creates physical connection with gameplay                  ║
// ║ • Essential for premium iOS app experience                                   ║
// ║ • Paired with audio for multi-sensory feedback                               ║
// ║ • Carefully calibrated intensity for each interaction                        ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Singleton pattern for global coordination                                  ║
// ║ • Three feedback generator types (impact, notification, selection)           ║
// ║ • Generators pre-prepared for instant feedback                               ║
// ║ • User-configurable intensity levels                                         ║
// ║ • Respects system haptic settings automatically                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import UIKit
import Combine
import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ HapticManager                                                                 │
// │                                                                               │
// │ Manages all haptic feedback throughout the app.                             │
// └──────────────────────────────────────────────────────────────────────────────┘
@MainActor
class HapticManager: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SINGLETON                                                                 │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let shared = HapticManager()

    private init() {
        loadPreferences()
        prepareGenerators()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUBLISHED STATE                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether haptics are enabled
    @Published var isEnabled: Bool = true {
        didSet {
            saveIsEnabled()
        }
    }

    /// Haptic intensity level
    @Published var intensity: HapticIntensity = .medium {
        didSet {
            saveIntensity()
        }
    }

    /// Individual haptic enable states
    @Published var enabledHaptics: [HapticType: Bool] = [:] {
        didSet {
            saveEnabledHaptics()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ FEEDBACK GENERATORS                                                       │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Impact feedback generators (light, medium, heavy)
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]

    /// Notification feedback generator
    private lazy var notificationGenerator = UINotificationFeedbackGenerator()

    /// Selection feedback generator
    private lazy var selectionGenerator = UISelectionFeedbackGenerator()

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ USERDEFAULTS KEYS                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    private let isEnabledKey = "HapticManager.IsEnabled"
    private let intensityKey = "HapticManager.Intensity"
    private let enabledHapticsKey = "HapticManager.EnabledHaptics"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SETUP                                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Prepare all feedback generators
    private func prepareGenerators() {
        // Create impact generators for each style
        impactGenerators[.light] = UIImpactFeedbackGenerator(style: .light)
        impactGenerators[.medium] = UIImpactFeedbackGenerator(style: .medium)
        impactGenerators[.heavy] = UIImpactFeedbackGenerator(style: .heavy)

        // Prepare generators for instant feedback
        for generator in impactGenerators.values {
            generator.prepare()
        }

        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ HAPTIC PLAYBACK                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Play a haptic feedback
    /// - Parameters:
    ///   - type: Haptic type to play
    ///   - intensityOverride: Optional intensity override
    func playHaptic(_ type: HapticType, intensityOverride: HapticIntensity? = nil) {
        // Check if haptics are enabled globally
        guard isEnabled else { return }

        // Check if this specific haptic is enabled
        guard isHapticEnabled(type) else { return }

        // Check system haptic settings
        guard !UIAccessibility.isReduceMotionEnabled else { return }

        // Get effective intensity
        let effectiveIntensity = intensityOverride ?? intensity

        // Calculate final intensity with user preference
        let finalIntensity = type.intensityMultiplier * effectiveIntensity.multiplier

        // Play appropriate generator
        switch type.generatorType {
        case .impact(let style):
            playImpact(style: style, intensity: finalIntensity)

        case .notification(let feedbackType):
            playNotification(type: feedbackType)

        case .selection:
            playSelection()
        }
    }

    /// Play impact feedback
    private func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: Float) {
        guard let generator = impactGenerators[style] else { return }

        // Prepare for next use
        generator.prepare()

        // Play impact
        if #available(iOS 13.0, *) {
            generator.impactOccurred(intensity: CGFloat(intensity))
        } else {
            generator.impactOccurred()
        }

        // Re-prepare for next use
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.prepare()
        }
    }

    /// Play notification feedback
    private func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(type)

        // Re-prepare for next use
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notificationGenerator.prepare()
        }
    }

    /// Play selection feedback
    private func playSelection() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()

        // Re-prepare for next use
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selectionGenerator.prepare()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INDIVIDUAL HAPTIC MANAGEMENT                                              │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Check if a specific haptic is enabled
    /// - Parameter type: Haptic type to check
    /// - Returns: True if enabled
    func isHapticEnabled(_ type: HapticType) -> Bool {
        enabledHaptics[type] ?? true // Default to enabled
    }

    /// Enable or disable a specific haptic
    /// - Parameters:
    ///   - type: Haptic type to configure
    ///   - enabled: Whether haptic should be enabled
    func setHapticEnabled(_ type: HapticType, enabled: Bool) {
        enabledHaptics[type] = enabled
    }

    /// Enable all haptics
    func enableAllHaptics() {
        for type in HapticType.allCases {
            enabledHaptics[type] = true
        }
    }

    /// Disable all haptics
    func disableAllHaptics() {
        for type in HapticType.allCases {
            enabledHaptics[type] = false
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INTENSITY MANAGEMENT                                                      │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Set haptic intensity
    /// - Parameter newIntensity: Intensity level
    func setIntensity(_ newIntensity: HapticIntensity) {
        intensity = newIntensity
    }

    /// Toggle haptics on/off
    func toggleHaptics() {
        isEnabled.toggle()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PERSISTENCE                                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Load haptic preferences from UserDefaults
    private func loadPreferences() {
        // Load enabled state
        if UserDefaults.standard.object(forKey: isEnabledKey) != nil {
            isEnabled = UserDefaults.standard.bool(forKey: isEnabledKey)
        }

        // Load intensity
        if let intensityRawValue = UserDefaults.standard.string(forKey: intensityKey),
           let loadedIntensity = HapticIntensity(rawValue: intensityRawValue) {
            intensity = loadedIntensity
        }

        // Load enabled haptics
        if let data = UserDefaults.standard.data(forKey: enabledHapticsKey),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) {
            for (key, value) in decoded {
                if let type = HapticType(rawValue: key) {
                    enabledHaptics[type] = value
                }
            }
        }
    }

    /// Save enabled state
    private func saveIsEnabled() {
        UserDefaults.standard.set(isEnabled, forKey: isEnabledKey)
    }

    /// Save intensity
    private func saveIntensity() {
        UserDefaults.standard.set(intensity.rawValue, forKey: intensityKey)
    }

    /// Save enabled haptics
    private func saveEnabledHaptics() {
        let dict = enabledHaptics.reduce(into: [String: Bool]()) { result, pair in
            result[pair.key.rawValue] = pair.value
        }

        if let encoded = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(encoded, forKey: enabledHapticsKey)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ UTILITY METHODS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Reset to default settings
    func resetToDefaults() {
        isEnabled = true
        intensity = .medium
        enabledHaptics.removeAll()
    }

    /// Prepare generators (call before important feedback)
    func prepareAllGenerators() {
        for generator in impactGenerators.values {
            generator.prepare()
        }
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ CONVENIENCE METHODS                                                           │
// │                                                                               │
// │ Quick access to common haptic patterns.                                     │
// └──────────────────────────────────────────────────────────────────────────────┘
extension HapticManager {

    /// Play card deal haptic
    func playCardDeal() {
        playHaptic(.cardDeal)
    }

    /// Play card flip haptic
    func playCardFlip() {
        playHaptic(.cardFlip)
    }

    /// Play bet placed haptic
    func playBetPlaced() {
        playHaptic(.betPlaced)
    }

    /// Play win haptic
    func playWin() {
        playHaptic(.win)
    }

    /// Play loss haptic
    func playLoss() {
        playHaptic(.loss)
    }

    /// Play blackjack haptic (extra strong!)
    func playBlackjack() {
        playHaptic(.blackjack, intensityOverride: .heavy)
    }

    /// Play bust haptic
    func playBust() {
        playHaptic(.bust)
    }

    /// Play button tap haptic
    func playButtonTap() {
        playHaptic(.buttonTap)
    }

    /// Play hit action haptic
    func playHit() {
        playHaptic(.hit)
    }

    /// Play stand action haptic
    func playStand() {
        playHaptic(.stand)
    }

    /// Play double down haptic (strong)
    func playDoubleDown() {
        playHaptic(.doubleDown, intensityOverride: .heavy)
    }

    /// Play split haptic (strong)
    func playSplit() {
        playHaptic(.split, intensityOverride: .heavy)
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ PATTERN COMBINATIONS                                                          │
// │                                                                               │
// │ Complex haptic patterns for special events.                                 │
// └──────────────────────────────────────────────────────────────────────────────┘
extension HapticManager {

    /// Play double pulse (for special events)
    func playDoublePulse() {
        playHaptic(.win)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.playHaptic(.win)
        }
    }

    /// Play triple pulse (for blackjack celebration)
    func playTriplePulse() {
        playHaptic(.blackjack)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playHaptic(.blackjack)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playHaptic(.blackjack)
        }
    }

    /// Play escalating pattern (increasing intensity)
    func playEscalatingPattern() {
        playHaptic(.cardDeal, intensityOverride: .light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playHaptic(.cardDeal, intensityOverride: .medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playHaptic(.cardDeal, intensityOverride: .heavy)
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ HAPTIC DEBUGGING                                                              │
// │                                                                               │
// │ Helper methods for debugging haptic feedback.                               │
// └──────────────────────────────────────────────────────────────────────────────┘
extension HapticManager {

    /// Print current haptic state
    func printHapticState() {
        print("📳 Haptic Manager State:")
        print("   Is Enabled: \(isEnabled)")
        print("   Intensity: \(intensity.rawValue)")
        print("   System Reduce Motion: \(UIAccessibility.isReduceMotionEnabled)")
        print("   Enabled Haptics: \(enabledHaptics.filter { $0.value }.count)/\(HapticType.allCases.count)")
    }

    /// Test all haptic types (for debugging)
    func testAllHaptics() {
        var delay: TimeInterval = 0

        for hapticType in HapticType.allCases {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                print("Testing haptic: \(hapticType.displayName)")
                self.playHaptic(hapticType)
            }
            delay += 0.5
        }
    }
}
