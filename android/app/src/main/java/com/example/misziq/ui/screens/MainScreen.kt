package com.example.misziq.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.example.misziq.data.model.GameType
import com.example.misziq.data.model.MockDataService
import com.example.misziq.data.repository.MiszIQRepository

@Composable
fun MainScreen(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    onNavigateToGame: (GameType) -> Unit,
    onNavigateToSettings: () -> Unit,
    onSwitchProfile: () -> Unit
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf("Train", "Progress", "Profile")
    val icons = listOf(Icons.Default.Psychology, Icons.Default.Insights, Icons.Default.AccountCircle)
    
    Scaffold(
        bottomBar = {
            NavigationBar {
                tabs.forEachIndexed { index, title ->
                    NavigationBarItem(
                        icon = { Icon(icons[index], contentDescription = title) },
                        label = { Text(title) },
                        selected = selectedTab == index,
                        onClick = { selectedTab = index }
                    )
                }
            }
        }
    ) { padding ->
        Box(modifier = Modifier.padding(padding)) {
            when (selectedTab) {
                0 -> TrainScreen(
                    profileId = profileId,
                    repository = repository,
                    mockService = mockService,
                    onGameSelected = onNavigateToGame
                )
                1 -> ProgressScreen(
                    profileId = profileId,
                    repository = repository,
                    mockService = mockService
                )
                2 -> ProfileScreen(
                    profileId = profileId,
                    repository = repository,
                    onNavigateToSettings = onNavigateToSettings,
                    onSwitchProfile = onSwitchProfile
                )
            }
        }
    }
}
