# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Natural** (formerly NaturalBJ) is a modern iOS blackjack app built with SwiftUI. The app uses dealer personalities to represent different rule sets, making configuration intuitive and engaging. Each dealer has distinct visual design, personality traits, and playing rules.

**Platform:** iOS 16.0+, Swift/SwiftUI, native implementation
**Current Phase:** Phase 7 (Animations & Polish) - 95% complete
**Primary Language:** Australian English (use "colour", "customisation", etc.)

## Build & Run Commands

### Building the Project
```bash
# Build for simulator (Debug)
xcodebuild -project NaturalBJ.xcodeproj -scheme NaturalBJ -configuration Debug -sdk iphonesimulator build

# Build for device (Release)
xcodebuild -project NaturalBJ.xcodeproj -scheme NaturalBJ -configuration Release -sdk iphoneos build

# Clean build folder
xcodebuild clean -project NaturalBJ.xcodeproj -scheme NaturalBJ
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project NaturalBJ.xcodeproj -scheme NaturalBJ -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test file
xcodebuild test -project NaturalBJ.xcodeproj -scheme NaturalBJ -only-testing:NaturalBJTests/GameViewModelTests -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test method
xcodebuild test -project NaturalBJ.xcodeproj -scheme NaturalBJ -only-testing:NaturalBJTests/GameViewModelTests/testDealInitialCards -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Swift Package Manager (if dependencies added later)
```bash
# Resolve packages
xcodebuild -resolvePackageDependencies

# Update packages
swift package update
```

## High-Level Architecture

### MVVM Pattern with SwiftUI

The app follows the Model-View-ViewModel pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                         Views Layer                          │
│  (SwiftUI Views - declarative UI, observe ViewModels)       │
├─────────────────────────────────────────────────────────────┤
│                      ViewModels Layer                        │
│  (Business logic, @Published state, game orchestration)     │
├─────────────────────────────────────────────────────────────┤
│                       Models Layer                           │
│  (Data structures, game rules, dealer configs)              │
├─────────────────────────────────────────────────────────────┤
│                      Services Layer                          │
│  (Reusable managers - audio, haptics, animations, stats)    │
├─────────────────────────────────────────────────────────────┤
│                    Persistence Layer                         │
│  (SwiftData for local storage, UserDefaults for settings)   │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Concepts

**1. Game State Machine**

The game operates as a state machine defined in `GameViewModel`:
```
.betting → .dealing → .playerTurn → .dealerTurn → .result → .betting
                                                      ↓
                                                  .gameOver (bankruptcy)
```

Each state determines available actions and UI display.

**2. Dealer Personalities = Rule Sets**

Instead of complex settings menus, players choose a dealer personality:
- **Ruby** (Classic Vegas): Standard 6-deck rules, dealer stands on soft 17
- **Lucky** (Player's Friend): Free doubles/splits, single deck, player-favoured
- **Shark** (High Roller): 8 decks, dealer hits soft 17, 6:5 blackjack, high stakes
- **Zen** (Teacher): Educational mode with strategy hints and probabilities
- **Blitz** (Speed Demon): Timer-based gameplay with speed bonuses
- **Maverick** (Wild Card): Randomised rules each shoe

Each dealer's rules are encapsulated in their `GameRules` struct.

**3. Animation Coordination System**

Phase 7 implements a sophisticated multi-sensory feedback system:

```
GameViewModel (triggers action)
       ↓
GameAnimationCoordinator (orchestrates)
       ↓
┌──────────────┬──────────────┬──────────────┬──────────────┐
│ Card         │ Chip         │ Audio        │ Haptic       │
│ Animation    │ Animation    │ Manager      │ Manager      │
│ Manager      │ Manager      │              │              │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

All game actions (hit, stand, split, etc.) trigger coordinated animations, sounds, and haptic feedback.

**4. Singleton Services**

Core services use the singleton pattern with `@MainActor`:
- `AudioManager.shared` - Sound effects and music
- `HapticManager.shared` - Tactile feedback
- `VisualSettingsManager.shared` - Visual customisation
- `StatisticsManager.shared` - Game statistics tracking
- `AchievementManager.shared` - Achievement system
- `ChallengeManager.shared` - Daily/weekly challenges

**5. Statistics & Progression System**

Two-tier statistics:
- **Session Stats**: Current play session (tracked until dealer change)
- **All-Time Stats**: Persistent across all sessions

