import Foundation
import SwiftData

class BadgeManager {

    // MARK: - Sync badges based on all existing sessions (for retroactive awarding)
    static func syncBadges(
        profile: UserProfile,
        mockService: MockDataService,
        modelContext: ModelContext
    ) {
        let existingBadgeTypes = Set(profile.badges.compactMap { $0.type })
        var newBadges: [BadgeType] = []

        // Check milestone badges
        newBadges.append(contentsOf: checkMilestoneBadges(profile: profile, existing: existingBadgeTypes))

        // Check streak badges
        newBadges.append(contentsOf: checkStreakBadges(profile: profile, existing: existingBadgeTypes))

        // Check performance badges based on ALL sessions
        newBadges.append(contentsOf: checkAllPerformanceBadges(profile: profile, existing: existingBadgeTypes))

        // Check mastery badges
        newBadges.append(contentsOf: checkMasteryBadges(profile: profile, existing: existingBadgeTypes))

        // Check percentile badges based on ALL sessions
        newBadges.append(contentsOf: checkAllPercentileBadges(
            profile: profile,
            mockService: mockService,
            existing: existingBadgeTypes
        ))

        // Award new badges
        for badgeType in newBadges {
            let badge = Badge(badgeType: badgeType)
            badge.profile = profile
            profile.badges.append(badge)
            modelContext.insert(badge)
        }

        // Save changes
        try? modelContext.save()
    }

    // Check performance badges across all sessions
    private static func checkAllPerformanceBadges(profile: UserProfile, existing: Set<BadgeType>) -> [BadgeType] {
        var newBadges: [BadgeType] = []

        let hasPerfect = profile.sessions.contains { $0.accuracy >= 100 }
        if hasPerfect && !existing.contains(.perfectionist) {
            newBadges.append(.perfectionist)
        }

        return newBadges
    }

    // Check percentile badges across all sessions
    private static func checkAllPercentileBadges(
        profile: UserProfile,
        mockService: MockDataService,
        existing: Set<BadgeType>
    ) -> [BadgeType] {
        var newBadges: [BadgeType] = []

        for session in profile.sessions {
            let percentile = mockService.calculatePercentile(score: session.score, for: session.game)

            if percentile >= 75 && !existing.contains(.risingStar) && !newBadges.contains(.risingStar) {
                newBadges.append(.risingStar)
            }
            if percentile >= 90 && !existing.contains(.elite) && !newBadges.contains(.elite) {
                newBadges.append(.elite)
            }
            if percentile >= 95 && !existing.contains(.champion) && !newBadges.contains(.champion) {
                newBadges.append(.champion)
            }
            if percentile >= 99 && !existing.contains(.genius) && !newBadges.contains(.genius) {
                newBadges.append(.genius)
            }
        }

        return newBadges
    }

    // MARK: - Check for new badges after a game session
    static func checkForNewBadges(
        profile: UserProfile,
        session: GameSession,
        mockService: MockDataService,
        modelContext: ModelContext
    ) -> [BadgeType] {
        var newBadges: [BadgeType] = []
        let existingBadgeTypes = Set(profile.badges.compactMap { $0.type })

        // Check milestone badges
        newBadges.append(contentsOf: checkMilestoneBadges(profile: profile, existing: existingBadgeTypes))

        // Check streak badges
        newBadges.append(contentsOf: checkStreakBadges(profile: profile, existing: existingBadgeTypes))

        // Check performance badges
        newBadges.append(contentsOf: checkPerformanceBadges(session: session, existing: existingBadgeTypes))

        // Check mastery badges
        newBadges.append(contentsOf: checkMasteryBadges(profile: profile, existing: existingBadgeTypes))

        // Check percentile badges
        newBadges.append(contentsOf: checkPercentileBadges(
            profile: profile,
            session: session,
            mockService: mockService,
            existing: existingBadgeTypes
        ))

        // Award new badges
        for badgeType in newBadges {
            let badge = Badge(badgeType: badgeType)
            badge.profile = profile
            profile.badges.append(badge)
            modelContext.insert(badge)
        }

        return newBadges
    }

    // MARK: - Milestone Badges
    private static func checkMilestoneBadges(profile: UserProfile, existing: Set<BadgeType>) -> [BadgeType] {
        var newBadges: [BadgeType] = []
        let totalGames = profile.sessions.count

        if totalGames >= 1 && !existing.contains(.firstSteps) {
            newBadges.append(.firstSteps)
        }
        if totalGames >= 10 && !existing.contains(.gettingStarted) {
            newBadges.append(.gettingStarted)
        }
        if totalGames >= 50 && !existing.contains(.dedicated) {
            newBadges.append(.dedicated)
        }
        if totalGames >= 100 && !existing.contains(.committed) {
            newBadges.append(.committed)
        }
        if totalGames >= 500 && !existing.contains(.legend) {
            newBadges.append(.legend)
        }

        return newBadges
    }

    // MARK: - Streak Badges
    private static func checkStreakBadges(profile: UserProfile, existing: Set<BadgeType>) -> [BadgeType] {
        var newBadges: [BadgeType] = []
        let streak = calculateCurrentStreak(sessions: profile.sessions)

        if streak >= 3 && !existing.contains(.onTrack) {
            newBadges.append(.onTrack)
        }
        if streak >= 7 && !existing.contains(.consistent) {
            newBadges.append(.consistent)
        }
        if streak >= 14 && !existing.contains(.persistent) {
            newBadges.append(.persistent)
        }
        if streak >= 30 && !existing.contains(.unstoppable) {
            newBadges.append(.unstoppable)
        }

        return newBadges
    }

