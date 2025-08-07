local deck = {}

deck.player_deck = {}
deck.opponent_deck = {}
deck.player_deck_position = {x = 0, y = 0}
deck.opponent_deck_position = {x = 0, y = 0}

function deck.load()
end

function deck.reset()
    local cards = require("cards")
    
    deck.player_deck = {}
    deck.opponent_deck = {}
    
    local suits = {"hearts", "diamonds", "clubs", "spades"}
    local ranks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            table.insert(deck.player_deck, cards.create_card(suit, rank))
            table.insert(deck.opponent_deck, cards.create_card(suit, rank))
        end
    end
    
    deck.shuffle_player_deck()
    deck.shuffle_opponent_deck()
end

function deck.shuffle_player_deck()
    for i = #deck.player_deck, 2, -1 do
        local j = math.random(i)
        deck.player_deck[i], deck.player_deck[j] = deck.player_deck[j], deck.player_deck[i]
    end
end

function deck.shuffle_opponent_deck()
    for i = #deck.opponent_deck, 2, -1 do
        local j = math.random(i)
        deck.opponent_deck[i], deck.opponent_deck[j] = deck.opponent_deck[j], deck.opponent_deck[i]
    end
end

function deck.deal_player_cards(count)
    local dealt_cards = {}
    for i = 1, count do
        if #deck.player_deck > 0 then
            table.insert(dealt_cards, table.remove(deck.player_deck, 1))
        end
    end
    return dealt_cards
end

function deck.deal_opponent_cards(count)
    local dealt_cards = {}
    for i = 1, count do
        if #deck.opponent_deck > 0 then
            table.insert(dealt_cards, table.remove(deck.opponent_deck, 1))
        end
    end
    return dealt_cards
end

function deck.can_deal_more(hand_size)
    return #deck.player_deck >= hand_size and #deck.opponent_deck >= hand_size
end

function deck.set_player_deck_position(x, y)
    deck.player_deck_position.x = x
    deck.player_deck_position.y = y
end

function deck.set_opponent_deck_position(x, y)
    deck.opponent_deck_position.x = x
    deck.opponent_deck_position.y = y
end

function deck.draw_decks()
    local cards = require("cards")
    
    -- Draw player deck (red back)
    if #deck.player_deck > 0 then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            cards.back_red,
            deck.player_deck_position.x,
            deck.player_deck_position.y,
            0,
            cards.SCALE,
            cards.SCALE
        )
        
        -- Draw count label with stylish background
        local font = love.graphics.newFont(16)
        love.graphics.setFont(font)
        local count_text = #deck.player_deck .. "/52"
        local text_width = font:getWidth(count_text)
        local label_x = deck.player_deck_position.x + (cards.get_display_width() - text_width) / 2
        local label_y = deck.player_deck_position.y - 35
        
        -- Label background
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", label_x - 5, label_y - 2, text_width + 10, 20, 5)
        
        -- Label text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(count_text, label_x, label_y)
    end
    
    -- Draw opponent deck (blue back)
    if #deck.opponent_deck > 0 then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            cards.back_blue,
            deck.opponent_deck_position.x,
            deck.opponent_deck_position.y,
            0,
            cards.SCALE,
            cards.SCALE
        )
        
        -- Draw count label with stylish background
        local font = love.graphics.newFont(16)
        love.graphics.setFont(font)
        local count_text = #deck.opponent_deck .. "/52"
        local text_width = font:getWidth(count_text)
        local label_x = deck.opponent_deck_position.x + (cards.get_display_width() - text_width) / 2
        local label_y = deck.opponent_deck_position.y - 35
        
        -- Label background
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", label_x - 5, label_y - 2, text_width + 10, 20, 5)
        
        -- Label text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(count_text, label_x, label_y)
    end
end

function deck.get_player_deck_count()
    return #deck.player_deck
end

function deck.get_opponent_deck_count()
    return #deck.opponent_deck
end

return deck
