package com.example.misziq.data.repository

import android.content.Context
import androidx.room.*
import com.example.misziq.data.model.Achievement
import com.example.misziq.data.model.DifficultyUnlock
import com.example.misziq.data.model.GameSession
import com.example.misziq.data.model.UserProfile
import kotlinx.coroutines.flow.Flow

@Dao
interface UserProfileDao {
    @Query("SELECT * FROM user_profiles ORDER BY createdAt DESC")
    fun getAllProfiles(): Flow<List<UserProfile>>

    @Query("SELECT * FROM user_profiles WHERE id = :id")
    suspend fun getProfileById(id: String): UserProfile?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProfile(profile: UserProfile)

    @Update
    suspend fun updateProfile(profile: UserProfile)

    @Delete
    suspend fun deleteProfile(profile: UserProfile)
}

@Dao
interface GameSessionDao {
    @Query("SELECT * FROM game_sessions WHERE profileId = :profileId ORDER BY completedAt DESC")
    fun getSessionsForProfile(profileId: String): Flow<List<GameSession>>

    @Query("SELECT * FROM game_sessions WHERE profileId = :profileId AND gameType = :gameType ORDER BY completedAt DESC")
    fun getSessionsForProfileAndGame(profileId: String, gameType: String): Flow<List<GameSession>>

    @Insert
    suspend fun insertSession(session: GameSession)

    @Query("DELETE FROM game_sessions WHERE profileId = :profileId")
    suspend fun deleteSessionsForProfile(profileId: String)
}

@Dao
interface AchievementDao {
    @Query("SELECT * FROM achievements WHERE profileId = :profileId ORDER BY unlockedAt DESC")
    fun getAchievementsForProfile(profileId: String): Flow<List<Achievement>>

    @Query("SELECT * FROM achievements WHERE profileId = :profileId")
    suspend fun getAchievementsForProfileSync(profileId: String): List<Achievement>

    @Insert
    suspend fun insertAchievement(achievement: Achievement)

    @Query("DELETE FROM achievements WHERE profileId = :profileId")
    suspend fun deleteAchievementsForProfile(profileId: String)
}

@Dao
interface DifficultyUnlockDao {
    @Query("SELECT * FROM difficulty_unlocks WHERE profileId = :profileId")
    fun getUnlocksForProfile(profileId: String): Flow<List<DifficultyUnlock>>

    @Query("SELECT * FROM difficulty_unlocks WHERE profileId = :profileId AND gameType = :gameType")
    suspend fun getUnlocksForGame(profileId: String, gameType: String): List<DifficultyUnlock>

    @Query("SELECT MAX(level) FROM difficulty_unlocks WHERE profileId = :profileId AND gameType = :gameType")
    suspend fun getMaxUnlockedLevel(profileId: String, gameType: String): Int?

    @Insert
    suspend fun insertUnlock(unlock: DifficultyUnlock)

    @Query("DELETE FROM difficulty_unlocks WHERE profileId = :profileId")
    suspend fun deleteUnlocksForProfile(profileId: String)
}

@Database(
    entities = [UserProfile::class, GameSession::class, Achievement::class, DifficultyUnlock::class],
    version = 2,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userProfileDao(): UserProfileDao
    abstract fun gameSessionDao(): GameSessionDao
    abstract fun achievementDao(): AchievementDao
    abstract fun difficultyUnlockDao(): DifficultyUnlockDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "iq_trainer_database"
                )
                    .fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}

class MiszIQRepository(private val database: AppDatabase) {
    val allProfiles: Flow<List<UserProfile>> = database.userProfileDao().getAllProfiles()

    fun getSessionsForProfile(profileId: String): Flow<List<GameSession>> =
        database.gameSessionDao().getSessionsForProfile(profileId)

    suspend fun getProfileById(id: String): UserProfile? =
        database.userProfileDao().getProfileById(id)

    suspend fun insertProfile(profile: UserProfile) =
        database.userProfileDao().insertProfile(profile)

    suspend fun updateProfile(profile: UserProfile) =
        database.userProfileDao().updateProfile(profile)

    suspend fun deleteProfile(profile: UserProfile) {
        database.gameSessionDao().deleteSessionsForProfile(profile.id)
        database.achievementDao().deleteAchievementsForProfile(profile.id)
        database.difficultyUnlockDao().deleteUnlocksForProfile(profile.id)
        database.userProfileDao().deleteProfile(profile)
    }

    suspend fun insertSession(session: GameSession) =
        database.gameSessionDao().insertSession(session)

    // Achievement methods
    fun getAchievementsForProfile(profileId: String): Flow<List<Achievement>> =
        database.achievementDao().getAchievementsForProfile(profileId)

    suspend fun getAchievementsForProfileSync(profileId: String): List<Achievement> =
        database.achievementDao().getAchievementsForProfileSync(profileId)

    suspend fun insertAchievement(achievement: Achievement) =
        database.achievementDao().insertAchievement(achievement)

    // Difficulty unlock methods
    fun getUnlocksForProfile(profileId: String): Flow<List<DifficultyUnlock>> =
        database.difficultyUnlockDao().getUnlocksForProfile(profileId)

    suspend fun getUnlocksForGame(profileId: String, gameType: String): List<DifficultyUnlock> =
        database.difficultyUnlockDao().getUnlocksForGame(profileId, gameType)

    suspend fun getMaxUnlockedLevel(profileId: String, gameType: String): Int =
        database.difficultyUnlockDao().getMaxUnlockedLevel(profileId, gameType) ?: 1

    suspend fun insertUnlock(unlock: DifficultyUnlock) =
        database.difficultyUnlockDao().insertUnlock(unlock)

    // Reset progress methods (for settings)
    suspend fun deleteSessionsForProfile(profileId: String) =
        database.gameSessionDao().deleteSessionsForProfile(profileId)

    suspend fun deleteUnlocksForProfile(profileId: String) =
        database.difficultyUnlockDao().deleteUnlocksForProfile(profileId)
}
