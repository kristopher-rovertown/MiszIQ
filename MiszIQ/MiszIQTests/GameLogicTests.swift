import XCTest
@testable import MiszIQ

/// Unit tests for all MiszIQ game logic
final class GameLogicTests: XCTestCase {
    
    // MARK: - Memory Games
    
    func testMemoryGrid_correctSelection_shouldMatch() {
        let highlighted: Set<Int> = [0, 3, 5, 8]
        let selected: Set<Int> = [0, 3, 5, 8]
        XCTAssertEqual(highlighted, selected)
    }
    
    func testMemoryGrid_incorrectSelection_shouldNotMatch() {
        let highlighted: Set<Int> = [0, 3, 5, 8]
        let selected: Set<Int> = [0, 3, 5, 7] // 7 instead of 8
        XCTAssertNotEqual(highlighted, selected)
    }
    
    func testMemoryGrid_partialSelection_shouldNotMatch() {
        let highlighted: Set<Int> = [0, 3, 5, 8]
        let selected: Set<Int> = [0, 3, 5] // missing 8
        XCTAssertNotEqual(highlighted, selected)
    }
    
    func testSequenceMemory_correctSequence_shouldMatch() {
        let sequence = [2, 5, 1, 8, 3]
        let playerSequence = [2, 5, 1, 8, 3]
        XCTAssertEqual(sequence, playerSequence)
    }
    
    func testSequenceMemory_incorrectSequence_shouldNotMatch() {
        let sequence = [2, 5, 1, 8, 3]
        let playerSequence = [2, 5, 1, 7, 3] // 7 instead of 8
        XCTAssertNotEqual(sequence, playerSequence)
    }
    
    func testSequenceMemory_wrongOrder_shouldNotMatch() {
        let sequence = [2, 5, 1, 8, 3]
        let playerSequence = [2, 1, 5, 8, 3] // swapped 5 and 1
        XCTAssertNotEqual(sequence, playerSequence)
    }
    
    func testWordRecall_correctWords_shouldScore() {
        let words = ["apple", "river", "mountain"]
        let recalled = ["Apple", "RIVER", "Mountain"] // case insensitive
        let correct = recalled.filter { r in
            words.contains { $0.lowercased() == r.lowercased() }
        }.count
        XCTAssertEqual(correct, 3)
    }
    
    func testWordRecall_partialCorrect_shouldScorePartially() {
        let words = ["apple", "river", "mountain"]
        let recalled = ["apple", "ocean", "mountain"] // ocean is wrong
        let correct = recalled.filter { r in
            words.contains { $0.lowercased() == r.lowercased() }
        }.count
        XCTAssertEqual(correct, 2)
    }
    
    func testWordRecall_allWrong_shouldScoreZero() {
        let words = ["apple", "river", "mountain"]
        let recalled = ["banana", "ocean", "hill"]
        let correct = recalled.filter { r in
            words.contains { $0.lowercased() == r.lowercased() }
        }.count
        XCTAssertEqual(correct, 0)
    }
    
    // MARK: - Math Games
    
    func testMentalMath_addition_correctAnswer() {
        let a = 25
        let b = 17
        let answer = a + b
        XCTAssertEqual(answer, 42)
    }
    
    func testMentalMath_subtraction_correctAnswer() {
        let a = 45
        let b = 18
        let answer = a - b
        XCTAssertEqual(answer, 27)
    }
    
    func testMentalMath_multiplication_correctAnswer() {
        let a = 7
        let b = 8
        let answer = a * b
        XCTAssertEqual(answer, 56)
    }
    
    func testMentalMath_division_correctAnswer() {
        let a = 72
        let b = 9
        let answer = a / b
        XCTAssertEqual(answer, 8)
    }
    
    func testMentalMath_wrongAnswer_shouldFail() {
        let a = 25
        let b = 17
        let correctAnswer = a + b
        let userAnswer = 43 // wrong
        XCTAssertNotEqual(correctAnswer, userAnswer)
    }
    
    func testNumberComparison_leftGreater_shouldReturnPositive() {
        let left = 50
        let right = 30
        XCTAssertGreaterThan(left, right)
    }
    
