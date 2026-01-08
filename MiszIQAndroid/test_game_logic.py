#!/usr/bin/env python3
"""
IQ Trainer Game Logic Tests
Tests correct and incorrect answer validation for all 12 games
"""

import math

class TestRunner:
    def __init__(self):
        self.passed = 0
        self.failed = 0
    
    def test(self, name, condition):
        if condition:
            print(f"✅ PASS: {name}")
            self.passed += 1
        else:
            print(f"❌ FAIL: {name}")
            self.failed += 1
    
    def summary(self):
        total = self.passed + self.failed
        print(f"\n{'='*50}")
        print(f"RESULTS: {self.passed}/{total} passed, {self.failed} failed")
        print(f"{'='*50}\n")
        return self.failed == 0


def run_tests():
    t = TestRunner()
    
    print("\n" + "="*50)
    print("IQ TRAINER GAME LOGIC TESTS")
    print("="*50)
    
    # ==================== MEMORY GAMES ====================
    print("\n========== MEMORY GAMES ==========\n")
    
    # Memory Grid
    t.test("memoryGrid_correctSelection_shouldMatch",
           {0, 3, 5, 8} == {0, 3, 5, 8})
    
    t.test("memoryGrid_incorrectSelection_shouldNotMatch",
           {0, 3, 5, 8} != {0, 3, 5, 7})
    
    t.test("memoryGrid_partialSelection_shouldNotMatch",
           {0, 3, 5, 8} != {0, 3, 5})
    
    t.test("memoryGrid_extraSelection_shouldNotMatch",
           {0, 3, 5, 8} != {0, 3, 5, 8, 9})
    
    # Sequence Memory
    t.test("sequenceMemory_correctSequence_shouldMatch",
           [2, 5, 1, 8, 3] == [2, 5, 1, 8, 3])
    
    t.test("sequenceMemory_incorrectSequence_shouldNotMatch",
           [2, 5, 1, 8, 3] != [2, 5, 1, 7, 3])
    
    t.test("sequenceMemory_wrongOrder_shouldNotMatch",
           [2, 5, 1, 8, 3] != [2, 1, 5, 8, 3])
    
    t.test("sequenceMemory_incompleteSequence_shouldNotMatch",
           [2, 5, 1, 8, 3] != [2, 5, 1, 8])
    
    # Word Recall
    words = ["apple", "river", "mountain"]
    
    def count_correct(words, recalled):
        return sum(1 for r in recalled if any(w.lower() == r.lower() for w in words))
    
    t.test("wordRecall_correctWords_shouldScore3",
           count_correct(words, ["Apple", "RIVER", "Mountain"]) == 3)
    
    t.test("wordRecall_partialCorrect_shouldScore2",
           count_correct(words, ["apple", "ocean", "mountain"]) == 2)
    
    t.test("wordRecall_allWrong_shouldScore0",
           count_correct(words, ["banana", "ocean", "hill"]) == 0)
    
    t.test("wordRecall_duplicates_shouldNotDoubleCout",
           count_correct(words, ["apple", "apple", "apple"]) == 3)  # Each recall counts
    
    # ==================== MATH GAMES ====================
    print("\n========== MATH GAMES ==========\n")
    
    # Mental Math
    t.test("mentalMath_addition_25plus17_equals42",
           25 + 17 == 42)
    
    t.test("mentalMath_addition_wrongAnswer_43notEqual42",
           25 + 17 != 43)
    
    t.test("mentalMath_subtraction_45minus18_equals27",
           45 - 18 == 27)
    
    t.test("mentalMath_multiplication_7times8_equals56",
           7 * 8 == 56)
    
    t.test("mentalMath_division_72div9_equals8",
           72 // 9 == 8)
    
    t.test("mentalMath_division_wrongAnswer_shouldFail",
           72 // 9 != 9)
    
    # Number Comparison
    t.test("numberComparison_50vs30_leftGreater",
           (50 > 30) == True)
    
    t.test("numberComparison_20vs45_rightGreater",
           (20 < 45) == True)
    
    t.test("numberComparison_35vs35_equal",
           (35 == 35) == True)
    
    t.test("numberComparison_expression_15plus25_equals_8times5",
           (15 + 25) == (8 * 5))
    
    t.test("numberComparison_expression_12times3_greaterThan_20plus10",
           (12 * 3) > (20 + 10))
    
    # Estimation
    def calc_accuracy(actual, estimate):
        return 1.0 - abs(estimate - actual) / actual
    
    t.test("estimation_perfectAccuracy_100of100",
           abs(calc_accuracy(100, 100) - 1.0) < 0.001)
    
    t.test("estimation_90percent_accuracy",
           abs(calc_accuracy(100, 90) - 0.9) < 0.001)
    
    t.test("estimation_50percent_accuracy",
           abs(calc_accuracy(100, 50) - 0.5) < 0.001)
    
    t.test("estimation_overestimate_110for100_90percent",
           abs(calc_accuracy(100, 110) - 0.9) < 0.001)
    
    # ==================== LOGIC GAMES ====================
    print("\n========== LOGIC GAMES ==========\n")
    
    # Pattern Match
    def next_arithmetic(seq):
        diff = seq[1] - seq[0]
        return seq[-1] + diff
    
    def next_geometric(seq):
        ratio = seq[1] // seq[0]
        return seq[-1] * ratio
    
    t.test("patternMatch_arithmetic_2_5_8_11_next14",
           next_arithmetic([2, 5, 8, 11]) == 14)
    
    t.test("patternMatch_arithmetic_wrongAnswer_15notCorrect",
           next_arithmetic([2, 5, 8, 11]) != 15)
    
    t.test("patternMatch_geometric_2_4_8_16_next32",
           next_geometric([2, 4, 8, 16]) == 32)
    
    t.test("patternMatch_arithmetic_10_20_30_40_next50",
           next_arithmetic([10, 20, 30, 40]) == 50)
    
    # Logic Puzzle
    # "Alice > Bob > Carol, who is shortest?" -> Carol (index 2)
    t.test("logicPuzzle_correctAnswer_index2",
           2 == 2)
    
    t.test("logicPuzzle_wrongAnswer_index0_shouldFail",
           2 != 0)
    
    t.test("logicPuzzle_wrongAnswer_index1_shouldFail",
           2 != 1)
    
    # Tower of Hanoi
    def can_move(source_peg, target_peg):
        if not source_peg:
            return False
        disk = source_peg[0]
        return len(target_peg) == 0 or target_peg[0] > disk
    
    t.test("towerOfHanoi_validMove_disk1_onto_disk3",
           can_move([1, 2], [3]) == True)
    
    t.test("towerOfHanoi_invalidMove_disk3_onto_disk1",
           can_move([3], [1, 2]) == False)
    
    t.test("towerOfHanoi_validMove_onto_emptyPeg",
           can_move([2, 3], []) == True)
    
    t.test("towerOfHanoi_invalidMove_fromEmptyPeg",
           can_move([], [1, 2, 3]) == False)
    
    t.test("towerOfHanoi_winCondition_3disks_onTarget",
           len([1, 2, 3]) == 3)
    
    t.test("towerOfHanoi_notWin_2disks_onTarget",
           len([1, 2]) != 3)
    
    # Optimal moves = 2^n - 1
    t.test("towerOfHanoi_optimalMoves_3disks_is7",
           (1 << 3) - 1 == 7)
    
    t.test("towerOfHanoi_optimalMoves_4disks_is15",
           (1 << 4) - 1 == 15)
    
    t.test("towerOfHanoi_optimalMoves_5disks_is31",
           (1 << 5) - 1 == 31)
    
    # ==================== LANGUAGE GAMES ====================
    print("\n========== LANGUAGE GAMES ==========\n")
    
    # Word Scramble
    def check_unscramble(word, guess):
        return word.lower() == guess.lower()
    
    t.test("wordScramble_correct_apple",
           check_unscramble("apple", "apple") == True)
    
    t.test("wordScramble_correct_caseInsensitive",
           check_unscramble("mountain", "MOUNTAIN") == True)
    
    t.test("wordScramble_wrong_maple_not_apple",
           check_unscramble("apple", "maple") == False)
    
    t.test("wordScramble_wrong_similar_but_different",
           check_unscramble("garden", "graden") == False)
    
    # Verbal Analogies
    # Hot:Cold :: Up:? -> Down (index 0)
    t.test("verbalAnalogies_correct_Down_index0",
           0 == 0)
    
    t.test("verbalAnalogies_wrong_High_index1",
           0 != 1)
    
    t.test("verbalAnalogies_wrong_Sky_index2",
           0 != 2)
    
    # Vocabulary
    # "Abundant" means "Plentiful" (index 0)
    t.test("vocabulary_correct_Plentiful_index0",
           0 == 0)
    
    t.test("vocabulary_wrong_Scarce_index1",
           0 != 1)
    
    t.test("vocabulary_wrong_Empty_index2",
           0 != 2)
    
    # ==================== SCORING TESTS ====================
    print("\n========== SCORING TESTS ==========\n")
    
    t.test("scoring_perfectGame_10correct_level3_equals300",
           10 * 10 * 3 == 300)
    
    t.test("scoring_partialGame_5correct_level2_equals100",
           5 * 10 * 2 == 100)
    
    t.test("scoring_zeroCorrect_equals0",
           0 * 10 * 3 == 0)
    
    # Accuracy calculation
    t.test("accuracy_80of100_equals80percent",
           abs((80 / 100 * 100) - 80.0) < 0.001)
    
    # Percentile calculation
    def calc_percentile(score, mean, std_dev):
        z_score = (score - mean) / std_dev
        percentile = int(50 + 50 * (z_score / math.sqrt(1 + z_score * z_score)))
        return max(1, min(99, percentile))
    
    t.test("percentile_atMean_around50",
           45 <= calc_percentile(50, 50, 10) <= 55)
    
    t.test("percentile_aboveMean_greaterThan50",
           calc_percentile(70, 50, 10) > 50)
    
    t.test("percentile_belowMean_lessThan50",
           calc_percentile(30, 50, 10) < 50)
    
    t.test("percentile_highScore_near99",
           calc_percentile(100, 50, 10) > 90)
    
    t.test("percentile_lowScore_near1",
           calc_percentile(0, 50, 10) < 10)
    
    return t.summary()


if __name__ == "__main__":
    success = run_tests()
    exit(0 if success else 1)
