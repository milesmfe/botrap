-- Game State Manager - Handles scenes and core game logic

local game_state = {}

-- Game scenes: "menu", "playing", "upgrade", "game_over", "run_complete", "stats"
game_state.scene = "menu"

-- Run/Round/Hand hierarchy
game_state.run = 1
game_state.round = 1
game_state.hand = 1
game_state.phase = "card_selection" -- "card_selection", "rule_selection", "hand_complete"

-- Current opponent data
game_state.current_opponent = nil
game_state.opponent_abilities = {}

-- Player progression
game_state.player_upgrades = {}
game_state.defeated_opponents = {}
game_state.available_upgrades = {} -- For upgrade selection screen

-- Current hands
game_state.player_hand = {}
game_state.opponent_hand = {}
game_state.selected_cards = {}

-- Configuration
game_state.config = {
    hand_size = 5,
    max_rounds_per_run = 5, -- Complete run after 5 rounds
    upgrades_offered = 3    -- Number of upgrade choices offered
}

-- Win/Loss tracking
game_state.winner = nil
game_state.game_over_message = ""
game_state.win_detected = false
game_state.scene_transition_timer = 0
game_state.pending_scene = nil

function game_state.load()
    -- Initialize card system
    local cards = require("cards")
    local deck = require("deck")
    local rules = require("rules")
    local stats = require("stats")
    
    cards.load()
    deck.load()
    rules.load()
    stats.load()
    
    -- Start at menu
    game_state.scene = "menu"
end

function game_state.update(dt)
    local cards = require("cards")
    local all_cards = {}
    
    for _, card in ipairs(game_state.player_hand) do
        table.insert(all_cards, card)
    end
    for _, card in ipairs(game_state.opponent_hand) do
        table.insert(all_cards, card)
    end
    
    cards.update_all(all_cards, dt)
    
    -- Handle smooth scene transitions
    if game_state.scene_transition_timer > 0 then
        game_state.scene_transition_timer = game_state.scene_transition_timer - dt
        if game_state.scene_transition_timer <= 0 and game_state.pending_scene then
            game_state.scene = game_state.pending_scene
            game_state.pending_scene = nil
        end
    end
end

function game_state.get_scene()
    return game_state.scene
end

function game_state.set_scene(new_scene)
    game_state.scene = new_scene
end

function game_state.schedule_scene_transition(new_scene, delay)
    delay = delay or 1.5 -- Default 1.5 second delay
    game_state.pending_scene = new_scene
    game_state.scene_transition_timer = delay
end

function game_state.start_new_game()
    local deck = require("deck")
    local rules = require("rules")
    local stats = require("stats")
    
    game_state.run = 1
    game_state.round = 1
    game_state.hand = 1
    game_state.current_opponent = nil
    game_state.opponent_abilities = {}
    game_state.player_upgrades = {}
    game_state.defeated_opponents = {}
    game_state.available_upgrades = {}
    game_state.winner = nil
    game_state.game_over_message = ""
    game_state.win_detected = false
    game_state.scene_transition_timer = 0
    game_state.pending_scene = nil
    
    deck.reset()
    rules.reset()
    stats.start_new_run()
    
    game_state.start_new_round()
    game_state.scene = "playing"
end

function game_state.start_new_round()
    local opponents = require("opponents")
    local upgrades = require("upgrades")
    local rules = require("rules")
    
    game_state.hand = 1
    game_state.current_opponent = opponents.get_opponent_for_round(game_state.round)
    game_state.win_detected = false  -- Reset win detection for new round
    
    -- Reset rules for new round - each opponent starts fresh
    rules.reset_round()
    
    opponents.reset_opponent_effects(game_state)
    opponents.apply_opponent_ability(game_state.current_opponent, game_state)
    upgrades.apply_all_upgrades(game_state)
    
    game_state.start_new_hand()
end