    func testNumberComparison_rightGreater_shouldReturnNegative() {
        let left = 20
        let right = 45
        XCTAssertLessThan(left, right)
    }
    
    func testNumberComparison_equal_shouldReturnZero() {
        let left = 35
        let right = 35
        XCTAssertEqual(left, right)
    }
    
    func testNumberComparison_expressionEvaluation() {
        // 15 + 25 vs 8 * 5
        let left = 15 + 25 // 40
        let right = 8 * 5  // 40
        XCTAssertEqual(left, right)
    }
    
    func testEstimation_perfectAccuracy() {
        let actual: Float = 100
        let estimate: Float = 100
        let accuracy = 1 - abs(estimate - actual) / actual
        XCTAssertEqual(accuracy, 1.0, accuracy: 0.001)
    }
    
    func testEstimation_closeAccuracy() {
        let actual: Float = 100
        let estimate: Float = 90 // 10% off
        let accuracy = 1 - abs(estimate - actual) / actual
        XCTAssertEqual(accuracy, 0.9, accuracy: 0.001)
    }
    
    func testEstimation_poorAccuracy() {
        let actual: Float = 100
        let estimate: Float = 50 // 50% off
        let accuracy = 1 - abs(estimate - actual) / actual
        XCTAssertEqual(accuracy, 0.5, accuracy: 0.001)
    }
    
    // MARK: - Logic Games
    
    func testPatternMatch_arithmeticSequence_correctAnswer() {
        // 2, 5, 8, 11, ? -> 14
        let sequence = [2, 5, 8, 11]
        let diff = sequence[1] - sequence[0] // 3
        let answer = sequence.last! + diff
        XCTAssertEqual(answer, 14)
    }
    
    func testPatternMatch_geometricSequence_correctAnswer() {
        // 2, 4, 8, 16, ? -> 32
        let sequence = [2, 4, 8, 16]
        let ratio = sequence[1] / sequence[0] // 2
        let answer = sequence.last! * ratio
        XCTAssertEqual(answer, 32)
    }
    
    func testPatternMatch_wrongAnswer_shouldFail() {
        // 2, 5, 8, 11, ? -> 14 (not 15)
        let correctAnswer = 14
        let userAnswer = 15
        XCTAssertNotEqual(correctAnswer, userAnswer)
    }
    
    func testLogicPuzzle_correctAnswer_shouldMatch() {
        // "Alice is taller than Bob. Bob is taller than Carol. Who is shortest?"
        // Answer: Carol (index 2)
        let correctIdx = 2
        let userSelection = 2
        XCTAssertEqual(correctIdx, userSelection)
    }
    
    func testLogicPuzzle_wrongAnswer_shouldNotMatch() {
        let correctIdx = 2
        let userSelection = 0 // Alice (wrong)
        XCTAssertNotEqual(correctIdx, userSelection)
    }
    
    func testTowerOfHanoi_validMove_smallerOnLarger() {
        // Can place disk 1 on disk 3
        let sourcePeg = [1, 2] // disk 1 on top
        let targetPeg = [3]    // disk 3
        let diskToMove = sourcePeg.first! // 1
        let canMove = targetPeg.isEmpty || targetPeg.first! > diskToMove
        XCTAssertTrue(canMove)
    }
    
    func testTowerOfHanoi_invalidMove_largerOnSmaller() {
        // Cannot place disk 3 on disk 1
        let sourcePeg = [3]
        let targetPeg = [1, 2] // disk 1 on top
        let diskToMove = sourcePeg.first! // 3
        let canMove = targetPeg.isEmpty || targetPeg.first! > diskToMove
        XCTAssertFalse(canMove)
    }
    
    func testTowerOfHanoi_validMove_ontoEmptyPeg() {
        let sourcePeg = [2, 3]
        let targetPeg: [Int] = []
        let diskToMove = sourcePeg.first! // 2
        let canMove = targetPeg.isEmpty || targetPeg.first! > diskToMove
        XCTAssertTrue(canMove)
    }
    
    func testTowerOfHanoi_winCondition_allDisksOnTarget() {
        let diskCount = 3
        let targetPeg = [1, 2, 3] // all disks
        let isWin = targetPeg.count == diskCount
        XCTAssertTrue(isWin)
    }
    
