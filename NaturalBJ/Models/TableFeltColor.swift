// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║ TableFeltColor.swift                                                          ║
// ║                                                                               ║
// ║ Defines customisable table felt colour options for game background.         ║
// ║                                                                               ║
// ║ BUSINESS CONTEXT:                                                             ║
// ║ • Visual customisation increases player engagement                           ║
// ║ • Table colour affects mood and perceived luxury                             ║
// ║ • Premium colours can drive in-app purchases                                 ║
// ║ • Gradients add depth and visual polish                                      ║
// ║                                                                               ║
// ║ DESIGN DECISIONS:                                                             ║
// ║ • Each colour has primary + gradient for depth                               ║
// ║ • Premium flag for potential IAP monetisation                                ║
// ║ • Identifiable for SwiftUI ForEach iteration                                 ║
// ║ • Codable for user preference persistence                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation
import SwiftUI

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ TableFeltColor                                                                │
// │                                                                               │
// │ Represents a table felt colour option with gradient and metadata.           │
// └──────────────────────────────────────────────────────────────────────────────┘
struct TableFeltColor: Identifiable, Codable, Equatable {

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ PROPERTIES                                                                │
    // └──────────────────────────────────────────────────────────────────────────┘

    /// Unique identifier
    let id: UUID

    /// Display name for UI
    let name: String

    /// Primary colour (for solid backgrounds or gradient start)
    let primaryColor: CodableColor

    /// Secondary colour for gradient (if nil, use solid colour)
    let secondaryColor: CodableColor?

    /// Gradient angle in degrees (0 = left to right, 90 = bottom to top)
    let gradientAngle: Double

    /// Whether this is a premium colour (requires unlock/purchase)
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

    /// SwiftUI Color for secondary (or primary if no secondary)
    var secondarySwiftUIColor: Color {
        secondaryColor?.color ?? primaryColor.color
    }

