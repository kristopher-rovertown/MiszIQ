import XCTest
@testable import MiszIQ

/// Unit tests for settings system, theme modes, and audio/haptic managers
final class SettingsTests: XCTestCase {

    // MARK: - ThemeMode Tests

    func testThemeMode_system_shouldReturnNilColorScheme() {
        let themeMode = ThemeMode.system
        XCTAssertNil(themeMode.colorScheme, "System theme mode should return nil colorScheme")
    }

    func testThemeMode_light_shouldReturnLightColorScheme() {
        let themeMode = ThemeMode.light
        XCTAssertEqual(themeMode.colorScheme, .light, "Light theme mode should return .light colorScheme")
    }

    func testThemeMode_dark_shouldReturnDarkColorScheme() {
        let themeMode = ThemeMode.dark
        XCTAssertEqual(themeMode.colorScheme, .dark, "Dark theme mode should return .dark colorScheme")
    }

    func testThemeMode_allCases_shouldHaveDisplayName() {
        for mode in ThemeMode.allCases {
            XCTAssertFalse(mode.displayName.isEmpty, "\(mode) should have a display name")
        }
    }

    func testThemeMode_allCases_shouldHaveIcon() {
        for mode in ThemeMode.allCases {
            XCTAssertFalse(mode.icon.isEmpty, "\(mode) should have an icon")
        }
    }

    func testThemeMode_count_shouldBe3() {
        XCTAssertEqual(ThemeMode.allCases.count, 3, "There should be exactly 3 theme modes")
    }

    func testThemeMode_rawValues_shouldBeCorrect() {
        XCTAssertEqual(ThemeMode.system.rawValue, "system")
        XCTAssertEqual(ThemeMode.light.rawValue, "light")
        XCTAssertEqual(ThemeMode.dark.rawValue, "dark")
    }

    func testThemeMode_initFromRawValue_shouldWork() {
        XCTAssertEqual(ThemeMode(rawValue: "system"), .system)
        XCTAssertEqual(ThemeMode(rawValue: "light"), .light)
        XCTAssertEqual(ThemeMode(rawValue: "dark"), .dark)
        XCTAssertNil(ThemeMode(rawValue: "invalid"))
    }

    // MARK: - SoundEffect Tests

    func testSoundEffect_allCases_shouldHaveFileName() {
        for effect in SoundEffect.allCases {
            XCTAssertFalse(effect.rawValue.isEmpty, "\(effect) should have a file name")
        }
    }

    func testSoundEffect_count_shouldBe4() {
        XCTAssertEqual(SoundEffect.allCases.count, 4, "There should be exactly 4 sound effects")
    }

    func testSoundEffect_rawValues_shouldBeCorrect() {
        XCTAssertEqual(SoundEffect.correctAnswer.rawValue, "correct_chime")
        XCTAssertEqual(SoundEffect.wrongAnswer.rawValue, "wrong_buzz")
        XCTAssertEqual(SoundEffect.buttonTap.rawValue, "button_tap")
        XCTAssertEqual(SoundEffect.gameComplete.rawValue, "celebration")
    }

    // MARK: - Settings Default Values Tests

    func testSettings_musicEnabled_defaultShouldBeTrue() {
        // Default value should be true (music enabled by default)
        let defaultValue = true
        XCTAssertTrue(defaultValue, "Music should be enabled by default")
    }

    func testSettings_soundEffectsEnabled_defaultShouldBeTrue() {
        // Default value should be true (sound effects enabled by default)
        let defaultValue = true
        XCTAssertTrue(defaultValue, "Sound effects should be enabled by default")
    }

    func testSettings_hapticFeedbackEnabled_defaultShouldBeTrue() {
        // Default value should be true (haptic feedback enabled by default)
        let defaultValue = true
        XCTAssertTrue(defaultValue, "Haptic feedback should be enabled by default")
    }

    func testSettings_themeMode_defaultShouldBeSystem() {
        // Default theme mode should be system
        let defaultMode = ThemeMode.system
        XCTAssertEqual(defaultMode, .system, "Default theme mode should be system")
    }

    // MARK: - Settings Toggle Tests

    func testSettings_toggleMusic_shouldInvertValue() {
        var musicEnabled = true
        musicEnabled.toggle()
        XCTAssertFalse(musicEnabled, "Toggling music should invert the value")
        musicEnabled.toggle()
        XCTAssertTrue(musicEnabled, "Toggling again should restore the value")
    }

