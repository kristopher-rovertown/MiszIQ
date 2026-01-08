package com.example.misziq.data.model

import com.example.misziq.data.repository.MiszIQRepository
import java.util.Calendar

object BadgeManager {

    // Sync badges based on all existing sessions (for retroactive awarding)
    suspend fun syncBadges(
        profileId: String,
        sessions: List<GameSession>,
        existingAchievements: List<Achievement>,
        repository: MiszIQRepository
    ): List<BadgeType> {
        val existingBadgeTypes = existingAchievements.mapNotNull { it.type }.toSet()
        val newBadges = mutableListOf<BadgeType>()

        // Check milestone badges
        newBadges.addAll(checkMilestoneBadges(sessions, existingBadgeTypes))

        // Check streak badges
        newBadges.addAll(checkStreakBadges(sessions, existingBadgeTypes))

        // Check performance badges based on ALL sessions
        newBadges.addAll(checkAllPerformanceBadges(sessions, existingBadgeTypes))

        // Check mastery badges
        newBadges.addAll(checkMasteryBadges(sessions, existingBadgeTypes))

        // Check percentile badges based on ALL sessions
        val mockService = MockDataService()
        newBadges.addAll(checkAllPercentileBadges(sessions, mockService, existingBadgeTypes))

        // Award new badges
        for (badgeType in newBadges) {
            val achievement = Achievement(
                profileId = profileId,
                badgeType = badgeType.id
            )
            repository.insertAchievement(achievement)
        }

        return newBadges
    }

    private fun checkAllPerformanceBadges(
        sessions: List<GameSession>,
        existing: Set<BadgeType>
    ): List<BadgeType> {
        val newBadges = mutableListOf<BadgeType>()

        val hasPerfect = sessions.any { it.accuracy >= 100 }
        if (hasPerfect && BadgeType.PERFECTIONIST !in existing) {
            newBadges.add(BadgeType.PERFECTIONIST)
        }

        return newBadges
    }

    private fun checkAllPercentileBadges(
        sessions: List<GameSession>,
        mockService: MockDataService,
        existing: Set<BadgeType>
    ): List<BadgeType> {
        val newBadges = mutableListOf<BadgeType>()

        for (session in sessions) {
            val gameType = GameType.values().find { it.name == session.gameType } ?: continue
            val percentile = mockService.calculatePercentile(session.score, gameType)

            if (percentile >= 75 && BadgeType.RISING_STAR !in existing && BadgeType.RISING_STAR !in newBadges) {
                newBadges.add(BadgeType.RISING_STAR)
            }
            if (percentile >= 90 && BadgeType.ELITE !in existing && BadgeType.ELITE !in newBadges) {
                newBadges.add(BadgeType.ELITE)
            }
            if (percentile >= 95 && BadgeType.CHAMPION !in existing && BadgeType.CHAMPION !in newBadges) {
                newBadges.add(BadgeType.CHAMPION)
            }
            if (percentile >= 99 && BadgeType.GENIUS !in existing && BadgeType.GENIUS !in newBadges) {
                newBadges.add(BadgeType.GENIUS)
            }
        }

        return newBadges
    }

    suspend fun checkForNewBadges(
        profileId: String,
        session: GameSession,
        sessions: List<GameSession>,
        repository: MiszIQRepository,
        mockService: MockDataService
    ): List<BadgeType> {
        val existingAchievements = repository.getAchievementsForProfileSync(profileId)
        val existingBadgeTypes = existingAchievements.mapNotNull { it.type }.toSet()
        val newBadges = mutableListOf<BadgeType>()

        // Check milestone badges
        newBadges.addAll(checkMilestoneBadges(sessions, existingBadgeTypes))

        // Check streak badges
        newBadges.addAll(checkStreakBadges(sessions, existingBadgeTypes))

        // Check performance badges
        newBadges.addAll(checkPerformanceBadges(session, existingBadgeTypes))

        // Check mastery badges
        newBadges.addAll(checkMasteryBadges(sessions, existingBadgeTypes))

        // Check percentile badges
        newBadges.addAll(checkPercentileBadges(session, mockService, existingBadgeTypes))

        // Award new badges
        for (badgeType in newBadges) {
            val achievement = Achievement(
                profileId = profileId,
                badgeType = badgeType.id
            )
            repository.insertAchievement(achievement)
        }

        return newBadges
    }

