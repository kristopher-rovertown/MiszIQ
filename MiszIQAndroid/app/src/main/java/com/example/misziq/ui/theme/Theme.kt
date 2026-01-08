package com.example.misziq.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat
import com.example.misziq.data.preferences.ThemeMode

// Theme primary colors
val RoyalBlue = Color(0xFF4169E1)
val Turquoise = Color(0xFF40E0D0)

// Light variants for dark theme
val RoyalBlueLight = Color(0xFF6B8DE8)
val TurquoiseLight = Color(0xFF6DE8DB)

// Legacy colors (kept for compatibility)
val Purple80 = Color(0xFFD0BCFF)
val PurpleGrey80 = Color(0xFFCCC2DC)
val Pink80 = Color(0xFFEFB8C8)
val Purple40 = Color(0xFF6650a4)
val PurpleGrey40 = Color(0xFF625b71)
val Pink40 = Color(0xFF7D5260)

// Unified game accent color - all categories use RoyalBlue
val GameAccentColor = RoyalBlue
val GameSecondaryColor = Turquoise

// Language games use Turquoise for variety (matching iOS)
val LanguageAccentColor = Turquoise

private val DarkColorScheme = darkColorScheme(
    primary = RoyalBlueLight,
    secondary = TurquoiseLight,
    tertiary = Turquoise
)

private val LightColorScheme = lightColorScheme(
    primary = RoyalBlue,
    secondary = Turquoise,
    tertiary = TurquoiseLight,
    background = Color(0xFFF5F5F5),
    surface = Color.White,
    surfaceVariant = Color(0xFFF0F0F0)
)

@Composable
fun MiszIQTheme(
    themeMode: ThemeMode = ThemeMode.SYSTEM,
    content: @Composable () -> Unit
) {
    val darkTheme = when (themeMode) {
        ThemeMode.SYSTEM -> isSystemInDarkTheme()
        ThemeMode.LIGHT -> false
        ThemeMode.DARK -> true
    }
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    val view = LocalView.current
    
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography(),
        content = content
    )
}
