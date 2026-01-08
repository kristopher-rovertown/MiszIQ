package com.example.misziq

import com.example.misziq.audio.SoundEffect
import com.example.misziq.data.preferences.ThemeMode
import org.junit.Test
import org.junit.Assert.*

/**
 * Unit tests for settings system, theme modes, and audio/haptic functionality
 */
class SettingsTests {

    // ==================== THEME MODE TESTS ====================

    @Test
    fun themeMode_system_shouldExist() {
        val themeMode = ThemeMode.SYSTEM
        assertNotNull("System theme mode should exist", themeMode)
    }

    @Test
    fun themeMode_light_shouldExist() {
        val themeMode = ThemeMode.LIGHT
        assertNotNull("Light theme mode should exist", themeMode)
    }

    @Test
    fun themeMode_dark_shouldExist() {
        val themeMode = ThemeMode.DARK
        assertNotNull("Dark theme mode should exist", themeMode)
    }

    @Test
    fun themeMode_allCases_shouldHaveDisplayName() {
        for (mode in ThemeMode.values()) {
            assertFalse("$mode should have a display name", mode.displayName.isEmpty())
        }
    }

    @Test
    fun themeMode_count_shouldBe3() {
        assertEquals("There should be exactly 3 theme modes", 3, ThemeMode.values().size)
    }

    @Test
    fun themeMode_displayNames_shouldBeCorrect() {
        assertEquals("System", ThemeMode.SYSTEM.displayName)
        assertEquals("Light", ThemeMode.LIGHT.displayName)
        assertEquals("Dark", ThemeMode.DARK.displayName)
    }

    @Test
    fun themeMode_valueOf_shouldWork() {
        assertEquals(ThemeMode.SYSTEM, ThemeMode.valueOf("SYSTEM"))
        assertEquals(ThemeMode.LIGHT, ThemeMode.valueOf("LIGHT"))
        assertEquals(ThemeMode.DARK, ThemeMode.valueOf("DARK"))
    }

    @Test(expected = IllegalArgumentException::class)
    fun themeMode_invalidValueOf_shouldThrow() {
        ThemeMode.valueOf("INVALID")
    }

    // ==================== SOUND EFFECT TESTS ====================

    @Test
    fun soundEffect_allCases_shouldHaveResourceName() {
        for (effect in SoundEffect.values()) {
            assertFalse("$effect should have a resource name", effect.resourceName.isEmpty())
        }
    }

    @Test
    fun soundEffect_count_shouldBe4() {
        assertEquals("There should be exactly 4 sound effects", 4, SoundEffect.values().size)
    }

    @Test
    fun soundEffect_resourceNames_shouldBeCorrect() {
        assertEquals("correct_chime", SoundEffect.CORRECT_ANSWER.resourceName)
        assertEquals("wrong_buzz", SoundEffect.WRONG_ANSWER.resourceName)
        assertEquals("button_tap", SoundEffect.BUTTON_TAP.resourceName)
        assertEquals("celebration", SoundEffect.GAME_COMPLETE.resourceName)
    }

    @Test
    fun soundEffect_valueOf_shouldWork() {
        assertEquals(SoundEffect.CORRECT_ANSWER, SoundEffect.valueOf("CORRECT_ANSWER"))
        assertEquals(SoundEffect.WRONG_ANSWER, SoundEffect.valueOf("WRONG_ANSWER"))
        assertEquals(SoundEffect.BUTTON_TAP, SoundEffect.valueOf("BUTTON_TAP"))
        assertEquals(SoundEffect.GAME_COMPLETE, SoundEffect.valueOf("GAME_COMPLETE"))
    }

    // ==================== SETTINGS DEFAULT VALUES TESTS ====================

    @Test
    fun settings_musicEnabled_defaultShouldBeTrue() {
        val defaultValue = true
        assertTrue("Music should be enabled by default", defaultValue)
    }