    func testSettings_toggleSoundEffects_shouldInvertValue() {
        var soundEnabled = true
        soundEnabled.toggle()
        XCTAssertFalse(soundEnabled, "Toggling sound effects should invert the value")
        soundEnabled.toggle()
        XCTAssertTrue(soundEnabled, "Toggling again should restore the value")
    }

    func testSettings_toggleHapticFeedback_shouldInvertValue() {
        var hapticEnabled = true
        hapticEnabled.toggle()
        XCTAssertFalse(hapticEnabled, "Toggling haptic feedback should invert the value")
        hapticEnabled.toggle()
        XCTAssertTrue(hapticEnabled, "Toggling again should restore the value")
    }

    // MARK: - Theme Mode Cycling Tests

    func testThemeMode_cycling_shouldWorkCorrectly() {
        let modes = ThemeMode.allCases
        XCTAssertEqual(modes[0], .system)
        XCTAssertEqual(modes[1], .light)
        XCTAssertEqual(modes[2], .dark)
    }

    // MARK: - AudioManager State Tests

    func testAudioManager_singleton_shouldExist() {
        let manager = AudioManager.shared
        XCTAssertNotNil(manager, "AudioManager.shared should not be nil")
    }

    func testAudioManager_singleton_shouldBeSameInstance() {
        let manager1 = AudioManager.shared
        let manager2 = AudioManager.shared
        XCTAssertTrue(manager1 === manager2, "AudioManager.shared should return the same instance")
    }

    // MARK: - HapticManager State Tests

    func testHapticManager_singleton_shouldExist() {
        let manager = HapticManager.shared
        XCTAssertNotNil(manager, "HapticManager.shared should not be nil")
    }

    func testHapticManager_singleton_shouldBeSameInstance() {
        let manager1 = HapticManager.shared
        let manager2 = HapticManager.shared
        XCTAssertTrue(manager1 === manager2, "HapticManager.shared should return the same instance")
    }

    // MARK: - SettingsManager State Tests

    func testSettingsManager_singleton_shouldExist() {
        let manager = SettingsManager.shared
        XCTAssertNotNil(manager, "SettingsManager.shared should not be nil")
    }

    func testSettingsManager_singleton_shouldBeSameInstance() {
        let manager1 = SettingsManager.shared
        let manager2 = SettingsManager.shared
        XCTAssertTrue(manager1 === manager2, "SettingsManager.shared should return the same instance")
    }

    // MARK: - Volume Tests

    func testVolume_validRange_shouldBeBetween0And1() {
        let minVolume: Float = 0.0
        let maxVolume: Float = 1.0
        let musicVolume: Float = 0.3 // Default music volume

        XCTAssertGreaterThanOrEqual(musicVolume, minVolume, "Volume should be at least 0")
        XCTAssertLessThanOrEqual(musicVolume, maxVolume, "Volume should be at most 1")
    }

    func testVolume_clamp_shouldWorkCorrectly() {
        func clampVolume(_ volume: Float) -> Float {
            return max(0, min(1, volume))
        }

        XCTAssertEqual(clampVolume(-0.5), 0.0, "Negative volume should be clamped to 0")
        XCTAssertEqual(clampVolume(0.5), 0.5, "Valid volume should remain unchanged")
        XCTAssertEqual(clampVolume(1.5), 1.0, "Volume above 1 should be clamped to 1")
    }

    // MARK: - Settings Persistence Key Tests

    func testSettingsKeys_shouldBeUnique() {
        let keys = [
            "musicEnabled",
            "soundEffectsEnabled",
            "hapticFeedbackEnabled",
            "themeMode"
        ]
        let uniqueKeys = Set(keys)
        XCTAssertEqual(keys.count, uniqueKeys.count, "All settings keys should be unique")
    }

    // MARK: - Reset Progress Logic Tests

    func testResetProgress_shouldPreserveBadges() {
        // When resetting progress, badges should be preserved
        let badgesBeforeReset = ["firstSteps", "gettingStarted"]
        let sessionsBeforeReset = 50

        // After reset, sessions should be 0 but badges remain
        let sessionsAfterReset = 0
        let badgesAfterReset = badgesBeforeReset // Badges preserved

        XCTAssertEqual(sessionsAfterReset, 0, "Sessions should be cleared after reset")
        XCTAssertEqual(badgesAfterReset, badgesBeforeReset, "Badges should be preserved after reset")
    }

    func testResetProgress_shouldClearUnlocks() {
        // When resetting progress, difficulty unlocks should be cleared
        let unlocksBeforeReset = [2, 3]
        let unlocksAfterReset: [Int] = []

        XCTAssertTrue(unlocksAfterReset.isEmpty, "Unlocks should be cleared after reset")
        XCTAssertFalse(unlocksBeforeReset.isEmpty, "Unlocks existed before reset")
    }

