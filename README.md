# BOTRAP

A strategic single-player card game built with Lua and Love2D where you battle increasingly difficult opponents using trap mechanics and deck manipulation.

## Game Overview

Botrap is a tactical card game where you face off against opponents using a unique trap-based mechanic system. Each player maintains their own 52-card deck, with the human player's cards dealt face-up and the opponent's cards dealt face-down. The core gameplay revolves around strategically applying trap rules to cards while navigating through progressively challenging rounds.

Opponents operate on logical rule-based systems rather than artificial intelligence, with cards drawn randomly for both players. This creates fair, predictable gameplay where success depends on strategic planning and understanding game mechanics rather than competing against adaptive AI behavior.

The game is structured in a hierarchical format: runs contain rounds, rounds contain hands. Each run consists of 13 rounds with 4 different difficulty levels, culminating in a boss battle against "Bo Trap". Victory requires completing all rounds, while defeat ends the current run immediately.

Each round contains multiple hands of 5 cards each, one hand for the player and one hand for the opponent, drawn from their respective decks. Some opponents possess the ability to increase the player's hand size by their level number, adding an extra strategic challenge to those encounters.

### Core Mechanics

The trap system forms the foundation of Botrap's strategic depth. Players can apply four different trap rules to selected cards:

- Trap Suit: Makes all cards of a specific suit become trapped
- Trap Rank: Makes all cards of a specific rank become trapped  
- Trap Suit Match: Creates a trap based on the combination of two card suits
- Trap Rank Match: Creates a trap based on the combination of two card ranks

Trap rules accumulate throughout a round, meaning decisions made in early hands affect all subsequent hands in that round. This creates a complex strategic layer where players must balance immediate tactical needs with long-term round planning. After each trap rule is applied, all cards are returned to their respective decks, the decks are reshuffled, and new hands are dealt with the accumulated trap rules taking effect.

The Gold rule provides a unique strategic option, allowing players to designate one specific card per round as Gold. This not only protects that card but also resets all currently trapped cards back to normal, offering a powerful but limited defensive mechanism. Like other rules, applying Gold triggers a complete reshuffle and redeal of hands.

## How to Play

### Basic Gameplay Flow

Each hand begins with 5 cards dealt to both you and your opponent. Your cards are visible while your opponent's remain face-down, creating an information asymmetry that favors careful planning over reactive play. Note that certain opponents can increase your hand size by their level number (e.g., level 2 opponents may give you 7 cards instead of 5).

Opponent cards show visual hints about their type through subtle highlighting on their backs - trapped cards have a red tint, gold cards have a yellow tint, and wild cards have a gray tint, while normal cards have no highlighting.

Select any combination of cards from either hand and apply one of the available trap rules. The rule affects all matching cards currently in play and will continue to affect matching cards in future hands within the same round.

The objective is simple: end a hand where you hold no trapped cards while your opponent holds at least one trapped card. When this condition is met, you can call "Botrap!" and win the round.

### Strategic Considerations

Successful play requires balancing offensive and defensive strategies. Aggressive players might focus on trapping opponent cards early, but this approach risks creating traps that affect their own future hands. Conservative players might wait to apply traps until they can ensure their own safety, but this gives opponents more opportunities to establish favorable board states.

The accumulating nature of trap rules means early decisions have cascading effects. Applying a Trap Suit rule on clubs in hand one will affect every subsequent hand where clubs appear, as cards are returned to the deck, reshuffled, and redealt after each rule application. This creates a risk-reward dynamic where powerful early moves can backfire later in the round.

Gold cards represent the most crucial strategic decision point. Using Gold too early wastes its trap-clearing potential, but waiting too long might mean facing an impossible trap situation. Experienced players often hold Gold until they can simultaneously clear their own traps while leaving opponents vulnerable.

Card counting becomes increasingly important as rounds progress. Knowing which cards remain in both decks helps predict future hands and plan trap applications accordingly. This is especially critical when facing higher-level opponents who have upgrade advantages.

### Poor Strategies to Avoid

Random trap application without considering future implications leads to self-entrapment. Players who apply trap rules without calculating their deck composition often find themselves unable to draw safe hands later in the round.

Hoarding Gold throughout an entire round is equally problematic. While Gold provides security, failing to use it when facing insurmountable trap combinations results in inevitable defeat.

Ignoring opponent upgrade effects creates unnecessary disadvantages. Higher-level opponents begin rounds with significant advantages, and players who don't account for these modifiers when planning their trap strategies will struggle to compete effectively.

Note that opponents follow deterministic rule-based logic rather than adaptive AI behavior, making their actions predictable once you understand their upgrade configurations and the random card distribution system.

## Code Architecture and Organization

The codebase follows a modular scene-based architecture with clear separation of concerns and centralized state management.

### File Structure and Responsibilities

```
botrap/
├── main.lua
├── scenes/
│   ├── menu.lua
│   ├── round.lua
│   ├── locker.lua
│   └── end.lua
├── card.lua
├── upgrades.lua
├── opponents.lua
└── assets/
    └── cards/
        ├── [card_face_images].png
        ├── back_blue.png
        └── back_red.png
```

