import SwiftUI
import SwiftData

struct VocabularyGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var currentQuestion: VocabQuestion?
    @State private var selectedAnswer: Int? = nil
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var correctAnswers = 0
    
    enum GameState {
        case instructions, playing, feedback, gameOver
    }
    
    struct VocabQuestion {
        let word: String
        let partOfSpeech: String
        let options: [String]
        let correctIndex: Int
        let exampleSentence: String
    }
    
    let questionsByLevel: [[VocabQuestion]] = [
        // Level 1 - Common words
        [
            VocabQuestion(word: "Abundant", partOfSpeech: "adjective", options: ["Plentiful", "Scarce", "Empty", "Broken"], correctIndex: 0, exampleSentence: "The garden had abundant flowers."),
            VocabQuestion(word: "Hesitate", partOfSpeech: "verb", options: ["Rush", "Pause", "Continue", "Finish"], correctIndex: 1, exampleSentence: "Don't hesitate to ask for help."),
            VocabQuestion(word: "Genuine", partOfSpeech: "adjective", options: ["Fake", "Copied", "Real", "Similar"], correctIndex: 2, exampleSentence: "She gave a genuine smile."),
            VocabQuestion(word: "Peculiar", partOfSpeech: "adjective", options: ["Normal", "Strange", "Common", "Simple"], correctIndex: 1, exampleSentence: "He had a peculiar way of walking."),
            VocabQuestion(word: "Tranquil", partOfSpeech: "adjective", options: ["Noisy", "Chaotic", "Peaceful", "Active"], correctIndex: 2, exampleSentence: "The lake was tranquil at dawn."),
            VocabQuestion(word: "Conceal", partOfSpeech: "verb", options: ["Hide", "Show", "Find", "Lose"], correctIndex: 0, exampleSentence: "He tried to conceal his disappointment."),
        ],
        // Level 2 - Intermediate words
        [
            VocabQuestion(word: "Meticulous", partOfSpeech: "adjective", options: ["Careless", "Thorough", "Quick", "Lazy"], correctIndex: 1, exampleSentence: "She was meticulous in her research."),
            VocabQuestion(word: "Ephemeral", partOfSpeech: "adjective", options: ["Permanent", "Short-lived", "Ancient", "Recurring"], correctIndex: 1, exampleSentence: "The beauty of cherry blossoms is ephemeral."),
            VocabQuestion(word: "Pragmatic", partOfSpeech: "adjective", options: ["Idealistic", "Theoretical", "Practical", "Emotional"], correctIndex: 2, exampleSentence: "She took a pragmatic approach to the problem."),
            VocabQuestion(word: "Ambiguous", partOfSpeech: "adjective", options: ["Clear", "Uncertain", "Definite", "Obvious"], correctIndex: 1, exampleSentence: "The message was ambiguous."),
            VocabQuestion(word: "Eloquent", partOfSpeech: "adjective", options: ["Articulate", "Silent", "Confused", "Boring"], correctIndex: 0, exampleSentence: "The speaker was eloquent and persuasive."),
            VocabQuestion(word: "Benevolent", partOfSpeech: "adjective", options: ["Cruel", "Kind", "Neutral", "Angry"], correctIndex: 1, exampleSentence: "The benevolent king helped his people."),
        ],
        // Level 3 - Advanced words
        [
            VocabQuestion(word: "Ubiquitous", partOfSpeech: "adjective", options: ["Rare", "Everywhere", "Hidden", "Unique"], correctIndex: 1, exampleSentence: "Smartphones have become ubiquitous."),
            VocabQuestion(word: "Juxtapose", partOfSpeech: "verb", options: ["Separate", "Place side by side", "Remove", "Ignore"], correctIndex: 1, exampleSentence: "The artist juxtaposed light and dark."),
            VocabQuestion(word: "Sycophant", partOfSpeech: "noun", options: ["Leader", "Rebel", "Flatterer", "Hermit"], correctIndex: 2, exampleSentence: "The king was surrounded by sycophants."),
            VocabQuestion(word: "Ineffable", partOfSpeech: "adjective", options: ["Expressible", "Indescribable", "Ordinary", "Forgettable"], correctIndex: 1, exampleSentence: "The view was of ineffable beauty."),
            VocabQuestion(word: "Perfunctory", partOfSpeech: "adjective", options: ["Thorough", "Enthusiastic", "Halfhearted", "Careful"], correctIndex: 2, exampleSentence: "He gave a perfunctory nod."),
            VocabQuestion(word: "Obfuscate", partOfSpeech: "verb", options: ["Clarify", "Confuse", "Explain", "Simplify"], correctIndex: 1, exampleSentence: "The politician tried to obfuscate the issue."),
        ]
    ]
    
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
        .navigationTitle("Vocabulary")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "character.book.closed")
                .font(.system(size: 60))
                .foregroundStyle(Color.turquoise)
            
            Text("Vocabulary")
                .font(.title.bold())
            
            Text("Select the word or phrase that best matches the meaning of the given word.")
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
            if let question = currentQuestion {
                // Word display
                VStack(spacing: 8) {
                    Text(question.word)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.turquoise)
                    
                    Text(question.partOfSpeech)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding()
                
                Text("Choose the correct meaning:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(question.options.indices, id: \.self) { index in
                        Button {
                            selectedAnswer = index
                        } label: {
                            HStack {
                                Text(optionLabel(index))
                                    .font(.headline)
                                    .foregroundStyle(Color.turquoise)
                                    .frame(width: 30)
                                
                                Text(question.options[index])
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if selectedAnswer == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.turquoise)
                                }
                            }
                            .padding()
                            .background(selectedAnswer == index ? Color.turquoise.opacity(0.1) : Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedAnswer == index ? Color.turquoise : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                
                if selectedAnswer != nil {
                    Button {
                        submitAnswer()
                    } label: {
                        Text("Submit")
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
        }
    }
    
    private var feedbackView: some View {
        guard let question = currentQuestion else { return AnyView(EmptyView()) }
        let isCorrect = selectedAnswer == question.correctIndex
        
        return AnyView(
            VStack(spacing: 24) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Correct!" : "Not quite...")
                    .font(.title.bold())
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(question.word)
                            .font(.headline)
                        Text("means")
                            .foregroundStyle(.secondary)
                        Text(question.options[question.correctIndex])
                            .font(.headline)
                            .foregroundStyle(Color.turquoise)
                    }
                    
                    Divider()
                    
                    Text("Example:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\"\(question.exampleSentence)\"")
                        .font(.body)
                        .italic()
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
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
        )
    }
    
    private var gameOverView: some View {
        let percentile = mockService.calculatePercentile(score: score, for: .vocabulary)
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
    
    private func optionLabel(_ index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }
    
    private func startGame() {
        startTime = Date()
        generateRound()
        gameState = .playing
    }
    
    private func generateRound() {
        let levelQuestions = questionsByLevel[min(level - 1, questionsByLevel.count - 1)]
        currentQuestion = levelQuestions.randomElement()
        selectedAnswer = nil
    }
    
    private func submitAnswer() {
        guard let question = currentQuestion, let answer = selectedAnswer else { return }

        if answer == question.correctIndex {
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
            gameType: .vocabulary,
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
        startTime = Date()
        gameState = .instructions
    }
}

#Preview {
    NavigationStack {
        VocabularyGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