    private fun checkMilestoneBadges(
        sessions: List<GameSession>,
        existing: Set<BadgeType>
    ): List<BadgeType> {
        val newBadges = mutableListOf<BadgeType>()
        val totalGames = sessions.size

        if (totalGames >= 1 && BadgeType.FIRST_STEPS !in existing) {
            newBadges.add(BadgeType.FIRST_STEPS)
        }
        if (totalGames >= 10 && BadgeType.GETTING_STARTED !in existing) {
            newBadges.add(BadgeType.GETTING_STARTED)
        }
        if (totalGames >= 50 && BadgeType.DEDICATED !in existing) {
            newBadges.add(BadgeType.DEDICATED)
        }
        if (totalGames >= 100 && BadgeType.COMMITTED !in existing) {
            newBadges.add(BadgeType.COMMITTED)
        }
        if (totalGames >= 500 && BadgeType.LEGEND !in existing) {
            newBadges.add(BadgeType.LEGEND)
        }

        return newBadges
    }

    private fun checkStreakBadges(
        sessions: List<GameSession>,
        existing: Set<BadgeType>
    ): List<BadgeType> {
        val newBadges = mutableListOf<BadgeType>()
        val streak = calculateCurrentStreak(sessions)

        if (streak >= 3 && BadgeType.ON_TRACK !in existing) {
            newBadges.add(BadgeType.ON_TRACK)
        }
        if (streak >= 7 && BadgeType.CONSISTENT !in existing) {
            newBadges.add(BadgeType.CONSISTENT)
        }
        if (streak >= 14 && BadgeType.PERSISTENT !in existing) {
            newBadges.add(BadgeType.PERSISTENT)
        }
        if (streak >= 30 && BadgeType.UNSTOPPABLE !in existing) {
            newBadges.add(BadgeType.UNSTOPPABLE)
        }

        return newBadges
    }

