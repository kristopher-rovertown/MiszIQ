import Foundation
import SwiftData

// MARK: - User Profile Model
@Model
final class UserProfile {
    var id: UUID
    var name: String
    var avatarEmoji: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \GameSession.profile)
    var sessions: [GameSession]

    @Relationship(deleteRule: .cascade, inverse: \Badge.profile)
    var badges: [Badge]

    @Relationship(deleteRule: .cascade, inverse: \DifficultyUnlock.profile)
    var difficultyUnlocks: [DifficultyUnlock]

    init(name: String, avatarEmoji: String = "🧠") {
        self.id = UUID()
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.createdAt = Date()
        self.sessions = []
        self.badges = []
        self.difficultyUnlocks = []
    }
}

// MARK: - Badge Model
@Model
final class Badge {
    var id: UUID
    var badgeType: String
    var unlockedAt: Date

    var profile: UserProfile?

    init(badgeType: BadgeType) {
        self.id = UUID()
        self.badgeType = badgeType.rawValue
        self.unlockedAt = Date()
    }

    var type: BadgeType? {
        BadgeType(rawValue: badgeType)
    }
}

// MARK: - Difficulty Unlock Model
@Model
final class DifficultyUnlock {
    var id: UUID
    var gameType: String
    var level: Int
    var unlockedAt: Date

    var profile: UserProfile?

    init(gameType: GameType, level: Int) {
        self.id = UUID()
        self.gameType = gameType.rawValue
        self.level = level
        self.unlockedAt = Date()
    }

    var game: GameType? {
        GameType(rawValue: gameType)
    }
}

// MARK: - Badge Type Definitions
enum BadgeType: String, CaseIterable, Identifiable {
    // Milestones
    case firstSteps = "first_steps"
    case gettingStarted = "getting_started"
    case dedicated = "dedicated"
    case committed = "committed"
    case legend = "legend"

    // Streaks
    case onTrack = "on_track"
    case consistent = "consistent"
    case persistent = "persistent"
    case unstoppable = "unstoppable"

    // Performance
    case perfectionist = "perfectionist"

    // Category Mastery
    case memoryMaster = "memory_master"
    case mathWhiz = "math_whiz"
    case logicLegend = "logic_legend"
    case wordWizard = "word_wizard"

    // Percentile
    case risingStar = "rising_star"
    case elite = "elite"
    case champion = "champion"
    case genius = "genius"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .firstSteps: return "First Steps"
        case .gettingStarted: return "Getting Started"
        case .dedicated: return "Dedicated"
        case .committed: return "Committed"
        case .legend: return "Legend"
        case .onTrack: return "On Track"
        case .consistent: return "Consistent"
        case .persistent: return "Persistent"
        case .unstoppable: return "Unstoppable"
        case .perfectionist: return "Perfectionist"
        case .memoryMaster: return "Memory Master"
        case .mathWhiz: return "Math Whiz"
        case .logicLegend: return "Logic Legend"
        case .wordWizard: return "Word Wizard"
        case .risingStar: return "Rising Star"
        case .elite: return "Elite"
        case .champion: return "Champion"
        case .genius: return "Genius"
        }
    }

    var description: String {
        switch self {
        case .firstSteps: return "Complete your first game"
        case .gettingStarted: return "Complete 10 games"
        case .dedicated: return "Complete 50 games"
        case .committed: return "Complete 100 games"
        case .legend: return "Complete 500 games"
        case .onTrack: return "Maintain a 3-day streak"
        case .consistent: return "Maintain a 7-day streak"
        case .persistent: return "Maintain a 14-day streak"
        case .unstoppable: return "Maintain a 30-day streak"
        case .perfectionist: return "Achieve 100% accuracy in any game"
        case .memoryMaster: return "Score 80%+ in all Memory games"
        case .mathWhiz: return "Score 80%+ in all Math games"
        case .logicLegend: return "Score 80%+ in all Logic games"
        case .wordWizard: return "Score 80%+ in all Language games"
        case .risingStar: return "Reach top 25% in any game"
        case .elite: return "Reach top 10% in any game"
        case .champion: return "Reach top 5% in any game"
        case .genius: return "Reach top 1% in any game"
        }
    }

    var emoji: String {
        switch self {
        case .firstSteps: return "🎯"
        case .gettingStarted: return "🌟"
        case .dedicated: return "💪"
        case .committed: return "🔥"
        case .legend: return "👑"
        case .onTrack: return "📅"
        case .consistent: return "🗓️"
        case .persistent: return "📆"
        case .unstoppable: return "⚡"
        case .perfectionist: return "✨"
        case .memoryMaster: return "🧠"
        case .mathWhiz: return "🔢"
        case .logicLegend: return "🧩"
        case .wordWizard: return "📚"
        case .risingStar: return "⭐"
        case .elite: return "🌟"
        case .champion: return "🏆"
        case .genius: return "💎"
        }
    }

    var category: BadgeCategory {
        switch self {
        case .firstSteps, .gettingStarted, .dedicated, .committed, .legend:
            return .milestone
        case .onTrack, .consistent, .persistent, .unstoppable:
            return .streak
        case .perfectionist:
            return .performance
        case .memoryMaster, .mathWhiz, .logicLegend, .wordWizard:
            return .mastery
        case .risingStar, .elite, .champion, .genius:
            return .percentile
        }
    }
}

