# Botrap

A modern, animated card game built with LÖVE2D featuring strategic rule-based gameplay with runs, rounds, unique opponents, and upgrades. Battle through 5 challenging opponents with distinct abilities while collecting powerful upgrades to enhance your deck and strategy.

## Game Overview

Botrap is a tactical card game where you progress through structured runs, facing increasingly difficult opponents with unique abilities. The goal is to create rules that make your opponent's hand invalid while keeping your own hand valid. Between rounds, collect upgrades to modify your deck and abilities, creating a dynamic roguelike experience.

### New Gameplay Structure

#### Runs, Rounds, and Hands
- **Run**: A complete game cycle consisting of 5 rounds
- **Round**: Face one opponent, play multiple hands until victory or defeat  
- **Hand**: Single card dealing phase where rules are applied and win conditions are checked

#### Victory Conditions
- **Round Victory**: Defeat opponent by making them violate rules or achieving BOTRAP
- **Run Victory**: Complete all 5 rounds successfully to win the entire run
- **Run Defeat**: Lose to any opponent or run out of cards

### Core Mechanics
- 5-card hands dealt each round from a standard 52-card deck
- Rule accumulation - rules persist and stack throughout hands
- Instant win detection - automatic victory when opponent violates rules
- Strategic depth - balance offense and defense with rule selection
- Deck modification through upgrades between rounds

## Opponents

Face 5 unique opponents with escalating difficulty and special abilities:

### 1. Novice Dealer (Round 1)
- **Ability**: None
- **Description**: A beginner opponent with no special abilities - perfect for learning the game

### 2. Card Hoarder (Round 2)  
- **Ability**: Extra Cards
- **Description**: Starts each hand with 6 cards instead of 5, giving them more options

### 3. Rule Bender (Round 3)
- **Ability**: Rule Immunity
- **Description**: Can ignore one rule violation per hand, making them harder to trap

### 4. Gold Guardian (Round 4)
- **Ability**: Auto-Gold Protection
- **Description**: Automatically gets gold protection on random cards at the start of each hand

### 5. Deck Master (Round 5)
- **Ability**: Perfect Draws
- **Description**: Can see your hand and gets optimal card distributions

## Upgrade System

Between each round, choose from 3 random upgrades with rarity-based selection:

### Common Upgrades (60% chance)
- **Extra Aces**: Add 2 additional Aces to your deck
- **Remove Twos**: Remove all 2s from your deck for cleaner draws

### Rare Upgrades (30% chance, increases in later rounds)
- **Golden Start**: Start each hand with gold protection on a random card
- **Opponent Handicap**: Opponent starts with 4 cards instead of 5

### Epic Upgrades (10% chance, increases significantly in later rounds)
- **Face Card Ban**: Remove all face cards from opponent's deck

### Upgrade Strategy
- Rarity chances improve in later rounds (rounds 3-5 have better upgrade pools)
- Plan your upgrades carefully - effects persist throughout the entire run
- Deck modifications can't be undone, so choose wisely

## Statistics & Progression

All gameplay statistics are automatically saved and tracked:

### Overall Statistics
- Runs completed vs attempted
- Total rounds won across all runs
- Total hands played
- Best run length achieved

### Detailed Tracking  
- Opponents defeated (with individual counts)
- Upgrades used (with usage frequency)
- Last run details including opponents faced and upgrades chosen

### Local Save System
- Statistics saved automatically in `saves/` folder
- View comprehensive stats from the main menu
- Track your improvement over time

## Quick Start

### Prerequisites
- LÖVE2D version 11.0 or higher

### Installation
1. Install LÖVE2D for your platform:
   ```bash
   # macOS with Homebrew
   brew install love
   
   # Ubuntu/Debian
   sudo apt install love
   
   # Windows: Download from love2d.org
   ```

2. Clone and run the game:
   ```bash
   git clone https://github.com/milesmfe/botrap.git
   cd botrap
   love .
   ```

## How to Play

### Game Flow
1. **Start New Run** - Begin facing the first opponent (Novice Dealer)
2. **Play Hands** - Cards are dealt, apply rules or skip to trap your opponent
3. **Win Round** - Defeat the opponent to advance
4. **Choose Upgrade** - Select from 3 random upgrades to enhance your strategy
5. **Face Next Opponent** - Progress to the next round with a more challenging opponent
6. **Complete Run** - Defeat all 5 opponents to achieve victory

### Hand Mechanics
1. **New Hand** - Cards are automatically dealt to both players
2. **Card Selection** - Choose cards to base your rule on (optional)
3. **Rule Selection** - Pick a rule type and apply it, or skip to next hand
4. **Win Check** - Automatic detection if opponent violates rules
5. **Continue** - If no win condition, deal new cards and repeat

### Rule Types