Tracked via `StatisticsManager` with `HandResult` models stored for analysis.

## Project Structure

```
NaturalBJ/
├── NaturalBJ/
│   ├── NaturalBJApp.swift           # App entry point, SwiftData setup
│   ├── ContentView.swift            # Root view (currently shows GameView)
│   ├── Models/                      # Data models and enums
│   │   ├── Card.swift              # Card representation (rank, suit, value)
│   │   ├── Deck.swift              # Deck model
│   │   ├── Hand.swift              # Hand of cards with evaluation logic
│   │   ├── Dealer.swift            # Dealer personalities with rules
│   │   ├── GameRules.swift         # Rule set definitions
│   │   ├── PlayerProfile.swift     # Player data and settings
│   │   ├── Session.swift           # Play session tracking
│   │   ├── HandResult.swift        # Individual hand outcome
│   │   ├── Challenge.swift         # Daily/weekly challenge definitions
│   │   ├── Achievement.swift       # Achievement system
│   │   ├── SoundEffect.swift       # Audio effect enumeration
│   │   ├── HapticType.swift        # Haptic feedback types
│   │   ├── CardBackDesign.swift    # Card customisation
│   │   ├── TableFeltColor.swift    # Table customisation
│   │   └── VisualSettings.swift    # Visual preferences model
│   ├── ViewModels/
│   │   ├── GameViewModel.swift     # CRITICAL: Core game logic & state
│   │   ├── StatisticsViewModel.swift
│   │   ├── TutorialViewModel.swift
│   │   └── HelpViewModel.swift
│   ├── Views/
│   │   ├── Game/
│   │   │   ├── GameView.swift      # Main game screen
│   │   │   └── CardView.swift      # Card rendering
│   │   ├── Dealers/
│   │   │   ├── DealerSelectionView.swift
│   │   │   └── DealerInfoView.swift
│   │   ├── Statistics/
│   │   │   └── StatisticsView.swift
│   │   ├── Tutorial/
│   │   │   └── TutorialOverlayView.swift
│   │   ├── Challenges/
│   │   │   └── ChallengesView.swift
│   │   ├── Achievements/
│   │   │   └── AchievementsView.swift
│   │   └── SettingsView.swift      # App settings (includes Phase 7 controls)
│   ├── Services/                    # Singleton managers
│   │   ├── DeckManager.swift       # Shoe management, dealing cards
│   │   ├── StatisticsManager.swift # Session & all-time stats
│   │   ├── AudioManager.swift      # Sound effects (Phase 7)
│   │   ├── HapticManager.swift     # Haptic feedback (Phase 7)
│   │   ├── CardAnimationManager.swift    # Card animations (Phase 7)
│   │   ├── ChipAnimationManager.swift    # Betting animations (Phase 7)
│   │   ├── TransitionManager.swift       # State transitions (Phase 7)
│   │   ├── GameAnimationCoordinator.swift # Animation orchestration (Phase 7)
│   │   ├── VisualSettingsManager.swift   # Visual preferences (Phase 7)
│   │   ├── AccessibilityManager.swift    # Accessibility features (Phase 7)
│   │   ├── AchievementManager.swift
│   │   ├── ChallengeManager.swift
│   │   ├── TutorialManager.swift
│   │   └── MaverickRuleGenerator.swift   # Random rules for Maverick dealer
│   └── Utils/
│       ├── Colors.swift            # Theme colours
│       ├── VoiceOverLabels.swift   # Accessibility labels (Phase 7)
│       └── StatisticsPersistence.swift
├── NaturalBJTests/              # Unit tests
├── NaturalBJUITests/            # UI tests
└── Documentation/
    ├── blackjack_app_spec.md        # Complete product specification
    ├── PHASE_2_COMPLETE.md          # Core gameplay phase report
    ├── PHASE_3_COMPLETE.md          # Dealer personalities phase
    ├── PHASE_4_COMPLETE.md          # Statistics phase
    ├── PHASE_6_COMPLETE.md          # Tutorial phase
    ├── PHASE_7_COMPLETE.md          # Animations & polish (current)
    └── AUDIO_ASSET_REQUIREMENTS.md  # Audio file specifications
```

## Critical Implementation Details

### GameViewModel is the Brain

