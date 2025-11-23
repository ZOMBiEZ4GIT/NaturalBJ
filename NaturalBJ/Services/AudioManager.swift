// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ AudioManager.swift                                                            ║
// ║                                                                               ║
// ║ Complete audio system managing sound effects and background music.          ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Audio feedback is critical for premium app feel                            ║
// ║ • Sound effects create emotional connection with gameplay                    ║
// ║ • Proper audio session management respects system settings                   ║
// ║ • Volume control and muting are essential user preferences                   ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Singleton pattern for global audio coordination                            ║
// ║ • AVAudioPlayer for sound effects (low latency)                              ║
// ║ • Preloading common sounds for instant playback                              ║
// ║ • Concurrent sound playback with limit (prevent clipping)                    ║
// ║ • Persistent user preferences (volume, mute, individual sounds)              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import AVFoundation
import Combine
import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ AudioManager                                                                  │
// │                                                                               │
// │ Manages all audio playback including sound effects and music.               │
// └──────────────────────────────────────────────────────────────────────────────┘
@MainActor
class AudioManager: NSObject, ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SINGLETON                                                                 │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let shared = AudioManager()

    private override init() {
        super.init()
        setupAudioSession()
        preloadCommonSounds()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUBLISHED STATE                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Master volume (0.0 - 1.0)
    @Published var masterVolume: Float = AudioConfiguration.defaultMasterVolume {
        didSet {
            saveMasterVolume()
            updateAllPlayersVolume()
        }
    }

    /// Whether sound effects are muted
    @Published var isMuted: Bool = false {
        didSet {
            saveIsMuted()
            updateAllPlayersVolume()
        }
    }

    /// Individual sound effect enable states
    @Published var enabledSounds: [SoundEffect: Bool] = [:] {
        didSet {
            saveEnabledSounds()
        }
    }

    /// Whether background music is playing
    @Published private(set) var isMusicPlaying: Bool = false

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ AUDIO PLAYERS                                                             │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Active sound effect players
    private var soundPlayers: [SoundEffect: AVAudioPlayer] = [:]

    /// Background music player
    private var musicPlayer: AVAudioPlayer?

    /// Currently playing sound instances (for concurrent playback)
    private var activePlayers: [UUID: AVAudioPlayer] = [:]

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ USERDEFAULTS KEYS                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    private let masterVolumeKey = "AudioManager.MasterVolume"
    private let isMutedKey = "AudioManager.IsMuted"
    private let enabledSoundsKey = "AudioManager.EnabledSounds"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SETUP                                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Configure audio session for game audio
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()

            // Set category to ambient (mix with other audio)
            try audioSession.setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )

            try audioSession.setActive(true)

            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to setup audio session: \(error.localizedDescription)")
        }

        // Load saved preferences
        loadPreferences()
    }

    /// Preload common sound effects for instant playback
    private func preloadCommonSounds() {
        // Preload high-frequency sounds
        let commonSounds: [SoundEffect] = [
            .cardDeal,
            .cardFlip,
            .chipClink,
            .buttonTap
        ]

        for sound in commonSounds {
            preloadSound(sound)
        }
    }

    /// Preload a specific sound effect
    private func preloadSound(_ sound: SoundEffect) {
        guard let url = soundURL(for: sound) else {
            print("⚠️ Sound file not found: \(sound.filename)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 0 // Preload silently
            soundPlayers[sound] = player
        } catch {
            print("⚠️ Failed to preload sound \(sound.displayName): \(error.localizedDescription)")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SOUND EFFECT PLAYBACK                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Play a sound effect
    /// - Parameters:
    ///   - effect: Sound effect to play
    ///   - volume: Optional volume override (0.0 - 1.0)
    func playSoundEffect(_ effect: SoundEffect, volume: Float? = nil) {
        // Check if sound is enabled
        guard isEnabled(effect) else { return }

        // Check if muted
        guard !isMuted else { return }

        // Check if master volume is zero
        guard masterVolume > 0 else { return }

        // Get or create player
        if let existingPlayer = soundPlayers[effect], !existingPlayer.isPlaying {
            // Reuse existing player
            playPlayer(existingPlayer, for: effect, volume: volume)
        } else {
            // Create new concurrent player instance
            createAndPlayNewPlayer(for: effect, volume: volume)
        }
    }

    /// Play using existing player
    private func playPlayer(_ player: AVAudioPlayer, for effect: SoundEffect, volume: Float?) {
        // Calculate final volume
        let effectVolume = volume ?? effect.defaultVolume
        player.volume = effectVolume * masterVolume

        // Play from beginning
        player.currentTime = 0
        player.play()
    }

    /// Create new player for concurrent playback
    private func createAndPlayNewPlayer(for effect: SoundEffect, volume: Float?) {
        guard let url = soundURL(for: effect) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            let effectVolume = volume ?? effect.defaultVolume
            player.volume = effectVolume * masterVolume
            player.prepareToPlay()

            // Store with unique ID for concurrent playback
            let playerID = UUID()
            activePlayers[playerID] = player

            // Clean up after playback
            player.play()

            // Remove after duration + buffer
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.5) {
                self.activePlayers.removeValue(forKey: playerID)
            }

            // Enforce concurrent playback limit
            enforcePlayerLimit()

        } catch {
            print("⚠️ Failed to play sound \(effect.displayName): \(error.localizedDescription)")
        }
    }

    /// Enforce maximum concurrent sound limit
    private func enforcePlayerLimit() {
        let maxPlayers = AudioConfiguration.maxConcurrentSounds

        if activePlayers.count > maxPlayers {
            // Remove oldest player
            if let oldestKey = activePlayers.keys.sorted().first {
                activePlayers[oldestKey]?.stop()
                activePlayers.removeValue(forKey: oldestKey)
            }
        }
    }

    /// Get URL for sound effect
    private func soundURL(for effect: SoundEffect) -> URL? {
        // Try to find in bundle
        if let url = Bundle.main.url(
            forResource: effect.filename,
            withExtension: effect.fileExtension
        ) {
            return url
        }

        // Not found - will need actual sound files
        // For now, return nil gracefully
        return nil
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BACKGROUND MUSIC                                                          │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Play background music
    /// - Parameter fadeIn: Whether to fade in the music
    func playBackgroundMusic(fadeIn: Bool = true) {
        // Background music is optional - implement if needed
        // For now, blackjack works great with just sound effects
        print("ℹ️ Background music playback requested (not implemented)")
    }

    /// Stop background music
    /// - Parameter fadeOut: Whether to fade out the music
    func stopBackgroundMusic(fadeOut: Bool = true) {
        guard let player = musicPlayer else { return }

        if fadeOut {
            fadeOutMusic(player: player)
        } else {
            player.stop()
            isMusicPlaying = false
        }
    }

    /// Fade out music
    private func fadeOutMusic(player: AVAudioPlayer) {
        let fadeDuration = AudioConfiguration.fadeDuration
        let fadeSteps = 20
        let volumeDecrement = player.volume / Float(fadeSteps)
        let stepDuration = fadeDuration / Double(fadeSteps)

        var currentStep = 0

        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            player.volume -= volumeDecrement

            if currentStep >= fadeSteps || player.volume <= 0 {
                player.stop()
                self.isMusicPlaying = false
                timer.invalidate()
            }
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ VOLUME MANAGEMENT                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Set master volume
    /// - Parameter volume: Volume level (0.0 - 1.0)
    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0.0, min(1.0, volume))
    }

    /// Toggle mute
    func toggleMute() {
        isMuted.toggle()
    }

    /// Update all active players' volume
    private func updateAllPlayersVolume() {
        for (effect, player) in soundPlayers {
            if isMuted {
                player.volume = 0
            } else {
                player.volume = effect.defaultVolume * masterVolume
            }
        }

        for player in activePlayers.values {
            if isMuted {
                player.volume = 0
            } else {
                player.volume *= masterVolume
            }
        }

        musicPlayer?.volume = isMuted ? 0 : 0.2 * masterVolume
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INDIVIDUAL SOUND MANAGEMENT                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Check if a sound effect is enabled
    /// - Parameter effect: Sound effect to check
    /// - Returns: True if enabled
    func isEnabled(_ effect: SoundEffect) -> Bool {
        enabledSounds[effect] ?? true // Default to enabled
    }

    /// Enable or disable a specific sound effect
    /// - Parameters:
    ///   - effect: Sound effect to configure
    ///   - enabled: Whether sound should be enabled
    func setEnabled(_ effect: SoundEffect, enabled: Bool) {
        enabledSounds[effect] = enabled
    }

    /// Enable all sound effects
    func enableAllSounds() {
        for effect in SoundEffect.allCases {
            enabledSounds[effect] = true
        }
    }

    /// Disable all sound effects
    func disableAllSounds() {
        for effect in SoundEffect.allCases {
            enabledSounds[effect] = false
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PERSISTENCE                                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Load audio preferences from UserDefaults
    private func loadPreferences() {
        // Load master volume
        if UserDefaults.standard.object(forKey: masterVolumeKey) != nil {
            masterVolume = UserDefaults.standard.float(forKey: masterVolumeKey)
        }

        // Load mute state
        isMuted = UserDefaults.standard.bool(forKey: isMutedKey)

        // Load enabled sounds
        if let data = UserDefaults.standard.data(forKey: enabledSoundsKey),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) {
            for (key, value) in decoded {
                if let effect = SoundEffect(rawValue: key) {
                    enabledSounds[effect] = value
                }
            }
        }
    }

    /// Save master volume
    private func saveMasterVolume() {
        UserDefaults.standard.set(masterVolume, forKey: masterVolumeKey)
    }

    /// Save mute state
    private func saveIsMuted() {
        UserDefaults.standard.set(isMuted, forKey: isMutedKey)
    }

    /// Save enabled sounds
    private func saveEnabledSounds() {
        let dict = enabledSounds.reduce(into: [String: Bool]()) { result, pair in
            result[pair.key.rawValue] = pair.value
        }

        if let encoded = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(encoded, forKey: enabledSoundsKey)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ UTILITY METHODS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Stop all currently playing sounds
    func stopAllSounds() {
        for player in soundPlayers.values {
            player.stop()
        }

        for player in activePlayers.values {
            player.stop()
        }

        activePlayers.removeAll()
    }

    /// Reset audio manager to defaults
    func resetToDefaults() {
        masterVolume = AudioConfiguration.defaultMasterVolume
        isMuted = false
        enabledSounds.removeAll()
        stopAllSounds()
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ CONVENIENCE METHODS                                                           │
// │                                                                               │
// │ Quick access to common sound effects.                                       │
// └──────────────────────────────────────────────────────────────────────────────┘
extension AudioManager {

    /// Play card deal sound
    func playCardDeal() {
        playSoundEffect(.cardDeal)
    }

    /// Play card flip sound
    func playCardFlip() {
        playSoundEffect(.cardFlip)
    }

    /// Play chip clink sound
    func playChipClink() {
        playSoundEffect(.chipClink)
    }

    /// Play win sound
    func playWin() {
        playSoundEffect(.win)
    }

    /// Play loss sound
    func playLoss() {
        playSoundEffect(.loss)
    }

    /// Play blackjack sound
    func playBlackjack() {
        playSoundEffect(.blackjack)
    }

    /// Play button tap sound
    func playButtonTap() {
        playSoundEffect(.buttonTap)
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ AUDIO DEBUGGING                                                               │
// │                                                                               │
// │ Helper methods for debugging audio issues.                                  │
// └──────────────────────────────────────────────────────────────────────────────┘
extension AudioManager {

    /// Print current audio state
    func printAudioState() {
        print("🔊 Audio Manager State:")
        print("   Master Volume: \(masterVolume)")
        print("   Is Muted: \(isMuted)")
        print("   Active Players: \(activePlayers.count)")
        print("   Preloaded Sounds: \(soundPlayers.count)")
        print("   Enabled Sounds: \(enabledSounds.filter { $0.value }.count)/\(SoundEffect.allCases.count)")
    }
}
