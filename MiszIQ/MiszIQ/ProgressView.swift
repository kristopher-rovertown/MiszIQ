import SwiftUI
import SwiftData
import Charts

struct UserProgressView: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @State private var selectedCategory: GameCategory = .memory
    @State private var selectedGameType: GameType = .memoryGrid
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Category Picker
                    CategoryPicker(selectedCategory: $selectedCategory)
                        .padding(.horizontal)
                        .onChange(of: selectedCategory) { _, newCategory in
                            selectedGameType = newCategory.games.first ?? .memoryGrid
                        }
                    
                    // Game Type Picker within category
                    GameTypePicker(
                        games: selectedCategory.games,
                        selectedGameType: $selectedGameType
                    )
                    .padding(.horizontal)
                    
                    let stats = GameStatistics.calculate(
                        from: profile.sessions,
                        gameType: selectedGameType,
                        mockService: mockService
                    )
                    
                    if stats.totalGamesPlayed == 0 {
                        ContentUnavailableView {
                            Label("No Data Yet", systemImage: "chart.line.uptrend.xyaxis")
                        } description: {
                            Text("Complete some \(selectedGameType.rawValue) sessions to see your progress")
                        }
                        .frame(height: 300)
                    } else {
                        PercentileCard(stats: stats, mockService: mockService)
                            .padding(.horizontal)
                        
                        StatsGrid(stats: stats)
                            .padding(.horizontal)
                        
                        ScoreHistoryChart(
                            sessions: profile.sessions.filter { $0.gameType == selectedGameType.rawValue }
                        )
                        .padding(.horizontal)
                        
                        RecentSessionsList(
                            sessions: profile.sessions.filter { $0.gameType == selectedGameType.rawValue }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Progress")
        }
    }
}

struct CategoryPicker: View {
    @Binding var selectedCategory: GameCategory
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(GameCategory.allCases) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(category.icon)
                            .font(.system(size: 16))
                        Text(shortName(for: category))
                            .font(.caption2.weight(.medium))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(selectedCategory == category ? categoryColor(category).opacity(0.15) : Color.clear)
                    .foregroundStyle(selectedCategory == category ? categoryColor(category) : .secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func shortName(for category: GameCategory) -> String {
        switch category {
        case .memory: return "Memory"
        case .mentalMath: return "Math"
        case .problemSolving: return "Logic"
        case .language: return "Language"
        }
    }
    
    private func categoryColor(_ category: GameCategory) -> Color {
        return .royalBlue
    }
}

struct GameTypePicker: View {
    let games: [GameType]
    @Binding var selectedGameType: GameType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(games) { game in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedGameType = game
                        }
                    } label: {
                        Text(game.rawValue)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedGameType == game ? gameColor(game).opacity(0.15) : Color(.systemBackground))
                            .foregroundStyle(selectedGameType == game ? gameColor(game) : .secondary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedGameType == game ? gameColor(game).opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func gameColor(_ game: GameType) -> Color {
        return .royalBlue
    }
}

struct PercentileCard: View {
    let stats: GameStatistics
    let mockService: MockDataService

    var body: some View {
        let bracket = mockService.getPerformanceBracket(percentile: stats.percentile)
        let bracketColor: Color = AppTheme.bracketColor(for: stats.percentile)

        VStack(spacing: 12) {
            HStack {
                Text("Your Ranking")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: stats.recentTrend.icon)
                    Text(trendLabel(stats.recentTrend))
                        .font(.caption)
                }
                .foregroundStyle(trendColor(stats.recentTrend))
            }

            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(stats.percentile)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(bracketColor)

                    Text("percentile")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Text(bracket.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(bracketColor)
                Text(bracket.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(bracketColor.gradient)
                        .frame(width: geometry.size.width * CGFloat(stats.percentile) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func trendColor(_ trend: GameStatistics.Trend) -> Color {
        switch trend {
        case .improving: return .green
        case .declining: return .red
        case .stable: return .secondary
        }
    }
    
    private func trendLabel(_ trend: GameStatistics.Trend) -> String {
        switch trend {
        case .improving: return "Improving"
        case .declining: return "Declining"
        case .stable: return "Stable"
        }
    }
}

struct StatsGrid: View {
    let stats: GameStatistics
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            StatCard(title: "High Score", value: "\(stats.highScore)", icon: "trophy.fill", color: Color.turquoise)
            StatCard(title: "Average", value: String(format: "%.0f", stats.averageScore), icon: "chart.bar.fill", color: Color.royalBlue)
            StatCard(title: "Games", value: "\(stats.totalGamesPlayed)", icon: "gamecontroller.fill", color: Color.turquoise)
            StatCard(title: "Accuracy", value: String(format: "%.0f%%", stats.averageAccuracy), icon: "target", color: Color.royalBlue)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(color)

            Text(value)
                .font(.title3.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ScoreHistoryChart: View {
    let sessions: [GameSession]
    
    var sortedSessions: [GameSession] {
        sessions.sorted { $0.completedAt < $1.completedAt }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Score History")
                .font(.headline)
            
            if sortedSessions.count < 2 {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.title2)
                            .foregroundStyle(.tertiary)
                        Text("Play more games to see trends")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(height: 100)
            } else {
                Chart {
                    ForEach(Array(sortedSessions.enumerated()), id: \.element.id) { index, session in
                        AreaMark(
                            x: .value("Game", index + 1),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(Color.royalBlue.opacity(0.1))
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Game", index + 1),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(Color.royalBlue)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Game", index + 1),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(Color.turquoise)
                        .symbolSize(25)
                    }
                }
                .frame(height: 120)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct RecentSessionsList: View {
    let sessions: [GameSession]
    
    var recentSessions: [GameSession] {
        Array(sessions.sorted { $0.completedAt > $1.completedAt }.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Sessions")
                .font(.headline)
            
            if recentSessions.isEmpty {
                HStack {
                    Spacer()
                    Text("No sessions yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                ForEach(recentSessions) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Score: \(session.score)")
                                .font(.subheadline.weight(.semibold))
                            Text(session.completedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("Lvl \(session.level)")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.royalBlue.opacity(0.1))
                            .foregroundStyle(Color.royalBlue)
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 2)
                    
                    if session.id != recentSessions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, GameSession.self, configurations: config)
    let profile = UserProfile(name: "Test User", avatarEmoji: "🧠")
    container.mainContext.insert(profile)
    
    return UserProgressView(profile: profile, mockService: MockDataService())
        .modelContainer(container)
}
