import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var orbsVisible = false
    @State private var pulseScale: CGFloat = 1.0

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color.royalBlue.opacity(0.9),
                    Color.royalBlue,
                    Color(red: 0.2, green: 0.3, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating orbs in background
            GeometryReader { geometry in
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.turquoise.opacity(0.4),
                                    Color.turquoise.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: orbSize(for: index), height: orbSize(for: index))
                        .position(orbPosition(for: index, in: geometry.size))
                        .opacity(orbsVisible ? 1 : 0)
                        .scaleEffect(orbsVisible ? 1 : 0.3)
                        .animation(
                            .easeOut(duration: 1.0)
                            .delay(Double(index) * 0.1),
                            value: orbsVisible
                        )
                }
            }

            VStack(spacing: 30) {
                Spacer()

                // Animated brain icon with pulse effect
                ZStack {
                    // Pulse rings
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 140 + CGFloat(ring * 30), height: 140 + CGFloat(ring * 30))
                            .scaleEffect(pulseScale)
                            .opacity(2 - pulseScale)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(ring) * 0.3),
                                value: pulseScale
                            )
                    }

                    // Main icon container
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)

                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 55, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.royalBlue, Color.turquoise],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }

                // App title
                VStack(spacing: 8) {
                    Text("MiszIQ")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                    Text("Train Your Brain")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .tracking(2)
                }
                .offset(y: titleOffset)
                .opacity(titleOpacity)

                Spacer()

                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .opacity(isAnimating ? 1.0 : 0.3)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .opacity(subtitleOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Start loading dots animation
        withAnimation {
            isAnimating = true
        }

        // Show floating orbs
        withAnimation(.easeOut(duration: 0.5)) {
            orbsVisible = true
        }

        // Animate logo
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Start pulse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pulseScale = 2.0
        }

        // Animate title
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            titleOffset = 0
            titleOpacity = 1.0
        }

        // Show loading indicator
        withAnimation(.easeIn(duration: 0.3).delay(0.8)) {
            subtitleOpacity = 1.0
        }

        // Complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeIn(duration: 0.3)) {
                onComplete()
            }
        }
    }

    private func orbSize(for index: Int) -> CGFloat {
        let sizes: [CGFloat] = [80, 60, 100, 50, 70, 90]
        return sizes[index % sizes.count]
    }

    private func orbPosition(for index: Int, in size: CGSize) -> CGPoint {
        let positions: [(CGFloat, CGFloat)] = [
            (0.15, 0.2),
            (0.85, 0.15),
            (0.1, 0.7),
            (0.9, 0.6),
            (0.3, 0.85),
            (0.75, 0.8)
        ]
        let pos = positions[index % positions.count]
        return CGPoint(x: size.width * pos.0, y: size.height * pos.1)
    }
}

#Preview {
    SplashScreen {
        print("Splash complete")
    }
}
