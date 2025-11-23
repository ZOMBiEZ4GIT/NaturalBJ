// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ CardAnimationManager.swift                                                    ║
// ║                                                                               ║
// ║ Coordinates all card-related animations throughout the game.                ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Card animations are core to the premium feel of the app                    ║
// ║ • Smooth, delightful animations increase perceived quality                   ║
// ║ • Must support Reduce Motion for accessibility                               ║
// ║ • Animations should be cancellable for fast-paced gameplay                   ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Singleton pattern for global coordination                                  ║
// ║ • ObservableObject for reactive state updates                                ║
// ║ • Separate methods for each animation type                                   ║
// ║ • Configurable timing based on user preferences                              ║
// ║ • Accessibility-first with Reduce Motion support                             ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ CardAnimationManager                                                          │
// │                                                                               │
// │ Manages all card animation states and provides animation configurations.    │
// └──────────────────────────────────────────────────────────────────────────────┘
@MainActor
class CardAnimationManager: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SINGLETON                                                                 │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let shared = CardAnimationManager()

    private init() {
        // Private init to enforce singleton pattern
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUBLISHED STATE                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Currently animating card IDs
    @Published private(set) var animatingCards: Set<UUID> = []

    /// Animation queue for sequential animations
    @Published private(set) var animationQueue: [CardAnimationTask] = []

    /// Whether animations are globally paused
    @Published var isPaused: Bool = false

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CONFIGURATION                                                             │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Visual settings (injected from VisualSettingsManager)
    var visualSettings: VisualSettings = .default

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ANIMATION POSITIONS                                                       │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Deck position (source for dealing)
    var deckPosition: CGPoint = .zero

    /// Player hand position
    var playerPosition: CGPoint = .zero

    /// Dealer hand position
    var dealerPosition: CGPoint = .zero

    /// Discard pile position (for collecting cards)
    var discardPosition: CGPoint = .zero

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ DEAL ANIMATIONS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Create animation for dealing a card
    /// - Parameters:
    ///   - cardID: The ID of the card being dealt
    ///   - to: Destination position (player or dealer)
    ///   - delay: Delay before animation starts
    /// - Returns: SwiftUI Animation
    func dealCardAnimation(
        cardID: UUID,
        to destination: CardPosition,
        delay: TimeInterval = 0.0
    ) -> Animation {
        // Mark card as animating
        animatingCards.insert(cardID)

        // Determine animation based on Reduce Motion
        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1).delay(delay)
        }

        // Spring animation for smooth, natural motion
        return .spring(
            response: visualSettings.cardDealDuration,
            dampingFraction: 0.75,
            blendDuration: 0.1
        )
        .delay(delay)
    }

    /// Complete a card animation
    /// - Parameter cardID: The ID of the card that finished animating
    func completeCardAnimation(cardID: UUID) {
        animatingCards.remove(cardID)
    }

    /// Calculate position offset for card dealing animation
    /// - Parameters:
    ///   - from: Source position
    ///   - to: Destination position
    /// - Returns: CGSize offset
    func dealOffset(from source: CardPosition, to destination: CardPosition) -> CGSize {
        let fromPoint = point(for: source)
        let toPoint = point(for: destination)

        return CGSize(
            width: toPoint.x - fromPoint.x,
            height: toPoint.y - fromPoint.y
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ FLIP ANIMATIONS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Create animation for flipping a card (hole card reveal)
    /// - Parameter duration: Optional custom duration
    /// - Returns: SwiftUI Animation
    func flipCardAnimation(duration: TimeInterval? = nil) -> Animation {
        let animationDuration = duration ?? visualSettings.cardFlipDuration

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Ease-in-out for smooth 3D rotation
        return .easeInOut(duration: animationDuration)
    }

    /// Rotation angle for card flip
    /// - Parameter isFaceUp: Whether the card should be face up
    /// - Returns: Rotation angle in degrees
    func flipRotation(isFaceUp: Bool) -> Double {
        isFaceUp ? 0 : 180
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ COLLECT ANIMATIONS                                                        │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Create animation for collecting cards (end of hand)
    /// - Parameter cardID: The ID of the card being collected
    /// - Returns: SwiftUI Animation
    func collectCardAnimation(cardID: UUID) -> Animation {
        animatingCards.insert(cardID)

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Ease-in for smooth acceleration toward discard pile
        return .easeIn(duration: visualSettings.cardCollectDuration)
    }

    /// Offset for card collection animation
    /// - Parameter from: Source position
    /// - Returns: CGSize offset to discard pile
    func collectOffset(from source: CardPosition) -> CGSize {
        let fromPoint = point(for: source)
        let toPoint = discardPosition

        return CGSize(
            width: toPoint.x - fromPoint.x,
            height: toPoint.y - fromPoint.y
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CASCADE ANIMATIONS                                                        │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Calculate delay for cascading card animations
    /// - Parameter index: Index of card in sequence
    /// - Returns: Delay in seconds
    func cascadeDelay(for index: Int) -> TimeInterval {
        TimeInterval(index) * visualSettings.cardDealDelay
    }

    /// Horizontal offset for card stacking
    /// - Parameter index: Index of card in hand
    /// - Returns: Horizontal offset in points
    func stackOffset(for index: Int) -> CGFloat {
        CGFloat(index) * 30 // 30pt spacing between cards
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INITIAL DEAL SEQUENCE                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Create animation sequence for initial deal (player, dealer, player, dealer)
    /// - Returns: Array of animation tasks with delays
    func initialDealSequence() -> [CardAnimationTask] {
        let baseDelay = visualSettings.cardDealDelay

        return [
            CardAnimationTask(
                position: .player,
                delay: 0.0,
                isFaceUp: true
            ),
            CardAnimationTask(
                position: .dealer,
                delay: baseDelay,
                isFaceUp: true
            ),
            CardAnimationTask(
                position: .player,
                delay: baseDelay * 2,
                isFaceUp: true
            ),
            CardAnimationTask(
                position: .dealer,
                delay: baseDelay * 3,
                isFaceUp: false // Hole card
            )
        ]
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ POSITION HELPERS                                                          │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Get CGPoint for a card position
    /// - Parameter position: Card position enum
    /// - Returns: CGPoint coordinates
    func point(for position: CardPosition) -> CGPoint {
        switch position {
        case .deck:
            return deckPosition
        case .player:
            return playerPosition
        case .dealer:
            return dealerPosition
        case .discard:
            return discardPosition
        }
    }

    /// Update position coordinates
    /// - Parameters:
    ///   - position: Position to update
    ///   - point: New coordinates
    func updatePosition(_ position: CardPosition, to point: CGPoint) {
        switch position {
        case .deck:
            deckPosition = point
        case .player:
            playerPosition = point
        case .dealer:
            dealerPosition = point
        case .discard:
            discardPosition = point
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ANIMATION QUEUE MANAGEMENT                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Add animation task to queue
    /// - Parameter task: Animation task to queue
    func enqueueAnimation(_ task: CardAnimationTask) {
        animationQueue.append(task)
    }

    /// Remove completed animation from queue
    func dequeueAnimation() {
        guard !animationQueue.isEmpty else { return }
        animationQueue.removeFirst()
    }

    /// Clear all queued animations
    func clearQueue() {
        animationQueue.removeAll()
        animatingCards.removeAll()
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ UTILITY METHODS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Check if a specific card is currently animating
    /// - Parameter cardID: Card ID to check
    /// - Returns: True if card is animating
    func isAnimating(cardID: UUID) -> Bool {
        animatingCards.contains(cardID)
    }

    /// Check if any animations are in progress
    var hasActiveAnimations: Bool {
        !animatingCards.isEmpty || !animationQueue.isEmpty
    }

    /// Reset animation manager state
    func reset() {
        clearQueue()
        isPaused = false
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ SUPPORTING TYPES                                                              │
// └──────────────────────────────────────────────────────────────────────────────┘

/// Card position in the game
enum CardPosition {
    case deck       // Source position for dealing
    case player     // Player hand position
    case dealer     // Dealer hand position
    case discard    // Discard pile position
}

/// Animation task for sequencing
struct CardAnimationTask: Identifiable {
    let id = UUID()
    let position: CardPosition
    let delay: TimeInterval
    let isFaceUp: Bool
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ANIMATION PRESETS                                                             │
// │                                                                               │
// │ Common animation configurations for consistency.                             │
// └──────────────────────────────────────────────────────────────────────────────┘
extension CardAnimationManager {

    /// Standard deal animation (used for Hit action)
    func standardDealAnimation(cardID: UUID) -> Animation {
        dealCardAnimation(cardID: cardID, to: .player, delay: 0.0)
    }

    /// Quick flip animation (for hole card reveal)
    func quickFlipAnimation() -> Animation {
        flipCardAnimation(duration: 0.2)
    }

    /// Smooth collect animation (for end of hand)
    func smoothCollectAnimation(cardID: UUID) -> Animation {
        collectCardAnimation(cardID: cardID)
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ACCESSIBILITY SUPPORT                                                         │
// │                                                                               │
// │ Animation alternatives for Reduce Motion.                                   │
// └──────────────────────────────────────────────────────────────────────────────┘
extension CardAnimationManager {

    /// Get appropriate animation respecting accessibility settings
    /// - Parameter standardAnimation: Standard animation when motion allowed
    /// - Returns: Either standard or reduced motion alternative
    func accessibleAnimation(_ standardAnimation: Animation) -> Animation {
        if visualSettings.shouldPlayAnimations {
            return standardAnimation
        } else {
            // Reduced motion: simple fade in/out
            return .easeInOut(duration: 0.15)
        }
    }

    /// Whether card should slide during deal (vs. simple fade)
    var shouldSlideCards: Bool {
        visualSettings.shouldPlayAnimations
    }

    /// Whether to show 3D rotation (vs. simple opacity change)
    var shouldUse3DRotation: Bool {
        visualSettings.shouldPlayAnimations
    }
}
