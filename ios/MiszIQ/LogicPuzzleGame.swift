import SwiftUI
import SwiftData

struct LogicPuzzleGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var currentPuzzle: LogicPuzzle?
    @State private var selectedAnswer: Int? = nil
    @State private var score = 0
    @State private var round = 1
    @State private var level = 1
    @State private var startTime = Date()
    @State private var correctAnswers = 0
    @State private var showFeedback = false
    
    enum GameState {
        case instructions, playing, feedback, gameOver
    }
    
    struct LogicPuzzle {
        let premise: [String]
        let question: String
        let options: [String]
        let correctIndex: Int
        let explanation: String
    }
    
    let puzzles: [[LogicPuzzle]] = [
        // Level 1 - Simple comparisons (10 puzzles)
        [
            LogicPuzzle(
                premise: ["Alice is taller than Bob.", "Bob is taller than Carol."],
                question: "Who is the shortest?",
                options: ["Alice", "Bob", "Carol", "Cannot determine"],
                correctIndex: 2,
                explanation: "Carol is shortest since Bob is taller than Carol, and Alice is taller than Bob."
            ),
            LogicPuzzle(
                premise: ["The red box is heavier than the blue box.", "The green box is lighter than the blue box."],
                question: "Which box is the heaviest?",
                options: ["Red", "Blue", "Green", "Cannot determine"],
                correctIndex: 0,
                explanation: "Red > Blue > Green, so Red is heaviest."
            ),
            LogicPuzzle(
                premise: ["All cats are animals.", "Whiskers is a cat."],
                question: "What can we conclude about Whiskers?",
                options: ["Whiskers is not an animal", "Whiskers is an animal", "Whiskers is a dog", "Nothing"],
                correctIndex: 1,
                explanation: "Since all cats are animals and Whiskers is a cat, Whiskers must be an animal."
            ),
            LogicPuzzle(
                premise: ["If it rains, the ground gets wet.", "It is raining."],
                question: "What can we conclude?",
                options: ["The ground is dry", "The ground is wet", "It might rain", "Nothing"],
                correctIndex: 1,
                explanation: "If P then Q, and P is true, therefore Q must be true."
            ),
            LogicPuzzle(
                premise: ["All birds have feathers.", "Sparrows are birds."],
                question: "What can we conclude about sparrows?",
                options: ["Sparrows don't have feathers", "Sparrows have feathers", "Sparrows can't fly", "Nothing"],
                correctIndex: 1,
                explanation: "Since all birds have feathers and sparrows are birds, sparrows have feathers."
            ),
            LogicPuzzle(
                premise: ["Emma is older than Fiona.", "Grace is older than Emma."],
                question: "Who is the oldest?",
                options: ["Emma", "Fiona", "Grace", "Cannot determine"],
                correctIndex: 2,
                explanation: "Grace > Emma > Fiona, so Grace is oldest."
            ),
            LogicPuzzle(
                premise: ["The pizza costs more than the salad.", "The soup costs less than the salad."],
                question: "What is the cheapest item?",
                options: ["Pizza", "Salad", "Soup", "Cannot determine"],
                correctIndex: 2,
                explanation: "Pizza > Salad > Soup, so soup is cheapest."
            ),
            LogicPuzzle(
                premise: ["If you exercise, you get stronger.", "Sam exercises every day."],
                question: "What can we conclude about Sam?",
                options: ["Sam is weak", "Sam gets stronger", "Sam is tired", "Nothing"],
                correctIndex: 1,
                explanation: "Since exercising makes you stronger and Sam exercises, Sam gets stronger."
            ),
            LogicPuzzle(
                premise: ["All roses are flowers.", "All flowers need water."],
                question: "What can we conclude about roses?",
                options: ["Roses don't need water", "Roses need water", "Roses are red", "Nothing"],
                correctIndex: 1,
                explanation: "Roses are flowers, and all flowers need water, so roses need water."
            ),
            LogicPuzzle(
                premise: ["Max runs faster than Lily.", "Lily runs faster than Noah."],
                question: "Who runs the slowest?",
                options: ["Max", "Lily", "Noah", "Cannot determine"],
                correctIndex: 2,
                explanation: "Max > Lily > Noah in speed, so Noah is slowest."
            ),
        ],
        // Level 2 - More complex (10 puzzles)
        [
            LogicPuzzle(
                premise: ["Either John or Mary took the last cookie.", "John was at work all day."],
                question: "Who took the cookie?",
                options: ["John", "Mary", "Both", "Neither"],
                correctIndex: 1,
                explanation: "Since John was at work and couldn't have taken it, Mary must have."
            ),
            LogicPuzzle(
                premise: ["All doctors are smart.", "Some smart people are rich.", "Dr. Smith is a doctor."],
                question: "What MUST be true about Dr. Smith?",
                options: ["Dr. Smith is rich", "Dr. Smith is smart", "Dr. Smith is not rich", "Dr. Smith is poor"],
                correctIndex: 1,
                explanation: "All doctors are smart, and Dr. Smith is a doctor, so Dr. Smith must be smart. Being rich is only 'some', not guaranteed."
            ),
            LogicPuzzle(
                premise: ["The meeting is on Monday or Tuesday.", "If it's Monday, bring coffee.", "You don't need to bring coffee."],
                question: "When is the meeting?",
                options: ["Monday", "Tuesday", "Wednesday", "Cannot determine"],
                correctIndex: 1,
                explanation: "If it were Monday, you'd need coffee. You don't need coffee, so it's not Monday. Therefore, it's Tuesday."
            ),
            LogicPuzzle(
                premise: ["A is before B.", "C is after B.", "D is before A."],
                question: "What is the correct order?",
                options: ["D, A, B, C", "A, B, C, D", "D, B, A, C", "C, B, A, D"],
                correctIndex: 0,
                explanation: "D before A, A before B, B before C gives us D, A, B, C."
            ),
            LogicPuzzle(
                premise: ["No fish can walk.", "A salmon is a fish."],
                question: "What can we conclude about salmon?",
                options: ["Salmon can walk", "Salmon cannot walk", "Salmon can fly", "Nothing"],
                correctIndex: 1,
                explanation: "No fish can walk and salmon is a fish, so salmon cannot walk."
            ),
            LogicPuzzle(
                premise: ["If it's a weekday, the store is open.", "If the store is open, I can buy milk.", "Today is Wednesday."],
                question: "Can I buy milk today?",
                options: ["No", "Yes", "Maybe", "Cannot determine"],
                correctIndex: 1,
                explanation: "Wednesday is a weekday, so the store is open, so I can buy milk."
            ),
            LogicPuzzle(
                premise: ["Either the bus or the train is late.", "The train arrived on time."],
                question: "What can we conclude?",
                options: ["The bus is on time", "The bus is late", "Both are late", "Nothing"],
                correctIndex: 1,
                explanation: "Since one must be late and the train is on time, the bus must be late."
            ),
            LogicPuzzle(
                premise: ["All planets orbit the sun.", "Earth is a planet.", "The moon orbits Earth."],
                question: "What MUST be true?",
                options: ["The moon orbits the sun", "Earth orbits the sun", "The moon is a planet", "Nothing"],
                correctIndex: 1,
                explanation: "Earth is a planet, and all planets orbit the sun, so Earth orbits the sun."
            ),
            LogicPuzzle(
                premise: ["Red is left of Blue.", "Green is right of Blue.", "Yellow is left of Red."],
                question: "What is the order from left to right?",
                options: ["Yellow, Red, Blue, Green", "Red, Yellow, Blue, Green", "Green, Blue, Red, Yellow", "Blue, Red, Yellow, Green"],
                correctIndex: 0,
                explanation: "Yellow is left of Red, Red is left of Blue, Blue is left of Green."
            ),
            LogicPuzzle(
                premise: ["All squares are rectangles.", "All rectangles have four sides.", "This shape is a square."],
                question: "How many sides does this shape have?",
                options: ["Three", "Four", "Five", "Cannot determine"],
                correctIndex: 1,
                explanation: "Squares are rectangles, rectangles have four sides, so this square has four sides."
            ),
        ],
        // Level 3 - Complex puzzles (10 puzzles)
        [
            LogicPuzzle(
                premise: ["If it's sunny, I go to the beach.", "If I go to the beach, I get a tan.", "I did not get a tan."],
                question: "What can we conclude about the weather?",
                options: ["It was sunny", "It was not sunny", "I went to the beach", "Cannot determine"],
                correctIndex: 1,
                explanation: "No tan → didn't go to beach → wasn't sunny (contrapositive reasoning)."
            ),
            LogicPuzzle(
                premise: ["Every student who studies passes.", "Alex didn't pass.", "Beth studied."],
                question: "What MUST be true?",
                options: ["Alex studied", "Alex didn't study", "Beth didn't pass", "Beth passed"],
                correctIndex: 1,
                explanation: "If Alex studied, Alex would pass. Alex didn't pass, so Alex didn't study. Beth studied, so Beth passed."
            ),
            LogicPuzzle(
                premise: ["No reptiles have fur.", "All snakes are reptiles.", "Some pets have fur."],
                question: "What can we conclude?",
                options: ["Some pets are snakes", "No snakes have fur", "All pets are reptiles", "Some snakes have fur"],
                correctIndex: 1,
                explanation: "Snakes are reptiles, and no reptiles have fur, so no snakes have fur."
            ),
            LogicPuzzle(
                premise: ["Tom is older than Jane.", "Jane is older than Mike.", "Sara is younger than Mike but older than Lee."],
                question: "Who is the second youngest?",
                options: ["Tom", "Jane", "Mike", "Sara"],
                correctIndex: 3,
                explanation: "Order: Tom > Jane > Mike > Sara > Lee. Second youngest is Sara."
            ),
            LogicPuzzle(
                premise: ["If A, then B.", "If B, then C.", "If C, then D.", "D is false."],
                question: "What can we conclude about A?",
                options: ["A is true", "A is false", "A might be true", "Cannot determine"],
                correctIndex: 1,
                explanation: "If D is false, then C must be false, then B must be false, then A must be false."
            ),
            LogicPuzzle(
                premise: ["All managers attend meetings.", "No interns attend meetings.", "Chris attends meetings."],
                question: "What can we conclude about Chris?",
                options: ["Chris is an intern", "Chris is not an intern", "Chris is a manager", "Nothing certain"],
                correctIndex: 1,
                explanation: "Since no interns attend meetings and Chris attends meetings, Chris is not an intern."
            ),
            LogicPuzzle(
                premise: ["Either the red wire or the blue wire is live.", "If the red wire is live, the alarm sounds.", "The alarm is silent."],
                question: "Which wire is live?",
                options: ["Red wire", "Blue wire", "Both", "Neither"],
                correctIndex: 1,
                explanation: "If red were live, the alarm would sound. The alarm is silent, so red is not live. Thus blue is live."
            ),
            LogicPuzzle(
                premise: ["X is north of Y.", "Z is east of Y.", "W is south of Z.", "W is east of Y."],
                question: "Which location is furthest west?",
                options: ["X", "Y", "Z", "W"],
                correctIndex: 1,
                explanation: "Z and W are east of Y, X is north of Y (same longitude). Y is furthest west."
            ),
            LogicPuzzle(
                premise: ["Some artists are musicians.", "All musicians practice daily.", "Jane is an artist who practices daily."],
                question: "Is Jane a musician?",
                options: ["Yes, definitely", "No, definitely not", "Maybe", "Cannot determine"],
                correctIndex: 3,
                explanation: "Jane practices daily, but we can't conclude she's a musician—she might practice art daily."
            ),
            LogicPuzzle(
                premise: ["If guilty, then evidence exists.", "If evidence exists, then arrested.", "Not arrested."],
                question: "What can we conclude?",
                options: ["Guilty", "Not guilty", "Evidence exists", "Cannot determine"],
                correctIndex: 1,
                explanation: "Not arrested → no evidence → not guilty (contrapositive chain)."
            ),
        ]
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(level)")
                        .font(.headline)
                    Text("Round \(round)/8")
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
        .navigationTitle("Logic Puzzle")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundStyle(Color.royalBlue)
            
            Text("Logic Puzzle")
                .font(.title.bold())
            
            Text("Read the premises carefully and use logical reasoning to answer the question. Take your time!")
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
        ScrollView {
            VStack(spacing: 20) {
                if let puzzle = currentPuzzle {
                    // Premises
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Given:")
                            .font(.headline)
                            .foregroundStyle(Color.royalBlue)
                        
                        ForEach(puzzle.premise.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundStyle(Color.royalBlue)
                                Text(puzzle.premise[index])
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Question
                    Text(puzzle.question)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Options
                    VStack(spacing: 12) {
                        ForEach(puzzle.options.indices, id: \.self) { index in
                            Button {
                                selectAnswer(index)
                            } label: {
                                HStack {
                                    Text(optionLabel(index))
                                        .font(.headline)
                                        .foregroundStyle(Color.royalBlue)
                                        .frame(width: 30)
                                    
                                    Text(puzzle.options[index])
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAnswer == index ? Color.royalBlue : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    if selectedAnswer != nil {
                        Button {
                            submitAnswer()
                        } label: {
                            Text("Submit")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.royalBlue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .padding()
        }
    }
    
    private var feedbackView: some View {
        guard let puzzle = currentPuzzle else { return AnyView(EmptyView()) }
        let isCorrect = selectedAnswer == puzzle.correctIndex
        
        return AnyView(
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(isCorrect ? .green : .red)
                    
                    Text(isCorrect ? "Correct!" : "Not quite...")
                        .font(.title.bold())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Correct answer:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(puzzle.options[puzzle.correctIndex])
                            .font(.headline)
                            .foregroundStyle(Color.royalBlue)
                        
                        Text("Explanation:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                        Text(puzzle.explanation)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
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
                }
                .padding()
            }
        )
    }
    
    private var gameOverView: some View {
        let percentile = mockService.calculatePercentile(score: score, for: .logicPuzzle)
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
            
            Text("\(correctAnswers)/8 Correct")
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
    
    private func startGame() {
        startTime = Date()
        generateRound()
        gameState = .playing
    }
    
    private func generateRound() {
        let levelPuzzles = puzzles[min(level - 1, puzzles.count - 1)]
        currentPuzzle = levelPuzzles.randomElement()
        selectedAnswer = nil
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
    }
    
    private func submitAnswer() {
        guard let puzzle = currentPuzzle, let answer = selectedAnswer else { return }

        if answer == puzzle.correctIndex {
            correctAnswers += 1
            score += 15 * level
            AudioManager.shared.playSoundEffect(.correctAnswer)
            HapticManager.shared.correctAnswer()
        } else {
            AudioManager.shared.playSoundEffect(.wrongAnswer)
            HapticManager.shared.wrongAnswer()
        }

        gameState = .feedback
    }
    
    private func nextRound() {
        if round >= 8 {
            saveSession()
            gameState = .gameOver
        } else {
            round += 1
            if round == 3 { level = 2 }
            if round == 6 { level = 3 }
            generateRound()
            gameState = .playing
        }
    }
    
    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = GameSession(
            gameType: .logicPuzzle,
            score: score,
            maxPossibleScore: 255,  // 2×15 + 3×30 + 3×45 = 255
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
        LogicPuzzleGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
