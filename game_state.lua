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
    -- Update card animations
    local cards = require("cards")
    local all_cards = {}
    
    -- Collect all cards for animation updates
    for _, card in ipairs(game_state.player_hand) do
        table.insert(all_cards, card)
    end
    for _, card in ipairs(game_state.opponent_hand) do
        table.insert(all_cards, card)
    end
    
    cards.update_all(all_cards, dt)
    
    -- Handle delayed win condition display
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
    local cards = require("cards")
    local rules = require("rules")
    
    -- Check if any active rules exist
    local active_rules = rules.get_active_rules()
    if #active_rules == 0 then
        return false -- No rules to violate
    end
    
    -- Check player hand for violations (using current system which respects gold protection)
    local player_violations = false
    for _, card in ipairs(game_state.player_hand) do
        if cards.is_violating_rules(card, game_state.player_hand) then
            player_violations = true
            break
        end
    end
    
    -- Check opponent hand for violations (using current system which respects gold protection)
    local opponent_violations = false
    for _, card in ipairs(game_state.opponent_hand) do
        if cards.is_violating_rules(card, game_state.opponent_hand) then
            opponent_violations = true
            break
        end
    end
    
    -- Check for violations WITHOUT gold protection
    local player_violations_without_gold = rules.has_violations_without_gold(game_state.player_hand)
    local opponent_violations_without_gold = rules.has_violations_without_gold(game_state.opponent_hand)
    
    -- Check gold protection status
    local player_has_gold = rules.has_gold_protection(game_state.player_hand)
    local opponent_has_gold = rules.has_gold_protection(game_state.opponent_hand)
    
    -- Special case: Both have violations without gold, but only opponent has gold protection
    if player_violations_without_gold and opponent_violations_without_gold and 
       opponent_has_gold and not player_has_gold then
        game_state.winner = "opponent"
        game_state.game_over_message = "You Lose! Opponent's gold protects them!"
        game_state.win_detected = true
        game_state.win_check_timer = 2.0 -- 2 second delay before showing win screen
        
        -- Show notification to player
        local ui = require("ui")
        ui.add_floating_text("Defeat! Gold protection saves opponent!", love.graphics.getWidth() / 2, 300, ui.colors.danger)
        
        return true
    end
    
    -- Standard win conditions: opponent has violations but player doesn't
    if opponent_violations and not player_violations then
        game_state.winner = "player"
        game_state.game_over_message = "You Win! Opponent violated rules!"
        game_state.win_detected = true
        game_state.win_check_timer = 2.0 -- 2 second delay before showing win screen
        
        -- Show notification to player
        local ui = require("ui")
        ui.add_floating_text("Victory! Opponent violates rules!", love.graphics.getWidth() / 2, 300, ui.colors.success)
        
        return true
    elseif player_violations and not opponent_violations then
        game_state.winner = "opponent"
        game_state.game_over_message = "You Lose! Your hand violated rules!"
        game_state.win_detected = true
        game_state.win_check_timer = 2.0 -- 2 second delay before showing win screen
        
        -- Show notification to player
        local ui = require("ui")
        ui.add_floating_text("Defeat! Your hand violates rules!", love.graphics.getWidth() / 2, 300, ui.colors.danger)
        
        return true
    end
    
    -- BOTRAP condition: player hand is valid, opponent hand is invalid
    -- This uses the rules.validate_hand which handles gold protection properly
    local player_valid, player_violations_list = rules.validate_hand(game_state.player_hand)
    local opponent_valid, opponent_violations_list = rules.validate_hand(game_state.opponent_hand)
    
    if player_valid and not opponent_valid then
        game_state.winner = "player"
        game_state.game_over_message = "BOTRAP! You trapped your opponent!"
        game_state.win_detected = true
        game_state.win_check_timer = 2.0 -- 2 second delay before showing win screen
        
        -- Show notification to player
        local ui = require("ui")
        ui.add_floating_text("BOTRAP! You trapped your opponent!", love.graphics.getWidth() / 2, 300, ui.colors.success)
        
        return true
    end
    
    return false
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
