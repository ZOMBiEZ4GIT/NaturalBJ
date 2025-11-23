# Blackjack iOS App - Complete Project Specification

## 🎯 Vision & Core Concept

A simple, modern blackjack app for iOS that uses **dealer personalities** to represent different rule sets. Each dealer has a distinct character and playstyle that determines the house rules, making rule selection intuitive and engaging rather than navigating complex settings menus.

### Design Philosophy
- **Simple. Modern. Clean.** - Inspired by offsuit.app's aesthetic
- Minimal UI with maximum clarity
- Smooth animations, no clutter
- Dark theme with accent colours for key information
- Educational without being preachy
- Engaging without being overwhelming

---

## 👥 Dealer Personalities & Rule Sets

Each dealer is an avatar character with distinct visual design, personality traits, and rule sets. Players choose their dealer, which automatically sets the game rules.

### 1. **Ruby** - The Vegas Classic
**Personality:** Professional, by-the-book, classic Vegas energy  
**Avatar:** Elegant red-themed character  
**Tagline:** "Let's keep it traditional"

**Rules:**
- 6 decks
- Dealer stands on soft 17
- Double on any two cards
- Double after split allowed
- Split up to 3 hands (4 total)
- Aces can be split once, one card each
- No surrender
- Blackjack pays 3:2
- House edge: ~0.55%

---

### 2. **Lucky** - The Player's Friend
**Personality:** Generous, laid-back, rooting for you  
**Avatar:** Gold/yellow themed lucky character  
**Tagline:** "I'm on your side!"

**Rules:**
- Single deck
- Dealer stands on soft 17
- Double on any two cards
- **Free doubles** - Double down costs nothing (still get one card)
- **Free splits** - Split costs nothing, cards dealt as normal
- Re-split aces allowed
- Late surrender allowed
- Blackjack pays 3:2
- House edge: Slightly player-favoured

---

### 3. **Shark** - The High Roller
**Personality:** Aggressive, confident, high stakes  
**Avatar:** Sharp blue/grey character  
**Tagline:** "Big risks, big rewards"

**Rules:**
- 8 decks
- Dealer hits soft 17
- Double on 9, 10, 11 only
- No double after split
- Split once only (2 hands max)
- No re-splitting aces
- No surrender
- Blackjack pays 6:5
- House edge: ~2%
- **Special:** Minimum bet is 5x normal, payouts scaled accordingly

---

### 4. **Zen** - The Teacher
**Personality:** Calm, patient, educational  
**Avatar:** Purple/zen themed character  
**Tagline:** "Learn the way"

**Rules:**
- 2 decks
- Dealer stands on soft 17
- Double on any two cards
- Double after split allowed
- Re-split up to 4 hands
- Re-split aces allowed
- Early surrender allowed
- Blackjack pays 3:2
- **Special:** Basic strategy hints always enabled
- **Special:** Hand probabilities shown on request
- House edge: ~0.35%

---

### 5. **Blitz** - The Speed Demon
**Personality:** Fast-paced, energetic, quick decisions  
**Avatar:** Red/orange lightning themed  
**Tagline:** "Let's go! No time to waste!"

**Rules:**
- 6 decks
- Dealer stands on soft 17
- Standard blackjack rules (similar to Ruby)
- **Special:** 5-second decision timer on each action
- **Special:** Speed multiplier - faster wins = bigger bonuses
- **Special:** Streak bonuses for consecutive quick wins
- House edge: ~0.55%

---

### 6. **Maverick** - The Wild Card
**Personality:** Unpredictable, fun, experimental  
**Avatar:** Multi-coloured chaotic character  
**Tagline:** "Expect the unexpected"

**Rules:**
- **Rules randomise each shoe** from a pool of fair variations
- Displays current rules clearly at start of shoe
- Always between 0.4% - 0.8% house edge (fair range)
- Can include wild rules like:
  - 5-card charlie (automatic win with 5 cards)
  - Suited blackjack pays 2:1
  - 777 bonus pays 3:1
  - Late surrender on any hand total
- **Special:** Mystery bonus rounds