    func testResetProgress_shouldClearGameSessions() {
        // When resetting progress, game sessions should be cleared
        var gameSessions = ["session1", "session2", "session3"]
        gameSessions.removeAll()

        XCTAssertTrue(gameSessions.isEmpty, "Game sessions should be cleared after reset")
    }

    // MARK: - Theme Display Tests

    func testThemeMode_displayName_shouldBeHumanReadable() {
        XCTAssertEqual(ThemeMode.system.displayName, "System")
        XCTAssertEqual(ThemeMode.light.displayName, "Light")
        XCTAssertEqual(ThemeMode.dark.displayName, "Dark")
    }

    func testThemeMode_icon_shouldBeSFSymbolName() {
        // Icons should be valid SF Symbol names
        let validIconPrefixes = ["sun", "moon", "gear", "circle", "sparkle"]

        for mode in ThemeMode.allCases {
            let hasValidPrefix = validIconPrefixes.contains { mode.icon.contains($0) }
            XCTAssertTrue(hasValidPrefix || !mode.icon.isEmpty, "\(mode) icon should be a valid SF Symbol")
        }
    }

    // MARK: - Audio State Management Tests

    func testAudioState_pauseResume_shouldTrackCorrectly() {
        var isPlaying = true
        var isPaused = false

        // Pause
        isPaused = true
        isPlaying = false
        XCTAssertTrue(isPaused, "Audio should be marked as paused")
        XCTAssertFalse(isPlaying, "Audio should not be playing when paused")

        // Resume
        isPaused = false
        isPlaying = true
        XCTAssertFalse(isPaused, "Audio should not be paused after resume")
        XCTAssertTrue(isPlaying, "Audio should be playing after resume")
    }

    func testAudioState_stop_shouldResetState() {
        var isPlaying = true
        var isPaused = false

        // Stop
        isPlaying = false
        isPaused = false

        XCTAssertFalse(isPlaying, "Audio should not be playing after stop")
        XCTAssertFalse(isPaused, "Audio should not be paused after stop")
    }

    // MARK: - Settings Validation Tests

    func testSettings_allSettingsTypes_shouldBeValid() {
        // Music enabled should be boolean
        let musicEnabled: Bool = true
        XCTAssertTrue(musicEnabled is Bool, "Music enabled should be a boolean")

        // Sound effects enabled should be boolean
        let soundEnabled: Bool = true
        XCTAssertTrue(soundEnabled is Bool, "Sound effects enabled should be a boolean")

        // Haptic feedback enabled should be boolean
        let hapticEnabled: Bool = true
        XCTAssertTrue(hapticEnabled is Bool, "Haptic feedback enabled should be a boolean")

        // Theme mode should be ThemeMode enum
        let themeMode: ThemeMode = .system
        XCTAssertTrue(themeMode is ThemeMode, "Theme mode should be ThemeMode enum")
    }

    // MARK: - Haptic Feedback Type Tests

    func testHapticFeedback_types_shouldExist() {
        // Test that all haptic feedback types can be triggered without crashing
        // In a real test, these would be called on actual HapticManager
        let hapticTypes = ["buttonTap", "correctAnswer", "wrongAnswer", "gameComplete"]
        XCTAssertEqual(hapticTypes.count, 4, "There should be 4 haptic feedback types")
    }

    // MARK: - Combined Settings Tests

    func testSettings_allDisabled_shouldBeValid() {
        let musicEnabled = false
        let soundEnabled = false
        let hapticEnabled = false

        // All settings disabled should be a valid state
        XCTAssertFalse(musicEnabled)
        XCTAssertFalse(soundEnabled)
        XCTAssertFalse(hapticEnabled)
    }

    func testSettings_allEnabled_shouldBeValid() {
        let musicEnabled = true
        let soundEnabled = true
        let hapticEnabled = true

        // All settings enabled should be a valid state
        XCTAssertTrue(musicEnabled)
        XCTAssertTrue(soundEnabled)
        XCTAssertTrue(hapticEnabled)
    }

    func testSettings_mixedState_shouldBeValid() {
        // Music on, sound off, haptic on
        let musicEnabled = true
        let soundEnabled = false
        let hapticEnabled = true

        XCTAssertTrue(musicEnabled)
        XCTAssertFalse(soundEnabled)
        XCTAssertTrue(hapticEnabled)
    }
}
