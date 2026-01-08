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
import com.example.misziq.ui.theme.LanguageAccentColor
import kotlinx.coroutines.launch

// WORD SCRAMBLE GAME
@Composable
fun WordScrambleGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    // Progressive word difficulty: easier short words -> harder long words
    val wordsByLevel = listOf(
        // Level 1: 4-5 letter common words
        mapOf("apple" to "A common fruit", "house" to "Where people live", "water" to "Essential for life", "music" to "Audible art form", "dream" to "Happens during sleep", "chair" to "Furniture to sit on", "bread" to "Baked food", "light" to "Opposite of dark", "stone" to "A small rock", "flame" to "Part of fire"),
        // Level 2: 6-7 letter words
        mapOf("garden" to "Where flowers grow", "bridge" to "Crosses over water", "shadow" to "Blocked light", "castle" to "Medieval fortress", "planet" to "Orbits a star", "jungle" to "Dense forest", "silver" to "Precious metal", "frozen" to "Very cold", "wizard" to "Magic user", "pirate" to "Sea robber"),
        // Level 3: 8+ letter challenging words
        mapOf("mountain" to "Very tall landform", "elephant" to "Large gray animal", "computer" to "Electronic device", "treasure" to "Valuable items", "keyboard" to "Typing device", "dinosaur" to "Extinct reptile", "umbrella" to "Rain protection", "strawberry" to "Red berry", "chocolate" to "Sweet treat", "adventure" to "Exciting journey")
    )
    
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var round by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var correct by remember { mutableIntStateOf(0) }
    var currentWord by remember { mutableStateOf("") }
    var hint by remember { mutableStateOf("") }
    var scrambled by remember { mutableStateOf(listOf<Char>()) }
    var selected by remember { mutableStateOf(listOf<Int>()) }
    var showFeedback by remember { mutableStateOf(false) }
    var wasCorrect by remember { mutableStateOf(false) }
    var showHint by remember { mutableStateOf(false) }
    var startTime by remember { mutableLongStateOf(0L) }
    var previousWord by remember { mutableStateOf("") }
    val scope = rememberCoroutineScope()

    fun generate() {
        val words = wordsByLevel[level - 1]
        // Filter out previous word to avoid repeats
        val availableWords = words.filter { it.key != previousWord }
        val wordsToChooseFrom = if (availableWords.isEmpty()) words else availableWords
        val (word, h) = wordsToChooseFrom.entries.random()
        previousWord = word
        currentWord = word; hint = h
        scrambled = word.uppercase().toList().shuffled()
        // Make sure it's actually scrambled
        var attempts = 0
        while (scrambled.joinToString("") == word.uppercase() && word.length > 1 && attempts < 10) {
            scrambled = scrambled.shuffled()
            attempts++
        }
        selected = emptyList(); showFeedback = false; showHint = false
    }
    
    fun submit() {
        val guess = selected.map { scrambled[it] }.joinToString("")
        wasCorrect = guess.equals(currentWord, true)
        if (wasCorrect) {
            correct++
            // Bonus for not using hint
            score += if (showHint) 5 * level else 10 * level
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
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.WORD_SCRAMBLE.name, score = score, maxPossibleScore = 210, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else { round++; if (round == 4) level = 2; if (round == 7) level = 3; generate() }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("🔤", "Word Scramble", "Unscramble the letters to form a word.", LanguageAccentColor) { startTime = System.currentTimeMillis(); generate(); gameState = GameState.PLAYING }
        GameState.PLAYING -> {
            GameScaffold("Word Scramble", level, round, 10, score, LanguageAccentColor, onBack) {
                if (!showFeedback) {
                    Spacer(Modifier.weight(1f))
                    Surface(shape = RoundedCornerShape(16.dp), color = LanguageAccentColor.copy(0.1f)) { Text(hint, Modifier.padding(12.dp, 6.dp), style = MaterialTheme.typography.bodyMedium) }
                    Spacer(Modifier.height(24.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        (0 until currentWord.length).forEach { i ->
                            Card(Modifier.size(44.dp)) {
                                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                                    Text(if (i < selected.size) "${scrambled[selected[i]]}" else "", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold, color = LanguageAccentColor)
                                }
                            }
                        }
                    }
                    Spacer(Modifier.height(24.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        scrambled.forEachIndexed { idx, c ->
                            val isUsed = idx in selected
                            Button(onClick = { if (!isUsed && selected.size < currentWord.length) selected = selected + idx }, Modifier.size(50.dp), shape = RoundedCornerShape(8.dp), colors = ButtonDefaults.buttonColors(containerColor = if (isUsed) Color.Gray else MaterialTheme.colorScheme.surfaceVariant), enabled = !isUsed) { Text("$c", fontSize = 20.sp, fontWeight = FontWeight.Bold) }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        OutlinedButton(onClick = { selected = emptyList() }) { Text("Clear") }
                        if (selected.size == currentWord.length) Button(onClick = { submit() }, colors = ButtonDefaults.buttonColors(containerColor = LanguageAccentColor)) { Text("Submit") }
                    }
                    Spacer(Modifier.weight(1f))
                } else {
                    FeedbackScreen(wasCorrect, "The word was: ${currentWord.uppercase()}") { next() }
                }
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, correct, 10, mockService, GameType.WORD_SCRAMBLE, LanguageAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0; correct = 0 }, onBack)
    }
}

// VERBAL ANALOGIES GAME
@Composable
fun VerbalAnalogiesGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    data class Analogy(val a: String, val b: String, val c: String, val options: List<String>, val correctIdx: Int, val rel: String)
    val analogies = listOf(
        Analogy("Hot", "Cold", "Up", listOf("Down", "High", "Sky", "Left"), 0, "Opposites"),
        Analogy("Dog", "Puppy", "Cat", listOf("Kitten", "Feline", "Pet", "Mouse"), 0, "Adult to young"),
        Analogy("Bird", "Fly", "Fish", listOf("Swim", "Water", "Fin", "Scale"), 0, "Animal to movement"),
        Analogy("Author", "Book", "Composer", listOf("Symphony", "Piano", "Conductor", "Note"), 0, "Creator to creation"),
        Analogy("Doctor", "Hospital", "Teacher", listOf("School", "Student", "Lesson", "Book"), 0, "Professional to workplace"),
        Analogy("Hammer", "Nail", "Screwdriver", listOf("Screw", "Tool", "Turn", "Fix"), 0, "Tool to object")
    )
    
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var round by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var correct by remember { mutableIntStateOf(0) }
    var analogy by remember { mutableStateOf(analogies[0]) }
    var selected by remember { mutableStateOf<Int?>(null) }
    var showFeedback by remember { mutableStateOf(false) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    fun generate() { analogy = analogies.random(); selected = null; showFeedback = false }

    fun submit() {
        val isCorrect = selected == analogy.correctIdx
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
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.VERBAL_ANALOGIES.name, score = score, maxPossibleScore = 210, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else { round++; if (round == 4) level = 2; if (round == 7) level = 3; generate() }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("↔️", "Verbal Analogies", "A is to B as C is to ?", LanguageAccentColor) { startTime = System.currentTimeMillis(); generate(); gameState = GameState.PLAYING }
        GameState.PLAYING -> {
            GameScaffold("Analogies", level, round, 10, score, LanguageAccentColor, onBack) {
                if (!showFeedback) {
                    Spacer(Modifier.weight(1f))
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        listOf(analogy.a, analogy.b).forEach { w -> Surface(shape = RoundedCornerShape(8.dp), color = LanguageAccentColor.copy(0.15f)) { Text(w, Modifier.padding(12.dp, 8.dp), fontWeight = FontWeight.Bold) } }
                    }
                    Text("::", style = MaterialTheme.typography.headlineMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        Surface(shape = RoundedCornerShape(8.dp), color = LanguageAccentColor.copy(0.15f)) { Text(analogy.c, Modifier.padding(12.dp, 8.dp), fontWeight = FontWeight.Bold) }
                        Surface(shape = RoundedCornerShape(8.dp), color = LanguageAccentColor.copy(0.3f)) { Text("?", Modifier.padding(12.dp, 8.dp), fontWeight = FontWeight.Bold) }
                    }
                    Spacer(Modifier.height(32.dp))
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        analogy.options.forEachIndexed { idx, opt ->
                            Card(Modifier.fillMaxWidth().clickable { selected = idx }, colors = CardDefaults.cardColors(containerColor = if (selected == idx) LanguageAccentColor.copy(0.2f) else MaterialTheme.colorScheme.surface)) {
                                Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                                    Text("${('A' + idx)}", fontWeight = FontWeight.Bold, color = LanguageAccentColor)
                                    Spacer(Modifier.width(12.dp))
                                    Text(opt)
                                }
                            }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    if (selected != null) Button(onClick = { submit() }, colors = ButtonDefaults.buttonColors(containerColor = LanguageAccentColor)) { Text("Submit") }
                    Spacer(Modifier.weight(1f))
                } else {
                    FeedbackScreen(selected == analogy.correctIdx, "${analogy.a} : ${analogy.b} :: ${analogy.c} : ${analogy.options[analogy.correctIdx]}", "Relationship: ${analogy.rel}") { next() }
                }
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, correct, 10, mockService, GameType.VERBAL_ANALOGIES, LanguageAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0; correct = 0 }, onBack)
    }
}

// VOCABULARY GAME
@Composable
fun VocabularyGame(
    profileId: String,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    data class VocabQ(val word: String, val pos: String, val options: List<String>, val correctIdx: Int, val example: String)
    val questions = listOf(
        VocabQ("Abundant", "adj", listOf("Plentiful", "Scarce", "Empty", "Broken"), 0, "The garden had abundant flowers."),
        VocabQ("Hesitate", "verb", listOf("Rush", "Pause", "Continue", "Finish"), 1, "Don't hesitate to ask."),
        VocabQ("Genuine", "adj", listOf("Fake", "Copied", "Real", "Similar"), 2, "A genuine smile."),
        VocabQ("Tranquil", "adj", listOf("Noisy", "Chaotic", "Peaceful", "Active"), 2, "The lake was tranquil."),
        VocabQ("Meticulous", "adj", listOf("Careless", "Thorough", "Quick", "Lazy"), 1, "Meticulous research."),
        VocabQ("Eloquent", "adj", listOf("Articulate", "Silent", "Confused", "Boring"), 0, "An eloquent speaker."),
        VocabQ("Benevolent", "adj", listOf("Cruel", "Kind", "Neutral", "Angry"), 1, "A benevolent king."),
        VocabQ("Ubiquitous", "adj", listOf("Rare", "Everywhere", "Hidden", "Unique"), 1, "Smartphones are ubiquitous.")
    )
    
    var gameState by remember { mutableStateOf(GameState.INSTRUCTIONS) }
    var level by remember { mutableIntStateOf(1) }
    var round by remember { mutableIntStateOf(1) }
    var score by remember { mutableIntStateOf(0) }
    var correct by remember { mutableIntStateOf(0) }
    var question by remember { mutableStateOf(questions[0]) }
    var selected by remember { mutableStateOf<Int?>(null) }
    var showFeedback by remember { mutableStateOf(false) }
    var startTime by remember { mutableLongStateOf(0L) }
    val scope = rememberCoroutineScope()
    
    fun generate() { question = questions.random(); selected = null; showFeedback = false }

    fun submit() {
        val isCorrect = selected == question.correctIdx
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
            scope.launch { repository.insertSession(GameSession(profileId = profileId, gameType = GameType.VOCABULARY.name, score = score, maxPossibleScore = 210, level = level, durationSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt())) }
            audioManager.playSoundEffect(SoundEffect.GAME_COMPLETE)
            hapticManager.gameComplete()
            gameState = GameState.GAME_OVER
        } else { round++; if (round == 4) level = 2; if (round == 7) level = 3; generate() }
    }
    
    when (gameState) {
        GameState.INSTRUCTIONS -> InstructionsScreen("📖", "Vocabulary", "Choose the correct meaning of the word.", LanguageAccentColor) { startTime = System.currentTimeMillis(); generate(); gameState = GameState.PLAYING }
        GameState.PLAYING -> {
            GameScaffold("Vocabulary", level, round, 10, score, LanguageAccentColor, onBack) {
                if (!showFeedback) {
                    Spacer(Modifier.weight(1f))
                    Text(question.word, style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.Bold, color = LanguageAccentColor)
                    Text(question.pos, style = MaterialTheme.typography.bodyMedium, fontStyle = androidx.compose.ui.text.font.FontStyle.Italic, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.height(32.dp))
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        question.options.forEachIndexed { idx, opt ->
                            Card(Modifier.fillMaxWidth().clickable { selected = idx }, colors = CardDefaults.cardColors(containerColor = if (selected == idx) LanguageAccentColor.copy(0.2f) else MaterialTheme.colorScheme.surface)) {
                                Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                                    Text("${('A' + idx)}", fontWeight = FontWeight.Bold, color = LanguageAccentColor)
                                    Spacer(Modifier.width(12.dp))
                                    Text(opt)
                                }
                            }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    if (selected != null) Button(onClick = { submit() }, colors = ButtonDefaults.buttonColors(containerColor = LanguageAccentColor)) { Text("Submit") }
                    Spacer(Modifier.weight(1f))
                } else {
                    FeedbackScreen(selected == question.correctIdx, "${question.word} means ${question.options[question.correctIdx]}", "Example: \"${question.example}\"") { next() }
                }
            }
        }
        GameState.FEEDBACK -> {}
        GameState.GAME_OVER -> GameOverScreen(score, correct, 10, mockService, GameType.VOCABULARY, LanguageAccentColor, { gameState = GameState.INSTRUCTIONS; level = 1; round = 1; score = 0; correct = 0 }, onBack)
    }
}
