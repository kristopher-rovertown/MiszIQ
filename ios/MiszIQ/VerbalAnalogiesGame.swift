import SwiftUI
import SwiftData

struct VerbalAnalogiesGame: View {
    let profile: UserProfile
    let mockService: MockDataService
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .instructions
    @State private var currentAnalogy: Analogy?
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
    
    struct Analogy {
        let wordA: String
        let wordB: String
        let wordC: String
        let options: [String]
        let correctIndex: Int
        let relationship: String
    }
    
    let analogiesByLevel: [[Analogy]] = [
        // Level 1 - Simple relationships (15 analogies)
        [
            Analogy(wordA: "Hot", wordB: "Cold", wordC: "Up", options: ["Down", "High", "Sky", "Left"], correctIndex: 0, relationship: "Opposites"),
            Analogy(wordA: "Dog", wordB: "Puppy", wordC: "Cat", options: ["Kitten", "Feline", "Pet", "Mouse"], correctIndex: 0, relationship: "Adult to young"),
            Analogy(wordA: "Hand", wordB: "Glove", wordC: "Foot", options: ["Sock", "Leg", "Toe", "Walk"], correctIndex: 0, relationship: "Body part to covering"),
            Analogy(wordA: "Bird", wordB: "Fly", wordC: "Fish", options: ["Swim", "Water", "Fin", "Scale"], correctIndex: 0, relationship: "Animal to movement"),
            Analogy(wordA: "Day", wordB: "Night", wordC: "Summer", options: ["Winter", "Hot", "Sun", "Season"], correctIndex: 0, relationship: "Opposites"),
            Analogy(wordA: "Book", wordB: "Read", wordC: "Song", options: ["Listen", "Music", "Note", "Sing"], correctIndex: 0, relationship: "Object to action"),
            Analogy(wordA: "Pen", wordB: "Write", wordC: "Knife", options: ["Cut", "Sharp", "Kitchen", "Metal"], correctIndex: 0, relationship: "Tool to action"),
            Analogy(wordA: "Cow", wordB: "Calf", wordC: "Horse", options: ["Foal", "Stable", "Ride", "Mane"], correctIndex: 0, relationship: "Adult to young"),
            Analogy(wordA: "Big", wordB: "Small", wordC: "Fast", options: ["Slow", "Quick", "Run", "Speed"], correctIndex: 0, relationship: "Opposites"),
            Analogy(wordA: "Apple", wordB: "Fruit", wordC: "Carrot", options: ["Vegetable", "Orange", "Garden", "Eat"], correctIndex: 0, relationship: "Example to category"),
            Analogy(wordA: "Eye", wordB: "See", wordC: "Ear", options: ["Hear", "Sound", "Head", "Music"], correctIndex: 0, relationship: "Organ to function"),
            Analogy(wordA: "Shoe", wordB: "Foot", wordC: "Hat", options: ["Head", "Hair", "Wear", "Top"], correctIndex: 0, relationship: "Clothing to body part"),
            Analogy(wordA: "Bee", wordB: "Hive", wordC: "Ant", options: ["Colony", "Small", "Bug", "Work"], correctIndex: 0, relationship: "Animal to home"),
            Analogy(wordA: "Sad", wordB: "Cry", wordC: "Happy", options: ["Laugh", "Joy", "Smile", "Fun"], correctIndex: 0, relationship: "Emotion to expression"),
            Analogy(wordA: "Milk", wordB: "White", wordC: "Grass", options: ["Green", "Grow", "Field", "Soft"], correctIndex: 0, relationship: "Object to color"),
        ],
        // Level 2 - Moderate relationships (15 analogies)
        [
            Analogy(wordA: "Author", wordB: "Book", wordC: "Composer", options: ["Symphony", "Piano", "Conductor", "Note"], correctIndex: 0, relationship: "Creator to creation"),
            Analogy(wordA: "Hungry", wordB: "Eat", wordC: "Tired", options: ["Sleep", "Bed", "Yawn", "Night"], correctIndex: 0, relationship: "State to remedy"),
            Analogy(wordA: "Tree", wordB: "Forest", wordC: "Star", options: ["Galaxy", "Night", "Bright", "Space"], correctIndex: 0, relationship: "Part to whole"),
            Analogy(wordA: "Doctor", wordB: "Hospital", wordC: "Teacher", options: ["School", "Student", "Lesson", "Book"], correctIndex: 0, relationship: "Professional to workplace"),
            Analogy(wordA: "Hammer", wordB: "Nail", wordC: "Screwdriver", options: ["Screw", "Tool", "Turn", "Fix"], correctIndex: 0, relationship: "Tool to object"),
            Analogy(wordA: "Chapter", wordB: "Book", wordC: "Verse", options: ["Poem", "Word", "Rhyme", "Line"], correctIndex: 0, relationship: "Part to whole"),
            Analogy(wordA: "Painter", wordB: "Canvas", wordC: "Sculptor", options: ["Clay", "Art", "Museum", "Statue"], correctIndex: 0, relationship: "Artist to medium"),
            Analogy(wordA: "Electricity", wordB: "Wire", wordC: "Water", options: ["Pipe", "Wet", "Drink", "Ocean"], correctIndex: 0, relationship: "Resource to conduit"),
            Analogy(wordA: "Lawyer", wordB: "Court", wordC: "Chef", options: ["Kitchen", "Food", "Cook", "Recipe"], correctIndex: 0, relationship: "Professional to workplace"),
            Analogy(wordA: "Caterpillar", wordB: "Butterfly", wordC: "Tadpole", options: ["Frog", "Pond", "Swim", "Green"], correctIndex: 0, relationship: "Young to adult form"),
            Analogy(wordA: "Soldier", wordB: "Army", wordC: "Player", options: ["Team", "Game", "Win", "Sport"], correctIndex: 0, relationship: "Individual to group"),
            Analogy(wordA: "Thermometer", wordB: "Temperature", wordC: "Speedometer", options: ["Speed", "Car", "Fast", "Dashboard"], correctIndex: 0, relationship: "Instrument to measurement"),
            Analogy(wordA: "Key", wordB: "Lock", wordC: "Password", options: ["Account", "Secret", "Type", "Computer"], correctIndex: 0, relationship: "Opener to barrier"),
            Analogy(wordA: "Flour", wordB: "Bread", wordC: "Grapes", options: ["Wine", "Fruit", "Purple", "Vine"], correctIndex: 0, relationship: "Ingredient to product"),
            Analogy(wordA: "Pilot", wordB: "Airplane", wordC: "Captain", options: ["Ship", "Sea", "Sail", "Crew"], correctIndex: 0, relationship: "Operator to vehicle"),
        ],
        // Level 3 - Complex relationships (15 analogies)
        [
            Analogy(wordA: "Eloquent", wordB: "Speech", wordC: "Graceful", options: ["Dance", "Beauty", "Elegant", "Move"], correctIndex: 0, relationship: "Quality to expression"),
            Analogy(wordA: "Vaccine", wordB: "Prevent", wordC: "Medicine", options: ["Cure", "Doctor", "Sick", "Hospital"], correctIndex: 0, relationship: "Treatment to purpose"),
            Analogy(wordA: "Telescope", wordB: "Stars", wordC: "Microscope", options: ["Cells", "Small", "Lab", "Lens"], correctIndex: 0, relationship: "Instrument to observation"),
            Analogy(wordA: "Monarch", wordB: "Kingdom", wordC: "President", options: ["Republic", "Election", "Power", "Leader"], correctIndex: 0, relationship: "Ruler to domain"),
            Analogy(wordA: "Chronological", wordB: "Time", wordC: "Alphabetical", options: ["Letters", "Order", "Words", "Sequence"], correctIndex: 0, relationship: "Order type to basis"),
            Analogy(wordA: "Hypothesis", wordB: "Experiment", wordC: "Blueprint", options: ["Construction", "Building", "Plan", "Design"], correctIndex: 0, relationship: "Plan to execution"),
            Analogy(wordA: "Nomad", wordB: "Wander", wordC: "Hermit", options: ["Isolate", "Cave", "Alone", "Quiet"], correctIndex: 0, relationship: "Person to characteristic action"),
            Analogy(wordA: "Famine", wordB: "Hunger", wordC: "Drought", options: ["Thirst", "Rain", "Desert", "Dry"], correctIndex: 0, relationship: "Disaster to consequence"),
            Analogy(wordA: "Preamble", wordB: "Document", wordC: "Overture", options: ["Opera", "Music", "Begin", "Stage"], correctIndex: 0, relationship: "Introduction to work"),
            Analogy(wordA: "Altruistic", wordB: "Selfless", wordC: "Pragmatic", options: ["Practical", "Smart", "Logical", "Real"], correctIndex: 0, relationship: "Synonyms"),
            Analogy(wordA: "Archipelago", wordB: "Islands", wordC: "Constellation", options: ["Stars", "Night", "Space", "Pattern"], correctIndex: 0, relationship: "Collection to components"),
            Analogy(wordA: "Anesthesia", wordB: "Pain", wordC: "Censorship", options: ["Information", "Government", "Media", "Ban"], correctIndex: 0, relationship: "Suppressor to target"),
            Analogy(wordA: "Plagiarism", wordB: "Writing", wordC: "Counterfeiting", options: ["Currency", "Crime", "Fake", "Money"], correctIndex: 0, relationship: "Fraud type to domain"),
            Analogy(wordA: "Herbivore", wordB: "Plants", wordC: "Carnivore", options: ["Meat", "Animals", "Hunt", "Teeth"], correctIndex: 0, relationship: "Eater to food source"),
            Analogy(wordA: "Euphoria", wordB: "Joy", wordC: "Melancholy", options: ["Sadness", "Mood", "Quiet", "Tears"], correctIndex: 0, relationship: "Intense form to basic emotion"),
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
        .navigationTitle("Analogies")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 60))
                .foregroundStyle(Color.turquoise)
            
