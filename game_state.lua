-- Game State Manager - Handles scenes and core game logic

local game_state = {}

-- Game scenes
game_state.scene = "menu" -- "menu", "playing", "game_over"

-- Game data
game_state.round = 1
game_state.hand = 1
game_state.player_score = 0
game_state.opponent_score = 0
game_state.phase = "card_selection" -- "card_selection", "rule_selection", "hand_complete"

-- Card hands
game_state.player_hand = {}
game_state.opponent_hand = {}
game_state.selected_cards = {}

-- Game configuration
game_state.config = {
    hand_size = 5,
    max_rounds = 3
}

-- Game over data
game_state.winner = nil
game_state.game_over_message = ""
game_state.win_check_timer = 0 -- Timer for delayed win overlay
game_state.win_detected = false -- Flag for when win is detected but not yet shown

function game_state.load()
    -- Initialize card system
    local cards = require("cards")
    local deck = require("deck")
    local rules = require("rules")
    
    cards.load()
    deck.load()
    rules.load()
    
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
    
    if game_state.win_check_timer > 0 then
        game_state.win_check_timer = game_state.win_check_timer - dt
        if game_state.win_check_timer <= 0 then
            game_state.scene = "game_over"
        end
    end
end

function game_state.get_scene()
    return game_state.scene
end

function game_state.set_scene(new_scene)
    game_state.scene = new_scene
end

function game_state.start_new_game()
    print("Starting new Botrap game!")
    
    local deck = require("deck")
    local rules = require("rules")
    
    -- Reset game state
    game_state.round = 1
    game_state.hand = 1
    game_state.player_score = 0
    game_state.opponent_score = 0
    game_state.winner = nil
    game_state.game_over_message = ""
    game_state.win_check_timer = 0
    game_state.win_detected = false
    
    -- Reset card systems
    deck.reset()
    rules.reset()
    
    -- Start first hand
    game_state.start_new_hand()
    game_state.scene = "playing"
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
    
    game_state.winner = winner
    game_state.game_over_message = message
    game_state.win_detected = true
    game_state.win_check_timer = 2.0
    
    local color = winner == "player" and ui.colors.success or ui.colors.danger
    ui.add_floating_text(notification, love.graphics.getWidth() / 2, 300, color)
    
    return true
end

function game_state.start_new_hand()
    print("Starting hand " .. game_state.hand)
    
    local deck = require("deck")
    local rules = require("rules")
    
    -- Reset hand state
    game_state.phase = "card_selection"
    game_state.selected_cards = {}
    rules.reset_hand()
    
    -- Deal new cards
    game_state.player_hand = deck.deal_player_cards(game_state.config.hand_size)
    game_state.opponent_hand = deck.deal_opponent_cards(game_state.config.hand_size)
    
    -- Arrange cards on screen
    game_state.arrange_cards()
    
    -- Check for win condition after dealing
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

function game_state.achieve_botrap()
    game_state.player_score = game_state.player_score + 1
    
    if game_state.player_score >= 2 then
        game_state.end_game("player", "BOTRAP! You won the game!")
    else
        game_state.game_over_message = "BOTRAP! You win this round!"
        game_state.scene = "game_over"
        
        -- Auto-continue after showing message
        love.timer.sleep(2)
        game_state.next_round()
    end
end

function game_state.next_hand()
    game_state.hand = game_state.hand + 1
    
    local deck = require("deck")
    
    if not deck.can_deal_more(game_state.config.hand_size) then
        game_state.end_game("draw", "No more cards to deal")
    else
        game_state.start_new_hand()
    end
end

function game_state.next_round()
    game_state.round = game_state.round + 1
    game_state.hand = 1
    local deck = require("deck")
    deck.reset()
    game_state.start_new_hand()
    game_state.scene = "playing"
end

function game_state.end_game(winner, message)
    game_state.winner = winner
    game_state.game_over_message = message
    game_state.scene = "game_over"
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

function game_state.get_player_score()
    return game_state.player_score
end

function game_state.get_opponent_score()
    return game_state.opponent_score
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

return game_state
