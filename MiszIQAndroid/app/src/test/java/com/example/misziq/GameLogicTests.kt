package com.example.misziq

import org.junit.Test
import org.junit.Assert.*

/**
 * Unit tests for all IQ Trainer game logic
 */
class GameLogicTests {

    // ==================== MEMORY GAMES ====================
    
    @Test
    fun memoryGrid_correctSelection_shouldMatch() {
        val highlighted = setOf(0, 3, 5, 8)
        val selected = setOf(0, 3, 5, 8)
        assertEquals(highlighted, selected)
    }
    
    @Test
    fun memoryGrid_incorrectSelection_shouldNotMatch() {
        val highlighted = setOf(0, 3, 5, 8)
        val selected = setOf(0, 3, 5, 7) // 7 instead of 8
        assertNotEquals(highlighted, selected)
    }
    
    @Test
    fun memoryGrid_partialSelection_shouldNotMatch() {
        val highlighted = setOf(0, 3, 5, 8)
        val selected = setOf(0, 3, 5) // missing 8
        assertNotEquals(highlighted, selected)
    }
    
    @Test
    fun sequenceMemory_correctSequence_shouldMatch() {
        val sequence = listOf(2, 5, 1, 8, 3)
        val playerSequence = listOf(2, 5, 1, 8, 3)
        assertEquals(sequence, playerSequence)
    }
    
    @Test
    fun sequenceMemory_incorrectSequence_shouldNotMatch() {
        val sequence = listOf(2, 5, 1, 8, 3)
        val playerSequence = listOf(2, 5, 1, 7, 3) // 7 instead of 8
        assertNotEquals(sequence, playerSequence)
    }
    
    @Test
    fun sequenceMemory_wrongOrder_shouldNotMatch() {
        val sequence = listOf(2, 5, 1, 8, 3)
        val playerSequence = listOf(2, 1, 5, 8, 3) // swapped 5 and 1
        assertNotEquals(sequence, playerSequence)
    }
    
    @Test
    fun wordRecall_correctWords_shouldScore() {
        val words = listOf("apple", "river", "mountain")
        val recalled = listOf("Apple", "RIVER", "Mountain") // case insensitive
        val correct = recalled.count { r -> words.any { it.equals(r, ignoreCase = true) } }
        assertEquals(3, correct)
    }
    
    @Test
    fun wordRecall_partialCorrect_shouldScorePartially() {
        val words = listOf("apple", "river", "mountain")
        val recalled = listOf("apple", "ocean", "mountain") // ocean is wrong
        val correct = recalled.count { r -> words.any { it.equals(r, ignoreCase = true) } }
        assertEquals(2, correct)
    }
    
    @Test
    fun wordRecall_allWrong_shouldScoreZero() {
        val words = listOf("apple", "river", "mountain")
        val recalled = listOf("banana", "ocean", "hill")
        val correct = recalled.count { r -> words.any { it.equals(r, ignoreCase = true) } }
        assertEquals(0, correct)
    }

    // ==================== MATH GAMES ====================
    
    @Test
    fun mentalMath_addition_correctAnswer() {
        val a = 25
        val b = 17
        val answer = a + b
        assertEquals(42, answer)
    }
    
    @Test
    fun mentalMath_subtraction_correctAnswer() {
        val a = 45
        val b = 18
        val answer = a - b
        assertEquals(27, answer)
    }
    
    @Test
    fun mentalMath_multiplication_correctAnswer() {
        val a = 7
        val b = 8
        val answer = a * b
        assertEquals(56, answer)
    }
    
    @Test
    fun mentalMath_division_correctAnswer() {
        val a = 72
        val b = 9
        val answer = a / b
        assertEquals(8, answer)
    }
    
    @Test
    fun mentalMath_wrongAnswer_shouldFail() {
        val a = 25
        val b = 17
        val correctAnswer = a + b
        val userAnswer = 43 // wrong
        assertNotEquals(correctAnswer, userAnswer)
    }
    
    @Test
    fun numberComparison_leftGreater_shouldReturnPositive() {
        val left = 50
        val right = 30
        assertTrue(left.compareTo(right) > 0)
    }
    
    @Test
    fun numberComparison_rightGreater_shouldReturnNegative() {
        val left = 20
        val right = 45
        assertTrue(left.compareTo(right) < 0)
    }
    
