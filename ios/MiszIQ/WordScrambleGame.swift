import SwiftUI
import SwiftData

struct WordScrambleGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var currentWord = ""
    @State private var scrambledLetters: [Character] = []
    @State private var selectedIndices: [Int] = []
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var correctAnswers = 0
    @State private var showFeedback = false
    @State private var wasCorrect = false
    @State private var hint = ""
    @State private var previousWord = ""

    enum GameState {
        case instructions, playing, feedback, gameOver
    }
    
    let wordsByLevel: [[String: String]] = [
        // Level 1 - 4-5 letter words (20 words)
        [
            "apple": "A common fruit",
            "house": "Where people live",
            "water": "Essential for life",
            "bread": "Baked food item",
            "chair": "Furniture for sitting",
            "plant": "Green living thing",
            "music": "Audible art form",
            "cloud": "In the sky",
            "river": "Flowing water",
            "dream": "Happens during sleep",
            "light": "Opposite of dark",
            "stone": "Hard rock material",
            "beach": "Sandy shore",
            "storm": "Severe weather",
            "flame": "Fire produces this",
            "grape": "Small purple fruit",
            "train": "Runs on tracks",
            "smile": "Happy expression",
            "globe": "Model of Earth",
            "clock": "Tells time"
        ],
        // Level 2 - 6-7 letter words (20 words)
        [
            "garden": "Where flowers grow",
            "window": "See through wall opening",
            "bridge": "Crosses over water",
            "forest": "Many trees together",
            "market": "Place to buy things",
            "shadow": "Blocked light creates this",
            "summer": "Warm season",
            "wonder": "Feeling of amazement",
            "castle": "Medieval fortress",
            "planet": "Orbits a star",
            "frozen": "Very cold state",
            "island": "Land surrounded by water",
            "tunnel": "Underground passage",
            "basket": "Container with handle",
            "rocket": "Space vehicle",
            "jungle": "Dense tropical forest",
            "puzzle": "Brain teaser",
            "blanket": "Warm bed cover",
            "crystal": "Clear mineral",
            "dolphin": "Intelligent sea mammal"
        ],
        // Level 3 - 8+ letter words (20 words)
        [
            "mountain": "Very tall landform",
            "elephant": "Large gray animal",
            "birthday": "Annual celebration",
            "computer": "Electronic device",
            "treasure": "Valuable hidden items",
            "umbrella": "Rain protection",
            "sandwich": "Food between bread",
            "dinosaur": "Extinct reptile",
            "hospital": "Medical facility",
            "keyboard": "Typing device",
            "firework": "Explosive celebration",
            "butterfly": "Colorful insect",
            "lightning": "Electric sky flash",
            "nightmare": "Bad dream",
            "submarine": "Underwater vessel",
            "chocolate": "Sweet brown treat",
            "adventure": "Exciting journey",
            "telescope": "Views distant stars",
            "crocodile": "Large reptile",
            "celebrate": "Mark special occasion"
        ]
    ]
    
    var currentGuess: String {
        String(selectedIndices.map { scrambledLetters[$0] })
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
                    .foregroundStyle(Color.turquoise)
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
        .navigationTitle("Word Scramble")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "textformat.abc")
                .font(.system(size: 60))
                .foregroundStyle(Color.turquoise)
            
            Text("Word Scramble")
                .font(.title.bold())
            
            Text("Unscramble the letters to form a word. Use the hint if you get stuck!")
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
                    .background(Color.turquoise)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 24) {
            // Hint
            Text(hint)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.turquoise.opacity(0.1))
                .clipShape(Capsule())
            
            // Current guess display
            HStack(spacing: 8) {
                ForEach(0..<currentWord.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                            .frame(width: 40, height: 50)
                            .shadow(color: .black.opacity(0.1), radius: 2)
                        
                        if index < selectedIndices.count {
                            Text(String(scrambledLetters[selectedIndices[index]]))
                                .font(.title2.bold())
                                .foregroundStyle(Color.turquoise)
                        }
                    }
                }
            }
            .padding()
            
            // Scrambled letters
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(currentWord.count, 6)), spacing: 10) {
                ForEach(0..<scrambledLetters.count, id: \.self) { index in
                    Button {
                        toggleLetter(index)
                    } label: {
                        Text(String(scrambledLetters[index]))
                            .font(.title2.bold())
                            .frame(width: 50, height: 50)
                            .background(selectedIndices.contains(index) ? Color.turquoise : Color(.systemBackground))
                            .foregroundStyle(selectedIndices.contains(index) ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    }
                    .disabled(selectedIndices.contains(index))
                }
            }
            .padding(.horizontal, 30)
            
            // Action buttons
            HStack(spacing: 16) {
                Button {
                    clearSelection()
                } label: {
                    Label("Clear", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                Button {
                    submitGuess()
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(selectedIndices.count == currentWord.count ? .green : .gray)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .disabled(selectedIndices.count != currentWord.count)
            }
            .padding(.top, 10)
        }
    }
    
    private var feedbackView: some View {
        VStack(spacing: 24) {
            Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(wasCorrect ? .green : .red)
            
            Text(wasCorrect ? "Correct!" : "Not quite...")
                .font(.title.bold())
            
            VStack(spacing: 8) {
                Text("The word was:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(currentWord.uppercased())
                    .font(.title.bold())
                    .foregroundStyle(Color.turquoise)
            }
            
            if wasCorrect {
                Text("+\(10 * level) points")
                    .font(.headline)
                    .foregroundStyle(Color.turquoise)
            }
            
            Button {
                nextRound()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.turquoise)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var gameOverView: some View {
        let percentile = mockService.calculatePercentile(score: score, for: .wordScramble)
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
                    .foregroundStyle(Color.turquoise)
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
            .background(Color.turquoise.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack(spacing: 16) {
                Button {
                    resetGame()
                } label: {
                    Text("Play Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.turquoise)
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
        generateRound()
        gameState = .playing
    }
    
    private func generateRound() {
        let levelWords = wordsByLevel[min(level - 1, wordsByLevel.count - 1)]

        // Filter out the previous word to avoid repeats
        let availableWords = levelWords.filter { $0.key != previousWord }
        let wordsToChooseFrom = availableWords.isEmpty ? levelWords : availableWords

        if let (word, wordHint) = wordsToChooseFrom.randomElement() {
            previousWord = word
            currentWord = word
            hint = wordHint
            scrambledLetters = Array(word.uppercased()).shuffled()

            // Make sure it's actually scrambled
            while String(scrambledLetters) == word.uppercased() && word.count > 1 {
                scrambledLetters.shuffle()
            }
        }
        selectedIndices = []
    }
    
    private func toggleLetter(_ index: Int) {
        if !selectedIndices.contains(index) && selectedIndices.count < currentWord.count {
            selectedIndices.append(index)
        }
    }
    
    private func clearSelection() {
        selectedIndices = []
    }
    
    private func submitGuess() {
        wasCorrect = currentGuess.lowercased() == currentWord.lowercased()

        if wasCorrect {
            correctAnswers += 1
            score += 10 * level
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
        }
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = GameSession(
            gameType: .wordScramble,
            score: score,
            maxPossibleScore: 210,  // 3×10 + 3×20 + 4×30 = 210
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
        previousWord = ""
        startTime = Date()
        gameState = .instructions
    }
}

#Preview {
    NavigationStack {
        WordScrambleGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
