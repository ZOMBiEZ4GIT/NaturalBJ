//
//  ShareView.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI
import UIKit

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Share View
// ═══════════════════════════════════════════════════════════════════════════════════
/// Share sheet generator with preview and platform options
struct ShareView: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    let content: ShareContent
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sharingManager = SharingManager.shared

    @State private var shareImage: UIImage?
    @State private var showingShareSheet = false
    @State private var showingSuccessAnimation = false

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(white: 0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView

                        // Share image preview
                        if let shareImage = shareImage {
                            shareImagePreview(shareImage)
                        } else {
                            ProgressView()
                                .tint(.white)
                        }

                        // Message preview
                        messagePreview

                        // Share buttons
                        shareButtons

                        // Copy button
                        copyButton
                    }
                    .padding()
                }

                // Success animation overlay
                if showingSuccessAnimation {
                    successOverlay
                }
            }
            .navigationTitle("Share Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            generateShareImage()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareImage = shareImage {
                ActivityViewController(
                    activityItems: [content.message, shareImage],
                    applicationActivities: nil
                )
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 HEADER                                                        │
    // └─────────────────────────────────────────────────────────────────┘

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(content.iconEmoji)
                .font(.system(size: 60))

            Text(content.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Share your achievement with the world!")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🖼️ SHARE IMAGE PREVIEW                                           │
    // └─────────────────────────────────────────────────────────────────┘

    private func shareImagePreview(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 10)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 💬 MESSAGE PREVIEW                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var messagePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Message")
                .font(.caption)
                .foregroundColor(.gray)

            Text(content.message)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.1))
                )
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📤 SHARE BUTTONS                                                 │
    // └─────────────────────────────────────────────────────────────────┘

    private var shareButtons: some View {
        VStack(spacing: 12) {
            Text("Share To")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

            // System share sheet
            Button {
                showingShareSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)

                    Text("Share...")
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
                .foregroundColor(.white)
            }
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📋 COPY BUTTON                                                   │
    // └─────────────────────────────────────────────────────────────────┘

    private var copyButton: some View {
        Button {
            UIPasteboard.general.string = content.message
            withAnimation {
                showingSuccessAnimation = true
            }

            // Hide after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showingSuccessAnimation = false
                }
            }
        } label: {
            HStack {
                Image(systemName: "doc.on.doc")
                    .font(.title3)

                Text("Copy Message")
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.15))
            )
            .foregroundColor(.white)
        }
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ ✅ SUCCESS OVERLAY                                               │
    // └─────────────────────────────────────────────────────────────────┘

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text("Copied to Clipboard!")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.15))
            )
        }
        .transition(.opacity)
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🖼️ GENERATE SHARE IMAGE                                          │
    // └─────────────────────────────────────────────────────────────────┘

    private func generateShareImage() {
        shareImage = sharingManager.generateShareImage(for: content)
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Activity View Controller
// ═══════════════════════════════════════════════════════════════════════════════════
/// UIKit bridge for UIActivityViewController
struct ActivityViewController: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )

        // Exclude some activities
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    ShareView(
        content: ShareContent(
            type: .achievementUnlocked,
            title: "Achievement Unlocked!",
            message: "I just unlocked 'High Roller' in Natural Blackjack!",
            details: [
                "Achievement": "High Roller",
                "Description": "Win $10,000 in a single session",
                "Tier": "Gold",
                "XP Reward": "+500 XP"
            ],
            iconEmoji: "🏆",
            playerName: "CardMaster",
            playerLevel: 42,
            playerRank: "Expert"
        )
    )
}
