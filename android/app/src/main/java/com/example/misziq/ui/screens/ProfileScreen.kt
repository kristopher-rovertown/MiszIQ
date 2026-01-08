package com.example.misziq.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.border
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.misziq.data.model.Achievement
import com.example.misziq.data.model.BadgeCategory
import com.example.misziq.data.model.BadgeManager
import com.example.misziq.data.model.BadgeType
import com.example.misziq.data.model.UserProfile
import com.example.misziq.data.repository.MiszIQRepository
import com.example.misziq.ui.theme.RoyalBlue
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun ProfileScreen(
    profileId: String,
    repository: MiszIQRepository,
    onNavigateToSettings: () -> Unit,
    onSwitchProfile: () -> Unit
) {
    var profile by remember { mutableStateOf<UserProfile?>(null) }
    val sessions by repository.getSessionsForProfile(profileId).collectAsState(initial = emptyList())
    val achievements by repository.getAchievementsForProfile(profileId).collectAsState(initial = emptyList())
    var showEditDialog by remember { mutableStateOf(false) }
    var showDeleteDialog by remember { mutableStateOf(false) }
    var showAllBadgesDialog by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val dateFormat = remember { SimpleDateFormat("MMM d, yyyy", Locale.getDefault()) }

    LaunchedEffect(profileId) {
        profile = repository.getProfileById(profileId)
    }

    // Sync badges based on existing sessions (retroactive awarding)
    LaunchedEffect(profile, sessions) {
        profile?.let { p ->
            if (sessions.isNotEmpty()) {
                val newBadges = BadgeManager.syncBadges(
                    profileId = p.id,
                    sessions = sessions,
                    existingAchievements = achievements,
                    repository = repository
                )
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(16.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Profile",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 24.dp)
        )
        
        profile?.let { p ->
            // Avatar
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center
            ) {
                Text(text = p.avatarEmoji, fontSize = 48.sp)
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = p.name,
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold
            )
            
            Text(
                text = "Member since ${dateFormat.format(Date(p.createdAt))}",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Stats summary
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "${sessions.size}",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Games Played",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "${sessions.map { it.gameType }.distinct().size}",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Games Tried",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        val avgScore = if (sessions.isNotEmpty()) sessions.map { it.score }.average().toInt() else 0
                        Text(
                            text = "$avgScore",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Avg Score",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))

            // Badges Section
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
                            text = "Badges",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                        TextButton(onClick = { showAllBadgesDialog = true }) {
                            Text("View All")
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    if (achievements.isEmpty()) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(text = "🏅", fontSize = 40.sp)
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "No badges yet",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                text = "Complete games to earn badges!",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    } else {
                        LazyRow(
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            items(achievements.sortedByDescending { it.unlockedAt }.take(8)) { achievement ->
                                achievement.type?.let { badgeType ->
                                    BadgeItem(badgeType = badgeType, isUnlocked = true)
                                }
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Actions
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp)
            ) {
                Column {
                    ListItem(
                        headlineContent = { Text("Settings") },
                        leadingContent = {
                            Icon(Icons.Default.Settings, contentDescription = null)
                        },
                        modifier = Modifier.clickable { onNavigateToSettings() }
                    )
                    HorizontalDivider()
                    ListItem(
                        headlineContent = { Text("Edit Profile") },
                        leadingContent = {
                            Icon(Icons.Default.Edit, contentDescription = null)
                        },
                        modifier = Modifier.clickable { showEditDialog = true }
                    )
                    HorizontalDivider()
                    ListItem(
                        headlineContent = { Text("Switch Profile") },
                        leadingContent = {
                            Icon(Icons.Default.SwitchAccount, contentDescription = null)
                        },
                        modifier = Modifier.clickable { onSwitchProfile() }
                    )
                    HorizontalDivider()
                    ListItem(
                        headlineContent = {
                            Text("Delete Profile", color = MaterialTheme.colorScheme.error)
                        },
                        leadingContent = {
                            Icon(
                                Icons.Default.Delete,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.error
                            )
                        },
                        modifier = Modifier.clickable { showDeleteDialog = true }
                    )
                }
            }
        }
    }
    
    if (showEditDialog) {
        profile?.let { p ->
            EditProfileDialog(
                profile = p,
                onDismiss = { showEditDialog = false },
                onSave = { name, emoji ->
                    scope.launch {
                        repository.updateProfile(p.copy(name = name, avatarEmoji = emoji))
                        profile = repository.getProfileById(profileId)
                    }
                    showEditDialog = false
                }
            )
        }
    }
    
    if (showDeleteDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteDialog = false },
            title = { Text("Delete Profile") },
            text = { Text("Are you sure you want to delete this profile? All game history will be lost.") },
            confirmButton = {
                Button(
                    onClick = {
                        scope.launch {
                            profile?.let { repository.deleteProfile(it) }
                        }
                        showDeleteDialog = false
                        onSwitchProfile()
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    if (showAllBadgesDialog) {
        AllBadgesDialog(
            achievements = achievements,
            sessions = sessions,
            onDismiss = { showAllBadgesDialog = false }
        )
    }
}

@Composable
fun EditProfileDialog(
    profile: UserProfile,
    onDismiss: () -> Unit,
    onSave: (String, String) -> Unit
) {
    var name by remember { mutableStateOf(profile.name) }
    var selectedEmoji by remember { mutableStateOf(profile.avatarEmoji) }
    
    val emojis = listOf("🧠", "🎯", "⭐", "🚀", "💡", "🔥", "💪", "🎨", "🌟", "🏆", "🦊", "🐱", "🐶", "🦁", "🐼")
    
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit Profile") },
        text = {
            Column {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Name") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                
                Spacer(modifier = Modifier.height(16.dp))
                
                Text("Choose Avatar", style = MaterialTheme.typography.labelLarge)
                
                Spacer(modifier = Modifier.height(8.dp))
                
                LazyVerticalGrid(
                    columns = GridCells.Fixed(5),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.height(120.dp)
                ) {
                    items(emojis) { emoji ->
                        Box(
                            modifier = Modifier
                                .size(44.dp)
                                .clip(CircleShape)
                                .background(
                                    if (emoji == selectedEmoji)
                                        MaterialTheme.colorScheme.primaryContainer
                                    else
                                        Color.Transparent
                                )
                                .clickable { selectedEmoji = emoji },
                            contentAlignment = Alignment.Center
                        ) {
                            Text(text = emoji, fontSize = 24.sp)
                        }
                    }
                }
            }
        },
        confirmButton = {
            Button(
                onClick = { onSave(name, selectedEmoji) },
                enabled = name.isNotBlank()
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun BadgeItem(
    badgeType: BadgeType,
    isUnlocked: Boolean,
    progress: Double = 1.0
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.width(64.dp)
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(50.dp)
                .clip(CircleShape)
                .background(
                    if (isUnlocked) RoyalBlue.copy(alpha = 0.1f)
                    else Color.Gray.copy(alpha = 0.1f)
                )
        ) {
            Text(
                text = badgeType.emoji,
                fontSize = 24.sp,
                modifier = Modifier.alpha(if (isUnlocked) 1f else 0.4f)
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = badgeType.displayName,
            style = MaterialTheme.typography.labelSmall,
            textAlign = TextAlign.Center,
            maxLines = 1,
            color = if (isUnlocked) MaterialTheme.colorScheme.onSurface
                    else MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun AllBadgesDialog(
    achievements: List<Achievement>,
    sessions: List<com.example.misziq.data.model.GameSession>,
    onDismiss: () -> Unit
) {
    val unlockedBadgeTypes = achievements.mapNotNull { it.type }.toSet()
    val badgeProgress = BadgeManager.getBadgeProgress(sessions)
    var selectedBadge by remember { mutableStateOf<BadgeType?>(null) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("All Badges") },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(400.dp)
                    .verticalScroll(rememberScrollState())
            ) {
                BadgeCategory.values().forEach { category ->
                    Text(
                        text = category.displayName,
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(vertical = 8.dp)
                    )

                    val categoryBadges = BadgeType.values().filter { it.category == category }

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        categoryBadges.forEach { badgeType ->
                            val isUnlocked = badgeType in unlockedBadgeTypes
                            val progress = badgeProgress[badgeType] ?: 0.0
                            Box(modifier = Modifier.clickable { selectedBadge = badgeType }) {
                                BadgeItem(
                                    badgeType = badgeType,
                                    isUnlocked = isUnlocked,
                                    progress = progress
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Close")
            }
        }
    )

    // Badge Detail Dialog
    selectedBadge?.let { badge ->
        val isUnlocked = badge in unlockedBadgeTypes
        val progress = badgeProgress[badge] ?: 0.0
        val unlockedDate = achievements.find { it.type == badge }?.unlockedAt

        BadgeDetailDialog(
            badgeType = badge,
            isUnlocked = isUnlocked,
            progress = progress,
            unlockedDate = unlockedDate,
            onDismiss = { selectedBadge = null }
        )
    }
}

@Composable
fun BadgeDetailDialog(
    badgeType: BadgeType,
    isUnlocked: Boolean,
    progress: Double,
    unlockedDate: Long?,
    onDismiss: () -> Unit
) {
    val dateFormat = remember { java.text.SimpleDateFormat("MMM d, yyyy", java.util.Locale.getDefault()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = null,
        text = {
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Badge Icon
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(100.dp)
                        .clip(CircleShape)
                        .background(
                            if (isUnlocked) RoyalBlue.copy(alpha = 0.15f)
                            else Color.Gray.copy(alpha = 0.1f)
                        )
                        .then(
                            if (isUnlocked) Modifier.border(3.dp, RoyalBlue, CircleShape)
                            else Modifier
                        )
                ) {
                    if (!isUnlocked && progress > 0) {
                        CircularProgressIndicator(
                            progress = { progress.toFloat() },
                            modifier = Modifier.size(100.dp),
                            color = RoyalBlue,
                            strokeWidth = 4.dp,
                            trackColor = Color.Transparent
                        )
                    }
                    Text(
                        text = badgeType.emoji,
                        fontSize = 44.sp,
                        modifier = Modifier.alpha(if (isUnlocked) 1f else 0.4f)
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Badge Name
                Text(
                    text = badgeType.displayName,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Status
                if (isUnlocked) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = Color(0xFF4CAF50),
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "Earned",
                            color = Color(0xFF4CAF50),
                            fontWeight = FontWeight.Medium
                        )
                    }
                    unlockedDate?.let { date ->
                        Text(
                            text = "Unlocked on ${dateFormat.format(java.util.Date(date))}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                } else {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Lock,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "Not Yet Earned",
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            fontWeight = FontWeight.Medium
                        )
                    }
                    if (progress > 0) {
                        Text(
                            text = "${(progress * 100).toInt()}% Progress",
                            style = MaterialTheme.typography.bodySmall,
                            color = RoyalBlue
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // How to Earn
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                    )
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "How to Earn",
                            style = MaterialTheme.typography.titleSmall,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Row(verticalAlignment = Alignment.Top) {
                            Icon(
                                imageVector = if (isUnlocked) Icons.Default.CheckCircle else Icons.Default.Star,
                                contentDescription = null,
                                tint = if (isUnlocked) Color(0xFF4CAF50) else RoyalBlue,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = badgeType.description,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Category
                Text(
                    text = "Category: ${badgeType.category.displayName}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Done")
            }
        }
    )
}
