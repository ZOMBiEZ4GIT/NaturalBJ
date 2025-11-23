//
//  ChallengeCompletionView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 9: Daily Challenges & Events System
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎉 CHALLENGE COMPLETION VIEW                                               ║
// ║                                                                            ║
// ║ Purpose: Celebration overlay shown when a challenge is completed          ║
// ║ Business Context: Players need positive reinforcement when completing     ║
// ║                   challenges. This view provides exciting visual          ║
// ║                   feedback with confetti and reward breakdown.            ║
// ║                                                                            ║
// ║ Responsibilities:                                                          ║
// ║ • Display animated challenge badge                                        ║
// ║ • Show "Challenge Complete!" message                                      ║
// ║ • Display reward breakdown                                                ║
// ║ • Animate XP gained                                                        ║
// ║ • Show bonus items unlocked                                               ║
// ║ • Provide continue button                                                 ║
// ║                                                                            ║
// ║ Used By: GameView (shows after challenge completion)                      ║
// ║ Uses: Challenge model                                                      ║
// ║                                                                            ║
// ║ Related Spec: See "Daily Challenges & Events System" Phase 9              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct ChallengeCompletionView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 STATE & DEPENDENCIES                                          │
    // └─────────────────────────────────────────────────────────────────┘

    let challenge: Challenge
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var animateXP = false

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                           │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        ZStack {
            // Dimmed Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Completion Card
            VStack(spacing: 24) {
                // Challenge Icon (Animated)
                Text(challenge.iconName)
                    .font(.system(size: 80))
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showContent)

                // "Challenge Complete!" Message
                VStack(spacing: 8) {
                    Text("🎉 Challenge Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(challenge.name)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)

                Divider()

                // Rewards Breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("REWARDS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)

                    ForEach(challenge.rewards) { reward in
                        HStack(spacing: 12) {
                            Text(reward.type.iconName)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(reward.displayText)
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                if reward.isCosmetic {
                                    Text("✨ Exclusive Unlock!")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                }
                            }

                            Spacer()

                            // Animated checkmark for XP
                            if reward.type == .xp {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                    .scaleEffect(animateXP ? 1.0 : 0.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.6), value: animateXP)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)

                // Continue Button
                Button(action: dismiss) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.6), value: showContent)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
            .scaleEffect(showContent ? 1.0 : 0.8)
            .opacity(showContent ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation {
                showContent = true
                animateXP = true
            }

            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🔧 HELPER METHODS                                                │
    // └─────────────────────────────────────────────────────────────────┘

    private func dismiss() {
        withAnimation {
            showContent = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview {
    let challenge = Challenge(
        id: "test",
        name: "Triple Threat",
        description: "Win 3 hands in a row",
        iconName: "🔥",
        type: .daily,
        category: .performance,
        difficulty: .medium,
        requiredProgress: 3,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400),
        rewards: [.xp(100), .chips(500), .cardBack(named: "Streak Master")],
        currentProgress: 3,
        isCompleted: true
    )

    return ChallengeCompletionView(challenge: challenge) {
        print("Dismissed")
    }
}