`GameViewModel.swift` (~1,650 lines) is the central orchestrator:
- Manages complete game state machine
- Coordinates DeckManager for card dealing
- Implements dealer AI logic (dealer-specific soft 17 rules)
- Handles all player actions (hit, stand, double, split, surrender)
- Calculates payouts based on dealer rules (3:2 vs 6:5 blackjack)
- Tracks statistics via StatisticsManager
- Triggers animations via GameAnimationCoordinator (Phase 7)

When modifying game logic, this is the primary file.

### Hand Evaluation Logic

The `Hand` model handles soft/hard hand calculation:
- Aces are automatically optimised (11 or 1)
- `isSoft` indicates an ace counting as 11
- `isBlackjack` checks for natural 21 (2 cards only)
- Dealer-specific rules affect when dealer hits soft 17

### Dealer-Specific Rule Variations

Critical dealer differences in `GameRules`:
- **Soft 17**: Ruby/Lucky stand, Shark hits (affects house edge)
- **Blackjack payout**: Most pay 3:2, Shark pays 6:5
- **Free doubles/splits**: Lucky only (no bankroll deduction)
- **Max split hands**: Shark limited to 2, others allow 4
- **Double restrictions**: Shark only allows 9/10/11
- **Surrender**: Lucky/Zen allow, others don't

### Animation Integration Pattern (Phase 7)

All game actions now follow this pattern:
```swift
func gameAction() {
    // Validate action
    guard canPerformAction else { return }

    // Trigger coordinated animation
    animationCoordinator.animateAction(params) { [weak self] in
        // Update game state AFTER animation
        self?.updateGameState()

        // Chain next animation if needed
        if needsNext { self?.nextAnimation() }
    }
}
```

Animations are asynchronous with completion handlers to maintain proper sequencing.

### Settings Persistence

Phase 7 settings use UserDefaults with JSON encoding:
- Visual settings: Table colours, card backs, animation speed
- Audio settings: Master volume, individual sound toggles
- Haptic settings: Intensity, individual haptic toggles
- All settings auto-save on change via `@Published` property observers

### Accessibility Compliance

The app implements comprehensive accessibility:
- VoiceOver labels for all UI elements
- Reduce Motion alternatives for animations
- Colour contrast adjustments
- Dynamic Type support
- Haptic feedback respects system settings

VoiceOver announcements for game events use `AccessibilityManager.announce()`.

## Development Phases

The app is being built in phases (see phase completion docs):

1. ✅ **Phase 1**: Foundation (Models, basic UI structure)
2. ✅ **Phase 2**: Core Gameplay (Hit, stand, betting, dealer AI)
3. ✅ **Phase 3**: Dealer Personalities (6 dealers with unique rules)
4. ✅ **Phase 4**: Statistics & Persistence (Session/all-time tracking)
5. ⏭️ **Phase 5**: Basic Strategy Engine (Not yet implemented)
6. ✅ **Phase 6**: Tutorial System (Interactive onboarding)
7. 🔨 **Phase 7**: Animations & Polish (95% complete - audio assets pending)
8. 🔜 **Phase 8**: Achievements & Progression (Next phase)
9. 🔜 **Phase 9**: Challenges & Events
10. 🔜 **Phase 10**: Leaderboards & Social
11. 🔜 **Phase 11**: Final Polish & Launch

## Common Development Patterns

### Adding a New Game Action

1. Add method to `GameViewModel`
2. Implement validation logic
3. Integrate animation via `GameAnimationCoordinator`
4. Update UI state in completion handler
5. Record statistics via `StatisticsManager`
6. Add unit test in `GameViewModelTests`

### Adding a New Sound Effect

1. Add case to `SoundEffect` enum in `Models/SoundEffect.swift`
2. Specify filename, volume, and haptic pairing
3. Add MP3 file to project (see `AUDIO_ASSET_REQUIREMENTS.md`)
4. Call via `AudioManager.shared.playSoundEffect(.newSound)`

### Adding Visual Customisation

1. Add property to `VisualSettings` model
2. Add toggle/picker in `SettingsView`
3. Apply setting in relevant view via `@EnvironmentObject var visualSettings`
4. Setting auto-persists via `VisualSettingsManager`

### Modifying Dealer Rules

1. Update `GameRules` struct in dealer definition (`Dealer.swift`)
2. GameViewModel automatically uses new rules via `rules` computed property
3. Update dealer info display in `DealerInfoView`
4. Test rule interactions in `DealerModelTests`

## Testing Strategy

