import SwiftUI
import SwiftData

struct ProfileView: View {
    @Bindable var profile: UserProfile
    let mockService: MockDataService
    let onSwitchProfile: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var editName = ""
    @State private var editEmoji = ""
    
    let emojiOptions = ["🧠", "🎯", "⚡️", "🌟", "🔥", "💪", "🎮", "🏆", "🚀", "💡", "🦊", "🐱", "🐶", "🦁", "🐼"]
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Header
                Section {
                    HStack(spacing: 16) {
                        Text(profile.avatarEmoji)
                            .font(.system(size: 50))
                            .frame(width: 80, height: 80)
                            .background(Color.royalBlue.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.name)
                                .font(.title2.bold())
                            
                            Text("Member since \(profile.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Stats Overview
                Section("Overview") {
                    StatRow(icon: "gamecontroller.fill", label: "Total Sessions", value: "\(profile.sessions.count)")

                    if !profile.sessions.isEmpty {
                        let totalTime = profile.sessions.reduce(0) { $0 + $1.durationSeconds }
                        StatRow(icon: "clock.fill", label: "Total Training Time", value: formatDuration(totalTime))

                        let avgAccuracy = profile.sessions.map { $0.accuracy }.reduce(0, +) / Double(profile.sessions.count)
                        StatRow(icon: "percent", label: "Average Accuracy", value: String(format: "%.1f%%", avgAccuracy))
                    }
                }

                // Badges Section
                Section("Badges") {
                    if profile.badges.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text("🏅")
                                    .font(.system(size: 40))
                                Text("No badges yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Complete games to earn badges!")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 16)
                            Spacer()
                        }
                    } else {
                        BadgeGridView(badges: profile.badges)
                    }

                    NavigationLink {
                        AllBadgesView(profile: profile)
                    } label: {
                        Label("View All Badges", systemImage: "medal.fill")
                    }
                }

                // Actions
                Section {
                    NavigationLink {
                        SettingsView(profile: profile)
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }

                    Button {
                        editName = profile.name
                        editEmoji = profile.avatarEmoji
                        showingEditSheet = true
                    } label: {
                        Label("Edit Profile", systemImage: "pencil")
                    }

                    Button {
                        onSwitchProfile()
                    } label: {
                        Label("Switch Profile", systemImage: "person.2.fill")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Profile", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditSheet) {
                EditProfileSheet(
                    name: $editName,
                    selectedEmoji: $editEmoji,
                    emojiOptions: emojiOptions
                ) {
                    profile.name = editName
                    profile.avatarEmoji = editEmoji
                }
            }
            .alert("Delete Profile?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    modelContext.delete(profile)
                    onSwitchProfile()
                }
            } message: {
                Text("This will permanently delete \(profile.name)'s profile and all training history. This cannot be undone.")
            }
            .onAppear {
                // Sync badges based on existing sessions (retroactive awarding)
                BadgeManager.syncBadges(
                    profile: profile,
                    mockService: mockService,
                    modelContext: modelContext
                )
            }
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.royalBlue)
                .frame(width: 24)
            
            Text(label)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var selectedEmoji: String
    let emojiOptions: [String]
    let onSave: () -> Void
    
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
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Badge Grid View
struct BadgeGridView: View {
    let badges: [Badge]

    var sortedBadges: [Badge] {
        badges.sorted(by: { $0.unlockedAt > $1.unlockedAt }).prefix(8).compactMap { $0 }
    }

