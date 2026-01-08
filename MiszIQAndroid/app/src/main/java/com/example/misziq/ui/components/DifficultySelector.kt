package com.example.misziq.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Lock
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
import com.example.misziq.ui.theme.RoyalBlue
import kotlinx.coroutines.launch

@Composable
fun DifficultySelector(
    profileId: String,
    gameType: GameType,
    repository: MiszIQRepository,
    selectedLevel: Int,
    onLevelSelected: (Int) -> Unit,
    onStart: () -> Unit
) {
    var maxUnlockedLevel by remember { mutableIntStateOf(1) }
    val scope = rememberCoroutineScope()

    LaunchedEffect(profileId, gameType) {
        maxUnlockedLevel = repository.getMaxUnlockedLevel(profileId, gameType.name)
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Select Difficulty",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(24.dp))

        Column(
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            listOf(
                Triple(1, "Easy", "Great for beginners"),
                Triple(2, "Medium", "A balanced challenge"),
                Triple(3, "Hard", "For experienced players")
            ).forEach { (level, name, description) ->
                val isUnlocked = level <= maxUnlockedLevel
                val isSelected = selectedLevel == level

                DifficultyRow(
                    level = level,
                    name = name,
                    description = description,
                    isSelected = isSelected,
                    isUnlocked = isUnlocked,
                    onClick = {
                        if (isUnlocked) {
                            onLevelSelected(level)
                        }
                    }
                )
            }
        }

        if (maxUnlockedLevel < 3) {
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = "Achieve 100% accuracy to unlock higher levels",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = onStart,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 40.dp),
            colors = ButtonDefaults.buttonColors(containerColor = RoyalBlue)
        ) {
            Text("Start Game", style = MaterialTheme.typography.titleMedium)
        }
    }
}

@Composable
fun DifficultyRow(
    level: Int,
    name: String,
    description: String,
    isSelected: Boolean,
    isUnlocked: Boolean,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(
                if (isSelected && isUnlocked) RoyalBlue.copy(alpha = 0.1f)
                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
            )
            .border(
                width = if (isSelected && isUnlocked) 2.dp else 0.dp,
                color = if (isSelected && isUnlocked) RoyalBlue else Color.Transparent,
                shape = RoundedCornerShape(12.dp)
            )
            .clickable(enabled = isUnlocked) { onClick() }
            .padding(16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = name,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = if (isUnlocked) MaterialTheme.colorScheme.onSurface
                        else MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        if (isUnlocked) {
            if (isSelected) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = "Selected",
                    tint = RoyalBlue,
                    modifier = Modifier.size(28.dp)
                )
            }
        } else {
            Icon(
                imageVector = Icons.Default.Lock,
                contentDescription = "Locked",
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(28.dp)
            )
        }
    }
}

@Composable
fun GameCompletionOverlay(
    newBadges: List<BadgeType>,
    unlockedLevel: Int?,
    gameType: GameType,
    onDismiss: () -> Unit
) {
    if (newBadges.isNotEmpty() || unlockedLevel != null) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.5f))
                .clickable(enabled = false) { },
            contentAlignment = Alignment.Center
        ) {
            Card(
                modifier = Modifier
                    .fillMaxWidth(0.85f)
                    .padding(16.dp),
                shape = RoundedCornerShape(20.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    if (newBadges.isNotEmpty()) {
                        Text(
                            text = "Badge Unlocked!",
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Bold,
                            color = RoyalBlue
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        newBadges.forEach { badge ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .background(
                                        RoyalBlue.copy(alpha = 0.1f),
                                        RoundedCornerShape(12.dp)
                                    )
                                    .padding(12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = badge.emoji,
                                    fontSize = 36.sp
                                )
                                Spacer(modifier = Modifier.width(12.dp))
                                Column {
                                    Text(
                                        text = badge.displayName,
                                        style = MaterialTheme.typography.titleMedium,
                                        fontWeight = FontWeight.Bold
                                    )
                                    Text(
                                        text = badge.description,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }
                            Spacer(modifier = Modifier.height(8.dp))
                        }
                    }

                    if (unlockedLevel != null) {
                        if (newBadges.isNotEmpty()) {
                            Spacer(modifier = Modifier.height(16.dp))
                        }

                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .background(
                                    Color(0xFF40E0D0).copy(alpha = 0.1f),
                                    RoundedCornerShape(12.dp)
                                )
                                .padding(16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(text = "🔓", fontSize = 40.sp)
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "Level $unlockedLevel Unlocked!",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = "You can now play ${gameType.displayName} on a harder difficulty!",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    Button(
                        onClick = onDismiss,
                        colors = ButtonDefaults.buttonColors(containerColor = RoyalBlue)
                    ) {
                        Text("Continue")
                    }
                }
            }
        }
    }
}
