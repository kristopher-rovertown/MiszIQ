package com.example.misziq.ui.games

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
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
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.abs

// MENTAL MATH GAME
@Composable
fun MentalMathGame(
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
    var correct by remember { mutableIntStateOf(0) }
    var problem by remember { mutableStateOf("") }
    var answer by remember { mutableIntStateOf(0) }
    var userInput by remember { mutableStateOf("") }
    var timeRemaining by remember { mutableIntStateOf(15) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    fun generateProblem() {
        // Progressive difficulty based on level AND round
        val difficulty = level + (round / 4)
        
        val ops = when (difficulty) {
            1 -> listOf("+")
            2 -> listOf("+", "-")
            3 -> listOf("+", "-", "×")
            else -> listOf("+", "-", "×", "÷")
        }
        
        val maxNum = when (difficulty) {
            1 -> 20
            2 -> 35
            3 -> 50
            4 -> 70
            else -> 99
        }
        
        val op = ops.random()
        val (a, b) = when (op) {
            "+" -> Pair((5..maxNum).random(), (5..maxNum).random())
            "-" -> { val x = (10..maxNum).random(); Pair(x, (5..x).random()) }
            "×" -> {
                val maxMult = minOf(12, 5 + difficulty * 2)
                Pair((2..maxMult).random(), (2..maxMult).random())
            }
            else -> { 
                val maxDiv = minOf(12, 4 + difficulty * 2)
                val divisor = (2..maxDiv).random()
                Pair(divisor * (2..maxDiv).random(), divisor) 
            }
        }
        problem = "$a $op $b"
        answer = when (op) { "+" -> a + b; "-" -> a - b; "×" -> a * b; else -> a / b }
        userInput = ""
        // Time decreases with level: 15s -> 12s -> 10s -> 8s -> 6s
        timeRemaining = maxOf(6, 16 - level * 2)
    }
    
    fun submit() {
        val isCorrect = userInput.toIntOrNull() == answer
        if (isCorrect) {
            correct++
            score += 10 * level + (timeRemaining / 2)
            audioManager.playSoundEffect(SoundEffect.CORRECT_ANSWER)
            hapticManager.correctAnswer()
        } else {
            audioManager.playSoundEffect(SoundEffect.WRONG_ANSWER)
            hapticManager.wrongAnswer()
        }
        if (round >= 10) {
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.MENTAL_MATH.name, score = score, maxPossibleScore = 260, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else {
            round++
            if (round == 4) level = 2
            if (round == 7) level = 3
            generateProblem()
        }
    }
    
    LaunchedEffect(gameState, round) {
        if (gameState == GameState.PLAYING) {
            while (timeRemaining > 0) { delay(1000); timeRemaining-- }
            submit()
        }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("➕", "Mental Math", "Solve arithmetic problems as quickly as possible.", GameAccentColor) { startTime = System.currentTimeMillis(); gameState = GameState.PLAYING; generateProblem() }
        GameState.PLAYING -> {
            GameScaffold("Mental Math", level, round, 10, score, GameAccentColor, onBack) {
                LinearProgressIndicator(progress = { timeRemaining / 15f }, Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(4.dp)), color = if (timeRemaining <= 3) Color.Red else GameAccentColor)
                Spacer(Modifier.height(8.dp))
                Text("${timeRemaining}s", style = MaterialTheme.typography.bodyMedium, color = if (timeRemaining <= 3) Color.Red else MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(Modifier.weight(1f))
                Text(problem, style = MaterialTheme.typography.displayMedium, fontWeight = FontWeight.Bold)
                Spacer(Modifier.height(24.dp))
                Text(userInput.ifEmpty { "?" }, style = MaterialTheme.typography.displaySmall, color = GameAccentColor, fontWeight = FontWeight.Bold)
                Spacer(Modifier.height(24.dp))
                // Number pad
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    listOf(listOf("1","2","3"), listOf("4","5","6"), listOf("7","8","9"), listOf("C","0","⏎")).forEach { row ->
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            row.forEach { key ->
                                Button(onClick = { when (key) { "C" -> userInput = ""; "⏎" -> submit(); else -> userInput += key } }, Modifier.size(72.dp), shape = RoundedCornerShape(12.dp), colors = ButtonDefaults.buttonColors(containerColor = if (key == "⏎") GameAccentColor else MaterialTheme.colorScheme.surfaceVariant, contentColor = if (key == "⏎") Color.White else MaterialTheme.colorScheme.onSurface)) {
                                    Text(key, fontSize = 24.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }
                }
                Spacer(Modifier.weight(1f))
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, correct, 10, mockService, GameType.MENTAL_MATH, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0; correct = 0 }, onBack)
    }
}

// NUMBER COMPARISON GAME
@Composable
fun NumberComparisonGame(
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
    var correct by remember { mutableIntStateOf(0) }
    var leftExpr by remember { mutableStateOf("") }
    var rightExpr by remember { mutableStateOf("") }
    var leftVal by remember { mutableIntStateOf(0) }
    var rightVal by remember { mutableIntStateOf(0) }
    var timeRemaining by remember { mutableIntStateOf(8) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    fun genExpr(): Pair<String, Int> {
        return when ((0..if (level > 1) 3 else 1).random()) {
            0 -> { val n = (10..99).random(); "$n" to n }
            1 -> { val a = (5..30).random(); val b = (5..30).random(); "$a + $b" to a + b }
            2 -> { val a = (2..12).random(); val b = (2..9).random(); "$a × $b" to a * b }
            else -> { val a = (10..50).random(); val b = (5..20).random(); "$a - $b" to a - b }
        }
    }
    
    fun generate() {
        val (le, lv) = genExpr(); val (re, rv) = genExpr()
        leftExpr = le; leftVal = lv; rightExpr = re; rightVal = rv
        timeRemaining = when (level) { 1 -> 8; 2 -> 6; else -> 5 }
    }
    
    fun answer(choice: Int) { // -1 = <, 0 = =, 1 = >
        val correctChoice = leftVal.compareTo(rightVal)
        val isCorrect = choice == correctChoice
        if (isCorrect) {
            correct++
            score += 10 * level + if (timeRemaining > 3) 5 else 0
            audioManager.playSoundEffect(SoundEffect.CORRECT_ANSWER)
            hapticManager.correctAnswer()
        } else {
            audioManager.playSoundEffect(SoundEffect.WRONG_ANSWER)
            hapticManager.wrongAnswer()
        }
        if (round >= 10) {
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.NUMBER_COMPARISON.name, score = score, maxPossibleScore = 260, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else {
            round++; if (round == 4) level = 2; if (round == 7) level = 3; generate()
        }
    }
    
    LaunchedEffect(gameState, round) {
        if (gameState == GameState.PLAYING) {
            while (timeRemaining > 0) { delay(1000); timeRemaining-- }
            answer(2) // timeout = wrong
        }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("⚖️", "Number Compare", "Compare the two expressions. Is left <, =, or > right?", GameAccentColor) { startTime = System.currentTimeMillis(); gameState = GameState.PLAYING; generate() }
        GameState.PLAYING -> {
            GameScaffold("Number Compare", level, round, 10, score, GameAccentColor, onBack) {
                LinearProgressIndicator(progress = { timeRemaining / 8f }, Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(4.dp)), color = if (timeRemaining <= 2) Color.Red else GameAccentColor)
                Spacer(Modifier.weight(1f))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.CenterVertically) {
                    Card(Modifier.weight(1f).padding(8.dp)) { Text(leftExpr, Modifier.padding(20.dp).fillMaxWidth(), textAlign = TextAlign.Center, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold) }
                    Text("?", style = MaterialTheme.typography.headlineMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Card(Modifier.weight(1f).padding(8.dp)) { Text(rightExpr, Modifier.padding(20.dp).fillMaxWidth(), textAlign = TextAlign.Center, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold) }
                }
                Spacer(Modifier.height(32.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    listOf("<" to -1, "=" to 0, ">" to 1).forEach { (sym, val_) ->
                        Button(onClick = { answer(val_) }, Modifier.size(80.dp), shape = CircleShape, colors = ButtonDefaults.buttonColors(containerColor = GameAccentColor)) { Text(sym, fontSize = 32.sp, fontWeight = FontWeight.Bold) }
                    }
                }
                Spacer(Modifier.weight(1f))
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, correct, 10, mockService, GameType.NUMBER_COMPARISON, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0; correct = 0 }, onBack)
    }
}

// ESTIMATION GAME
@Composable
fun EstimationGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    data class Question(val prompt: String, val actual: Float, val unit: String, val min: Float, val max: Float)
    val questions = listOf(
        Question("Keys on a standard piano?", 88f, "keys", 40f, 120f),
        Question("Bones in adult human body?", 206f, "bones", 100f, 350f),
        Question("Countries in Africa?", 54f, "countries", 20f, 80f),
        Question("Cards in a standard deck?", 52f, "cards", 30f, 80f),
        Question("Percent of Earth covered by water?", 71f, "%", 40f, 95f),
        Question("Height of Eiffel Tower (meters)?", 330f, "m", 150f, 500f),
        Question("Days in a year?", 365f, "days", 300f, 400f),
        Question("US states?", 50f, "states", 30f, 70f),
        Question("Boiling point of water (°C)?", 100f, "°C", 60f, 150f),
        Question("Minutes in a day?", 1440f, "min", 800f, 2000f)
    )
    
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var round by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var question by remember { mutableStateOf(questions[0]) }
    var estimate by remember { mutableFloatStateOf(50f) }
    var showFeedback by remember { mutableStateOf(false) }
    var lastAccuracy by remember { mutableFloatStateOf(0f) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    fun generate() { question = questions.random(); estimate = (question.min + question.max) / 2; showFeedback = false }

    fun submit() {
        val acc = 1f - abs(estimate - question.actual) / question.actual
        lastAccuracy = acc.coerceIn(0f, 1f)
        val pts = when { lastAccuracy >= 0.95f -> 15; lastAccuracy >= 0.8f -> 10; lastAccuracy >= 0.6f -> 5; lastAccuracy >= 0.4f -> 2; else -> 0 }
        score += pts * level
        if (lastAccuracy >= 0.6f) {
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
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.ESTIMATION.name, score = score, maxPossibleScore = 315, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else {
            round++; if (round == 4) level = 2; if (round == 7) level = 3; generate()
        }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("🎯", "Estimation", "Estimate quantities, distances, and percentages.", GameAccentColor) { startTime = System.currentTimeMillis(); gameState = GameState.PLAYING; generate() }
        GameState.PLAYING -> {
            GameScaffold("Estimation", level, round, 10, score, GameAccentColor, onBack) {
                if (!showFeedback) {
                    Spacer(Modifier.weight(1f))
                    Text(question.prompt, style = MaterialTheme.typography.titleLarge, textAlign = TextAlign.Center)
                    Spacer(Modifier.height(32.dp))
                    Text("${estimate.toInt()} ${question.unit}", style = MaterialTheme.typography.displayMedium, fontWeight = FontWeight.Bold, color = GameAccentColor)
                    Spacer(Modifier.height(24.dp))
                    Slider(estimate, { estimate = it }, valueRange = question.min..question.max, colors = SliderDefaults.colors(thumbColor = GameAccentColor, activeTrackColor = GameAccentColor))
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("${question.min.toInt()}", style = MaterialTheme.typography.bodySmall)
                        Text("${question.max.toInt()}", style = MaterialTheme.typography.bodySmall)
                    }
                    Spacer(Modifier.height(32.dp))
                    Button(onClick = { submit() }, colors = ButtonDefaults.buttonColors(containerColor = GameAccentColor)) { Text("Lock In") }
                    Spacer(Modifier.weight(1f))
                } else {
                    Spacer(Modifier.weight(1f))
                    Text("${(lastAccuracy * 100).toInt()}% Accurate", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold, color = if (lastAccuracy > 0.7f) Color.Green else if (lastAccuracy > 0.4f) GameAccentColor else Color.Red)
                    Spacer(Modifier.height(16.dp))
                    Text("Your estimate: ${estimate.toInt()} ${question.unit}", style = MaterialTheme.typography.bodyLarge)
                    Text("Actual: ${question.actual.toInt()} ${question.unit}", style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Bold, color = GameAccentColor)
                    Spacer(Modifier.height(32.dp))
                    Button(onClick = { next() }, colors = ButtonDefaults.buttonColors(containerColor = GameAccentColor)) { Text("Continue") }
                    Spacer(Modifier.weight(1f))
                }
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, 0, 0, mockService, GameType.ESTIMATION, GameAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0 }, onBack)
    }
}
