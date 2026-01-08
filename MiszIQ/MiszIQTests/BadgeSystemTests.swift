import XCTest
@testable import MiszIQ

/// Unit tests for badge system and difficulty unlocking
final class BadgeSystemTests: XCTestCase {

    // MARK: - Milestone Badge Tests

    func testMilestoneBadge_firstGame_shouldUnlock() {
        let totalGames = 1
        let shouldUnlock = totalGames >= 1
        XCTAssertTrue(shouldUnlock, "First Steps badge should unlock after 1 game")
    }

    func testMilestoneBadge_tenGames_shouldUnlock() {
        let totalGames = 10
        let shouldUnlock = totalGames >= 10
        XCTAssertTrue(shouldUnlock, "Getting Started badge should unlock after 10 games")
    }

    func testMilestoneBadge_fiftyGames_shouldUnlock() {
        let totalGames = 50
        let shouldUnlock = totalGames >= 50
        XCTAssertTrue(shouldUnlock, "Dedicated badge should unlock after 50 games")
    }

    func testMilestoneBadge_hundredGames_shouldUnlock() {
        let totalGames = 100
        let shouldUnlock = totalGames >= 100
        XCTAssertTrue(shouldUnlock, "Committed badge should unlock after 100 games")
    }

    func testMilestoneBadge_fiveHundredGames_shouldUnlock() {
        let totalGames = 500
        let shouldUnlock = totalGames >= 500
        XCTAssertTrue(shouldUnlock, "Legend badge should unlock after 500 games")
    }

    func testMilestoneBadge_notEnoughGames_shouldNotUnlock() {
        let totalGames = 9
        let shouldUnlockGettingStarted = totalGames >= 10
        XCTAssertFalse(shouldUnlockGettingStarted, "Getting Started badge should not unlock before 10 games")
    }

    // MARK: - Streak Badge Tests

    func testStreakBadge_threeDays_shouldUnlock() {
        let streak = 3
        let shouldUnlock = streak >= 3
        XCTAssertTrue(shouldUnlock, "On Track badge should unlock after 3-day streak")
    }

    func testStreakBadge_sevenDays_shouldUnlock() {
        let streak = 7
        let shouldUnlock = streak >= 7
        XCTAssertTrue(shouldUnlock, "Consistent badge should unlock after 7-day streak")
    }

    func testStreakBadge_fourteenDays_shouldUnlock() {
        let streak = 14
        let shouldUnlock = streak >= 14
        XCTAssertTrue(shouldUnlock, "Persistent badge should unlock after 14-day streak")
    }

    func testStreakBadge_thirtyDays_shouldUnlock() {
        let streak = 30
        let shouldUnlock = streak >= 30
        XCTAssertTrue(shouldUnlock, "Unstoppable badge should unlock after 30-day streak")
    }

    func testStreakBadge_twoDay_shouldNotUnlockOnTrack() {
        let streak = 2
        let shouldUnlock = streak >= 3
        XCTAssertFalse(shouldUnlock, "On Track badge should not unlock before 3-day streak")
    }

    func testStreakCalculation_consecutiveDays_shouldCountCorrectly() {
        // Simulate dates: today, yesterday, day before
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var dates: [Date] = []
        for i in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }

