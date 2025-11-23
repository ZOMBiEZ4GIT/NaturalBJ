// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ CardBackDesign.swift                                                          ║
// ║                                                                               ║
// ║ Defines customisable card back designs for face-down cards.                 ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Card back design is crucial for visual personalisation                     ║
// ║ • Multiple designs increase player engagement                                ║
// ║ • Premium designs can drive in-app purchases                                 ║
// ║ • Consistent with traditional playing card aesthetics                        ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Pattern-based approach (no image assets initially)                         ║
// ║ • Each design has primary + accent colours                                   ║
// ║ • Border style configurable per design                                       ║
// ║ • Premium flag for monetisation potential                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ CardBackDesign                                                                │
// │                                                                               │
// │ Represents a card back design with pattern and colour scheme.               │
// └──────────────────────────────────────────────────────────────────────────────┘
struct CardBackDesign: Identifiable, Codable, Equatable {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PROPERTIES                                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Unique identifier
    let id: UUID

    /// Display name for UI
    let name: String

    /// Pattern style for the card back
    let pattern: CardBackPattern

    /// Primary colour for pattern
    let primaryColor: CodableColor

    /// Accent colour for pattern details
    let accentColor: CodableColor

    /// Border colour
    let borderColor: CodableColor

    /// Border width
    let borderWidth: Double

    /// Whether this is a premium design (requires unlock/purchase)
    let isPremium: Bool

    /// Display order in selection UI
    let displayOrder: Int

    /// Accessibility label
    let accessibilityLabel: String

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ COMPUTED PROPERTIES                                                       │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// SwiftUI Color for primary
    var color: Color {
        primaryColor.color
    }

    /// SwiftUI Color for accent
    var accent: Color {
        accentColor.color
    }