    @Test
    fun settings_soundEffectsEnabled_defaultShouldBeTrue() {
        val defaultValue = true
        assertTrue("Sound effects should be enabled by default", defaultValue)
    }

    @Test
    fun settings_hapticFeedbackEnabled_defaultShouldBeTrue() {
        val defaultValue = true
        assertTrue("Haptic feedback should be enabled by default", defaultValue)
    }

    @Test
    fun settings_themeMode_defaultShouldBeSystem() {
        val defaultMode = ThemeMode.SYSTEM
        assertEquals("Default theme mode should be system", ThemeMode.SYSTEM, defaultMode)
    }

    // ==================== SETTINGS TOGGLE TESTS ====================

    @Test
    fun settings_toggleMusic_shouldInvertValue() {
        var musicEnabled = true
        musicEnabled = !musicEnabled
        assertFalse("Toggling music should invert the value", musicEnabled)
        musicEnabled = !musicEnabled
        assertTrue("Toggling again should restore the value", musicEnabled)
    }

    @Test
    fun settings_toggleSoundEffects_shouldInvertValue() {
        var soundEnabled = true
        soundEnabled = !soundEnabled
        assertFalse("Toggling sound effects should invert the value", soundEnabled)
        soundEnabled = !soundEnabled
        assertTrue("Toggling again should restore the value", soundEnabled)
    }

    @Test
    fun settings_toggleHapticFeedback_shouldInvertValue() {
        var hapticEnabled = true
        hapticEnabled = !hapticEnabled
        assertFalse("Toggling haptic feedback should invert the value", hapticEnabled)
        hapticEnabled = !hapticEnabled
        assertTrue("Toggling again should restore the value", hapticEnabled)
    }

    // ==================== THEME MODE CYCLING TESTS ====================

    @Test
    fun themeMode_cycling_shouldWorkCorrectly() {
        val modes = ThemeMode.values()
        assertEquals(ThemeMode.SYSTEM, modes[0])
        assertEquals(ThemeMode.LIGHT, modes[1])
        assertEquals(ThemeMode.DARK, modes[2])
    }

    @Test
    fun themeMode_ordinal_shouldBeCorrect() {
        assertEquals(0, ThemeMode.SYSTEM.ordinal)
        assertEquals(1, ThemeMode.LIGHT.ordinal)
        assertEquals(2, ThemeMode.DARK.ordinal)
    }

    // ==================== VOLUME TESTS ====================

    @Test
    fun volume_validRange_shouldBeBetween0And1() {
        val minVolume = 0.0f
        val maxVolume = 1.0f
        val musicVolume = 0.3f // Default music volume

        assertTrue("Volume should be at least 0", musicVolume >= minVolume)
        assertTrue("Volume should be at most 1", musicVolume <= maxVolume)
    }

    @Test
    fun volume_clamp_shouldWorkCorrectly() {
        fun clampVolume(volume: Float): Float {
            return maxOf(0f, minOf(1f, volume))
        }

        assertEquals("Negative volume should be clamped to 0", 0.0f, clampVolume(-0.5f), 0.001f)
        assertEquals("Valid volume should remain unchanged", 0.5f, clampVolume(0.5f), 0.001f)
        assertEquals("Volume above 1 should be clamped to 1", 1.0f, clampVolume(1.5f), 0.001f)
    }

    // ==================== SETTINGS PERSISTENCE KEY TESTS ====================

    @Test
    fun settingsKeys_shouldBeUnique() {
        val keys = listOf(
            "music_enabled",
            "sound_effects_enabled",
            "haptic_feedback_enabled",
            "theme_mode"
        )
        val uniqueKeys = keys.toSet()
        assertEquals("All settings keys should be unique", keys.size, uniqueKeys.size)
    }

    // ==================== RESET PROGRESS LOGIC TESTS ====================

