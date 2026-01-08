package com.example.misziq.ui.games

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.misziq.audio.AudioManager
import com.example.misziq.audio.SoundEffect
import com.example.misziq.data.model.GameSession
import com.example.misziq.data.model.GameType
import com.example.misziq.data.model.MockDataService
import com.example.misziq.data.repository.MiszIQRepository
import com.example.misziq.haptics.HapticManager
import com.example.misziq.ui.theme.GameAccentColor
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

enum class GameState { INSTRUCTIONS, PLAYING, FEEDBACK, GAME_OVER }

// MEMORY GRID GAME
@Composable
fun MemoryGridGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var round by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var correctInRound by remember { mutableIntStateOf(0) }
    var highlightedTiles by remember { mutableStateOf(setOf<Int>()) }
    var selectedTiles by remember { mutableStateOf(setOf<Int>()) }
    var showingPattern by remember { mutableStateOf(false) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    val gridSize = 2 + level + (round / 3)  // Grows during game: 3x3 -> 4x4 -> 5x5 -> 6x6
    val tilesToHighlight = 1 + level + (round / 2)  // More tiles as you progress
    val showDuration = maxOf(800L, 2000L - level * 300L)  // Less time to memorize
    
    fun generatePattern() {
        val totalCells = gridSize * gridSize
        highlightedTiles = (0 until totalCells).shuffled().take(minOf(tilesToHighlight, totalCells - 1)).toSet()
        selectedTiles = emptySet()
    }
    
    fun startRound() {
        generatePattern()
        showingPattern = true
        scope.launch {
            delay(showDuration)
            showingPattern = false
        }
    }
    
    fun checkAndProceed() {
        if (selectedTiles == highlightedTiles) {
            correctInRound++
            score += 10 * level
            audioManager.playSoundEffect(SoundEffect.CORRECT_ANSWER)
            hapticManager.correctAnswer()
        } else {
            audioManager.playSoundEffect(SoundEffect.WRONG_ANSWER)
            hapticManager.wrongAnswer()
        }

        if (round >= 5) {
            if (correctInRound >= 4 && level < 3) {
                level++
                round = 1
                correctInRound = 0
                startRound()
            } else {
                scope.launch {
                    repository.insertSession(GameSession(profileId = profileId, gameType = GameType.MEMORY_GRID.name, score = score, maxPossibleScore = 150, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt()))
                }
                audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
                hapticManager.gameComplete()
                gameState = GameState.GAME_OVER
            }
        } else {
            round++
            startRound()
        }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen(icon = "🔲", title = "Memory Grid", description = "Memorize the highlighted tiles, then tap to select them.", accentColor = GameAccentColor) { startTime = System.currentTimeMillis(); gameState = GameState.PLAYING; startRound() }
        GameState.PLAYING -> {
            GameScaffold("Memory Grid", level, round, 5, score, GameAccentColor, onBack) {
                Spacer(Modifier.weight(1f))
                Text(if (showingPattern) "Memorize!" else "Select the tiles", style = MaterialTheme.typography.titleMedium, color = GameAccentColor)
                Spacer(Modifier.height(24.dp))
                Column(verticalArrangement = Arrangement.spacedBy(8.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    for (row in 0 until gridSize) {
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            for (col in 0 until gridSize) {
                                val idx = row * gridSize + col
                                val bg by animateColorAsState(when { idx in highlightedTiles && showingPattern -> GameAccentColor; idx in selectedTiles -> GameAccentColor.copy(0.5f); else -> MaterialTheme.colorScheme.surfaceVariant }, label = "")
                                Box(Modifier.size(56.dp).clip(RoundedCornerShape(8.dp)).background(bg).clickable(!showingPattern) { selectedTiles = if (idx in selectedTiles) selectedTiles - idx else selectedTiles + idx })
                            }
                        }
                    }
                }
                Spacer(Modifier.height(24.dp))
                if (!showingPattern && selectedTiles.size == tilesToHighlight) {
                    Button(onClick = { checkAndProceed() }, colors = ButtonDefaults.buttonColors(containerColor = GameAccentColor)) { Text("Submit") }
                }
                Spacer(Modifier.weight(1f))
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, correctInRound, 5, mockService, GameType.MEMORY_GRID, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0; correctInRound = 0 }, onBack)
    }
}