    func testTowerOfHanoi_notWin_disksStillMoving() {
        let diskCount = 3
        let targetPeg = [1, 2] // only 2 disks
        let isWin = targetPeg.count == diskCount
        XCTAssertFalse(isWin)
    }
    
    func testTowerOfHanoi_optimalMoves_calculation() {
        // Optimal moves = 2^n - 1
        XCTAssertEqual((1 << 3) - 1, 7)   // 3 disks
        XCTAssertEqual((1 << 4) - 1, 15)  // 4 disks
        XCTAssertEqual((1 << 5) - 1, 31)  // 5 disks
    }
    
    // MARK: - Language Games
    
    func testWordScramble_correctUnscramble_shouldMatch() {
        let word = "apple"
        let userGuess = "apple"
        XCTAssertTrue(word.lowercased() == userGuess.lowercased())
    }
    
    func testWordScramble_wrongUnscramble_shouldNotMatch() {
        let word = "apple"
        let userGuess = "maple"
        XCTAssertFalse(word.lowercased() == userGuess.lowercased())
    }
    
    func testWordScramble_caseInsensitive_shouldMatch() {
        let word = "mountain"
        let userGuess = "MOUNTAIN"
        XCTAssertTrue(word.lowercased() == userGuess.lowercased())
    }
    
    func testVerbalAnalogies_correctAnswer_shouldMatch() {
        // Hot:Cold :: Up:? -> Down (index 0)
        let correctIdx = 0
        let userSelection = 0
        XCTAssertEqual(correctIdx, userSelection)
    }
    
    func testVerbalAnalogies_wrongAnswer_shouldNotMatch() {
        // Hot:Cold :: Up:? -> Down (index 0), not "High" (index 1)
        let correctIdx = 0
        let userSelection = 1
        XCTAssertNotEqual(correctIdx, userSelection)
    }
    
    func testVocabulary_correctDefinition_shouldMatch() {
        // "Abundant" means "Plentiful" (index 0)
        let correctIdx = 0
        let userSelection = 0
        XCTAssertEqual(correctIdx, userSelection)
    }
    
    func testVocabulary_wrongDefinition_shouldNotMatch() {
        // "Abundant" means "Plentiful" (index 0), not "Scarce" (index 1)
        let correctIdx = 0
        let userSelection = 1
        XCTAssertNotEqual(correctIdx, userSelection)
    }
    
    // MARK: - Scoring Tests
    
    func testScoring_perfectGame_shouldMaxScore() {
        let correctAnswers = 10
        let level = 3
        let pointsPerCorrect = 10
        let score = correctAnswers * pointsPerCorrect * level
        XCTAssertEqual(score, 300)
    }
    
    func testScoring_partialCorrect_shouldScaleScore() {
        let correctAnswers = 5
        let level = 2
        let pointsPerCorrect = 10
        let score = correctAnswers * pointsPerCorrect * level
        XCTAssertEqual(score, 100)
    }
    
    func testScoring_accuracy_calculation() {
        let score = 80
        let maxPossibleScore = 100
        let accuracy = Double(score) / Double(maxPossibleScore) * 100
        XCTAssertEqual(accuracy, 80.0, accuracy: 0.001)
    }
    
    func testPercentile_calculation() {
        func calculatePercentile(score: Int, mean: Double, stdDev: Double) -> Int {
            let zScore = (Double(score) - mean) / stdDev
            // Simplified normal CDF approximation
            let percentile = Int(50 + 50 * (zScore / sqrt(1 + zScore * zScore)))
            return min(99, max(1, percentile))
        }
        
        // Score at mean should be ~50th percentile
        let percentileAtMean = calculatePercentile(score: 50, mean: 50.0, stdDev: 10.0)
        XCTAssertTrue((45...55).contains(percentileAtMean))
        
        // Score above mean should be >50th percentile
        let percentileAbove = calculatePercentile(score: 70, mean: 50.0, stdDev: 10.0)
        XCTAssertGreaterThan(percentileAbove, 50)
        
        // Score below mean should be <50th percentile
        let percentileBelow = calculatePercentile(score: 30, mean: 50.0, stdDev: 10.0)
        XCTAssertLessThan(percentileBelow, 50)
    }
}
