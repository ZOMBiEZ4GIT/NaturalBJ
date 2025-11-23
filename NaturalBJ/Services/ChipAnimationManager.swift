// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ ChipAnimationManager.swift                                                    ║
// ║                                                                               ║
// ║ Manages betting and chip animations throughout the game.                    ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Chip animations make betting feel tactile and satisfying                   ║
// ║ • Win/loss animations provide clear visual feedback                          ║
// ║ • Payout animations create moments of celebration                            ║
// ║ • Smooth chip movements enhance premium feel                                 ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Singleton pattern for global coordination                                  ║
// ║ • Spring animations for natural chip movement                                ║
// ║ • Count-up animations for large payouts                                      ║
// ║ • Different animations for win/loss/push outcomes                            ║
// ║ • Accessibility support with Reduce Motion alternatives                      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI
import Combine

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ChipAnimationManager                                                          │
// │                                                                               │
// │ Manages all chip and betting animation states and configurations.           │
// └──────────────────────────────────────────────────────────────────────────────┘
@MainActor
class ChipAnimationManager: ObservableObject {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ SINGLETON                                                                 │
    // └──────────────────────────────────────────────────────────────────────────┘

    static let shared = ChipAnimationManager()

    private init() {
        // Private init to enforce singleton pattern
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUBLISHED STATE                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Currently animating chip groups
    @Published private(set) var animatingChips: Set<UUID> = []

    /// Bet amount being animated (for count-up effect)
    @Published var animatedBetAmount: Double = 0.0

    /// Bankroll being animated (for count-up/down effect)
    @Published var animatedBankroll: Double = 0.0

    /// Whether chip animations are in progress
    @Published private(set) var isAnimating: Bool = false

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CONFIGURATION                                                             │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Visual settings (injected from VisualSettingsManager)
    var visualSettings: VisualSettings = .default

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CHIP POSITIONS                                                            │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Betting area position (where chips are placed)
    var bettingAreaPosition: CGPoint = .zero

    /// Player bankroll position (bottom left typically)
    var bankrollPosition: CGPoint = .zero

    /// Dealer chip tray position (top, for losses)
    var dealerTrayPosition: CGPoint = .zero

    /// Table center position (for dramatic win animations)
    var tableCenterPosition: CGPoint = .zero

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BET PLACEMENT ANIMATIONS                                                  │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Create animation for placing a bet
    /// - Parameter amount: Bet amount
    /// - Returns: SwiftUI Animation
    func placeBetAnimation(amount: Double) -> Animation {
        isAnimating = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Spring animation for satisfying chip placement
        return .spring(
            response: visualSettings.chipPlaceDuration,
            dampingFraction: 0.65, // Slightly bouncy
            blendDuration: 0.1
        )
    }

    /// Animate bet amount with count-up effect
    /// - Parameters:
    ///   - from: Starting amount
    ///   - to: Target amount
    ///   - duration: Animation duration
    func animateBetAmount(from startAmount: Double, to endAmount: Double, duration: TimeInterval? = nil) {
        let animationDuration = duration ?? visualSettings.chipPlaceDuration

        withAnimation(.linear(duration: animationDuration)) {
            animatedBetAmount = endAmount
        }

        // Optionally count up incrementally
        if visualSettings.shouldPlayAnimations && abs(endAmount - startAmount) > 10 {
            countUpBetAmount(from: startAmount, to: endAmount, duration: animationDuration)
        } else {
            animatedBetAmount = endAmount
        }
    }

    /// Count up bet amount incrementally
    private func countUpBetAmount(from start: Double, to end: Double, duration: TimeInterval) {
        let steps = 20 // Number of increments
        let increment = (end - start) / Double(steps)
        let stepDuration = duration / Double(steps)

        var currentStep = 0

        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            self.animatedBetAmount = start + (increment * Double(currentStep))

            if currentStep >= steps {
                self.animatedBetAmount = end
                timer.invalidate()
            }
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ WIN ANIMATIONS                                                            │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Create animation for winning chips moving to player
    /// - Parameter payout: Payout amount
    /// - Returns: SwiftUI Animation
    func winAnimation(payout: Double) -> Animation {
        isAnimating = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Ease-out for smooth deceleration to player
        return .easeOut(duration: visualSettings.chipMoveDuration)
    }

    /// Animate bankroll increase on win
    /// - Parameters:
    ///   - from: Starting bankroll
    ///   - to: New bankroll after win
    func animateBankrollIncrease(from start: Double, to end: Double) {
        let duration = visualSettings.chipMoveDuration

        if visualSettings.shouldPlayAnimations && (end - start) > 50 {
            // Count up for large wins
            countUpBankroll(from: start, to: end, duration: duration)
        } else {
            // Instant update for small wins
            withAnimation(.easeInOut(duration: 0.2)) {
                animatedBankroll = end
            }
        }
    }

    /// Count up bankroll incrementally (satisfying for big wins!)
    private func countUpBankroll(from start: Double, to end: Double, duration: TimeInterval) {
        let steps = min(30, Int((end - start) / 10)) // More steps for bigger wins
        let increment = (end - start) / Double(steps)
        let stepDuration = duration / Double(steps)

        var currentStep = 0

        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            self.animatedBankroll = start + (increment * Double(currentStep))

            if currentStep >= steps {
                self.animatedBankroll = end
                timer.invalidate()
                self.isAnimating = false
            }
        }
    }

    /// Offset for chips moving to player on win
    var winChipOffset: CGSize {
        CGSize(
            width: bankrollPosition.x - bettingAreaPosition.x,
            height: bankrollPosition.y - bettingAreaPosition.y
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ LOSS ANIMATIONS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Create animation for losing chips moving to dealer
    /// - Returns: SwiftUI Animation
    func lossAnimation() -> Animation {
        isAnimating = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Ease-in for acceleration toward dealer
        return .easeIn(duration: visualSettings.chipMoveDuration * 0.7) // Slightly faster
    }

    /// Offset for chips moving to dealer on loss
    var lossChipOffset: CGSize {
        CGSize(
            width: dealerTrayPosition.x - bettingAreaPosition.x,
            height: dealerTrayPosition.y - bettingAreaPosition.y
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PUSH ANIMATIONS                                                           │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Create animation for push (chips stay, subtle pulse)
    /// - Returns: SwiftUI Animation
    func pushAnimation() -> Animation {
        isAnimating = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // Subtle pulse to indicate return
        return .spring(
            response: 0.3,
            dampingFraction: 0.6,
            blendDuration: 0.1
        )
    }

    /// Scale for push pulse effect
    var pushPulseScale: CGFloat {
        1.1 // Subtle 10% increase
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BLACKJACK ANIMATIONS                                                      │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Special animation for blackjack payout (3:2)
    /// - Parameter payout: Blackjack payout amount
    /// - Returns: SwiftUI Animation
    func blackjackPayoutAnimation(payout: Double) -> Animation {
        isAnimating = true

        if !visualSettings.shouldPlayAnimations {
            return .easeInOut(duration: 0.1)
        }

        // More dramatic spring for special payout
        return .spring(
            response: 0.7,
            dampingFraction: 0.55, // More bounce for celebration
            blendDuration: 0.1
        )
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CHIP STACK ANIMATIONS                                                     │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Calculate vertical offset for chip in a stack
    /// - Parameters:
    ///   - index: Index of chip in stack (0 = bottom)
    ///   - chipHeight: Height of a single chip
    /// - Returns: Vertical offset
    func chipStackOffset(index: Int, chipHeight: CGFloat = 8) -> CGFloat {
        CGFloat(index) * chipHeight * 0.7 // Overlap chips slightly
    }

    /// Number of chips to show in a stack for given amount
    /// - Parameter amount: Bet amount
    /// - Returns: Number of visual chips (capped for performance)
    func chipCount(for amount: Double) -> Int {
        // Show proportional chips, but cap at 10 for visual clarity
        let rawCount = Int(amount / 5) // 1 chip per $5
        return min(max(rawCount, 1), 10)
    }

    /// Chip colour based on denomination
    /// - Parameter denomination: Chip value
    /// - Returns: Chip colour
    func chipColor(for denomination: Double) -> Color {
        switch denomination {
        case 0..<5:
            return Color.white           // $1 - White
        case 5..<25:
            return Color.red             // $5 - Red
        case 25..<100:
            return Color.green           // $25 - Green
        case 100..<500:
            return Color.black           // $100 - Black
        case 500...:
            return Color.purple          // $500+ - Purple
        default:
            return Color.gray
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ POSITION MANAGEMENT                                                       │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Update position coordinates
    /// - Parameters:
    ///   - position: Position to update
    ///   - point: New coordinates
    func updatePosition(_ position: ChipPosition, to point: CGPoint) {
        switch position {
        case .bettingArea:
            bettingAreaPosition = point
        case .bankroll:
            bankrollPosition = point
        case .dealerTray:
            dealerTrayPosition = point
        case .tableCenter:
            tableCenterPosition = point
        }
    }

    /// Get CGPoint for a chip position
    /// - Parameter position: Chip position enum
    /// - Returns: CGPoint coordinates
    func point(for position: ChipPosition) -> CGPoint {
        switch position {
        case .bettingArea:
            return bettingAreaPosition
        case .bankroll:
            return bankrollPosition
        case .dealerTray:
            return dealerTrayPosition
        case .tableCenter:
            return tableCenterPosition
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ANIMATION STATE MANAGEMENT                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Mark chip animation as complete
    func completeAnimation() {
        isAnimating = false
    }

    /// Reset all chip animations
    func reset() {
        animatingChips.removeAll()
        isAnimating = false
        animatedBetAmount = 0.0
        animatedBankroll = 0.0
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ SUPPORTING TYPES                                                              │
// └──────────────────────────────────────────────────────────────────────────────┘

/// Chip position in the game
enum ChipPosition {
    case bettingArea    // Where bets are placed
    case bankroll       // Player's chip stack
    case dealerTray     // Dealer's chip tray (losses)
    case tableCenter    // Center of table (dramatic animations)
}

/// Chip animation type for different outcomes
enum ChipAnimationType {
    case bet            // Placing a bet
    case win            // Chips to player
    case loss           // Chips to dealer
    case push           // Chips returned (pulse)
    case blackjack      // Special blackjack payout
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ANIMATION PRESETS                                                             │
// │                                                                               │
// │ Common chip animations for consistency.                                     │
// └──────────────────────────────────────────────────────────────────────────────┘
extension ChipAnimationManager {

    /// Standard bet placement (quick and satisfying)
    func standardBetPlacement() -> Animation {
        placeBetAnimation(amount: 0)
    }

    /// Dramatic win sweep (chips to player)
    func dramaticWinSweep() -> Animation {
        winAnimation(payout: 0)
    }

    /// Quick loss collection
    func quickLossCollection() -> Animation {
        lossAnimation()
    }

    /// Gentle push pulse
    func gentlePushPulse() -> Animation {
        pushAnimation()
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ ACCESSIBILITY SUPPORT                                                         │
// │                                                                               │
// │ Chip animation alternatives for Reduce Motion.                              │
// └──────────────────────────────────────────────────────────────────────────────┘
extension ChipAnimationManager {

    /// Whether chips should slide (vs. simple fade)
    var shouldSlideChips: Bool {
        visualSettings.shouldPlayAnimations
    }

    /// Whether to show chip count-up animation
    var shouldCountUp: Bool {
        visualSettings.shouldPlayAnimations
    }

    /// Simplified animation for accessibility
    func accessibleChipAnimation() -> Animation {
        .easeInOut(duration: 0.15)
    }
}