// SEQUENCE MEMORY GAME
@Composable
fun SequenceMemoryGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var sequence by remember { mutableStateOf(listOf<Int>()) }
    var playerSequence by remember { mutableStateOf(listOf<Int>()) }
    var showingSequence by remember { mutableStateOf(false) }
    var activeButton by remember { mutableIntStateOf(-1) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    val colors = listOf(Color.Red, Color.Blue, Color.Green, Color.Yellow, Color(0xFFFF9800), Color.Cyan, Color.Magenta, Color(0xFF9C27B0), Color.Gray)
    
    // Speed increases with level: starts at 500ms, decreases to 250ms
    val displayInterval = maxOf(250L, 550L - level * 30L)
    val pauseInterval = maxOf(100L, 220L - level * 12L)
    
    fun showSequence() {
        showingSequence = true
        scope.launch {
            delay(400)
            for (i in sequence) {
                activeButton = i
                delay(displayInterval)
                activeButton = -1
                delay(pauseInterval)
            }
            showingSequence = false
        }
    }
    
    fun startLevel() {
        sequence = sequence + (0..8).random()
        playerSequence = emptyList()
        showSequence()
    }
    
    fun handleTap(idx: Int) {
        if (showingSequence) return
        playerSequence = playerSequence + idx
        hapticManager.buttonTap()
        scope.launch { activeButton = idx; delay(200); activeButton = -1 }

        if (playerSequence.last() != sequence[playerSequence.size - 1]) {
            audioManager.playSoundEffect(SoundEffect.WRONG_ANSWER)
            hapticManager.wrongAnswer()
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.SEQUENCE_MEMORY.name, score = score, maxPossibleScore = 100, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else if (playerSequence.size == sequence.size) {
            audioManager.playSoundEffect(SoundEffect.CORRECT_ANSWER)
            hapticManager.correctAnswer()
            score += sequence.size * 5
            level++
            scope.launch { delay(500); startLevel() }
        }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("🔀", "Sequence Memory", "Watch the sequence of lights, then repeat it in order.", GameAccentColor) { startTime = System.currentTimeMillis(); sequence = emptyList(); gameState = GameState.PLAYING; startLevel() }
        GameState.PLAYING -> {
            GameScaffold("Sequence Memory", level, level, 99, score, GameAccentColor, onBack) {
                Spacer(Modifier.weight(1f))
                Text(if (showingSequence) "Watch..." else "Your turn!", style = MaterialTheme.typography.titleMedium, color = GameAccentColor)
                Text("Sequence length: ${sequence.size}", style = MaterialTheme.typography.bodyMedium)
                Spacer(Modifier.height(24.dp))
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    for (row in 0..2) {
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            for (col in 0..2) {
                                val idx = row * 3 + col
                                Box(Modifier.size(80.dp).clip(RoundedCornerShape(12.dp)).background(if (activeButton == idx) colors[idx] else colors[idx].copy(0.3f)).clickable(!showingSequence) { handleTap(idx) })
                            }
                        }
                    }
                }
                Spacer(Modifier.weight(1f))
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, level - 1, 0, mockService, GameType.SEQUENCE_MEMORY, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; score = 0 }, onBack)
    }
}

// WORD RECALL GAME
@Composable
fun WordRecallGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var round by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var words by remember { mutableStateOf(listOf<String>()) }
    var userInput by remember { mutableStateOf("") }
    var recalledWords by remember { mutableStateOf(listOf<String>()) }
    var showingWords by remember { mutableStateOf(false) }
    var timeRemaining by remember { mutableIntStateOf(0) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    val wordBank = listOf("apple","river","mountain","garden","bridge","castle","forest","ocean","sunset","thunder","crystal","shadow","whisper","journey","harmony","mystery","village","temple","dragon","phoenix","meadow","canyon","island","desert","palace","harbor","valley","glacier","volcano","rainbow")
    val wordsCount = 4 + level
    
    fun startRound() {
        words = wordBank.shuffled().take(wordsCount)
        recalledWords = emptyList()
        userInput = ""
        showingWords = true
        timeRemaining = wordsCount * 2
        scope.launch {
            while (timeRemaining > 0) { delay(1000); timeRemaining-- }
            showingWords = false
        }
    }
    
    fun submitWord() {
        val w = userInput.trim().lowercase()
        if (w.isNotEmpty() && w !in recalledWords.map { it.lowercase() }) {
            recalledWords = recalledWords + userInput.trim()
            val isCorrect = words.any { it.equals(w, true) }
            if (isCorrect) {
                audioManager.playSoundEffect(SoundEffect.CORRECT_ANSWER)
                hapticManager.correctAnswer()
            } else {
                audioManager.playSoundEffect(SoundEffect.WRONG_ANSWER)
                hapticManager.wrongAnswer()
            }
        }
        userInput = ""
    }

    fun finishRound() {
        val correct = recalledWords.count { r -> words.any { it.equals(r, true) } }
        score += correct * 10 * level
        if (round >= 3) {
            if (level < 3) { level++; round = 1 }
            else {
                scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.WORD_RECALL.name, score = score, maxPossibleScore = 270, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
                audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
                hapticManager.gameComplete()
                gameState = GameState.GAME_OVER
                return
            }
        } else { round++ }
        startRound()
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("📝", "Word Recall", "Memorize the list of words, then type as many as you can remember.", GameAccentColor) { startTime = System.currentTimeMillis(); gameState = GameState.PLAYING; startRound() }
        GameState.PLAYING -> {
            GameScaffold("Word Recall", level, round, 3, score, GameAccentColor, onBack) {
                if (showingWords) {
                    Text("Memorize! ${timeRemaining}s", style = MaterialTheme.typography.titleMedium, color = GameAccentColor)
                    Spacer(Modifier.height(16.dp))
                    words.chunked(2).forEach { row ->
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            row.forEach { word -> Card(Modifier.padding(4.dp)) { Text(word, Modifier.padding(12.dp), style = MaterialTheme.typography.titleMedium) } }
                        }
                    }
                } else {
                    Text("Type the words you remember (${recalledWords.size}/${words.size})", style = MaterialTheme.typography.titleMedium)
                    Spacer(Modifier.height(16.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        OutlinedTextField(userInput, { userInput = it }, Modifier.weight(1f), singleLine = true, keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done), keyboardActions = KeyboardActions { submitWord() })
                        Spacer(Modifier.width(8.dp))
                        Button(onClick = { submitWord() }) { Text("+") }
                    }
                    Spacer(Modifier.height(12.dp))
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        recalledWords.forEach { w ->
                            val isCorrect = words.any { it.equals(w, true) }
                            Surface(shape = RoundedCornerShape(16.dp), color = if (isCorrect) Color.Green.copy(0.2f) else Color.Red.copy(0.2f)) {
                                Text(w, Modifier.padding(8.dp, 4.dp), style = MaterialTheme.typography.bodySmall)
                            }
                        }
                    }
                    Spacer(Modifier.height(24.dp))
                    Button(onClick = { finishRound() }, colors = ButtonDefaults.buttonColors(containerColor = GameAccentColor)) { Text("Done") }
                }
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, 0, 0, mockService, GameType.WORD_RECALL, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0 }, onBack)
    }
}
