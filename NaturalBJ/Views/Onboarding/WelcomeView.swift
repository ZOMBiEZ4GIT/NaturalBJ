//
//  WelcomeView.swift
//  Natural - Modern Blackjack
//
//  Created by Claude Code
//  First Launch Onboarding
//

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👋 WELCOME VIEW - First Launch Introduction                               ║
// ║                                                                            ║
// ║ Purpose: Welcome screen for first-time users                              ║
// ║ Business Context: Sets expectations, introduces dealer concept            ║
// ║                   Follows spec lines 532-541 (First Launch Flow)          ║
// ║                                                                            ║
// ║ Flow: Splash → Welcome → Dealer Selection → Game                          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import SwiftUI

struct WelcomeView: View {

    @Binding var isPresented: Bool
    @ObservedObject private var appState = AppStateManager.shared

    @State private var currentPage = 0
    @State private var showDealerSelection = false

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        skipOnboarding()
                    }
                    .foregroundColor(.mediumGrey)
                    .padding()
                }

                Spacer()

                // Content pages
                TabView(selection: $currentPage) {
                    // Page 1: App intro
                    welcomePage1
                        .tag(0)

                    // Page 2: Dealer concept
                    welcomePage2
                        .tag(1)

                    // Page 3: How to play
                    welcomePage3
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Spacer()

                // Action button
                actionButton
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showDealerSelection) {
            OnboardingDealerSelection(onComplete: completeOnboarding)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📄 PAGE 1: WELCOME                                                   │
    // └─────────────────────────────────────────────────────────────────────┘

    private var welcomePage1: some View {
        VStack(spacing: 24) {
            // App icon/logo area
            Image(systemName: "suit.spade.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.65, blue: 0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 8)

            Text("Simple. Modern. Blackjack.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Play authentic blackjack with a clean, modern interface. No clutter, no gimmicks—just pure gameplay.")
                .font(.body)
                .foregroundColor(.mediumGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📄 PAGE 2: DEALER PERSONALITIES                                     │
    // └─────────────────────────────────────────────────────────────────────┘

    private var welcomePage2: some View {
        VStack(spacing: 24) {
            // Dealer icons
            HStack(spacing: 16) {
                dealerIcon(icon: "heart.fill", colour: .red)
                dealerIcon(icon: "clover.fill", colour: .yellow)
                dealerIcon(icon: "drop.triangle.fill", colour: .blue)
            }
            .padding(.bottom, 8)

            Text("Meet Your Dealers")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Each dealer has a unique personality and rule set. Choose the dealer that matches your style:")
                .font(.body)
                .foregroundColor(.mediumGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 12) {
                featureBullet(icon: "heart.fill", text: "Ruby - Classic Vegas rules", colour: Color(red: 1.0, green: 0.23, blue: 0.19))
                featureBullet(icon: "clover.fill", text: "Lucky - Player-friendly bonuses", colour: Color(red: 1.0, green: 0.84, blue: 0.0))
                featureBullet(icon: "drop.triangle.fill", text: "Shark - High-stakes challenge", colour: Color(red: 0.04, green: 0.52, blue: 1.0))
                featureBullet(icon: "leaf.fill", text: "Zen - Learn with strategy hints", colour: Color(red: 0.69, green: 0.32, blue: 0.87))
            }
            .padding(.horizontal, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 📄 PAGE 3: HOW TO PLAY                                              │
    // └─────────────────────────────────────────────────────────────────────┘

    private var welcomePage3: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 60))
                .foregroundColor(.info)
                .padding(.bottom, 8)

            Text("Ready to Play?")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Natural makes blackjack simple:")
                .font(.body)
                .foregroundColor(.mediumGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 16) {
                instructionStep(number: "1", text: "Choose your dealer")
                instructionStep(number: "2", text: "Place your bet")
                instructionStep(number: "3", text: "Play your hand")
                instructionStep(number: "4", text: "Beat the dealer to win!")
            }
            .padding(.horizontal, 48)

            Text("Swipe up anytime to see your stats and progress.")
                .font(.caption)
                .foregroundColor(.mediumGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎨 HELPER VIEWS                                                      │
    // └─────────────────────────────────────────────────────────────────────┘

    private func dealerIcon(icon: String, colour: Color) -> some View {
        Image(systemName: icon)
            .font(.system(size: 40))
            .foregroundColor(colour)
            .frame(width: 70, height: 70)
            .background(
                Circle()
                    .fill(colour.opacity(0.15))
            )
            .overlay(
                Circle()
                    .strokeBorder(colour.opacity(0.3), lineWidth: 2)
            )
    }

    private func featureBullet(icon: String, text: String, colour: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(colour)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()
        }
    }

    private func instructionStep(number: String, text: String) -> some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.info.opacity(0.2))
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.info, lineWidth: 2)
                )

            Text(text)
                .font(.body)
                .foregroundColor(.white)

            Spacer()
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🔘 ACTION BUTTON                                                     │
    // └─────────────────────────────────────────────────────────────────────┘

    private var actionButton: some View {
        Button(action: {
            if currentPage < 2 {
                withAnimation {
                    currentPage += 1
                }
            } else {
                // Last page - proceed to dealer selection
                showDealerSelection = true
            }
        }) {
            Text(currentPage < 2 ? "Next" : "Choose Your Dealer")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.info)
                .cornerRadius(12)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ 🎬 ACTIONS                                                           │
    // └─────────────────────────────────────────────────────────────────────┘

    private func skipOnboarding() {
        appState.completeOnboarding()
        isPresented = false
    }

    private func completeOnboarding() {
        appState.completeOnboarding()
        isPresented = false
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🎲 ONBOARDING DEALER SELECTION                                            ║
// ║                                                                            ║
// ║ Simplified dealer selection for first-time users                          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct OnboardingDealerSelection: View {

    let onComplete: () -> Void
    @ObservedObject private var appState = AppStateManager.shared
    @State private var selectedDealer: Dealer = .ruby()
    @State private var showingConfirmation = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Dealer")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Don't worry, you can change this anytime in settings")
                        .font(.subheadline)
                        .foregroundColor(.mediumGrey)
                }
                .padding(.top, 60)

                // Dealer carousel
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Dealer.allDealers) { dealer in
                            OnboardingDealerCard(
                                dealer: dealer,
                                isSelected: selectedDealer.name == dealer.name
                            )
                            .onTapGesture {
                                selectedDealer = dealer
                                HapticManager.shared.impact(.light)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Confirm button
                Button(action: {
                    showingConfirmation = true
                }) {
                    VStack(spacing: 8) {
                        Text("Start Playing with \(selectedDealer.name)")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(selectedDealer.tagline)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedDealer.accentColor)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .alert("Ready to Play?", isPresented: $showingConfirmation) {
            Button("Let's Go!") {
                confirmSelection()
            }
            Button("Choose Different Dealer", role: .cancel) {}
        } message: {
            Text("You've chosen \(selectedDealer.name). \(selectedDealer.tagline)")
        }
    }

    private func confirmSelection() {
        appState.setDealer(selectedDealer)
        AudioManager.shared.playSoundEffect(.dealerSelect)
        HapticManager.shared.notification(.success)
        onComplete()
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 🃏 ONBOARDING DEALER CARD                                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

struct OnboardingDealerCard: View {

    let dealer: Dealer
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: dealer.avatarIcon)
                .font(.system(size: 50))
                .foregroundColor(dealer.accentColor)
                .frame(height: 60)

            // Name
            Text(dealer.name)
                .font(.headline)
                .foregroundColor(.white)

            // Tagline
            Text(dealer.tagline)
                .font(.caption)
                .foregroundColor(.mediumGrey)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? dealer.accentColor.opacity(0.2) : Color.darkGrey.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isSelected ? dealer.accentColor : Color.clear,
                    lineWidth: 2
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ 👁️ PREVIEW                                                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#Preview("Welcome View") {
    WelcomeView(isPresented: .constant(true))
}

#Preview("Onboarding Dealer Selection") {
    OnboardingDealerSelection(onComplete: {})
}
