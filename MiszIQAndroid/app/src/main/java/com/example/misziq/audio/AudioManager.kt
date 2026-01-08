package com.example.misziq.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.SoundPool
import com.example.misziq.R
import com.example.misziq.data.preferences.SettingsDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

enum class SoundEffect(val resourceName: String) {
    CORRECT_ANSWER("correct_chime"),
    WRONG_ANSWER("wrong_buzz"),
    BUTTON_TAP("button_tap"),
    GAME_COMPLETE("celebration")
}

class AudioManager(private val context: Context) {
    private var mediaPlayer: MediaPlayer? = null
    private var soundPool: SoundPool? = null
    private val soundIds = mutableMapOf<SoundEffect, Int>()
    private val settingsDataStore = SettingsDataStore(context)
    private var isMusicPlaying = false

    fun initialize() {
        // Initialize SoundPool for sound effects
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        soundPool = SoundPool.Builder()
            .setMaxStreams(4)
            .setAudioAttributes(audioAttributes)
            .build()

        // Load sound effects
        loadSoundEffect(SoundEffect.CORRECT_ANSWER, "correct_chime")
        loadSoundEffect(SoundEffect.WRONG_ANSWER, "wrong_buzz")
        loadSoundEffect(SoundEffect.BUTTON_TAP, "button_tap")
        loadSoundEffect(SoundEffect.GAME_COMPLETE, "celebration")
    }

    private fun loadSoundEffect(effect: SoundEffect, resourceName: String) {
        val resId = context.resources.getIdentifier(resourceName, "raw", context.packageName)
        if (resId != 0) {
            soundPool?.load(context, resId, 1)?.let { id ->
                soundIds[effect] = id
            }
        }
    }

    // MARK: - Background Music

    fun playBackgroundMusic() {
        val musicEnabled = runBlocking { settingsDataStore.musicEnabled.first() }
        if (!musicEnabled) return
        if (isMusicPlaying) return

        val resId = context.resources.getIdentifier("background_music", "raw", context.packageName)
        if (resId != 0) {
            try {
                mediaPlayer = MediaPlayer.create(context, resId)?.apply {
                    isLooping = true
                    setVolume(0.3f, 0.3f)
                    start()
                }
                isMusicPlaying = true
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun stopBackgroundMusic() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        isMusicPlaying = false
    }

    fun pauseBackgroundMusic() {
        mediaPlayer?.pause()
    }

    fun resumeBackgroundMusic() {
        val musicEnabled = runBlocking { settingsDataStore.musicEnabled.first() }
        if (!musicEnabled) return
        if (!isMusicPlaying) return
        mediaPlayer?.start()
    }

    // MARK: - Sound Effects

    fun playSoundEffect(effect: SoundEffect) {
        val soundEnabled = runBlocking { settingsDataStore.soundEffectsEnabled.first() }
        if (!soundEnabled) return

        soundIds[effect]?.let { soundId ->
            soundPool?.play(soundId, 1f, 1f, 1, 0, 1f)
        }
    }

    fun playCorrectSound() = playSoundEffect(SoundEffect.CORRECT_ANSWER)
    fun playWrongSound() = playSoundEffect(SoundEffect.WRONG_ANSWER)
    fun playButtonTap() = playSoundEffect(SoundEffect.BUTTON_TAP)
    fun playGameComplete() = playSoundEffect(SoundEffect.GAME_COMPLETE)

    // MARK: - Cleanup

    fun release() {
        mediaPlayer?.release()
        mediaPlayer = null
        soundPool?.release()
        soundPool = null
        isMusicPlaying = false
    }
}
