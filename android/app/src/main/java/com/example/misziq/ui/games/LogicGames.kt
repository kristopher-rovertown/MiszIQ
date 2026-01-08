package com.example.misziq.ui.games

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
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
import kotlinx.coroutines.launch
import kotlin.math.pow

// PATTERN MATCH GAME
@Composable
fun PatternMatchGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    data class Pattern(val sequence: List<Int>, val answer: Int, val options: List<Int>)
    
    fun genPattern(level: Int, round: Int): Pattern {
        val difficulty = level + (round / 4)
        // More complex patterns at higher difficulty
        val patternTypes = when (difficulty) {
            1 -> listOf(0)  // Arithmetic only
            2 -> listOf(0, 1)  // + Geometric
            3 -> listOf(0, 1, 2)  // + Alternating
            else -> listOf(0, 1, 2, 3, 4)  // All patterns
        }
        
        return when (patternTypes.random()) {
            0 -> { 
                // Arithmetic: larger numbers at higher levels
                val start = (1..(5 * difficulty)).random()
                val diff = (2..(3 + difficulty)).random()
                val seq = (0..4).map { start + it * diff }
                Pattern(seq.dropLast(1), seq.last(), listOf(seq.last(), seq.last()+diff, seq.last()-1, seq.last()+diff*2).shuffled()) 
            }
            1 -> { 
                // Geometric
                val start = (2..4).random()
                val ratio = if (difficulty > 2) (2..3).random() else 2
                val seq = (0..4).map { start * ratio.toDouble().pow(it.toDouble()).toInt() }
                Pattern(seq.dropLast(1), seq.last(), listOf(seq.last(), seq.last()*ratio, seq.last()/ratio, seq.last()+start).shuffled()) 
            }
            2 -> { 
                // Alternating
                val a = (1..5).random()
                val b = (6..12).random()
                val incr = (1..difficulty).random()
                val seq = listOf(a, b, a+incr, b+incr, a+incr*2)
                Pattern(seq.dropLast(1), seq.last(), listOf(a+incr*2, b+incr*2, a+incr, b+incr).shuffled()) 
            }
            3 -> { 
                // Fibonacci-like
                val seq = listOf(1, 1, 2, 3, 5, 8)
                Pattern(seq.dropLast(1), 8, listOf(8, 7, 9, 6).shuffled()) 
            }
            else -> { 
                // Squares or cubes
                if (difficulty > 4) {
                    val seq = (1..5).map { it * it * it }  // Cubes
                    Pattern(seq.dropLast(1), 125, listOf(125, 100, 64, 216).shuffled())
                } else {
                    val seq = (1..5).map { it * it }  // Squares
                    Pattern(seq.dropLast(1), 25, listOf(25, 24, 26, 20).shuffled())
                }
            }
        }
    }
    
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var round by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var correct by remember { mutableIntStateOf(0) }
    var pattern by remember { mutableStateOf(genPattern(1, 1)) }
    var selected by remember { mutableStateOf<Int?>(null) }
    var showFeedback by remember { mutableStateOf(false) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    fun submit() {
        val isCorrect = selected == pattern.answer
        if (isCorrect) {
            correct++
            score += 10 * level
            audioManager.playSoundEffect(SoundEffect.CORRECT_ANSWER)
            hapticManager.correctAnswer()
        } else {
            audioManager.playSoundEffect(SoundEffect.WRONG_ANSWER)
            hapticManager.wrongAnswer()
        }
        showFeedback = true
    }

    fun next() {
        if (round >= 10) {
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.PATTERN_MATCH.name, score = score, maxPossibleScore = 210, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else {
            round++; if (round == 4) level = 2; if (round == 7) level = 3
            pattern = genPattern(level, round); selected = null; showFeedback = false
        }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("🔢", "Pattern Match", "Find the number that completes the sequence.", GameAccentColor) { startTime = System.currentTimeMillis(); pattern = genPattern(1); gameState = GameState.PLAYING }
        GameState.PLAYING -> {
            GameScaffold("Pattern Match", level, round, 10, score, GameAccentColor, onBack) {
                if (!showFeedback) {
                    Spacer(Modifier.weight(1f))
                    Text("What comes next?", style = MaterialTheme.typography.titleMedium, color = GameAccentColor)
                    Spacer(Modifier.height(24.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        pattern.sequence.forEach { n -> Card { Text("$n", Modifier.padding(16.dp), style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold) } }
                        Card(colors = CardDefaults.cardColors(containerColor = GameAccentColor.copy(0.2f))) { Text("?", Modifier.padding(16.dp), style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold, color = GameAccentColor) }
                    }
                    Spacer(Modifier.height(32.dp))
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        pattern.options.chunked(2).forEach { row ->
                            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                                row.forEach { opt ->
                                    Button(onClick = { selected = opt }, Modifier.width(120.dp), shape = RoundedCornerShape(12.dp), colors = ButtonDefaults.buttonColors(containerColor = if (selected == opt) GameAccentColor else MaterialTheme.colorScheme.surfaceVariant, contentColor = if (selected == opt) Color.White else MaterialTheme.colorScheme.onSurface)) { Text("$opt", style = MaterialTheme.typography.titleLarge) }
                                }
                            }
                        }
                    }
                    Spacer(Modifier.height(24.dp))
                    if (selected != null) Button(onClick = { submit() }, colors = ButtonDefaults.buttonColors(containerColor = GameAccentColor)) { Text("Submit") }
                    Spacer(Modifier.weight(1f))
                } else {
                    FeedbackScreen(selected == pattern.answer, "The answer was ${pattern.answer}") { next() }
                }
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, correct, 10, mockService, GameType.PATTERN_MATCH, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0; correct = 0 }, onBack)
    }
}

