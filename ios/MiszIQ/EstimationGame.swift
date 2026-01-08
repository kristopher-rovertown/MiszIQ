import SwiftUI
import SwiftData

struct EstimationGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var currentQuestion: EstimationQuestion?
    @State private var userEstimate: Double = 50
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var showFeedback = false
    @State private var lastAccuracy: Double = 0
    
    enum GameState {
        case instructions, playing, feedback, gameOver
    }
    
    struct EstimationQuestion {
        let prompt: String
        let actualValue: Double
        let unit: String
        let minSlider: Double
        let maxSlider: Double
        let hint: String
        
        var tolerancePercent: Double { 0.20 } // 20% tolerance for full points
    }
    
    let questions: [EstimationQuestion] = [
        // Quantities
        EstimationQuestion(prompt: "How many keys on a standard piano?", actualValue: 88, unit: "keys", minSlider: 40, maxSlider: 120, hint: "Musical instrument"),
        EstimationQuestion(prompt: "How many bones in the adult human body?", actualValue: 206, unit: "bones", minSlider: 100, maxSlider: 350, hint: "Anatomy"),
        EstimationQuestion(prompt: "How many countries in Africa?", actualValue: 54, unit: "countries", minSlider: 20, maxSlider: 80, hint: "Geography"),
        EstimationQuestion(prompt: "How many teeth does an adult human have?", actualValue: 32, unit: "teeth", minSlider: 16, maxSlider: 48, hint: "Anatomy"),
        EstimationQuestion(prompt: "How many cards in a standard deck?", actualValue: 52, unit: "cards", minSlider: 30, maxSlider: 80, hint: "Games"),
        EstimationQuestion(prompt: "How many chromosomes in a human cell?", actualValue: 46, unit: "chromosomes", minSlider: 20, maxSlider: 80, hint: "Biology"),
        EstimationQuestion(prompt: "How many elements in the periodic table?", actualValue: 118, unit: "elements", minSlider: 80, maxSlider: 150, hint: "Chemistry"),
        EstimationQuestion(prompt: "How many squares on a chess board?", actualValue: 64, unit: "squares", minSlider: 36, maxSlider: 100, hint: "Games"),
        EstimationQuestion(prompt: "How many players on a soccer team?", actualValue: 11, unit: "players", minSlider: 5, maxSlider: 18, hint: "Sports"),
        EstimationQuestion(prompt: "How many letters in the English alphabet?", actualValue: 26, unit: "letters", minSlider: 20, maxSlider: 35, hint: "Language"),

        // Percentages
        EstimationQuestion(prompt: "What percent of Earth's surface is water?", actualValue: 71, unit: "%", minSlider: 40, maxSlider: 95, hint: "Geography"),
        EstimationQuestion(prompt: "What percent of the human body is water?", actualValue: 60, unit: "%", minSlider: 30, maxSlider: 90, hint: "Biology"),
        EstimationQuestion(prompt: "What percent of Earth's atmosphere is nitrogen?", actualValue: 78, unit: "%", minSlider: 40, maxSlider: 100, hint: "Science"),
        EstimationQuestion(prompt: "What percent of the brain is fat?", actualValue: 60, unit: "%", minSlider: 20, maxSlider: 80, hint: "Biology"),
        EstimationQuestion(prompt: "What percent of Earth is covered by forests?", actualValue: 31, unit: "%", minSlider: 10, maxSlider: 60, hint: "Geography"),
        EstimationQuestion(prompt: "What percent of oxygen is in air?", actualValue: 21, unit: "%", minSlider: 10, maxSlider: 40, hint: "Science"),

        // Distances/Sizes
        EstimationQuestion(prompt: "Height of the Eiffel Tower in meters?", actualValue: 330, unit: "m", minSlider: 150, maxSlider: 500, hint: "Architecture"),
        EstimationQuestion(prompt: "Length of a marathon in kilometers?", actualValue: 42, unit: "km", minSlider: 20, maxSlider: 60, hint: "Sports"),
        EstimationQuestion(prompt: "Speed of sound in m/s (at sea level)?", actualValue: 343, unit: "m/s", minSlider: 200, maxSlider: 500, hint: "Physics"),
        EstimationQuestion(prompt: "Height of Mount Everest in meters?", actualValue: 8849, unit: "m", minSlider: 6000, maxSlider: 12000, hint: "Geography"),
        EstimationQuestion(prompt: "Depth of the Mariana Trench in meters?", actualValue: 10994, unit: "m", minSlider: 5000, maxSlider: 15000, hint: "Geography"),
        EstimationQuestion(prompt: "Length of the Great Wall of China in km?", actualValue: 21196, unit: "km", minSlider: 5000, maxSlider: 30000, hint: "Architecture"),
        EstimationQuestion(prompt: "Diameter of the Moon in kilometers?", actualValue: 3474, unit: "km", minSlider: 2000, maxSlider: 5000, hint: "Astronomy"),
        EstimationQuestion(prompt: "Average depth of the ocean in meters?", actualValue: 3688, unit: "m", minSlider: 1500, maxSlider: 6000, hint: "Geography"),

        // Time
        EstimationQuestion(prompt: "How many days in a year?", actualValue: 365, unit: "days", minSlider: 300, maxSlider: 400, hint: "Calendar"),
        EstimationQuestion(prompt: "Average human heart beats per minute?", actualValue: 72, unit: "bpm", minSlider: 40, maxSlider: 120, hint: "Biology"),
        EstimationQuestion(prompt: "Hours of daylight at equator on equinox?", actualValue: 12, unit: "hours", minSlider: 6, maxSlider: 18, hint: "Astronomy"),
        EstimationQuestion(prompt: "Average human lifespan in years?", actualValue: 73, unit: "years", minSlider: 50, maxSlider: 100, hint: "Biology"),
        EstimationQuestion(prompt: "How many seconds in an hour?", actualValue: 3600, unit: "seconds", minSlider: 2000, maxSlider: 5000, hint: "Math"),
        EstimationQuestion(prompt: "How many hours does a koala sleep per day?", actualValue: 22, unit: "hours", minSlider: 10, maxSlider: 24, hint: "Animals"),
        EstimationQuestion(prompt: "Length of an Olympic swimming pool in meters?", actualValue: 50, unit: "m", minSlider: 25, maxSlider: 100, hint: "Sports"),

        // Misc
        EstimationQuestion(prompt: "Number of US states?", actualValue: 50, unit: "states", minSlider: 30, maxSlider: 70, hint: "Geography"),
        EstimationQuestion(prompt: "Boiling point of water in °C?", actualValue: 100, unit: "°C", minSlider: 60, maxSlider: 150, hint: "Science"),
        EstimationQuestion(prompt: "Freezing point of water in °F?", actualValue: 32, unit: "°F", minSlider: 0, maxSlider: 60, hint: "Science"),
        EstimationQuestion(prompt: "How many minutes in a day?", actualValue: 1440, unit: "min", minSlider: 800, maxSlider: 2000, hint: "Math"),
        EstimationQuestion(prompt: "How many muscles in the human body?", actualValue: 600, unit: "muscles", minSlider: 300, maxSlider: 900, hint: "Anatomy"),
        EstimationQuestion(prompt: "Speed of light in km per second?", actualValue: 300000, unit: "km/s", minSlider: 150000, maxSlider: 400000, hint: "Physics"),
        EstimationQuestion(prompt: "Average temperature on Mars in °C?", actualValue: -60, unit: "°C", minSlider: -120, maxSlider: 0, hint: "Astronomy"),
        EstimationQuestion(prompt: "How many taste buds on human tongue?", actualValue: 10000, unit: "buds", minSlider: 3000, maxSlider: 20000, hint: "Anatomy"),
        EstimationQuestion(prompt: "Weight of an adult blue whale in tons?", actualValue: 150, unit: "tons", minSlider: 50, maxSlider: 250, hint: "Animals"),
        EstimationQuestion(prompt: "How many species of birds exist?", actualValue: 10000, unit: "species", minSlider: 5000, maxSlider: 20000, hint: "Animals"),
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
        .navigationTitle("Estimation")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Estimation")
                .font(.title.bold())
            
            Text("Estimate quantities, distances, and percentages. The closer you are to the actual value, the more points you earn!")
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
            if let question = currentQuestion {
                // Question
                VStack(spacing: 12) {
                    Text(question.hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.royalBlue.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Text(question.prompt)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Current estimate display
                VStack(spacing: 8) {
                    Text(formatValue(userEstimate, unit: question.unit))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.royalBlue)
                    
                    Text(question.unit)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 20)
                
                // Slider
                VStack(spacing: 8) {
                    Slider(value: $userEstimate, in: question.minSlider...question.maxSlider, step: getStep(for: question))
                        .tint(Color.royalBlue)
                        .padding(.horizontal)
                    
                    HStack {
                        Text(formatValue(question.minSlider, unit: question.unit))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(formatValue(question.maxSlider, unit: question.unit))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                Button {
                    submitEstimate()
                } label: {
                    Text("Lock In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.royalBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
        }
    }
    
    private var feedbackView: some View {
        guard let question = currentQuestion else { return AnyView(EmptyView()) }
        
        let accuracy = calculateAccuracy(estimate: userEstimate, actual: question.actualValue)
        let pointsEarned = calculatePoints(accuracy: accuracy)
        
        return AnyView(
            VStack(spacing: 24) {
                // Accuracy indicator
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: accuracy)
                        .stroke(accuracyColor(accuracy), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(accuracy * 100))%")
                            .font(.title.bold())
                        Text("accurate")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Results
                VStack(spacing: 8) {
                    HStack {
                        Text("Your estimate:")
                        Spacer()
                        Text(formatValue(userEstimate, unit: question.unit))
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Actual value:")
                        Spacer()
                        Text(formatValue(question.actualValue, unit: question.unit))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.royalBlue)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Points earned:")
                        Spacer()
                        Text("+\(pointsEarned)")
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
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
                        .background(Color.royalBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
            }
        )
    }
    
    private var gameOverView: some View {
        let percentile = mockService.calculatePercentile(score: score, for: .estimation)
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
    
    private func formatValue(_ value: Double, unit: String) -> String {
        if value >= 1000 {
            return String(format: "%.0f", value)
        } else if value == floor(value) {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    private func getStep(for question: EstimationQuestion) -> Double {
        let range = question.maxSlider - question.minSlider
        if range > 500 { return 10 }
        if range > 100 { return 5 }
        if range > 50 { return 1 }
        return 0.5
    }
    
    private func calculateAccuracy(estimate: Double, actual: Double) -> Double {
        let error = abs(estimate - actual) / actual
        return max(0, 1 - error)
    }
    
    private func calculatePoints(accuracy: Double) -> Int {
        if accuracy >= 0.95 { return 15 * level }
        if accuracy >= 0.80 { return 10 * level }
        if accuracy >= 0.60 { return 5 * level }
        if accuracy >= 0.40 { return 2 * level }
        return 0
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.80 { return .green }
        if accuracy >= 0.60 { return .yellow }
        if accuracy >= 0.40 { return .orange }
        return .red
    }
    
    private func startGame() {
        startTime = Date()
        generateRound()
        gameState = .playing
    }
    
    private func generateRound() {
        currentQuestion = questions.randomElement()
        if let question = currentQuestion {
            userEstimate = (question.minSlider + question.maxSlider) / 2
        }
    }
    
    private func submitEstimate() {
        guard let question = currentQuestion else { return }
        let accuracy = calculateAccuracy(estimate: userEstimate, actual: question.actualValue)
        let points = calculatePoints(accuracy: accuracy)
        score += points
        lastAccuracy = accuracy

        if accuracy >= 0.6 {
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
            gameType: .estimation,
            score: score,
            maxPossibleScore: 315,  // 3×15 + 3×30 + 4×45 = 315
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

#Preview {
    NavigationStack {
        EstimationGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
