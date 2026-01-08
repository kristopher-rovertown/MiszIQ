package com.example.misziq.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
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
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun ProgressScreen(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService
) {
    var selectedCategory by remember { mutableStateOf(GameCategory.MEMORY) }
    var selectedGameType by remember { mutableStateOf(GameType.MEMORY_GRID) }
    val sessions by repository.getSessionsForProfile(profileId).collectAsState(initial = emptyList())
    
    LaunchedEffect(selectedCategory) {
        selectedGameType = selectedCategory.games.firstOrNull() ?: GameType.MEMORY_GRID
    }
    
    val stats = remember(sessions, selectedGameType) {
        GameStatistics.calculate(sessions, selectedGameType, mockService)
    }
    
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Text(
                text = "Progress",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
        }
        
        // Category picker
        item {
            CategoryPicker(
                selectedCategory = selectedCategory,
                onCategorySelected = { selectedCategory = it }
            )
        }
        
        // Game type picker
        item {
            GameTypePicker(
                games = selectedCategory.games,
                selectedGame = selectedGameType,
                onGameSelected = { selectedGameType = it }
            )
        }
        
        if (stats.totalGamesPlayed == 0) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(text = "📊", fontSize = 48.sp)
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "No data yet",
                            style = MaterialTheme.typography.titleMedium
                        )
                        Text(
                            text = "Complete some ${selectedGameType.displayName} sessions",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        } else {
            // Percentile card
            item {
                PercentileCard(stats = stats, mockService = mockService)
            }
            
            // Stats grid
            item {
                StatsGrid(stats = stats)
            }
            
            // Recent sessions
            item {
                RecentSessionsCard(
                    sessions = sessions.filter { it.gameType == selectedGameType.name }
                )
            }
        }
    }
}

@Composable
fun CategoryPicker(
    selectedCategory: GameCategory,
    onCategorySelected: (GameCategory) -> Unit
) {
    Card(shape = RoundedCornerShape(12.dp)) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(4.dp),
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            GameCategory.values().forEach { category ->
                val isSelected = category == selectedCategory
                val categoryColor = Color(category.color)
                
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(if (isSelected) categoryColor.copy(alpha = 0.15f) else Color.Transparent)
                        .clickable { onCategorySelected(category) }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(text = category.icon, fontSize = 16.sp)
                        Text(
                            text = when(category) {
                                GameCategory.MEMORY -> "Memory"
                                GameCategory.MENTAL_MATH -> "Math"
                                GameCategory.PROBLEM_SOLVING -> "Logic"
                                GameCategory.LANGUAGE -> "Language"
                            },
                            style = MaterialTheme.typography.labelSmall,
                            fontWeight = if (isSelected) FontWeight.Medium else FontWeight.Normal,
                            color = if (isSelected) categoryColor else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun GameTypePicker(
    games: List<GameType>,
    selectedGame: GameType,
    onGameSelected: (GameType) -> Unit
) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(games) { game ->
            val isSelected = game == selectedGame
            val gameColor = Color(game.color)
            
            FilterChip(
                selected = isSelected,
                onClick = { onGameSelected(game) },
                label = { Text(game.displayName) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = gameColor.copy(alpha = 0.15f),
                    selectedLabelColor = gameColor
                )
            )
        }
    }
}

@Composable
fun PercentileCard(stats: GameStatistics, mockService: MockDataService) {
    val (bracketName, bracketColorLong, bracketDesc) = mockService.getPerformanceBracket(stats.percentile)
    val bracketColor = Color(bracketColorLong)
    val trendColor = Color(stats.recentTrend.color)
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Your Ranking",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(text = stats.recentTrend.icon, color = trendColor)
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = stats.recentTrend.name.lowercase().replaceFirstChar { it.uppercase() },
                        style = MaterialTheme.typography.labelMedium,
                        color = trendColor
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(12.dp))

            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        text = "${stats.percentile}",
                        style = MaterialTheme.typography.displayMedium,
                        fontWeight = FontWeight.Bold,
                        color = bracketColor
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "percentile",
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(bottom = 8.dp)
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = bracketName,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.SemiBold,
                    color = bracketColor
                )
                Text(
                    text = bracketDesc,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Progress bar
            LinearProgressIndicator(
                progress = { stats.percentile / 100f },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .clip(RoundedCornerShape(3.dp)),
                color = bracketColor,
                trackColor = MaterialTheme.colorScheme.surfaceVariant
            )
        }
    }
}

@Composable
fun StatsGrid(stats: GameStatistics) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        StatCard(
            modifier = Modifier.weight(1f),
            icon = "🏆",
            value = "${stats.highScore}",
            label = "High Score",
            color = Color(0xFFFFEB3B)
        )
        StatCard(
            modifier = Modifier.weight(1f),
            icon = "📊",
            value = "%.0f".format(stats.averageScore),
            label = "Average",
            color = Color(0xFF2196F3)
        )
    }
    
    Spacer(modifier = Modifier.height(12.dp))
    
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        StatCard(
            modifier = Modifier.weight(1f),
            icon = "🎮",
            value = "${stats.totalGamesPlayed}",
            label = "Games",
            color = Color(0xFF4CAF50)
        )
        StatCard(
            modifier = Modifier.weight(1f),
            icon = "🎯",
            value = "%.0f%%".format(stats.averageAccuracy),
            label = "Accuracy",
            color = Color(0xFFFF9800)
        )
    }
}

@Composable
fun StatCard(
    modifier: Modifier = Modifier,
    icon: String,
    value: String,
    label: String,
    color: Color
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(text = icon, fontSize = 18.sp)
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = value,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = label,
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun RecentSessionsCard(sessions: List<GameSession>) {
    val recentSessions = sessions.sortedByDescending { it.completedAt }.take(5)
    val dateFormat = remember { SimpleDateFormat("MMM d, h:mm a", Locale.getDefault()) }
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = "Recent Sessions",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )
            
            Spacer(modifier = Modifier.height(12.dp))
            
            if (recentSessions.isEmpty()) {
                Text(
                    text = "No sessions yet",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            } else {
                recentSessions.forEachIndexed { index, session ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "Score: ${session.score}",
                                style = MaterialTheme.typography.bodyLarge,
                                fontWeight = FontWeight.Medium
                            )
                            Text(
                                text = dateFormat.format(Date(session.completedAt)),
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)
                        ) {
                            Text(
                                text = "Lvl ${session.level}",
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                                style = MaterialTheme.typography.labelMedium,
                                color = MaterialTheme.colorScheme.primary
                            )
                        }
                    }
                    
                    if (index < recentSessions.lastIndex) {
                        HorizontalDivider(modifier = Modifier.padding(vertical = 4.dp))
                    }
                }
            }
        }
    }
}