### Unit Tests
- `CardModelTests`: Card evaluation, rank/suit logic
- `HandModelTests`: Hand calculation, soft/hard detection, blackjack
- `DeckModelTests`: Shuffling, dealing, shoe management
- `GameViewModelTests`: Core game flow, state transitions, payouts
- `DealerModelTests`: Rule set validation
- `StatisticsModelTests`: Stat tracking accuracy

Run tests targeting specific files to iterate quickly during development.

### UI Tests
- `BlackjackwhitejackUITests`: Full game flow
- Focus on accessibility compliance
- Test VoiceOver navigation

## Important Files to Review Before Major Changes

1. **blackjack_app_spec.md** - Complete product specification with design philosophy
2. **GameViewModel.swift** - Understand game state machine before modifying flow
3. **PHASE_7_COMPLETE.md** - Animation system architecture
4. **Dealer.swift** - Rule set variations for each dealer personality

## Current Known Issues & Pending Work

### Phase 7 (Current)
- ⏳ **Audio Assets**: 14 MP3 files need to be added (see AUDIO_ASSET_REQUIREMENTS.md)
- AudioManager gracefully handles missing files (no crashes)
- All animation integration complete in GameViewModel

### Future Phases
- Phase 5 (Basic Strategy Engine) not yet implemented
- Phase 8-11 are next in development pipeline

## Coding Standards

### Australian English
Use British spelling variants:
- "colour" not "color"
- "customisation" not "customization"
- "centre" not "center"
- "behaviour" not "behavior"

### Code Style
- Heavy commenting with box-drawing characters (see existing files)
- Business context in comments, not just technical description
- Clear separation between published properties and private properties
- SwiftUI view modifiers on separate lines for readability
- Comprehensive accessibility labels

### Architecture Principles
1. **Separation of Concerns**: Views don't contain business logic
2. **Reactive State**: Use `@Published` and `@ObservableObject` for state flow
3. **Testability**: Business logic in ViewModels, easily unit tested
4. **Accessibility First**: Not an afterthought - build it in from the start
5. **Performance**: 60fps animations, efficient rendering, singleton services

## SwiftData Persistence

Currently using `Item` model as placeholder. Future implementation will persist:
- Player profile (bankroll, settings)
- Hand history (for statistics)
- Achievement/challenge progress
- Session history

SwiftData schema defined in `NaturalBJApp.swift` - expand as needed.

## Animation System Deep Dive (Phase 7)

The animation system is the most complex architectural component:

### Layers of Coordination
1. **GameViewModel**: Triggers actions and manages game state
2. **GameAnimationCoordinator**: Orchestrates multi-sensory feedback
3. **Specialized Managers**: CardAnimationManager, ChipAnimationManager, TransitionManager
4. **Feedback Systems**: AudioManager, HapticManager (fire in parallel)

### Animation Sequencing
Animations use completion handlers for strict sequencing:
```swift
animateDeal {
    checkBlackjack()
    if blackjack {
        animateBlackjack {
            endHand()
        }
    }
}
```

### Accessibility Adaptations
- Reduce Motion: Simplified or instant animations
- VoiceOver: Announcements parallel to visual feedback
- Settings: User can disable effects individually

## References & Resources

- **Product Spec**: `blackjack_app_spec.md` - Complete vision and requirements
- **Phase Reports**: `PHASE_*_COMPLETE.md` - Implementation details per phase
- **Audio Guide**: `AUDIO_ASSET_REQUIREMENTS.md` - Sound effect specifications
- **Apple Docs**: SwiftUI, SwiftData, AVFoundation (audio), UIKit (haptics)

## Quick Start for New Features

1. Review product spec to ensure alignment with vision
2. Identify which phase the feature belongs to
3. Check phase completion docs for related infrastructure
4. Follow MVVM pattern: Model → ViewModel → View
5. Integrate animations via GameAnimationCoordinator
6. Add accessibility labels and VoiceOver support
7. Write unit tests for business logic
8. Test with VoiceOver and Reduce Motion enabled
9. Use Australian English in all strings and comments

## Final Notes

This is a premium blackjack app focused on user experience, not gambling mechanics. The dealer personality system makes rule selection intuitive. Phase 7's multi-sensory feedback system (visual + audio + haptic) creates a polished, casino-quality feel.

When in doubt, refer to `blackjack_app_spec.md` for design philosophy and `GameViewModel.swift` for implementation patterns.