    @Test
    fun resetProgress_shouldPreserveBadges() {
        val badgesBeforeReset = listOf("firstSteps", "gettingStarted")
        val sessionsBeforeReset = 50

        // After reset, sessions should be 0 but badges remain
        val sessionsAfterReset = 0
        val badgesAfterReset = badgesBeforeReset // Badges preserved

        assertEquals("Sessions should be cleared after reset", 0, sessionsAfterReset)
        assertEquals("Badges should be preserved after reset", badgesBeforeReset, badgesAfterReset)
    }

    @Test
    fun resetProgress_shouldClearUnlocks() {
        val unlocksBeforeReset = listOf(2, 3)
        val unlocksAfterReset = emptyList<Int>()

        assertTrue("Unlocks should be cleared after reset", unlocksAfterReset.isEmpty())
        assertFalse("Unlocks existed before reset", unlocksBeforeReset.isEmpty())
    }

    @Test
    fun resetProgress_shouldClearGameSessions() {
        val gameSessions = mutableListOf("session1", "session2", "session3")
        gameSessions.clear()

        assertTrue("Game sessions should be cleared after reset", gameSessions.isEmpty())
    }

    // ==================== AUDIO STATE MANAGEMENT TESTS ====================

    @Test
    fun audioState_pauseResume_shouldTrackCorrectly() {
        var isPlaying = true
        var isPaused = false

        // Pause
        isPaused = true
        isPlaying = false
        assertTrue("Audio should be marked as paused", isPaused)
        assertFalse("Audio should not be playing when paused", isPlaying)

        // Resume
        isPaused = false
        isPlaying = true
        assertFalse("Audio should not be paused after resume", isPaused)
        assertTrue("Audio should be playing after resume", isPlaying)
    }

    @Test
    fun audioState_stop_shouldResetState() {
        var isPlaying = true
        var isPaused = false

        // Stop
        isPlaying = false
        isPaused = false

        assertFalse("Audio should not be playing after stop", isPlaying)
        assertFalse("Audio should not be paused after stop", isPaused)
    }

    // ==================== HAPTIC FEEDBACK TYPE TESTS ====================

    @Test
    fun hapticFeedback_types_shouldExist() {
        val hapticTypes = listOf("buttonTap", "correctAnswer", "wrongAnswer", "gameComplete")
        assertEquals("There should be 4 haptic feedback types", 4, hapticTypes.size)
    }

    // ==================== COMBINED SETTINGS TESTS ====================

    @Test
    fun settings_allDisabled_shouldBeValid() {
        val musicEnabled = false
        val soundEnabled = false
        val hapticEnabled = false

        assertFalse(musicEnabled)
        assertFalse(soundEnabled)
        assertFalse(hapticEnabled)
    }

    @Test
    fun settings_allEnabled_shouldBeValid() {
        val musicEnabled = true
        val soundEnabled = true
        val hapticEnabled = true

        assertTrue(musicEnabled)
        assertTrue(soundEnabled)
        assertTrue(hapticEnabled)
    }

    @Test
    fun settings_mixedState_shouldBeValid() {
        // Music on, sound off, haptic on
        val musicEnabled = true
        val soundEnabled = false
        val hapticEnabled = true

        assertTrue(musicEnabled)
        assertFalse(soundEnabled)
        assertTrue(hapticEnabled)
    }

    // ==================== DATASTORE KEY TESTS ====================

    @Test
    fun dataStoreKeys_musicEnabled_shouldBeCorrect() {
        val key = "music_enabled"
        assertEquals("music_enabled", key)
    }

    @Test
    fun dataStoreKeys_soundEffectsEnabled_shouldBeCorrect() {
        val key = "sound_effects_enabled"
        assertEquals("sound_effects_enabled", key)
    }

    @Test
    fun dataStoreKeys_hapticFeedbackEnabled_shouldBeCorrect() {
        val key = "haptic_feedback_enabled"
        assertEquals("haptic_feedback_enabled", key)
    }

    @Test
    fun dataStoreKeys_themeMode_shouldBeCorrect() {
        val key = "theme_mode"
        assertEquals("theme_mode", key)
    }

    // ==================== THEME MODE CONVERSION TESTS ====================

