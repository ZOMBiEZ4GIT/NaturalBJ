//
//  TutorialProgress.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6: Tutorial & Help System
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ TutorialProgress.swift                                                        ║
// ║                                                                               ║
// ║ Tracks user's progress through the tutorial system.                          ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Tutorial state must persist across app sessions                            ║
// ║ • Users can skip, pause, or replay tutorial at any time                      ║
// ║ • Contextual hints can be toggled independently of tutorial completion       ║
// ║ • Progress tracking helps us understand where users struggle                 ║
// ║                                                                               ║
// ║ PERSISTENCE STRATEGY:                                                         ║
// ║ • Uses UserDefaults for lightweight, fast access                             ║
// ║ • Codable for easy serialisation                                             ║
// ║ • Changes saved immediately to prevent data loss                             ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 📊 TUTORIAL PROGRESS                                                      │
// │                                                                           │
// │ Represents the user's current state in the tutorial system.              │
// │ Persisted to UserDefaults for cross-session continuity.                  │
// └──────────────────────────────────────────────────────────────────────────┘

struct TutorialProgress: Codable, Equatable {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📝 PROPERTIES                                                         │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Has the user completed the full tutorial?
    var hasCompletedTutorial: Bool

    /// Current step in tutorial (nil if not in tutorial)
    var currentStepType: TutorialStepType?

    /// Set of completed step types (for resuming partial progress)
    var completedSteps: Set<TutorialStepType>

    /// Are tutorial hints enabled? (independent of tutorial completion)
    var tutorialHintsEnabled: Bool

    /// Should we show contextual hints during regular gameplay?
    var showContextualHints: Bool

    /// Timestamp of when tutorial was last started
    var lastTutorialStartDate: Date?

    /// Timestamp of when tutorial was completed
    var completionDate: Date?

    /// Number of times tutorial has been skipped (analytics)
    var skipCount: Int

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISERS                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Default initialiser for new users
    init() {
        self.hasCompletedTutorial = false
        self.currentStepType = nil
        self.completedSteps = []
        self.tutorialHintsEnabled = true
        self.showContextualHints = true
        self.lastTutorialStartDate = nil
        self.completionDate = nil
        self.skipCount = 0
    }

    /// Full initialiser for testing or custom states
    init(
        hasCompletedTutorial: Bool,
        currentStepType: TutorialStepType?,
        completedSteps: Set<TutorialStepType>,
        tutorialHintsEnabled: Bool,
        showContextualHints: Bool,
        lastTutorialStartDate: Date?,
        completionDate: Date?,
        skipCount: Int
    ) {
        self.hasCompletedTutorial = hasCompletedTutorial
        self.currentStepType = currentStepType
        self.completedSteps = completedSteps
        self.tutorialHintsEnabled = tutorialHintsEnabled
        self.showContextualHints = showContextualHints
        self.lastTutorialStartDate = lastTutorialStartDate
        self.completionDate = completionDate
        self.skipCount = skipCount
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎯 COMPUTED PROPERTIES                                                │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Is tutorial currently active?
    var isTutorialActive: Bool {
        return currentStepType != nil && !hasCompletedTutorial
    }

    /// Progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard !completedSteps.isEmpty else { return 0.0 }
        let totalSteps = Double(TutorialStepType.allCases.count)
        let completed = Double(completedSteps.count)
        return completed / totalSteps
    }

