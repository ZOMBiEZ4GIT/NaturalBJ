//
//  AchievementUnlockView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 8: Achievements & Progression System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎉 ACHIEVEMENT UNLOCK VIEW                                                 ║
// ║                                                                            ║
// ║ Purpose: Celebration overlay displayed when achievement is unlocked       ║
// ║ Business Context: Players deserve recognition for their accomplishments.  ║
// ║                   This view provides satisfying visual and audio feedback ║
// ║                   to celebrate achievement unlocks.                       ║
// ║                                                                            ║
// ║ Features:                                                                  ║
// ║ • Animated badge reveal with scale and rotation                           ║
// ║ • Achievement name and description                                        ║
// ║ • Confetti/particle effect animation                                      ║
// ║ • XP reward display with count-up animation                               ║
// ║ • Sound effect trigger                                                    ║
// ║ • Haptic feedback trigger                                                 ║
// ║ • "Continue" button to dismiss                                            ║
// ║                                                                            ║
// ║ Used By: GameView (shown as overlay when achievement unlocks)             ║
// ║                                                                            ║
// ║ Related Spec: See "Achievements & Progression System" Phase 8             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎉 ACHIEVEMENT UNLOCK VIEW                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct AchievementUnlockView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    let achievement: Achievement
    let onDismiss: () -> Void

    // Animation state
    @State private var badgeScale: CGFloat = 0.1
    @State private var badgeRotation: Double = -180
    @State private var badgeOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var confettiOpacity: Double = 0
    @State private var xpCounterValue: Int = 0

    // Haptic & audio managers
    private let hapticManager = HapticManager.shared
    private let audioManager = AudioManager.shared

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // Confetti particles
            ConfettiView()
                .opacity(confettiOpacity)

            // Main content
            VStack(spacing: 24) {
                // Achievement unlocked header
                Text("🎊 Achievement Unlocked! 🎊")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(contentOpacity)

                // Badge icon with animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(tierColor.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)

                    // Badge
                    VStack(spacing: 8) {
                        Text(achievement.iconName)
                            .font(.system(size: 80))

                        Text(achievement.tier.medal)
                            .font(.system(size: 40))
                    }
                    .scaleEffect(badgeScale)
                    .rotationEffect(.degrees(badgeRotation))
                    .opacity(badgeOpacity)
                }

                // Achievement name
                Text(achievement.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(contentOpacity)

                // Achievement description
                Text(achievement.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(contentOpacity)

                // XP reward
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)

                    Text("+\(xpCounterValue) XP")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
                .opacity(contentOpacity)

                // Continue button
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 14)
                        .background(tierColor)
                        .cornerRadius(12)
                }
                .opacity(contentOpacity)
                .padding(.top, 8)
            }
            .padding()
        }
        .onAppear {
            playUnlockAnimation()
            triggerHapticFeedback()
            playUnlockSound()
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎬 ANIMATIONS                                                      ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Play the full unlock animation sequence
    private func playUnlockAnimation() {
        // Badge reveal (0.0s - 0.6s)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            badgeScale = 1.2
            badgeRotation = 0
            badgeOpacity = 1.0
        }

        // Badge settle (0.6s - 0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                badgeScale = 1.0
            }
        }

        // Content fade in (0.3s - 0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
        }

        // Confetti (0.2s - 1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.3)) {
                confettiOpacity = 1.0
            }
        }

        // XP counter animation (0.5s - 1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateXPCounter()
        }
    }

    /// Animate XP counter counting up
    private func animateXPCounter() {
        let duration: Double = 1.0
        let steps = 20
        let stepDuration = duration / Double(steps)
        let xpPerStep = achievement.xpReward / steps

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                if step == steps {
                    xpCounterValue = achievement.xpReward
                } else {
                    xpCounterValue = xpPerStep * step
                }
            }
        }
    }

    /// Dismiss with animation
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            badgeScale = 0.1
            badgeOpacity = 0
            contentOpacity = 0
            confettiOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🔊 AUDIO & HAPTIC FEEDBACK                                         ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Trigger haptic feedback for achievement unlock
    private func triggerHapticFeedback() {
        // Success notification haptic
        hapticManager.trigger(.notification(.success))

        // Additional impact for platinum tier
        if achievement.tier == .platinum {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                hapticManager.trigger(.impact(.heavy))
            }
        }
    }

    /// Play unlock sound effect
    private func playUnlockSound() {
        // Use existing achievement sound if available
        // Otherwise use a celebratory sound
        audioManager.playCheer() // Phase 7 audio
    }

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║ 🎨 STYLING HELPERS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════╝

    /// Tier-based colour
    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return .orange
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎊 CONFETTI VIEW                                                           ║
// ║                                                                            ║
// ║ Simple confetti particle effect using geometric shapes                    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct ConfettiView: View {
    @State private var animate = false

    // Confetti colours
    private let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]

    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(color: colors[index % colors.count])
                    .offset(
                        x: animate ? randomX() : 0,
                        y: animate ? randomY() : -100
                    )
                    .rotationEffect(.degrees(animate ? Double.random(in: 0...720) : 0))
                    .opacity(animate ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 3.0)) {
                animate = true
            }
        }
    }

    private func randomX() -> CGFloat {
        CGFloat.random(in: -200...200)
    }

    private func randomY() -> CGFloat {
        CGFloat.random(in: 600...1000)
    }
}

/// Individual confetti piece
struct ConfettiPiece: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 10...20))
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎊 LEVEL UP VIEW (Similar celebration for level-ups)                      ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct LevelUpView: View {
    let newLevel: Int
    let rankTitle: String
    let rankEmoji: String
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.1
    @State private var rotation: Double = -180
    @State private var opacity: Double = 0

    private let hapticManager = HapticManager.shared
    private let audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // Confetti
            ConfettiView()

            // Content
            VStack(spacing: 24) {
                Text("🎉 Level Up! 🎉")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Level number
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)

                    VStack(spacing: 8) {
                        Text("\(newLevel)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)

                        Text("Level")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))

                // Rank
                HStack(spacing: 8) {
                    Text(rankEmoji)
                        .font(.title)

                    Text(rankTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(rankEmoji)
                        .font(.title)
                }
                .opacity(opacity)

                // Continue button
                Button(action: {
                    onDismiss()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .opacity(opacity)
                .padding(.top, 8)
            }
        }
        .onAppear {
            playAnimation()
            triggerFeedback()
        }
    }

    private func playAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.2
            rotation = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                scale = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1.0
            }
        }
    }

    private func triggerFeedback() {
        hapticManager.trigger(.notification(.success))
        audioManager.playCheer()
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEWS                                                                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("Achievement Unlock") {
    var achievement = Achievement(
        id: "preview",
        name: "Blackjack Master",
        description: "Get 100 blackjacks",
        unlockHint: "Keep playing!",
        category: .performance,
        tier: .platinum,
        requiredProgress: 100,
        iconName: "💎"
    )
    achievement.unlock()

    return AchievementUnlockView(achievement: achievement) {
        print("Dismissed")
    }
}

#Preview("Level Up") {
    LevelUpView(
        newLevel: 10,
        rankTitle: "Amateur",
        rankEmoji: "🎯",
        onDismiss: {
            print("Dismissed")
        }
    )
}
