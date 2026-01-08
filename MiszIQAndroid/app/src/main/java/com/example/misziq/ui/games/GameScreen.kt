package com.example.misziq.ui.games

import androidx.compose.runtime.Composable
import com.example.misziq.audio.AudioManager
import com.example.misziq.data.model.GameType
import com.example.misziq.data.model.MockDataService
import com.example.misziq.data.repository.MiszIQRepository
import com.example.misziq.haptics.HapticManager

@Composable
fun GameScreen(
    profileId: String,
    gameType: GameType,
    repository: MiszIQRepository,
    mockService: MockDataService,
    audioManager: AudioManager,
    hapticManager: HapticManager,
    onBack: () -> Unit
) {
    when (gameType) {
        GameType.MEMORY_GRID -> MemoryGridGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.SEQUENCE_MEMORY -> SequenceMemoryGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.WORD_RECALL -> WordRecallGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.MENTAL_MATH -> MentalMathGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.NUMBER_COMPARISON -> NumberComparisonGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.ESTIMATION -> EstimationGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.PATTERN_MATCH -> PatternMatchGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.LOGIC_PUZZLE -> LogicPuzzleGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.TOWER_OF_HANOI -> TowerOfHanoiGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.WORD_SCRAMBLE -> WordScrambleGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.VERBAL_ANALOGIES -> VerbalAnalogiesGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
        GameType.VOCABULARY -> VocabularyGame(profileId, repository, mockService, audioManager, hapticManager, onBack)
    }
}
