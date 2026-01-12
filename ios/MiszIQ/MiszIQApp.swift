import SwiftUI
import SwiftData

@main
struct MiszIQApp: App {
    @StateObject private var settings = SettingsManager.shared
    @State private var showSplash = true
    @State private var showOnboarding = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            GameSession.self,
            Badge.self,
            DifficultyUnlock.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .preferredColorScheme(settings.themeMode.colorScheme)
                    .environmentObject(settings)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        AudioManager.shared.pauseBackgroundMusic()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        AudioManager.shared.resumeBackgroundMusic()
                    }

                if showOnboarding {
                    OnboardingView {
                        hasCompletedOnboarding = true
                        withAnimation(.easeOut(duration: 0.4)) {
                            showOnboarding = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }

                if showSplash {
                    SplashScreen {
                        withAnimation(.easeOut(duration: 0.4)) {
                            showSplash = false
                            if !hasCompletedOnboarding {
                                showOnboarding = true
                            }
                        }
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
