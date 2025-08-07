-- Round scene - Core gameplay interface
local Round = {}
local Card = require("card")

local game_ref
local ui_elements = {}
local rule_buttons = {}
local selected_rule = nil

-- Animation state
local animation_state = {
    active = false,
    type = nil, -- "win" or "lose"
    time = 0,
    duration = 3.0, -- Total animation duration
    flip_duration = 1.5, -- Time for card flips
    message_duration = 1.5, -- Time to show win/lose message
    cards_revealed = false,
    message = ""
}

-- Cached win condition (only calculated when hand changes)
local cached_win_condition = false

function Round.init(game)
    game_ref = game
    
    -- Initialize rule buttons
    rule_buttons = {
        {
            text = "Trap Suit",
            rule = "suit",
            min_cards = 1,
            max_cards = 1,
            x = 50,
            y = game.ui.height - 150,
            w = 120,
            h = 40
        },
        {
            text = "Trap Rank",
            rule = "rank",
            min_cards = 1,
            max_cards = 1,
            x = 180,
            y = game.ui.height - 150,
            w = 120,
            h = 40
        },
        {
            text = "Trap Suit Match",
            rule = "suit_match",
            min_cards = 2,
            max_cards = 2,
            x = 310,
            y = game.ui.height - 150,
            w = 140,
            h = 40
        },
        {
            text = "Trap Rank Match",
            rule = "rank_match",
            min_cards = 2,
            max_cards = 2,
            x = 460,
            y = game.ui.height - 150,
            w = 140,
            h = 40
        },
        {
            text = "Gold",
            rule = "gold",
            min_cards = 1,
            max_cards = 1,
            x = 610,
            y = game.ui.height - 150,
            w = 100,
            h = 40
        }
    }
    
    ui_elements = {
        apply_button = {
            text = "APPLY RULE",
            x = 750,
            y = game.ui.height - 150,
            w = 120,
            h = 40
        },
        botrap_button = {
            text = "BOTRAP!",
            x = 750,
            y = game.ui.height - 100,
            w = 120,
            h = 40
        },
        new_hand_button = {
            text = "NEW HAND",
            x = 600,
            y = game.ui.height - 100,
            w = 120,
            h = 40
        }
    }
end

function Round.enter()
    print("DEBUG: Round.enter() called")
    dealHand()
    selected_rule = nil
    
    -- Reset animation state
    animation_state.active = false
    animation_state.type = nil
    animation_state.time = 0
    animation_state.cards_revealed = false
    animation_state.message = ""
    
    print("DEBUG: Round scene entered, initial win condition check...")
    Round.updateWinCondition()
end

function Round.updateWinCondition()
    cached_win_condition = checkWinCondition()
    print("DEBUG: Win condition updated:", cached_win_condition)
end

function Round.update(dt)
    -- Update animations if active
    if animation_state.active then
        animation_state.time = animation_state.time + dt
        
        -- Reveal cards after flip duration
        if not animation_state.cards_revealed and animation_state.time >= animation_state.flip_duration then
            animation_state.cards_revealed = true
            print("DEBUG: Animation - cards revealed, showing result")
        end
        
        -- Complete animation and transition scene
        if animation_state.time >= animation_state.duration then
            print("DEBUG: Animation complete, transitioning scene")
            animation_state.active = false
            
            if animation_state.type == "win" then
                nextRound()
            else
                gameOver()
            end
        end
    end
end

function Round.draw()
    -- Background
    love.graphics.setColor(0.05, 0.1, 0.05, 1)
    love.graphics.rectangle("fill", 0, 0, game_ref.ui.width, game_ref.ui.height)
    
    -- Draw round info
    Round.drawRoundInfo()
    
    -- Draw opponent info
    Round.drawOpponentInfo()
    
    -- Draw decks
    Round.drawDecks()
    
    -- Draw hands
    Round.drawPlayerHand()
    Round.drawOpponentHand()
    
    -- Draw current trap rules
    Round.drawTrapRules()
    
    -- Draw active upgrades
    Round.drawUpgrades()
    
    -- Draw UI elements only if not animating
    if not animation_state.active then
        Round.drawRuleButtons()
        Round.drawActionButtons()
        Round.drawSelectionInfo()
    end
    
    -- Draw animation overlay if active
    if animation_state.active then
        Round.drawAnimationOverlay()
    end
end

