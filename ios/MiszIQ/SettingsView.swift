import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var profile: UserProfile
    @ObservedObject var settings = SettingsManager.shared

    @Environment(\.modelContext) private var modelContext
    @State private var showResetConfirmation = false

    var body: some View {
        List {
            // Audio Section
            Section {
                Toggle(isOn: $settings.musicEnabled) {
                    Label("Background Music", systemImage: "music.note")
                }
                .tint(Color.royalBlue)
                .onChange(of: settings.musicEnabled) { _, newValue in
                    if newValue {
                        AudioManager.shared.playBackgroundMusic()
                    } else {
                        AudioManager.shared.stopBackgroundMusic()
                    }
                }

                Toggle(isOn: $settings.soundEffectsEnabled) {
                    Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                }
                .tint(Color.royalBlue)
            } header: {
                Text("Audio")
            } footer: {
                Text("Background music plays during games. Sound effects play for correct/wrong answers and game completion.")
            }

            // Feedback Section
            Section {
                Toggle(isOn: $settings.hapticFeedbackEnabled) {
                    Label("Haptic Feedback", systemImage: "hand.tap.fill")
                }
                .tint(Color.royalBlue)
            } header: {
                Text("Feedback")
            } footer: {
                Text("Vibration feedback on button taps and game events.")
            }

            // Appearance Section
            Section {
                Picker(selection: Binding(
                    get: { settings.themeMode },
                    set: { settings.themeMode = $0 }
                )) {
                    ForEach(ThemeMode.allCases) { mode in
                        Label(mode.displayName, systemImage: mode.icon)
                            .tag(mode)
                    }
                } label: {
                    Label("Theme", systemImage: "paintpalette.fill")
                }
            } header: {
                Text("Appearance")
            }

            // Data Section
            Section {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset Progress", systemImage: "arrow.counterclockwise")
                }
            } header: {
                Text("Data")
            } footer: {
                Text("This will delete all game history for \(profile.name). Earned badges will be kept.")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetProgress()
            }
        } message: {
            Text("This will permanently delete all game history for \(profile.name). Badges will be preserved. This cannot be undone.")
        }
    }

    private func resetProgress() {
        // Delete all sessions for this profile
        for session in profile.sessions {
            modelContext.delete(session)
        }
        // Reset difficulty unlocks but keep badges
        for unlock in profile.difficultyUnlocks {
            modelContext.delete(unlock)
        }
        try? modelContext.save()

        // Play haptic feedback
        HapticManager.shared.impact(.medium)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, GameSession.self, Badge.self, DifficultyUnlock.self, configurations: config)
    let profile = UserProfile(name: "Test User", avatarEmoji: "🧠")
    container.mainContext.insert(profile)

    return NavigationStack {
        SettingsView(profile: profile)
    }
    .modelContainer(container)
}
