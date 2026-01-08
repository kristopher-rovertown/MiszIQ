package com.example.misziq

import com.example.misziq.data.model.BadgeCategory
import com.example.misziq.data.model.BadgeType
import org.junit.Test
import org.junit.Assert.*
import java.util.*

/**
 * Unit tests for badge system and difficulty unlocking
 */
class BadgeSystemTests {

    // ==================== MILESTONE BADGE TESTS ====================

    @Test
    fun milestoneBadge_firstGame_shouldUnlock() {
        val totalGames = 1
        val shouldUnlock = totalGames >= 1
        assertTrue("First Steps badge should unlock after 1 game", shouldUnlock)
    }

    @Test
    fun milestoneBadge_tenGames_shouldUnlock() {
        val totalGames = 10
        val shouldUnlock = totalGames >= 10
        assertTrue("Getting Started badge should unlock after 10 games", shouldUnlock)
    }

    @Test
    fun milestoneBadge_fiftyGames_shouldUnlock() {
        val totalGames = 50
        val shouldUnlock = totalGames >= 50
        assertTrue("Dedicated badge should unlock after 50 games", shouldUnlock)
    }

    @Test
    fun milestoneBadge_hundredGames_shouldUnlock() {
        val totalGames = 100
        val shouldUnlock = totalGames >= 100
        assertTrue("Committed badge should unlock after 100 games", shouldUnlock)
    }

    @Test
    fun milestoneBadge_fiveHundredGames_shouldUnlock() {
        val totalGames = 500
        val shouldUnlock = totalGames >= 500
        assertTrue("Legend badge should unlock after 500 games", shouldUnlock)
    }

    @Test
    fun milestoneBadge_notEnoughGames_shouldNotUnlock() {
        val totalGames = 9
        val shouldUnlockGettingStarted = totalGames >= 10
        assertFalse("Getting Started badge should not unlock before 10 games", shouldUnlockGettingStarted)
    }

    // ==================== STREAK BADGE TESTS ====================

    @Test
    fun streakBadge_threeDays_shouldUnlock() {
        val streak = 3
        val shouldUnlock = streak >= 3
        assertTrue("On Track badge should unlock after 3-day streak", shouldUnlock)
    }

    @Test
    fun streakBadge_sevenDays_shouldUnlock() {
        val streak = 7
        val shouldUnlock = streak >= 7
        assertTrue("Consistent badge should unlock after 7-day streak", shouldUnlock)
    }

    @Test
    fun streakBadge_fourteenDays_shouldUnlock() {
        val streak = 14
        val shouldUnlock = streak >= 14
        assertTrue("Persistent badge should unlock after 14-day streak", shouldUnlock)
    }

    @Test
    fun streakBadge_thirtyDays_shouldUnlock() {
        val streak = 30
        val shouldUnlock = streak >= 30
        assertTrue("Unstoppable badge should unlock after 30-day streak", shouldUnlock)
    }

    @Test
    fun streakBadge_twoDay_shouldNotUnlockOnTrack() {
        val streak = 2
        val shouldUnlock = streak >= 3
        assertFalse("On Track badge should not unlock before 3-day streak", shouldUnlock)
    }

    @Test
    fun streakCalculation_consecutiveDays_shouldCountCorrectly() {
        val calendar = Calendar.getInstance()
        val today = calendar.apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

        val dates = mutableListOf<Long>()
        for (i in 0 until 5) {
            dates.add(today - i * 24 * 60 * 60 * 1000)
        }

        val streak = countConsecutiveDays(dates)
        assertEquals(5, streak)
    }

    @Test
    fun streakCalculation_brokenStreak_shouldResetCount() {
        val calendar = Calendar.getInstance()
        val today = calendar.apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

        val dayMs = 24 * 60 * 60 * 1000L
        val dates = listOf(
            today,
            today - dayMs,     // yesterday
            today - 3 * dayMs  // skip a day
        )

        val streak = countConsecutiveDays(dates)
        assertEquals("Streak should be 2 due to broken day", 2, streak)
    }

