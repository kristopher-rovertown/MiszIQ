import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var selectedProfile: UserProfile?
    @StateObject private var mockService = MockDataService()
    
    var body: some View {
        Group {
            if let profile = selectedProfile {
                MainTabView(profile: profile, mockService: mockService) {
                    selectedProfile = nil
                }
            } else {
                ProfileSelectionView(profiles: profiles, selectedProfile: $selectedProfile)
            }
        }
        .onAppear {
            // Auto-select if only one profile exists
            if profiles.count == 1 {
                selectedProfile = profiles.first
            }
        }
    }
}

struct MainTabView: View {
    let profile: UserProfile
    let mockService: MockDataService
    let onSwitchProfile: () -> Void
    
    var body: some View {
        TabView {
            ExerciseListView(profile: profile, mockService: mockService)
                .tabItem {
                    Label("Train", systemImage: "brain.head.profile")
                }
            
            UserProgressView(profile: profile, mockService: mockService)
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            ProfileView(profile: profile, mockService: mockService, onSwitchProfile: onSwitchProfile)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(Color.royalBlue)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, GameSession.self], inMemory: true)
}
