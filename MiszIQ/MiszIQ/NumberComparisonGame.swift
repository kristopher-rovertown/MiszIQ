import SwiftUI
import SwiftData

struct NumberComparisonGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var leftExpression: Expression?
    @State private var rightExpression: Expression?
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var correctAnswers = 0
    @State private var selectedAnswer: ComparisonResult? = nil
    @State private var showFeedback = false
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    
    enum GameState {
        case instructions, playing, feedback, gameOver
    }
    
    enum ComparisonResult {
        case less, equal, greater
        
        var symbol: String {
            switch self {
            case .less: return "<"
            case .equal: return "="
            case .greater: return ">"
            }
        }
    }
    
    struct Expression {
        let display: String
        let value: Int
        
        static func generate(level: Int) -> Expression {
            switch level {
            case 1:
                // Simple numbers or basic addition
                if Bool.random() {
                    let n = Int.random(in: 10...99)
                    return Expression(display: "\(n)", value: n)
                } else {
                    let a = Int.random(in: 5...30)
                    let b = Int.random(in: 5...30)
                    return Expression(display: "\(a) + \(b)", value: a + b)
                }
            case 2:
                // Addition, subtraction, simple multiplication
                let ops = ["+", "-", "×"]
                let op = ops.randomElement()!
                let a = Int.random(in: 5...25)
                let b = op == "×" ? Int.random(in: 2...9) : Int.random(in: 5...25)
                let value: Int
                switch op {
                case "+": value = a + b
                case "-": value = a - b
                default: value = a * b
                }
                return Expression(display: "\(a) \(op) \(b)", value: value)
            default:
                // Complex expressions
                let type = Int.random(in: 0...3)
                switch type {
                case 0:
                    let a = Int.random(in: 10...50)
                    let b = Int.random(in: 5...20)
                    let c = Int.random(in: 5...20)
                    return Expression(display: "\(a) + \(b) - \(c)", value: a + b - c)
                case 1:
                    let a = Int.random(in: 2...9)
                    let b = Int.random(in: 2...9)
                    let c = Int.random(in: 1...10)
                    return Expression(display: "\(a) × \(b) + \(c)", value: a * b + c)
                case 2:
                    let a = Int.random(in: 2...12)
                    return Expression(display: "\(a)²", value: a * a)
                default:
                    let a = Int.random(in: 20...100)
                    let b = Int.random(in: 2...9)
                    let value = a / b * b // Make it divisible
                    return Expression(display: "\(value) ÷ \(b)", value: value / b)
                }
            }
        }
    }
    
    var timeLimit: Int {
        switch level {
        case 1: return 8
        case 2: return 6
        default: return 5
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(level)")
                        .font(.headline)
                    Text("Round \(round)/10")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.title2.bold())
                    .foregroundStyle(Color.royalBlue)
            }
            .padding(.horizontal)
            
            Spacer()
            
            switch gameState {
            case .instructions:
                instructionsView
            case .playing:
                gameView
            case .feedback:
                feedbackView
            case .gameOver:
                gameOverView
            }
            
            Spacer()
        }
        .navigationTitle("Number Compare")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "lessthan.circle")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Number Compare")
                .font(.title.bold())
            
            Text("Compare the two expressions and select <, =, or > to show their relationship. Be quick!")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button {
                startGame()
            } label: {
                Text("Start Game")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.royalBlue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 24) {
            // Timer bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(timerColor.gradient)
                        .frame(width: geometry.size.width * CGFloat(timeRemaining) / CGFloat(timeLimit), height: 8)
                        .animation(.linear(duration: 1), value: timeRemaining)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)
            
            // Expressions
            HStack(spacing: 16) {
                // Left expression
                VStack {
                    Text(leftExpression?.display ?? "")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Question mark
                Text("?")
                    .font(.title.bold())
                    .foregroundStyle(.secondary)
                
                // Right expression
                VStack {
                    Text(rightExpression?.display ?? "")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 5)
            }
            .padding(.horizontal)
            
            // Answer buttons
            HStack(spacing: 20) {
                ForEach([ComparisonResult.less, .equal, .greater], id: \.symbol) { result in
                    Button {
                        selectAnswer(result)
                    } label: {
                        Text(result.symbol)
                            .font(.system(size: 36, weight: .bold))
                            .frame(width: 80, height: 80)
                            .background(Color.royalBlue)
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private var feedbackView: some View {
        let correctResult = getCorrectResult()
        let isCorrect = selectedAnswer == correctResult
        
        return VStack(spacing: 24) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(isCorrect ? .green : .red)
            
            Text(isCorrect ? "Correct!" : "Not quite...")
                .font(.title.bold())
            
            // Show the solution
            HStack(spacing: 8) {
                Text(leftExpression?.display ?? "")
                    .font(.title3.bold())
                Text("(\(leftExpression?.value ?? 0))")
                    .foregroundStyle(.secondary)
                Text(correctResult.symbol)
                    .font(.title2.bold())
                    .foregroundStyle(Color.royalBlue)
                Text(rightExpression?.display ?? "")
                    .font(.title3.bold())
                Text("(\(rightExpression?.value ?? 0))")
                    .foregroundStyle(.secondary)
            }
            
            Button {
                nextRound()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.royalBlue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var gameOverView: some View {
        let percentile = mockService.calculatePercentile(score: score, for: .numberComparison)
        let bracket = mockService.getPerformanceBracket(percentile: percentile)
        
        return VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
            
            Text("Game Complete!")
                .font(.title.bold())
            
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.royalBlue)
            }
            
            Text("\(correctAnswers)/10 Correct")
                .font(.headline)
            
            VStack(spacing: 4) {
                Text("\(percentile)th Percentile")
                    .font(.headline)
                Text(bracket.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.royalBlue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack(spacing: 16) {
                Button {
                    resetGame()
                } label: {
                    Text("Play Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.royalBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var timerColor: Color {
        if timeRemaining <= 2 {
            return .red
        } else if timeRemaining <= 4 {
            return .orange
        }
        return .green
    }
    
    private func getCorrectResult() -> ComparisonResult {
        guard let left = leftExpression, let right = rightExpression else { return .equal }
        if left.value < right.value { return .less }
        if left.value > right.value { return .greater }
        return .equal
    }
    
    private func startGame() {
        startTime = Date()
        generateRound()
        gameState = .playing
        startTimer()
    }
    
    private func generateRound() {
        leftExpression = Expression.generate(level: level)
        rightExpression = Expression.generate(level: level)
        selectedAnswer = nil
    }
    
    private func startTimer() {
        timeRemaining = timeLimit
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                selectAnswer(nil)
            }
        }
    }
    
    private func selectAnswer(_ answer: ComparisonResult?) {
        timer?.invalidate()
        selectedAnswer = answer

        let correct = getCorrectResult()
        if answer == correct {
            correctAnswers += 1
            score += 10 * level
            if timeRemaining > timeLimit / 2 {
                score += 5 // Speed bonus
            }
            AudioManager.shared.playSoundEffect(.correctAnswer)
            HapticManager.shared.correctAnswer()
        } else {
            AudioManager.shared.playSoundEffect(.wrongAnswer)
            HapticManager.shared.wrongAnswer()
        }

        gameState = .feedback
    }
    
    private func nextRound() {
        if round >= 10 {
            saveSession()
            gameState = .gameOver
        } else {
            round += 1
            if round == 4 { level = 2 }
            if round == 7 { level = 3 }
            generateRound()
            gameState = .playing
            startTimer()
        }
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = GameSession(
            gameType: .numberComparison,
            score: score,
            maxPossibleScore: 260,  // 3×15 + 3×25 + 4×35 = 260 (includes speed bonus)
            level: level,
            durationSeconds: duration
        )
        session.profile = profile
        modelContext.insert(session)

        AudioManager.shared.playSoundEffect(.gameComplete)
        HapticManager.shared.gameComplete()
    }
    
    private func resetGame() {
        level = 1
        round = 1
        score = 0
        correctAnswers = 0
        startTime = Date()
        gameState = .instructions
    }
}

#Preview {
    NavigationStack {
        NumberComparisonGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