---

## 🎮 Core Gameplay Mechanics

### Card Display & Dealing
- **Card size:** Large, readable, centered on screen
- **Dealing animation:** Smooth slide from dealer to player position (~0.3s)
- **Card reveal:** Dealer's hole card flips with satisfying animation
- **Hand totals:** Prominent display above each hand
  - Shows soft/hard status clearly (e.g., "Soft 17" or "Hard 16")
  - Turns red when bust
  - Highlights blackjack in gold

### Action Buttons
Positioned at bottom third of screen, similar to poker app reference:

**Primary Actions (Always visible when applicable):**
- **Hit** - Tap to take another card
- **Stand** - Tap to end turn
- **Double** - Appears when doubling is allowed
- **Split** - Appears when splitting is allowed
- **Surrender** - Appears when surrender is available (where rules permit)

**Secondary Actions:**
- **? Hint** - Small button that pulses with basic strategy recommendation
- **Settings** ⚙️ - Top right corner
- **Dealer Info** ℹ️ - Tap dealer avatar to see their rules

### Betting System
- **Chip display:** Top left, large readable number
- **Bet slider:** Appears before each hand
  - Quick bet presets: Min, 25%, 50%, 100%, Max
  - Fine control via slider
  - Previous bet remembered
- **Minimum bet:** $10 default (adjustable in settings)
- **Starting bankroll:** $10,000 (adjustable in settings)

### Speed Control
- **Instant mode:** No animations, immediate results
- **Normal mode:** Smooth animations (~0.5s per action)
- **Slow mode:** Extended animations (~1s per action), good for learning
- Adjustable in settings, persists between sessions

---

## 📊 Statistics & Progress Tracking

### Session Statistics (Swipe-up panel)
Accessible by swiping up from bottom of screen:

- **Current Session:**
  - Hands played
  - Hands won / lost / pushed
  - Win rate %
  - Biggest win this session
  - Biggest loss this session
  - Current streak (wins/losses)
  - Net profit/loss
  - Time played

- **All-Time Stats:**
  - Total hands played
  - Overall win rate
  - Best session
  - Favourite dealer
  - Total profit/loss across all sessions

### Bankroll Management
- **Main balance:** Persistent across sessions
- **Session view:** Shows starting balance vs current
- **Reset options:**
  - Reset to default ($10,000)
  - Custom starting amount
  - "Bankruptcy reset" - automatic offer when balance < minimum bet

---

## 🎯 Daily Challenge Mode

One curated challenge per day, resets at midnight local time.

### Challenge Types:
1. **Win Streak:** Win X hands in a row
2. **Profit Target:** Turn $100 into $X
3. **Perfect Play:** Play X hands with perfect basic strategy
4. **Comeback King:** Recover from a Y% loss to profit
5. **Speed Run:** Win X hands in under Y minutes
6. **Dealer Specific:** Beat [Dealer Name] in X hands
7. **High Roller:** Win a hand with max bet
8. **Conservative:** Win X hands without busting once

### Challenge Rewards:
- **Completion badge** displayed on profile
- **Bankroll bonus** (e.g., +$1,000 added to balance)
- **Leaderboard placement** for that day's challenge
- Track streak of consecutive daily challenges completed

---

## 🏆 Leaderboard System

### Weekly Leaderboard
Resets every Monday at midnight:

- **Ranking metric:** Bankroll growth percentage (not absolute amount)
  - Keeps competition fair regardless of starting bankroll
  - Formula: ((Current - Starting) / Starting) × 100
- **Display:**
  - Top 100 players
  - Your current rank
  - Percentile placement
  - Ghost data (see below)

### Ghost Comparison
- **Concept:** See how other top players played the same shoe
- **Implementation:**
  - After completing a shoe, optionally view decisions made by top 10 players
  - Shows: Hit/Stand/Double/Split decisions at each point
  - Highlights differences from your play
  - Educational without being intrusive
- **Privacy:** All data anonymised, shown as "Player #1", "Player #2", etc.

---

## 🎓 Learning Features

