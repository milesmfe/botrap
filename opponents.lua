local opponents = {}

-- Opponent definitions - exactly 5 opponents for 5 rounds
opponents.opponent_types = {
    {
        name = "Novice Dealer",
        description = "A beginner opponent with no special abilities",
        ability = nil,
        round = 1
    },
    {
        name = "Card Hoarder", 
        description = "Starts each hand with 6 cards instead of 5",
        ability = "extra_card",
        round = 2
    },
    {
        name = "Rule Bender",
        description = "Can ignore one rule violation per hand", 
        ability = "rule_immunity",
        round = 3
    },
    {
        name = "Gold Guardian",
        description = "Automatically gets gold protection on random cards",
        ability = "auto_gold",
        round = 4
    },
    {
        name = "Deck Master",
        description = "Can see your hand and gets perfect draws",
        ability = "perfect_draw",
        round = 5
    }
}

-- Generate opponent for a given round
function opponents.get_opponent_for_round(round)
    if round < 1 or round > 5 then
        return opponents.opponent_types[1] -- Default to first opponent
    end
    
    return opponents.opponent_types[round]
end

-- Apply opponent ability effects
function opponents.apply_opponent_ability(opponent, game_state)
    if not opponent or not opponent.ability then
        return
    end
    
    if opponent.ability == "extra_card" then
        -- Opponent gets 6 cards instead of 5 (handled in start_new_hand)
        -- No need to modify config here
    elseif opponent.ability == "rule_immunity" then
        -- Opponent can ignore one rule violation per hand
        game_state.opponent_rule_immunity = true
    elseif opponent.ability == "auto_gold" then
        -- Opponent automatically gets gold protection
        game_state.opponent_auto_gold = true
    elseif opponent.ability == "perfect_draw" then
        -- Opponent can see player hand and gets perfect draws
        game_state.opponent_can_peek = true
        game_state.opponent_perfect_draws = true
    end
end

-- Reset opponent effects
function opponents.reset_opponent_effects(game_state)
    game_state.opponent_rule_immunity = false
    game_state.opponent_auto_gold = false
    game_state.opponent_can_peek = false
    game_state.opponent_perfect_draws = false
end

return opponents
