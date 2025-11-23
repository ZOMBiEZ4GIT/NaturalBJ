// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ TransitionManager.swift                                                       ║
// ║                                                                               ║
// ║ Manages smooth transitions between game states and view presentations.      ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Smooth transitions create professional, polished feel                      ║
// ║ • State changes should be visually clear to player                           ║
// ║ • Modal presentations need consistent animation                              ║
// ║ • Reduce cognitive load with predictable transitions                         ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Singleton pattern for global coordination                                  ║
// ║ • Different transitions for different state changes                          ║
// ║ • Accessibility support with Reduce Motion                                   ║
// ║ • Configurable timing based on user preferences                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ TransitionManager                                                             │
// │                                                                               │
// │ Manages all view and state transition animations.                           │
// └──────────────────────────────────────────────────────────────────────────────┘
@MainActor
class TransitionManager: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SINGLETON                                                                 │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let shared = TransitionManager()

    private init() {
        // Private init to enforce singleton pattern
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUBLISHED STATE                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Currently transitioning state
    @Published private(set) var isTransitioning: Bool = false

    /// Current game state (for transition coordination)
    @Published var currentGameState: String = "betting"

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CONFIGURATION                                                             │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Visual settings (injected from VisualSettingsManager)
    var visualSettings: VisualSettings = .default

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ GAME STATE TRANSITIONS                                                    │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Transition from betting to dealing
    func transitionToDealingAnimation() -> Animation {
        isTransitioning = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Quick fade for immediate action
        return .easeOut(duration: visualSettings.stateTransitionDuration * 0.5)
    }

    /// Transition from dealing to player turn
    func transitionToPlayerTurnAnimation() -> Animation {
        isTransitioning = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Smooth transition after cards dealt
        return .easeInOut(duration: visualSettings.stateTransitionDuration)
    }

    /// Transition from player turn to dealer turn
    func transitionToDealerTurnAnimation() -> Animation {
        isTransitioning = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Medium-paced transition
        return .easeInOut(duration: visualSettings.stateTransitionDuration)
    }

    /// Transition from dealer turn to result display
    func transitionToResultAnimation() -> Animation {
        isTransitioning = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Slightly slower for result reveal
        return .easeOut(duration: visualSettings.resultDisplayDuration)
    }

    /// Transition from result back to betting
    func transitionToBettingAnimation() -> Animation {
        isTransitioning = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Clean reset transition
        return .easeInOut(duration: visualSettings.stateTransitionDuration)
    }

    /// Complete transition
    func completeTransition() {
        isTransitioning = false
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ RESULT DISPLAY TRANSITIONS                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Transition for showing win result
    func showWinResultAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Spring for celebratory feel
        return .spring(
            response: 0.5,
            dampingFraction: 0.7,
            blendDuration: 0.1
        )
    }

    /// Transition for showing loss result
    func showLossResultAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Gentle fade for loss
        return .easeInOut(duration: 0.4)
    }

    /// Transition for showing blackjack result
    func showBlackjackResultAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Dramatic spring for special result
        return .spring(
            response: 0.6,
            dampingFraction: 0.6,
            blendDuration: 0.1
        )
    }

    /// Transition for showing push result
    func showPushResultAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Neutral transition
        return .easeInOut(duration: 0.35)
    }

    /// Dismiss result message
    func dismissResultAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeIn(duration: visualSettings.fadeDuration)
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ MODAL TRANSITIONS                                                         │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Transition for presenting settings modal
    func presentSettingsAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Smooth slide up
        return .easeOut(duration: 0.35)
    }

    /// Transition for dismissing settings modal
    func dismissSettingsAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Smooth slide down
        return .easeIn(duration: 0.3)
    }

    /// Transition for presenting statistics panel
    func presentStatisticsAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Slide up from bottom
        return .spring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0.1
        )
    }

    /// Transition for dismissing statistics panel
    func dismissStatisticsAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeIn(duration: 0.25)
    }

    /// Transition for presenting help view
    func presentHelpAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeOut(duration: 0.3)
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEALER SELECTION TRANSITIONS                                              │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Transition for changing dealer
    func changeDealerAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Smooth cross-fade
        return .easeInOut(duration: 0.5)
    }

    /// Transition for dealer card flip (personality reveal)
    func dealerCardFlipAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .spring(
            response: 0.45,
            dampingFraction: 0.75,
            blendDuration: 0.1
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ HAND SPLIT TRANSITIONS                                                    │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Transition for splitting hand (cards separate)
    func splitHandAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Spring for separation
        return .spring(
            response: 0.5,
            dampingFraction: 0.7,
            blendDuration: 0.1
        )
    }

    /// Transition for switching active hand after split
    func switchActiveHandAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeInOut(duration: 0.2)
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ OVERLAY TRANSITIONS                                                       │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Transition for showing overlay (tutorial, bankruptcy, etc.)
    func showOverlayAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeOut(duration: 0.3)
    }

    /// Transition for dismissing overlay
    func dismissOverlayAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeIn(duration: 0.25)
    }

    /// Transition for tutorial spotlight
    func tutorialSpotlightAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .spring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0.1
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BUTTON & UI TRANSITIONS                                                   │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Transition for button press feedback
    func buttonPressAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.05)
        }

        // Quick spring for tactile feel
        return .spring(
            response: 0.2,
            dampingFraction: 0.5,
            blendDuration: 0.05
        )
    }

    /// Transition for button state change (enabled/disabled)
    func buttonStateChangeAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeInOut(duration: 0.2)
    }

    /// Pulse animation for important actions
    func pulseAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeInOut(duration: 0.8)
            .repeatCount(3, autoreverses: true)
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ VALUE CHANGE TRANSITIONS                                                  │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Transition for bankroll value change
    func bankrollChangeAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .easeInOut(duration: 0.3)
    }

    /// Transition for hand value update
    func handValueUpdateAnimation() -> Animation {
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        return .spring(
            response: 0.3,
            dampingFraction: 0.7,
            blendDuration: 0.05
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SWIFTUI TRANSITION HELPERS                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// SwiftUI Transition for result messages
    var resultTransition: AnyTransition {
        if !visualSettings.shouldPlayAnimations {
            return .opacity
        }

        return .asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .opacity
        )
    }

    /// SwiftUI Transition for modals (slide from bottom)
    var modalTransition: AnyTransition {
        if !visualSettings.shouldPlayAnimations {
            return .opacity
        }

        return .move(edge: .bottom).combined(with: .opacity)
    }

    /// SwiftUI Transition for overlays (fade)
    var overlayTransition: AnyTransition {
        .opacity
    }

    /// SwiftUI Transition for cards (scale + fade)
    var cardTransition: AnyTransition {
        if !visualSettings.shouldPlayAnimations {
            return .opacity
        }

        return .scale(scale: 0.5).combined(with: .opacity)
    }

    /// SwiftUI Transition for chips (slide + fade)
    var chipTransition: AnyTransition {
        if !visualSettings.shouldPlayAnimations {
            return .opacity
        }

        return .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ UTILITY METHODS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Reset transition manager state
    func reset() {
        isTransitioning = false
        currentGameState = "betting"
    }

    /// Execute transition with completion handler
    /// - Parameters:
    ///   - animation: Animation to use
    ///   - action: Action to perform during transition
    ///   - completion: Completion handler
    func executeTransition(
        with animation: Animation,
        action: @escaping () -> Void,
        completion: (() -> Void)? = nil
    ) {
        isTransitioning = true

        withAnimation(animation) {
            action()
        }

        // Approximate completion based on animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + visualSettings.stateTransitionDuration) {
            self.isTransitioning = false
            completion?()
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ANIMATION PRESETS                                                             │
// │                                                                               │
// │ Common transitions for consistency.                                         │
// └──────────────────────────────────────────────────────────────────────────────┘
extension TransitionManager {

    /// Standard fade transition
    var standardFade: Animation {
        visualSettings.animation(.easeInOut(duration: visualSettings.fadeDuration))
    }

    /// Quick fade for rapid UI updates
    var quickFade: Animation {
        visualSettings.animation(.easeInOut(duration: 0.15))
    }

    /// Smooth slide transition
    var smoothSlide: Animation {
        visualSettings.animation(
            .spring(response: 0.4, dampingFraction: 0.8)
        )
    }

    /// Bouncy transition for celebrations
    var bouncyTransition: Animation {
        visualSettings.animation(
            .spring(response: 0.6, dampingFraction: 0.6)
        )
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ACCESSIBILITY SUPPORT                                                         │
// │                                                                               │
// │ Transition alternatives for Reduce Motion.                                  │
// └──────────────────────────────────────────────────────────────────────────────┘
extension TransitionManager {

    /// Whether to use complex transitions
    var shouldUseComplexTransitions: Bool {
        visualSettings.shouldPlayAnimations
    }

    /// Get simple fade alternative
    var simpleFadeAlternative: Animation {
        .easeInOut(duration: 0.15)
    }
}
