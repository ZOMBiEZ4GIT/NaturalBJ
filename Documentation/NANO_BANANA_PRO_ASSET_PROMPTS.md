# Nano Banana Pro AI Asset Generation Guide
## Natural Blackjack iOS App

**Model:** Gemini 3 Pro Image (Nano Banana Pro)
**API Endpoint:** `gemini-3-pro-image-preview`
**Date:** November 2025
**Purpose:** Generate all visual assets for Natural blackjack app

---

## 📋 Table of Contents

1. [Nano Banana Pro Overview](#nano-banana-pro-overview)
2. [API Configuration & Best Practices](#api-configuration--best-practices)
3. [Asset Categories](#asset-categories)
4. [Dealer Avatar Prompts](#dealer-avatar-prompts)
5. [Card Design Prompts](#card-design-prompts)
6. [App Icon & Branding](#app-icon--branding)
7. [UI Elements & Icons](#ui-elements--icons)
8. [Tutorial & Educational Graphics](#tutorial--educational-graphics)
9. [Marketing Assets](#marketing-assets)
10. [Batch Processing Strategy](#batch-processing-strategy)

---

## 🍌 Nano Banana Pro Overview

### Key Capabilities Relevant to This Project

- **High Resolution:** 1K, 2K, 4K output (use 4K for app icon, 2K for most assets)
- **Text Rendering:** Industry-leading text legibility (critical for card faces)
- **Character Consistency:** Up to 14 reference images for maintaining dealer personalities
- **Thinking Mode:** Advanced reasoning for complex compositions
- **Vector-Style Output:** Clean, scalable graphics perfect for iOS assets

### Why Nano Banana Pro is Ideal for This App

1. **Text on cards** (suit symbols, rank numbers) requires perfect rendering
2. **Character consistency** across dealer avatar variations (normal, happy, sad, thinking)
3. **High-resolution output** for Retina displays (@3x assets)
4. **Clean, modern aesthetic** matches app's design philosophy

---

## ⚙️ API Configuration & Best Practices

### API Call Structure

```python
import google.generativeai as genai

genai.configure(api_key='YOUR_API_KEY')

model = genai.GenerativeModel('gemini-3-pro-image-preview')

# Generate image
response = model.generate_images(
    prompt="your prompt here",
    number_of_images=1,  # Generate 1-4 variations
    aspect_ratio="1:1",   # Options: 1:1, 16:9, 9:16, 4:3, 3:4
    resolution="4K",      # Options: 1K, 2K, 4K
    safety_filter="default"
)
```

### Prompting Best Practices for Nano Banana Pro

1. **Be Concise & Direct:** Gemini 3 responds best to clear, direct prompts
2. **Structure:** Subject → Composition → Style → Technical specs
3. **Camera Terms:** Use photographic language (top-down view, macro shot, etc.)
4. **Negative Prompts:** Specify what to avoid (overexposure, blur, artifacts)
5. **Reference Images:** Use up to 14 reference images for consistency

### Resolution & Aspect Ratio Guide

| Asset Type | Resolution | Aspect Ratio | File Format |
|------------|-----------|--------------|-------------|
| App Icon | 4K | 1:1 | PNG |
| Dealer Avatars | 2K | 1:1 | PNG/SVG |
| Card Faces | 2K | 3:4 (portrait) | PNG |
| UI Icons | 2K | 1:1 | PNG/SVG |
| Screenshots | 4K | 9:16 (portrait) | PNG |
| Tutorial Graphics | 2K | 16:9 or 9:16 | PNG |

### Batch Processing Strategy

Use batch API to save 50% on costs:
- Group similar assets (all dealer normal states, all card faces)
- Process overnight for 24-hour turnaround
- Generate 2-4 variations per prompt for selection

---

## 📦 Asset Categories

### Priority 1: Core Gameplay Assets (Required for MVP)
- [ ] 6 Dealer Avatars (normal state)
- [ ] 52 Card Faces (Classic style)
- [ ] 1 Card Back Design
- [ ] App Icon
- [ ] Basic UI Icons (chip, settings, info)

### Priority 2: Enhanced Experience
- [ ] Dealer Avatar Variations (happy, sad, thinking) - 18 total
- [ ] Alternative Card Styles (Modern, Minimalist)
- [ ] Additional Card Back Designs
- [ ] Trophy/Achievement Icons
- [ ] Tutorial Graphics

### Priority 3: Marketing & Polish
- [ ] App Store Screenshots
- [ ] Launch Screen Graphic
- [ ] Celebration Effect Frames
- [ ] Social Media Assets

---

## 🎭 Dealer Avatar Prompts

### General Guidelines for All Dealers

**Style Specifications:**
- Flat vector illustration style, similar to modern iOS app icons
- Clean, simple shapes with subtle gradients
- Dark theme compatible (should pop on black background #000000)
- Consistent proportions across all dealers (head and shoulders portrait)
- 1024x1024px at 4K resolution for crisp rendering

**Technical Specs:**
- Aspect ratio: 1:1
- Resolution: 2K
- Background: Transparent
- Output: PNG with alpha channel

---

### 1. Ruby - The Vegas Classic

**Primary Avatar (Normal State)**

```
A professional female blackjack dealer avatar in flat vector illustration style. Head and shoulders portrait. Elegant ruby-red themed character with classic Vegas energy. Sleek black hair, confident expression, wearing a professional dealer's vest in deep red (#FF3B30) with subtle gold accents. Clean, modern, minimal design suitable for iOS app. Transparent background. High contrast on dark theme. Vector art style with smooth gradients, no textures. Professional, sophisticated, by-the-book personality conveyed through posture and expression.

Camera: Straight-on portrait, centered composition
Style: Flat vector illustration, modern iOS design language
Lighting: Soft, even lighting with subtle rim light
Avoid: Photorealism, clutter, excessive detail, busy backgrounds
```

**API Parameters:**
```python
{
    "aspect_ratio": "1:1",
    "resolution": "2K",
    "number_of_images": 3  # Generate variations for selection
}
```

**Variation: Happy State (Win)**

```
The same professional ruby-red themed dealer character from the previous image, now with a warm, genuine smile and slightly raised eyebrows showing happiness. Maintain exact same art style, colour palette (#FF3B30), and composition. Only change: facial expression showing celebration of player's win. Same professional dealer's vest, same sleek black hair, same vector illustration style. Transparent background.

Camera: Identical framing to normal state
Style: Maintain vector illustration consistency
Reference: [Upload Ruby normal state as reference image]
```

**Variation: Sad State (Loss)**

```
The same professional ruby-red themed dealer character, now with a sympathetic, slightly concerned expression. Maintain exact same art style, colour palette, and composition. Only change: facial expression showing empathy for player's loss. Same professional attire. Transparent background.

Camera: Identical framing to normal state
Reference: [Upload Ruby normal state as reference image]
```

**Variation: Thinking State**

```
The same professional ruby-red themed dealer character, now with a thoughtful, contemplative expression. One hand near chin in thinking gesture. Maintain exact same art style, colour palette, and composition. Only change: pose and expression showing strategic consideration. Transparent background.

Camera: Identical framing to normal state
Reference: [Upload Ruby normal state as reference image]
```

---

### 2. Lucky - The Player's Friend

**Primary Avatar (Normal State)**

```
A friendly, generous blackjack dealer avatar in flat vector illustration style. Head and shoulders portrait. Gold and yellow themed (#FFD700) lucky character with warm, welcoming energy. Cheerful expression, casual but professional attire in golden yellow tones with subtle sparkle elements suggesting luck. Clean, modern, minimal design suitable for iOS app. Transparent background. High contrast on dark theme. Vector art style with smooth gradients. Laid-back, approachable, "rooting for you" personality conveyed through open, friendly posture.

Camera: Straight-on portrait, centered composition, slightly relaxed pose
Style: Flat vector illustration, modern iOS design language
Lighting: Warm, inviting lighting with subtle glow effect
Avoid: Photorealism, excessive glitter, busy backgrounds, tacky appearance
```

**API Parameters:**
```python
{
    "aspect_ratio": "1:1",
    "resolution": "2K",
    "number_of_images": 3
}
```

**Variation: Happy State**

```
The same friendly golden-yellow themed dealer character (#FFD700), now with an enthusiastic, celebratory expression and both hands making a subtle victory gesture. Maintain exact same art style, colour palette, and composition. Only change: animated, excited facial expression and gesture showing genuine happiness for player's win. Transparent background.

Reference: [Upload Lucky normal state]
```

**Variation: Sad State**

```
The same golden-yellow themed dealer character, now with a disappointed but supportive expression. Maintain exact same art style and colour palette. Only change: facial expression showing gentle sympathy, still maintaining friendly demeanour. Transparent background.

Reference: [Upload Lucky normal state]
```

**Variation: Thinking State**

```
The same golden-yellow themed dealer character, now with a playful, curious expression and finger pointing upward in an "aha!" gesture. Maintain exact same art style and colour palette. Conveys helpful, encouraging thinking. Transparent background.

Reference: [Upload Lucky normal state]
```

---

### 3. Shark - The High Roller

**Primary Avatar (Normal State)**

```
An aggressive, confident high-roller blackjack dealer avatar in flat vector illustration style. Head and shoulders portrait. Sharp blue-grey themed character (#0A84FF) with intense, competitive energy. Strong jawline, intense gaze, wearing sleek dealer attire in steel blue and grey tones with sharp geometric accents. Clean, modern, minimal design suitable for iOS app. Transparent background. High contrast on dark theme. Vector art style with angular gradients suggesting sharpness. Aggressive, high-stakes personality conveyed through confident, slightly intimidating expression.

Camera: Straight-on portrait, slightly low angle for authority
Style: Flat vector illustration with angular, sharp design elements
Lighting: Dramatic lighting with strong contrast
Avoid: Photorealism, overly aggressive appearance, busy backgrounds
```

**API Parameters:**
```python
{
    "aspect_ratio": "1:1",
    "resolution": "2K",
    "number_of_images": 3
}
```

**Variation: Happy State**

```
The same sharp blue-grey themed dealer character (#0A84FF), now with a competitive, smug smile showing satisfaction. Maintain exact same art style, angular design, and colour palette. Only change: confident, victorious expression. Transparent background.

Reference: [Upload Shark normal state]
```

**Variation: Sad State**

```
The same blue-grey themed dealer character, now with a slight frown and narrowed eyes showing frustration. Maintain exact same art style and colour palette. Only change: expression showing displeasure at player's win, maintaining competitive edge. Transparent background.

Reference: [Upload Shark normal state]
```

**Variation: Thinking State**

```
The same blue-grey themed dealer character, now with fingers steepled together and calculating expression. Maintain exact same art style and colour palette. Conveys strategic, calculating thinking. Sharp, focused gaze. Transparent background.

Reference: [Upload Shark normal state]
```

---

### 4. Zen - The Teacher

**Primary Avatar (Normal State)**

```
A calm, patient teacher blackjack dealer avatar in flat vector illustration style. Head and shoulders portrait. Purple and zen-themed character (#AF52DE) with serene, meditative energy. Peaceful expression, wearing simple elegant attire in purple tones with subtle mandala or lotus motifs. Clean, modern, minimal design suitable for iOS app. Transparent background. High contrast on dark theme. Vector art style with smooth, flowing gradients. Calm, patient, educational personality conveyed through composed, welcoming expression.

Camera: Straight-on portrait, perfectly centered, balanced composition
Style: Flat vector illustration with flowing, organic design elements
Lighting: Soft, diffused, peaceful lighting
Avoid: Photorealism, religious symbols, busy backgrounds, stereotypical imagery
```

**API Parameters:**
```python
{
    "aspect_ratio": "1:1",
    "resolution": "2K",
    "number_of_images": 3
}
```

**Variation: Happy State**

```
The same calm purple-themed teacher character (#AF52DE), now with a gentle, encouraging smile and eyes that crinkle warmly. Maintain exact same art style, flowing design, and colour palette. Only change: warm, nurturing expression showing pride in student's success. Transparent background.

Reference: [Upload Zen normal state]
```

**Variation: Sad State**

```
The same purple-themed teacher character, now with a compassionate, understanding expression and slight head tilt. Maintain exact same art style and colour palette. Only change: expression conveying gentle empathy and encouragement to keep learning. Transparent background.

Reference: [Upload Zen normal state]
```

**Variation: Thinking State**

```
The same purple-themed teacher character, now with eyes closed in meditative thought and hands in a teaching mudra gesture. Maintain exact same art style and colour palette. Conveys patient, thoughtful consideration. Transparent background.

Reference: [Upload Zen normal state]
```

---

### 5. Blitz - The Speed Demon

**Primary Avatar (Normal State)**

```
A fast-paced, energetic blackjack dealer avatar in flat vector illustration style. Head and shoulders portrait. Red-orange lightning themed character (#FF9500) with dynamic, high-energy presence. Excited expression, wearing sporty dealer attire in vibrant orange and red tones with lightning bolt accents. Clean, modern, minimal design suitable for iOS app. Transparent background. High contrast on dark theme. Vector art style with dynamic angular gradients suggesting speed and motion. Fast-paced, energetic, "let's go!" personality conveyed through animated expression and forward-leaning posture.

Camera: Straight-on portrait with slight dynamic tilt
Style: Flat vector illustration with angular, energetic design elements
Lighting: Bright, vibrant lighting with motion blur suggestion
Avoid: Photorealism, actual motion blur, overly chaotic composition
```

**API Parameters:**
```python
{
    "aspect_ratio": "1:1",
    "resolution": "2K",
    "number_of_images": 3
}
```

**Variation: Happy State**

```
The same energetic red-orange themed dealer character (#FF9500), now with an explosive, enthusiastic expression and fist pump gesture. Maintain exact same art style, dynamic design, and colour palette. Only change: maximum excitement expression showing celebration of fast win. Transparent background.

Reference: [Upload Blitz normal state]
```

**Variation: Sad State**

```
The same red-orange themed dealer character, now with an impatient, hurried expression tapping wrist as if checking time. Maintain exact same art style and colour palette. Only change: expression showing urgency to move on to next hand. Transparent background.

Reference: [Upload Blitz normal state]
```

**Variation: Thinking State**

```
The same red-orange themed dealer character, now with quick, rapid-fire thinking expression and finger tapping temple. Maintain exact same art style and colour palette. Conveys fast mental processing. Eyes darting. Transparent background.

Reference: [Upload Blitz normal state]
```

---

### 6. Maverick - The Wild Card

**Primary Avatar (Normal State)**

```
An unpredictable, fun blackjack dealer avatar in flat vector illustration style. Head and shoulders portrait. Multi-coloured chaotic character with rainbow gradient elements and playful energy. Mischievous, experimental expression, wearing eclectic dealer attire featuring unexpected colour combinations (purple, green, orange, blue gradient). Clean, modern, minimal design suitable for iOS app despite playful chaos. Transparent background. High contrast on dark theme. Vector art style with unpredictable gradients and geometric patterns. Unpredictable, fun, "expect the unexpected" personality conveyed through asymmetric design and wild expression.

Camera: Straight-on portrait with slight asymmetric composition
Style: Flat vector illustration with playful, chaotic design elements
Lighting: Multi-coloured lighting with unexpected colour casts
Avoid: Photorealism, overly busy design, illegible composition, clown-like appearance
```

**API Parameters:**
```python
{
    "aspect_ratio": "1:1",
    "resolution": "2K",
    "number_of_images": 4  # Extra variation for unpredictability
}
```

**Variation: Happy State**

```
The same multi-coloured chaotic dealer character, now with a wild, surprised expression of delight and both hands in the air. Maintain exact same art style, rainbow gradient, and composition. Only change: expression showing joyful chaos and celebration. Transparent background.

Reference: [Upload Maverick normal state]
```

**Variation: Sad State**

```
The same multi-coloured dealer character, now with a comically exaggerated sad expression and shrug gesture. Maintain exact same art style and colour palette. Only change: theatrical, playful expression of disappointment. Transparent background.

Reference: [Upload Maverick normal state]
```

**Variation: Thinking State**

```
The same multi-coloured dealer character, now with a wild-eyed, chaotic thinking expression and hands gesturing erratically. Maintain exact same art style and colour palette. Conveys unpredictable, experimental thinking process. Transparent background.

Reference: [Upload Maverick normal state]
```

---

## 🃏 Card Design Prompts

### Design Requirements

- **52 unique card faces** (13 ranks × 4 suits)
- **3 style variations** (Classic, Modern, Minimalist)
- **Card back designs** (at least 3 options)
- **Dimensions:** Portrait 3:4 aspect ratio, 2K resolution
- **Text clarity:** Critical for rank and suit symbols

### Suit Colour Specifications

Per spec:
- **Red suits (♥ Hearts, ♦ Diamonds):** #FF3B30
- **Black suits (♠ Spades, ♣ Clubs):** #000000
- **Card background:** White #FFFFFF
- **Card border:** Subtle grey or black outline

---

### Classic Style Card Faces

**Template Prompt for Face Cards (Example: King of Hearts)**

```
A King of Hearts playing card in classic Vegas casino style. Clean white background (#FFFFFF). Large "K" rank in top-left and bottom-right corners in bold serif font, red colour (#FF3B30). Large red heart suit symbol (♥) next to each rank. Centre features traditional King character illustration in red and white, symmetrical design suitable for either orientation. Classic, timeless playing card aesthetic with sharp, crisp details. High contrast for easy readability. Professional casino quality. Vector-style illustration.

Card dimensions: Standard playing card portrait orientation (3:4 aspect ratio)
Style: Traditional casino playing card design
Text rendering: Crystal clear, legible rank and suit symbols
Colours: Red #FF3B30 on white #FFFFFF background
Avoid: Modern minimalism, artistic interpretation, hard-to-read fonts
```

**API Parameters:**
```python
{
    "aspect_ratio": "3:4",  # Portrait card
    "resolution": "2K",
    "number_of_images": 1
}
```

**Number Cards Prompt (Example: 7 of Diamonds)**

```
A 7 of Diamonds playing card in classic Vegas casino style. Clean white background (#FFFFFF). Large "7" rank in top-left and bottom-right corners in bold serif font, red colour (#FF3B30). Seven red diamond suit symbols (♦) arranged in traditional 7-card pattern on card face. Classic, timeless playing card aesthetic with sharp, crisp details. High contrast for easy readability. Professional casino quality. Vector-style illustration.

Card dimensions: Standard playing card portrait orientation (3:4 aspect ratio)
Style: Traditional casino playing card design
Text rendering: Crystal clear, legible rank and suit symbols
Colours: Red #FF3B30 on white #FFFFFF background
Avoid: Decorative elements, artistic interpretation, hard-to-read symbols
```

**Ace Cards Prompt (Example: Ace of Spades)**

```
An Ace of Spades playing card in classic Vegas casino style. Clean white background (#FFFFFF). Large "A" rank in top-left and bottom-right corners in bold serif font, black colour (#000000). Single large ornate black spade suit symbol (♠) centred on card face, traditional elaborate design for Ace of Spades. Classic, timeless playing card aesthetic with sharp, crisp details. High contrast for easy readability. Professional casino quality. Vector-style illustration.

Card dimensions: Standard playing card portrait orientation (3:4 aspect ratio)
Style: Traditional casino playing card design with elaborate centre spade
Text rendering: Crystal clear, legible rank
Colours: Black #000000 on white #FFFFFF background
Avoid: Overly ornate design, artistic interpretation that reduces clarity
```

---

### Modern Style Card Faces

**Modern Face Card (Example: Queen of Clubs)**

```
A Queen of Clubs playing card in modern minimalist style. Clean white background (#FFFFFF). Large geometric sans-serif "Q" rank in top-left and bottom-right corners, black colour (#000000). Simplified geometric club suit symbol (♣) next to each rank. Centre features stylised, modern geometric interpretation of Queen character in black, using simple shapes and clean lines. Contemporary design aesthetic while maintaining clarity. Vector-style illustration.

Card dimensions: Standard playing card portrait orientation (3:4 aspect ratio)
Style: Modern, geometric, minimalist playing card design
Text rendering: Crystal clear sans-serif typography
Colours: Black #000000 on white #FFFFFF background
Avoid: Traditional ornate designs, hard-to-read experimental fonts
```

**Modern Number Card (Example: 10 of Hearts)**

```
A 10 of Hearts playing card in modern minimalist style. Clean white background (#FFFFFF). Large geometric sans-serif "10" rank in top-left and bottom-right corners, red colour (#FF3B30). Ten simplified geometric heart suit symbols (♥) arranged in clean, balanced pattern. Modern design aesthetic with plenty of white space. Vector-style illustration.

Card dimensions: Standard playing card portrait orientation (3:4 aspect ratio)
Style: Modern, geometric, minimalist playing card design
Text rendering: Crystal clear sans-serif typography
Colours: Red #FF3B30 on white #FFFFFF background
Avoid: Traditional ornate designs, cluttered layouts
```

---

### Minimalist Style Card Faces

**Minimalist Card (Example: Jack of Diamonds)**

```
A Jack of Diamonds playing card in ultra-minimalist style. Clean white background (#FFFFFF). Small sans-serif "J" rank only in top-left corner, red colour (#FF3B30). Single small diamond suit symbol (♦) next to rank. Centre features single large red diamond with subtle "J" integrated. Maximum simplicity, maximum clarity. Scandinavian design aesthetic. Vector-style illustration.

Card dimensions: Standard playing card portrait orientation (3:4 aspect ratio)
Style: Ultra-minimalist, Scandinavian-inspired playing card design
Text rendering: Small but crystal clear typography
Colours: Red #FF3B30 on white #FFFFFF background
Avoid: Decorative elements, traditional card layouts, complexity
```

---

### Card Back Designs

**Classic Card Back #1**

```
A playing card back design in classic casino style. Symmetrical geometric pattern in deep red (#FF3B30) and white on black background (#000000). Traditional ornate border with intricate centre pattern featuring geometric shapes. Pattern must be perfectly symmetrical both vertically and horizontally for either card orientation. Professional casino quality. Suitable for dark-themed iOS blackjack app.

Card dimensions: Portrait 3:4 aspect ratio
Style: Traditional casino card back, symmetrical geometric pattern
Colours: Red #FF3B30, white, black #000000
Avoid: Asymmetrical designs, branded elements, text
```

**Modern Card Back #2**

```
A playing card back design in modern geometric style. Clean abstract pattern using gold gradient (#FFD700 to #FFA500) geometric shapes on black background (#000000). Minimalist, contemporary design with symmetrical pattern suitable for either orientation. Subtle texture suggesting luxury. Suitable for dark-themed iOS app.

Card dimensions: Portrait 3:4 aspect ratio
Style: Modern, geometric, minimalist
Colours: Gold gradient on black background
Avoid: Traditional ornate patterns, busy designs
```

**Minimalist Card Back #3**

```
A playing card back design in minimalist style. Simple large geometric shape (single spade symbol outline) in white on pure black background (#000000). Maximum simplicity. Clean, elegant, Scandinavian design aesthetic. Pattern works in either orientation.

Card dimensions: Portrait 3:4 aspect ratio
Style: Ultra-minimalist, single element
Colours: White on black #000000
Avoid: Complexity, multiple elements, traditional patterns
```

---

## 🎨 App Icon & Branding

### iOS App Icon (Required Sizes)

**Primary App Icon**

```
An iOS app icon for a modern blackjack app called "Natural". Design features a stylised playing card (Ace of Spades) overlapping with a poker chip. Clean, minimal composition on dark gradient background (black #000000 to dark grey #1C1C1E). Gold accents (#FFD700) for premium feel. Modern, sophisticated design suitable for iOS 16+. No text on icon. Recognisable at small sizes. Vector-style illustration with subtle depth.

Icon size: 1024x1024px square
Aspect ratio: 1:1
Style: Modern iOS app icon, flat design with subtle gradient
Colours: Black/dark grey background, white card, gold accents
Avoid: Text, complex details, photorealism, excessive elements
```

**API Parameters:**
```python
{
    "aspect_ratio": "1:1",
    "resolution": "4K",  # Maximum quality for app icon
    "number_of_images": 4  # Generate multiple options
}
```

**Alternative Icon Concept #2**

```
An iOS app icon for a blackjack app. Design features abstract geometric representation of "21" in bold modern typography. Numbers integrate suit symbols (♠♥♦♣) subtly into the letterforms. Dark background (#000000) with vibrant accent colours. Clean, recognisable at small sizes. Vector-style illustration.

Icon size: 1024x1024px square
Style: Modern iOS app icon, typographic focus
Colours: Black background, vibrant multi-colour accents
Avoid: Text besides "21", complex illustrations, photorealism
```

---

## 🎯 UI Elements & Icons

### Chip/Currency Icon

```
A poker chip icon for iOS blackjack app UI. Top-down view of a single casino chip. Gold colour (#FFD700 to #FFA500 gradient) with white edge spots. Clean, simple design suitable for small icon size. Shows denomination marker in centre. Vector-style illustration with subtle 3D depth. Transparent background.

Icon size: 256x256px
Aspect ratio: 1:1
Style: Flat icon with subtle depth, iOS design language
Colours: Gold gradient with white accents
Avoid: Photorealism, excessive detail, multiple chips
```

**API Parameters:**
```python
{
    "aspect_ratio": "1:1",
    "resolution": "2K",
    "number_of_images": 2
}
```

### Trophy/Achievement Icons

**Win Streak Trophy**

```
A trophy icon for achievement system in iOS blackjack app. Modern, geometric trophy design in gold (#FFD700) with small flame symbol on top indicating "streak". Clean, minimal design suitable for small icon size. Transparent background. Vector-style illustration.

Icon size: 256x256px
Aspect ratio: 1:1
Style: Flat iOS icon, modern geometric
Colours: Gold with subtle gradient
Avoid: Photorealism, traditional trophy designs, complex detail
```

**Blackjack Achievement Icon**

```
An achievement badge icon showing "21" in bold typography with subtle playing card suit symbols orbiting around it. Gold and black colour scheme (#FFD700 on black). Clean, minimal design for iOS app. Circular badge format. Transparent background. Vector-style illustration.

Icon size: 256x256px
Aspect ratio: 1:1
Style: Flat iOS badge icon
Colours: Gold and black
Avoid: Photorealism, excessive detail
```

**Perfect Strategy Icon**

```
A brain or lightbulb icon in purple (#AF52DE) representing strategic thinking for achievement system. Modern, geometric, minimalist design. Suitable for small icon size. Transparent background. Vector-style illustration.

Icon size: 256x256px
Aspect ratio: 1:1
Style: Flat iOS icon
Colours: Purple with subtle gradient
Avoid: Photorealism, complex anatomy
```

---

## 📚 Tutorial & Educational Graphics

### Basic Strategy Chart Visualisation

```
An infographic showing basic blackjack strategy chart in modern, clean design. Grid layout with player hand totals on Y-axis (5-21) and dealer upcard on X-axis (2-A). Cells colour-coded: green for "Hit", red for "Stand", yellow for "Double", blue for "Split". Clean sans-serif typography. Dark theme compatible (#000000 background). High legibility. Professional educational design.

Dimensions: 16:9 landscape for horizontal viewing
Style: Modern infographic, educational design
Colours: Colour-coded cells on dark background
Text: Must be crystal clear and legible at all sizes
Avoid: Cluttered layout, hard-to-read fonts, poor contrast
```

**API Parameters:**
```python
{
    "aspect_ratio": "16:9",
    "resolution": "2K",
    "number_of_images": 2
}
```

### Tutorial Screen: "What is Blackjack?"

```
An educational tutorial graphic for iOS blackjack app showing a simple example hand. Illustration shows two cards (10 and Ace) with large "= 21!" text and "BLACKJACK" label. Clean, modern design on dark background (#000000). Minimal, friendly, educational aesthetic. Easy to understand for beginners. Vector-style illustration with playing cards.

Dimensions: 9:16 portrait for mobile
Style: Modern educational illustration
Colours: Cards on dark background, gold highlight for "21"
Text: Large, clear, friendly typography
Avoid: Complex rules, walls of text, intimidating design
```

---

## 📱 Marketing Assets

### App Store Screenshot Templates

**Screenshot 1: Gameplay**

```
An iPhone screenshot showing a blackjack game in progress. Modern dark interface (#000000 background). Dealer cards at top showing 17. Player cards at bottom showing 19. Large, clear card graphics. Action buttons (Hit, Stand, Double) at bottom in dark grey (#2C2C2E). Chip count displayed as "$10,250" in gold (#FFD700) at top left. Clean, uncluttered, premium design. High contrast for clarity. Portrait orientation.

Dimensions: 9:16 portrait (iPhone aspect ratio)
Style: Realistic app interface mockup
Resolution: 4K for App Store requirements
Colours: Dark theme as per spec
Avoid: Cluttered UI, poor readability, unprofessional appearance
```

**Screenshot 2: Dealer Selection**

```
An iPhone screenshot showing dealer selection screen. Six dealer avatars displayed in grid layout (2 columns, 3 rows). Each dealer shows name and tagline below avatar. Ruby (red), Lucky (gold), Shark (blue), Zen (purple), Blitz (orange), Maverick (rainbow). Dark background (#000000). Clean, modern card-based UI design. Portrait orientation.

Dimensions: 9:16 portrait
Style: Realistic app interface mockup
Resolution: 4K
Colours: Dark theme with dealer-specific accent colours
Avoid: Cluttered layout, illegible text
```

---

## 🔄 Batch Processing Strategy

### Recommended Batch Groups for Cost Efficiency

Use Nano Banana Pro batch API to save 50% on generation costs.

**Batch 1: Dealer Normal States (Priority 1)**
- 6 prompts for all dealer primary avatars
- Process together to maintain style consistency
- Review, select best, then use as reference images for variations

**Batch 2: Dealer Variations (Priority 2)**
- 18 prompts for all dealer states (happy, sad, thinking)
- Use selected normal states as reference images
- Process overnight

**Batch 3: Classic Card Faces (Priority 1)**
- 52 prompts for all card faces in classic style
- Largest batch, process overnight
- Critical for text rendering quality

**Batch 4: Card Backs & Modern Cards (Priority 2)**
- 3 card back designs
- 52 modern style card faces (if time allows)

**Batch 5: App Icon & UI Icons (Priority 1)**
- App icon variations (4 concepts)
- Essential UI icons (chip, trophy, etc.)

**Batch 6: Marketing Assets (Priority 3)**
- App Store screenshots
- Tutorial graphics
- Launch screen

---

## 📝 Generation Workflow Checklist

### Phase 1: Core Assets (Week 1)
- [ ] Generate all 6 dealer normal state avatars
- [ ] Review and select best variations
- [ ] Generate 52 classic card faces
- [ ] Generate 3 card back designs
- [ ] Generate app icon (4 variations to choose from)
- [ ] Generate essential UI icons

### Phase 2: Enhancements (Week 2)
- [ ] Generate dealer variations (happy, sad, thinking) using selected normals as reference
- [ ] Generate modern style card faces (if desired)
- [ ] Generate minimalist card faces (if desired)
- [ ] Generate achievement/trophy icons
- [ ] Generate tutorial graphics

### Phase 3: Marketing (Week 3)
- [ ] Generate App Store screenshot templates
- [ ] Generate launch screen graphic
- [ ] Generate social media assets
- [ ] Generate any remaining polish assets

---

## 💡 Pro Tips for Best Results

### 1. Reference Image Strategy
After generating dealer normal states, ALWAYS use them as reference images for variations. This ensures perfect character consistency across all emotional states.

### 2. Text Rendering Validation
For card faces, generate 2-3 variations and check text legibility at actual app size. Nano Banana Pro excels at text, but validation is critical.

### 3. Batch Similar Assets
Process all dealer normal states together, then all variations together. Maintains style consistency and saves costs.

### 4. Resolution Guidelines
- **App Icon:** 4K (needs maximum quality)
- **Dealer Avatars:** 2K (sufficient for @3x iOS)
- **Cards:** 2K (balance between quality and file size)
- **UI Icons:** 2K (scalable for various uses)

### 5. Iteration Strategy
Generate 2-4 variations for critical assets (app icon, dealer avatars). Select best, then use as reference for consistency.

---

## 🎯 Expected Output Quality

With Nano Banana Pro's capabilities:

✅ **Text on cards:** Crystal clear, perfectly legible
✅ **Dealer consistency:** Use reference images for exact character matching
✅ **High resolution:** 4K for app icon, 2K for most assets
✅ **Style consistency:** Batch processing maintains coherent aesthetic
✅ **iOS optimised:** Vector-style outputs scale perfectly for Retina displays

---

## 📊 Cost Estimation

**Assuming batch API pricing (50% savings):**

- Dealer avatars (24 total): ~$X.XX
- Card faces (52 classic + optional styles): ~$X.XX
- UI icons and app icon: ~$X.XX
- Marketing assets: ~$X.XX

**Total estimated cost:** Contact Google AI for current pricing

**Recommended budget:** Generate core assets first (Priority 1), evaluate quality, then proceed with enhancements.

---

## 🚀 Getting Started

1. **Set up Gemini API access** with Nano Banana Pro
2. **Start with test prompt:** Generate Ruby dealer to validate quality
3. **Refine prompts** based on initial results
4. **Process Priority 1 batches:** Dealers, cards, app icon
5. **Review and iterate** before proceeding to Priority 2
6. **Use reference images** for all variation work

---

**Document Version:** 1.0
**Model:** Gemini 3 Pro Image (gemini-3-pro-image-preview)
**Last Updated:** November 2025
**Status:** Ready for asset generation via API

