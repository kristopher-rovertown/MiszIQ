import Foundation

/// Service that provides mock population data for percentile calculations
class MockDataService: ObservableObject {
    // Mock score distributions for each game type (mean, std deviation)
    private let scoreDistributions: [GameType: (mean: Double, stdDev: Double)] = [
        // Memory
        .memoryGrid: (mean: 65, stdDev: 20),
        .sequenceMemory: (mean: 8, stdDev: 3),
        .wordRecall: (mean: 12, stdDev: 4),
        
        // Mental Math
        .mentalMath: (mean: 55, stdDev: 25),
        .numberComparison: (mean: 70, stdDev: 15),
        .estimation: (mean: 60, stdDev: 20),
        
        // Problem Solving
        .patternMatch: (mean: 70, stdDev: 18),
        .logicPuzzle: (mean: 50, stdDev: 20),
        .towerOfHanoi: (mean: 40, stdDev: 15),
        
        // Language
        .wordScramble: (mean: 65, stdDev: 18),
        .verbalAnalogies: (mean: 55, stdDev: 20),
        .vocabulary: (mean: 60, stdDev: 22)
    ]
    
    /// Calculate the percentile rank for a given score
    func calculatePercentile(score: Int, for gameType: GameType) -> Int {
        guard let distribution = scoreDistributions[gameType] else { return 50 }
        
        let zScore = (Double(score) - distribution.mean) / distribution.stdDev
        let percentile = normalCDF(zScore) * 100
        
        return min(99, max(1, Int(percentile)))
    }
    
    /// Get mock leaderboard data
    func getLeaderboardData(for gameType: GameType, count: Int = 10) -> [(rank: Int, name: String, score: Int)] {
        guard let distribution = scoreDistributions[gameType] else { return [] }
        
        let names = ["Alex", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Quinn", "Avery", "Sage", "Phoenix",
                     "Dakota", "Reese", "Skyler", "Charlie", "Drew", "Emery", "Finley", "Harper", "Jamie", "Kennedy"]
        
        var scores: [(rank: Int, name: String, score: Int)] = []
        for i in 0..<count {
            let percentile = 99.0 - Double(i) * (50.0 / Double(count))
            let score = Int(distribution.mean + distribution.stdDev * inverseNormalCDF(percentile / 100))
            scores.append((rank: i + 1, name: names[i % names.count], score: score))
        }
        
        return scores
    }
    
    /// Get performance brackets
    func getPerformanceBracket(percentile: Int) -> (name: String, color: String, description: String) {
        switch percentile {
        case 95...100:
            return ("Exceptional", "purple", "Top 5% of all players")
        case 85..<95:
            return ("Advanced", "blue", "Top 15% of all players")
        case 70..<85:
            return ("Proficient", "green", "Above average performance")
        case 40..<70:
            return ("Average", "orange", "Typical performance range")
        case 20..<40:
            return ("Developing", "yellow", "Room for improvement")
        default:
            return ("Beginner", "gray", "Just getting started")
        }
    }
    
    // MARK: - Statistical Functions
    
    private func normalCDF(_ x: Double) -> Double {
        return 0.5 * (1 + erf(x / sqrt(2)))
    }
    
    private func erf(_ x: Double) -> Double {
        let a1 =  0.254829592
        let a2 = -0.284496736
        let a3 =  1.421413741
        let a4 = -1.453152027
        let a5 =  1.061405429
        let p  =  0.3275911
        
        let sign = x < 0 ? -1.0 : 1.0
        let absX = abs(x)
        
        let t = 1.0 / (1.0 + p * absX)
        let y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-absX * absX)
        
        return sign * y
    }
    
    private func inverseNormalCDF(_ p: Double) -> Double {
        if p <= 0 { return -3 }
        if p >= 1 { return 3 }
        
        if p < 0.5 {
            return -rationalApproximation(sqrt(-2.0 * log(p)))
        } else {
            return rationalApproximation(sqrt(-2.0 * log(1 - p)))
        }
    }
    
    private func rationalApproximation(_ t: Double) -> Double {
        let c0 = 2.515517
        let c1 = 0.802853
        let c2 = 0.010328
        let d1 = 1.432788
        let d2 = 0.189269
        let d3 = 0.001308
        
        return t - ((c2 * t + c1) * t + c0) / (((d3 * t + d2) * t + d1) * t + 1.0)
    }
}
