-- Modern Card System - Bouncy animations and colorful effects

local cards = {}

-- Card constants
cards.ASSET_WIDTH = 256
cards.ASSET_HEIGHT = 384
cards.SCALE = 0.5 -- Cards will be 128x192
cards.ANIMATION_SPEED = 12.0
cards.BOUNCE_STRENGTH = 0.8
cards.HOVER_SCALE = 1.15
cards.SELECT_SCALE = 1.1

-- Card images
cards.images = {}
cards.back_blue = nil
cards.back_red = nil

function cards.load()
    print("Loading card assets...")
    
    -- Load card backs
    cards.back_blue = love.graphics.newImage("assets/cards/back_blue.png")
    cards.back_red = love.graphics.newImage("assets/cards/back_red.png")
    
    -- Load all card faces
    local suits = {"hearts", "diamonds", "clubs", "spades"}
    local ranks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local filename = rank .. "_of_" .. suit .. ".png"
            local filepath = "assets/cards/" .. filename
            cards.images[rank .. "_" .. suit] = love.graphics.newImage(filepath)
        end
    end
    
    print("Loaded " .. (52 + 2) .. " card images")
end

function cards.create_card(suit, rank)
    local card = {
        suit = suit,
        rank = rank,
        
        -- Position and animation
        x = 0,
        y = 0,
        target_x = 0,
        target_y = 0,
        scale = cards.SCALE,
        target_scale = cards.SCALE,
        rotation = 0,
        target_rotation = 0,
        
        -- State
        revealed = false,
        selected = false,
        hovered = false,
        
        -- Animation properties
        bounce_time = 0,
        bounce_intensity = 0,
        shake_time = 0,
        shake_intensity = 0,
        glow_time = 0,
        glow_intensity = 0,
        
        -- Color effects
        tint = {r = 1, g = 1, b = 1, a = 1},
        target_tint = {r = 1, g = 1, b = 1, a = 1},
        
        -- Physics-like animation
        velocity_x = 0,
        velocity_y = 0,
        spring_tension = 0.3,
        spring_damping = 0.7
    }
    
    return card
end

function cards.update_all(all_cards, dt)
    for _, card in ipairs(all_cards) do
        cards.update_card(card, dt)
    end
end

function cards.update_card(card, dt)
    -- Smooth spring-based position animation
    local dx = card.target_x - card.x
    local dy = card.target_y - card.y
    
    card.velocity_x = card.velocity_x + dx * card.spring_tension
    card.velocity_y = card.velocity_y + dy * card.spring_tension
    
    card.velocity_x = card.velocity_x * card.spring_damping
    card.velocity_y = card.velocity_y * card.spring_damping
    
    card.x = card.x + card.velocity_x * dt * cards.ANIMATION_SPEED
    card.y = card.y + card.velocity_y * dt * cards.ANIMATION_SPEED
    
    -- Scale animation with bounce
    local scale_diff = card.target_scale - card.scale
    card.scale = card.scale + scale_diff * dt * 10
    
    -- Rotation animation
    local rot_diff = card.target_rotation - card.rotation
    card.rotation = card.rotation + rot_diff * dt * 8
    
    -- Update bounce effect
    if card.bounce_time > 0 then
        card.bounce_time = card.bounce_time - dt
        card.bounce_intensity = card.bounce_intensity * 0.95
    end
    
    -- Update shake effect
    if card.shake_time > 0 then
        card.shake_time = card.shake_time - dt
        card.shake_intensity = card.shake_intensity * 0.92
    end
    
    -- Update glow effect
    if card.glow_time > 0 then
        card.glow_time = card.glow_time - dt
        card.glow_intensity = math.max(0, card.glow_intensity - dt * 2)
    end
    
    -- Color tint interpolation
    local tint_speed = dt * 6
    card.tint.r = card.tint.r + (card.target_tint.r - card.tint.r) * tint_speed
    card.tint.g = card.tint.g + (card.target_tint.g - card.tint.g) * tint_speed
    card.tint.b = card.tint.b + (card.target_tint.b - card.tint.b) * tint_speed
    card.tint.a = card.tint.a + (card.target_tint.a - card.tint.a) * tint_speed
end

