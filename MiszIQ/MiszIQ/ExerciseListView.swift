import SwiftUI
import SwiftData

struct ExerciseListView: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(profile.name)
                                .font(.title.bold())
                        }
                        
                        Spacer()
                        
                        Text(profile.avatarEmoji)
                            .font(.system(size: 40))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Categories
                    ForEach(GameCategory.allCases) { category in
                        CategorySection(
                            category: category,
                            profile: profile,
                            mockService: mockService
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Train")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CategorySection: View {
    let category: GameCategory
    let profile: UserProfile
    let mockService: MockDataService
    
    private var categoryColor: Color {
        return .royalBlue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Header
            HStack(spacing: 8) {
                Text(category.icon)
                    .font(.title3)
                
                Text(category.rawValue)
                    .font(.headline)
                
                Spacer()
            }
            
            // Games in category
            ForEach(category.games) { gameType in
                NavigationLink {
                    gameView(for: gameType)
                } label: {
                    ExerciseCard(
                        gameType: gameType,
                        stats: GameStatistics.calculate(
                            from: profile.sessions,
                            gameType: gameType,
                            mockService: mockService
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    private func gameView(for gameType: GameType) -> some View {
        switch gameType {
        // Memory
        case .memoryGrid:
            MemoryGridGame(profile: profile, mockService: mockService)
        case .sequenceMemory:
            SequenceMemoryGame(profile: profile, mockService: mockService)
        case .wordRecall:
            WordRecallGame(profile: profile, mockService: mockService)
            
        // Mental Math
        case .mentalMath:
            MentalMathGame(profile: profile, mockService: mockService)
        case .numberComparison:
            NumberComparisonGame(profile: profile, mockService: mockService)
        case .estimation:
            EstimationGame(profile: profile, mockService: mockService)
            
        // Problem Solving
        case .patternMatch:
            PatternMatchGame(profile: profile, mockService: mockService)
        case .logicPuzzle:
            LogicPuzzleGame(profile: profile, mockService: mockService)
        case .towerOfHanoi:
            TowerOfHanoiGame(profile: profile, mockService: mockService)
            
        // Language
        case .wordScramble:
            WordScrambleGame(profile: profile, mockService: mockService)
        case .verbalAnalogies:
            VerbalAnalogiesGame(profile: profile, mockService: mockService)
        case .vocabulary:
            VocabularyGame(profile: profile, mockService: mockService)
        }
    }
}

struct ExerciseCard: View {
    let gameType: GameType
    let stats: GameStatistics
    
    private var accentColor: Color {
        return .royalBlue
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Text(gameType.icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(gameType.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(gameType.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Stats Preview
            if stats.totalGamesPlayed > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(stats.percentile)%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(accentColor)
                    Text("percentile")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, GameSession.self, configurations: config)
    let profile = UserProfile(name: "Test User", avatarEmoji: "🧠")
    container.mainContext.insert(profile)
    
    return ExerciseListView(profile: profile, mockService: MockDataService())
        .modelContainer(container)
}