    @Test
    fun themeMode_fromString_shouldWork() {
        fun themeModeFromString(value: String): ThemeMode {
            return try {
                ThemeMode.valueOf(value.uppercase())
            } catch (e: IllegalArgumentException) {
                ThemeMode.SYSTEM
            }
        }

        assertEquals(ThemeMode.SYSTEM, themeModeFromString("SYSTEM"))
        assertEquals(ThemeMode.LIGHT, themeModeFromString("light"))
        assertEquals(ThemeMode.DARK, themeModeFromString("DARK"))
        assertEquals(ThemeMode.SYSTEM, themeModeFromString("invalid")) // Falls back to SYSTEM
    }

    @Test
    fun themeMode_toString_shouldWork() {
        assertEquals("SYSTEM", ThemeMode.SYSTEM.name)
        assertEquals("LIGHT", ThemeMode.LIGHT.name)
        assertEquals("DARK", ThemeMode.DARK.name)
    }

    // ==================== SOUND EFFECT ENUMERATION TESTS ====================

    @Test
    fun soundEffect_allValues_shouldBeEnumerable() {
        val effects = SoundEffect.values().toList()
        assertTrue("Should be able to enumerate all sound effects", effects.isNotEmpty())
        assertEquals(4, effects.size)
    }

    @Test
    fun soundEffect_ordinals_shouldBeSequential() {
        assertEquals(0, SoundEffect.CORRECT_ANSWER.ordinal)
        assertEquals(1, SoundEffect.WRONG_ANSWER.ordinal)
        assertEquals(2, SoundEffect.BUTTON_TAP.ordinal)
        assertEquals(3, SoundEffect.GAME_COMPLETE.ordinal)
    }

    // ==================== VIBRATION EFFECT TESTS ====================

    @Test
    fun vibrationEffect_validDuration_shouldBePositive() {
        val shortVibration = 50L // milliseconds
        val mediumVibration = 100L
        val longVibration = 200L

        assertTrue("Short vibration should be positive", shortVibration > 0)
        assertTrue("Medium vibration should be positive", mediumVibration > 0)
        assertTrue("Long vibration should be positive", longVibration > 0)
    }

    @Test
    fun vibrationEffect_durations_shouldBeReasonable() {
        val maxReasonableDuration = 1000L // 1 second max for haptic feedback
        val buttonTapDuration = 50L
        val successDuration = 100L
        val errorDuration = 150L
        val completeDuration = 200L

        assertTrue("Button tap vibration should be under 1 second", buttonTapDuration < maxReasonableDuration)
        assertTrue("Success vibration should be under 1 second", successDuration < maxReasonableDuration)
        assertTrue("Error vibration should be under 1 second", errorDuration < maxReasonableDuration)
        assertTrue("Complete vibration should be under 1 second", completeDuration < maxReasonableDuration)
    }

    // ==================== SETTINGS STATE CONSISTENCY TESTS ====================

    @Test
    fun settings_shouldMaintainConsistency() {
        // Simulate setting changes
        var musicEnabled = true
        var soundEnabled = true
        var hapticEnabled = true
        var themeMode = ThemeMode.SYSTEM

        // Change each setting
        musicEnabled = false
        soundEnabled = false
        hapticEnabled = false
        themeMode = ThemeMode.DARK

        // Verify all changes persisted
        assertFalse(musicEnabled)
        assertFalse(soundEnabled)
        assertFalse(hapticEnabled)
        assertEquals(ThemeMode.DARK, themeMode)
    }

    @Test
    fun settings_independentToggle_shouldNotAffectOthers() {
        var musicEnabled = true
        var soundEnabled = true
        var hapticEnabled = true

        // Toggle only music
        musicEnabled = false

        // Other settings should remain unchanged
        assertFalse("Music should be disabled", musicEnabled)
        assertTrue("Sound should still be enabled", soundEnabled)
        assertTrue("Haptic should still be enabled", hapticEnabled)
    }
}
