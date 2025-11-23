//
//  StatisticsPersistence.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 4: Statistics & Session History
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 💾 STATISTICS PERSISTENCE UTILITY                                          ║
// ║                                                                            ║
// ║ Purpose: Handles saving and loading session history to/from disk          ║
// ║ Business Context: Players expect their stats to persist across app        ║
// ║                   launches. This utility manages the file system storage  ║
// ║                   of session data using JSON encoding.                    ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Save sessions to Documents directory as JSON                            ║
// ║ • Load sessions from disk on app launch                                   ║
// ║ • Handle file I/O errors gracefully                                       ║
// ║ • Provide clear/reset functionality                                       ║
// ║ • Manage file size (optional: limit to last N sessions)                   ║
// ║                                                                            ║
// ║ Storage Strategy:                                                          ║
// ║ • One JSON file: "blackjack_sessions.json"                                ║
// ║ • Stored in Documents directory (user data)                               ║
// ║ • Array of Session objects encoded as JSON                                ║
// ║ • Auto-backup on save (optional enhancement)                              ║
// ║                                                                            ║
// ║ Used By: StatisticsManager (calls save/load methods)                      ║
// ║                                                                            ║
// ║ Related Spec: See "Statistics & Session History" (lines 178-215)          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 💾 STATISTICS PERSISTENCE CLASS                                            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class StatisticsPersistence {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON PATTERN                                             │
    // │                                                                  │
    // │ Using singleton to ensure consistent access across app          │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = StatisticsPersistence()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📁 FILE CONFIGURATION                                            │
    // └─────────────────────────────────────────────────────────────────┘

    /// Filename for session storage
    private let sessionsFilename = "blackjack_sessions.json"

    /// Maximum number of sessions to keep (0 = unlimited)
    private let maxSessionsToKeep = 100

    /// JSON encoder with pretty printing for debugging
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    /// JSON decoder
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {
        print("💾 StatisticsPersistence initialised")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📂 FILE PATH MANAGEMENT                                            ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Get path to sessions file in Documents directory
    private var sessionsFileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(sessionsFilename)
    }

    /// Check if sessions file exists
    var sessionsFileExists: Bool {
        return FileManager.default.fileExists(atPath: sessionsFileURL.path)
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 💾 SAVE OPERATIONS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💾 SAVE SESSIONS                                                 │
    // │                                                                  │
    // │ Business Logic: Save all sessions to disk as JSON               │
    // │ Called by: StatisticsManager whenever sessions are updated      │
    // │                                                                  │
    // │ Implementation:                                                  │
    // │ • Encode sessions array to JSON                                 │
    // │ • Write atomically to prevent corruption                        │
    // │ • Limit to maxSessionsToKeep (keep most recent)                 │
    // │ • Log errors but don't crash app                                │
    // └─────────────────────────────────────────────────────────────────┘

    func saveSessions(_ sessions: [Session]) {
        do {
            // Limit sessions if needed (keep most recent)
            let sessionsToSave: [Session]
            if maxSessionsToKeep > 0 && sessions.count > maxSessionsToKeep {
                // Sort by start time descending and take first N
                sessionsToSave = sessions
                    .sorted { $0.startTime > $1.startTime }
                    .prefix(maxSessionsToKeep)
                    .map { $0 }
                print("⚠️ Limiting sessions to \(maxSessionsToKeep) most recent (had \(sessions.count))")
            } else {
                sessionsToSave = sessions
            }

            // Encode to JSON
            let jsonData = try encoder.encode(sessionsToSave)

            // Write atomically (prevents corruption if write fails mid-way)
            try jsonData.write(to: sessionsFileURL, options: .atomic)

            let fileSize = Double(jsonData.count) / 1024.0 // KB
            print("💾 Saved \(sessionsToSave.count) sessions (\(String(format: "%.1f", fileSize)) KB)")

        } catch {
            print("❌ Failed to save sessions: \(error.localizedDescription)")
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📂 LOAD OPERATIONS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📂 LOAD SESSIONS                                                 │
    // │                                                                  │
    // │ Business Logic: Load all sessions from disk                     │
    // │ Called by: StatisticsManager on initialisation                  │
    // │                                                                  │
    // │ Implementation:                                                  │
    // │ • Read JSON file from Documents directory                       │
    // │ • Decode into Session array                                     │
    // │ • Return empty array if file doesn't exist (first launch)       │
    // │ • Log errors but return empty array (graceful degradation)      │
    // └─────────────────────────────────────────────────────────────────┘

    func loadSessions() -> [Session] {
        // Check if file exists
        guard sessionsFileExists else {
            print("ℹ️ No sessions file found - first launch or cleared data")
            return []
        }

        do {
            // Read JSON data
            let jsonData = try Data(contentsOf: sessionsFileURL)

            // Decode sessions
            let sessions = try decoder.decode([Session].self, from: jsonData)

            let fileSize = Double(jsonData.count) / 1024.0 // KB
            print("📂 Loaded \(sessions.count) sessions (\(String(format: "%.1f", fileSize)) KB)")

            return sessions

        } catch {
            print("❌ Failed to load sessions: \(error.localizedDescription)")
            print("   Returning empty array - user will start fresh")
            return []
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🗑️ CLEAR/RESET OPERATIONS                                          ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🗑️ CLEAR ALL SESSIONS                                            │
    // │                                                                  │
    // │ Business Logic: Delete session history file                     │
    // │ Called by: StatisticsManager when user clears history           │
    // │                                                                  │
    // │ Implementation:                                                  │
    // │ • Delete sessions file from disk                                │
    // │ • Log success/failure                                           │
    // │ • Return true if successful, false otherwise                    │
    // └─────────────────────────────────────────────────────────────────┘

    func clearAllSessions() -> Bool {
        guard sessionsFileExists else {
            print("ℹ️ No sessions file to clear")
            return true // Not an error - already clear
        }

        do {
            try FileManager.default.removeItem(at: sessionsFileURL)
            print("🗑️ Cleared all session history")
            return true
        } catch {
            print("❌ Failed to clear sessions: \(error.localizedDescription)")
            return false
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💾 EXPORT SESSIONS TO JSON STRING                               │
    // │                                                                  │
    // │ Business Logic: Export sessions as JSON string for sharing      │
    // │ Called by: StatisticsManager when user exports data             │
    // │                                                                  │
    // │ Returns: Pretty-printed JSON string or nil if encoding fails    │
    // └─────────────────────────────────────────────────────────────────┘

    func exportSessionsAsJSON(_ sessions: [Session]) -> String? {
        do {
            let jsonData = try encoder.encode(sessions)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("📤 Exported \(sessions.count) sessions to JSON string")
            return jsonString
        } catch {
            print("❌ Failed to export sessions: \(error.localizedDescription)")
            return nil
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📥 IMPORT SESSIONS FROM JSON STRING                             │
    // │                                                                  │
    // │ Business Logic: Import sessions from JSON string                │
    // │ Called by: StatisticsManager when user imports data             │
    // │                                                                  │
    // │ Returns: Array of sessions or nil if decoding fails             │
    // └─────────────────────────────────────────────────────────────────┘

    func importSessionsFromJSON(_ jsonString: String) -> [Session]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ Invalid JSON string format")
            return nil
        }

        do {
            let sessions = try decoder.decode([Session].self, from: jsonData)
            print("📥 Imported \(sessions.count) sessions from JSON string")
            return sessions
        } catch {
            print("❌ Failed to import sessions: \(error.localizedDescription)")
            return nil
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📊 UTILITY METHODS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Get file size of sessions file (in KB)
    var sessionFileSize: Double? {
        guard sessionsFileExists else { return nil }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: sessionsFileURL.path)
            if let fileSize = attributes[.size] as? NSNumber {
                return fileSize.doubleValue / 1024.0 // Convert to KB
            }
        } catch {
            print("❌ Failed to get file size: \(error.localizedDescription)")
        }

        return nil
    }

    /// Get last modified date of sessions file
    var sessionFileLastModified: Date? {
        guard sessionsFileExists else { return nil }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: sessionsFileURL.path)
            return attributes[.modificationDate] as? Date
        } catch {
            print("❌ Failed to get last modified date: \(error.localizedDescription)")
            return nil
        }
    }

    /// Get full path to sessions file (for debugging)
    var sessionFilePath: String {
        return sessionsFileURL.path
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Save sessions:                                                             ║
// ║   let persistence = StatisticsPersistence.shared                          ║
// ║   persistence.saveSessions(mySessions)                                    ║
// ║                                                                            ║
// ║ Load sessions:                                                             ║
// ║   let sessions = persistence.loadSessions()                               ║
// ║   print("Loaded \(sessions.count) sessions")                              ║
// ║                                                                            ║
// ║ Clear all data:                                                            ║
// ║   if persistence.clearAllSessions() {                                     ║
// ║       print("History cleared")                                            ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ Export/Import:                                                             ║
// ║   if let jsonString = persistence.exportSessionsAsJSON(sessions) {        ║
// ║       // Share jsonString via email, iCloud, etc.                         ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║   if let imported = persistence.importSessionsFromJSON(jsonString) {      ║
// ║       // Merge or replace current sessions                                ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ Check file info:                                                           ║
// ║   if let size = persistence.sessionFileSize {                             ║
// ║       print("File size: \(size) KB")                                      ║
// ║   }                                                                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
