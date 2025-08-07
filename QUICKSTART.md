# BOTRAP - Quick Start Guide

## How to Run the Game

1. Make sure Love2D is installed (already available at `/opt/homebrew/bin/love`)
2. Open a terminal and navigate to the game directory
3. Run: `love .` or use the VS Code task "Run Botrap Game"

## How to Play

### Main Menu
- Click "NEW GAME" to start a new run
- Click "STATS" to view your overall statistics
- Click "QUIT" to exit

### Game Objective
- Complete 13 rounds to win the run
- Each round, try to achieve a hand with NO trapped cards while your opponent HAS trapped cards
- When this condition is met, click "BOTRAP!" to win the round

### Gameplay Controls

#### Card Selection
- Click on any card (yours or opponent's) to select/deselect it
- Selected cards are highlighted with a blue border
- You can select multiple cards for certain rules

#### Trap Rules
- **Trap Suit** (1 card): Makes all cards of the selected card's suit become trapped
- **Trap Rank** (1 card): Makes all cards of the selected card's rank become trapped  
- **Trap Suit Match** (2 cards): Makes all cards matching either of the two selected suits become trapped
- **Trap Rank Match** (2 cards): Makes all cards matching either of the two selected ranks become trapped
- **Gold** (1 card): Resets all trapped cards to normal AND makes that specific card type gold (only once per round)

#### Action Buttons
- **APPLY RULE**: Apply the selected trap rule to selected cards
- **NEW HAND**: Return all cards to decks, reshuffle, and deal new hands
- **BOTRAP!**: Win the round (only available when you have no trapped cards and opponent has trapped cards)

### Card Types (Visual Indicators)
- **Normal Cards**: No tint
- **Trapped Cards**: Red tint - these are dangerous!
- **Gold Cards**: Yellow tint - these are safe and valuable
- **Wild Cards**: Gray background with "WILD" text

### Round Progression
1. Play hands until you can call "BOTRAP!"
2. Visit the Locker to choose 1 upgrade from 3 options
3. Face a new opponent in the next round
4. Repeat until round 13 (final boss: Bo Trap)

### Upgrade Types
- **Prison Guard**: Converts opponent cards to trapped cards
- **King's Orders**: Converts your cards to gold cards  
- **Rogue**: Converts your cards to wild cards

### Strategy Tips
- Trap rules accumulate throughout a round - plan carefully!
- Use Gold strategically to clear dangerous trap situations
- Consider future hands when applying trap rules
- Higher-level opponents have more upgrades, making them harder

### Winning/Losing
- **Win**: Complete all 13 rounds by defeating Bo Trap
- **Lose**: End up with a hand containing trapped cards when opponent has none

## Keyboard Shortcuts
- Currently mouse-only interface
- Click and point for all interactions

## Troubleshooting
- If the game doesn't start, ensure Love2D 11.4+ is installed
- All card images are generated automatically if missing
- Check the console for any error messages