    var body: some View {
        VStack(spacing: 12) {
            // First row (up to 4 badges)
            HStack(spacing: 8) {
                ForEach(Array(sortedBadges.prefix(4)), id: \.id) { badge in
                    if let type = badge.type {
                        BadgeCell(badgeType: type, isUnlocked: true)
                    }
                }
            }

            // Second row (remaining badges, centered)
            if sortedBadges.count > 4 {
                HStack(spacing: 8) {
                    ForEach(Array(sortedBadges.dropFirst(4)), id: \.id) { badge in
                        if let type = badge.type {
                            BadgeCell(badgeType: type, isUnlocked: true)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct BadgeCell: View {
    let badgeType: BadgeType
    let isUnlocked: Bool
    var progress: Double = 1.0

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.royalBlue.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)

                if !isUnlocked && progress > 0 {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.royalBlue.opacity(0.3), lineWidth: 3)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                }

                Text(badgeType.emoji)
                    .font(.system(size: 24))
                    .opacity(isUnlocked ? 1.0 : 0.4)
            }

            Text(badgeType.displayName)
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(isUnlocked ? .primary : .secondary)
        }
    }
}

// MARK: - All Badges View
struct AllBadgesView: View {
    let profile: UserProfile
    @State private var selectedBadge: BadgeType? = nil

    private var unlockedBadgeTypes: Set<BadgeType> {
        Set(profile.badges.compactMap { $0.type })
    }

    private var badgeProgress: [BadgeType: Double] {
        BadgeManager.getBadgeProgress(profile: profile)
    }

    var body: some View {
        List {
            ForEach(BadgeCategory.allCases, id: \.self) { category in
                Section(category.rawValue) {
                    let categoryBadges = BadgeType.allCases.filter { $0.category == category }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(categoryBadges, id: \.self) { badgeType in
                            let isUnlocked = unlockedBadgeTypes.contains(badgeType)
                            let progress = badgeProgress[badgeType] ?? 0

                            BadgeCell(badgeType: badgeType, isUnlocked: isUnlocked, progress: progress)
                                .onTapGesture {
                                    selectedBadge = badgeType
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("All Badges")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailSheet(
                badgeType: badge,
                isUnlocked: unlockedBadgeTypes.contains(badge),
                progress: badgeProgress[badge] ?? 0,
                unlockedDate: profile.badges.first { $0.type == badge }?.unlockedAt
            )
        }
    }
}

// MARK: - Badge Detail Sheet
struct BadgeDetailSheet: View {
    let badgeType: BadgeType
    let isUnlocked: Bool
    let progress: Double
    let unlockedDate: Date?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Badge Icon
                ZStack {
                    Circle()
                        .fill(isUnlocked ? Color.royalBlue.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 120, height: 120)

                    if !isUnlocked && progress > 0 {
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.royalBlue, lineWidth: 6)
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                    }

                    if isUnlocked {
                        Circle()
                            .stroke(Color.royalBlue, lineWidth: 4)
                            .frame(width: 120, height: 120)
                    }

                    Text(badgeType.emoji)
                        .font(.system(size: 56))
                        .opacity(isUnlocked ? 1.0 : 0.4)
                }

                // Badge Name
                Text(badgeType.displayName)
                    .font(.title.bold())

                // Status
                if isUnlocked {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Earned")
                            .foregroundStyle(.green)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)

                    if let date = unlockedDate {
                        Text("Unlocked on \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                        Text("Not Yet Earned")
                            .foregroundStyle(.secondary)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)

                    if progress > 0 {
                        Text("\(Int(progress * 100))% Progress")
                            .font(.caption)
                            .foregroundStyle(Color.royalBlue)
                    }
                }

                // How to Earn
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to Earn")
                        .font(.headline)

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: isUnlocked ? "checkmark.circle.fill" : "target")
                            .foregroundStyle(isUnlocked ? .green : Color.royalBlue)
                            .font(.title3)

                        Text(badgeType.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Category
                HStack {
                    Text("Category:")
                        .foregroundStyle(.secondary)
                    Text(badgeType.category.rawValue)
                        .fontWeight(.medium)
                }
                .font(.subheadline)

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, GameSession.self, Badge.self, DifficultyUnlock.self, configurations: config)
    let profile = UserProfile(name: "Test User", avatarEmoji: "🧠")
    container.mainContext.insert(profile)

    return ProfileView(profile: profile, mockService: MockDataService(), onSwitchProfile: {})
        .modelContainer(container)
}
