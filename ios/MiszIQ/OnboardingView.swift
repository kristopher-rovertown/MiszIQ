import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Train Your Brain",
            description: "Challenge yourself with 12 unique games designed to sharpen memory, logic, math, and language skills.",
            color: .royalBlue
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "See how you improve over time with detailed stats and percentile rankings compared to other players.",
            color: .turquoise
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Earn Badges",
            description: "Unlock achievements as you play and master different skill levels across all game categories.",
            color: .orange
        ),
        OnboardingPage(
            icon: "person.2.fill",
            title: "Multiple Profiles",
            description: "Create profiles for family members so everyone can track their own progress separately.",
            color: .purple
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    pages[currentPage].color.opacity(0.8),
                    pages[currentPage].color,
                    pages[currentPage].color.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding()
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom page indicator and navigation
                VStack(spacing: 24) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                                .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }

                    // Navigation button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundStyle(pages[currentPage].color)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 160, height: 160)

                Image(systemName: page.icon)
                    .font(.system(size: 70, weight: .medium))
                    .foregroundStyle(.white)
            }

            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(page.description)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView {
        print("Onboarding complete")
    }
}
