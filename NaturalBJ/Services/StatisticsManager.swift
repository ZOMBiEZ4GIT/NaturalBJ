//
//  StatisticsManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 STATISTICS MANAGER SERVICE                                              ║
// ║                                                                            ║
// ║ Purpose: Central coordinator for all statistics tracking and management   ║
// ║ Business Context: This is the single source of truth for all statistics.  ║
// ║                   It manages the current session, saves/loads history,    ║
// ║                   and calculates aggregated statistics on demand.         ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Manage current active session                                           ║
// ║ • Track hand results as they happen                                       ║
// ║ • Save/load session history via StatisticsPersistence                     ║
// ║ • Calculate dealer statistics and overall statistics                      ║
// ║ • Provide statistics to ViewModels for display                            ║
// ║ • Handle session start/end lifecycle                                      ║
// ║                                                                            ║
// ║ Architecture Pattern: Singleton service                                    ║
// ║ Used By: GameViewModel (records hands), StatisticsViewModel (reads stats) ║
// ║ Uses: StatisticsPersistence (storage), Session/HandResult models          ║
// ║                                                                            ║
// ║ Related Spec: See "Statistics & Session History" (lines 178-215)          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation
import Combine

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📊 STATISTICS MANAGER CLASS                                                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class StatisticsManager: ObservableObject {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON PATTERN                                             │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = StatisticsManager()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PUBLISHED STATE                                               │
    // │                                                                  │
    // │ These properties trigger UI updates when changed                │
    // └─────────────────────────────────────────────────────────────────┘

    /// Current active session (nil if no session running)
    @Published private(set) var currentSession: Session?

    /// All past sessions (loaded from disk)
    @Published private(set) var sessionHistory: [Session] = []

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    /// Persistence layer
    private let persistence = StatisticsPersistence.shared

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // │                                                                  │
    // │ Private to enforce singleton pattern                            │
    // │ Loads session history from disk on creation                     │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {
        print("📊 StatisticsManager initialising...")
        loadSessionHistory()
        print("📊 StatisticsManager ready (\(sessionHistory.count) sessions loaded)")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎮 SESSION LIFECYCLE                                               ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ▶️ START NEW SESSION                                             │
    // │                                                                  │
    // │ Business Logic: Begin tracking a new playing session            │
    // │ Called by: GameViewModel when player places first bet           │
    // │                                                                  │
    // │ Parameters:                                                      │
    // │ • dealerName: Name of dealer (e.g., "Ruby", "Lucky")            │
    // │ • dealerIcon: Emoji for dealer (e.g., "♦️", "🍀")               │
    // │ • startingBankroll: Player's bankroll at session start          │
    // │                                                                  │
    // │ Side Effects:                                                    │
    // │ • Creates new Session object                                    │
    // │ • Sets as currentSession                                        │
    // │ • Publishes update to subscribers                               │
    // └─────────────────────────────────────────────────────────────────┘

    func startSession(dealerName: String, dealerIcon: String, startingBankroll: Double) {
        // End existing session if any
        if let existing = currentSession, existing.isActive {
            print("⚠️ Ending previous session before starting new one")
            endSession(finalBankroll: existing.currentBankroll)
        }

        // Create new session
        let session = Session(
            dealerName: dealerName,
            dealerIcon: dealerIcon,
            startingBankroll: startingBankroll,
            currentBankroll: startingBankroll
        )

        currentSession = session
        print("▶️ Started new session with \(dealerName) \(dealerIcon) (bankroll: $\(startingBankroll))")
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ⏹️ END CURRENT SESSION                                           │
    // │                                                                  │
    // │ Business Logic: Finish current session and save to history      │
    // │ Called by: GameViewModel when player quits or switches dealers  │
    // │                                                                  │
    // │ Parameters:                                                      │
    // │ • finalBankroll: Player's final bankroll amount                 │
    // │                                                                  │
    // │ Side Effects:                                                    │
    // │ • Marks session as ended with timestamp                         │
    // │ • Adds to session history                                       │
    // │ • Saves history to disk                                         │
    // │ • Clears currentSession                                         │
    // └─────────────────────────────────────────────────────────────────┘

    func endSession(finalBankroll: Double) {
        guard var session = currentSession else {
            print("⚠️ No active session to end")
            return
        }

        // Mark session as ended
        session.endSession(finalBankroll: finalBankroll)

        // Add to history
        sessionHistory.append(session)

        // Save to disk
        saveSessionHistory()

        // Clear current session
        currentSession = nil

        print("⏹️ Ended session - \(session.handsPlayed) hands, \(session.formattedNetProfit), \(session.formattedDuration)")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎴 HAND TRACKING                                                   ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎴 RECORD HAND RESULT                                            │
    // │                                                                  │
    // │ Business Logic: Add a completed hand to current session         │
    // │ Called by: GameViewModel after each hand is evaluated           │
    // │                                                                  │
    // │ Parameters:                                                      │
    // │ • handResult: Complete hand result with all details             │
    // │ • newBankroll: Updated player bankroll after this hand          │
    // │                                                                  │
    // │ Side Effects:                                                    │
    // │ • Adds hand to current session                                  │
    // │ • Updates session bankroll                                      │
    // │ • Saves to disk (for crash recovery)                            │
    // │ • Publishes update to subscribers                               │
    // └─────────────────────────────────────────────────────────────────┘

    func recordHand(_ handResult: HandResult, newBankroll: Double) {
        guard currentSession != nil else {
            print("⚠️ No active session - cannot record hand")
            return
        }

        // Add hand to session
        currentSession!.addHand(handResult)
        currentSession!.updateBankroll(newBankroll)

        print("🎴 Recorded hand: \(handResult.outcome.displayString) (\(handResult.formattedNetResult))")

        // Auto-save every 5 hands for crash recovery
        if currentSession!.handsPlayed % 5 == 0 {
            saveCurrentSessionToHistory()
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💾 SAVE CURRENT SESSION TO HISTORY (INTERIM SAVE)               │
    // │                                                                  │
    // │ Business Logic: Periodically save current session for recovery  │
    // │ Called automatically every N hands                              │
    // │                                                                  │
    // │ Implementation:                                                  │
    // │ • Temporarily adds current session to history                   │
    // │ • Saves to disk                                                 │
    // │ • Removes from history (still active)                           │
    // │                                                                  │
    // │ This ensures current session can be recovered after crash       │
    // └─────────────────────────────────────────────────────────────────┘

    private func saveCurrentSessionToHistory() {
        guard let session = currentSession else { return }

        // Check if already in history (from previous auto-save)
        if let existingIndex = sessionHistory.firstIndex(where: { $0.id == session.id }) {
            // Update existing
            sessionHistory[existingIndex] = session
        } else {
            // Add new
            sessionHistory.append(session)
        }

        // Save to disk
        saveSessionHistory()

        print("💾 Auto-saved current session (\(session.handsPlayed) hands)")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 💾 PERSISTENCE OPERATIONS                                          ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Load session history from disk
    private func loadSessionHistory() {
        sessionHistory = persistence.loadSessions()
    }

    /// Save session history to disk
    private func saveSessionHistory() {
        persistence.saveSessions(sessionHistory)
    }

    /// Clear all session history
    func clearHistory() {
        sessionHistory = []
        if persistence.clearAllSessions() {
            print("🗑️ Cleared all session history")
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 STATISTICS CALCULATION                                          ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 GET OVERALL STATISTICS                                        │
    // │                                                                  │
    // │ Business Logic: Calculate all-time statistics from all sessions │
    // │ Called by: StatisticsViewModel for display                      │
    // │                                                                  │
    // │ Returns: OverallStats with aggregated data                      │
    // └─────────────────────────────────────────────────────────────────┘

    func getOverallStats() -> OverallStats {
        // Include current session if active
        var allSessions = sessionHistory
        if let current = currentSession {
            // Check if already in history (from auto-save)
            if !allSessions.contains(where: { $0.id == current.id }) {
                allSessions.append(current)
            } else {
                // Update with latest version
                if let index = allSessions.firstIndex(where: { $0.id == current.id }) {
                    allSessions[index] = current
                }
            }
        }

        return OverallStats.from(sessions: allSessions)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎰 GET DEALER STATISTICS                                         │
    // │                                                                  │
    // │ Business Logic: Calculate stats for a specific dealer           │
    // │ Called by: DealerComparisonView for per-dealer analysis         │
    // │                                                                  │
    // │ Parameters:                                                      │
    // │ • dealerName: Name of dealer to analyse                         │
    // │ • dealerIcon: Icon for dealer                                   │
    // │                                                                  │
    // │ Returns: DealerStats for specified dealer                       │
    // └─────────────────────────────────────────────────────────────────┘

    func getDealerStats(dealerName: String, dealerIcon: String) -> DealerStats {
        var allSessions = sessionHistory
        if let current = currentSession {
            if !allSessions.contains(where: { $0.id == current.id }) {
                allSessions.append(current)
            } else {
                if let index = allSessions.firstIndex(where: { $0.id == current.id }) {
                    allSessions[index] = current
                }
            }
        }

        return DealerStats.from(sessions: allSessions, dealerName: dealerName, dealerIcon: dealerIcon)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎰 GET ALL DEALER STATISTICS                                     │
    // │                                                                  │
    // │ Business Logic: Calculate stats for all known dealers           │
    // │ Called by: DealerComparisonView for side-by-side comparison     │
    // │                                                                  │
    // │ Parameters:                                                      │
    // │ • dealers: Array of (name, icon) tuples for all dealers         │
    // │                                                                  │
    // │ Returns: Array of DealerStats for all dealers                   │
    // └─────────────────────────────────────────────────────────────────┘

    func getAllDealerStats(dealers: [(name: String, icon: String)]) -> [DealerStats] {
        return dealers.map { getDealerStats(dealerName: $0.name, dealerIcon: $0.icon) }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔍 QUERY METHODS                                                   ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Get all sessions sorted by start time (most recent first)
    func getAllSessions() -> [Session] {
        var allSessions = sessionHistory
        if let current = currentSession {
            if !allSessions.contains(where: { $0.id == current.id }) {
                allSessions.append(current)
            } else {
                if let index = allSessions.firstIndex(where: { $0.id == current.id }) {
                    allSessions[index] = current
                }
            }
        }
        return allSessions.sorted { $0.startTime > $1.startTime }
    }

    /// Get sessions for specific dealer
    func getSessions(forDealer dealerName: String) -> [Session] {
        return getAllSessions().filter { $0.dealerName == dealerName }
    }

    /// Get session by ID
    func getSession(byId id: UUID) -> Session? {
        return getAllSessions().first { $0.id == id }
    }

    /// Get best session (highest profit)
    func getBestSession() -> Session? {
        return getAllSessions().max { $0.netProfit < $1.netProfit }
    }

    /// Get worst session (biggest loss)
    func getWorstSession() -> Session? {
        return getAllSessions().min { $0.netProfit < $1.netProfit }
    }

    /// Get total number of sessions
    var totalSessionsCount: Int {
        return sessionHistory.count + (currentSession != nil ? 1 : 0)
    }

    /// Check if currently tracking a session
    var hasActiveSession: Bool {
        return currentSession != nil
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📤 EXPORT/IMPORT                                                   ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Export all sessions as JSON string
    func exportSessions() -> String? {
        return persistence.exportSessionsAsJSON(getAllSessions())
    }

    /// Import sessions from JSON string (merges with existing)
    func importSessions(from jsonString: String) -> Bool {
        guard let imported = persistence.importSessionsFromJSON(jsonString) else {
            return false
        }

        // Merge with existing (avoid duplicates by ID)
        for session in imported {
            if !sessionHistory.contains(where: { $0.id == session.id }) {
                sessionHistory.append(session)
            }
        }

        saveSessionHistory()
        print("📥 Imported \(imported.count) sessions")
        return true
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Start a session:                                                           ║
// ║   let statsManager = StatisticsManager.shared                             ║
// ║   statsManager.startSession(                                              ║
// ║       dealerName: "Ruby",                                                 ║
// ║       dealerIcon: "♦️",                                                    ║
// ║       startingBankroll: 10000                                             ║
// ║   )                                                                        ║
// ║                                                                            ║
// ║ Record hands:                                                              ║
// ║   let handResult = HandResult(...)                                         ║
// ║   statsManager.recordHand(handResult, newBankroll: 10050)                ║
// ║                                                                            ║
// ║ End session:                                                               ║
// ║   statsManager.endSession(finalBankroll: 10500)                           ║
// ║                                                                            ║
// ║ Get statistics:                                                            ║
// ║   let overallStats = statsManager.getOverallStats()                       ║
// ║   print("Win rate: \(overallStats.formattedWinRate)")                     ║
// ║                                                                            ║
// ║   let rubyStats = statsManager.getDealerStats(                            ║
// ║       dealerName: "Ruby",                                                 ║
// ║       dealerIcon: "♦️"                                                     ║
// ║   )                                                                        ║
// ║   print("Ruby win rate: \(rubyStats.formattedWinRate)")                   ║
// ║                                                                            ║
// ║ In SwiftUI View:                                                           ║
// ║   @StateObject private var stats = StatisticsManager.shared               ║
// ║                                                                            ║
// ║   var body: some View {                                                    ║
// ║       if let session = stats.currentSession {                             ║
// ║           Text("Hands: \(session.handsPlayed)")                           ║
// ║           Text("Win rate: \(session.formattedWinRate)")                   ║
// ║       }                                                                    ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
