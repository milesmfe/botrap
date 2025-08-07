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
- Hands contain 5 cards each (some opponents may increase this to 6, 7, 8, or 9 cards)

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
- **APPLY RULE**: Apply the selected trap rule to selected cards (triggers reshuffle and new hand)
- **NEW HAND**: Return all cards to decks, reshuffle, and deal new hands manually
- **BOTRAP!**: Win the round (only available when you have no trapped cards and opponent has trapped cards)

**Important**: After applying any trap rule, all cards automatically return to their decks, get reshuffled, and new hands are dealt with the accumulated trap rules in effect.

### Card Types (Visual Indicators)
- **Normal Cards**: No tint
- **Trapped Cards**: Red tint - these are dangerous!
- **Gold Cards**: Yellow tint - these are safe and valuable
- **Wild Cards**: Gray background with "WILD" text

**Opponent Card Backs**: Even when face-down, opponent cards show hints about their type:
- Normal cards: No highlighting on back
- Trapped cards: Red-tinted back
- Gold cards: Yellow-tinted back  
- Wild cards: Gray-tinted back

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
- After each rule application, cards are automatically returned to decks and reshuffled
- Use Gold strategically to clear dangerous trap situations and get a fresh hand
- Consider future hands when applying trap rules - they persist for the entire round
- Higher-level opponents have more upgrades, making them harder
- Some opponents increase your hand size, giving you more cards to work with but also more potential traps
- Watch opponent card back colors for strategic information about hidden cards
- The "NEW HAND" button lets you reshuffle without applying a rule, but trap rules remain active

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