function cards.draw_card(card)
    love.graphics.push()
    
    -- Apply shake effect
    local shake_x = 0
    local shake_y = 0
    if card.shake_time > 0 then
        shake_x = (math.random() - 0.5) * card.shake_intensity * 4
        shake_y = (math.random() - 0.5) * card.shake_intensity * 4
    end
    
    -- Position and rotation
    love.graphics.translate(card.x + shake_x, card.y + shake_y)
    love.graphics.translate(cards.get_display_width() / 2, cards.get_display_height() / 2)
    love.graphics.rotate(card.rotation)
    
    -- Scale with bounce effect
    local bounce_scale = 1
    if card.bounce_time > 0 then
        bounce_scale = 1 + math.sin(card.bounce_time * 15) * card.bounce_intensity * 0.2
    end
    
    local final_scale = card.scale * bounce_scale
    love.graphics.scale(final_scale, final_scale)
    love.graphics.translate(-cards.ASSET_WIDTH / 2, -cards.ASSET_HEIGHT / 2)
    
    -- Check if card has gold protection or violations for visual effects
    local game_state = require("game_state")
    local rules = require("rules")
    local is_gold_protected = false
    local is_violating = false
    
    -- Check for gold protection
    for _, rule in ipairs(rules.get_active_rules()) do
        if rule.type == "gold" and card.rank == rule.value then
            is_gold_protected = true
            break
        end
    end
    
    -- Check for violations (only if not gold protected)
    if not is_gold_protected then
        local player_hand = game_state.get_player_hand()
        local opponent_hand = game_state.get_opponent_hand()
        local hand = nil
        
        -- Find which hand this card belongs to
        for _, hand_card in ipairs(player_hand) do
            if hand_card == card then
                hand = player_hand
                break
            end
        end
        if not hand then
            for _, hand_card in ipairs(opponent_hand) do
                if hand_card == card then
                    hand = opponent_hand
                    break
                end
            end
        end
        
        if hand then
            is_violating = cards.is_violating_rules(card, hand)
        end
    end
    
    -- Glow effect for selected/hovered cards
    if card.selected or card.hovered or card.glow_time > 0 then
        local glow_color = {1, 1, 0.3, 0.6} -- Golden glow
        if card.selected then
            glow_color = {0.3, 1, 0.3, 0.8} -- Green glow for selected
        end
        if card.glow_time > 0 then
            glow_color[4] = card.glow_intensity
        end
        
        love.graphics.setColor(glow_color)
        -- Draw glow effect (slightly larger)
        love.graphics.draw(cards.get_card_image(card), -4, -4, 0, 1.02, 1.02)
    end
    
    -- Set card tint (gold if protected, dim if violating)
    local tint_multiplier = is_violating and 0.4 or 1.0
    local gold_tint = is_gold_protected and {r = 1.0, g = 0.9, b = 0.3} or {r = 1.0, g = 1.0, b = 1.0}
    
    love.graphics.setColor(
        card.tint.r * tint_multiplier * gold_tint.r, 
        card.tint.g * tint_multiplier * gold_tint.g, 
        card.tint.b * tint_multiplier * gold_tint.b, 
        card.tint.a
    )
    
    -- Draw the actual card
    love.graphics.draw(cards.get_card_image(card), 0, 0)
    
    love.graphics.pop()
end

function cards.get_card_image(card)
    if card.revealed then
        return cards.images[card.rank .. "_" .. card.suit]
    else
        -- Use blue back for opponent cards
        return cards.back_blue
    end
end

function cards.set_target_position(card, x, y)
    card.target_x = x
    card.target_y = y
    -- Store original position for hover effects
    if not card.original_y then
        card.original_y = y
    end
end

function cards.set_revealed(card, revealed)
    card.revealed = revealed
    if revealed then
        cards.add_glow_effect(card, 0.5, 0.8)
    end
end

function cards.set_selected(card, selected)
    card.selected = selected
    if selected then
        card.target_scale = cards.SCALE * cards.SELECT_SCALE
        card.target_tint = {r = 1.2, g = 1.2, b = 0.8, a = 1}
        cards.add_bounce_effect(card)
    else
        card.target_scale = cards.SCALE
        card.target_tint = {r = 1, g = 1, b = 1, a = 1}
        -- Reset to original position if hovering is disabled
        if not card.hovered and card.original_y then
            card.target_y = card.original_y
        end
    end
end

function cards.set_hovered(card, hovered)
    card.hovered = hovered
    if hovered then
        card.target_scale = cards.SCALE * cards.HOVER_SCALE
        -- Store original position if not already stored
        if not card.original_y then
            card.original_y = card.target_y
        end
        card.target_y = card.original_y - 10 -- Slight lift
    else
        card.target_scale = cards.SCALE
        -- Reset to original position
        if card.original_y then
            card.target_y = card.original_y
        end
    end
end

function cards.add_bounce_effect(card)
    card.bounce_time = 0.8
    card.bounce_intensity = cards.BOUNCE_STRENGTH
end

function cards.add_shake_effect(card, intensity, duration)
    card.shake_time = duration or 0.5
    card.shake_intensity = intensity or 1.0
end

function cards.add_glow_effect(card, intensity, duration)
    card.glow_time = duration or 1.0
    card.glow_intensity = intensity or 1.0
end

function cards.contains_point(card, x, y)
    local card_width = cards.get_display_width()
    local card_height = cards.get_display_height()
    
    return x >= card.x and x <= card.x + card_width and
           y >= card.y and y <= card.y + card_height
end

function cards.is_selected(card)
    return card.selected
end

function cards.is_violating_rules(card, hand)
    local rules = require("rules")
    local violations = {}
    
    -- Check each active rule against this specific card
    for _, rule in ipairs(rules.get_active_rules()) do
        if rule.type == "suit" and card.suit == rule.value then
            table.insert(violations, rule)
        elseif rule.type == "rank" and card.rank == rule.value then
            table.insert(violations, rule)
        elseif rule.type == "mix" and type(rule.value) == "table" then
            -- For mix rules, check if hand has both forbidden suits and this card is one of them
            local has_other_suit = false
            for _, other_card in ipairs(hand) do
                if other_card ~= card then
                    if (card.suit == rule.value[1] and other_card.suit == rule.value[2]) or
                       (card.suit == rule.value[2] and other_card.suit == rule.value[1]) then
                        has_other_suit = true
                        break
                    end
                end
            end
            if has_other_suit and (card.suit == rule.value[1] or card.suit == rule.value[2]) then
                table.insert(violations, rule)
            end
        end
    end
    
    -- Check if gold rule protects this card
    for _, rule in ipairs(rules.get_active_rules()) do
        if rule.type == "gold" and card.rank == rule.value then
            return false -- Gold protects this card
        end
    end
    
    return #violations > 0
end

function cards.get_display_width()
    return cards.ASSET_WIDTH * cards.SCALE
end

function cards.get_display_height()
    return cards.ASSET_HEIGHT * cards.SCALE
end

return cards
