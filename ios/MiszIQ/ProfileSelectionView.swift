import SwiftUI
import SwiftData

struct ProfileSelectionView: View {
    let profiles: [UserProfile]
    @Binding var selectedProfile: UserProfile?
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingNewProfile = false
    @State private var newProfileName = ""
    @State private var selectedEmoji = "🧠"
    
    let emojiOptions = ["🧠", "🎯", "⚡️", "🌟", "🔥", "💪", "🎮", "🏆", "🚀", "💡", "🦊", "🐱", "🐶", "🦁", "🐼"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.royalBlue.gradient)
                    
                    Text("IQ Trainer")
                        .font(.largeTitle.bold())
                    
                    Text("Select or create a profile to begin")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // Profiles List
                if profiles.isEmpty {
                    ContentUnavailableView {
                        Label("No Profiles", systemImage: "person.crop.circle.badge.plus")
                    } description: {
                        Text("Create your first profile to start training")
                    }
                    .frame(maxHeight: 200)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(profiles) { profile in
                                ProfileCard(profile: profile) {
                                    selectedProfile = profile
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Create Profile Button
                Button {
                    showingNewProfile = true
                } label: {
                    Label("Create New Profile", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.royalBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .sheet(isPresented: $showingNewProfile) {
                NewProfileSheet(
                    name: $newProfileName,
                    selectedEmoji: $selectedEmoji,
                    emojiOptions: emojiOptions
                ) {
                    createProfile()
                }
            }
        }
    }
    
    private func createProfile() {
        guard !newProfileName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let profile = UserProfile(name: newProfileName.trimmingCharacters(in: .whitespaces), avatarEmoji: selectedEmoji)
        modelContext.insert(profile)
        
        newProfileName = ""
        selectedEmoji = "🧠"
        showingNewProfile = false
        
        // Auto-select the new profile
        selectedProfile = profile
    }
}

struct ProfileCard: View {
    let profile: UserProfile
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Text(profile.avatarEmoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color.royalBlue.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("\(profile.sessions.count) sessions completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct NewProfileSheet: View {
    @Binding var name: String
    @Binding var selectedEmoji: String
    let emojiOptions: [String]
    let onCreate: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Name") {
                    TextField("Enter your name", text: $name)
                        .textContentType(.name)
                }
                
                Section("Avatar") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 50, height: 50)
                                    .background(selectedEmoji == emoji ? Color.royalBlue.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedEmoji == emoji ? Color.royalBlue : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ProfileSelectionView(profiles: [], selectedProfile: .constant(nil))
        .modelContainer(for: [UserProfile.self, GameSession.self], inMemory: true)
}
