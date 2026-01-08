import SwiftUI
import SwiftData

struct MentalMathGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var currentProblem: MathProblem?
    @State private var userAnswer = ""
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var correctAnswers = 0
    @State private var showFeedback = false
    @State private var wasCorrect = false
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    
    enum GameState {
        case instructions, playing, feedback, gameOver
    }
    
    struct MathProblem {
        let num1: Int
        let num2: Int
        let operation: Operation
        let answer: Int
        
        enum Operation: String, CaseIterable {
            case add = "+"
            case subtract = "-"
            case multiply = "×"
            case divide = "÷"
        }
        
        var displayString: String {
            "\(num1) \(operation.rawValue) \(num2)"
        }
    }
    
    var timeLimit: Int {
        // Time decreases as level increases: 15s -> 12s -> 10s -> 8s -> 6s
        return max(6, 16 - level * 2)
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
        .navigationTitle("Mental Math")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "plus.forwardslash.minus")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Mental Math")
                .font(.title.bold())
            
            Text("Solve arithmetic problems as quickly as you can. Answer before time runs out!")
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
            // Timer
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(timeLimit))
                    .stroke(timerColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)
                
                Text("\(timeRemaining)")
                    .font(.title.bold())
                    .foregroundStyle(timerColor)
            }
            
            // Problem
            if let problem = currentProblem {
                Text(problem.displayString)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // Answer input
            VStack(spacing: 16) {
                TextField("Your answer", text: $userAnswer)
                    .font(.title)
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 60)
                
                Button {
                    submitAnswer()
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(userAnswer.isEmpty ? .gray : .orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(userAnswer.isEmpty)
                .padding(.horizontal, 40)
            }
            
            // Number pad for easier input
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(1...9, id: \.self) { num in
                    NumberPadButton(number: "\(num)") {
                        userAnswer += "\(num)"
                    }
                }
                NumberPadButton(number: "-") {
                    if userAnswer.isEmpty {
                        userAnswer = "-"
                    }
                }
                NumberPadButton(number: "0") {
                    userAnswer += "0"
                }
                NumberPadButton(number: "⌫") {
                    if !userAnswer.isEmpty {
                        userAnswer.removeLast()
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var feedbackView: some View {
        VStack(spacing: 24) {
            Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(wasCorrect ? .green : .red)
            
            Text(wasCorrect ? "Correct!" : "Not quite...")
                .font(.title.bold())
            
            if let problem = currentProblem {
                Text("\(problem.displayString) = \(problem.answer)")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            if wasCorrect {
                Text("+\(10 * level) points")
                    .font(.headline)
                    .foregroundStyle(.green)
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
        let percentile = mockService.calculatePercentile(score: score, for: .mentalMath)
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
        if timeRemaining <= 3 {
            return .red
        } else if timeRemaining <= 5 {
            return .orange
        }
        return .green
    }
    
    private func startGame() {
        startTime = Date()
        generateProblem()
        gameState = .playing
        startTimer()
    }
    
    private func generateProblem() {
        userAnswer = ""
        
        let operations: [MathProblem.Operation]
        var maxNum: Int
        var minNum: Int
        
        // Progressive difficulty based on level AND round
        let difficulty = level + (round / 4)  // Increases within level too
        
        switch difficulty {
        case 1:
            operations = [.add]
            minNum = 1
            maxNum = 15
        case 2:
            operations = [.add, .subtract]
            minNum = 5
            maxNum = 25
        case 3:
            operations = [.add, .subtract, .multiply]
            minNum = 10
            maxNum = 40
        case 4:
            operations = [.add, .subtract, .multiply]
            minNum = 15
            maxNum = 60
        default:
            operations = MathProblem.Operation.allCases
            minNum = 20
            maxNum = 99
        }
        
        let operation = operations.randomElement()!
        var num1: Int
        var num2: Int
        var answer: Int
        
        switch operation {
        case .add:
            num1 = Int.random(in: minNum...maxNum)
            num2 = Int.random(in: minNum...maxNum)
            answer = num1 + num2
            
        case .subtract:
            num1 = Int.random(in: minNum...maxNum)
            num2 = Int.random(in: 1...num1)
            answer = num1 - num2
            
        case .multiply:
            // Scale multipliers with difficulty
            let maxMult = min(12, 5 + difficulty * 2)
            num1 = Int.random(in: 2...maxMult)
            num2 = Int.random(in: 2...maxMult)
            answer = num1 * num2
            
        case .divide:
            let maxDiv = min(12, 4 + difficulty * 2)
            num2 = Int.random(in: 2...maxDiv)
            answer = Int.random(in: 2...maxDiv)
            num1 = num2 * answer
        }
        
        currentProblem = MathProblem(num1: num1, num2: num2, operation: operation, answer: answer)
    }
    
    private func startTimer() {
        timeRemaining = timeLimit
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                submitAnswer()
            }
        }
    }
    
    private func submitAnswer() {
        timer?.invalidate()

        let userNum = Int(userAnswer) ?? Int.min
        wasCorrect = userNum == currentProblem?.answer

        if wasCorrect {
            correctAnswers += 1
            score += 10 * level
            // Bonus for quick answers
            if timeRemaining > timeLimit / 2 {
                score += 5
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
            generateProblem()
            gameState = .playing
            startTimer()
        }
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = GameSession(
            gameType: .mentalMath,
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

struct NumberPadButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.title2.bold())
                .frame(width: 60, height: 50)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MentalMathGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