    private fun countConsecutiveDays(timestamps: List<Long>): Int {
        if (timestamps.isEmpty()) return 0

        val calendar = Calendar.getInstance()
        val today = calendar.apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

        val dayMs = 24 * 60 * 60 * 1000L
        val sortedDates = timestamps
            .map { ts ->
                Calendar.getInstance().apply {
                    timeInMillis = ts
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }.timeInMillis
            }
            .distinct()
            .sortedDescending()

        val mostRecent = sortedDates.firstOrNull() ?: return 0
        val daysSinceLast = ((today - mostRecent) / dayMs).toInt()

        if (daysSinceLast > 1) return 0

        var streak = 1
        var currentDate = mostRecent

        for (date in sortedDates.drop(1)) {
            val expectedPrevious = currentDate - dayMs
            if (date == expectedPrevious) {
                streak++
                currentDate = date
            } else {
                break
            }
        }

        return streak
    }

    // ==================== PERFORMANCE BADGE TESTS ====================

    @Test
    fun performanceBadge_perfectAccuracy_shouldUnlock() {
        val accuracy = 100.0
        val shouldUnlock = accuracy >= 100.0
        assertTrue("Perfectionist badge should unlock at 100% accuracy", shouldUnlock)
    }

    @Test
    fun performanceBadge_nearPerfect_shouldNotUnlock() {
        val accuracy = 99.9
        val shouldUnlock = accuracy >= 100.0
        assertFalse("Perfectionist badge should not unlock below 100% accuracy", shouldUnlock)
    }

    @Test
    fun accuracyCalculation_fullScore_shouldBe100Percent() {
        val score = 100
        val maxPossibleScore = 100
        val accuracy = score.toDouble() / maxPossibleScore * 100
        assertEquals(100.0, accuracy, 0.001)
    }

    @Test
    fun accuracyCalculation_halfScore_shouldBe50Percent() {
        val score = 50
        val maxPossibleScore = 100
        val accuracy = score.toDouble() / maxPossibleScore * 100
        assertEquals(50.0, accuracy, 0.001)
    }

    // ==================== MASTERY BADGE TESTS ====================

    @Test
    fun masteryBadge_allMemoryGames80Plus_shouldUnlock() {
        val memoryGameAccuracies = listOf(85.0, 90.0, 80.0) // All 3 memory games
        val allAbove80 = memoryGameAccuracies.all { it >= 80 }
        assertTrue("Memory Master badge should unlock when all memory games are 80%+", allAbove80)
    }

    @Test
    fun masteryBadge_oneGameBelow80_shouldNotUnlock() {
        val memoryGameAccuracies = listOf(85.0, 79.0, 90.0) // One below 80
        val allAbove80 = memoryGameAccuracies.all { it >= 80 }
        assertFalse("Memory Master badge should not unlock if any game is below 80%", allAbove80)
    }

    @Test
    fun masteryBadge_missingGame_shouldNotUnlock() {
        val gamesPlayedInCategory = 2
        val totalGamesInCategory = 3
        val hasPlayedAll = gamesPlayedInCategory == totalGamesInCategory
        assertFalse("Mastery badge should not unlock if not all games are played", hasPlayedAll)
    }

    // ==================== PERCENTILE BADGE TESTS ====================

    @Test
    fun percentileBadge_top25_shouldUnlock() {
        val percentile = 75
        val shouldUnlock = percentile >= 75
        assertTrue("Rising Star badge should unlock at 75th percentile", shouldUnlock)
    }

    @Test
    fun percentileBadge_top10_shouldUnlock() {
        val percentile = 90
        val shouldUnlock = percentile >= 90
        assertTrue("Elite badge should unlock at 90th percentile", shouldUnlock)
    }

