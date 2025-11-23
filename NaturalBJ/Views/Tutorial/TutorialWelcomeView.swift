//
//  TutorialWelcomeView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  Part of Phase 6.5: Tutorial & Help System - View Layer
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ TutorialWelcomeView.swift                                                     ║
// ║                                                                               ║
// ║ First-launch welcome screen for new users.                                   ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • First impression matters - must be welcoming and professional              ║
// ║ • Clear value proposition: "Why take the tutorial?"                          ║
// ║ • Low-pressure: Skip option always available                                 ║
// ║ • Beautiful design sets tone for entire app experience                       ║
// ║                                                                               ║
// ║ UX PRINCIPLES:                                                                ║
// ║ • Minimal text - users don't read walls of text                              ║
// ║ • Clear CTAs - "Start Tutorial" vs "Skip to Game"                            ║
// ║ • Visual hierarchy - draw eyes to primary action                             ║
// ║ • Animations - fade in for polish                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 👋 TUTORIAL WELCOME VIEW                                                  │
// │                                                                           │
// │ Full-screen welcome screen shown to first-time users.                    │
// └──────────────────────────────────────────────────────────────────────────┘

struct TutorialWelcomeView: View {

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🔗 DEPENDENCIES                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    @StateObject private var viewModel = TutorialViewModel()
    @Binding var isPresented: Bool

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 ANIMATION STATE                                                    │
    // └──────────────────────────────────────────────────────────────────────┘

    @State private var showContent = false

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                               │
    // └──────────────────────────────────────────────────────────────────────┘

    var body: some View {
        ZStack {
            // Background
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App logo/icon area
                logoSection

                // Welcome text
                welcomeText

                // Feature highlights
                features

                Spacer()

                // Action buttons
                actionButtons

                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 24)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎨 LOGO SECTION                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    private var logoSection: some View {
        VStack(spacing: 16) {
            // Card icon (representing blackjack)
            Image(systemName: "suit.spade.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.chipGradient)

            // App name
            Text("Natural")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(Color.chipGradient)

            // Tagline
            Text("Premium Blackjack")
                .font(.title3)
                .foregroundColor(.mediumGrey)
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 👋 WELCOME TEXT                                                       │
    // └──────────────────────────────────────────────────────────────────────┘

    private var welcomeText: some View {
        VStack(spacing: 12) {
            Text("Welcome!")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Learn blackjack basics in under 5 minutes with our interactive tutorial.")
                .font(.body)
                .foregroundColor(.mediumGrey)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(.horizontal, 16)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ ✨ FEATURES                                                           │
    // └──────────────────────────────────────────────────────────────────────┘

    private var features: some View {
        VStack(spacing: 16) {
            FeatureRow(
                icon: "hand.tap.fill",
                title: "Interactive Learning",
                description: "Learn by playing, not reading"
            )

            FeatureRow(
                icon: "person.3.fill",
                title: "6 Unique Dealers",
                description: "Each with different rules and personalities"
            )

            FeatureRow(
                icon: "chart.bar.fill",
                title: "Track Your Progress",
                description: "Comprehensive statistics and insights"
            )
        }
        .padding(.horizontal, 8)
    }

    // ┌──────────────────────────────────────────────────────────────────────┐
    // │ 🎯 ACTION BUTTONS                                                     │
    // └──────────────────────────────────────────────────────────────────────┘

    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Primary action: Start Tutorial
            Button(action: {
                viewModel.startTutorial()
                withAnimation {
                    isPresented = false
                }
            }) {
                Text("Start Tutorial")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.success)
                    .cornerRadius(12)
            }

            // Secondary action: Skip
            Button(action: {
                TutorialManager.shared.skipTutorial()
                withAnimation {
                    isPresented = false
                }
            }) {
                Text("Skip to Game")
                    .font(.subheadline)
                    .foregroundColor(.mediumGrey)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.darkGrey)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 8)
    }
}

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ 🎨 FEATURE ROW COMPONENT                                                  │
// │                                                                           │
// │ Reusable row for displaying feature highlights.                          │
// └──────────────────────────────────────────────────────────────────────────┘

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.info)
                .frame(width: 44, height: 44)
                .background(Color.darkGrey)
                .cornerRadius(10)

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.mediumGrey)
            }

            Spacer()
        }
    }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

#Preview("Tutorial Welcome") {
    TutorialWelcomeView(isPresented: .constant(true))
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ 📖 USAGE EXAMPLES                                                             ║
// ║                                                                               ║
// ║ In ContentView or main app flow:                                              ║
// ║   @State private var showWelcome = TutorialManager.shared.shouldShowWelcome   ║
// ║                                                                               ║
// ║   var body: some View {                                                       ║
// ║       GameView()                                                              ║
// ║           .fullScreenCover(isPresented: $showWelcome) {                       ║
// ║               TutorialWelcomeView(isPresented: $showWelcome)                  ║
// ║           }                                                                    ║
// ║   }                                                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
