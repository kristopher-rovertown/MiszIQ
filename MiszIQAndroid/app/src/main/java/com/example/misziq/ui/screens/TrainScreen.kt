package com.example.misziq.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.misziq.data.model.*
import com.example.misziq.data.repository.MiszIQRepository

@Composable
fun TrainScreen(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    onGameSelected: (GameType) -> Unit
) {
    var profile by remember { mutableStateOf<UserProfile?>(null) }
    val sessions by repository.getSessionsForProfile(profileId).collectAsState(initial = emptyList())
    
    LaunchedEffect(profileId) {
        profile = repository.getProfileById(profileId)
    }
    
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Welcome header
        item {
            profile?.let { p ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "Welcome back,",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                text = p.name,
                                style = MaterialTheme.typography.headlineSmall,
                                fontWeight = FontWeight.Bold
                            )
                        }
                        Text(text = p.avatarEmoji, fontSize = 40.sp)
                    }
                }
            }
        }
        
        // Categories
        items(GameCategory.values().toList()) { category ->
            CategorySection(
                category = category,
                sessions = sessions,
                mockService = mockService,
                onGameSelected = onGameSelected
            )
        }
    }
}

@Composable
fun CategorySection(
    category: GameCategory,
    sessions: List<GameSession>,
    mockService: MockDataService,
    onGameSelected: (GameType) -> Unit
) {
    val categoryColor = Color(category.color)
    
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        // Category header
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(text = category.icon, fontSize = 20.sp)
            Text(
                text = category.displayName,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )
        }
        
        // Games in category
        category.games.forEach { gameType ->
            val stats = GameStatistics.calculate(sessions, gameType, mockService)
            GameCard(
                gameType = gameType,
                stats = stats,
                onClick = { onGameSelected(gameType) }
            )
        }
    }
}

@Composable
fun GameCard(
    gameType: GameType,
    stats: GameStatistics,
    onClick: () -> Unit
) {
    val gameColor = Color(gameType.color)
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Icon
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(gameColor.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Text(text = gameType.icon, fontSize = 22.sp)
            }
            
            Spacer(modifier = Modifier.width(12.dp))
            
            // Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = gameType.displayName,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = gameType.description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1
                )
            }
            
            // Stats preview
            if (stats.totalGamesPlayed > 0) {
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "${stats.percentile}%",
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.SemiBold,
                        color = gameColor
                    )
                    Text(
                        text = "percentile",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            Spacer(modifier = Modifier.width(8.dp))
            
            Icon(
                imageVector = Icons.Default.ChevronRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
            )
        }
    }
}