The main.lua file serves as the central controller and state manager for the entire game. It handles the primary game loop, manages all persistent data including current decks, opponent information, and hand states, and coordinates communication between different scenes. Main.lua also contains the core logic for card manipulation, trap rule application, and deck modification operations.

The scenes directory contains four specialized modules that handle specific game phases. The menu.lua file manages the initial game interface, displaying the animated title, and providing navigation options for starting new runs, viewing statistics, or exiting the game. The round.lua module handles the core gameplay loop, managing hand dealing, card selection, trap rule application, and win condition checking. The locker.lua scene manages the upgrade selection process between rounds, presenting upgrade choices and applying selected modifications to the game state. The end.lua scene displays run completion results and statistics.

Supporting modules provide specialized functionality. The card.lua module defines card behavior, rendering, and animation systems for all card types including normal, trapped, gold, and wild cards. The upgrades.lua file contains the complete upgrade system with all possible modifications including Prison Guard, King's Orders, and Rogue upgrades across all rarity levels. The opponents.lua module defines all opponent types, their difficulty levels, starting upgrades, and behavioral characteristics.

### Main Game Loop and Flow Control

The game operates on a state-driven loop where main.lua maintains the current scene state and delegates control to the appropriate scene module. Scene transitions occur through main.lua callbacks, ensuring consistent state management and proper data persistence across scene changes.

When starting a new run, main.lua initializes fresh decks for both players, resets all trap rules and game modifiers, and loads the first opponent. The game then transitions to the round scene where the primary gameplay occurs.

During round play, the round.lua module handles immediate user interactions while delegating card state modifications to main.lua. This ensures that all card changes are centrally managed and properly synchronized across the game state.

Victory conditions are evaluated after each hand, with main.lua determining whether round completion criteria are met. Upon round victory, the game transitions to the locker scene for upgrade selection before advancing to the next round with a new opponent.

### Data Flow and State Management

All persistent game data flows through main.lua, creating a single source of truth for game state. This includes current deck compositions, active trap rules, opponent configurations, and accumulated upgrades.

Card modifications occur through main.lua functions that update both the logical game state and trigger visual updates in the current scene. This separation ensures that card behavior remains consistent regardless of which scene is active.

Upgrade applications modify deck compositions and game modifiers through main.lua, with changes immediately reflected in subsequent hands. The modular upgrade system allows for easy expansion of upgrade types without affecting core game logic.

Scene transitions preserve all game state while allowing scenes to maintain their own temporary interface states. This design enables smooth transitions between game phases while maintaining data integrity.

### Logical Flow Architecture

The game follows a clear hierarchical flow where runs contain rounds and rounds contain hands. This structure is reflected in the code organization, with main.lua managing run-level state, round.lua handling round progression, and hand-specific logic distributed between round.lua and main.lua based on whether it affects persistent state.

Trap rule evaluation occurs in main.lua using the current rule set and card properties, ensuring consistent application across all hands. The rule accumulation system is implemented through persistent rule storage that carries forward through round progression.

Win condition checking happens after each hand completion, with main.lua evaluating both player and opponent hands against current trap rules to determine round outcomes.

## Visual Design and User Experience

Botrap employs a clean, colorful visual design that emphasizes clarity and engagement through dynamic animations and visual feedback systems.

### Card Presentation and Visual Hierarchy

Cards use a 256x384 pixel resolution providing crisp detail while maintaining reasonable performance. Normal cards display without visual modification, while special card types receive distinct visual treatments through color tinting systems.

Trapped cards receive subtle red tinting to clearly indicate their dangerous status without overwhelming the card artwork. Gold cards feature warm yellow tinting that conveys their protective and valuable nature. Wild cards use neutral gray tinting to emphasize their universal nature.

Player and opponent decks are visually distinguished through colored card backs - blue for the player deck and red for the opponent deck. Additionally, opponent card backs are highlighted with color tints matching their card type, providing strategic information even when cards are face-down. This color coding extends throughout the interface to maintain consistent visual associations.

### Animation and Interface Dynamics

All interface elements feature subtle floating and wobbling animations that create a lively, engaging atmosphere without distracting from gameplay. Text elements gently pulse and move to draw attention while maintaining readability.

Card animations provide immediate feedback for user interactions. Cards smoothly transition between states when trap rules are applied, with tinting changes accompanied by brief highlight effects that clearly communicate state changes.

Scene transitions use smooth animations that maintain visual continuity while clearly indicating progression through different game phases. The animated title screen creates an inviting entry point that establishes the game's energetic visual tone.

### User Interface Design Philosophy

The interface prioritizes clarity and immediate comprehension over decorative elements. Card selections are highlighted with clear visual indicators, and available actions are presented through intuitive button layouts.

Information hierarchy ensures that critical game state information remains prominently displayed without cluttering the interface. Current trap rules, hand compositions, and opponent information are positioned for quick reference during gameplay.

Visual feedback systems provide immediate confirmation of user actions. Trap rule applications, card selections, and upgrade choices all feature clear visual responses that help players understand the consequences of their decisions.

The overall design philosophy emphasizes accessibility and clarity, ensuring that players can focus on strategic decision-making rather than interface navigation. Color choices and contrast levels support gameplay across different viewing conditions while maintaining the game's vibrant aesthetic.
