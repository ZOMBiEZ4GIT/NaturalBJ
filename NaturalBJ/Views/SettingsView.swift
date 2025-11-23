//
//  SettingsView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6.5: Tutorial & Help System - View Layer
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ SettingsView.swift                                                            ║
// ║                                                                               ║
// ║ App settings and customisation screen.                                       ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Provides access to all app customisation options                           ║
// ║ • Tutorial and Help access point                                             ║
// ║ • Visual, audio, and gameplay preferences                                    ║
// ║ • Follows iOS Settings app patterns                                          ║
// ║                                                                               ║
// ║ SECTIONS:                                                                     ║
// ║ 1. Tutorial & Help                                                            ║
// ║ 2. Visual Settings (planned for Phase 5)                                     ║
// ║ 3. Audio & Haptics (planned for Phase 5)                                     ║
// ║ 4. Gameplay                                                                   ║
// ║ 5. About                                                                      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ ⚙️ SETTINGS VIEW                                                          │
// │                                                                           │
// │ Main settings screen with grouped sections.                              │
// └──────────────────────────────────────────────────────────────────────────┘

struct SettingsView: View {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 DEPENDENCIES                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    @ObservedObject private var appState = AppStateManager.shared
    @ObservedObject private var tutorialManager = TutorialManager.shared
    @Environment(\.dismiss) private var dismiss

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 PHASE 7: ANIMATION, AUDIO & VISUAL MANAGERS                       │
    // └──────────────────────────────────────────────────────────────────────┘

    @EnvironmentObject var visualSettings: VisualSettingsManager
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var hapticManager = HapticManager.shared

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏆 PHASE 8: ACHIEVEMENT & PROGRESSION MANAGERS                       │
    // └──────────────────────────────────────────────────────────────────────┘

    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var progressionManager = ProgressionManager.shared

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎯 PHASE 9: CHALLENGE MANAGER                                        │
    // └──────────────────────────────────────────────────────────────────────┘

    @StateObject private var challengeManager = ChallengeManager.shared

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 STATE                                                              │
    // └──────────────────────────────────────────────────────────────────────┘

    @State private var showHelp = false
    @State private var showReplayConfirmation = false
    @State private var showDealerSelection = false
    @State private var tutorialHintsEnabled: Bool
    @State private var contextualHintsEnabled: Bool

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                        │
    // └──────────────────────────────────────────────────────────────────────┘

