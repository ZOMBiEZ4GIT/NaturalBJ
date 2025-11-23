// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ AccessibilityManager.swift                                                    ║
// ║                                                                               ║
// ║ Manages accessibility features and provides adaptive experiences.           ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Accessibility is essential for inclusive app design                        ║
// ║ • VoiceOver users need comprehensive labeling                                ║
// ║ • Reduce Motion must be respected for motion sensitivity                     ║
// ║ • Dynamic Type support improves readability                                  ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Singleton pattern for global accessibility state                           ║
// ║ • Reactive to system accessibility changes                                   ║
// ║ • Provides alternative experiences for different needs                       ║
// ║ • Comprehensive VoiceOver announcements                                      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ AccessibilityManager                                                          │
// │                                                                               │
// │ Manages all accessibility features and system settings monitoring.          │
// └──────────────────────────────────────────────────────────────────────────────┘
@MainActor
class AccessibilityManager: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SINGLETON                                                                 │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let shared = AccessibilityManager()

    private init() {
        setupAccessibilityObservers()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUBLISHED STATE                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether VoiceOver is currently running
    @Published private(set) var isVoiceOverRunning: Bool = UIAccessibility.isVoiceOverRunning

    /// Whether Reduce Motion is enabled
    @Published private(set) var isReduceMotionEnabled: Bool = UIAccessibility.isReduceMotionEnabled

    /// Whether Reduce Transparency is enabled
    @Published private(set) var isReduceTransparencyEnabled: Bool = UIAccessibility.isReduceTransparencyEnabled

    /// Whether Bold Text is enabled
    @Published private(set) var isBoldTextEnabled: Bool = UIAccessibility.isBoldTextEnabled

    /// Whether Increase Contrast is enabled
    @Published private(set) var isDarkerSystemColorsEnabled: Bool = UIAccessibility.isDarkerSystemColorsEnabled

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ACCESSIBILITY OBSERVERS                                                   │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Setup observers for accessibility changes
    private func setupAccessibilityObservers() {
        // VoiceOver status changed
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
            print("🔊 VoiceOver status changed: \(UIAccessibility.isVoiceOverRunning)")
        }

        // Reduce Motion changed
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
            print("🎬 Reduce Motion changed: \(UIAccessibility.isReduceMotionEnabled)")

            // Update animation managers
            self?.updateAnimationManagersForMotion()
        }

        // Reduce Transparency changed
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isReduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
            print("🌫️ Reduce Transparency changed: \(UIAccessibility.isReduceTransparencyEnabled)")
        }

        // Bold Text changed
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.boldTextStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isBoldTextEnabled = UIAccessibility.isBoldTextEnabled
            print("🔤 Bold Text changed: \(UIAccessibility.isBoldTextEnabled)")
        }

        // Darker System Colors (Increase Contrast) changed
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isDarkerSystemColorsEnabled = UIAccessibility.isDarkerSystemColorsEnabled
            print("🎨 Darker System Colors changed: \(UIAccessibility.isDarkerSystemColorsEnabled)")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ANIMATION ADAPTATIONS                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Update animation managers when Reduce Motion changes
    private func updateAnimationManagersForMotion() {
        // Visual settings manager will handle this through its computed properties
        // Just trigger a refresh
        NotificationCenter.default.post(name: .init("ReduceMotionChanged"), object: nil)
    }

    /// Get animation appropriate for current accessibility settings
    /// - Parameter standardAnimation: Standard animation
    /// - Returns: Adapted animation
    func adaptAnimation(_ standardAnimation: Animation) -> Animation {
        if isReduceMotionEnabled {
            // Simple fade instead of complex animations
            return .easeInOut(duration: 0.15)
        }
        return standardAnimation
    }

    /// Whether complex animations should be used
    var shouldUseComplexAnimations: Bool {
        !isReduceMotionEnabled
    }

    /// Whether particle effects should be shown
    var shouldShowParticles: Bool {
        !isReduceMotionEnabled
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ VOICEOVER ANNOUNCEMENTS                                                   │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Announce a message for VoiceOver
    /// - Parameters:
    ///   - message: Message to announce
    ///   - priority: Announcement priority
    func announce(_ message: String, priority: UIAccessibility.Notification = .announcement) {
        guard isVoiceOverRunning else { return }

        UIAccessibility.post(notification: priority, argument: message)
    }

    /// Announce with default notification
    func announceForAccessibility(_ message: String) {
        announce(message)
    }

    /// Announce screen changed (major navigation)
    func announceScreenChanged(_ message: String) {
        announce(message, priority: .screenChanged)
    }

    /// Announce layout changed (minor content update)
    func announceLayoutChanged(_ message: String) {
        announce(message, priority: .layoutChanged)
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ GAME-SPECIFIC ANNOUNCEMENTS                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Announce card dealt
    func announceCardDealt(_ card: Card, to recipient: String) {
        let cardDescription = VoiceOverLabels.cardDescription(card)
        announce("\(cardDescription) dealt to \(recipient)")
    }

    /// Announce hand value
    func announceHandValue(_ value: Int, isSoft: Bool = false) {
        let softness = isSoft ? "soft" : ""
        announce("Hand value: \(softness) \(value)")
    }

    /// Announce game result
    func announceGameResult(_ result: String, payout: Double? = nil) {
        var message = result
        if let payout = payout, payout > 0 {
            message += ". You won \(Int(payout)) dollars"
        }
        announce(message, priority: .announcement)
    }

    /// Announce dealer action
    func announceDealerAction(_ action: String) {
        announce("Dealer \(action)")
    }

    /// Announce bet placed
    func announceBetPlaced(_ amount: Double) {
        announce("Bet placed: \(Int(amount)) dollars")
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ COLOR CONTRAST                                                            │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Get contrast-adjusted color
    /// - Parameter color: Original color
    /// - Returns: Adjusted color if needed
    func contrastAdjustedColor(_ color: Color) -> Color {
        if isDarkerSystemColorsEnabled {
            // Increase contrast
            // This is a simplified approach - real implementation would
            // calculate luminance and adjust accordingly
            return color
        }
        return color
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ACCESSIBILITY FEATURES STATUS                                             │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Get summary of active accessibility features
    var activeFeatures: [String] {
        var features: [String] = []

        if isVoiceOverRunning {
            features.append("VoiceOver")
        }
        if isReduceMotionEnabled {
            features.append("Reduce Motion")
        }
        if isReduceTransparencyEnabled {
            features.append("Reduce Transparency")
        }
        if isBoldTextEnabled {
            features.append("Bold Text")
        }
        if isDarkerSystemColorsEnabled {
            features.append("Increase Contrast")
        }

        return features
    }

    /// Whether any accessibility features are enabled
    var hasActiveFeatures: Bool {
        !activeFeatures.isEmpty
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEBUGGING                                                                 │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Print accessibility status
    func printAccessibilityStatus() {
        print("♿️ Accessibility Status:")
        print("   VoiceOver: \(isVoiceOverRunning ? "ON" : "OFF")")
        print("   Reduce Motion: \(isReduceMotionEnabled ? "ON" : "OFF")")
        print("   Reduce Transparency: \(isReduceTransparencyEnabled ? "ON" : "OFF")")
        print("   Bold Text: \(isBoldTextEnabled ? "ON" : "OFF")")
        print("   Increase Contrast: \(isDarkerSystemColorsEnabled ? "ON" : "OFF")")
        print("   Active Features: \(activeFeatures.joined(separator: ", "))")
    }
}