### Basic Strategy Hints
- **Toggle:** Can be enabled/disabled per dealer (always on for Zen)
- **Visual indicator:** Subtle glow/pulse on the recommended action button
- **Colour coding:**
  - Green pulse = Optimal play
  - Yellow pulse = Acceptable alternative
  - No pulse = Not recommended
- **Explanation mode:** Long-press hint button for why it's recommended
- **Learning tracking:** Stats show how often you follow basic strategy

### Hand Probabilities (Zen Dealer Only)
- **Tap "?" for detailed breakdown:**
  - Probability of busting on hit
  - Probability of dealer busting
  - Expected value of each action
  - Best mathematical play
- **Chart mode:** Shows full basic strategy chart
- **Tutorial mode:** First 10 hands with Zen include explanations

---

## 🎨 UI/UX Design Specification

### Colour Palette
- **Background:** Pure black (#000000)
- **Card background:** White (#FFFFFF)
- **Suit colours:** 
  - Red suits: #FF3B30
  - Black suits: #000000
- **Chip display:** Gold gradient (#FFD700 to #FFA500)
- **Buttons:**
  - Primary actions: Dark grey (#2C2C2E) with white text
  - Destructive: Red tint (#FF3B30)
  - Success: Green tint (#34C759)
- **Accent colours per dealer:**
  - Ruby: #FF3B30
  - Lucky: #FFD700
  - Shark: #0A84FF
  - Zen: #AF52DE
  - Blitz: #FF9500
  - Maverick: Rainbow gradient

### Typography
- **System font:** SF Pro (Apple's system font)
- **Card numbers:** SF Pro Display Bold
- **Hand totals:** SF Pro Display Semibold, size 24pt
- **Chip count:** SF Pro Display Bold, size 32pt
- **Button text:** SF Pro Text Medium, size 17pt

### Layout Structure

**Main Game Screen:**
```
┌─────────────────────────────────┐
│  💰 10,250      [ℹ️]       [⚙️]  │  ← Top bar
│                                   │
│      [Dealer Avatar]              │  ← Dealer position
│         "Dealer: 17"              │
│       [K♠] [7♥]                   │
│                                   │
│                                   │
│         "Your: 19"                │  ← Player position
│       [10♦] [9♣]                  │
│                                   │
│                                   │
│  [Hit]  [Stand]  [Double]  [?]   │  ← Action buttons
│                                   │
│  ═══════════════════════════     │  ← Swipe indicator
└─────────────────────────────────┘
```

**Statistics Panel (Swipe Up):**
```
┌─────────────────────────────────┐
│  ╭─── Session Stats ───╮        │
│  │ Hands: 24            │        │
│  │ Won: 11 (45.8%)      │        │
│  │ Net: +$1,240         │        │
│  │ Streak: 3 wins       │        │
│  ╰──────────────────────╯        │
│                                   │
│  ╭─── All Time ─────────╮        │
│  │ Total Hands: 1,248   │        │
│  │ Win Rate: 43.2%      │        │
│  │ Best Session: +$5.2K │        │
│  ╰──────────────────────╯        │
└─────────────────────────────────┘
```

### Animations & Transitions
- **Card dealing:** 0.3s ease-out slide from top
- **Card flip:** 0.4s 3D rotation on Y-axis
- **Chip updates:** 0.5s count-up animation with slight bounce
- **Button presses:** 0.1s scale down to 0.95, then bounce back
- **Screen transitions:** 0.3s slide from right (dealer selection, settings)
- **Dealer switching:** 0.5s fade transition with avatar swap

---

## ⚙️ Settings & Configuration

### Gameplay Settings
- **Starting bankroll:** $1K / $5K / $10K / $25K / $50K / Custom
- **Minimum bet:** $5 / $10 / $25 / $50 / $100 / Custom
- **Animation speed:** Instant / Normal / Slow
- **Sound effects:** On / Off
- **Haptic feedback:** On / Off
- **Tutorial mode:** On / Off (explains decisions first time)

### Display Settings
- **Theme:** Dark (only option for now, light theme future consideration)
- **Card design:** Classic / Modern / Minimalist
- **Avatar style:** Illustrated / Emoji / Abstract
- **Show probabilities:** On / Off (Zen only)

### Accessibility
- **VoiceOver support:** Full screen reader compatibility
- **Dynamic type:** Respect system text size settings
- **Reduce motion:** Disable non-essential animations
- **Colour blind mode:** High contrast card suits

### Data & Privacy
- **Anonymous leaderboard participation:** On / Off
- **Share hand history with ghosts:** On / Off
- **Daily challenges:** On / Off
- **Reset all statistics:** Nuclear option, requires confirmation
- **Export statistics:** CSV export of all hand history

---

## 🎵 Audio Design

### Sound Effects (Subtle & Clean)
- **Card deal:** Soft swish sound
- **Card flip:** Quick snap
- **Chip collect (win):** Pleasant chime
- **Chip loss:** Subtle low tone
- **Blackjack:** Special celebratory chime
- **Button tap:** Minimal click
- **Bust:** Brief negative tone
- **Push:** Neutral beep
- **Dealer actions:** Slightly different pitch than player actions

### Volume Levels
- All sounds at 70% max volume by default
- Master volume control in settings
- Individual sound toggle option

**No background music** - keeps focus on gameplay, player can use their own

---

## 📱 Technical Implementation

### Platform
- **iOS 16.0+** (to support latest SwiftUI features)
- **iPhone only** (iPad support future consideration)
- **Portrait orientation** only
- **Native Swift/SwiftUI** implementation

### Architecture
```
┌─────────────────────────────────┐
│     SwiftUI Views                │
│  (Game, Stats, Settings)         │
├─────────────────────────────────┤
│     ViewModels                   │
│  (Game Logic, State Management)  │
├─────────────────────────────────┤
│     Models                       │
│  (Card, Dealer, Rules, Player)   │
├─────────────────────────────────┤
│     Services                     │
│  (Deck, Strategy, Stats)         │
├─────────────────────────────────┤
│     Persistence                  │
│  (SwiftData for local storage)   │
└─────────────────────────────────┘
```

### Key Components

**Models:**
- `Card`: Rank, suit, value calculation
- `Dealer`: Personality, rules, avatar, behaviour
- `Hand`: Collection of cards, total calculation, status
- `Player`: Bankroll, statistics, settings
- `GameRules`: Rule set definition per dealer
- `Challenge`: Daily challenge definition and tracking

**Services:**
- `DeckManager`: Shuffle, deal, track cards (shoe management)
- `StrategyEngine`: Basic strategy calculations, hint generation
- `StatisticsTracker`: Hand history, win rates, streaks
- `LeaderboardService`: Rank calculation, ghost data
- `AudioManager`: Sound effect playback

**Persistence:**
- `SwiftData` for all local storage
- Models to persist:
  - Player profile (bankroll, settings)
  - Hand history (for statistics)
  - Challenge completion tracking
  - Leaderboard cache (weekly)

### Card Logic

**Deck Composition:**
- 52 cards per deck (13 ranks × 4 suits)
- Multiple decks based on dealer rules
- Shoe reshuffled at 75% penetration (standard casino practice)

**Card Values:**
- 2-10: Face value
- J, Q, K: 10
- Ace: 1 or 11 (automatically calculated for soft/hard hands)

**Hand Evaluation:**
```swift
// Pseudocode for hand evaluation
func evaluateHand(cards: [Card]) -> (total: Int, isSoft: Bool, isBlackjack: Bool) {
    var total = 0
    var aces = 0
    
    for card in cards {
        if card.rank == .ace {
            aces += 1
            total += 11
        } else {
            total += card.value
        }
    }
    
    // Adjust aces from 11 to 1 if needed
    while total > 21 && aces > 0 {
        total -= 10
        aces -= 1
    }
    
    let isSoft = (aces > 0 && total <= 21)
    let isBlackjack = (cards.count == 2 && total == 21)
    
    return (total, isSoft, isBlackjack)
}
```

### Basic Strategy Engine

**Strategy Table:**
- Pre-computed optimal plays for all scenarios
- Indexed by: (Player total, Dealer upcard, Soft/Hard, Can double, Can split)
- Returns: Recommended action (Hit, Stand, Double, Split, Surrender)

**Implementation:**
- JSON file with strategy table
- Loaded at app startup
- Fast lookup for real-time hints
- Separate tables for different rule variations

### Animation System

**Core Principles:**
- All animations interruptible for speed mode
- Smooth 60fps animations using SwiftUI `.animation()`
- Physics-based animations for card dealing (spring animation)
- Separate animation pipeline for instant mode (bypasses animations)

### Performance Targets
- **Launch time:** < 1 second
- **Action response:** < 100ms (instant mode) or animation duration
- **Memory footprint:** < 50MB
- **Battery impact:** Minimal (efficient rendering, no background processes)
- **Storage:** < 100MB app size, < 10MB user data

---

## 🚀 User Flows

### First Launch Flow
1. **Splash screen** (0.5s) - App logo
2. **Welcome screen** - "Simple. Modern. Blackjack."
3. **Tutorial prompt** - "Want a quick tutorial?" (Yes / Skip)
4. **Choose starting bankroll** - Preset options
5. **Choose minimum bet** - Preset options
6. **Meet the dealers** - Swipeable carousel of all dealers with brief descriptions
7. **Select first dealer** - Tap to select
8. **First hand** - Tutorial overlay if opted in
9. **Game begins**

### Typical Game Flow
1. **Main screen loads** - Shows current dealer, bankroll, ready to play
2. **Bet selection** - Slider or presets appear
3. **Confirm bet** - Tap to lock in
4. **Cards dealt** - Animation sequence
5. **Player actions** - Hit/Stand/Double/Split as appropriate
6. **Dealer plays** - Automatic, animated
7. **Result shown** - Win/Loss/Push with chip change animation
8. **Next hand** - Return to step 2, or option to switch dealers

### Switching Dealers Flow
1. **Tap dealer avatar** or settings icon
2. **Dealer selection screen** - Carousel of all dealers
3. **Tap dealer** - Preview of rules and personality
4. **Confirm switch** - "Switch to [Dealer Name]?"
5. **Transition animation** - Smooth swap
6. **New game begins** - Current shoe discarded, fresh shoe with new rules

### Daily Challenge Flow
1. **Challenge notification** - Appears on main screen if available
2. **Tap challenge card** - See details and requirements
3. **Accept challenge** - "Let's go!" button
4. **Challenge mode** - Normal gameplay with challenge tracker overlay
5. **Progress indicator** - Top of screen shows progress
6. **Completion** - Special animation and reward
7. **Leaderboard option** - "See how others did"

---

## 📈 Future Enhancements (Post-Launch)

### Phase 2 Considerations
- **More dealers:** Community can suggest new personalities/rules
- **Custom rule builder:** Advanced users create their own dealer
- **Multiplayer mode:** Compete on same shoe as friends
- **Card counting practice mode:** Toggle that shows running/true count
- **Tournament mode:** Timed events with global leaderboards
- **Apple Watch companion:** Quick stats and challenge reminders
- **Widgets:** iOS widget showing current bankroll or daily challenge
- **Achievements system:** Unlock badges for milestones
- **Replay mode:** Review past hands and decisions

### Monetisation Options (If Needed)
- **Free version:** Full gameplay, all dealers, ads removed after gameplay session
- **Premium ($4.99 AUD one-time):**
  - Remove ads entirely
  - Unlock advanced statistics
  - Export hand history
  - Custom starting bankroll amounts
  - Priority leaderboard features
- **No IAPs, no subscriptions, no pay-to-win mechanics**

---

## 🧪 Testing & Quality Assurance

### Unit Tests
- Card dealing logic (randomness, shuffling)
- Hand evaluation (soft/hard, blackjack detection)
- Basic strategy engine (all scenarios)
- Bankroll calculations (win/loss/push)
- Rule set variations per dealer

### Integration Tests
- Full game flow from bet to payout
- Dealer switching mid-session
- Statistics tracking across sessions
- Challenge completion and rewards
- Leaderboard ranking calculations

### UI Tests
- All user flows navigable
- Buttons enabled/disabled appropriately
- Animations complete without crashes
- Accessibility features functional
- Settings persist correctly

### Edge Cases to Test
- Bankrupt scenario (balance < minimum bet)
- Multiple splits (up to 4 hands)
- Splitting aces with different rules
- Free double/split mechanics (Lucky dealer)
- Speed mode with rapid actions
- Very large bankroll numbers (display formatting)

---

## 📋 Development Checklist

### Foundation (Week 1-2)
- [ ] Project setup (Xcode, SwiftUI, SwiftData)
- [ ] Core models (Card, Deck, Hand, Player)
- [ ] Basic UI structure (game screen layout)
- [ ] Card dealing logic and animations
- [ ] Hand evaluation engine
- [ ] Basic action buttons (Hit/Stand)

### Core Gameplay (Week 3-4)
- [ ] All action types (Double, Split, Surrender)
- [ ] Dealer AI logic per rule set
- [ ] Betting system and bankroll management
- [ ] Payout calculations
- [ ] Win/Loss/Push detection
- [ ] Basic game loop (bet → play → result → repeat)

### Dealers & Rules (Week 5-6)
- [ ] Dealer model with rule sets
- [ ] 6 dealer personalities defined
- [ ] Dealer avatars designed/implemented
- [ ] Rule set variations working correctly
- [ ] Dealer selection screen
- [ ] Dealer info display

### Statistics & Persistence (Week 7)
- [ ] SwiftData persistence setup
- [ ] Session statistics tracking
- [ ] All-time statistics
- [ ] Statistics display panel
- [ ] Bankroll reset options
- [ ] Hand history logging

### Learning Features (Week 8)
- [ ] Basic strategy table implementation
- [ ] Hint system with visual indicators
- [ ] Strategy engine integration
- [ ] Probability calculations (Zen)
- [ ] Tutorial mode for first-time users

### Challenge & Leaderboard (Week 9-10)
- [ ] Daily challenge system
- [ ] Challenge types implemented
- [ ] Reward system
- [ ] Leaderboard service (mock data initially)
- [ ] Ghost comparison feature
- [ ] Weekly reset logic

### Polish & Settings (Week 11-12)
- [ ] Settings screen fully implemented
- [ ] Animation speed controls
- [ ] Audio system and sound effects
- [ ] Accessibility features
- [ ] Theme consistency check
- [ ] Performance optimization

### Testing & Launch Prep (Week 13-14)
- [ ] Comprehensive testing (unit, integration, UI)
- [ ] Bug fixes
- [ ] App Store assets (screenshots, description, icon)
- [ ] Privacy policy and compliance
- [ ] TestFlight beta testing
- [ ] Final polish and App Store submission

---

## 📝 Content Writing

### App Store Description

**Title:** Simple Blackjack - Clean & Modern

**Subtitle:** Learn, Play, Master

**Description:**
```
Simple. Modern. Blackjack.

Choose your dealer, place your bets, and play authentic blackjack with a clean, modern interface. No clutter, no gimmicks—just pure gameplay.

MEET YOUR DEALERS
Each dealer has a unique personality and rule set:

• Ruby - Classic Vegas rules, professional and by-the-book
• Lucky - Player-friendly rules with free doubles and splits
• Shark - High-roller stakes with tougher rules
• Zen - Patient teacher with strategy hints and probabilities
• Blitz - Fast-paced speed rounds for quick sessions
• Maverick - Unpredictable rules that change every shoe

LEARN AS YOU PLAY
• Optional basic strategy hints
• Hand probability calculator
• Track your improvement over time
• Tutorial mode for beginners

COMPETE & CHALLENGE
• Daily challenges for bonus rewards
• Weekly leaderboards based on growth, not absolute wealth
• Compare your plays with top players (Ghost mode)

CLEAN DESIGN
• Dark, modern aesthetic
• Smooth animations you can control
• No annoying ads during gameplay
• No timers, energy systems, or manipulative mechanics

Your game, your pace, your style. Just blackjack, done right.
```

### In-App Tutorial Text

**First Launch:**
"Welcome! Blackjack is simple: get closer to 21 than the dealer without going over. Face cards are worth 10, Aces are 1 or 11. Tap 'Hit' for another card, 'Stand' to stick with what you have. Let's play!"

**Zen Dealer Introduction:**
"Hi, I'm Zen. I'm here to help you learn. Watch for the glowing hints—they'll show you the mathematically optimal play. Take your time, there's no rush. Let's make you a better player."

**Lucky Dealer Introduction:**
"Hey, I'm Lucky! I've got your back. Free doubles mean you can double down without extra cost, and free splits work the same way. Good luck—you'll need less of it with me!"

---

## 🎨 Asset Requirements

### Dealer Avatars
- 6 unique character designs
- Vector format (SF Symbols style or custom SVG)
- Optimised for iOS rendering
- Consistent style across all dealers
- Variations: Normal, Happy (win), Sad (loss), Thinking

### Card Designs
- 52 card faces (4 suits × 13 ranks)
- Card back design
- High resolution for all iPhone screens
- Vector or @3x raster assets
- Multiple style options (Classic, Modern, Minimalist)

### UI Elements
- App icon (1024×1024, various sizes for system)
- Launch screen graphic
- Button states (normal, pressed, disabled)
- Chip/currency icons
- Trophy/achievement icons
- Settings icons (SF Symbols where possible)

### Animations
- Card dealing sequences
- Chip count-up animations
- Win/loss celebration effects
- Transition effects between screens
- Micro-interactions (button presses, swipes)

---

## 🔐 Privacy & Data Handling

### Data Collection
**We collect:**
- Gameplay statistics (hands played, win rate)
- Anonymous leaderboard data (if opted in)
- Challenge completion data
- App settings and preferences

**We DO NOT collect:**
- Personal identity information
- Location data
- Contact information
- Payment information (no IAPs initially)
- Device identifiers beyond anonymous analytics

### Data Storage
- All data stored locally using SwiftData
- No cloud sync initially (future consideration)
- No third-party analytics by default
- Optional anonymous participation in leaderboards

### Data Deletion
- "Reset all statistics" in settings
- Clear action with confirmation dialog
- Irreversible (warn user)
- Maintains app settings unless separately reset

---

## ✅ Success Metrics

### Launch Targets (First 30 Days)
- 1,000+ downloads
- 4.5+ star rating
- 70%+ Day 1 retention
- 40%+ Day 7 retention
- < 1% crash rate
- Positive community feedback

### Engagement Metrics
- Average session length: 5-10 minutes
- Daily active users: 30% of total installs
- Challenge participation: 50%+ of DAU
- Dealer variety: Users try at least 3 different dealers
- Strategy improvement: Users following hints more over time

### Quality Metrics
- App Store review sentiment: 80%+ positive
- Bug reports: < 5% of users report issues
- Performance: 4.5+ stars for "App Quality" in reviews
- Accessibility: Positive feedback from users with accessibility needs

---

## 📞 Support & Community

### In-App Support
- "Help" section in settings
- FAQ covering basic rules and app features
- Contact form for bug reports/feedback
- Link to App Store reviews for ratings

### Community Engagement
- Subreddit or Discord for player discussion (future)
- Regular updates based on feedback
- Transparency about upcoming features
- User suggestions for new dealers/rules

---

## 🎬 Conclusion

This blackjack app combines clean design, engaging gameplay, and educational features without complexity or manipulation. By using dealer personalities to represent rule sets, we make configuration intuitive and fun. The focus is on pure blackjack skill development with just enough gamification (challenges, leaderboards) to keep players engaged without becoming exploitative.

The app respects the player's time, intelligence, and autonomy. No dark patterns, no pay-to-win, no artificial scarcity. Just great blackjack with personality.

---

**Document Version:** 1.0  
**Last Updated:** November 2025  
**Status:** Complete Specification - Ready for Development