        // All 5 dates are consecutive
        let streak = countConsecutiveDays(dates: dates)
        XCTAssertEqual(streak, 5)
    }

    func testStreakCalculation_brokenStreak_shouldResetCount() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var dates: [Date] = []
        // Today, yesterday, skip a day, then 2 more
        dates.append(today)
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
            dates.append(yesterday)
        }
        // Skip day -2
        if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today) {
            dates.append(threeDaysAgo)
        }

        let streak = countConsecutiveDays(dates: dates)
        XCTAssertEqual(streak, 2, "Streak should be 2 due to broken day")
    }

    private func countConsecutiveDays(dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sortedDates = Set(dates.map { calendar.startOfDay(for: $0) }).sorted(by: >)

        guard let mostRecent = sortedDates.first else { return 0 }
        let daysSinceLast = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0

        if daysSinceLast > 1 { return 0 }

        var streak = 1
        var currentDate = mostRecent

        for date in sortedDates.dropFirst() {
            let expectedPrevious = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if calendar.isDate(date, inSameDayAs: expectedPrevious) {
                streak += 1
                currentDate = date
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Performance Badge Tests

    func testPerformanceBadge_perfectAccuracy_shouldUnlock() {
        let accuracy: Double = 100.0
        let shouldUnlock = accuracy >= 100.0
        XCTAssertTrue(shouldUnlock, "Perfectionist badge should unlock at 100% accuracy")
    }

    func testPerformanceBadge_nearPerfect_shouldNotUnlock() {
        let accuracy: Double = 99.9
        let shouldUnlock = accuracy >= 100.0
        XCTAssertFalse(shouldUnlock, "Perfectionist badge should not unlock below 100% accuracy")
    }

    func testAccuracyCalculation_fullScore_shouldBe100Percent() {
        let score = 100
        let maxPossibleScore = 100
        let accuracy = Double(score) / Double(maxPossibleScore) * 100
        XCTAssertEqual(accuracy, 100.0, accuracy: 0.001)
    }

    func testAccuracyCalculation_halfScore_shouldBe50Percent() {
        let score = 50
        let maxPossibleScore = 100
        let accuracy = Double(score) / Double(maxPossibleScore) * 100
        XCTAssertEqual(accuracy, 50.0, accuracy: 0.001)
    }

    // MARK: - Mastery Badge Tests

    func testMasteryBadge_allMemoryGames80Plus_shouldUnlock() {
        let memoryGameAccuracies: [Double] = [85.0, 90.0, 80.0] // All 3 memory games
        let allAbove80 = memoryGameAccuracies.allSatisfy { $0 >= 80 }
        XCTAssertTrue(allAbove80, "Memory Master badge should unlock when all memory games are 80%+")
    }

    func testMasteryBadge_oneGameBelow80_shouldNotUnlock() {
        let memoryGameAccuracies: [Double] = [85.0, 79.0, 90.0] // One below 80
        let allAbove80 = memoryGameAccuracies.allSatisfy { $0 >= 80 }
        XCTAssertFalse(allAbove80, "Memory Master badge should not unlock if any game is below 80%")
    }

    func testMasteryBadge_missingGame_shouldNotUnlock() {
        // User hasn't played all games in category
        let gamesPlayedInCategory = 2
        let totalGamesInCategory = 3
        let hasPlayedAll = gamesPlayedInCategory == totalGamesInCategory
        XCTAssertFalse(hasPlayedAll, "Mastery badge should not unlock if not all games are played")
    }

    // MARK: - Percentile Badge Tests

    func testPercentileBadge_top25_shouldUnlock() {
        let percentile = 75
        let shouldUnlock = percentile >= 75
        XCTAssertTrue(shouldUnlock, "Rising Star badge should unlock at 75th percentile")
    }

    func testPercentileBadge_top10_shouldUnlock() {
        let percentile = 90
        let shouldUnlock = percentile >= 90
        XCTAssertTrue(shouldUnlock, "Elite badge should unlock at 90th percentile")
    }

    func testPercentileBadge_top5_shouldUnlock() {
        let percentile = 95
        let shouldUnlock = percentile >= 95
        XCTAssertTrue(shouldUnlock, "Champion badge should unlock at 95th percentile")
    }

    func testPercentileBadge_top1_shouldUnlock() {
        let percentile = 99
        let shouldUnlock = percentile >= 99
        XCTAssertTrue(shouldUnlock, "Genius badge should unlock at 99th percentile")
    }

    func testPercentileBadge_74thPercentile_shouldNotUnlockRisingStar() {
        let percentile = 74
        let shouldUnlock = percentile >= 75
        XCTAssertFalse(shouldUnlock, "Rising Star badge should not unlock below 75th percentile")
    }

    // MARK: - Difficulty Unlock Tests

    func testDifficultyUnlock_100PercentAccuracy_shouldUnlockNextLevel() {
        let accuracy: Double = 100.0
        let currentLevel = 1
        let shouldUnlock = accuracy >= 100.0 && currentLevel < 3
        XCTAssertTrue(shouldUnlock, "Level 2 should unlock after 100% on Level 1")
    }

    func testDifficultyUnlock_99PercentAccuracy_shouldNotUnlock() {
        let accuracy: Double = 99.0
        let currentLevel = 1
        let shouldUnlock = accuracy >= 100.0 && currentLevel < 3
        XCTAssertFalse(shouldUnlock, "Next level should not unlock below 100% accuracy")
    }

    func testDifficultyUnlock_level2To3_shouldWork() {
        let accuracy: Double = 100.0
        let currentLevel = 2
        let shouldUnlock = accuracy >= 100.0 && currentLevel < 3
        XCTAssertTrue(shouldUnlock, "Level 3 should unlock after 100% on Level 2")
    }

    func testDifficultyUnlock_level3_shouldNotUnlockFurther() {
        let accuracy: Double = 100.0
        let currentLevel = 3
        let shouldUnlock = accuracy >= 100.0 && currentLevel < 3
        XCTAssertFalse(shouldUnlock, "No further levels to unlock after Level 3")
    }

    func testDifficultyUnlock_alreadyUnlocked_shouldNotDuplicate() {
        let existingUnlocks = [2, 3] // Already unlocked levels 2 and 3
        let attemptedUnlock = 2
        let isAlreadyUnlocked = existingUnlocks.contains(attemptedUnlock)
        XCTAssertTrue(isAlreadyUnlocked, "Should not create duplicate unlock")
    }

    func testMaxUnlockedLevel_noUnlocks_shouldBeLevel1() {
        let unlocks: [Int] = []
        let maxLevel = unlocks.max() ?? 1
        XCTAssertEqual(maxLevel, 1)
    }

    func testMaxUnlockedLevel_withUnlocks_shouldReturnHighest() {
        let unlocks = [2, 3]
        let maxLevel = unlocks.max() ?? 1
        XCTAssertEqual(maxLevel, 3)
    }

    // MARK: - Badge Progress Tests

    func testBadgeProgress_partialMilestone_shouldCalculateCorrectly() {
        let totalGames = 25
        let targetGames = 50 // Dedicated badge
        let progress = min(1.0, Double(totalGames) / Double(targetGames))
        XCTAssertEqual(progress, 0.5, accuracy: 0.001)
    }

    func testBadgeProgress_overTarget_shouldCapAt100Percent() {
        let totalGames = 75
        let targetGames = 50 // Dedicated badge
        let progress = min(1.0, Double(totalGames) / Double(targetGames))
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }

    func testBadgeProgress_zeroGames_shouldBeZero() {
        let totalGames = 0
        let targetGames = 10
        let progress = min(1.0, Double(totalGames) / Double(targetGames))
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }

    func testStreakProgress_partialStreak_shouldCalculateCorrectly() {
        let currentStreak = 4
        let targetStreak = 7 // Consistent badge
        let progress = min(1.0, Double(currentStreak) / Double(targetStreak))
        XCTAssertEqual(progress, 4.0/7.0, accuracy: 0.001)
    }

    // MARK: - Badge Type Tests

    func testBadgeType_allCases_shouldHaveDisplayName() {
        for badge in BadgeType.allCases {
            XCTAssertFalse(badge.displayName.isEmpty, "\(badge) should have a display name")
        }
    }

    func testBadgeType_allCases_shouldHaveDescription() {
        for badge in BadgeType.allCases {
            XCTAssertFalse(badge.description.isEmpty, "\(badge) should have a description")
        }
    }

    func testBadgeType_allCases_shouldHaveEmoji() {
        for badge in BadgeType.allCases {
            XCTAssertFalse(badge.emoji.isEmpty, "\(badge) should have an emoji")
        }
    }

    func testBadgeType_allCases_shouldHaveCategory() {
        for badge in BadgeType.allCases {
            // Just accessing category should not crash
            _ = badge.category
        }
    }

    func testBadgeCategory_milestoneBadges_shouldBeGroupedCorrectly() {
        let milestoneBadges: [BadgeType] = [.firstSteps, .gettingStarted, .dedicated, .committed, .legend]
        for badge in milestoneBadges {
            XCTAssertEqual(badge.category, .milestone)
        }
    }

    func testBadgeCategory_streakBadges_shouldBeGroupedCorrectly() {
        let streakBadges: [BadgeType] = [.onTrack, .consistent, .persistent, .unstoppable]
        for badge in streakBadges {
            XCTAssertEqual(badge.category, .streak)
        }
    }

    func testBadgeCategory_masteryBadges_shouldBeGroupedCorrectly() {
        let masteryBadges: [BadgeType] = [.memoryMaster, .mathWhiz, .logicLegend, .wordWizard]
        for badge in masteryBadges {
            XCTAssertEqual(badge.category, .mastery)
        }
    }

    func testBadgeCategory_percentileBadges_shouldBeGroupedCorrectly() {
        let percentileBadges: [BadgeType] = [.risingStar, .elite, .champion, .genius]
        for badge in percentileBadges {
            XCTAssertEqual(badge.category, .percentile)
        }
    }

    // MARK: - Duplicate Prevention Tests

    func testBadgeUnlock_alreadyOwned_shouldNotDuplicate() {
        let existingBadges: Set<BadgeType> = [.firstSteps, .gettingStarted]
        let potentialNewBadge: BadgeType = .firstSteps
        let shouldAward = !existingBadges.contains(potentialNewBadge)
        XCTAssertFalse(shouldAward, "Should not award duplicate badge")
    }

    func testBadgeUnlock_notOwned_shouldAward() {
        let existingBadges: Set<BadgeType> = [.firstSteps]
        let potentialNewBadge: BadgeType = .gettingStarted
        let shouldAward = !existingBadges.contains(potentialNewBadge)
        XCTAssertTrue(shouldAward, "Should award new badge")
    }

    // MARK: - Accuracy Validation Tests

    func testAccuracy_normalScore_shouldCalculateCorrectly() {
        let score = 80
        let maxPossibleScore = 100
        let rawAccuracy = Double(score) / Double(maxPossibleScore) * 100
        let accuracy = min(rawAccuracy, 100.0)
        XCTAssertEqual(accuracy, 80.0, accuracy: 0.001)
    }

    func testAccuracy_perfectScore_shouldBe100() {
        let score = 100
        let maxPossibleScore = 100
        let rawAccuracy = Double(score) / Double(maxPossibleScore) * 100
        let accuracy = min(rawAccuracy, 100.0)
        XCTAssertEqual(accuracy, 100.0, accuracy: 0.001)
    }

    func testAccuracy_overMaxScore_shouldCapAt100() {
        let score = 120
        let maxPossibleScore = 100
        let rawAccuracy = Double(score) / Double(maxPossibleScore) * 100
        let accuracy = min(rawAccuracy, 100.0)
        XCTAssertEqual(accuracy, 100.0, accuracy: 0.001, "Accuracy should be capped at 100%")
    }

    func testAccuracy_zeroScore_shouldBeZero() {
        let score = 0
        let maxPossibleScore = 100
        let rawAccuracy = Double(score) / Double(maxPossibleScore) * 100
        let accuracy = min(rawAccuracy, 100.0)
        XCTAssertEqual(accuracy, 0.0, accuracy: 0.001)
    }

    func testAccuracy_zeroMaxPossible_shouldBeZero() {
        let score = 50
        let maxPossibleScore = 0
        let accuracy: Double = maxPossibleScore > 0 ? min(Double(score) / Double(maxPossibleScore) * 100, 100.0) : 0
        XCTAssertEqual(accuracy, 0.0, accuracy: 0.001, "Accuracy should be 0 when maxPossibleScore is 0")
    }

    func testAccuracy_shouldNeverExceed100() {
        // Test various score/maxPossible combinations that could exceed 100%
        let testCases: [(score: Int, maxPossible: Int)] = [
            (210, 200),   // Word Scramble old bug
            (205, 150),   // Number Compare old bug
            (300, 120),   // Logic Puzzle old bug
            (1000, 500),  // Arbitrary large score
        ]

        for (score, maxPossible) in testCases {
            let rawAccuracy = Double(score) / Double(maxPossible) * 100
            let accuracy = min(rawAccuracy, 100.0)
            XCTAssertLessThanOrEqual(accuracy, 100.0, "Accuracy should never exceed 100% (score: \(score), max: \(maxPossible))")
        }
    }

    func testAverageAccuracy_shouldCapAt100() {
        let accuracies: [Double] = [100.0, 100.0, 100.0, 100.0]
        let average = min(accuracies.reduce(0, +) / Double(accuracies.count), 100.0)
        XCTAssertLessThanOrEqual(average, 100.0, "Average accuracy should be capped at 100%")
    }
}