    private fun calculateCurrentStreak(sessions: List<GameSession>): Int {
        if (sessions.isEmpty()) return 0

        val calendar = Calendar.getInstance()
        val today = calendar.apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

        val sortedDates = sessions
            .map { session ->
                Calendar.getInstance().apply {
                    timeInMillis = session.completedAt
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }.timeInMillis
            }
            .distinct()
            .sortedDescending()

        val mostRecent = sortedDates.firstOrNull() ?: return 0
        val daysSinceLast = ((today - mostRecent) / (24 * 60 * 60 * 1000)).toInt()

        if (daysSinceLast > 1) return 0

        var streak = 1
        var currentDate = mostRecent
        val uniqueDates = sortedDates.toSet()

        while (true) {
            val previousDay = currentDate - (24 * 60 * 60 * 1000)
            if (previousDay in uniqueDates) {
                streak++
                currentDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    private fun checkPerformanceBadges(
        session: GameSession,
        existing: Set<BadgeType>
    ): List<BadgeType> {
        val newBadges = mutableListOf<BadgeType>()

        if (session.accuracy >= 100 && BadgeType.PERFECTIONIST !in existing) {
            newBadges.add(BadgeType.PERFECTIONIST)
        }

        return newBadges
    }

    private fun checkMasteryBadges(
        sessions: List<GameSession>,
        existing: Set<BadgeType>
    ): List<BadgeType> {
        val newBadges = mutableListOf<BadgeType>()

        for (category in GameCategory.values()) {
            val badgeType = when (category) {
                GameCategory.MEMORY -> BadgeType.MEMORY_MASTER
                GameCategory.MENTAL_MATH -> BadgeType.MATH_WHIZ
                GameCategory.PROBLEM_SOLVING -> BadgeType.LOGIC_LEGEND
                GameCategory.LANGUAGE -> BadgeType.WORD_WIZARD
            }

            if (badgeType !in existing && hasCategoryMastery(sessions, category)) {
                newBadges.add(badgeType)
            }
        }

        return newBadges
    }

    private fun hasCategoryMastery(sessions: List<GameSession>, category: GameCategory): Boolean {
        val categoryGames = category.games

        for (gameType in categoryGames) {
            val gameSessions = sessions.filter { it.gameType == gameType.name }
            if (gameSessions.isEmpty()) return false

            val bestAccuracy = gameSessions.maxOfOrNull { it.accuracy } ?: 0.0
            if (bestAccuracy < 80) return false
        }

        return true
    }

    private fun checkPercentileBadges(
        session: GameSession,
        mockService: MockDataService,
        existing: Set<BadgeType>
    ): List<BadgeType> {
        val newBadges = mutableListOf<BadgeType>()
        val gameType = GameType.values().find { it.name == session.gameType } ?: return newBadges

        val percentile = mockService.calculatePercentile(session.score, gameType)

        if (percentile >= 75 && BadgeType.RISING_STAR !in existing) {
            newBadges.add(BadgeType.RISING_STAR)
        }
        if (percentile >= 90 && BadgeType.ELITE !in existing) {
            newBadges.add(BadgeType.ELITE)
        }
        if (percentile >= 95 && BadgeType.CHAMPION !in existing) {
            newBadges.add(BadgeType.CHAMPION)
        }
        if (percentile >= 99 && BadgeType.GENIUS !in existing) {
            newBadges.add(BadgeType.GENIUS)
        }

        return newBadges
    }

    suspend fun checkDifficultyUnlock(
        profileId: String,
        session: GameSession,
        repository: MiszIQRepository
    ): Int? {
        // Only unlock if 100% accuracy
        if (session.accuracy < 100) return null

        val currentLevel = session.level

        // Can only unlock levels 2 and 3
        if (currentLevel >= 3) return null

        val nextLevel = currentLevel + 1

        // Check if already unlocked
        val maxUnlocked = repository.getMaxUnlockedLevel(profileId, session.gameType)
        if (maxUnlocked >= nextLevel) return null

        // Create new unlock
        val unlock = DifficultyUnlock(
            profileId = profileId,
            gameType = session.gameType,
            level = nextLevel
        )
        repository.insertUnlock(unlock)

        return nextLevel
    }

    fun getBadgeProgress(sessions: List<GameSession>): Map<BadgeType, Double> {
        val progress = mutableMapOf<BadgeType, Double>()
        val totalGames = sessions.size
        val streak = calculateCurrentStreak(sessions)

        // Milestone progress
        progress[BadgeType.FIRST_STEPS] = minOf(1.0, totalGames / 1.0)
        progress[BadgeType.GETTING_STARTED] = minOf(1.0, totalGames / 10.0)
        progress[BadgeType.DEDICATED] = minOf(1.0, totalGames / 50.0)
        progress[BadgeType.COMMITTED] = minOf(1.0, totalGames / 100.0)
        progress[BadgeType.LEGEND] = minOf(1.0, totalGames / 500.0)

        // Streak progress
        progress[BadgeType.ON_TRACK] = minOf(1.0, streak / 3.0)
        progress[BadgeType.CONSISTENT] = minOf(1.0, streak / 7.0)
        progress[BadgeType.PERSISTENT] = minOf(1.0, streak / 14.0)
        progress[BadgeType.UNSTOPPABLE] = minOf(1.0, streak / 30.0)

        // Performance progress
        val hasPerfect = sessions.any { it.accuracy >= 100 }
        progress[BadgeType.PERFECTIONIST] = if (hasPerfect) 1.0 else 0.0

        return progress
    }
}