    private static func calculateCurrentStreak(sessions: [GameSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sortedDates = sessions
            .map { calendar.startOfDay(for: $0.completedAt) }
            .sorted(by: >)

        guard let mostRecent = sortedDates.first else { return 0 }

        // Check if played today or yesterday
        let today = calendar.startOfDay(for: Date())
        let daysSinceLast = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0

        if daysSinceLast > 1 {
            return 0 // Streak broken
        }

        // Count consecutive days
        var streak = 1
        var currentDate = mostRecent
        let uniqueDates = Set(sortedDates)

        while true {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            if uniqueDates.contains(previousDay) {
                streak += 1
                currentDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Performance Badges
    private static func checkPerformanceBadges(session: GameSession, existing: Set<BadgeType>) -> [BadgeType] {
        var newBadges: [BadgeType] = []

        if session.accuracy >= 100 && !existing.contains(.perfectionist) {
            newBadges.append(.perfectionist)
        }

        return newBadges
    }

    // MARK: - Mastery Badges
    private static func checkMasteryBadges(profile: UserProfile, existing: Set<BadgeType>) -> [BadgeType] {
        var newBadges: [BadgeType] = []

        // Check each category
        for category in GameCategory.allCases {
            let badgeType: BadgeType
            switch category {
            case .memory: badgeType = .memoryMaster
            case .mentalMath: badgeType = .mathWhiz
            case .problemSolving: badgeType = .logicLegend
            case .language: badgeType = .wordWizard
            }

            if !existing.contains(badgeType) && hasCategoryMastery(profile: profile, category: category) {
                newBadges.append(badgeType)
            }
        }

        return newBadges
    }

    private static func hasCategoryMastery(profile: UserProfile, category: GameCategory) -> Bool {
        let categoryGames = category.games

        for gameType in categoryGames {
            let gameSessions = profile.sessions.filter { $0.gameType == gameType.rawValue }
            guard !gameSessions.isEmpty else { return false }

            let bestAccuracy = gameSessions.map { $0.accuracy }.max() ?? 0
            if bestAccuracy < 80 {
                return false
            }
        }

        return true
    }

    // MARK: - Percentile Badges
    private static func checkPercentileBadges(
        profile: UserProfile,
        session: GameSession,
        mockService: MockDataService,
        existing: Set<BadgeType>
    ) -> [BadgeType] {
        var newBadges: [BadgeType] = []

        let percentile = mockService.calculatePercentile(score: session.score, for: session.game)

        if percentile >= 75 && !existing.contains(.risingStar) {
            newBadges.append(.risingStar)
        }
        if percentile >= 90 && !existing.contains(.elite) {
            newBadges.append(.elite)
        }
        if percentile >= 95 && !existing.contains(.champion) {
            newBadges.append(.champion)
        }
        if percentile >= 99 && !existing.contains(.genius) {
            newBadges.append(.genius)
        }

        return newBadges
    }

    // MARK: - Check Difficulty Unlock
    static func checkDifficultyUnlock(
        profile: UserProfile,
        session: GameSession,
        modelContext: ModelContext
    ) -> Int? {
        // Only unlock if 100% accuracy
        guard session.accuracy >= 100 else { return nil }

        let gameType = session.game
        let currentLevel = session.level

        // Can only unlock levels 2 and 3
        guard currentLevel < 3 else { return nil }

        let nextLevel = currentLevel + 1

        // Check if already unlocked
        let existingUnlock = profile.difficultyUnlocks.first {
            $0.gameType == gameType.rawValue && $0.level == nextLevel
        }

        guard existingUnlock == nil else { return nil }

        // Create new unlock
        let unlock = DifficultyUnlock(gameType: gameType, level: nextLevel)
        unlock.profile = profile
        profile.difficultyUnlocks.append(unlock)
        modelContext.insert(unlock)

        return nextLevel
    }

    // MARK: - Get Unlocked Difficulty Level
    static func getMaxUnlockedLevel(profile: UserProfile, gameType: GameType) -> Int {
        let unlocks = profile.difficultyUnlocks.filter { $0.gameType == gameType.rawValue }
        let maxUnlocked = unlocks.map { $0.level }.max() ?? 1
        return maxUnlocked
    }

    // MARK: - Badge Progress
    static func getBadgeProgress(profile: UserProfile) -> [BadgeType: Double] {
        var progress: [BadgeType: Double] = [:]
        let totalGames = profile.sessions.count
        let streak = calculateCurrentStreak(sessions: profile.sessions)

        // Milestone progress
        progress[.firstSteps] = min(1.0, Double(totalGames) / 1.0)
        progress[.gettingStarted] = min(1.0, Double(totalGames) / 10.0)
        progress[.dedicated] = min(1.0, Double(totalGames) / 50.0)
        progress[.committed] = min(1.0, Double(totalGames) / 100.0)
        progress[.legend] = min(1.0, Double(totalGames) / 500.0)

        // Streak progress
        progress[.onTrack] = min(1.0, Double(streak) / 3.0)
        progress[.consistent] = min(1.0, Double(streak) / 7.0)
        progress[.persistent] = min(1.0, Double(streak) / 14.0)
        progress[.unstoppable] = min(1.0, Double(streak) / 30.0)

        // Performance progress
        let hasPerfect = profile.sessions.contains { $0.accuracy >= 100 }
        progress[.perfectionist] = hasPerfect ? 1.0 : 0.0

        return progress
    }
}