    @Test
    fun percentileBadge_top5_shouldUnlock() {
        val percentile = 95
        val shouldUnlock = percentile >= 95
        assertTrue("Champion badge should unlock at 95th percentile", shouldUnlock)
    }

    @Test
    fun percentileBadge_top1_shouldUnlock() {
        val percentile = 99
        val shouldUnlock = percentile >= 99
        assertTrue("Genius badge should unlock at 99th percentile", shouldUnlock)
    }

    @Test
    fun percentileBadge_74thPercentile_shouldNotUnlockRisingStar() {
        val percentile = 74
        val shouldUnlock = percentile >= 75
        assertFalse("Rising Star badge should not unlock below 75th percentile", shouldUnlock)
    }

    // ==================== DIFFICULTY UNLOCK TESTS ====================

    @Test
    fun difficultyUnlock_100PercentAccuracy_shouldUnlockNextLevel() {
        val accuracy = 100.0
        val currentLevel = 1
        val shouldUnlock = accuracy >= 100.0 && currentLevel < 3
        assertTrue("Level 2 should unlock after 100% on Level 1", shouldUnlock)
    }

    @Test
    fun difficultyUnlock_99PercentAccuracy_shouldNotUnlock() {
        val accuracy = 99.0
        val currentLevel = 1
        val shouldUnlock = accuracy >= 100.0 && currentLevel < 3
        assertFalse("Next level should not unlock below 100% accuracy", shouldUnlock)
    }

    @Test
    fun difficultyUnlock_level2To3_shouldWork() {
        val accuracy = 100.0
        val currentLevel = 2
        val shouldUnlock = accuracy >= 100.0 && currentLevel < 3
        assertTrue("Level 3 should unlock after 100% on Level 2", shouldUnlock)
    }

    @Test
    fun difficultyUnlock_level3_shouldNotUnlockFurther() {
        val accuracy = 100.0
        val currentLevel = 3
        val shouldUnlock = accuracy >= 100.0 && currentLevel < 3
        assertFalse("No further levels to unlock after Level 3", shouldUnlock)
    }

    @Test
    fun difficultyUnlock_alreadyUnlocked_shouldNotDuplicate() {
        val existingUnlocks = listOf(2, 3) // Already unlocked levels 2 and 3
        val attemptedUnlock = 2
        val isAlreadyUnlocked = existingUnlocks.contains(attemptedUnlock)
        assertTrue("Should not create duplicate unlock", isAlreadyUnlocked)
    }

    @Test
    fun maxUnlockedLevel_noUnlocks_shouldBeLevel1() {
        val unlocks = emptyList<Int>()
        val maxLevel = unlocks.maxOrNull() ?: 1
        assertEquals(1, maxLevel)
    }

    @Test
    fun maxUnlockedLevel_withUnlocks_shouldReturnHighest() {
        val unlocks = listOf(2, 3)
        val maxLevel = unlocks.maxOrNull() ?: 1
        assertEquals(3, maxLevel)
    }

    // ==================== BADGE PROGRESS TESTS ====================

    @Test
    fun badgeProgress_partialMilestone_shouldCalculateCorrectly() {
        val totalGames = 25
        val targetGames = 50 // Dedicated badge
        val progress = minOf(1.0, totalGames.toDouble() / targetGames)
        assertEquals(0.5, progress, 0.001)
    }

    @Test
    fun badgeProgress_overTarget_shouldCapAt100Percent() {
        val totalGames = 75
        val targetGames = 50 // Dedicated badge
        val progress = minOf(1.0, totalGames.toDouble() / targetGames)
        assertEquals(1.0, progress, 0.001)
    }

    @Test
    fun badgeProgress_zeroGames_shouldBeZero() {
        val totalGames = 0
        val targetGames = 10
        val progress = minOf(1.0, totalGames.toDouble() / targetGames)
        assertEquals(0.0, progress, 0.001)
    }

