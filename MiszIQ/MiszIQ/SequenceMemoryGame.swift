import SwiftUI
import SwiftData

struct SequenceMemoryGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var currentShowingIndex = -1
    @State private var score = 0
    @State private var level = 1
    @State private var startTime = Date()
    @State private var highestLevel = 0
    @State private var isShowingSequence = false
    @State private var showFeedback = false
    @State private var wasCorrect = false
    
    enum GameState {
        case instructions, showing, input, feedback, gameOver
    }
    
    let gridSize = 3
    var totalButtons: Int { gridSize * gridSize }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(level)")
                        .font(.headline)
                    Text("Sequence length: \(sequence.count)")
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
                
            case .showing, .input:
                gameView
                
            case .feedback:
                feedbackView
                
            case .gameOver:
                gameOverView
            }
            
            Spacer()
        }
        .navigationTitle("Sequence Memory")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Sequence Memory")
                .font(.title.bold())
            
            Text("Watch the sequence of lights, then repeat it back in the same order. The sequence gets longer as you progress!")
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
            if gameState == .showing {
                Text("Watch the sequence...")
                    .font(.headline)
                    .foregroundStyle(Color.royalBlue)
            } else {
                Text("Your turn! (\(userSequence.count)/\(sequence.count))")
                    .font(.headline)
            }
            
            // Button grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: gridSize), spacing: 12) {
                ForEach(0..<totalButtons, id: \.self) { index in
                    SequenceButton(
                        index: index,
                        isHighlighted: currentShowingIndex == index,
                        isUserPressed: userSequence.last == index && gameState == .input
                    )
                    .onTapGesture {
                        if gameState == .input {
                            buttonTapped(index)
                        }
                    }
                }
            }
            .padding(24)
            .aspectRatio(1, contentMode: .fit)
            
            if gameState == .input {
                HStack {
                    Text("Repeat the pattern")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var feedbackView: some View {
        VStack(spacing: 24) {
            Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(wasCorrect ? .green : .red)
            
            Text(wasCorrect ? "Perfect!" : "Wrong sequence!")
                .font(.title.bold())
            
            if wasCorrect {
                Text("+\(level * 10) points")
                    .font(.headline)
                    .foregroundStyle(Color.royalBlue)
                
                Text("Get ready for the next level...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("You reached level \(level)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                if wasCorrect {
                    nextLevel()
                } else {
                    endGame()
                }
            } label: {
                Text(wasCorrect ? "Continue" : "See Results")
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
        let percentile = mockService.calculatePercentile(score: highestLevel, for: .sequenceMemory)
        let bracket = mockService.getPerformanceBracket(percentile: percentile)
        
        return VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
            
            Text("Game Over!")
                .font(.title.bold())
            
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.royalBlue)
            }
            
            Text("Highest Level: \(highestLevel)")
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
    
    private func startGame() {
        startTime = Date()
        level = 1
        score = 0
        highestLevel = 0
        startLevel()
    }
    
    private func startLevel() {
        sequence.removeAll()
        userSequence.removeAll()
        
        // Generate sequence for current level
        // Level 1: 3 items, Level 2: 4 items, etc.
        let sequenceLength = level + 2
        for _ in 0..<sequenceLength {
            sequence.append(Int.random(in: 0..<totalButtons))
        }
        
        showSequence()
    }
    
    // Timing gets faster as levels increase
    var displayInterval: Double {
        // Level 1: 0.6s, Level 5: 0.4s, Level 10: 0.3s
        return max(0.3, 0.7 - Double(level) * 0.04)
    }
    
    private func showSequence() {
        gameState = .showing
        currentShowingIndex = -1
        
        let interval = displayInterval
        
        // Show each item in sequence
        for (index, buttonIndex) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * interval + 0.3) {
                currentShowingIndex = buttonIndex
                
                // Play haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * interval + interval * 0.8) {
                currentShowingIndex = -1
            }
        }
        
        // Switch to input mode after showing
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(sequence.count) * interval + 0.5) {
            gameState = .input
        }
    }
    
    private func buttonTapped(_ index: Int) {
        userSequence.append(index)

        // Light haptic
        HapticManager.shared.buttonTap()

        // Check if wrong
        let currentIndex = userSequence.count - 1
        if sequence[currentIndex] != index {
            // Wrong!
            wasCorrect = false
            AudioManager.shared.playSoundEffect(.wrongAnswer)
            HapticManager.shared.wrongAnswer()
            gameState = .feedback
            return
        }

        // Check if complete
        if userSequence.count == sequence.count {
            // Correct!
            wasCorrect = true
            AudioManager.shared.playSoundEffect(.correctAnswer)
            HapticManager.shared.correctAnswer()
            score += level * 10
            highestLevel = max(highestLevel, level)
            gameState = .feedback
        }
    }
    
    private func nextLevel() {
        level += 1
        startLevel()
    }
    
    private func endGame() {
        saveSession()
        gameState = .gameOver
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = GameSession(
            gameType: .sequenceMemory,
            score: score,
            maxPossibleScore: highestLevel * 20,
            level: highestLevel,
            durationSeconds: duration
        )
        session.profile = profile
        modelContext.insert(session)

        AudioManager.shared.playSoundEffect(.gameComplete)
        HapticManager.shared.gameComplete()
    }
    
    private func resetGame() {
        level = 1
        score = 0
        highestLevel = 0
        startTime = Date()
        gameState = .instructions
    }
}

struct SequenceButton: View {
    let index: Int
    let isHighlighted: Bool
    let isUserPressed: Bool
    
    // Theme-consistent button palette using variations of royal blue and turquoise
    private let buttonColors: [Color] = [
        Color.royalBlue,
        Color.turquoise,
        Color(red: 0.2, green: 0.4, blue: 0.8),    // Deep blue
        Color(red: 0.4, green: 0.8, blue: 0.9),    // Light turquoise
        Color(red: 0.3, green: 0.5, blue: 0.9),    // Medium blue
        Color(red: 0.3, green: 0.7, blue: 0.7),    // Teal
        Color(red: 0.15, green: 0.3, blue: 0.7),   // Dark royal blue
        Color(red: 0.5, green: 0.9, blue: 0.85),   // Bright turquoise
        Color(red: 0.4, green: 0.6, blue: 0.95)    // Sky blue
    ]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(buttonColors[index % buttonColors.count].opacity(isHighlighted || isUserPressed ? 1.0 : 0.3))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(isHighlighted ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHighlighted)
            .animation(.easeInOut(duration: 0.1), value: isUserPressed)
    }
}

#Preview {
    NavigationStack {
        SequenceMemoryGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
