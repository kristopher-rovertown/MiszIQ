import SwiftUI
import SwiftData

struct DifficultySelector: View {
    let profile: UserProfile
    let gameType: GameType
    @Binding var selectedLevel: Int
    let onStart: () -> Void

    private var maxUnlockedLevel: Int {
        BadgeManager.getMaxUnlockedLevel(profile: profile, gameType: gameType)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Select Difficulty")
                .font(.title2.bold())

            VStack(spacing: 12) {
                ForEach(1...3, id: \.self) { level in
                    let isUnlocked = level <= maxUnlockedLevel
                    DifficultyRow(
                        level: level,
                        isSelected: selectedLevel == level,
                        isUnlocked: isUnlocked
                    ) {
                        if isUnlocked {
                            selectedLevel = level
                        }
                    }
                }
            }
            .padding(.horizontal)

            if maxUnlockedLevel < 3 {
                Text("Achieve 100% accuracy to unlock higher levels")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                onStart()
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
}

struct DifficultyRow: View {
    let level: Int
    let isSelected: Bool
    let isUnlocked: Bool
    let onTap: () -> Void

    private var levelName: String {
        switch level {
        case 1: return "Easy"
        case 2: return "Medium"
        case 3: return "Hard"
        default: return "Level \(level)"
        }
    }

    private var levelDescription: String {
        switch level {
        case 1: return "Great for beginners"
        case 2: return "A balanced challenge"
        case 3: return "For experienced players"
        default: return ""
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(levelName)
                        .font(.headline)
                        .foregroundStyle(isUnlocked ? .primary : .secondary)

                    Text(levelDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isUnlocked {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.royalBlue)
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected && isUnlocked ? Color.royalBlue.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected && isUnlocked ? Color.royalBlue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

// Helper to handle badge checking and difficulty unlocks after game completion
struct GameCompletionHandler {
    static func handleGameCompletion(
        profile: UserProfile,
        gameType: GameType,
        score: Int,
        maxPossibleScore: Int,
        level: Int,
        durationSeconds: Int,
        mockService: MockDataService,
        modelContext: ModelContext
    ) -> (newBadges: [BadgeType], unlockedLevel: Int?) {
        // Create and save the session
        let session = GameSession(
            gameType: gameType,
            score: score,
            maxPossibleScore: maxPossibleScore,
            level: level,
            durationSeconds: durationSeconds
        )
        session.profile = profile
        modelContext.insert(session)

        // Check for new badges
        let newBadges = BadgeManager.checkForNewBadges(
            profile: profile,
            session: session,
            mockService: mockService,
            modelContext: modelContext
        )

        // Check for difficulty unlock
        let unlockedLevel = BadgeManager.checkDifficultyUnlock(
            profile: profile,
            session: session,
            modelContext: modelContext
        )

        return (newBadges, unlockedLevel)
    }
}

// A view to show unlocked badges and difficulty levels
struct GameCompletionOverlay: View {
    let newBadges: [BadgeType]
    let unlockedLevel: Int?
    let gameType: GameType
    let onDismiss: () -> Void

    var body: some View {
        if !newBadges.isEmpty || unlockedLevel != nil {
            VStack(spacing: 20) {
                if !newBadges.isEmpty {
                    VStack(spacing: 12) {
                        Text("Badge Unlocked!")
                            .font(.title2.bold())
                            .foregroundStyle(Color.royalBlue)

                        ForEach(newBadges, id: \.self) { badge in
                            HStack(spacing: 12) {
                                Text(badge.emoji)
                                    .font(.system(size: 40))

                                VStack(alignment: .leading) {
                                    Text(badge.displayName)
                                        .font(.headline)
                                    Text(badge.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.royalBlue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }

                if let level = unlockedLevel {
                    VStack(spacing: 8) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.turquoise)

                        Text("Level \(level) Unlocked!")
                            .font(.headline)

                        Text("You can now play \(gameType.rawValue) on a harder difficulty!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.turquoise.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button("Continue", action: onDismiss)
                    .font(.headline)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.royalBlue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(radius: 20)
            )
            .padding(40)
        }
    }
}