enum BadgeCategory: String, CaseIterable {
    case milestone = "Milestones"
    case streak = "Streaks"
    case performance = "Performance"
    case mastery = "Mastery"
    case percentile = "Rankings"
}

// MARK: - Game Session Model
@Model
final class GameSession {
    var id: UUID
    var gameType: String
    var score: Int
    var maxPossibleScore: Int
    var level: Int
    var completedAt: Date
    var durationSeconds: Int
    
    var profile: UserProfile?
    
    init(gameType: GameType, score: Int, maxPossibleScore: Int, level: Int, durationSeconds: Int) {
        self.id = UUID()
        self.gameType = gameType.rawValue
        self.score = score
        self.maxPossibleScore = maxPossibleScore
        self.level = level
        self.completedAt = Date()
        self.durationSeconds = durationSeconds
    }
    
    var accuracy: Double {
        guard maxPossibleScore > 0 else { return 0 }
        let rawAccuracy = Double(score) / Double(maxPossibleScore) * 100
        return min(rawAccuracy, 100.0)  // Cap at 100%
    }
    
    var game: GameType {
        GameType(rawValue: gameType) ?? .memoryGrid
    }
}

// MARK: - Game Category
enum GameCategory: String, CaseIterable, Identifiable {
    case memory = "Memory"
    case mentalMath = "Mental Math"
    case problemSolving = "Problem Solving"
    case language = "Language"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .memory: return "🧠"
        case .mentalMath: return "🔢"
        case .problemSolving: return "🧩"
        case .language: return "📚"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .memory: return "brain.head.profile"
        case .mentalMath: return "number"
        case .problemSolving: return "puzzlepiece.fill"
        case .language: return "textformat"
        }
    }
    
    var color: String {
        // Unified theme - all categories use the same accent color
        return "accent"
    }
    
    var games: [GameType] {
        switch self {
        case .memory:
            return [.memoryGrid, .sequenceMemory, .wordRecall]
        case .mentalMath:
            return [.mentalMath, .numberComparison, .estimation]
        case .problemSolving:
            return [.patternMatch, .logicPuzzle, .towerOfHanoi]
        case .language:
            return [.wordScramble, .verbalAnalogies, .vocabulary]
        }
    }
}

// MARK: - Game Types
enum GameType: String, CaseIterable, Identifiable {
    // Memory
    case memoryGrid = "Memory Grid"
    case sequenceMemory = "Sequence Memory"
    case wordRecall = "Word Recall"
    
    // Mental Math
    case mentalMath = "Mental Math"
    case numberComparison = "Number Compare"
    case estimation = "Estimation"
    
    // Problem Solving
    case patternMatch = "Pattern Match"
    case logicPuzzle = "Logic Puzzle"
    case towerOfHanoi = "Tower of Hanoi"
    
    // Language
    case wordScramble = "Word Scramble"
    case verbalAnalogies = "Analogies"
    case vocabulary = "Vocabulary"
    
    var id: String { rawValue }
    
    var category: GameCategory {
        switch self {
        case .memoryGrid, .sequenceMemory, .wordRecall:
            return .memory
        case .mentalMath, .numberComparison, .estimation:
            return .mentalMath
        case .patternMatch, .logicPuzzle, .towerOfHanoi:
            return .problemSolving
        case .wordScramble, .verbalAnalogies, .vocabulary:
            return .language
        }
    }
    