            Text("Verbal Analogies")
                .font(.title.bold())
            
            VStack(spacing: 12) {
                Text("Complete the relationship:")
                    .font(.headline)
                
                Text("A is to B as C is to ?")
                    .font(.title3)
                    .foregroundStyle(Color.turquoise)
                
                Text("Find the word that completes the same relationship pattern.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
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
                    .background(Color.turquoise)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 24) {
            if let analogy = currentAnalogy {
                // Analogy display
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        WordBox(word: analogy.wordA, color: Color.turquoise)
                        Text(":")
                            .font(.title2.bold())
                        WordBox(word: analogy.wordB, color: Color.turquoise)
                    }
                    
                    Text("::")
                        .font(.title.bold())
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        WordBox(word: analogy.wordC, color: Color.turquoise)
                        Text(":")
                            .font(.title2.bold())
                        WordBox(word: "?", color: Color.turquoise.opacity(0.3))
                    }
                }
                .padding()
                
                // Options
                VStack(spacing: 12) {
                    ForEach(analogy.options.indices, id: \.self) { index in
                        Button {
                            selectedAnswer = index
                        } label: {
                            HStack {
                                Text(optionLabel(index))
                                    .font(.headline)
                                    .foregroundStyle(Color.turquoise)
                                    .frame(width: 30)
                                
                                Text(analogy.options[index])
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
        guard let analogy = currentAnalogy else { return AnyView(EmptyView()) }
        let isCorrect = selectedAnswer == analogy.correctIndex
        
        return AnyView(
            VStack(spacing: 24) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Correct!" : "Not quite...")
                    .font(.title.bold())
                
                VStack(spacing: 12) {
                    Text("The relationship is:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(analogy.relationship)
                        .font(.headline)
                        .foregroundStyle(Color.turquoise)
                    
                    HStack(spacing: 8) {
                        Text(analogy.wordA)
                        Text(":")
                        Text(analogy.wordB)
                        Text("::")
                        Text(analogy.wordC)
                        Text(":")
                        Text(analogy.options[analogy.correctIndex])
                            .fontWeight(.bold)
                            .foregroundStyle(Color.turquoise)
                    }
                    .font(.body)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
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
        let percentile = mockService.calculatePercentile(score: score, for: .verbalAnalogies)
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
        let levelAnalogies = analogiesByLevel[min(level - 1, analogiesByLevel.count - 1)]
        currentAnalogy = levelAnalogies.randomElement()
        selectedAnswer = nil
    }
    
    private func submitAnswer() {
        guard let analogy = currentAnalogy, let answer = selectedAnswer else { return }

        if answer == analogy.correctIndex {
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
            gameType: .verbalAnalogies,
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

struct WordBox: View {
    let word: String
    let color: Color
    
    var body: some View {
        Text(word)
            .font(.title3.bold())
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color.opacity(0.15))
            .foregroundStyle(color == .green.opacity(0.3) ? .secondary : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        VerbalAnalogiesGame(profile: UserProfile(name: "Test"), mockService: MockDataService())
    }
}