function game_state.round_victory()
    local stats = require("stats")
    
    -- Record stats
    stats.record_round_victory(game_state.current_opponent.name)
    
    table.insert(game_state.defeated_opponents, game_state.current_opponent)
    game_state.round = game_state.round + 1
    
    if game_state.round > game_state.config.max_rounds_per_run then
        game_state.run_complete()
    else
        -- Offer upgrades before next round with smooth transition
        game_state.prepare_upgrade_selection()
        game_state.schedule_scene_transition("upgrade", 2.0)
    end
end

function game_state.round_defeat()
    local stats = require("stats")
    
    game_state.winner = "opponent"
    game_state.game_over_message = "Run ended! " .. game_state.current_opponent.name .. " defeated you!"
    
    -- Complete run stats (not victorious)
    stats.complete_run(false)
    
    game_state.schedule_scene_transition("game_over", 2.0)
end

function game_state.run_complete()
    local stats = require("stats")
    
    game_state.winner = "player"
    game_state.game_over_message = "Victory! You completed the full run!"
    
    -- Complete run stats (victorious)
    stats.complete_run(true)
    
    game_state.schedule_scene_transition("run_complete", 2.0)
end

function game_state.continue_after_upgrade()
    game_state.start_new_round()
    game_state.scene = "playing"
end

function game_state.prepare_upgrade_selection()
    local upgrades = require("upgrades")
    game_state.available_upgrades = upgrades.get_random_upgrades(game_state.config.upgrades_offered, game_state.round)
end

function game_state.choose_upgrade(upgrade_index)
    if upgrade_index < 1 or upgrade_index > #game_state.available_upgrades then
        return false, "Invalid upgrade selection"
    end
    
    local upgrades = require("upgrades")
    local stats = require("stats")
    local chosen_upgrade = game_state.available_upgrades[upgrade_index]
    
    -- Apply the upgrade
    upgrades.apply_upgrade(chosen_upgrade, game_state)
    
    -- Record in player upgrades and stats
    table.insert(game_state.player_upgrades, chosen_upgrade)
    stats.record_upgrade_chosen(chosen_upgrade.name)
    
    -- Clear available upgrades
    game_state.available_upgrades = {}
    
    return true, "Upgrade applied: " .. chosen_upgrade.name
end

function game_state.check_win_condition()
    local rules = require("rules")
    
    if #rules.get_active_rules() == 0 then
        return false
    end
    
    local player_violations = game_state.has_hand_violations(game_state.player_hand)
    local opponent_violations = game_state.has_hand_violations(game_state.opponent_hand)
    local player_violations_no_gold = rules.has_violations_without_gold(game_state.player_hand)
    local opponent_violations_no_gold = rules.has_violations_without_gold(game_state.opponent_hand)
    local player_has_gold = rules.has_gold_protection(game_state.player_hand)
    local opponent_has_gold = rules.has_gold_protection(game_state.opponent_hand)
    
    -- Handle opponent rule immunity ability
    if game_state.current_opponent and game_state.current_opponent.ability == "rule_immunity" and opponent_violations then
        opponent_violations = false -- Opponent ignores one violation per hand
    end
    
    -- Gold protection special case
    if player_violations_no_gold and opponent_violations_no_gold and 
       opponent_has_gold and not player_has_gold then
        return game_state.end_with_win("opponent", "You Lose! Opponent's gold protects them!", "Defeat! Gold protection saves opponent!")
    end
    
    -- Standard violations
    if opponent_violations and not player_violations then
        return game_state.end_with_win("player", "You Win! Opponent violated rules!", "Victory! Opponent violates rules!")
    elseif player_violations and not opponent_violations then
        return game_state.end_with_win("opponent", "You Lose! Your hand violated rules!", "Defeat! Your hand violates rules!")
    end
    
    -- BOTRAP condition
    local player_valid, _ = rules.validate_hand(game_state.player_hand)
    local opponent_valid, _ = rules.validate_hand(game_state.opponent_hand)
    
    if player_valid and not opponent_valid then
        return game_state.end_with_win("player", "BOTRAP! You trapped your opponent!", "BOTRAP! You trapped your opponent!")
    end
    
    return false
end

