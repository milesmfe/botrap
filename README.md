# Botrap

A modern, animated card game built with LÖVE2D where players set strategic rules to trap their opponents. Features vibrant animations, spring physics, and intuitive gameplay mechanics.

## Game Overview

Botrap is a tactical card game where you compete against an AI opponent using standard playing cards. The goal is to create rules that make your opponent's hand invalid while keeping your own hand valid. Each round, you can add new rules that persist throughout the game, creating increasingly complex strategic situations.

### Core Mechanics
- 5-card hands dealt each round from a standard 52-card deck
- Rule accumulation - rules persist and stack throughout the game
- Instant win detection - automatic victory when opponent violates rules
- Strategic depth - balance offense and defense with rule selection

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
1. New Hand - Cards are automatically dealt to both players
2. Card Selection - Choose cards to base your rule on (optional)
3. Rule Selection - Pick a rule type and apply it, or skip to next hand
4. Win Check - Automatic detection if opponent violates rules
5. Repeat - Continue until someone wins or deck runs out

### Rule Types

| Rule | Effect | Cards Required | Description |
|------|--------|----------------|-------------|
| Suit | Disallow suit | Same suit cards | Hands with selected suit become invalid |
| Rank | Disallow rank | Same rank cards | Hands with selected rank become invalid |
| Mix | Disallow suit mixing | 2 different suits | Hands with both suits become invalid |
| Gold | Protect rank | 1 card | Selected rank overrides all other rules (lasts 1 hand) |

### Victory Conditions
- Instant Win: Opponent's hand violates rules while yours doesn't
- Deck Exhaustion: Game ends when no more cards can be dealt

## Features

### Modern UI/UX
- Bouncy Animations: Spring-based physics for natural movement
- Visual Feedback: Card dimming for violations, gold borders for protection
- Responsive Design: Center-scaling hover effects and smooth transitions
- Rule Tooltips: Hover over rule icons to see detailed descriptions

### Smart Gameplay
- Auto Win Detection: Instant recognition when rules trap opponent
- Skip Option: Available throughout gameplay for strategic flexibility
- Gold Rule Expiration: Automatic removal with pop-out animation
- Visual Rule Queue: Animated icons showing all active rules

### Quality of Life
- No Manual Setup: Cards and assets included, no external generation needed
- Immediate Feedback: Floating text notifications for all actions
- Clean Interface: Minimal, focused design without visual clutter
- Smooth Transitions: Delayed overlays with locked controls during state changes

## Project Structure

```
botrap/
├── main.lua           # Entry point and game loop
├── game_state.lua     # Scene management and game logic
├── cards.lua          # Card system with animations
├── deck.lua           # Deck management and dealing
├── rules.lua          # Rule validation and application
├── ui.lua             # UI rendering and interactions
├── assets/cards/      # Card images (256x384 PNG files)
└── scripts/           # Asset generation utilities
```

## Design Philosophy

### Animation System
- Spring Physics: Natural, bouncy movements using velocity and damping
- Smooth Scaling: Center-origin transformations that maintain alignment
- Particle Effects: Colorful bursts for important interactions
- Floating Feedback: Text animations for user guidance

### Color Palette
- Background: Deep blue gradient with subtle animated elements
- Primary: Bright cyan for main actions and navigation
- Success: Vibrant green for positive feedback
- Warning: Orange for caution states and skip actions
- Danger: Red for negative outcomes and exits
- Special: Gold for protected elements, purple for mix rules

### User Experience
- Zero Configuration: Ready to play immediately after installation
- Clear Hierarchy: Multiple font sizes for information organization
- Consistent Feedback: Visual and textual confirmation for all actions
- Accessible Design: High contrast, clear typography, logical flow

## Development

Built with modern Lua practices and modular architecture:
- Functional Modules: Clean separation of concerns
- Idiomatic Lua: No unnecessary OOP complexity
- Performance Optimized: Efficient rendering and update loops
- Maintainable Code: Clear structure and comprehensive documentation

## License

This project is available as open source. See the repository for licensing details.

## Contributing

Contributions welcome! The codebase is designed to be approachable and well-documented. Feel free to submit issues or pull requests for improvements, bug fixes, or new features.
