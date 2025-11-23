// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ VisualSettingsManager.swift                                                   ║
// ║                                                                               ║
// ║ Manages visual customisation preferences with persistence.                  ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Visual customisation drives player engagement and retention                ║
// ║ • Settings must persist across app sessions                                  ║
// ║ • Changes should apply immediately throughout the app                        ║
// ║ • Premium visuals can drive in-app purchase conversions                      ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Singleton pattern for global access                                        ║
// ║ • ObservableObject for reactive UI updates                                   ║
// ║ • UserDefaults for simple persistence                                        ║
// ║ • Inject settings into animation managers                                    ║
// ║ • Accessibility-first with Reduce Motion support                             ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ VisualSettingsManager                                                         │
// │                                                                               │
// │ Manages all visual customisation settings and preferences.                  │
// └──────────────────────────────────────────────────────────────────────────────┘
@MainActor
class VisualSettingsManager: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SINGLETON                                                                 │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let shared = VisualSettingsManager()

    private init() {
        loadSettings()
        applySettings()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUBLISHED STATE                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Current visual settings
    @Published var settings: VisualSettings = .default {
        didSet {
            saveSettings()
            applySettings()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ USERDEFAULTS KEY                                                          │
    // └──────────────────────────────────────────────────────────────────────────┘

    private let settingsKey = "VisualSettingsManager.Settings"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ LOADING & SAVING                                                          │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Load settings from UserDefaults
    func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let decoded = try? JSONDecoder().decode(VisualSettings.self, from: data) else {
            print("ℹ️ No saved visual settings found, using defaults")
            settings = .default
            return
        }

        settings = decoded
        print("✅ Loaded visual settings")
    }

    /// Save settings to UserDefaults
    func saveSettings() {
        guard let encoded = try? JSONEncoder().encode(settings) else {
            print("❌ Failed to encode visual settings")
            return
        }

        UserDefaults.standard.set(encoded, forKey: settingsKey)
        print("✅ Saved visual settings")
    }

    /// Apply settings to all animation managers
    func applySettings() {
        // Inject settings into animation managers
        CardAnimationManager.shared.visualSettings = settings
        ChipAnimationManager.shared.visualSettings = settings
        TransitionManager.shared.visualSettings = settings

        print("✅ Applied visual settings to animation managers")
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ TABLE FELT COLOUR                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Selected table felt colour
    var tableFeltColor: TableFeltColor {
        get { settings.tableFeltColor }
        set {
            settings.tableFeltColor = newValue
        }
    }

    /// Update table felt colour
    /// - Parameter color: New table felt colour
    func setTableFeltColor(_ color: TableFeltColor) {
        tableFeltColor = color
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CARD BACK DESIGN                                                          │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Selected card back design
    var cardBackDesign: CardBackDesign {
        get { settings.cardBackDesign }
        set {
            settings.cardBackDesign = newValue
        }
    }

    /// Update card back design
    /// - Parameter design: New card back design
    func setCardBackDesign(_ design: CardBackDesign) {
        cardBackDesign = design
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ANIMATION SETTINGS                                                        │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether animations are enabled
    var animationsEnabled: Bool {
        get { settings.animationsEnabled }
        set {
            settings.animationsEnabled = newValue
        }
    }

    /// Animation speed
    var animationSpeed: AnimationSpeed {
        get { settings.animationSpeed }
        set {
            settings.animationSpeed = newValue
        }
    }

    /// Whether particle effects are shown
    var showParticleEffects: Bool {
        get { settings.showParticleEffects }
        set {
            settings.showParticleEffects = newValue
        }
    }

    /// Toggle animations
    func toggleAnimations() {
        animationsEnabled.toggle()
    }

    /// Set animation speed
    /// - Parameter speed: New animation speed
    func setAnimationSpeed(_ speed: AnimationSpeed) {
        animationSpeed = speed
    }

    /// Toggle particle effects
    func toggleParticleEffects() {
        showParticleEffects.toggle()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ VISUAL EFFECTS                                                            │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether card shadows are shown
    var showCardShadows: Bool {
        get { settings.showCardShadows }
        set {
            settings.showCardShadows = newValue
        }
    }

    /// Whether glow effects are shown
    var showGlowEffects: Bool {
        get { settings.showGlowEffects }
        set {
            settings.showGlowEffects = newValue
        }
    }

    /// Whether gradients are used
    var useGradients: Bool {
        get { settings.useGradients }
        set {
            settings.useGradients = newValue
        }
    }

    /// Toggle card shadows
    func toggleCardShadows() {
        showCardShadows.toggle()
    }

    /// Toggle glow effects
    func toggleGlowEffects() {
        showGlowEffects.toggle()
    }

    /// Toggle gradients
    func toggleGradients() {
        useGradients.toggle()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DISPLAY SETTINGS                                                          │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether hand values are shown
    var showHandValues: Bool {
        get { settings.showHandValues }
        set {
            settings.showHandValues = newValue
        }
    }

    /// Whether statistics overlay is shown
    var showStatisticsOverlay: Bool {
        get { settings.showStatisticsOverlay }
        set {
            settings.showStatisticsOverlay = newValue
        }
    }

    /// Card size preference
    var cardSize: CardSizePreference {
        get { settings.cardSize }
        set {
            settings.cardSize = newValue
        }
    }

    /// Toggle hand values
    func toggleHandValues() {
        showHandValues.toggle()
    }

    /// Toggle statistics overlay
    func toggleStatisticsOverlay() {
        showStatisticsOverlay.toggle()
    }

    /// Set card size
    /// - Parameter size: New card size preference
    func setCardSize(_ size: CardSizePreference) {
        cardSize = size
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PRESETS                                                                   │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Apply minimal visual settings (performance mode)
    func applyMinimalPreset() {
        settings = .minimal
    }

    /// Apply maximum visual settings (full effects)
    func applyMaximumPreset() {
        settings = .maximum
    }

    /// Apply accessibility-focused settings
    func applyAccessibilityPreset() {
        settings = .accessibility
    }

    /// Reset to default settings
    func resetToDefaults() {
        settings = .default
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ACCESSIBILITY HELPERS                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Whether animations should play (considering all factors)
    var shouldPlayAnimations: Bool {
        settings.shouldPlayAnimations
    }

    /// Whether particle effects should show (considering all factors)
    var shouldShowParticleEffects: Bool {
        settings.shouldShowParticleEffects
    }

    /// Get animation with accessibility consideration
    /// - Parameter animation: Standard animation
    /// - Returns: Appropriate animation for current settings
    func animation(_ animation: Animation) -> Animation {
        settings.animation(animation)
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ UNLOCK MANAGEMENT                                                         │
    // │                                                                            │
    // │ Track which premium colours/designs are unlocked (for future IAP)        │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Unlocked table felt colours
    @Published var unlockedTableColors: Set<UUID> = []

    /// Unlocked card back designs
    @Published var unlockedCardDesigns: Set<UUID> = []

    /// Check if table colour is unlocked
    /// - Parameter color: Table felt colour
    /// - Returns: True if unlocked or not premium
    func isUnlocked(_ color: TableFeltColor) -> Bool {
        !color.isPremium || unlockedTableColors.contains(color.id)
    }

    /// Check if card design is unlocked
    /// - Parameter design: Card back design
    /// - Returns: True if unlocked or not premium
    func isUnlocked(_ design: CardBackDesign) -> Bool {
        !design.isPremium || unlockedCardDesigns.contains(design.id)
    }

    /// Unlock a table colour
    /// - Parameter color: Table felt colour to unlock
    func unlock(_ color: TableFeltColor) {
        unlockedTableColors.insert(color.id)
        saveUnlocks()
    }

    /// Unlock a card design
    /// - Parameter design: Card back design to unlock
    func unlock(_ design: CardBackDesign) {
        unlockedCardDesigns.insert(design.id)
        saveUnlocks()
    }

    /// Unlock all premium content (for testing or promotion)
    func unlockAllPremium() {
        // Unlock all premium table colours
        for color in TableFeltColor.allColors where color.isPremium {
            unlockedTableColors.insert(color.id)
        }

        // Unlock all premium card designs
        for design in CardBackDesign.allDesigns where design.isPremium {
            unlockedCardDesigns.insert(design.id)
        }

        saveUnlocks()
    }

    /// Save unlock state
    private func saveUnlocks() {
        let tableColorUUIDs = unlockedTableColors.map { $0.uuidString }
        let cardDesignUUIDs = unlockedCardDesigns.map { $0.uuidString }

        UserDefaults.standard.set(tableColorUUIDs, forKey: "UnlockedTableColors")
        UserDefaults.standard.set(cardDesignUUIDs, forKey: "UnlockedCardDesigns")
    }

    /// Load unlock state
    private func loadUnlocks() {
        if let tableColorUUIDs = UserDefaults.standard.array(forKey: "UnlockedTableColors") as? [String] {
            unlockedTableColors = Set(tableColorUUIDs.compactMap { UUID(uuidString: $0) })
        }

        if let cardDesignUUIDs = UserDefaults.standard.array(forKey: "UnlockedCardDesigns") as? [String] {
            unlockedCardDesigns = Set(cardDesignUUIDs.compactMap { UUID(uuidString: $0) })
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEBUG & TESTING                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Print current settings
    func printSettings() {
        print("🎨 Visual Settings:")
        print("   Table: \(tableFeltColor.name)")
        print("   Card Back: \(cardBackDesign.name)")
        print("   Animations: \(animationsEnabled ? "On" : "Off")")
        print("   Speed: \(animationSpeed.rawValue)")
        print("   Particles: \(showParticleEffects ? "On" : "Off")")
        print("   Shadows: \(showCardShadows ? "On" : "Off")")
        print("   Glow: \(showGlowEffects ? "On" : "Off")")
        print("   Gradients: \(useGradients ? "On" : "Off")")
        print("   Card Size: \(cardSize.rawValue)")
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ CONVENIENCE EXTENSIONS                                                        │
// └──────────────────────────────────────────────────────────────────────────────┘
extension VisualSettingsManager {

    /// All available table felt colours (filtered by unlock status)
    var availableTableColors: [TableFeltColor] {
        TableFeltColor.allColors.filter { isUnlocked($0) }
    }

    /// All available card back designs (filtered by unlock status)
    var availableCardDesigns: [CardBackDesign] {
        CardBackDesign.allDesigns.filter { isUnlocked($0) }
    }

    /// Premium table colours that are locked
    var lockedTableColors: [TableFeltColor] {
        TableFeltColor.allColors.filter { $0.isPremium && !isUnlocked($0) }
    }

    /// Premium card designs that are locked
    var lockedCardDesigns: [CardBackDesign] {
        CardBackDesign.allDesigns.filter { $0.isPremium && !isUnlocked($0) }
    }
}