    /// SwiftUI Color for border
    var border: Color {
        borderColor.color
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INITIALISER                                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    init(
        id: UUID = UUID(),
        name: String,
        pattern: CardBackPattern,
        primaryColor: Color,
        accentColor: Color,
        borderColor: Color,
        borderWidth: Double = 2.0,
        isPremium: Bool = false,
        displayOrder: Int,
        accessibilityLabel: String? = nil
    ) {
        self.id = id
        self.name = name
        self.pattern = pattern
        self.primaryColor = CodableColor(color: primaryColor)
        self.accentColor = CodableColor(color: accentColor)
        self.borderColor = CodableColor(color: borderColor)
        self.borderWidth = borderWidth
        self.isPremium = isPremium
        self.displayOrder = displayOrder
        self.accessibilityLabel = accessibilityLabel ?? "\(name) card back"
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ CardBackPattern                                                               │
// │                                                                               │
// │ Available pattern styles for card backs.                                    │
// └──────────────────────────────────────────────────────────────────────────────┘
enum CardBackPattern: String, Codable, CaseIterable {
    /// Classic diagonal lattice pattern
    case lattice = "lattice"

    /// Concentric circles radiating from center
    case circles = "circles"

    /// Diamond/argyle pattern
    case diamonds = "diamonds"

    /// Geometric modern pattern
    case geometric = "geometric"

    /// Ornate decorative pattern
    case ornate = "ornate"

    /// Simple striped pattern
    case striped = "striped"

    /// Dotted pattern
    case dotted = "dotted"

    /// Floral decorative pattern
    case floral = "floral"

    var displayName: String {
        switch self {
        case .lattice: return "Lattice"
        case .circles: return "Circles"
        case .diamonds: return "Diamonds"
        case .geometric: return "Geometric"
        case .ornate: return "Ornate"
        case .striped: return "Striped"
        case .dotted: return "Dotted"
        case .floral: return "Floral"
        }
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ PREDEFINED CARD BACK DESIGNS                                                 │
// │                                                                               │
// │ Premium playing card back designs.                                           │
// └──────────────────────────────────────────────────────────────────────────────┘
extension CardBackDesign {

    /// All available card back designs
    static let allDesigns: [CardBackDesign] = [
        .classicRed,
        .classicBlue,
        .elegantBlack,
        .goldLuxury,
        .modernGeometric,
        .royalPurple,
        .emeraldGreen,
        .crimsonRose
    ]

    /// Default card back design
    static var `default`: CardBackDesign {
        .classicRed
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CLASSIC RED - Traditional red bicycle-style                              │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let classicRed = CardBackDesign(
        name: "Classic Red",
        pattern: .lattice,
        primaryColor: Color(red: 0.8, green: 0.1, blue: 0.1),    // Bright red
        accentColor: Color.white,
        borderColor: Color.white,
        borderWidth: 3.0,
        isPremium: false,
        displayOrder: 1,
        accessibilityLabel: "Classic red playing card back"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CLASSIC BLUE - Traditional blue bicycle-style                            │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let classicBlue = CardBackDesign(
        name: "Classic Blue",
        pattern: .lattice,
        primaryColor: Color(red: 0.1, green: 0.3, blue: 0.8),    // Bright blue
        accentColor: Color.white,
        borderColor: Color.white,
        borderWidth: 3.0,
        isPremium: false,
        displayOrder: 2,
        accessibilityLabel: "Classic blue playing card back"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ELEGANT BLACK - Sophisticated black with gold accents                    │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let elegantBlack = CardBackDesign(
        name: "Elegant Black",
        pattern: .ornate,
        primaryColor: Color(red: 0.1, green: 0.1, blue: 0.1),    // Near black
        accentColor: Color(red: 1.0, green: 0.84, blue: 0.0),    // Gold
        borderColor: Color(red: 1.0, green: 0.84, blue: 0.0),    // Gold border
        borderWidth: 2.5,
        isPremium: true,
        displayOrder: 3,
        accessibilityLabel: "Elegant black card back with gold accents"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ GOLD LUXURY - Premium gold design                                        │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let goldLuxury = CardBackDesign(
        name: "Gold Luxury",
        pattern: .diamonds,
        primaryColor: Color(red: 1.0, green: 0.84, blue: 0.0),   // Gold
        accentColor: Color(red: 0.72, green: 0.52, blue: 0.04),  // Dark gold
        borderColor: Color(red: 0.72, green: 0.52, blue: 0.04),
        borderWidth: 3.0,
        isPremium: true,
        displayOrder: 4,
        accessibilityLabel: "Gold luxury premium card back"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ MODERN GEOMETRIC - Contemporary geometric pattern                        │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let modernGeometric = CardBackDesign(
        name: "Modern Geometric",
        pattern: .geometric,
        primaryColor: Color(red: 0.2, green: 0.2, blue: 0.25),   // Charcoal
        accentColor: Color(red: 0.0, green: 0.7, blue: 0.9),     // Cyan
        borderColor: Color(red: 0.0, green: 0.7, blue: 0.9),
        borderWidth: 2.0,
        isPremium: false,
        displayOrder: 5,
        accessibilityLabel: "Modern geometric pattern card back"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ROYAL PURPLE - Regal purple design                                       │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let royalPurple = CardBackDesign(
        name: "Royal Purple",
        pattern: .circles,
        primaryColor: Color(red: 0.4, green: 0.1, blue: 0.6),    // Deep purple
        accentColor: Color(red: 0.9, green: 0.8, blue: 1.0),     // Light purple
        borderColor: Color(red: 0.9, green: 0.8, blue: 1.0),
        borderWidth: 2.5,
        isPremium: true,
        displayOrder: 6,
        accessibilityLabel: "Royal purple premium card back"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ EMERALD GREEN - Rich green casino style                                  │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let emeraldGreen = CardBackDesign(
        name: "Emerald Green",
        pattern: .dotted,
        primaryColor: Color(red: 0.0, green: 0.5, blue: 0.3),    // Emerald
        accentColor: Color.white,
        borderColor: Color.white,
        borderWidth: 3.0,
        isPremium: false,
        displayOrder: 7,
        accessibilityLabel: "Emerald green casino-style card back"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CRIMSON ROSE - Elegant red floral pattern                                │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let crimsonRose = CardBackDesign(
        name: "Crimson Rose",
        pattern: .floral,
        primaryColor: Color(red: 0.6, green: 0.05, blue: 0.15),  // Deep red
        accentColor: Color(red: 1.0, green: 0.75, blue: 0.8),    // Pink
        borderColor: Color(red: 1.0, green: 0.75, blue: 0.8),
        borderWidth: 2.0,
        isPremium: true,
        displayOrder: 8,
        accessibilityLabel: "Crimson rose floral card back"
    )
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ PREVIEW HELPERS                                                               │
// │                                                                               │
// │ Helper functions for rendering card back previews.                          │
// └──────────────────────────────────────────────────────────────────────────────┘
extension CardBackDesign {

    /// Create a view displaying this card back design
    /// - Parameters:
    ///   - size: Size of the card back preview
    /// - Returns: A View representing the card back
    @ViewBuilder
    func previewView(size: CGSize = CGSize(width: 60, height: 84)) -> some View {
        ZStack {
            // Background
            Rectangle()
                .fill(color)

            // Pattern overlay (simplified for preview)
            patternOverlay()
                .foregroundColor(accent.opacity(0.3))

            // Border
            Rectangle()
                .strokeBorder(border, lineWidth: borderWidth)
        }
        .frame(width: size.width, height: size.height)
        .cornerRadius(8)
    }

    /// Generate pattern overlay based on pattern type
    @ViewBuilder
    private func patternOverlay() -> some View {
        switch pattern {
        case .lattice:
            // Diagonal lines pattern
            GeometryReader { geometry in
                Path { path in
                    let spacing: CGFloat = 10
                    for i in stride(from: -geometry.size.height, to: geometry.size.width + geometry.size.height, by: spacing) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: i + geometry.size.height, y: geometry.size.height))
                    }
                }
                .stroke(accent, lineWidth: 1.5)
            }

        case .circles:
            // Concentric circles
            GeometryReader { geometry in
                ForEach(0..<5) { i in
                    Circle()
                        .stroke(accent, lineWidth: 1)
                        .frame(width: CGFloat(i + 1) * 15, height: CGFloat(i + 1) * 15)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }

        case .diamonds, .geometric, .ornate, .striped, .dotted, .floral:
            // Simplified pattern for other types
            Rectangle()
                .fill(accent.opacity(0.2))
        }
    }
}
