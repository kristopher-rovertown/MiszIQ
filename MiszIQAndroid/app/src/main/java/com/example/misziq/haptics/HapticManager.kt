package com.example.misziq.haptics

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import com.example.misziq.data.preferences.SettingsDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

class HapticManager(context: Context) {
    private val vibrator: Vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
        vibratorManager.defaultVibrator
    } else {
        @Suppress("DEPRECATION")
        context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    }

    private val settingsDataStore = SettingsDataStore(context)

    private fun isEnabled(): Boolean {
        return runBlocking { settingsDataStore.hapticFeedbackEnabled.first() }
    }

    private fun vibrate(durationMs: Long) {
        if (!isEnabled()) return
        if (!vibrator.hasVibrator()) return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(durationMs)
        }
    }

    private fun vibrateWithEffect(effectId: Int, fallbackDurationMs: Long) {
        if (!isEnabled()) return
        if (!vibrator.hasVibrator()) return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                vibrator.vibrate(VibrationEffect.createPredefined(effectId))
            } catch (e: Exception) {
                vibrate(fallbackDurationMs)
            }
        } else {
            vibrate(fallbackDurationMs)
        }
    }

    // MARK: - Button Tap (Light)
    fun buttonTap() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrateWithEffect(VibrationEffect.EFFECT_TICK, 10)
        } else {
            vibrate(10)
        }
    }

    // MARK: - Correct Answer (Success)
    fun correctAnswer() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrateWithEffect(VibrationEffect.EFFECT_CLICK, 50)
        } else {
            vibrate(50)
        }
    }

    // MARK: - Wrong Answer (Error)
    fun wrongAnswer() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrateWithEffect(VibrationEffect.EFFECT_HEAVY_CLICK, 100)
        } else {
            vibrate(100)
        }
    }

    // MARK: - Game Complete
    fun gameComplete() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrateWithEffect(VibrationEffect.EFFECT_DOUBLE_CLICK, 200)
        } else {
            vibrate(200)
        }
    }

    // MARK: - Level Up / Badge Unlock
    fun levelUp() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrateWithEffect(VibrationEffect.EFFECT_CLICK, 75)
        } else {
            vibrate(75)
        }
    }

    fun badgeUnlocked() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrateWithEffect(VibrationEffect.EFFECT_HEAVY_CLICK, 150)
        } else {
            vibrate(150)
        }
    }
}