function Round.drawRoundInfo()
    love.graphics.setFont(game_ref.ui.font_medium)
    love.graphics.setColor(1, 1, 1, 1)
    drawFloatingText("Round " .. game_ref.run.current_round .. " / 13", 20, 20, game_ref.ui.font_medium)
    
    if game_ref.run.current_opponent then
        drawFloatingText("vs " .. game_ref.run.current_opponent.name, 20, 50, game_ref.ui.font_small)
    end
    
    -- Show current hand size
    local hand_size_text = "Hand Size: " .. game_ref.hand.hand_size
    if game_ref.hand.hand_size > game_ref.hand.base_hand_size then
        love.graphics.setColor(1, 0.8, 0.3, 1)  -- Highlight if increased
        hand_size_text = hand_size_text .. " (+" .. (game_ref.hand.hand_size - game_ref.hand.base_hand_size) .. ")"
    else
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    end
    drawFloatingText(hand_size_text, 20, 80, game_ref.ui.font_small)
end

function Round.drawOpponentInfo()
    local x = game_ref.ui.width - 200
    local y = 20
    local w = 180
    local h = 150
    
    if game_ref.run.current_opponent then
        local Opponents = require("opponents")
        Opponents.drawOpponent(game_ref.run.current_opponent, x, y, w, h)
    end
end

function Round.drawDecks()
    -- Player deck
    Card.drawDeck(game_ref.run.player_deck, 50, 200, true)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(game_ref.ui.font_small)
    drawFloatingText("Your Deck", 50, 180, game_ref.ui.font_small)
    
    -- Opponent deck
    Card.drawDeck(game_ref.run.opponent_deck, game_ref.ui.width - 100, 200, false)
    drawFloatingText("Opponent Deck", game_ref.ui.width - 150, 180, game_ref.ui.font_small)
end

