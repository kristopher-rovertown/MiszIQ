package com.example.misziq

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.misziq.audio.AudioManager
import com.example.misziq.data.model.GameType
import com.example.misziq.data.model.MockDataService
import com.example.misziq.data.preferences.SettingsDataStore
import com.example.misziq.data.preferences.ThemeMode
import com.example.misziq.data.repository.AppDatabase
import com.example.misziq.data.repository.MiszIQRepository
import com.example.misziq.haptics.HapticManager
import com.example.misziq.ui.screens.*
import com.example.misziq.ui.games.*
import com.example.misziq.ui.theme.MiszIQTheme

class MainActivity : ComponentActivity() {
    private lateinit var audioManager: AudioManager
    private lateinit var settingsDataStore: SettingsDataStore
    private lateinit var hapticManager: HapticManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val database = AppDatabase.getDatabase(applicationContext)
        val repository = MiszIQRepository(database)
        val mockService = MockDataService()

        // Initialize managers
        settingsDataStore = SettingsDataStore(applicationContext)
        audioManager = AudioManager(applicationContext).apply { initialize() }
        hapticManager = HapticManager(applicationContext)

        setContent {
            val themeMode by settingsDataStore.themeMode.collectAsState(initial = ThemeMode.SYSTEM)

            MiszIQTheme(themeMode = themeMode) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MiszIQApp(
                        repository = repository,
                        mockService = mockService,
                        settingsDataStore = settingsDataStore,
                        audioManager = audioManager,
                        hapticManager = hapticManager
                    )
                }
            }
        }
    }

    override fun onPause() {
        super.onPause()
        audioManager.pauseBackgroundMusic()
    }

    override fun onResume() {
        super.onResume()
        audioManager.resumeBackgroundMusic()
    }

    override fun onDestroy() {
        super.onDestroy()
        audioManager.release()
    }
}

@Composable
fun MiszIQApp(
    repository: MiszIQRepository,
    mockService: MockDataService,
    settingsDataStore: SettingsDataStore,
    audioManager: AudioManager,
    hapticManager: HapticManager
) {
    val navController = rememberNavController()
    var currentProfileId by remember { mutableStateOf<String?>(null) }
    var currentProfileName by remember { mutableStateOf("") }

    NavHost(navController = navController, startDestination = "profile_selection") {
        composable("profile_selection") {
            ProfileSelectionScreen(
                repository = repository,
                onProfileSelected = { profileId ->
                    currentProfileId = profileId
                    navController.navigate("main/$profileId")
                }
            )
        }

        composable(
            "main/{profileId}",
            arguments = listOf(navArgument("profileId") { type = NavType.StringType })
        ) { backStackEntry ->
            val profileId = backStackEntry.arguments?.getString("profileId") ?: return@composable

            // Get profile name for settings
            LaunchedEffect(profileId) {
                repository.getProfileById(profileId)?.let {
                    currentProfileName = it.name
                }
            }

            MainScreen(
                profileId = profileId,
                repository = repository,
                mockService = mockService,
                onNavigateToGame = { gameType ->
                    navController.navigate("game/$profileId/${gameType.name}")
                },
                onNavigateToSettings = {
                    navController.navigate("settings/$profileId")
                },
                onSwitchProfile = {
                    navController.navigate("profile_selection") {
                        popUpTo("profile_selection") { inclusive = true }
                    }
                }
            )
        }

        composable(
            "game/{profileId}/{gameType}",
            arguments = listOf(
                navArgument("profileId") { type = NavType.StringType },
                navArgument("gameType") { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val profileId = backStackEntry.arguments?.getString("profileId") ?: return@composable
            val gameTypeName = backStackEntry.arguments?.getString("gameType") ?: return@composable
            val gameType = GameType.valueOf(gameTypeName)

            GameScreen(
                profileId = profileId,
                gameType = gameType,
                repository = repository,
                mockService = mockService,
                audioManager = audioManager,
                hapticManager = hapticManager,
                onBack = { navController.popBackStack() }
            )
        }

        composable(
            "settings/{profileId}",
            arguments = listOf(navArgument("profileId") { type = NavType.StringType })
        ) { backStackEntry ->
            val profileId = backStackEntry.arguments?.getString("profileId") ?: return@composable

            SettingsScreen(
                profileId = profileId,
                profileName = currentProfileName,
                repository = repository,
                settingsDataStore = settingsDataStore,
                audioManager = audioManager,
                hapticManager = hapticManager,
                onBack = { navController.popBackStack() }
            )
        }
    }
}
