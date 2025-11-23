//
//  TimeManager.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 9: Daily Challenges & Events System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ ⏰ TIME MANAGER SERVICE                                                    ║
// ║                                                                            ║
// ║ Purpose: Central coordinator for all time-based challenge operations      ║
// ║ Business Context: Challenges refresh on specific schedules (daily,        ║
// ║                   weekly, events). TimeManager provides consistent        ║
// ║                   time calculations accounting for timezones and DST.     ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Calculate time until midnight (daily reset)                             ║
// ║ • Calculate time until Monday 00:00 (weekly reset)                        ║
// ║ • Determine if challenges need refresh                                    ║
// ║ • Handle timezone considerations                                          ║
// ║ • Generate start/end dates for challenges                                 ║
// ║ • Track daily login streaks                                               ║
// ║                                                                            ║
// ║ Architecture Pattern: Singleton service                                    ║
// ║ Used By: ChallengeManager (challenge refresh logic)                       ║
// ║          ChallengesView (displays countdown timers)                       ║
// ║                                                                            ║
// ║ Related Spec: See "Daily Challenges & Events System" Phase 9              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import Foundation

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ ⏰ TIME MANAGER CLASS                                                      ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class TimeManager {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔑 SINGLETON PATTERN                                             │
    // └─────────────────────────────────────────────────────────────────┘

    static let shared = TimeManager()

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 INTERNAL PROPERTIES                                           │
    // └─────────────────────────────────────────────────────────────────┘

    /// Calendar for date calculations (uses current timezone)
    private let calendar: Calendar

    /// UserDefaults key for last refresh dates
    private let lastDailyRefreshKey = "last_daily_challenge_refresh"
    private let lastWeeklyRefreshKey = "last_weekly_challenge_refresh"

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🏗️ INITIALISER                                                   │
    // │                                                                  │
    // │ Private to enforce singleton pattern                            │
    // └─────────────────────────────────────────────────────────────────┘

    private init() {
        self.calendar = Calendar.current
        print("⏰ TimeManager initialised")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🕐 DAILY CHALLENGE TIME CALCULATIONS                               ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🌅 GET NEXT MIDNIGHT                                             │
    // │                                                                  │
    // │ Business Logic: Calculate when the next midnight occurs          │
    // │ Uses: Local timezone (respects player's location)               │
    // │                                                                  │
    // │ Returns: Date representing next midnight (00:00:00)             │
    // └─────────────────────────────────────────────────────────────────┘

    func getNextMidnight() -> Date {
        let now = Date()
        let startOfTomorrow = calendar.startOfDay(for: now.addingTimeInterval(86400))
        return startOfTomorrow
    }

    /// Get start of today (midnight)
    func getStartOfToday() -> Date {
        return calendar.startOfDay(for: Date())
    }

    /// Time interval until next midnight
    func timeUntilMidnight() -> TimeInterval {
        let now = Date()
        let midnight = getNextMidnight()
        return midnight.timeIntervalSince(now)
    }

    /// Formatted time until midnight (e.g., "5h 23m")
    func formattedTimeUntilMidnight() -> String {
        let interval = timeUntilMidnight()
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔄 NEEDS DAILY REFRESH?                                          │
    // │                                                                  │
    // │ Business Logic: Determine if daily challenges should refresh    │
    // │ Checks: If we've crossed midnight since last refresh            │
    // │                                                                  │
    // │ Returns: true if refresh needed, false otherwise                │
    // └─────────────────────────────────────────────────────────────────┘

    func needsDailyRefresh() -> Bool {
        guard let lastRefresh = UserDefaults.standard.object(forKey: lastDailyRefreshKey) as? Date else {
            // Never refreshed - needs refresh
            return true
        }

        let startOfToday = getStartOfToday()
        return lastRefresh < startOfToday
    }

    /// Record that daily refresh occurred
    func recordDailyRefresh() {
        UserDefaults.standard.set(Date(), forKey: lastDailyRefreshKey)
        print("📅 Daily refresh recorded at \(Date())")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 📅 WEEKLY CHALLENGE TIME CALCULATIONS                              ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📅 GET NEXT MONDAY MIDNIGHT                                      │
    // │                                                                  │
    // │ Business Logic: Calculate when next Monday 00:00 occurs          │
    // │ Uses: ISO 8601 week definition (Monday is start of week)        │
    // │                                                                  │
    // │ Returns: Date representing next Monday at midnight              │
    // └─────────────────────────────────────────────────────────────────┘

    func getNextMondayMidnight() -> Date {
        let now = Date()

        // Get current weekday (1 = Sunday, 2 = Monday, etc. by default)
        // We want Monday = 1, so use ISO calendar
        let weekday = calendar.component(.weekday, from: now)

        // Calculate days until next Monday
        // If today is Monday, next Monday is 7 days away
        // If today is Tuesday (3), next Monday is 6 days away
        let daysUntilMonday: Int
        if weekday == 2 { // Monday
            daysUntilMonday = 7
        } else if weekday == 1 { // Sunday
            daysUntilMonday = 1
        } else { // Tuesday-Saturday
            daysUntilMonday = 9 - weekday
        }

        let nextMonday = calendar.date(byAdding: .day, value: daysUntilMonday, to: now)!
        return calendar.startOfDay(for: nextMonday)
    }

    /// Get start of current week (Monday midnight)
    func getStartOfWeek() -> Date {
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)

        let daysSinceMonday: Int
        if weekday == 2 { // Monday
            daysSinceMonday = 0
        } else if weekday == 1 { // Sunday
            daysSinceMonday = 6
        } else { // Tuesday-Saturday
            daysSinceMonday = weekday - 2
        }

        let monday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: now)!
        return calendar.startOfDay(for: monday)
    }

    /// Time interval until next Monday midnight
    func timeUntilWeeklyReset() -> TimeInterval {
        let now = Date()
        let nextMonday = getNextMondayMidnight()
        return nextMonday.timeIntervalSince(now)
    }

    /// Formatted time until weekly reset (e.g., "2d 5h")
    func formattedTimeUntilWeeklyReset() -> String {
        let interval = timeUntilWeeklyReset()
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600

        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h"
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔄 NEEDS WEEKLY REFRESH?                                         │
    // │                                                                  │
    // │ Business Logic: Determine if weekly challenges should refresh   │
    // │ Checks: If we've crossed Monday since last refresh              │
    // │                                                                  │
    // │ Returns: true if refresh needed, false otherwise                │
    // └─────────────────────────────────────────────────────────────────┘

    func needsWeeklyRefresh() -> Bool {
        guard let lastRefresh = UserDefaults.standard.object(forKey: lastWeeklyRefreshKey) as? Date else {
            // Never refreshed - needs refresh
            return true
        }

        let startOfWeek = getStartOfWeek()
        return lastRefresh < startOfWeek
    }

    /// Record that weekly refresh occurred
    func recordWeeklyRefresh() {
        UserDefaults.standard.set(Date(), forKey: lastWeeklyRefreshKey)
        print("📅 Weekly refresh recorded at \(Date())")
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎯 CHALLENGE DATE GENERATION                                       ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📅 GENERATE DAILY CHALLENGE DATES                                │
    // │                                                                  │
    // │ Business Logic: Create start/end dates for a daily challenge    │
    // │                                                                  │
    // │ Returns: (start: today midnight, end: tomorrow midnight)        │
    // └─────────────────────────────────────────────────────────────────┘

    func getDailyChallengeWindow() -> (start: Date, end: Date) {
        let start = getStartOfToday()
        let end = getNextMidnight()
        return (start, end)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📅 GENERATE WEEKLY CHALLENGE DATES                               │
    // │                                                                  │
    // │ Business Logic: Create start/end dates for a weekly challenge   │
    // │                                                                  │
    // │ Returns: (start: Monday midnight, end: next Monday midnight)    │
    // └─────────────────────────────────────────────────────────────────┘

    func getWeeklyChallengeWindow() -> (start: Date, end: Date) {
        let start = getStartOfWeek()
        let end = getNextMondayMidnight()
        return (start, end)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎉 GENERATE EVENT CHALLENGE DATES                                │
    // │                                                                  │
    // │ Business Logic: Create custom date range for special events     │
    // │                                                                  │
    // │ Parameters:                                                      │
    // │ • durationDays: How many days the event lasts                   │
    // │                                                                  │
    // │ Returns: (start: now, end: now + duration)                      │
    // └─────────────────────────────────────────────────────────────────┘

    func getEventChallengeWindow(durationDays: Int) -> (start: Date, end: Date) {
        let start = Date()
        let end = calendar.date(byAdding: .day, value: durationDays, to: start)!
        return (start, end)
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔥 DAILY LOGIN STREAK TRACKING                                     ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    private let lastLoginDateKey = "last_login_date"
    private let currentStreakKey = "daily_login_streak"
    private let longestStreakKey = "longest_daily_login_streak"

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔥 RECORD DAILY LOGIN                                            │
    // │                                                                  │
    // │ Business Logic: Update login streak when player logs in         │
    // │ Streak continues if: Login is on consecutive days               │
    // │ Streak breaks if: Player misses a day                           │
    // │                                                                  │
    // │ Returns: Current streak count                                   │
    // └─────────────────────────────────────────────────────────────────┘

    func recordDailyLogin() -> Int {
        let today = getStartOfToday()

        guard let lastLogin = UserDefaults.standard.object(forKey: lastLoginDateKey) as? Date else {
            // First time login
            UserDefaults.standard.set(today, forKey: lastLoginDateKey)
            UserDefaults.standard.set(1, forKey: currentStreakKey)
            UserDefaults.standard.set(1, forKey: longestStreakKey)
            print("🔥 First login - streak started at 1")
            return 1
        }

        let lastLoginDay = calendar.startOfDay(for: lastLogin)
        let daysBetween = calendar.dateComponents([.day], from: lastLoginDay, to: today).day ?? 0

        var currentStreak = UserDefaults.standard.integer(forKey: currentStreakKey)
        let longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)

        if daysBetween == 0 {
            // Same day - no change
            print("🔥 Same day login - streak unchanged at \(currentStreak)")
            return currentStreak
        } else if daysBetween == 1 {
            // Consecutive day - increment streak
            currentStreak += 1
            UserDefaults.standard.set(today, forKey: lastLoginDateKey)
            UserDefaults.standard.set(currentStreak, forKey: currentStreakKey)

            // Check longest streak
            if currentStreak > longestStreak {
                UserDefaults.standard.set(currentStreak, forKey: longestStreakKey)
                print("🏆 New longest streak: \(currentStreak) days!")
            }

            print("🔥 Consecutive login - streak now \(currentStreak)")
            return currentStreak
        } else {
            // Missed days - streak breaks
            print("💔 Missed \(daysBetween - 1) days - streak reset from \(currentStreak) to 1")
            UserDefaults.standard.set(today, forKey: lastLoginDateKey)
            UserDefaults.standard.set(1, forKey: currentStreakKey)
            return 1
        }
    }

    /// Get current daily login streak
    func getDailyLoginStreak() -> Int {
        return UserDefaults.standard.integer(forKey: currentStreakKey)
    }

    /// Get longest daily login streak
    func getLongestLoginStreak() -> Int {
        return UserDefaults.standard.integer(forKey: longestStreakKey)
    }

    /// Check if player logged in today
    func hasLoggedInToday() -> Bool {
        guard let lastLogin = UserDefaults.standard.object(forKey: lastLoginDateKey) as? Date else {
            return false
        }

        let lastLoginDay = calendar.startOfDay(for: lastLogin)
        let today = getStartOfToday()

        return lastLoginDay == today
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎮 SPECIAL EVENT DETECTION                                         ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎉 IS WEEKEND?                                                   │
    // │                                                                  │
    // │ Business Logic: Check if today is Saturday or Sunday            │
    // │ Used for: Weekend event challenges                              │
    // └─────────────────────────────────────────────────────────────────┘

    func isWeekend() -> Bool {
        let weekday = calendar.component(.weekday, from: Date())
        return weekday == 1 || weekday == 7 // Sunday = 1, Saturday = 7
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎄 IS HOLIDAY?                                                   │
    // │                                                                  │
    // │ Business Logic: Check if today is a special holiday             │
    // │ Used for: Holiday-themed event challenges                       │
    // │                                                                  │
    // │ Note: Currently checks major holidays, can be expanded          │
    // └─────────────────────────────────────────────────────────────────┘

    func isHoliday() -> String? {
        let now = Date()
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)

        // Check major holidays
        switch (month, day) {
        case (1, 1):
            return "New Year's Day"
        case (2, 14):
            return "Valentine's Day"
        case (3, 17):
            return "St. Patrick's Day"
        case (10, 31):
            return "Halloween"
        case (12, 25):
            return "Christmas"
        case (12, 31):
            return "New Year's Eve"
        default:
            return nil
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🛠️ UTILITY METHODS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Format time interval as human-readable string
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    /// Check if date is in the past
    func isPast(_ date: Date) -> Bool {
        return date < Date()
    }

    /// Check if date is in the future
    func isFuture(_ date: Date) -> Bool {
        return date > Date()
    }

    /// Check if date is today
    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }

    /// Reset all time-based tracking (for testing)
    func resetAllTracking() {
        UserDefaults.standard.removeObject(forKey: lastDailyRefreshKey)
        UserDefaults.standard.removeObject(forKey: lastWeeklyRefreshKey)
        UserDefaults.standard.removeObject(forKey: lastLoginDateKey)
        UserDefaults.standard.removeObject(forKey: currentStreakKey)
        UserDefaults.standard.removeObject(forKey: longestStreakKey)
        print("🔄 All time tracking reset")
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                          ║
// ║                                                                            ║
// ║ Get time manager:                                                          ║
// ║   let timeManager = TimeManager.shared                                    ║
// ║                                                                            ║
// ║ Check if refresh needed:                                                   ║
// ║   if timeManager.needsDailyRefresh() {                                    ║
// ║       // Refresh daily challenges                                         ║
// ║       timeManager.recordDailyRefresh()                                    ║
// ║   }                                                                        ║
// ║                                                                            ║
// ║ Get challenge windows:                                                     ║
// ║   let (start, end) = timeManager.getDailyChallengeWindow()                ║
// ║   let challenge = Challenge(startDate: start, endDate: end, ...)          ║
// ║                                                                            ║
// ║ Track daily login:                                                         ║
// ║   let streak = timeManager.recordDailyLogin()                             ║
// ║   print("Login streak: \(streak) days")                                   ║
// ║                                                                            ║
// ║ Display countdown:                                                         ║
// ║   Text("Resets in: \(timeManager.formattedTimeUntilMidnight())")         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