    init() {
        let progress = TutorialProgress.load()
        _tutorialHintsEnabled = State(initialValue: progress.tutorialHintsEnabled)
        _contextualHintsEnabled = State(initialValue: progress.showContextualHints)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                               │
    // └──────────────────────────────────────────────────────────────────────┘

    var body: some View {
        NavigationView {
            List {
                // Current Dealer section - PRIORITY PLACEMENT
                currentDealerSection

                // Tutorial & Help section
                tutorialHelpSection

                // Gameplay section
                gameplaySection

                // Phase 7: Visual Settings section
                visualSettingsSection

                // Phase 7: Audio Settings section
                audioSettingsSection

                // Phase 7: Haptic Settings section
                hapticSettingsSection

                // Phase 8-10: Progress Hub (Achievements, Challenges, Social)
                progressHubSection

                // About section
                aboutSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.info)
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .sheet(isPresented: $showDealerSelection) {
            SimpleDealerSelectionView(
                currentDealer: appState.selectedDealer,
                onDealerSelected: { dealer in
                    appState.setDealer(dealer)
                    showDealerSelection = false
                }
            )
        }
        .alert("Replay Tutorial?", isPresented: $showReplayConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Start Tutorial") {
                replayTutorial()
            }
        } message: {
            Text("This will restart the tutorial from the beginning. Your game progress will not be affected.")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎲 CURRENT DEALER SECTION                                            │
    // │                                                                       │
    // │ Core app feature - dealer selection now PROMINENTLY PLACED           │
    // └──────────────────────────────────────────────────────────────────────┘

    private var currentDealerSection: some View {
        Section {
            // Current dealer display with avatar
            HStack(spacing: 12) {
                DealerAvatarView(dealer: appState.selectedDealer, size: .standard)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(appState.selectedDealer.tagline)
                        .font(.caption)
                        .foregroundColor(.mediumGrey)
                        .multilineTextAlignment(.trailing)

                    Text("House Edge: ~\(String(format: "%.2f", appState.selectedDealer.rules.estimatedHouseEdge))%")
                        .font(.caption2)
                        .foregroundColor(.mediumGrey)
                }
            }
            .padding(.vertical, 8)

            // Change dealer button
            Button(action: {
                showDealerSelection = true
            }) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.info)
                    Text("Change Dealer")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.mediumGrey)
                }
            }
        } header: {
            Text("Current Dealer")
        } footer: {
            Text("Each dealer has unique rules and personality. Changing dealers will start a new shoe but preserve your bankroll.")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎓 TUTORIAL & HELP SECTION                                            │
    // └──────────────────────────────────────────────────────────────────────┘

    private var tutorialHelpSection: some View {
        Section {
            // Tutorial Hints toggle
            Toggle(isOn: Binding(
                get: { tutorialHintsEnabled },
                set: { newValue in
                    tutorialHintsEnabled = newValue
                    tutorialManager.setTutorialHintsEnabled(newValue)
                }
            )) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.warning)
                    Text("Tutorial Hints")
                }
            }
            .tint(.info)

            // Contextual Hints toggle
            Toggle(isOn: Binding(
                get: { contextualHintsEnabled },
                set: { newValue in
                    contextualHintsEnabled = newValue
                    tutorialManager.setContextualHintsEnabled(newValue)
                }
            )) {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.warning)
                    Text("Strategy Hints")
                }
            }
            .tint(.info)

            // Replay Tutorial
            Button(action: {
                showReplayConfirmation = true
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.info)
                    Text("Replay Tutorial")
                        .foregroundColor(.white)
                }
            }

            // Help & Rules
            Button(action: {
                showHelp = true
            }) {
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.info)
                    Text("Help & Rules")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.mediumGrey)
                }
            }
        } header: {
            Text("Tutorial & Help")
        } footer: {
            Text("Strategy hints provide tips during gameplay based on your hand.")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📈 PHASE 8-10: PROGRESS HUB (Consolidated)                           │
    // │                                                                       │
    // │ Replaces separate Achievements and Challenges sections               │
    // │ Makes Settings cleaner by grouping progression features              │
    // └──────────────────────────────────────────────────────────────────────┘

    private var progressHubSection: some View {
        Section {
            // Progress & Achievements navigation (consolidated)
            NavigationLink(destination: ProgressView()) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.info, Color.info.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)

                        VStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.white)

                            Text("\(progressionManager.currentLevel)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress & Achievements")
                            .foregroundColor(.white)
                            .font(.headline)

                        HStack(spacing: 12) {
                            // Achievements count
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                Text("\(achievementManager.unlockedCount)/\(achievementManager.totalAchievements)")
                                    .font(.caption)
                                    .foregroundColor(.mediumGrey)
                            }

                            // Challenges count
                            HStack(spacing: 4) {
                                Image(systemName: "target")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                let activeCount = challengeManager.getAllActiveChallenges().filter { !$0.isCompleted }.count
                                Text("\(activeCount) active")
                                    .font(.caption)
                                    .foregroundColor(.mediumGrey)
                            }

                            // Streak
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                                Text("\(challengeManager.dailyLoginStreak)d")
                                    .font(.caption)
                                    .foregroundColor(.mediumGrey)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.mediumGrey)
                }
            }
        } header: {
            Text("Progress & Achievements")
        } footer: {
            Text("View your level, achievements, challenges, and progress. Earn XP to unlock rewards!")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 PHASE 7: VISUAL SETTINGS SECTION                                  │
    // └──────────────────────────────────────────────────────────────────────┘

    private var visualSettingsSection: some View {
        Section {
            // Table Felt Colour picker
            Picker("Table Felt", selection: $visualSettings.settings.tableFeltColor) {
                ForEach(TableFeltColor.allColors) { color in
                    HStack {
                        Circle()
                            .fill(color.color)
                            .frame(width: 20, height: 20)
                        Text(color.name)
                    }
                    .tag(color)
                }
            }

            // Card Back Design picker
            Picker("Card Back", selection: $visualSettings.settings.cardBackDesign) {
                ForEach(CardBackDesign.allDesigns) { design in
                    Text(design.name)
                        .tag(design)
                }
            }

            // Animation Speed picker
            Picker("Animation Speed", selection: $visualSettings.settings.animationSpeed) {
                ForEach(AnimationSpeed.allCases, id: \.self) { speed in
                    Text(speed.rawValue.capitalized)
                        .tag(speed)
                }
            }

            // Visual Effects toggles
            Toggle(isOn: $visualSettings.settings.showCardShadows) {
                HStack {
                    Image(systemName: "shadow")
                        .foregroundColor(.info)
                    Text("Card Shadows")
                }
            }
            .tint(.info)

            Toggle(isOn: $visualSettings.settings.showGlowEffects) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.warning)
                    Text("Glow Effects")
                }
            }
            .tint(.info)

            Toggle(isOn: $visualSettings.settings.showParticleEffects) {
                HStack {
                    Image(systemName: "sparkle")
                        .foregroundColor(.success)
                    Text("Particle Effects")
                }
            }
            .tint(.info)

            Toggle(isOn: $visualSettings.settings.useGradients) {
                HStack {
                    Image(systemName: "paintpalette.fill")
                        .foregroundColor(.info)
                    Text("Use Gradients")
                }
            }
            .tint(.info)
        } header: {
            Text("Visual Settings")
        } footer: {
            Text("Customise table appearance and visual effects. Premium colours and card backs available via in-app purchase.")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔊 PHASE 7: AUDIO SETTINGS SECTION                                   │
    // └──────────────────────────────────────────────────────────────────────┘

    private var audioSettingsSection: some View {
        Section {
            // Master sound effects toggle
            Toggle(isOn: Binding(
                get: { !audioManager.isMuted },
                set: { _ in audioManager.toggleMute() }
            )) {
                HStack {
                    Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                        .foregroundColor(.info)
                    Text("Sound Effects")
                }
            }
            .tint(.info)

            // Master Volume slider
            if !audioManager.isMuted {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.mediumGrey)
                        Text("Master Volume")
                        Spacer()
                        Text("\(Int(audioManager.masterVolume * 100))%")
                            .foregroundColor(.mediumGrey)
                    }

                    Slider(value: $audioManager.masterVolume, in: 0...1, step: 0.1)
                        .tint(.info)
                }
            }
        } header: {
            Text("Audio Settings")
        } footer: {
            Text("Control sound effects and volume. Individual sound controls available in Advanced Audio Settings.")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📳 PHASE 7: HAPTIC SETTINGS SECTION                                  │
    // └──────────────────────────────────────────────────────────────────────┘

    private var hapticSettingsSection: some View {
        Section {
            // Master haptics toggle
            Toggle(isOn: $hapticManager.isEnabled) {
                HStack {
                    Image(systemName: hapticManager.isEnabled ? "hand.tap.fill" : "hand.raised.slash.fill")
                        .foregroundColor(.info)
                    Text("Haptic Feedback")
                }
            }
            .tint(.info)

            // Haptic Intensity picker
            if hapticManager.isEnabled {
                Picker("Intensity", selection: $hapticManager.intensity) {
                    ForEach(HapticIntensity.allCases, id: \.self) { intensity in
                        Text(intensity.rawValue.capitalized)
                            .tag(intensity)
                    }
                }
            }
        } header: {
            Text("Haptic Settings")
        } footer: {
            Text("Haptic feedback provides tactile responses for game actions. Respects Reduce Motion accessibility settings.")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎮 GAMEPLAY SECTION                                                   │
    // └──────────────────────────────────────────────────────────────────────┘

    private var gameplaySection: some View {
        Section {
            // Tutorial completion status
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(tutorialManager.tutorialProgress.hasCompletedTutorial ? .success : .mediumGrey)
                Text("Tutorial Completed")
                Spacer()
                Text(tutorialManager.tutorialProgress.hasCompletedTutorial ? "Yes" : "No")
                    .foregroundColor(.mediumGrey)
            }

            // Hands played (placeholder for future statistics integration)
            HStack {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(.info)
                Text("Hands Played")
                Spacer()
                Text("--")
                    .foregroundColor(.mediumGrey)
            }
        } header: {
            Text("Gameplay")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ℹ️ ABOUT SECTION                                                      │
    // └──────────────────────────────────────────────────────────────────────┘

    private var aboutSection: some View {
        Section {
            // Version
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.mediumGrey)
            }

            // Developer
            HStack {
                Text("Developer")
                Spacer()
                Text("Natural Blackjack")
                    .foregroundColor(.mediumGrey)
            }
        } header: {
            Text("About")
        } footer: {
            Text("Natural - Premium Blackjack\nPhase 6.5: Tutorial & Help System")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔄 REPLAY TUTORIAL                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    private func replayTutorial() {
        tutorialManager.resetTutorial()
        tutorialManager.startTutorial()
        dismiss()
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

#Preview("Settings View") {
    SettingsView()
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In GameView:                                                                  ║
// ║   @State private var showSettings = false                                     ║
// ║                                                                               ║
// ║   Button(action: {                                                            ║
// ║       showSettings = true                                                     ║
// ║   }) {                                                                         ║
// ║       Image(systemName: "gearshape")                                          ║
// ║   }                                                                            ║
// ║   .sheet(isPresented: $showSettings) {                                        ║
// ║       SettingsView()                                                          ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
