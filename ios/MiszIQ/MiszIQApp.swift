import SwiftUI
import SwiftData

@main
struct MiszIQApp: App {
    @StateObject private var settings = SettingsManager.shared
    @State private var showSplash = true

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

                if showSplash {
                    SplashScreen {
                        withAnimation(.easeOut(duration: 0.4)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
