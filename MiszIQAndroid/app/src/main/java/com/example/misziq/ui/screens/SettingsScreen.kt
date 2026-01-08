package com.example.misziq.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.misziq.audio.AudioManager
import com.example.misziq.data.preferences.SettingsDataStore
import com.example.misziq.data.preferences.ThemeMode
import com.example.misziq.data.repository.MiszIQRepository
import com.example.misziq.haptics.HapticManager
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    profileId: String,
    profileName: String,
    repository: MiszIQRepository,
    settingsDataStore: SettingsDataStore,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    val scope = rememberCoroutineScope()

    val musicEnabled by settingsDataStore.musicEnabled.collectAsState(initial = true)
    val soundEnabled by settingsDataStore.soundEffectsEnabled.collectAsState(initial = true)
    val hapticEnabled by settingsDataStore.hapticFeedbackEnabled.collectAsState(initial = true)
    val themeMode by settingsDataStore.themeMode.collectAsState(initial = ThemeMode.SYSTEM)

    var showResetDialog by remember { mutableStateOf(false) }
    var showThemeDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
        ) {
            // Audio Section
            Text(
                text = "Audio",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
            )

            ListItem(
                headlineContent = { Text("Background Music") },
                supportingContent = { Text("Plays during games") },
                leadingContent = {
                    Icon(Icons.Default.MusicNote, contentDescription = null)
                },
                trailingContent = {
                    Switch(
                        checked = musicEnabled,
                        onCheckedChange = { enabled ->
                            scope.launch {
                                settingsDataStore.setMusicEnabled(enabled)
                                if (enabled) {
                                    audioManager.playBackgroundMusic()
                                } else {
                                    audioManager.stopBackgroundMusic()
                                }
                            }
                        }
                    )
                }
            )

            ListItem(
                headlineContent = { Text("Sound Effects") },
                supportingContent = { Text("Correct/wrong answers, game completion") },
                leadingContent = {
                    Icon(Icons.Default.VolumeUp, contentDescription = null)
                },
                trailingContent = {
                    Switch(
                        checked = soundEnabled,
                        onCheckedChange = { enabled ->
                            scope.launch {
                                settingsDataStore.setSoundEffectsEnabled(enabled)
                            }
                        }
                    )
                }
            )

            HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

            // Feedback Section
            Text(
                text = "Feedback",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
            )

            ListItem(
                headlineContent = { Text("Haptic Feedback") },
                supportingContent = { Text("Vibration on interactions") },
                leadingContent = {
                    Icon(Icons.Default.Vibration, contentDescription = null)
                },
                trailingContent = {
                    Switch(
                        checked = hapticEnabled,
                        onCheckedChange = { enabled ->
                            scope.launch {
                                settingsDataStore.setHapticFeedbackEnabled(enabled)
                            }
                            if (enabled) {
                                hapticManager.buttonTap()
                            }
                        }
                    )
                }
            )

            HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

            // Appearance Section
            Text(
                text = "Appearance",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
            )

            ListItem(
                headlineContent = { Text("Theme") },
                supportingContent = { Text(themeMode.displayName) },
                leadingContent = {
                    Icon(
                        when (themeMode) {
                            ThemeMode.SYSTEM -> Icons.Default.BrightnessAuto
                            ThemeMode.LIGHT -> Icons.Default.LightMode
                            ThemeMode.DARK -> Icons.Default.DarkMode
                        },
                        contentDescription = null
                    )
                },
                modifier = Modifier.clickable { showThemeDialog = true }
            )

            HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

            // Data Section
            Text(
                text = "Data",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
            )

            ListItem(
                headlineContent = {
                    Text("Reset Progress", color = MaterialTheme.colorScheme.error)
                },
                supportingContent = {
                    Text("Delete all game history for $profileName")
                },
                leadingContent = {
                    Icon(
                        Icons.Default.Refresh,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.error
                    )
                },
                modifier = Modifier.clickable { showResetDialog = true }
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Footer
            Text(
                text = "Badges will be preserved when resetting progress.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
        }
    }

    // Theme Selection Dialog
    if (showThemeDialog) {
        AlertDialog(
            onDismissRequest = { showThemeDialog = false },
            title = { Text("Choose Theme") },
            text = {
                Column {
                    ThemeMode.values().forEach { mode ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    scope.launch {
                                        settingsDataStore.setThemeMode(mode)
                                    }
                                    showThemeDialog = false
                                }
                                .padding(vertical = 12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = themeMode == mode,
                                onClick = {
                                    scope.launch {
                                        settingsDataStore.setThemeMode(mode)
                                    }
                                    showThemeDialog = false
                                }
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Icon(
                                when (mode) {
                                    ThemeMode.SYSTEM -> Icons.Default.BrightnessAuto
                                    ThemeMode.LIGHT -> Icons.Default.LightMode
                                    ThemeMode.DARK -> Icons.Default.DarkMode
                                },
                                contentDescription = null,
                                modifier = Modifier.size(24.dp)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Text(mode.displayName)
                        }
                    }
                }
            },
            confirmButton = {
                TextButton(onClick = { showThemeDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Reset Confirmation Dialog
    if (showResetDialog) {
        AlertDialog(
            onDismissRequest = { showResetDialog = false },
            title = { Text("Reset Progress?") },
            text = {
                Text("This will permanently delete all game history for $profileName. Earned badges will be preserved. This cannot be undone.")
            },
            confirmButton = {
                Button(
                    onClick = {
                        scope.launch {
                            repository.deleteSessionsForProfile(profileId)
                            repository.deleteUnlocksForProfile(profileId)
                        }
                        hapticManager.gameComplete()
                        showResetDialog = false
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("Reset")
                }
            },
            dismissButton = {
                TextButton(onClick = { showResetDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }
}