function Round.drawPlayerHand()
    local area_x = 150
    local area_y = 450
    local area_w = game_ref.ui.width - 300
    local area_h = 120
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(game_ref.ui.font_small)
    drawFloatingText("Your Hand", area_x, area_y - 25, game_ref.ui.font_small)
    
    for i, card in ipairs(game_ref.hand.player_cards) do
        local x, y, w, h = Card.getCardBounds(i, #game_ref.hand.player_cards, area_x, area_y, area_w, area_h)
        local selected = Round.isCardSelected(card, "player", i)
        Card.draw(card, x, y, true, true, selected)
    end
end

function Round.drawOpponentHand()
    local area_x = 150
    local area_y = 300
    local area_w = game_ref.ui.width - 300
    local area_h = 120
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(game_ref.ui.font_small)
    drawFloatingText("Opponent Hand", area_x, area_y - 25, game_ref.ui.font_small)
    
    for i, card in ipairs(game_ref.hand.opponent_cards) do
        local x, y, w, h = Card.getCardBounds(i, #game_ref.hand.opponent_cards, area_x, area_y, area_w, area_h)
        local selected = Round.isCardSelected(card, "opponent", i)
        
        -- Calculate flip animation
        local show_face = false
        if animation_state.active and animation_state.cards_revealed then
            show_face = true
        elseif animation_state.active then
            -- Staggered flip animation
            local flip_progress = math.min(animation_state.time / animation_state.flip_duration, 1)
            local card_delay = (i - 1) * 0.1 -- Stagger card reveals
            local card_flip_start = card_delay
            
            if animation_state.time >= card_flip_start then
                local card_flip_progress = math.min((animation_state.time - card_flip_start) / 0.3, 1)
                show_face = card_flip_progress >= 0.5
                
                -- Scale effect during flip
                if card_flip_progress < 1 then
                    local scale = math.abs(math.cos(card_flip_progress * math.pi))
                    local scale_offset_x = w * (1 - scale) / 2
                    love.graphics.push()
                    love.graphics.translate(x + w/2, y + h/2)
                    love.graphics.scale(scale, 1)
                    love.graphics.translate(-w/2, -h/2)
                    Card.draw(card, 0, 0, show_face, false, selected)
                    love.graphics.pop()
                else
                    Card.draw(card, x, y, show_face, false, selected)
                end
            else
                Card.draw(card, x, y, false, false, selected)
            end
        else
            Card.draw(card, x, y, false, false, selected)
        end
    end
end

function Round.drawTrapRules()
    local x = 20
    local y = 350
    local w = 120
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(game_ref.ui.font_small)
    drawFloatingText("Active Traps:", x, y, game_ref.ui.font_small)
    
    local rule_y = y + 25
    for _, rule in ipairs(game_ref.run.trap_rules) do
        local rule_text = ""
        if rule.type == "suit" then
            rule_text = "Suit: " .. rule.value
        elseif rule.type == "rank" then
            rule_text = "Rank: " .. rule.value
        elseif rule.type == "suit_match" then
            rule_text = "Suits: " .. rule.value[1] .. "+" .. rule.value[2]
        elseif rule.type == "rank_match" then
            rule_text = "Ranks: " .. rule.value[1] .. "+" .. rule.value[2]
        end
        
        love.graphics.setColor(1, 0.7, 0.7, 1)
        drawFloatingText(rule_text, x, rule_y, game_ref.ui.font_small)
        rule_y = rule_y + 20
    end
    
    if game_ref.run.gold_card then
        love.graphics.setColor(1, 1, 0.7, 1)
        local gold_text = "Gold: " .. game_ref.run.gold_card.rank .. " " .. game_ref.run.gold_card.suit
        drawFloatingText(gold_text, x, rule_y, game_ref.ui.font_small)
    end
end

function Round.drawUpgrades()
    -- Draw player upgrades on the left side
    local player_x = 20
    local player_y = 500
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(game_ref.ui.font_small)
    drawFloatingText("Your Upgrades:", player_x, player_y, game_ref.ui.font_small)
    
    local upgrade_y = player_y + 25
    if #game_ref.run.player_upgrades == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        drawFloatingText("None", player_x, upgrade_y, game_ref.ui.font_small)
    else
        for i, upgrade in ipairs(game_ref.run.player_upgrades) do
            local upgrade_text = upgrade.name .. " (" .. upgrade.value .. ")"
            local description = ""
            local color = {0.6, 1, 0.6, 1}  -- Green for player upgrades
            
            if upgrade.type == "prison_guard" then
                color = {1, 0.8, 0.4, 1}  -- Orange for offensive upgrades
                description = " - " .. upgrade.value .. " opponent cards trapped"
            elseif upgrade.type == "kings_orders" then
                color = {1, 1, 0.4, 1}  -- Yellow/gold for gold upgrades
                description = " - " .. upgrade.value .. " your cards are gold"
            elseif upgrade.type == "rogue" then
                color = {0.8, 0.4, 1, 1}  -- Purple for wild upgrades
                description = " - " .. upgrade.value .. " your cards are wild"
            end
            
            love.graphics.setColor(color)
            drawFloatingText(upgrade_text .. description, player_x, upgrade_y, game_ref.ui.font_small)
            upgrade_y = upgrade_y + 18
        end
    end
    
    -- Draw opponent upgrades on the right side
    local opponent_x = game_ref.ui.width - 200
    local opponent_y = 500
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(game_ref.ui.font_small)
    drawFloatingText("Opponent Upgrades:", opponent_x, opponent_y, game_ref.ui.font_small)
    
    upgrade_y = opponent_y + 25
    if #game_ref.run.opponent_upgrades == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        drawFloatingText("None", opponent_x, upgrade_y, game_ref.ui.font_small)
    else
        for i, upgrade in ipairs(game_ref.run.opponent_upgrades) do
            local upgrade_text = upgrade.name .. " (" .. upgrade.value .. ")"
            local description = ""
            local color = {1, 0.6, 0.6, 1}  -- Red for opponent upgrades
            
            if upgrade.type == "prison_guard" then
                color = {1, 0.4, 0.2, 1}  -- Dark red for opponent offensive upgrades
                description = " - " .. upgrade.value .. " your cards trapped"
            elseif upgrade.type == "kings_orders" then
                color = {1, 0.8, 0.2, 1}  -- Dark yellow/gold for opponent gold upgrades
                description = " - " .. upgrade.value .. " their cards are gold"
            elseif upgrade.type == "rogue" then
                color = {0.6, 0.2, 0.8, 1}  -- Dark purple for opponent wild upgrades
                description = " - " .. upgrade.value .. " their cards are wild"
            end
            
            love.graphics.setColor(color)
            drawFloatingText(upgrade_text .. description, opponent_x, upgrade_y, game_ref.ui.font_small)
            upgrade_y = upgrade_y + 18
        end
    end
end

function Round.drawAnimationOverlay()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, game_ref.ui.width, game_ref.ui.height)
    
    -- Show win/lose message
    if animation_state.cards_revealed then
        love.graphics.setFont(game_ref.ui.font_large)
        
        -- Choose color based on result
        if animation_state.type == "win" then
            love.graphics.setColor(0.3, 1, 0.3, 1)
        else
            love.graphics.setColor(1, 0.3, 0.3, 1)
        end
        
        local message = animation_state.message
        local text_width = game_ref.ui.font_large:getWidth(message)
        local x = (game_ref.ui.width - text_width) / 2
        local y = game_ref.ui.height / 2 - 50
        
        -- Pulsing effect
        local pulse = math.sin((animation_state.time - animation_state.flip_duration) * 4) * 0.1 + 1
        love.graphics.push()
        love.graphics.translate(x + text_width/2, y + 18)
        love.graphics.scale(pulse, pulse)
        love.graphics.translate(-text_width/2, -18)
        love.graphics.print(message, 0, 0)
        love.graphics.pop()
        
        -- Show explanation
        love.graphics.setFont(game_ref.ui.font_medium)
        love.graphics.setColor(1, 1, 1, 0.9)
        local explanation = ""
        if animation_state.type == "win" then
            explanation = "Opponent has trapped cards, you don't!"
        else
            explanation = "You have trapped cards, opponent doesn't!"
        end
        local exp_width = game_ref.ui.font_medium:getWidth(explanation)
        love.graphics.print(explanation, (game_ref.ui.width - exp_width) / 2, y + 60)
        
    else
        -- Show "Revealing cards..." during flip
        love.graphics.setFont(game_ref.ui.font_medium)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        
        local message = "Revealing opponent cards..."
        local text_width = game_ref.ui.font_medium:getWidth(message)
        local x = (game_ref.ui.width - text_width) / 2
        local y = game_ref.ui.height / 2 + 100
        
        love.graphics.print(message, x, y)
    end
end

function Round.drawRuleButtons()
    for _, button in ipairs(rule_buttons) do
        Round.drawRuleButton(button)
    end
end

function Round.drawRuleButton(button)
    local selected_count = #game_ref.hand.selected_cards
    local valid = selected_count >= button.min_cards and selected_count <= button.max_cards
    local is_selected = selected_rule == button.rule
    
    -- Special case for gold - only one per round
    if button.rule == "gold" and game_ref.run.gold_card then
        valid = false
    end
    
    local bg_color
    if is_selected then
        bg_color = {0.5, 0.5, 0.8, 1}
    elseif valid then
        bg_color = {0.3, 0.5, 0.3, 1}
    else
        bg_color = {0.3, 0.3, 0.3, 1}
    end
    
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
    
    love.graphics.setColor(valid and {1, 1, 1, 1} or {0.5, 0.5, 0.5, 1})
    love.graphics.rectangle("line", button.x, button.y, button.w, button.h)
    
    love.graphics.setFont(game_ref.ui.font_small)
    love.graphics.printf(button.text, button.x + 5, button.y + button.h/2 - 8, button.w - 10, "center")
end

function Round.drawActionButtons()
    -- Apply Rule button
    local apply_valid = selected_rule and #game_ref.hand.selected_cards > 0
    local apply_button = ui_elements.apply_button
    
    local bg_color = apply_valid and {0.3, 0.6, 0.3, 1} or {0.3, 0.3, 0.3, 1}
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", apply_button.x, apply_button.y, apply_button.w, apply_button.h)
    
    love.graphics.setColor(apply_valid and {1, 1, 1, 1} or {0.5, 0.5, 0.5, 1})
    love.graphics.rectangle("line", apply_button.x, apply_button.y, apply_button.w, apply_button.h)
    love.graphics.setFont(game_ref.ui.font_small)
    love.graphics.printf(apply_button.text, apply_button.x + 5, apply_button.y + apply_button.h/2 - 8, apply_button.w - 10, "center")
    
    -- Botrap button
    local can_botrap = cached_win_condition
    local botrap_button = ui_elements.botrap_button
    
    bg_color = can_botrap and {0.8, 0.3, 0.3, 1} or {0.3, 0.3, 0.3, 1}
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", botrap_button.x, botrap_button.y, botrap_button.w, botrap_button.h)
    
    love.graphics.setColor(can_botrap and {1, 1, 1, 1} or {0.5, 0.5, 0.5, 1})
    love.graphics.rectangle("line", botrap_button.x, botrap_button.y, botrap_button.w, botrap_button.h)
    love.graphics.printf(botrap_button.text, botrap_button.x + 5, botrap_button.y + botrap_button.h/2 - 8, botrap_button.w - 10, "center")
    
    -- New Hand button
    local new_hand_button = ui_elements.new_hand_button
    love.graphics.setColor(0.3, 0.3, 0.5, 1)
    love.graphics.rectangle("fill", new_hand_button.x, new_hand_button.y, new_hand_button.w, new_hand_button.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", new_hand_button.x, new_hand_button.y, new_hand_button.w, new_hand_button.h)
    love.graphics.printf(new_hand_button.text, new_hand_button.x + 5, new_hand_button.y + new_hand_button.h/2 - 8, new_hand_button.w - 10, "center")
end

function Round.drawSelectionInfo()
    if #game_ref.hand.selected_cards > 0 then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(game_ref.ui.font_small)
        local info_text = "Selected: " .. #game_ref.hand.selected_cards .. " card(s)"
        drawFloatingText(info_text, 20, game_ref.ui.height - 50, game_ref.ui.font_small)
    end
end

function Round.isCardSelected(card, hand_type, index)
    for _, selected in ipairs(game_ref.hand.selected_cards) do
        if selected.hand == hand_type and selected.index == index then
            return true
        end
    end
    return false
end

function Round.mousepressed(x, y, button)
    -- Don't allow any clicks during animation
    if animation_state.active then
        return
    end
    
    if button == 1 then  -- Left click
        print("DEBUG: Mouse clicked at", x, y)
        
        -- Check card selections
        Round.checkCardClick(x, y)
        
        -- Check rule buttons
        for _, rule_button in ipairs(rule_buttons) do
            if isPointInRect(x, y, rule_button.x, rule_button.y, rule_button.w, rule_button.h) then
                print("DEBUG: Rule button clicked:", rule_button.rule)
                local selected_count = #game_ref.hand.selected_cards
                if selected_count >= rule_button.min_cards and selected_count <= rule_button.max_cards then
                    if rule_button.rule == "gold" and game_ref.run.gold_card then
                        print("DEBUG: Gold rule already used this round")
                    else
                        selected_rule = rule_button.rule
                        print("DEBUG: Selected rule set to:", selected_rule)
                    end
                else
                    print("DEBUG: Invalid card count for rule. Need", rule_button.min_cards, "to", rule_button.max_cards, "cards, have", selected_count)
                end
                break
            end
        end
        
        -- Check action buttons
        local apply_button = ui_elements.apply_button
        if isPointInRect(x, y, apply_button.x, apply_button.y, apply_button.w, apply_button.h) then
            print("DEBUG: Apply rule button clicked")
            Round.applySelectedRule()
        end
        
        local botrap_button = ui_elements.botrap_button
        if isPointInRect(x, y, botrap_button.x, botrap_button.y, botrap_button.w, botrap_button.h) then
            print("DEBUG: BOTRAP button clicked")
            if cached_win_condition then
                print("DEBUG: Win condition confirmed, starting win animation")
                Round.startWinAnimation()
            else
                print("DEBUG: Win condition not met, cannot call BOTRAP")
            end
        end
        
        local new_hand_button = ui_elements.new_hand_button
        if isPointInRect(x, y, new_hand_button.x, new_hand_button.y, new_hand_button.w, new_hand_button.h) then
            print("DEBUG: New hand button clicked")
            Round.dealNewHand()
        end
    end
end

function Round.checkCardClick(x, y)
    -- Don't allow card clicks during animation
    if animation_state.active then
        return
    end
    
    -- Check player hand
    local area_x = 150
    local area_y = 450
    local area_w = game_ref.ui.width - 300
    local area_h = 120
    
    for i, card in ipairs(game_ref.hand.player_cards) do
        local card_x, card_y, card_w, card_h = Card.getCardBounds(i, #game_ref.hand.player_cards, area_x, area_y, area_w, area_h)
        if Card.isPointInCard(x, y, card_x, card_y) then
            Round.toggleCardSelection(card, "player", i)
            return
        end
    end
end

function Round.startWinAnimation()
    print("DEBUG: Starting win animation")
    animation_state.active = true
    animation_state.type = "win"
    animation_state.time = 0
    animation_state.cards_revealed = false
    animation_state.message = "VICTORY!"
end

function Round.startLossAnimation()
    print("DEBUG: Starting loss animation")
    animation_state.active = true
    animation_state.type = "lose"
    animation_state.time = 0
    animation_state.cards_revealed = false
    animation_state.message = "DEFEAT!"
end

function Round.toggleCardSelection(card, hand_type, index)
    print("DEBUG: Toggling card selection for", card.rank, "of", card.suit, "from", hand_type, "hand, index", index)
    
    -- Check if already selected
    for i, selected in ipairs(game_ref.hand.selected_cards) do
        if selected.hand == hand_type and selected.index == index then
            table.remove(game_ref.hand.selected_cards, i)
            print("DEBUG: Card deselected. Total selected:", #game_ref.hand.selected_cards)
            return
        end
    end
    
    -- Add to selection
    table.insert(game_ref.hand.selected_cards, {
        card = card,
        hand = hand_type,
        index = index
    })
    print("DEBUG: Card selected. Total selected:", #game_ref.hand.selected_cards)
end

function Round.applySelectedRule()
    print("DEBUG: Round.applySelectedRule called")
    print("DEBUG: Selected rule:", selected_rule)
    print("DEBUG: Selected cards count:", #game_ref.hand.selected_cards)
    
    if not selected_rule or #game_ref.hand.selected_cards == 0 then
        print("DEBUG: Cannot apply rule - no rule selected or no cards selected")
        return
    end
    
    local cards = {}
    for i, selected in ipairs(game_ref.hand.selected_cards) do
        table.insert(cards, selected.card)
        print("DEBUG: Selected card", i..":", selected.card.rank, "of", selected.card.suit, "from", selected.hand, "hand")
    end
    
    print("DEBUG: Calling applyTrapRule...")
    if applyTrapRule(selected_rule, cards) then
        print("DEBUG: Rule applied successfully, new hand dealt, clearing selections")
        -- Clear selections since we have a completely new hand
        game_ref.hand.selected_cards = {}
        selected_rule = nil
        
        -- Check win condition after applying rule and dealing new hand
        print("DEBUG: Checking win condition after rule application and new hand...")
        Round.updateWinCondition()
        if cached_win_condition then
            print("DEBUG: WIN CONDITION MET! Player can call BOTRAP!")
        else
            print("DEBUG: Win condition not met, continue playing")
        end
        
        -- Check if player lost (has trapped cards while opponent doesn't)
        local player_has_trapped = false
        local opponent_has_trapped = false
        
        for _, card in ipairs(game_ref.hand.player_cards) do
            if card.type == "trapped" then
                player_has_trapped = true
                break
            end
        end
        
        for _, card in ipairs(game_ref.hand.opponent_cards) do
            if card.type == "trapped" then
                opponent_has_trapped = true
                break
            end
        end
        
        if player_has_trapped and not opponent_has_trapped then
            print("DEBUG: PLAYER LOST - has trapped cards while opponent doesn't!")
            Round.startLossAnimation()
        end
    else
        print("DEBUG: Rule application failed")
    end
end

function Round.dealNewHand()
    print("DEBUG: Round.dealNewHand() called")
    print("DEBUG: Current trap rules before new hand:", #game_ref.run.trap_rules)
    
    -- Return cards to decks
    returnCardsToDeck()
    shuffleDeck(game_ref.run.player_deck)
    shuffleDeck(game_ref.run.opponent_deck)
    
    -- Deal new hand
    print("DEBUG: About to call dealHand() from Round.dealNewHand()")
    dealHand()
    print("DEBUG: dealHand() completed from Round.dealNewHand()")
    
    -- Clear selections
    game_ref.hand.selected_cards = {}
    selected_rule = nil
    
    print("DEBUG: New hand dealt, checking immediate win/lose conditions...")
    
    -- Update cached win condition
    Round.updateWinCondition()
    
    -- Check if opponent wins (player has trapped cards, opponent doesn't)
    local player_has_trapped = false
    local opponent_has_trapped = false
    
    for _, card in ipairs(game_ref.hand.player_cards) do
        if card.type == "trapped" then
            player_has_trapped = true
            break
        end
    end
    
    for _, card in ipairs(game_ref.hand.opponent_cards) do
        if card.type == "trapped" then
            opponent_has_trapped = true
            break
        end
    end
    
    print("DEBUG: After new hand - Player trapped:", player_has_trapped, "Opponent trapped:", opponent_has_trapped)
    
    if player_has_trapped and not opponent_has_trapped then
        print("DEBUG: GAME OVER - Player lost!")
        Round.startLossAnimation()
    end
end

return Round
