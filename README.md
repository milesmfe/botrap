# Botrap

A card game implemented in Lua using the LÖVE 2D framework. Players attempt to achieve "botrap" by having the opponent's hand violate accumulating game rules added each hand.

## Requirements

- LÖVE 2D framework (version 11.0 or higher)
- ImageMagick (for generating card assets)

## Installation

Install LÖVE 2D from https://love2d.org/ or using a package manager:

```bash
# macOS with Homebrew
brew install love

# Ubuntu/Debian
sudo apt install love

# Windows
# Download installer from love2d.org
```

Install ImageMagick for asset generation:

```bash
# macOS
brew install imagemagick

# Ubuntu/Debian  
sudo apt install imagemagick

# Windows
# Download from imagemagick.org
```

## Setup

Clone the repository and generate card assets:

```bash
cd botrap
./scripts/generate_cards.sh
```

Run the game:

```bash
love .
```

## Game Rules

Botrap is played with standard 52-card decks against a computer opponent. You draw a 5-card hand each round and add rules that restrict valid hands. The goal is to create rules that make your opponent's hand invalid while keeping your own hand valid.

### Basic Gameplay

You add rules to the game before completing each hand. Rules persist across all subsequent hands until the game ends. After adding rules, you complete the hand to check for botrap.

### Available Rules

**Disallow Suit**: Hands containing the specified suit become invalid.

**Disallow Rank**: Hands containing the specified rank become invalid.

**Disallow Suit Mix**: Hands containing any combination of the specified suits become invalid.

**Disallow Rank Mix**: Hands containing any combination of the specified ranks become invalid.

**Make Rank Gold**: If a hand contains the specified rank, the hand becomes valid regardless of other rules. This rule can only be used once per game.

### End Conditions

**Botrap**: Achieved when your opponent's hand violates the accumulated rules while your hand is valid.

**Game Over**: If all cards are dealt without achieving botrap, the game ends.

### Visual Feedback

Cards display visual overlays indicating their status:

- Black overlay: Card violates rules
- Gold overlay: Card is protected by gold rank
- Half black overlay: Card violates mix rules
- Highlight border: Selected card

Rule icons appear in the bottom-left corner showing all active rules with animated additions and removals.

## UI Design Guidelines

The game features a modern, animated interface designed for clarity and engagement:

### Animation System

**Spring Physics**: All animations use spring-based physics for natural, bouncy movements that feel responsive and satisfying.

**Smooth Transitions**: State changes between menu, gameplay, and game over screens use smooth fade and scale transitions.

**Particle Effects**: Visual feedback through colorful particle bursts on important interactions like button presses and rule applications.

### Color Palette

**Background**: Deep blue gradient (0.08, 0.12, 0.18) with subtle animated elements

**Primary Actions**: Bright cyan (0.2, 0.8, 1.0) for main navigation and rank rules

**Success States**: Vibrant green (0.3, 1.0, 0.5) for positive actions and confirmations  

**Warnings**: Warm orange (1.0, 0.7, 0.2) for caution states

**Destructive Actions**: Red (1.0, 0.3, 0.4) for dangerous actions like exit

**Special Elements**: Purple (0.8, 0.3, 1.0) for mix rules and gold (1.0, 0.8, 0.3) for special rules

### Interactive Elements

**Button States**: Hover effects with 1.1x scale, selection feedback with bounce animations, and visual depth through shadows and highlights.

**Card Animations**: Hover lift effect with glow, selection highlight with spring bounce, smooth positioning with physics-based movement.

**Visual Feedback**: Floating text for notifications, glow effects for important elements, shake animations for errors or conflicts.

### Typography

**Hierarchy**: Multiple font sizes (16px, 24px, 32px, 48px) for clear information hierarchy without relying on special characters or emojis.

**Readability**: High contrast white text on dark backgrounds with subtle transparency effects for secondary information.

### Layout Principles

**Centered Design**: Important UI elements center-aligned for balanced composition and clear focus.

**Breathing Room**: Adequate spacing between interactive elements to prevent accidental activation and improve visual clarity.

**Responsive Scaling**: All elements scale proportionally with screen size while maintaining readability and usability.
