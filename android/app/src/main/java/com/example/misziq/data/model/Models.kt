package com.example.misziq.data.model

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import androidx.room.Index
import java.util.UUID

@Entity(tableName = "user_profiles")
data class UserProfile(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val name: String,
    val avatarEmoji: String = "🧠",
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(
    tableName = "game_sessions",
    foreignKeys = [ForeignKey(
        entity = UserProfile::class,
        parentColumns = ["id"],
        childColumns = ["profileId"],
        onDelete = ForeignKey.CASCADE
    )],
    indices = [Index("profileId")]
)
data class GameSession(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val profileId: String,
    val gameType: String,
    val score: Int,
    val maxPossibleScore: Int,
    val level: Int,
    val completedAt: Long = System.currentTimeMillis(),
    val durationSeconds: Int
) {
    val accuracy: Double
        get() = if (maxPossibleScore > 0) minOf(score.toDouble() / maxPossibleScore * 100, 100.0) else 0.0
}

@Entity(
    tableName = "achievements",
    foreignKeys = [ForeignKey(
        entity = UserProfile::class,
        parentColumns = ["id"],
        childColumns = ["profileId"],
        onDelete = ForeignKey.CASCADE
    )],
    indices = [Index("profileId")]
)
data class Achievement(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val profileId: String,
    val badgeType: String,
    val unlockedAt: Long = System.currentTimeMillis()
) {
    val type: BadgeType?
        get() = BadgeType.values().find { it.id == badgeType }
}

@Entity(
    tableName = "difficulty_unlocks",
    foreignKeys = [ForeignKey(
        entity = UserProfile::class,
        parentColumns = ["id"],
        childColumns = ["profileId"],
        onDelete = ForeignKey.CASCADE
    )],
    indices = [Index("profileId")]
)
data class DifficultyUnlock(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val profileId: String,
    val gameType: String,
    val level: Int,
    val unlockedAt: Long = System.currentTimeMillis()
) {
    val game: GameType?
        get() = GameType.values().find { it.name == gameType }
}

enum class BadgeType(
    val id: String,
    val displayName: String,
    val description: String,
    val emoji: String,
    val category: BadgeCategory
) {
    // Milestones
    FIRST_STEPS("first_steps", "First Steps", "Complete your first game", "🎯", BadgeCategory.MILESTONE),
    GETTING_STARTED("getting_started", "Getting Started", "Complete 10 games", "🌟", BadgeCategory.MILESTONE),
    DEDICATED("dedicated", "Dedicated", "Complete 50 games", "💪", BadgeCategory.MILESTONE),
    COMMITTED("committed", "Committed", "Complete 100 games", "🔥", BadgeCategory.MILESTONE),
    LEGEND("legend", "Legend", "Complete 500 games", "👑", BadgeCategory.MILESTONE),

    // Streaks
    ON_TRACK("on_track", "On Track", "Maintain a 3-day streak", "📅", BadgeCategory.STREAK),
    CONSISTENT("consistent", "Consistent", "Maintain a 7-day streak", "🗓️", BadgeCategory.STREAK),
    PERSISTENT("persistent", "Persistent", "Maintain a 14-day streak", "📆", BadgeCategory.STREAK),
    UNSTOPPABLE("unstoppable", "Unstoppable", "Maintain a 30-day streak", "⚡", BadgeCategory.STREAK),

    // Performance
    PERFECTIONIST("perfectionist", "Perfectionist", "Achieve 100% accuracy in any game", "✨", BadgeCategory.PERFORMANCE),

    // Category Mastery
    MEMORY_MASTER("memory_master", "Memory Master", "Score 80%+ in all Memory games", "🧠", BadgeCategory.MASTERY),
    MATH_WHIZ("math_whiz", "Math Whiz", "Score 80%+ in all Math games", "🔢", BadgeCategory.MASTERY),
    LOGIC_LEGEND("logic_legend", "Logic Legend", "Score 80%+ in all Logic games", "🧩", BadgeCategory.MASTERY),
    WORD_WIZARD("word_wizard", "Word Wizard", "Score 80%+ in all Language games", "📚", BadgeCategory.MASTERY),

    // Percentile
    RISING_STAR("rising_star", "Rising Star", "Reach top 25% in any game", "⭐", BadgeCategory.PERCENTILE),
    ELITE("elite", "Elite", "Reach top 10% in any game", "🌟", BadgeCategory.PERCENTILE),
    CHAMPION("champion", "Champion", "Reach top 5% in any game", "🏆", BadgeCategory.PERCENTILE),
    GENIUS("genius", "Genius", "Reach top 1% in any game", "💎", BadgeCategory.PERCENTILE)
}

enum class BadgeCategory(val displayName: String) {
    MILESTONE("Milestones"),
    STREAK("Streaks"),
    PERFORMANCE("Performance"),
    MASTERY("Mastery"),
    PERCENTILE("Rankings")
}

enum class GameCategory(val displayName: String, val icon: String, val color: Long) {
    // Unified theme: Royal Blue (0xFF4169E1) for most categories, Turquoise (0xFF40E0D0) for Language
    MEMORY("Memory", "🧠", 0xFF4169E1),
    MENTAL_MATH("Mental Math", "🔢", 0xFF4169E1),
    PROBLEM_SOLVING("Problem Solving", "🧩", 0xFF4169E1),
    LANGUAGE("Language", "📚", 0xFF40E0D0);

    val games: List<GameType>
        get() = GameType.values().filter { it.category == this }
}

enum class GameType(
    val displayName: String,
    val description: String,
    val icon: String,
    val category: GameCategory
) {
    // Memory
    MEMORY_GRID("Memory Grid", "Remember the positions of highlighted tiles", "🔲", GameCategory.MEMORY),
    SEQUENCE_MEMORY("Sequence Memory", "Repeat the sequence of lights", "🔀", GameCategory.MEMORY),
    WORD_RECALL("Word Recall", "Memorize and recall a list of words", "📝", GameCategory.MEMORY),

    // Mental Math
    MENTAL_MATH("Mental Math", "Solve arithmetic problems quickly", "➕", GameCategory.MENTAL_MATH),
    NUMBER_COMPARISON("Number Compare", "Compare expressions quickly", "⚖️", GameCategory.MENTAL_MATH),
    ESTIMATION("Estimation", "Estimate quantities and values", "🎯", GameCategory.MENTAL_MATH),

    // Problem Solving
    PATTERN_MATCH("Pattern Match", "Find the pattern that completes the sequence", "🔢", GameCategory.PROBLEM_SOLVING),
    LOGIC_PUZZLE("Logic Puzzle", "Solve logical reasoning problems", "💡", GameCategory.PROBLEM_SOLVING),
    TOWER_OF_HANOI("Tower of Hanoi", "Move all disks to the target peg", "🗼", GameCategory.PROBLEM_SOLVING),

    // Language
    WORD_SCRAMBLE("Word Scramble", "Unscramble letters to form words", "🔤", GameCategory.LANGUAGE),
    VERBAL_ANALOGIES("Analogies", "Complete word relationships", "↔️", GameCategory.LANGUAGE),
    VOCABULARY("Vocabulary", "Test your word knowledge", "📖", GameCategory.LANGUAGE);

    val color: Long get() = category.color
}

data class GameStatistics(
    val averageScore: Double,
    val highScore: Int,
    val totalGamesPlayed: Int,
    val averageAccuracy: Double,
    val percentile: Int,
    val recentTrend: Trend
) {
    enum class Trend(val icon: String, val color: Long) {
        IMPROVING("↗", 0xFF4CAF50),
        DECLINING("↘", 0xFFF44336),
        STABLE("→", 0xFF9E9E9E)
    }

    companion object {
        fun calculate(sessions: List<GameSession>, gameType: GameType, mockService: MockDataService): GameStatistics {
            val gameSessions = sessions.filter { it.gameType == gameType.name }

            if (gameSessions.isEmpty()) {
                return GameStatistics(0.0, 0, 0, 0.0, 50, Trend.STABLE)
            }

            val scores = gameSessions.map { it.score }
            val averageScore = scores.average()
            val highScore = scores.maxOrNull() ?: 0
            val averageAccuracy = gameSessions.map { it.accuracy }.average()
            val percentile = mockService.calculatePercentile(averageScore.toInt(), gameType)

            val trend = if (gameSessions.size >= 3) {
                val sorted = gameSessions.sortedBy { it.completedAt }
                val recentAvg = sorted.takeLast(5).map { it.score }.average()
                val olderAvg = sorted.dropLast(5).takeIf { it.isNotEmpty() }?.map { it.score }?.average() ?: recentAvg

                when {
                    recentAvg > olderAvg * 1.1 -> Trend.IMPROVING
                    recentAvg < olderAvg * 0.9 -> Trend.DECLINING
                    else -> Trend.STABLE
                }
            } else {
                Trend.STABLE
            }

            return GameStatistics(averageScore, highScore, gameSessions.size, averageAccuracy, percentile, trend)
        }
    }
}

class MockDataService {
    private val scoreDistributions = mapOf(
        GameType.MEMORY_GRID to Pair(65.0, 20.0),
        GameType.SEQUENCE_MEMORY to Pair(8.0, 3.0),
        GameType.WORD_RECALL to Pair(12.0, 4.0),
        GameType.MENTAL_MATH to Pair(55.0, 25.0),
        GameType.NUMBER_COMPARISON to Pair(70.0, 15.0),
        GameType.ESTIMATION to Pair(60.0, 20.0),
        GameType.PATTERN_MATCH to Pair(70.0, 18.0),
        GameType.LOGIC_PUZZLE to Pair(50.0, 20.0),
        GameType.TOWER_OF_HANOI to Pair(40.0, 15.0),
        GameType.WORD_SCRAMBLE to Pair(65.0, 18.0),
        GameType.VERBAL_ANALOGIES to Pair(55.0, 20.0),
        GameType.VOCABULARY to Pair(60.0, 22.0)
    )

    fun calculatePercentile(score: Int, gameType: GameType): Int {
        val (mean, stdDev) = scoreDistributions[gameType] ?: return 50
        val zScore = (score - mean) / stdDev
        val percentile = (normalCDF(zScore) * 100).toInt()
        return percentile.coerceIn(1, 99)
    }

    fun getPerformanceBracket(percentile: Int): Triple<String, Long, String> {
        // Theme-consistent bracket colors using Royal Blue and Turquoise
        return when (percentile) {
            in 90..100 -> Triple("Exceptional", 0xFF40E0D0, "Top performers")       // Turquoise
            in 70..89 -> Triple("Advanced", 0xFF4169E1, "High performers")          // Royal Blue
            in 50..69 -> Triple("Proficient", 0xFF40A4D8, "Mid-range")              // Blend
            else -> Triple("Developing", 0xFF4169E1.and(0xB3FFFFFF), "Room to grow") // Royal Blue faded
        }
    }

    private fun normalCDF(x: Double): Double {
        return 0.5 * (1 + erf(x / kotlin.math.sqrt(2.0)))
    }

    private fun erf(x: Double): Double {
        val a1 = 0.254829592
        val a2 = -0.284496736
        val a3 = 1.421413741
        val a4 = -1.453152027
        val a5 = 1.061405429
        val p = 0.3275911

        val sign = if (x < 0) -1.0 else 1.0
        val absX = kotlin.math.abs(x)
        val t = 1.0 / (1.0 + p * absX)
        val y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * kotlin.math.exp(-absX * absX)

        return sign * y
    }
}
