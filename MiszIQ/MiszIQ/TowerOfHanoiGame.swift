import SwiftUI
import SwiftData

struct TowerOfHanoiGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var pegs: [[Int]] = [[], [], []]
    @State private var selectedPeg: Int? = nil
    @State private var moves = 0
    @State private var level = 1
    @State private var startTime = Date()
    @State private var score = 0
    @State private var showingInvalidMove = false
    
    enum GameState {
        case instructions, playing, complete, gameOver
    }
    
    var diskCount: Int { level + 2 }
    var optimalMoves: Int { Int(pow(2.0, Double(diskCount))) - 1 }
    
    // Theme-consistent disk palette using variations of royal blue and turquoise
    let diskColors: [Color] = [
        Color.royalBlue,
        Color.turquoise,
        Color(red: 0.2, green: 0.4, blue: 0.8),    // Deep blue
        Color(red: 0.4, green: 0.8, blue: 0.9),    // Light turquoise
        Color(red: 0.3, green: 0.5, blue: 0.9),    // Medium blue
        Color(red: 0.3, green: 0.7, blue: 0.7)     // Teal
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(level) • \(diskCount) Disks")
                        .font(.headline)
                    Text("Optimal: \(optimalMoves) moves")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Moves: \(moves)")
                        .font(.title2.bold())
                        .foregroundStyle(Color.royalBlue)
                    Text("Score: \(score)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            switch gameState {
            case .instructions:
                instructionsView
            case .playing:
                gameView
            case .complete:
                levelCompleteView
            case .gameOver:
                gameOverView
            }
            
            Spacer()
        }
        .navigationTitle("Tower of Hanoi")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.3.layers.3d")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Tower of Hanoi")
                .font(.title.bold())
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Rules:")
                    .font(.headline)
                
                HStack(alignment: .top) {
                    Text("1.")
                        .foregroundStyle(Color.royalBlue)
                    Text("Move all disks from the left peg to the right peg")
                }
                HStack(alignment: .top) {
                    Text("2.")
                        .foregroundStyle(Color.royalBlue)
                    Text("Only move one disk at a time")
                }
                HStack(alignment: .top) {
                    Text("3.")
                        .foregroundStyle(Color.royalBlue)
                    Text("A larger disk cannot be placed on a smaller disk")
                }
            }
            .font(.subheadline)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
        VStack(spacing: 20) {
            if showingInvalidMove {
                Text("Invalid move! Can't place larger disk on smaller one.")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.red.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Tower visualization
            HStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { pegIndex in
                    PegView(
                        disks: pegs[pegIndex],
                        maxDisks: diskCount,
                        diskColors: diskColors,
                        isSelected: selectedPeg == pegIndex,
                        pegIndex: pegIndex
                    )
                    .onTapGesture {
                        handlePegTap(pegIndex)
                    }
                }
            }
            .padding()
            
            // Labels
            HStack {
                Text("Source")
                    .frame(maxWidth: .infinity)
                Text("Auxiliary")
                    .frame(maxWidth: .infinity)
                Text("Target")
                    .frame(maxWidth: .infinity)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            
            // Reset button
            Button {
                resetLevel()
            } label: {
                Label("Reset Level", systemImage: "arrow.counterclockwise")
                    .font(.subheadline)
                    .foregroundStyle(Color.royalBlue)
            }
            .padding(.top, 10)
        }
    }
    
    private var levelCompleteView: some View {
        let efficiency = Double(optimalMoves) / Double(max(moves, 1))
        let levelScore = Int(100 * efficiency * Double(level))
        
        return VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
            
            Text("Level Complete!")
                .font(.title.bold())
            
            VStack(spacing: 8) {
                HStack {
                    Text("Your moves:")
                    Spacer()
                    Text("\(moves)")
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("Optimal moves:")
                    Spacer()
                    Text("\(optimalMoves)")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.royalBlue)
                }
                HStack {
                    Text("Efficiency:")
                    Spacer()
                    Text("\(Int(efficiency * 100))%")
                        .fontWeight(.semibold)
                        .foregroundStyle(efficiency >= 1.0 ? .green : .orange)
                }
                Divider()
                HStack {
                    Text("Points earned:")
                    Spacer()
                    Text("+\(levelScore)")
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            if level < 3 {
                Button {
                    nextLevel()
                } label: {
                    Text("Next Level")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.royalBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
            } else {
                Button {
                    finishGame()
                } label: {
                    Text("Finish Game")
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
        let percentile = mockService.calculatePercentile(score: score, for: .towerOfHanoi)
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
    
    private func startGame() {
        startTime = Date()
        setupLevel()
        gameState = .playing
    }
    
    private func setupLevel() {
        pegs = [Array((1...diskCount).reversed()), [], []]
        moves = 0
        selectedPeg = nil
        showingInvalidMove = false
    }
    
    private func handlePegTap(_ pegIndex: Int) {
        showingInvalidMove = false

        if let selected = selectedPeg {
            // Try to move disk
            if selected == pegIndex {
                // Deselect
                selectedPeg = nil
            } else if let disk = pegs[selected].last {
                // Check if move is valid
                if pegs[pegIndex].isEmpty || pegs[pegIndex].last! > disk {
                    // Valid move
                    withAnimation(.easeInOut(duration: 0.2)) {
                        pegs[selected].removeLast()
                        pegs[pegIndex].append(disk)
                    }
                    moves += 1
                    HapticManager.shared.buttonTap()
                    selectedPeg = nil

                    // Check win condition
                    if pegs[2].count == diskCount {
                        let efficiency = Double(optimalMoves) / Double(max(moves, 1))
                        let levelScore = Int(100 * efficiency * Double(level))
                        score += levelScore
                        AudioManager.shared.playSoundEffect(.correctAnswer)
                        HapticManager.shared.correctAnswer()
                        gameState = .complete
                    }
                } else {
                    // Invalid move
                    showingInvalidMove = true
                    selectedPeg = nil
                }
            }
        } else {
            // Select peg if it has disks
            if !pegs[pegIndex].isEmpty {
                selectedPeg = pegIndex
                HapticManager.shared.buttonTap()
            }
        }
    }
    
    private func resetLevel() {
        setupLevel()
    }
    
    private func nextLevel() {
        level += 1
        setupLevel()
        gameState = .playing
    }
    
    private func finishGame() {
        saveSession()
        gameState = .gameOver
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = GameSession(
            gameType: .towerOfHanoi,
            score: score,
            maxPossibleScore: 300,
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
        score = 0
        startTime = Date()
        gameState = .instructions
    }
}

struct PegView: View {
    let disks: [Int]
    let maxDisks: Int
    let diskColors: [Color]
    let isSelected: Bool
    let pegIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Peg pole
            ZStack(alignment: .bottom) {
                // Base and pole
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.brown.opacity(0.6))
                        .frame(width: 8, height: CGFloat(maxDisks * 20 + 20))
                    
                    Rectangle()
                        .fill(Color.brown.opacity(0.8))
                        .frame(height: 10)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }
                
                // Disks
                VStack(spacing: 2) {
                    ForEach(disks.reversed(), id: \.self) { disk in
                        DiskView(
                            size: disk,
                            maxSize: maxDisks,
                            color: diskColors[(disk - 1) % diskColors.count],
                            isTopDisk: disk == disks.last
                        )
                    }
                }
                .padding(.bottom, 10)
            }
            .frame(height: CGFloat(maxDisks * 22 + 40))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isSelected ? Color.royalBlue.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.royalBlue : Color.clear, lineWidth: 2)
        )
    }
}

struct DiskView: View {
    let size: Int
    let maxSize: Int
    let color: Color
    let isTopDisk: Bool
    
    var width: CGFloat {
        CGFloat(30 + size * 15)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color.gradient)
            .frame(width: width, height: 18)
            .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
    }
}

#Preview {
    NavigationStack {
        TowerOfHanoiGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
