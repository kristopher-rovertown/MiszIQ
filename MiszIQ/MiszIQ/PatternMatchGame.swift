import SwiftUI
import SwiftData

struct PatternMatchGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var currentPattern: [Int] = []
    @State private var options: [[Int]] = []
    @State private var correctAnswer = 0
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var correctAnswers = 0
    @State private var selectedOption: Int? = nil
    @State private var showFeedback = false
    
    enum GameState {
        case instructions, playing, feedback, gameOver
    }
    
    var patternLength: Int { 4 + level }
    
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
                
            case .playing, .feedback:
                gameView
                
            case .gameOver:
                gameOverView
            }
            
            Spacer()
        }
        .navigationTitle("Pattern Match")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "rectangle.pattern.checkered")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Pattern Match")
                .font(.title.bold())
            
            Text("Find the pattern in the sequence and select the option that correctly continues it.")
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
            Text("What comes next?")
                .font(.headline)
            
            // Pattern display
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<currentPattern.count, id: \.self) { index in
                        PatternCell(value: currentPattern[index])
                    }
                    
                    Text("?")
                        .font(.title.bold())
                        .frame(width: 50, height: 50)
                        .background(Color.royalBlue.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            
            // Options
            VStack(spacing: 12) {
                ForEach(0..<options.count, id: \.self) { index in
                    Button {
                        selectOption(index)
                    } label: {
                        HStack {
                            Text(optionLabel(index))
                                .font(.headline)
                                .frame(width: 30)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<options[index].count, id: \.self) { i in
                                    PatternCell(value: options[index][i], small: true)
                                }
                            }
                            
                            Spacer()
                            
                            if showFeedback && selectedOption == index {
                                Image(systemName: index == correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(index == correctAnswer ? .green : .red)
                            }
                        }
                        .padding()
                        .background(optionBackground(index))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(showFeedback)
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            
            if showFeedback {
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
    }
    
    private var gameOverView: some View {
        let percentile = mockService.calculatePercentile(score: score, for: .patternMatch)
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
    
    private func optionLabel(_ index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }
    
    private func optionBackground(_ index: Int) -> Color {
        if showFeedback {
            if index == correctAnswer {
                return .green.opacity(0.2)
            } else if index == selectedOption {
                return .red.opacity(0.2)
            }
        }
        return Color.gray.opacity(0.1)
    }
    
    private func startGame() {
        startTime = Date()
        generateRound()
        gameState = .playing
    }
    
    private func generateRound() {
        selectedOption = nil
        showFeedback = false
        
        // Progressive difficulty: more pattern types and harder variants as level/round increase
        let difficulty = level + (round / 4)
        let maxPatternType = min(1 + difficulty, 5)
        let patternType = Int.random(in: 0..<maxPatternType)
        
        switch patternType {
        case 0: // Arithmetic sequence - larger numbers at higher difficulty
            let start = Int.random(in: 1...(5 * difficulty))
            let diff = Int.random(in: 1...(2 + difficulty)) * (Bool.random() ? 1 : -1)
            currentPattern = (0..<patternLength).map { start + $0 * diff }
            let next = start + patternLength * diff
            let next2 = next + diff
            generateOptions(correct: [next, next2])
            
        case 1: // Geometric (multiply by 2 or 3)
            let start = Int.random(in: 1...4)
            let multiplier = difficulty > 2 ? Int.random(in: 2...3) : 2
            currentPattern = (0..<patternLength).map { start * Int(pow(Double(multiplier), Double($0))) }
            let next = currentPattern.last! * multiplier
            let next2 = next * multiplier
            generateOptions(correct: [next, next2])
            
        case 2: // Alternating pattern with increment
            let a = Int.random(in: 1...10)
            let b = Int.random(in: 11...20)
            let increment = difficulty > 2 ? Int.random(in: 1...difficulty) : 0
            currentPattern = (0..<patternLength).map { 
                let base = $0 % 2 == 0 ? a : b
                return base + ($0 / 2) * increment
            }
            let nextIdx = patternLength
            let next = (nextIdx % 2 == 0 ? a : b) + (nextIdx / 2) * increment
            let next2Idx = patternLength + 1
            let next2 = (next2Idx % 2 == 0 ? a : b) + (next2Idx / 2) * increment
            generateOptions(correct: [next, next2])
            
        case 3: // Fibonacci-like
            let a = Int.random(in: 1...3)
            let b = Int.random(in: 2...5)
            currentPattern = [a, b]
            while currentPattern.count < patternLength {
                currentPattern.append(currentPattern[currentPattern.count - 1] + currentPattern[currentPattern.count - 2])
            }
            let next = currentPattern[patternLength - 1] + currentPattern[patternLength - 2]
            let next2 = next + currentPattern[patternLength - 1]
            generateOptions(correct: [next, next2])
            
        default: // Squares or Cubes based on difficulty
            let start = Int.random(in: 1...4)
            currentPattern = (0..<patternLength).map { (start + $0) * (start + $0) }
            let next = (start + patternLength) * (start + patternLength)
            let next2 = (start + patternLength + 1) * (start + patternLength + 1)
            generateOptions(correct: [next, next2])
        }
    }
    
    private func generateOptions(correct: [Int]) {
        correctAnswer = Int.random(in: 0..<4)
        options = []
        
        var usedOptions: Set<String> = []
        usedOptions.insert(correct.map { String($0) }.joined(separator: ","))
        
        for i in 0..<4 {
            if i == correctAnswer {
                options.append(correct)
            } else {
                // Generate wrong answer
                var wrong: [Int]
                var attempts = 0
                repeat {
                    let offset1 = Int.random(in: 1...10) * (Bool.random() ? 1 : -1)
                    let offset2 = Int.random(in: 1...10) * (Bool.random() ? 1 : -1)
                    wrong = [max(1, correct[0] + offset1), max(1, correct[1] + offset2)]
                    attempts += 1
                } while usedOptions.contains(wrong.map { String($0) }.joined(separator: ",")) && attempts < 20
                
                usedOptions.insert(wrong.map { String($0) }.joined(separator: ","))
                options.append(wrong)
            }
        }
    }
    
    private func selectOption(_ index: Int) {
        selectedOption = index
        showFeedback = true

        if index == correctAnswer {
            correctAnswers += 1
            score += 10 * level
            AudioManager.shared.playSoundEffect(.correctAnswer)
            HapticManager.shared.correctAnswer()
        } else {
            AudioManager.shared.playSoundEffect(.wrongAnswer)
            HapticManager.shared.wrongAnswer()
        }
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
        }
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = GameSession(
            gameType: .patternMatch,
            score: score,
            maxPossibleScore: 100 * level,
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

struct PatternCell: View {
    let value: Int
    var small: Bool = false
    
    var body: some View {
        Text("\(value)")
            .font(small ? .body.bold() : .title2.bold())
            .frame(width: small ? 40 : 50, height: small ? 40 : 50)
            .background(Color.royalBlue.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        PatternMatchGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