| Rule | Effect | Cards Required | Description |
|------|--------|----------------|-------------|
| Suit | Disallow suit | Same suit cards | Hands with selected suit become invalid |
| Rank | Disallow rank | Same rank cards | Hands with selected rank become invalid |
| Mix | Disallow suit mixing | 2 different suits | Hands with both suits become invalid |
| Gold | Protect rank | 1 card | Selected rank overrides all other rules (lasts 1 hand) |

### Strategic Tips
- Save powerful upgrades for later rounds when opponents get harder
- Gold protection becomes increasingly important against later opponents  
- Opponent abilities stack with their natural difficulty
- Plan deck modifications carefully - removed cards can't be recovered during a run
- Different opponents require different strategies - adapt your playstyle

## Features

### Modern UI/UX
- **Multi-Scene Interface**: Menu, gameplay, upgrade selection, statistics, and victory screens
- **Bouncy Animations**: Spring-based physics for natural movement
- **Visual Feedback**: Card dimming for violations, gold tinting for protection
- **Responsive Design**: Center-scaling hover effects and smooth transitions
- **Rule Tooltips**: Hover over rule icons to see detailed descriptions

### Smart Gameplay
- **Auto Win Detection**: Instant recognition when rules trap opponent
- **Opponent AI**: Unique abilities that activate automatically during gameplay
- **Skip Option**: Available throughout gameplay for strategic flexibility  
- **Gold Rule Expiration**: Automatic removal with pop-out animation
- **Visual Rule Queue**: Animated icons showing all active rules

### Progression System
- **Upgrade Selection**: Beautiful rarity-based upgrade selection interface
- **Statistics Tracking**: Comprehensive progress tracking with local saves
- **Run Completion**: Special victory screen showing your journey and achievements
- **Persistent Progress**: All stats saved automatically between sessions

### Quality of Life
- **No Manual Setup**: Cards and assets included, no external generation needed
- **Immediate Feedback**: Floating text notifications for all actions
- **Clean Interface**: Minimal, focused design without visual clutter
- **Smooth Transitions**: Delayed overlays with appropriate state management

## Project Structure

```
botrap/
├── main.lua           # Entry point and game loop
├── game_state.lua     # Scene management and run/round/hand logic
├── cards.lua          # Card system with animations and gold tinting
├── deck.lua           # Deck management, dealing, and upgrade modifications
├── rules.lua          # Rule validation, application, and opponent abilities
├── ui.lua             # UI rendering for all scenes and interactions
├── opponents.lua      # Opponent definitions and unique abilities
├── upgrades.lua       # Upgrade system with rarity-based selection
├── stats.lua          # Statistics tracking and local save system
├── assets/cards/      # Card images (256x384 PNG files)
└── scripts/           # Asset generation utilities
```

## Design Philosophy

### Roguelike Elements
- **Run-Based Structure**: Each playthrough is a complete run with beginning, middle, and end
- **Progressive Difficulty**: Opponents get harder with unique abilities
- **Upgrade Choices**: Meaningful decisions that affect entire run
- **Replayability**: Different upgrade combinations create varied experiences

### Animation System
- **Spring Physics**: Natural, bouncy movements using velocity and damping
- **Smooth Scaling**: Center-origin transformations that maintain alignment
- **Particle Effects**: Colorful bursts for important interactions
- **Floating Feedback**: Text animations for user guidance

### Color Palette
- **Background**: Deep blue gradient with subtle animated elements
- **Primary**: Bright cyan for main actions and navigation
- **Success**: Vibrant green for positive feedback and victories
- **Warning**: Orange for caution states and skip actions
- **Danger**: Red for negative outcomes and defeats
- **Special**: Gold for protected elements, purple for mix rules
- **Rarity Colors**: Common (white), Rare (cyan), Epic (magenta)

### User Experience
- **Zero Configuration**: Ready to play immediately after installation
- **Clear Progression**: Obvious run/round/hand structure with visual indicators
- **Meaningful Choices**: Every upgrade and rule decision matters
- **Comprehensive Feedback**: Visual and textual confirmation for all actions
- **Accessible Design**: High contrast, clear typography, logical flow

## Development

Built with modern Lua practices and modular architecture:
- **Functional Modules**: Clean separation of concerns across game systems
- **Idiomatic Lua**: No unnecessary OOP complexity, clean and readable
- **Performance Optimized**: Efficient rendering and update loops
- **Maintainable Code**: Clear structure and comprehensive documentation
- **Extensible Design**: Easy to add new opponents, upgrades, and features

## License

This project is available as open source. See the repository for licensing details.

## Contributing

Contributions welcome! The codebase is designed to be approachable and well-documented. Areas for potential contribution:
- New opponent types with unique abilities
- Additional upgrade effects and rarities
- UI/UX improvements and animations
- Balance tweaks and gameplay refinements
- Bug fixes and performance optimizations

Feel free to submit issues or pull requests for improvements!