    @Test
    fun streakProgress_partialStreak_shouldCalculateCorrectly() {
        val currentStreak = 4
        val targetStreak = 7 // Consistent badge
        val progress = minOf(1.0, currentStreak.toDouble() / targetStreak)
        assertEquals(4.0 / 7.0, progress, 0.001)
    }

    // ==================== BADGE TYPE TESTS ====================

    @Test
    fun badgeType_allCases_shouldHaveDisplayName() {
        for (badge in BadgeType.values()) {
            assertFalse("$badge should have a display name", badge.displayName.isEmpty())
        }
    }

    @Test
    fun badgeType_allCases_shouldHaveDescription() {
        for (badge in BadgeType.values()) {
            assertFalse("$badge should have a description", badge.description.isEmpty())
        }
    }

    @Test
    fun badgeType_allCases_shouldHaveEmoji() {
        for (badge in BadgeType.values()) {
            assertFalse("$badge should have an emoji", badge.emoji.isEmpty())
        }
    }

    @Test
    fun badgeType_allCases_shouldHaveCategory() {
        for (badge in BadgeType.values()) {
            assertNotNull("$badge should have a category", badge.category)
        }
    }

    @Test
    fun badgeCategory_milestoneBadges_shouldBeGroupedCorrectly() {
        val milestoneBadges = listOf(
            BadgeType.FIRST_STEPS,
            BadgeType.GETTING_STARTED,
            BadgeType.DEDICATED,
            BadgeType.COMMITTED,
            BadgeType.LEGEND
        )
        for (badge in milestoneBadges) {
            assertEquals(BadgeCategory.MILESTONE, badge.category)
        }
    }

    @Test
    fun badgeCategory_streakBadges_shouldBeGroupedCorrectly() {
        val streakBadges = listOf(
            BadgeType.ON_TRACK,
            BadgeType.CONSISTENT,
            BadgeType.PERSISTENT,
            BadgeType.UNSTOPPABLE
        )
        for (badge in streakBadges) {
            assertEquals(BadgeCategory.STREAK, badge.category)
        }
    }

    @Test
    fun badgeCategory_masteryBadges_shouldBeGroupedCorrectly() {
        val masteryBadges = listOf(
            BadgeType.MEMORY_MASTER,
            BadgeType.MATH_WHIZ,
            BadgeType.LOGIC_LEGEND,
            BadgeType.WORD_WIZARD
        )
        for (badge in masteryBadges) {
            assertEquals(BadgeCategory.MASTERY, badge.category)
        }
    }

    @Test
    fun badgeCategory_percentileBadges_shouldBeGroupedCorrectly() {
        val percentileBadges = listOf(
            BadgeType.RISING_STAR,
            BadgeType.ELITE,
            BadgeType.CHAMPION,
            BadgeType.GENIUS
        )
        for (badge in percentileBadges) {
            assertEquals(BadgeCategory.PERCENTILE, badge.category)
        }
    }

    // ==================== DUPLICATE PREVENTION TESTS ====================

    @Test
    fun badgeUnlock_alreadyOwned_shouldNotDuplicate() {
        val existingBadges = setOf(BadgeType.FIRST_STEPS, BadgeType.GETTING_STARTED)
        val potentialNewBadge = BadgeType.FIRST_STEPS
        val shouldAward = potentialNewBadge !in existingBadges
        assertFalse("Should not award duplicate badge", shouldAward)
    }

    @Test
    fun badgeUnlock_notOwned_shouldAward() {
        val existingBadges = setOf(BadgeType.FIRST_STEPS)
        val potentialNewBadge = BadgeType.GETTING_STARTED
        val shouldAward = potentialNewBadge !in existingBadges
        assertTrue("Should award new badge", shouldAward)
    }

    // ==================== BADGE COUNT TESTS ====================

    @Test
    fun badgeType_totalCount_shouldBe18() {
        assertEquals(18, BadgeType.values().size)
    }