    /// Should we auto-start tutorial for first-time users?
    var shouldAutoStartTutorial: Bool {
        return !hasCompletedTutorial && lastTutorialStartDate == nil
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔨 MUTATING METHODS                                                   │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Mark a specific step as completed
    mutating func markStepComplete(_ stepType: TutorialStepType) {
        completedSteps.insert(stepType)
        print("✅ Tutorial step completed: \(stepType.displayName)")
    }

    /// Advance to next step in tutorial
    mutating func advanceToNextStep() {
        guard let current = currentStepType else {
            // Start from beginning
            currentStepType = TutorialStepType.allCases.first
            return
        }

        // Mark current step as complete
        markStepComplete(current)

        // Find next step
        if let currentIndex = TutorialStepType.allCases.firstIndex(of: current) {
            let nextIndex = currentIndex + 1
            if nextIndex < TutorialStepType.allCases.count {
                currentStepType = TutorialStepType.allCases[nextIndex]
                print("▶️ Advanced to tutorial step: \(currentStepType!.displayName)")
            } else {
                // Completed all steps!
                completeTutorial()
            }
        }
    }

    /// Start tutorial from beginning
    mutating func startTutorial() {
        currentStepType = TutorialStepType.allCases.first
        lastTutorialStartDate = Date()
        print("🎓 Tutorial started")
    }

    /// Skip tutorial completely
    mutating func skipTutorial() {
        currentStepType = nil
        hasCompletedTutorial = true
        skipCount += 1
        completionDate = Date()
        print("⏭️ Tutorial skipped (skip count: \(skipCount))")
    }

    /// Mark tutorial as completed
    mutating func completeTutorial() {
        hasCompletedTutorial = true
        currentStepType = nil
        completionDate = Date()
        print("🎉 Tutorial completed!")
    }

    /// Reset tutorial progress (for replay)
    mutating func resetTutorial() {
        hasCompletedTutorial = false
        currentStepType = nil
        completedSteps = []
        lastTutorialStartDate = nil
        completionDate = nil
        // Note: Don't reset skipCount - it's analytics data
        print("🔄 Tutorial reset")
    }

    /// Toggle tutorial hints on/off
    mutating func setTutorialHintsEnabled(_ enabled: Bool) {
        tutorialHintsEnabled = enabled
        print("💡 Tutorial hints \(enabled ? "enabled" : "disabled")")
    }

    /// Toggle contextual hints on/off
    mutating func setContextualHintsEnabled(_ enabled: Bool) {
        showContextualHints = enabled
        print("💡 Contextual hints \(enabled ? "enabled" : "disabled")")
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 💾 PERSISTENCE HELPER                                                         ║
// ║                                                                               ║
// ║ Manages saving/loading TutorialProgress to/from UserDefaults.                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

extension TutorialProgress {

    // UserDefaults key
    private static let storageKey = "com.natural.blackjack.tutorialProgress"

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 💾 SAVE TO USER DEFAULTS                                              │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Save current progress to UserDefaults
    func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
            print("💾 Tutorial progress saved")
        } catch {
            print("❌ Failed to save tutorial progress: \(error)")
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 📂 LOAD FROM USER DEFAULTS                                            │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Load progress from UserDefaults (or create new if none exists)
    static func load() -> TutorialProgress {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            print("📝 No saved tutorial progress - creating new")
            return TutorialProgress()
        }

        do {
            let decoder = JSONDecoder()
            let progress = try decoder.decode(TutorialProgress.self, from: data)
            print("📂 Tutorial progress loaded")
            return progress
        } catch {
            print("❌ Failed to load tutorial progress: \(error)")
            return TutorialProgress()
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🗑️ CLEAR SAVED DATA                                                   │
    // └──────────────────────────────────────────────────────────────────────┘

    /// Delete saved progress (for testing or reset)
    static func clearSaved() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        print("🗑️ Tutorial progress cleared from storage")
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ Load existing progress:                                                       ║
// ║   var progress = TutorialProgress.load()                                      ║
// ║                                                                               ║
// ║ Start tutorial:                                                               ║
// ║   progress.startTutorial()                                                    ║
// ║   progress.save()                                                             ║
// ║                                                                               ║
// ║ Advance to next step:                                                         ║
// ║   progress.advanceToNextStep()                                                ║
// ║   progress.save()                                                             ║
// ║                                                                               ║
// ║ Skip tutorial:                                                                ║
// ║   progress.skipTutorial()                                                     ║
// ║   progress.save()                                                             ║
// ║                                                                               ║
// ║ Check if tutorial should auto-start:                                          ║
// ║   if progress.shouldAutoStartTutorial {                                       ║
// ║       // Show tutorial welcome screen                                         ║
// ║   }                                                                            ║
// ║                                                                               ║
// ║ Toggle hints:                                                                 ║
// ║   progress.setContextualHintsEnabled(false)                                   ║
// ║   progress.save()                                                             ║
// ║                                                                               ║
// ║ Replay tutorial:                                                              ║
// ║   progress.resetTutorial()                                                    ║
// ║   progress.startTutorial()                                                    ║
// ║   progress.save()                                                             ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
