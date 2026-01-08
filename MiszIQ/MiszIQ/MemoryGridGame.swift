import SwiftUI
import SwiftData

struct MemoryGridGame: View {
    let profile: UserProfile
    let mockService: MockDataService

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var gameState: GameState = .difficultySelect
    @State private var selectedDifficulty = 1
    @State private var gridSize = 3
    @State private var highlightedTiles: Set<Int> = []
    @State private var selectedTiles: Set<Int> = []
    @State private var showingTiles = false
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var correctInRound = 0
    @State private var totalTilesShown = 0
    @State private var newBadges: [BadgeType] = []
    @State private var unlockedLevel: Int? = nil
    @State private var showCompletionOverlay = false

    enum GameState {
        case difficultySelect, instructions, showing, guessing, feedback, gameOver
    }
    
    var totalCells: Int { gridSize * gridSize }
    var tilesToShow: Int { 
        // Level 1: 2-3 tiles, Level 2: 3-4 tiles, Level 3: 4-5 tiles
        // Grid also grows: 3x3 -> 4x4 -> 5x5 -> 6x6
        return min(level + 1 + (round / 3), totalCells - 1)
    }
    var showDuration: Double {
        // Less time to memorize as difficulty increases
        // Level 1: 2s, Level 2: 1.5s, Level 3: 1s per tile group
        return max(1.0, 2.5 - Double(level) * 0.5)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if gameState != .difficultySelect {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Difficulty: \(difficultyName)")
                                .font(.headline)
                            Text("Round \(round)/5")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("Score: \(score)")
                            .font(.title2.bold())
                            .foregroundStyle(Color.royalBlue)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                switch gameState {
                case .difficultySelect:
                    DifficultySelector(
                        profile: profile,
                        gameType: .memoryGrid,
                        selectedLevel: $selectedDifficulty
                    ) {
                        applyDifficulty()
                        gameState = .instructions
                    }

                case .instructions:
                    instructionsView

                case .showing, .guessing, .feedback:
                    gridView

                case .gameOver:
                    gameOverView
                }

                Spacer()
            }
            .navigationTitle("Memory Grid")
            .navigationBarTitleDisplayMode(.inline)

            if showCompletionOverlay {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { }

                GameCompletionOverlay(
                    newBadges: newBadges,
                    unlockedLevel: unlockedLevel,
                    gameType: .memoryGrid
                ) {
                    showCompletionOverlay = false
                }
            }
        }
    }

    private var difficultyName: String {
        switch selectedDifficulty {
        case 1: return "Easy"
        case 2: return "Medium"
        case 3: return "Hard"
        default: return "Level \(selectedDifficulty)"
        }
    }

    private func applyDifficulty() {
        switch selectedDifficulty {
        case 1:
            gridSize = 3
            level = 1
        case 2:
            gridSize = 4
            level = 2
        case 3:
            gridSize = 5
            level = 3
        default:
            gridSize = 3
            level = 1
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Memory Grid")
                .font(.title.bold())
            
            Text("Memorize the highlighted tiles, then tap them in any order after they disappear.")
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
    
    private var gridView: some View {
        VStack(spacing: 16) {
            if gameState == .showing {
                Text("Memorize these tiles!")
                    .font(.headline)
                    .foregroundStyle(Color.royalBlue)
            } else if gameState == .guessing {
                Text("Tap the tiles you saw")
                    .font(.headline)
            } else if gameState == .feedback {
                Text(selectedTiles == highlightedTiles ? "Perfect! ✓" : "Not quite...")
                    .font(.headline)
                    .foregroundStyle(selectedTiles == highlightedTiles ? .green : .orange)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize), spacing: 8) {
                ForEach(0..<totalCells, id: \.self) { index in
                    TileView(
                        index: index,
                        isHighlighted: highlightedTiles.contains(index),
                        isSelected: selectedTiles.contains(index),
                        showHighlight: gameState == .showing || gameState == .feedback,
                        showSelection: gameState == .guessing || gameState == .feedback
                    )
                    .onTapGesture {
                        if gameState == .guessing {
                            toggleTile(index)
                        }
                    }
                }
            }
            .padding()
            .aspectRatio(1, contentMode: .fit)
            
            if gameState == .guessing {
                Button {
                    checkAnswer()
                } label: {
                    Text("Submit (\(selectedTiles.count)/\(tilesToShow))")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTiles.count == tilesToShow ? .blue : .gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedTiles.count != tilesToShow)
                .padding(.horizontal, 40)
            }
            
            if gameState == .feedback {
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
        let percentile = mockService.calculatePercentile(score: score, for: .memoryGrid)
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
        highlightedTiles.removeAll()
        selectedTiles.removeAll()
        
        // Select random tiles to highlight
        var available = Array(0..<totalCells)
        for _ in 0..<tilesToShow {
            if let index = available.randomElement() {
                highlightedTiles.insert(index)
                available.removeAll { $0 == index }
            }
        }
        
        totalTilesShown += tilesToShow
        gameState = .showing
        
        // Show tiles for a duration based on level difficulty
        DispatchQueue.main.asyncAfter(deadline: .now() + showDuration) {
            if gameState == .showing {
                gameState = .guessing
            }
        }
    }
    
    private func toggleTile(_ index: Int) {
        if selectedTiles.contains(index) {
            selectedTiles.remove(index)
        } else if selectedTiles.count < tilesToShow {
            selectedTiles.insert(index)
        }
    }
    
    private func checkAnswer() {
        let correct = highlightedTiles.intersection(selectedTiles).count
        correctInRound += correct
        score += correct * 10 * level

        if selectedTiles == highlightedTiles {
            AudioManager.shared.playSoundEffect(.correctAnswer)
            HapticManager.shared.correctAnswer()
        } else {
            AudioManager.shared.playSoundEffect(.wrongAnswer)
            HapticManager.shared.wrongAnswer()
        }

        gameState = .feedback
    }
    
    private func nextRound() {
        if round >= 5 {
            // Level complete
            if correctInRound >= totalTilesShown * 80 / 100 {
                // Passed - go to next level
                level += 1
                if level > 3 {
                    gridSize = min(gridSize + 1, 6)
                    level = 1
                }
            }
            
            if round >= 5 && level > 1 || gridSize >= 6 {
                saveSession()
                gameState = .gameOver
                return
            }
            
            round = 1
            correctInRound = 0
            totalTilesShown = 0
        } else {
            round += 1
        }
        
        startRound()
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let result = GameCompletionHandler.handleGameCompletion(
            profile: profile,
            gameType: .memoryGrid,
            score: score,
            maxPossibleScore: totalTilesShown * 10 * level,
            level: selectedDifficulty,
            durationSeconds: duration,
            mockService: mockService,
            modelContext: modelContext
        )

        AudioManager.shared.playSoundEffect(.gameComplete)
        HapticManager.shared.gameComplete()

        newBadges = result.newBadges
        unlockedLevel = result.unlockedLevel

        if !newBadges.isEmpty || unlockedLevel != nil {
            showCompletionOverlay = true
        }
    }

    private func resetGame() {
        round = 1
        score = 0
        correctInRound = 0
        totalTilesShown = 0
        startTime = Date()
        newBadges = []
        unlockedLevel = nil
        gameState = .difficultySelect
    }
}

struct TileView: View {
    let index: Int
    let isHighlighted: Bool
    let isSelected: Bool
    let showHighlight: Bool
    let showSelection: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(tileColor)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected && showSelection ? Color.royalBlue : Color.clear, lineWidth: 3)
            )
            .animation(.easeInOut(duration: 0.2), value: isHighlighted)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var tileColor: Color {
        if showHighlight && isHighlighted {
            if showSelection && isSelected {
                return .green  // Correct selection
            } else if showSelection && !isSelected {
                return .red.opacity(0.7)  // Missed tile
            }
            return Color.turquoise  // Highlighted tile to remember
        }
        if showSelection && isSelected && !showHighlight {
            return Color.royalBlue.opacity(0.6)  // User selected tile
        }
        return .gray.opacity(0.3)
    }
}

#Preview {
    NavigationStack {
        MemoryGridGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