// LOGIC PUZZLE GAME
@Composable
fun LogicPuzzleGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    data class Puzzle(val premises: List<String>, val question: String, val options: List<String>, val correctIdx: Int, val explanation: String)
    val puzzles = listOf(
        Puzzle(listOf("Alice is taller than Bob.", "Bob is taller than Carol."), "Who is shortest?", listOf("Alice", "Bob", "Carol", "Unknown"), 2, "Carol < Bob < Alice"),
        Puzzle(listOf("All cats are animals.", "Whiskers is a cat."), "Is Whiskers an animal?", listOf("Yes", "No", "Maybe", "Unknown"), 0, "All cats are animals, Whiskers is a cat."),
        Puzzle(listOf("If it rains, the ground gets wet.", "It is raining."), "Is the ground wet?", listOf("Yes", "No", "Maybe", "Unknown"), 0, "If P then Q, P is true, so Q is true."),
        Puzzle(listOf("Either John or Mary took the cookie.", "John was at work all day."), "Who took it?", listOf("John", "Mary", "Both", "Neither"), 1, "John couldn't have, so Mary did."),
        Puzzle(listOf("All doctors are smart.", "Dr. Smith is a doctor."), "Is Dr. Smith smart?", listOf("Yes", "No", "Maybe", "Unknown"), 0, "All doctors are smart.")
    )
    
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var round by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var correct by remember { mutableIntStateOf(0) }
    var puzzle by remember { mutableStateOf(puzzles[0]) }
    var selected by remember { mutableStateOf<Int?>(null) }
    var showFeedback by remember { mutableStateOf(false) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    fun submit() {
        val isCorrect = selected == puzzle.correctIdx
        if (isCorrect) {
            correct++
            score += 15 * level
            audioManager.playSoundEffect(SoundEffect.CORRECT_ANSWER)
            hapticManager.correctAnswer()
        } else {
            audioManager.playSoundEffect(SoundEffect.WRONG_ANSWER)
            hapticManager.wrongAnswer()
        }
        showFeedback = true
    }

    fun next() {
        if (round >= 8) {
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.LOGIC_PUZZLE.name, score = score, maxPossibleScore = 255, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else { round++; if (round == 3) level = 2; if (round == 6) level = 3; puzzle = puzzles.random(); selected = null; showFeedback = false }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("💡", "Logic Puzzle", "Use logical reasoning to solve problems.", GameAccentColor) { startTime = System.currentTimeMillis(); puzzle = puzzles.random(); gameState = GameState.PLAYING }
        GameState.PLAYING -> {
            GameScaffold("Logic Puzzle", level, round, 8, score, GameAccentColor, onBack) {
                if (!showFeedback) {
                    Card(Modifier.fillMaxWidth()) {
                        Column(Modifier.padding(16.dp)) {
                            Text("Given:", style = MaterialTheme.typography.labelLarge, color = GameAccentColor)
                            puzzle.premises.forEach { Text("• $it", style = MaterialTheme.typography.bodyLarge) }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    Text(puzzle.question, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold, textAlign = TextAlign.Center)
                    Spacer(Modifier.height(16.dp))
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        puzzle.options.forEachIndexed { idx, opt ->
                            Card(Modifier.fillMaxWidth().clickable { selected = idx }, colors = CardDefaults.cardColors(containerColor = if (selected == idx) GameAccentColor.copy(0.2f) else MaterialTheme.colorScheme.surface)) {
                                Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                                    Text("${('A' + idx)}", fontWeight = FontWeight.Bold, color = GameAccentColor)
                                    Spacer(Modifier.width(12.dp))
                                    Text(opt)
                                }
                            }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    if (selected != null) Button(onClick = { submit() }, colors = ButtonDefaults.buttonColors(containerColor = GameAccentColor)) { Text("Submit") }
                } else {
                    FeedbackScreen(selected == puzzle.correctIdx, "Answer: ${puzzle.options[puzzle.correctIdx]}", puzzle.explanation) { next() }
                }
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, correct, 8, mockService, GameType.LOGIC_PUZZLE, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0; correct = 0 }, onBack)
    }
}

// TOWER OF HANOI GAME
@Composable
fun TowerOfHanoiGame(
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
    var pegs by remember { mutableStateOf(listOf(listOf<Int>(), listOf(), listOf())) }
    var selectedPeg by remember { mutableStateOf<Int?>(null) }
    var moves by remember { mutableIntStateOf(0) }
    var currentDiskCount by remember { mutableIntStateOf(3) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    val colors = listOf(Color.Red, Color(0xFFFF9800), Color.Yellow, Color.Green, Color.Blue)
    
    fun setupLevel() { 
        currentDiskCount = level + 2
        pegs = listOf((currentDiskCount downTo 1).toList(), emptyList(), emptyList())
        moves = 0
        selectedPeg = null 
    }
    
    val optimalMoves = (1 shl currentDiskCount) - 1
    
    fun handleTap(pegIdx: Int) {
        if (selectedPeg == null) {
            if (pegs[pegIdx].isNotEmpty()) {
                selectedPeg = pegIdx
                hapticManager.buttonTap()
            }
        } else {
            if (pegIdx == selectedPeg) { selectedPeg = null; return }
            val disk = pegs[selectedPeg!!].firstOrNull() ?: return
            if (pegs[pegIdx].isEmpty() || pegs[pegIdx].first() > disk) {
                val newPegs = pegs.mapIndexed { i, p ->
                    when (i) {
                        selectedPeg -> p.drop(1)
                        pegIdx -> listOf(disk) + p
                        else -> p
                    }
                }
                pegs = newPegs
                moves++
                hapticManager.buttonTap()

                // Check win condition - all disks on peg 2 (target)
                if (newPegs[2].size == currentDiskCount) {
                    val eff = optimalMoves.toFloat() / moves
                    score += (100 * eff * level).toInt()
                    audioManager.playSoundEffect(SoundEffect.CORRECT_ANSWER)
                    hapticManager.correctAnswer()
                    if (level < 3) {
                        level++
                        setupLevel()
                    } else {
                        scope.launch {
                            repository.insertSession(GameSession(
                                profileId = profileId,
                                gameType = GameType.TOWER_OF_HANOI.name,
                                score = score,
                                maxPossibleScore = 300,
                                level = level,
                                durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt()
                            ))
                        }
                        audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
                        hapticManager.gameComplete()
                        gameState = GameState.GAME_OVER
                    }
                }
            }
            selectedPeg = null
        }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("🗼", "Tower of Hanoi", "Move all disks from left to right peg. Larger disks can't go on smaller ones.", GameAccentColor) { startTime = System.currentTimeMillis(); setupLevel(); gameState = GameState.PLAYING }
        GameState.PLAYING -> {
            GameScaffold("Tower of Hanoi", level, 1, 1, score, GameAccentColor, onBack) {
                Text("Moves: $moves (Optimal: $optimalMoves)", style = MaterialTheme.typography.bodyLarge)
                Spacer(Modifier.weight(1f))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                    pegs.forEachIndexed { pegIdx, disks ->
                        Column(Modifier.width(100.dp).clip(RoundedCornerShape(8.dp)).background(if (selectedPeg == pegIdx) GameAccentColor.copy(0.2f) else Color.Transparent).clickable { handleTap(pegIdx) }.padding(8.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Bottom) {
                            Box(Modifier.height(120.dp), contentAlignment = Alignment.BottomCenter) {
                                Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                                    disks.forEach { disk ->
                                        Box(Modifier.width((20 + disk * 15).dp).height(18.dp).clip(RoundedCornerShape(4.dp)).background(colors.getOrElse(disk - 1) { Color.Gray }))
                                    }
                                }
                            }
                            Box(Modifier.fillMaxWidth().height(8.dp).background(Color.Gray.copy(0.5f)))
                        }
                    }
                }
                Spacer(Modifier.height(16.dp))
                Row(horizontalArrangement = Arrangement.SpaceEvenly, modifier = Modifier.fillMaxWidth()) {
                    listOf("Source", "Helper", "Target").forEach { Text(it, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant) }
                }
                Spacer(Modifier.weight(1f))
                OutlinedButton(onClick = { setupLevel() }) { Text("Reset") }
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, 0, 0, mockService, GameType.TOWER_OF_HANOI, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; score = 0 }, onBack)
    }
}
