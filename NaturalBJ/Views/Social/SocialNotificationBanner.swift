//
//  SocialNotificationBanner.swift
//  Blackjackwhitejack
//
//  Phase 10: Leaderboards & Social Features
//  Created by Claude on 23/11/2025.
//

import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Social Notification Banner
// ═══════════════════════════════════════════════════════════════════════════════════
/// Slide-down banner notification for social events
struct SocialNotificationBanner: View {

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 📊 PROPERTIES                                                    │
    // └─────────────────────────────────────────────────────────────────┘

    let notification: SocialNotification
    let onDismiss: () -> Void
    let onAction: (() -> Void)?

    @State private var offset: CGFloat = -200
    @State private var opacity: Double = 0

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎨 BODY                                                          │
    // └─────────────────────────────────────────────────────────────────┘

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon
                Text(notification.icon)
                    .font(.title)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }

                Spacer()

                // Action button (if available)
                if let actionText = notification.actionButtonText, let onAction = onAction {
                    Button(action: onAction) {
                        Text(actionText)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }

                // Dismiss button
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(notification.backgroundColor)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            .padding(.top, 50) // Below notch/status bar

            Spacer()
        }
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            // Slide down animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
            }
        }
        .gesture(
            // Swipe up to dismiss
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -50 {
                        dismissWithAnimation()
                    }
                }
        )
    }

    // ┌─────────────────────────────────────────────────────────────────┐
    // │ 🎬 DISMISS WITH ANIMATION                                        │
    // └─────────────────────────────────────────────────────────────────┘

    private func dismissWithAnimation() {
        withAnimation(.spring(response: 0.3)) {
            offset = -200
            opacity = 0
        }

        // Call dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Social Notification Overlay
// ═══════════════════════════════════════════════════════════════════════════════════
/// Modifier to show social notifications as an overlay
struct SocialNotificationOverlay: ViewModifier {

    @StateObject private var notificationManager = SocialNotificationManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            // Notification overlay
            if let notification = notificationManager.currentNotification {
                Color.clear
                    .overlay(
                        SocialNotificationBanner(
                            notification: notification,
                            onDismiss: {
                                notificationManager.dismissCurrentNotification()
                            },
                            onAction: {
                                // Handle action based on notification type
                                handleNotificationAction(notification)
                                notificationManager.dismissCurrentNotification()
                            }
                        ),
                        alignment: .top
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(999)
            }
        }
    }

    private func handleNotificationAction(_ notification: SocialNotification) {
        // This will be implemented in integration phase
        // Navigate to appropriate view based on notification type
        print("Handle notification action: \(notification.type)")
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - View Extension
// ═══════════════════════════════════════════════════════════════════════════════════
extension View {
    /// Add social notification overlay to any view
    func withSocialNotifications() -> some View {
        modifier(SocialNotificationOverlay())
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════════════
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Text("Sample Content")
                .foregroundColor(.white)
        }

        SocialNotificationBanner(
            notification: SocialNotification(
                type: .personalBest,
                title: "🎉 Personal Best!",
                message: "New personal best in Win Rate! You're now ranked #42!",
                category: .winRate
            ),
            onDismiss: {},
            onAction: {}
        )
    }
}