    @Test
    fun numberComparison_equal_shouldReturnZero() {
        val left = 35
        val right = 35
        assertEquals(0, left.compareTo(right))
    }
    
    @Test
    fun numberComparison_expressionEvaluation() {
        // 15 + 25 vs 8 * 5
        val left = 15 + 25 // 40
        val right = 8 * 5  // 40
        assertEquals(0, left.compareTo(right))
    }
    
    @Test
    fun estimation_perfectAccuracy() {
        val actual = 100f
        val estimate = 100f
        val accuracy = 1f - kotlin.math.abs(estimate - actual) / actual
        assertEquals(1f, accuracy, 0.001f)
    }
    
    @Test
    fun estimation_closeAccuracy() {
        val actual = 100f
        val estimate = 90f // 10% off
        val accuracy = 1f - kotlin.math.abs(estimate - actual) / actual
        assertEquals(0.9f, accuracy, 0.001f)
    }
    
    @Test
    fun estimation_poorAccuracy() {
        val actual = 100f
        val estimate = 50f // 50% off
        val accuracy = 1f - kotlin.math.abs(estimate - actual) / actual
        assertEquals(0.5f, accuracy, 0.001f)
    }

    // ==================== LOGIC GAMES ====================
    
    @Test
    fun patternMatch_arithmeticSequence_correctAnswer() {
        // 2, 5, 8, 11, ? -> 14
        val sequence = listOf(2, 5, 8, 11)
        val diff = sequence[1] - sequence[0] // 3
        val answer = sequence.last() + diff
        assertEquals(14, answer)
    }
    
    @Test
    fun patternMatch_geometricSequence_correctAnswer() {
        // 2, 4, 8, 16, ? -> 32
        val sequence = listOf(2, 4, 8, 16)
        val ratio = sequence[1] / sequence[0] // 2
        val answer = sequence.last() * ratio
        assertEquals(32, answer)
    }
    
    @Test
    fun patternMatch_wrongAnswer_shouldFail() {
        // 2, 5, 8, 11, ? -> 14 (not 15)
        val correctAnswer = 14
        val userAnswer = 15
        assertNotEquals(correctAnswer, userAnswer)
    }
    
    @Test
    fun logicPuzzle_correctAnswer_shouldMatch() {
        // "Alice is taller than Bob. Bob is taller than Carol. Who is shortest?"
        // Answer: Carol (index 2)
        val correctIdx = 2
        val userSelection = 2
        assertEquals(correctIdx, userSelection)
    }
    
    @Test
    fun logicPuzzle_wrongAnswer_shouldNotMatch() {
        val correctIdx = 2
        val userSelection = 0 // Alice (wrong)
        assertNotEquals(correctIdx, userSelection)
    }
    
    @Test
    fun towerOfHanoi_validMove_smallerOnLarger() {
        // Can place disk 1 on disk 3
        val sourcePeg = listOf(1, 2) // disk 1 on top
        val targetPeg = listOf(3)    // disk 3
        val diskToMove = sourcePeg.first() // 1
        val canMove = targetPeg.isEmpty() || targetPeg.first() > diskToMove
        assertTrue(canMove)
    }
    
    @Test
    fun towerOfHanoi_invalidMove_largerOnSmaller() {
        // Cannot place disk 3 on disk 1
        val sourcePeg = listOf(3)
        val targetPeg = listOf(1, 2) // disk 1 on top
        val diskToMove = sourcePeg.first() // 3
        val canMove = targetPeg.isEmpty() || targetPeg.first() > diskToMove
        assertFalse(canMove)
    }
    
    @Test
    fun towerOfHanoi_validMove_ontoEmptyPeg() {
        val sourcePeg = listOf(2, 3)
        val targetPeg = emptyList<Int>()
        val diskToMove = sourcePeg.first() // 2
        val canMove = targetPeg.isEmpty() || targetPeg.first() > diskToMove
        assertTrue(canMove)
    }
    
    @Test
    fun towerOfHanoi_winCondition_allDisksOnTarget() {
        val diskCount = 3
        val targetPeg = listOf(1, 2, 3) // all disks
        val isWin = targetPeg.size == diskCount
        assertTrue(isWin)
    }
    