function game_state.has_hand_violations(hand)
    local cards = require("cards")
    for _, card in ipairs(hand) do
        if cards.is_violating_rules(card, hand) then
            return true
        end
    end
    return false
end

function game_state.end_with_win(winner, message, notification)
    local ui = require("ui")
    
    -- Show floating text notification immediately
    local color = winner == "player" and ui.colors.success or ui.colors.danger
    ui.add_floating_text(notification, love.graphics.getWidth() / 2, 300, color)
    
    -- Set message for potential display
    game_state.game_over_message = message
    game_state.win_detected = true
    
    if winner == "player" then
        -- Player wins hand, advance to next round or complete run
        game_state.round_victory()
    else
        -- Opponent wins hand, end the run immediately
        game_state.round_defeat()
    end
    
    return true
end

function game_state.start_new_hand()
    print("Starting hand " .. game_state.hand .. " of round " .. game_state.round)
    
    local deck = require("deck")
    local rules = require("rules")
    local stats = require("stats")
    
    -- Record hand played
    stats.record_hand_played()
    
    -- Reset hand state
    game_state.phase = "card_selection"
    game_state.selected_cards = {}
    game_state.win_detected = false  -- Reset win detection for new hand
    rules.reset_hand()
    
    -- Deal new cards
    local player_hand_size = game_state.config.hand_size
    local opponent_hand_size = game_state.config.hand_size
    
    -- Apply opponent ability modifications
    if game_state.current_opponent and game_state.current_opponent.ability == "extra_card" then
        opponent_hand_size = opponent_hand_size + 1
    end
    
    -- Check if we can deal more cards
    if not deck.can_deal_more(player_hand_size + opponent_hand_size) then
        game_state.round_defeat()
        game_state.game_over_message = "No more cards to deal! " .. game_state.current_opponent.name .. " wins by deck exhaustion!"
        return
    end
    
    game_state.player_hand = deck.deal_player_cards(player_hand_size)
    game_state.opponent_hand = deck.deal_opponent_cards(opponent_hand_size)
    
    -- Apply opponent auto-gold ability if they have it
    if game_state.current_opponent and game_state.current_opponent.ability == "auto_gold" then
        rules.apply_opponent_auto_gold(game_state.opponent_hand)
    end
    
    -- Arrange cards on screen
    game_state.arrange_cards()
    
    -- Check for immediate win condition after dealing
    game_state.check_win_condition()
end