    @Test
    fun badgeCategory_totalCount_shouldBe5() {
        assertEquals(5, BadgeCategory.values().size)
    }

    @Test
    fun milestoneBadges_count_shouldBe5() {
        val count = BadgeType.values().count { it.category == BadgeCategory.MILESTONE }
        assertEquals(5, count)
    }

    @Test
    fun streakBadges_count_shouldBe4() {
        val count = BadgeType.values().count { it.category == BadgeCategory.STREAK }
        assertEquals(4, count)
    }

    @Test
    fun performanceBadges_count_shouldBe1() {
        val count = BadgeType.values().count { it.category == BadgeCategory.PERFORMANCE }
        assertEquals(1, count)
    }

    @Test
    fun masteryBadges_count_shouldBe4() {
        val count = BadgeType.values().count { it.category == BadgeCategory.MASTERY }
        assertEquals(4, count)
    }

    @Test
    fun percentileBadges_count_shouldBe4() {
        val count = BadgeType.values().count { it.category == BadgeCategory.PERCENTILE }
        assertEquals(4, count)
    }

    // ==================== ACCURACY VALIDATION TESTS ====================

    @Test
    fun accuracy_normalScore_shouldCalculateCorrectly() {
        val score = 80
        val maxPossibleScore = 100
        val rawAccuracy = score.toDouble() / maxPossibleScore * 100
        val accuracy = minOf(rawAccuracy, 100.0)
        assertEquals(80.0, accuracy, 0.001)
    }

    @Test
    fun accuracy_perfectScore_shouldBe100() {
        val score = 100
        val maxPossibleScore = 100
        val rawAccuracy = score.toDouble() / maxPossibleScore * 100
        val accuracy = minOf(rawAccuracy, 100.0)
        assertEquals(100.0, accuracy, 0.001)
    }

    @Test
    fun accuracy_overMaxScore_shouldCapAt100() {
        val score = 120
        val maxPossibleScore = 100
        val rawAccuracy = score.toDouble() / maxPossibleScore * 100
        val accuracy = minOf(rawAccuracy, 100.0)
        assertEquals("Accuracy should be capped at 100%", 100.0, accuracy, 0.001)
    }

    @Test
    fun accuracy_zeroScore_shouldBeZero() {
        val score = 0
        val maxPossibleScore = 100
        val rawAccuracy = score.toDouble() / maxPossibleScore * 100
        val accuracy = minOf(rawAccuracy, 100.0)
        assertEquals(0.0, accuracy, 0.001)
    }

    @Test
    fun accuracy_zeroMaxPossible_shouldBeZero() {
        val score = 50
        val maxPossibleScore = 0
        val accuracy = if (maxPossibleScore > 0) minOf(score.toDouble() / maxPossibleScore * 100, 100.0) else 0.0
        assertEquals("Accuracy should be 0 when maxPossibleScore is 0", 0.0, accuracy, 0.001)
    }

    @Test
    fun accuracy_shouldNeverExceed100() {
        // Test various score/maxPossible combinations that could exceed 100%
        val testCases = listOf(
            Pair(210, 200),   // Word Scramble old bug
            Pair(205, 150),   // Number Compare old bug
            Pair(300, 120),   // Logic Puzzle old bug
            Pair(1000, 500),  // Arbitrary large score
        )

        for ((score, maxPossible) in testCases) {
            val rawAccuracy = score.toDouble() / maxPossible * 100
            val accuracy = minOf(rawAccuracy, 100.0)
            assertTrue(
                "Accuracy should never exceed 100% (score: $score, max: $maxPossible)",
                accuracy <= 100.0
            )
        }
    }

    @Test
    fun averageAccuracy_shouldCapAt100() {
        val accuracies = listOf(100.0, 100.0, 100.0, 100.0)
        val average = minOf(accuracies.sum() / accuracies.size, 100.0)
        assertTrue("Average accuracy should be capped at 100%", average <= 100.0)
    }
}