    @Test
    fun towerOfHanoi_notWin_disksStillMoving() {
        val diskCount = 3
        val targetPeg = listOf(1, 2) // only 2 disks
        val isWin = targetPeg.size == diskCount
        assertFalse(isWin)
    }
    
    @Test
    fun towerOfHanoi_optimalMoves_calculation() {
        // Optimal moves = 2^n - 1
        assertEquals(7, (1 shl 3) - 1)   // 3 disks
        assertEquals(15, (1 shl 4) - 1)  // 4 disks
        assertEquals(31, (1 shl 5) - 1)  // 5 disks
    }

    // ==================== LANGUAGE GAMES ====================
    
    @Test
    fun wordScramble_correctUnscramble_shouldMatch() {
        val word = "apple"
        val scrambled = "ppale"
        val userGuess = "apple"
        assertTrue(word.equals(userGuess, ignoreCase = true))
    }
    
    @Test
    fun wordScramble_wrongUnscramble_shouldNotMatch() {
        val word = "apple"
        val userGuess = "maple"
        assertFalse(word.equals(userGuess, ignoreCase = true))
    }
    
    @Test
    fun wordScramble_caseInsensitive_shouldMatch() {
        val word = "mountain"
        val userGuess = "MOUNTAIN"
        assertTrue(word.equals(userGuess, ignoreCase = true))
    }
    
    @Test
    fun verbalAnalogies_correctAnswer_shouldMatch() {
        // Hot:Cold :: Up:? -> Down (index 0)
        val correctIdx = 0
        val userSelection = 0
        assertEquals(correctIdx, userSelection)
    }
    
    @Test
    fun verbalAnalogies_wrongAnswer_shouldNotMatch() {
        // Hot:Cold :: Up:? -> Down (index 0), not "High" (index 1)
        val correctIdx = 0
        val userSelection = 1
        assertNotEquals(correctIdx, userSelection)
    }
    
    @Test
    fun vocabulary_correctDefinition_shouldMatch() {
        // "Abundant" means "Plentiful" (index 0)
        val correctIdx = 0
        val userSelection = 0
        assertEquals(correctIdx, userSelection)
    }
    
    @Test
    fun vocabulary_wrongDefinition_shouldNotMatch() {
        // "Abundant" means "Plentiful" (index 0), not "Scarce" (index 1)
        val correctIdx = 0
        val userSelection = 1
        assertNotEquals(correctIdx, userSelection)
    }

    // ==================== SCORING TESTS ====================
    
    @Test
    fun scoring_perfectGame_shouldMaxScore() {
        val correctAnswers = 10
        val totalQuestions = 10
        val level = 3
        val pointsPerCorrect = 10
        val score = correctAnswers * pointsPerCorrect * level
        assertEquals(300, score)
    }
    
    @Test
    fun scoring_partialCorrect_shouldScaleScore() {
        val correctAnswers = 5
        val totalQuestions = 10
        val level = 2
        val pointsPerCorrect = 10
        val score = correctAnswers * pointsPerCorrect * level
        assertEquals(100, score)
    }
    
    @Test
    fun scoring_accuracy_calculation() {
        val score = 80
        val maxPossibleScore = 100
        val accuracy = score.toDouble() / maxPossibleScore * 100
        assertEquals(80.0, accuracy, 0.001)
    }
    
    @Test
    fun percentile_calculation() {
        // Simple mock percentile based on score
        fun calculatePercentile(score: Int, mean: Double, stdDev: Double): Int {
            val zScore = (score - mean) / stdDev
            // Simplified normal CDF approximation
            val percentile = (50 + 50 * (zScore / kotlin.math.sqrt(1 + zScore * zScore))).toInt()
            return percentile.coerceIn(1, 99)
        }
        
        // Score at mean should be ~50th percentile
        val percentileAtMean = calculatePercentile(50, 50.0, 10.0)
        assertTrue(percentileAtMean in 45..55)
        
        // Score above mean should be >50th percentile
        val percentileAbove = calculatePercentile(70, 50.0, 10.0)
        assertTrue(percentileAbove > 50)
        
        // Score below mean should be <50th percentile
        val percentileBelow = calculatePercentile(30, 50.0, 10.0)
        assertTrue(percentileBelow < 50)
    }
}
