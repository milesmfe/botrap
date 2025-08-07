-- Card rendering and animation system
local Card = {}

local card_images = {}
local card_width = 64
local card_height = 96

function Card.init()
    -- Load card images
    local suits = {"clubs", "diamonds", "hearts", "spades"}
    local ranks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    
    -- Load individual card faces
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local filename = "assets/cards/" .. rank .. "_of_" .. suit .. ".png"
            if love.filesystem.getInfo(filename) then
                card_images[rank .. "_" .. suit] = love.graphics.newImage(filename)
            end
        end
    end
    
    -- Load card backs
    if love.filesystem.getInfo("assets/cards/back_blue.png") then
        card_images.back_blue = love.graphics.newImage("assets/cards/back_blue.png")
    end
    if love.filesystem.getInfo("assets/cards/back_red.png") then
        card_images.back_red = love.graphics.newImage("assets/cards/back_red.png")
    end
end

function Card.draw(card, x, y, face_up, is_player_card, selected, scale)
    scale = scale or 1
    local w = card_width * scale
    local h = card_height * scale
    
    -- Determine card image
    local image
    if face_up then
        if card.type == "wild" then
            -- Draw wild card as gray rectangle
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
            love.graphics.rectangle("fill", x, y, w, h)
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("line", x, y, w, h)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("WILD", x, y + h/2 - 10, w, "center")
            return
        else
            local key = card.rank .. "_" .. card.suit
            image = card_images[key]
        end
    else
        image = is_player_card and card_images.back_blue or card_images.back_red
    end
    
    -- Apply tinting based on card type
    local tint = {1, 1, 1, 1}
    if face_up then
        if card.type == "trapped" then
            tint = {1, 0.7, 0.7, 1}  -- Red tint
        elseif card.type == "gold" then
            tint = {1, 1, 0.7, 1}    -- Yellow tint
        end
    end
    
    -- Selection highlight
    if selected then
        love.graphics.setColor(0.8, 0.8, 1, 1)
        love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4)
    end
    
    love.graphics.setColor(tint)
    
    if image then
        love.graphics.draw(image, x, y, 0, w / image:getWidth(), h / image:getHeight())
    else
        -- Fallback: draw colored rectangle with text
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("line", x, y, w, h)
        if face_up then
            love.graphics.printf(card.rank .. "\n" .. card.suit:sub(1,1):upper(), x, y + 10, w, "center")
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Card.drawDeck(deck, x, y, is_player_deck, scale)
    scale = scale or 0.5
    local w = card_width * scale
    local h = card_height * scale
    local offset = 2
    
    -- Draw stack effect
    for i = 1, math.min(#deck, 5) do
        local stack_x = x + (i - 1) * offset
        local stack_y = y + (i - 1) * offset
        
        love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
        love.graphics.rectangle("fill", stack_x, stack_y, w, h)
    end
    
    -- Draw top card
    if #deck > 0 then
        local image = is_player_deck and card_images.back_blue or card_images.back_red
        love.graphics.setColor(1, 1, 1, 1)
        
        if image then
            love.graphics.draw(image, x, y, 0, w / image:getWidth(), h / image:getHeight())
        else
            love.graphics.setColor(is_player_deck and {0.3, 0.3, 1, 1} or {1, 0.3, 0.3, 1})
            love.graphics.rectangle("fill", x, y, w, h)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", x, y, w, h)
        end
        
        -- Draw deck count
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(tostring(#deck), x, y + h + 5, w, "center")
    end
end

function Card.getCardBounds(index, total_cards, area_x, area_y, area_w, area_h)
    local spacing = math.min(80, area_w / total_cards)
    local start_x = area_x + (area_w - (total_cards - 1) * spacing - card_width) / 2
    local x = start_x + (index - 1) * spacing
    local y = area_y + (area_h - card_height) / 2
    
    return x, y, card_width, card_height
end

function Card.isPointInCard(point_x, point_y, card_x, card_y)
    return point_x >= card_x and point_x <= card_x + card_width and
           point_y >= card_y and point_y <= card_y + card_height
end

return Card