    /// Linear gradient from primary to secondary
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [color, secondarySwiftUIColor]),
            startPoint: gradientStartPoint,
            endPoint: gradientEndPoint
        )
    }

    /// Start point for gradient based on angle
    private var gradientStartPoint: UnitPoint {
        switch gradientAngle {
        case 0: return .leading      // Left to right
        case 90: return .bottom      // Bottom to top
        case 180: return .trailing   // Right to left
        case 270: return .top        // Top to bottom
        case 45: return .bottomLeading   // Diagonal bottom-left to top-right
        case 135: return .bottomTrailing // Diagonal bottom-right to top-left
        case 225: return .topTrailing    // Diagonal top-right to bottom-left
        case 315: return .topLeading     // Diagonal top-left to bottom-right
        default: return .leading     // Default to horizontal
        }
    }

    /// End point for gradient based on angle
    private var gradientEndPoint: UnitPoint {
        switch gradientAngle {
        case 0: return .trailing
        case 90: return .top
        case 180: return .leading
        case 270: return .bottom
        case 45: return .topTrailing
        case 135: return .topLeading
        case 225: return .bottomLeading
        case 315: return .bottomTrailing
        default: return .trailing
        }
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ INITIALISER                                                               │
    // └──────────────────────────────────────────────────────────────────────────┘

    init(
        id: UUID = UUID(),
        name: String,
        primaryColor: Color,
        secondaryColor: Color? = nil,
        gradientAngle: Double = 135,
        isPremium: Bool = false,
        displayOrder: Int,
        accessibilityLabel: String? = nil
    ) {
        self.id = id
        self.name = name
        self.primaryColor = CodableColor(color: primaryColor)
        self.secondaryColor = secondaryColor.map { CodableColor(color: $0) }
        self.gradientAngle = gradientAngle
        self.isPremium = isPremium
        self.displayOrder = displayOrder
        self.accessibilityLabel = accessibilityLabel ?? name
    }
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ PREDEFINED TABLE FELT COLOURS                                                │
// │                                                                               │
// │ Premium blackjack table colour options.                                      │
// └──────────────────────────────────────────────────────────────────────────────┘
extension TableFeltColor {

    /// All available table felt colours
    static let allColors: [TableFeltColor] = [
        .classicGreen,
        .midnightBlue,
        .burgundyRed,
        .charcoalGrey,
        .royalPurple,
        .forestGreen,
        .navyBlue,
        .crimsonRed
    ]

    /// Default table colour (classic green)
    static var `default`: TableFeltColor {
        .classicGreen
    }

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CLASSIC GREEN - The traditional casino felt                              │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let classicGreen = TableFeltColor(
        name: "Classic Green",
        primaryColor: Color(red: 0.0, green: 0.5, blue: 0.2),      // Rich green
        secondaryColor: Color(red: 0.0, green: 0.35, blue: 0.15),  // Darker green
        gradientAngle: 135,
        isPremium: false,
        displayOrder: 1,
        accessibilityLabel: "Classic green casino felt"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ MIDNIGHT BLUE - Sophisticated and modern                                 │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let midnightBlue = TableFeltColor(
        name: "Midnight Blue",
        primaryColor: Color(red: 0.05, green: 0.1, blue: 0.3),     // Deep blue
        secondaryColor: Color(red: 0.02, green: 0.05, blue: 0.2),  // Darker blue
        gradientAngle: 135,
        isPremium: false,
        displayOrder: 2,
        accessibilityLabel: "Midnight blue luxury felt"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ BURGUNDY RED - Elegant and luxurious                                     │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let burgundyRed = TableFeltColor(
        name: "Burgundy Red",
        primaryColor: Color(red: 0.5, green: 0.05, blue: 0.1),     // Rich burgundy
        secondaryColor: Color(red: 0.35, green: 0.02, blue: 0.08), // Darker burgundy
        gradientAngle: 135,
        isPremium: true,
        displayOrder: 3,
        accessibilityLabel: "Burgundy red premium felt"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CHARCOAL GREY - Sleek and professional                                   │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let charcoalGrey = TableFeltColor(
        name: "Charcoal Grey",
        primaryColor: Color(red: 0.2, green: 0.2, blue: 0.22),     // Medium grey
        secondaryColor: Color(red: 0.12, green: 0.12, blue: 0.14), // Darker grey
        gradientAngle: 135,
        isPremium: false,
        displayOrder: 4,
        accessibilityLabel: "Charcoal grey modern felt"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ ROYAL PURPLE - Premium and distinctive                                   │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let royalPurple = TableFeltColor(
        name: "Royal Purple",
        primaryColor: Color(red: 0.3, green: 0.1, blue: 0.5),      // Rich purple
        secondaryColor: Color(red: 0.2, green: 0.05, blue: 0.35),  // Darker purple
        gradientAngle: 135,
        isPremium: true,
        displayOrder: 5,
        accessibilityLabel: "Royal purple premium felt"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ FOREST GREEN - Deep and natural                                          │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let forestGreen = TableFeltColor(
        name: "Forest Green",
        primaryColor: Color(red: 0.05, green: 0.35, blue: 0.1),    // Forest green
        secondaryColor: Color(red: 0.02, green: 0.25, blue: 0.05), // Darker forest
        gradientAngle: 135,
        isPremium: false,
        displayOrder: 6,
        accessibilityLabel: "Forest green natural felt"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ NAVY BLUE - Classic and refined                                          │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let navyBlue = TableFeltColor(
        name: "Navy Blue",
        primaryColor: Color(red: 0.0, green: 0.08, blue: 0.25),    // Navy
        secondaryColor: Color(red: 0.0, green: 0.04, blue: 0.18),  // Darker navy
        gradientAngle: 135,
        isPremium: true,
        displayOrder: 7,
        accessibilityLabel: "Navy blue refined felt"
    )

    // ┌──────────────────────────────────────────────────────────────────────────┐
    // │ CRIMSON RED - Bold and striking                                          │
    // └──────────────────────────────────────────────────────────────────────────┘
    static let crimsonRed = TableFeltColor(
        name: "Crimson Red",
        primaryColor: Color(red: 0.6, green: 0.08, blue: 0.12),    // Crimson
        secondaryColor: Color(red: 0.45, green: 0.04, blue: 0.08), // Darker crimson
        gradientAngle: 135,
        isPremium: true,
        displayOrder: 8,
        accessibilityLabel: "Crimson red bold felt"
    )
}

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ CodableColor                                                                  │
// │                                                                               │
// │ Wrapper to make SwiftUI Color Codable for persistence.                      │
// └──────────────────────────────────────────────────────────────────────────────┘
struct CodableColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double

    init(color: Color) {
        // Extract RGBA components
        // Note: This is a simplified version. In production, you might want
        // to use UIColor/NSColor for more reliable component extraction
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
