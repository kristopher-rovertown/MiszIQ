package com.example.misziq.data.preferences

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

enum class ThemeMode {
    SYSTEM,
    LIGHT,
    DARK;

    val displayName: String
        get() = when (this) {
            SYSTEM -> "System"
            LIGHT -> "Light"
            DARK -> "Dark"
        }
}

class SettingsDataStore(private val context: Context) {

    companion object {
        private val MUSIC_ENABLED = booleanPreferencesKey("music_enabled")
        private val SOUND_EFFECTS_ENABLED = booleanPreferencesKey("sound_effects_enabled")
        private val HAPTIC_FEEDBACK_ENABLED = booleanPreferencesKey("haptic_feedback_enabled")
        private val THEME_MODE = stringPreferencesKey("theme_mode")
    }

    val musicEnabled: Flow<Boolean> = context.dataStore.data.map { preferences ->
        preferences[MUSIC_ENABLED] ?: true
    }

    val soundEffectsEnabled: Flow<Boolean> = context.dataStore.data.map { preferences ->
        preferences[SOUND_EFFECTS_ENABLED] ?: true
    }

    val hapticFeedbackEnabled: Flow<Boolean> = context.dataStore.data.map { preferences ->
        preferences[HAPTIC_FEEDBACK_ENABLED] ?: true
    }

    val themeMode: Flow<ThemeMode> = context.dataStore.data.map { preferences ->
        val themeName = preferences[THEME_MODE] ?: ThemeMode.SYSTEM.name
        try {
            ThemeMode.valueOf(themeName)
        } catch (e: IllegalArgumentException) {
            ThemeMode.SYSTEM
        }
    }

    suspend fun setMusicEnabled(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[MUSIC_ENABLED] = enabled
        }
    }

    suspend fun setSoundEffectsEnabled(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[SOUND_EFFECTS_ENABLED] = enabled
        }
    }

    suspend fun setHapticFeedbackEnabled(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[HAPTIC_FEEDBACK_ENABLED] = enabled
        }
    }

    suspend fun setThemeMode(mode: ThemeMode) {
        context.dataStore.edit { preferences ->
            preferences[THEME_MODE] = mode.name
        }
    }
}