function game_state.arrange_cards()
    local cards = require("cards")
    local deck = require("deck")
    
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    -- Card dimensions
    local card_width = cards.get_display_width()
    local card_height = cards.get_display_height()
    local card_spacing = 15
    
    -- Player hand (bottom)
    local player_y = screen_height - card_height - 120 -- Leave space for rule queue
    local player_total_width = (#game_state.player_hand - 1) * (card_width + card_spacing) + card_width
    local player_start_x = (screen_width - player_total_width) / 2
    
    for i, card in ipairs(game_state.player_hand) do
        local target_x = player_start_x + (i - 1) * (card_width + card_spacing)
        cards.set_target_position(card, target_x, player_y)
        cards.set_revealed(card, true)
    end
    
    -- Opponent hand (top)
    local opponent_y = 60
    local opponent_total_width = (#game_state.opponent_hand - 1) * (card_width + card_spacing) + card_width
    local opponent_start_x = (screen_width - opponent_total_width) / 2
    
    for i, card in ipairs(game_state.opponent_hand) do
        local target_x = opponent_start_x + (i - 1) * (card_width + card_spacing)
        cards.set_target_position(card, target_x, opponent_y)
        cards.set_revealed(card, false) -- Start face down
    end
    
    -- Position deck indicators
    local deck_spacing = 40
    
    -- Player deck (bottom right of player hand)
    local player_deck_x = player_start_x + player_total_width + deck_spacing
    local player_deck_y = player_y
    deck.set_player_deck_position(player_deck_x, player_deck_y)
    
    -- Opponent deck (bottom right of opponent hand)
    local opponent_deck_x = opponent_start_x + opponent_total_width + deck_spacing
    local opponent_deck_y = opponent_y
    deck.set_opponent_deck_position(opponent_deck_x, opponent_deck_y)
end

function game_state.apply_rule(rule_type, value)
    local rules = require("rules")
    local success, message = rules.apply_rule(rule_type, value)
    if success then
        -- Clear selected cards after applying rule
        local cards = require("cards")
        for _, card in ipairs(game_state.selected_cards) do
            cards.set_selected(card, false)
        end
        game_state.selected_cards = {}
        return true, message
    end
    return false, message
end

function game_state.select_card(card)
    if game_state.phase ~= "card_selection" and game_state.phase ~= "rule_selection" then
        return false, "Cannot select cards in current phase"
    end
    
    local cards = require("cards")
    
    -- Toggle card selection
    if cards.is_selected(card) then
        cards.set_selected(card, false)
        -- Remove from selected list
        for i, selected_card in ipairs(game_state.selected_cards) do
            if selected_card == card then
                table.remove(game_state.selected_cards, i)
                break
            end
        end
    else
        cards.set_selected(card, true)
        table.insert(game_state.selected_cards, card)
    end
    
    -- Update phase based on selection count
    if #game_state.selected_cards > 0 then
        game_state.phase = "rule_selection"
    else
        game_state.phase = "card_selection"
    end
    
    return true, "Card selection updated"
end

function game_state.complete_hand()
    local cards = require("cards")
    local rules = require("rules")
    
    -- Flip opponent cards
    for _, card in ipairs(game_state.opponent_hand) do
        cards.set_revealed(card, true)
        cards.add_bounce_effect(card)
    end
    
    -- Check ALL win conditions first (including new gold protection logic)
    if game_state.check_win_condition() then
        -- Win condition detected, don't proceed to next hand
        return true, "Win condition detected"
    end
    
    -- If no immediate win condition, continue the game - deal new hands
    game_state.next_hand()
    
    return true, "Hand completed"
end

function game_state.next_hand()
    game_state.hand = game_state.hand + 1
    game_state.start_new_hand()
end

function game_state.return_to_menu()
    game_state.scene = "menu"
    game_state.run = 1
    game_state.round = 1
    game_state.hand = 1
    game_state.winner = nil
    game_state.game_over_message = ""
    game_state.scene_transition_timer = 0
    game_state.pending_scene = nil
    
    -- Reset all game state
    local deck = require("deck")
    local rules = require("rules")
    
    game_state.current_opponent = nil
    game_state.opponent_abilities = {}
    game_state.player_upgrades = {}
    game_state.defeated_opponents = {}
    game_state.available_upgrades = {}
    game_state.player_hand = {}
    game_state.opponent_hand = {}
    game_state.selected_cards = {}
    
    deck.reset()
    rules.reset()
end

-- New getters for upgrade and stats systems
function game_state.get_available_upgrades()
    return game_state.available_upgrades
end

function game_state.get_config()
    return game_state.config
end

-- Getters for UI
function game_state.get_player_hand()
    return game_state.player_hand
end

function game_state.get_opponent_hand()
    return game_state.opponent_hand
end

function game_state.get_selected_cards()
    return game_state.selected_cards
end

function game_state.get_round()
    return game_state.round
end

function game_state.get_hand()
    return game_state.hand
end

function game_state.get_win_detected()
    return game_state.win_detected
end

function game_state.get_phase()
    return game_state.phase
end

function game_state.get_winner()
    return game_state.winner
end

function game_state.get_game_over_message()
    return game_state.game_over_message
end

-- New getters for run/round system
function game_state.get_run()
    return game_state.run
end

function game_state.get_current_opponent()
    return game_state.current_opponent
end

function game_state.get_player_upgrades()
    return game_state.player_upgrades
end

function game_state.get_defeated_opponents()
    return game_state.defeated_opponents
end

-- Getters for transition state
function game_state.get_scene_transition_timer()
    return game_state.scene_transition_timer
end

function game_state.get_pending_scene()
    return game_state.pending_scene
end

return game_state