    var icon: String {
        switch self {
        case .memoryGrid: return "🔲"
        case .sequenceMemory: return "🔀"
        case .wordRecall: return "📝"
        case .mentalMath: return "➕"
        case .numberComparison: return "⚖️"
        case .estimation: return "🎯"
        case .patternMatch: return "🔢"
        case .logicPuzzle: return "💡"
        case .towerOfHanoi: return "🗼"
        case .wordScramble: return "🔤"
        case .verbalAnalogies: return "↔️"
        case .vocabulary: return "📖"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .memoryGrid: return "square.grid.3x3.fill"
        case .sequenceMemory: return "arrow.triangle.branch"
        case .wordRecall: return "list.bullet.clipboard"
        case .mentalMath: return "plus.forwardslash.minus"
        case .numberComparison: return "lessthan.circle"
        case .estimation: return "eye.trianglebadge.exclamationmark"
        case .patternMatch: return "rectangle.pattern.checkered"
        case .logicPuzzle: return "lightbulb"
        case .towerOfHanoi: return "square.3.layers.3d"
        case .wordScramble: return "textformat.abc"
        case .verbalAnalogies: return "arrow.left.arrow.right"
        case .vocabulary: return "character.book.closed"
        }
    }
    
    var description: String {
        switch self {
        case .memoryGrid: return "Remember the positions of highlighted tiles"
        case .sequenceMemory: return "Repeat the sequence of lights"
        case .wordRecall: return "Memorize and recall a list of words"
        case .mentalMath: return "Solve arithmetic problems quickly"
        case .numberComparison: return "Compare expressions quickly"
        case .estimation: return "Estimate quantities and values"
        case .patternMatch: return "Find the pattern that completes the sequence"
        case .logicPuzzle: return "Solve logical reasoning problems"
        case .towerOfHanoi: return "Move all disks to the target peg"
        case .wordScramble: return "Unscramble letters to form words"
        case .verbalAnalogies: return "Complete word relationships"
        case .vocabulary: return "Test your word knowledge"
        }
    }
    
    var color: String {
        category.color
    }
}

// MARK: - Statistics Helper
struct GameStatistics {
    let averageScore: Double
    let highScore: Int
    let totalGamesPlayed: Int
    let averageAccuracy: Double
    let percentile: Int
    let recentTrend: Trend
    
    enum Trend {
        case improving, declining, stable
        
        var icon: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .declining: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
        
        var color: String {
            switch self {
            case .improving: return "green"
            case .declining: return "red"
            case .stable: return "gray"
            }
        }
    }
    
    static func calculate(from sessions: [GameSession], gameType: GameType, mockService: MockDataService) -> GameStatistics {
        let gameSessions = sessions.filter { $0.gameType == gameType.rawValue }
        
        guard !gameSessions.isEmpty else {
            return GameStatistics(
                averageScore: 0,
                highScore: 0,
                totalGamesPlayed: 0,
                averageAccuracy: 0,
                percentile: 50,
                recentTrend: .stable
            )
        }
        
        let scores = gameSessions.map { $0.score }
        let averageScore = Double(scores.reduce(0, +)) / Double(scores.count)
        let highScore = scores.max() ?? 0
        let averageAccuracy = min(gameSessions.map { $0.accuracy }.reduce(0, +) / Double(gameSessions.count), 100.0)
        
        let percentile = mockService.calculatePercentile(score: Int(averageScore), for: gameType)
        
        let trend: Trend
        if gameSessions.count >= 3 {
            let sortedSessions = gameSessions.sorted { $0.completedAt < $1.completedAt }
            let recentScores = sortedSessions.suffix(5).map { $0.score }
            let olderScores = sortedSessions.prefix(max(1, sortedSessions.count - 5)).map { $0.score }
            
            let recentAvg = Double(recentScores.reduce(0, +)) / Double(recentScores.count)
            let olderAvg = Double(olderScores.reduce(0, +)) / Double(olderScores.count)
            
            if recentAvg > olderAvg * 1.1 {
                trend = .improving
            } else if recentAvg < olderAvg * 0.9 {
                trend = .declining
            } else {
                trend = .stable
            }
        } else {
            trend = .stable
        }
        
        return GameStatistics(
            averageScore: averageScore,
            highScore: highScore,
            totalGamesPlayed: gameSessions.count,
            averageAccuracy: averageAccuracy,
            percentile: percentile,
            recentTrend: trend
        )
    }
}
