-- Round scene - Core gameplay interface
local Round = {}
local Card = require("card")

local game_ref
local ui_elements = {}
local rule_buttons = {}
local selected_rule = nil

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
    dealHand()
    selected_rule = nil
end

function Round.update(dt)
    -- No continuous updates needed for round scene
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
    
    -- Draw UI elements
    Round.drawRuleButtons()
    Round.drawActionButtons()
    
    -- Draw selection info
    Round.drawSelectionInfo()
end

function Round.drawRoundInfo()
    love.graphics.setFont(game_ref.ui.font_medium)
    love.graphics.setColor(1, 1, 1, 1)
    drawFloatingText("Round " .. game_ref.run.current_round .. " / 13", 20, 20, game_ref.ui.font_medium)
    
    if game_ref.run.current_opponent then
        drawFloatingText("vs " .. game_ref.run.current_opponent.name, 20, 50, game_ref.ui.font_small)
    end
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
        Card.draw(card, x, y, false, false, selected)
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
    local can_botrap = checkWinCondition()
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
    if button == 1 then  -- Left click
        -- Check card selections
        Round.checkCardClick(x, y)
        
        -- Check rule buttons
        for _, rule_button in ipairs(rule_buttons) do
            if isPointInRect(x, y, rule_button.x, rule_button.y, rule_button.w, rule_button.h) then
                local selected_count = #game_ref.hand.selected_cards
                if selected_count >= rule_button.min_cards and selected_count <= rule_button.max_cards then
                    if rule_button.rule == "gold" and game_ref.run.gold_card then
                        -- Gold already used this round
                    else
                        selected_rule = rule_button.rule
                    end
                end
                break
            end
        end
        
        -- Check action buttons
        local apply_button = ui_elements.apply_button
        if isPointInRect(x, y, apply_button.x, apply_button.y, apply_button.w, apply_button.h) then
            Round.applySelectedRule()
        end
        
        local botrap_button = ui_elements.botrap_button
        if isPointInRect(x, y, botrap_button.x, botrap_button.y, botrap_button.w, botrap_button.h) then
            if checkWinCondition() then
                nextRound()
            end
        end
        
        local new_hand_button = ui_elements.new_hand_button
        if isPointInRect(x, y, new_hand_button.x, new_hand_button.y, new_hand_button.w, new_hand_button.h) then
            Round.dealNewHand()
        end
    end
end

function Round.checkCardClick(x, y)
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
    
    -- Check opponent hand
    area_y = 300
    for i, card in ipairs(game_ref.hand.opponent_cards) do
        local card_x, card_y, card_w, card_h = Card.getCardBounds(i, #game_ref.hand.opponent_cards, area_x, area_y, area_w, area_h)
        if Card.isPointInCard(x, y, card_x, card_y) then
            Round.toggleCardSelection(card, "opponent", i)
            return
        end
    end
end

function Round.toggleCardSelection(card, hand_type, index)
    -- Check if already selected
    for i, selected in ipairs(game_ref.hand.selected_cards) do
        if selected.hand == hand_type and selected.index == index then
            table.remove(game_ref.hand.selected_cards, i)
            return
        end
    end
    
    -- Add to selection
    table.insert(game_ref.hand.selected_cards, {
        card = card,
        hand = hand_type,
        index = index
    })
end

function Round.applySelectedRule()
    if not selected_rule or #game_ref.hand.selected_cards == 0 then
        return
    end
    
    local cards = {}
    for _, selected in ipairs(game_ref.hand.selected_cards) do
        table.insert(cards, selected.card)
    end
    
    if applyTrapRule(selected_rule, cards) then
        game_ref.hand.selected_cards = {}
        selected_rule = nil
    end
end

function Round.dealNewHand()
    -- Return cards to decks
    returnCardsToDeck()
    shuffleDeck(game_ref.run.player_deck)
    shuffleDeck(game_ref.run.opponent_deck)
    
    -- Deal new hand
    dealHand()
    
    -- Clear selections
    game_ref.hand.selected_cards = {}
    selected_rule = nil
    
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
    
    if player_has_trapped and not opponent_has_trapped then
        gameOver()
    end
end

return Round
