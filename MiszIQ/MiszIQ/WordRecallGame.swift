import SwiftUI
import SwiftData

struct WordRecallGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var wordsToMemorize: [String] = []
    @State private var userInput = ""
    @State private var recalledWords: [String] = []
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var showingWords = false
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    
    enum GameState {
        case instructions, memorizing, recalling, feedback, gameOver
    }
    
    let wordBank = [
        // Common nouns
        "apple", "river", "mountain", "garden", "bridge", "castle", "forest", "ocean",
        "sunset", "thunder", "crystal", "shadow", "whisper", "journey", "harmony", "mystery",
        "village", "temple", "dragon", "phoenix", "meadow", "canyon", "island", "desert",
        "palace", "harbor", "valley", "glacier", "volcano", "rainbow", "lantern", "compass",
        // Abstract
        "freedom", "wisdom", "courage", "silence", "wonder", "patience", "kindness", "strength",
        "balance", "clarity", "serenity", "passion", "triumph", "legacy", "vision", "spirit"
    ]
    
    var wordsPerRound: Int { 4 + level }
    var memorizeTime: Int { max(5, wordsPerRound * 2) }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(level)")
                        .font(.headline)
                    Text("Round \(round)/3")
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
            case .memorizing:
                memorizingView
            case .recalling:
                recallingView
            case .feedback:
                feedbackView
            case .gameOver:
                gameOverView
            }
            
            Spacer()
        }
        .navigationTitle("Word Recall")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Word Recall")
                .font(.title.bold())
            
            Text("Memorize the list of words, then type as many as you can remember. Order doesn't matter!")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button {
                startRound()
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
    
    private var memorizingView: some View {
        VStack(spacing: 20) {
            // Timer
            Text("Memorize these words!")
                .font(.headline)
                .foregroundStyle(Color.royalBlue)
            
            Text("\(timeRemaining)s")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(timeRemaining <= 3 ? .red : .primary)
            
            // Words grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(wordsToMemorize, id: \.self) { word in
                    Text(word)
                        .font(.title3.weight(.medium))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.royalBlue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
        }
    }
    
    private var recallingView: some View {
        VStack(spacing: 20) {
            Text("Type the words you remember")
                .font(.headline)
            
            Text("\(recalledWords.count)/\(wordsToMemorize.count) words")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Input field
            HStack {
                TextField("Type a word...", text: $userInput)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit {
                        submitWord()
                    }
                
                Button {
                    submitWord()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.royalBlue)
                }
                .disabled(userInput.isEmpty)
            }
            .padding(.horizontal)
            
            // Recalled words
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(recalledWords, id: \.self) { word in
                        HStack {
                            Text(word)
                                .font(.subheadline)
                            if wordsToMemorize.map({ $0.lowercased() }).contains(word.lowercased()) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
            .frame(maxHeight: 150)
            .padding(.horizontal)
            
            Button {
                finishRecalling()
            } label: {
                Text("Done")
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
    
    private var feedbackView: some View {
        let correctCount = recalledWords.filter { word in
            wordsToMemorize.map { $0.lowercased() }.contains(word.lowercased())
        }.count
        
        return VStack(spacing: 24) {
            Image(systemName: correctCount == wordsToMemorize.count ? "star.fill" : "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(correctCount == wordsToMemorize.count ? .yellow : .green)
            
            Text("\(correctCount)/\(wordsToMemorize.count) Correct!")
                .font(.title.bold())
            
            // Show missed words
            if correctCount < wordsToMemorize.count {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Missed words:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    let missed = wordsToMemorize.filter { word in
                        !recalledWords.map { $0.lowercased() }.contains(word.lowercased())
                    }
                    
                    FlowLayout(spacing: 8) {
                        ForEach(missed, id: \.self) { word in
                            Text(word)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.red.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
        .padding()
    }
    
    private var gameOverView: some View {
        let percentile = mockService.calculatePercentile(score: score, for: .wordRecall)
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
    
    private func startRound() {
        wordsToMemorize = Array(wordBank.shuffled().prefix(wordsPerRound))
        recalledWords = []
        userInput = ""
        gameState = .memorizing
        timeRemaining = memorizeTime
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                gameState = .recalling
            }
        }
    }
    
    private func submitWord() {
        let word = userInput.trimmingCharacters(in: .whitespaces).lowercased()
        guard !word.isEmpty else { return }

        if !recalledWords.map({ $0.lowercased() }).contains(word) {
            recalledWords.append(userInput.trimmingCharacters(in: .whitespaces))
            let isCorrect = wordsToMemorize.map { $0.lowercased() }.contains(word)
            if isCorrect {
                AudioManager.shared.playSoundEffect(.correctAnswer)
                HapticManager.shared.correctAnswer()
            } else {
                AudioManager.shared.playSoundEffect(.wrongAnswer)
                HapticManager.shared.wrongAnswer()
            }
        }
        userInput = ""
    }
    
    private func finishRecalling() {
        let correctCount = recalledWords.filter { word in
            wordsToMemorize.map { $0.lowercased() }.contains(word.lowercased())
        }.count
        
        score += correctCount * 10 * level
        gameState = .feedback
    }
    
    private func nextRound() {
        if round >= 3 {
            level += 1
            if level > 3 {
                saveSession()
                gameState = .gameOver
                return
            }
            round = 1
        } else {
            round += 1
        }
        startRound()
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = GameSession(
            gameType: .wordRecall,
            score: score,
            maxPossibleScore: 9 * wordsPerRound * 10 * 3,
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
        startTime = Date()
        gameState = .instructions
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .init(frame.size))
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let width = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (CGSize(width: width, height: y + rowHeight), frames)
    }
}

#Preview {
    NavigationStack {
        WordRecallGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
