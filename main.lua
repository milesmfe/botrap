-- Botrap - Main game controller and state manager
local scene_menu = require("scenes/menu")
local scene_round = require("scenes/round")
local scene_locker = require("scenes/locker")
local scene_end = require("scenes/end")
local Card = require("card")
local Upgrades = require("upgrades")
local Opponents = require("opponents")

-- Game state
local game = {
    scene = "menu",
    run = {
        current_round = 1,
        player_deck = {},
        opponent_deck = {},
        current_opponent = nil,
        trap_rules = {},
        gold_card = nil,
        player_upgrades = {},
        opponent_upgrades = {},
        wins = 0,
        losses = 0
    },
    hand = {
        player_cards = {},
        opponent_cards = {},
        selected_cards = {},
        hand_size = 13
    },
    ui = {
        width = 1024,
        height = 768,
        font_large = nil,
        font_medium = nil,
        font_small = nil
    }
}

-- Animation system
local animations = {}
local time = 0

function love.load()
    love.window.setTitle("BOTRAP")
    love.window.setMode(game.ui.width, game.ui.height)
    
    -- Load fonts
    game.ui.font_large = love.graphics.newFont(36)
    game.ui.font_medium = love.graphics.newFont(24)
    game.ui.font_small = love.graphics.newFont(16)
    
    -- Initialize card system
    Card.init()
    
    -- Initialize scenes
    scene_menu.init(game)
    scene_round.init(game)
    scene_locker.init(game)
    scene_end.init(game)
    
    math.randomseed(os.time())
end

function love.update(dt)
    time = time + dt
    
    -- Update animations
    for i = #animations, 1, -1 do
        local anim = animations[i]
        anim.time = anim.time + dt
        if anim.time >= anim.duration then
            if anim.callback then
                anim.callback()
            end
            table.remove(animations, i)
        end
    end
    
    -- Update current scene
    if game.scene == "menu" then
        scene_menu.update(dt)
    elseif game.scene == "round" then
        scene_round.update(dt)
    elseif game.scene == "locker" then
        scene_locker.update(dt)
    elseif game.scene == "end" then
        scene_end.update(dt)
    end
end

function love.draw()
    -- Draw current scene
    if game.scene == "menu" then
        scene_menu.draw()
    elseif game.scene == "round" then
        scene_round.draw()
    elseif game.scene == "locker" then
        scene_locker.draw()
    elseif game.scene == "end" then
        scene_end.draw()
    end
end

function love.mousepressed(x, y, button)
    if game.scene == "menu" then
        scene_menu.mousepressed(x, y, button)
    elseif game.scene == "round" then
        scene_round.mousepressed(x, y, button)
    elseif game.scene == "locker" then
        scene_locker.mousepressed(x, y, button)
    elseif game.scene == "end" then
        scene_end.mousepressed(x, y, button)
    end
end

-- Global helper functions that scenes need access to
function isPointInRect(x, y, rect_x, rect_y, rect_w, rect_h)
    return x >= rect_x and x <= rect_x + rect_w and y >= rect_y and y <= rect_y + rect_h
end

function drawFloatingText(text, x, y, font, color)
    local offset_x = math.sin(time * 2) * 2
    local offset_y = math.cos(time * 1.5) * 1
    
    love.graphics.setFont(font)
    love.graphics.setColor(color or {1, 1, 1, 1})
    love.graphics.print(text, x + offset_x, y + offset_y)
end

-- Scene management
function changeScene(new_scene)
    game.scene = new_scene
    
    if new_scene == "round" then
        scene_round.enter()
    elseif new_scene == "locker" then
        scene_locker.enter()
    elseif new_scene == "end" then
        scene_end.enter()
    elseif new_scene == "menu" then
        scene_menu.enter()
    end
end

-- Game initialization
function startNewRun()
    -- Reset run state
    game.run.current_round = 1
    game.run.trap_rules = {}
    game.run.gold_card = nil
    game.run.player_upgrades = {}
    game.run.opponent_upgrades = {}
    
    -- Create fresh decks
    createStandardDeck(game.run.player_deck)
    createStandardDeck(game.run.opponent_deck)
    
    -- Load first opponent
    game.run.current_opponent = Opponents.getOpponent(1)
    game.run.opponent_upgrades = {}
    
    changeScene("round")
end

function createStandardDeck(deck)
    -- Clear existing deck
    for i = #deck, 1, -1 do
        deck[i] = nil
    end
    
    local suits = {"clubs", "diamonds", "hearts", "spades"}
    local ranks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            table.insert(deck, {suit = suit, rank = rank, type = "normal"})
        end
    end
    
    shuffleDeck(deck)
end

function shuffleDeck(deck)
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

function dealHand()
    -- Clear current hands
    game.hand.player_cards = {}
    game.hand.opponent_cards = {}
    game.hand.selected_cards = {}
    
    -- Deal cards
    for i = 1, game.hand.hand_size do
        if #game.run.player_deck > 0 then
            table.insert(game.hand.player_cards, table.remove(game.run.player_deck, 1))
        end
        if #game.run.opponent_deck > 0 then
            table.insert(game.hand.opponent_cards, table.remove(game.run.opponent_deck, 1))
        end
    end
    
    -- Apply current trap rules to dealt cards
    applyTrapRulesToHand()
    
    -- Apply gold rule if exists
    if game.run.gold_card then
        applyGoldRule()
    end
end

function applyTrapRulesToHand()
    -- Apply trap rules to player hand
    for _, card in ipairs(game.hand.player_cards) do
        if isCardTrapped(card) then
            card.type = "trapped"
        end
    end
    
    -- Apply trap rules to opponent hand
    for _, card in ipairs(game.hand.opponent_cards) do
        if isCardTrapped(card) then
            card.type = "trapped"
        end
    end
end

function isCardTrapped(card)
    for _, rule in ipairs(game.run.trap_rules) do
        if rule.type == "suit" and card.suit == rule.value then
            return true
        elseif rule.type == "rank" and card.rank == rule.value then
            return true
        elseif rule.type == "suit_match" then
            if (card.suit == rule.value[1] or card.suit == rule.value[2]) then
                return true
            end
        elseif rule.type == "rank_match" then
            if (card.rank == rule.value[1] or card.rank == rule.value[2]) then
                return true
            end
        end
    end
    return false
end

function applyGoldRule()
    -- Reset all trapped cards to normal
    for _, card in ipairs(game.hand.player_cards) do
        if card.type == "trapped" then
            card.type = "normal"
        end
    end
    
    for _, card in ipairs(game.hand.opponent_cards) do
        if card.type == "trapped" then
            card.type = "normal"
        end
    end
    
    -- Apply gold to matching cards
    for _, card in ipairs(game.hand.player_cards) do
        if card.suit == game.run.gold_card.suit and card.rank == game.run.gold_card.rank then
            card.type = "gold"
        end
    end
    
    for _, card in ipairs(game.hand.opponent_cards) do
        if card.suit == game.run.gold_card.suit and card.rank == game.run.gold_card.rank then
            card.type = "gold"
        end
    end
end

function applyTrapRule(rule_type, selected_cards)
    local rule = {type = rule_type}
    
    if rule_type == "suit" and #selected_cards == 1 then
        rule.value = selected_cards[1].suit
    elseif rule_type == "rank" and #selected_cards == 1 then
        rule.value = selected_cards[1].rank
    elseif rule_type == "suit_match" and #selected_cards == 2 then
        rule.value = {selected_cards[1].suit, selected_cards[2].suit}
    elseif rule_type == "rank_match" and #selected_cards == 2 then
        rule.value = {selected_cards[1].rank, selected_cards[2].rank}
    elseif rule_type == "gold" and #selected_cards == 1 then
        game.run.gold_card = {suit = selected_cards[1].suit, rank = selected_cards[1].rank}
        applyGoldRule()
        return
    else
        return false
    end
    
    table.insert(game.run.trap_rules, rule)
    applyTrapRulesToHand()
    return true
end

function checkWinCondition()
    local player_has_trapped = false
    local opponent_has_trapped = false
    
    for _, card in ipairs(game.hand.player_cards) do
        if card.type == "trapped" then
            player_has_trapped = true
            break
        end
    end
    
    for _, card in ipairs(game.hand.opponent_cards) do
        if card.type == "trapped" then
            opponent_has_trapped = true
            break
        end
    end
    
    return not player_has_trapped and opponent_has_trapped
end

function nextRound()
    game.run.current_round = game.run.current_round + 1
    
    if game.run.current_round > 13 then
        -- Player wins the run
        game.run.wins = game.run.wins + 1
        changeScene("end")
        return
    end
    
    -- Reset round state
    game.run.trap_rules = {}
    game.run.gold_card = nil
    
    -- Return all cards to decks and reshuffle
    returnCardsToDeck()
    shuffleDeck(game.run.player_deck)
    shuffleDeck(game.run.opponent_deck)
    
    -- Load new opponent
    game.run.current_opponent = Opponents.getOpponent(game.run.current_round)
    game.run.opponent_upgrades = Opponents.getOpponentUpgrades(game.run.current_opponent)
    
    -- Apply opponent upgrades to opponent deck
    applyUpgradesToDeck(game.run.opponent_upgrades, game.run.opponent_deck)
    
    changeScene("locker")
end

function returnCardsToDeck()
    -- Return player cards
    for _, card in ipairs(game.hand.player_cards) do
        card.type = "normal"
        table.insert(game.run.player_deck, card)
    end
    
    -- Return opponent cards
    for _, card in ipairs(game.hand.opponent_cards) do
        card.type = "normal"
        table.insert(game.run.opponent_deck, card)
    end
    
    game.hand.player_cards = {}
    game.hand.opponent_cards = {}
end

function applyUpgrade(upgrade)
    table.insert(game.run.player_upgrades, upgrade)
    
    if upgrade.type == "prison_guard" then
        applyPrisonGuardUpgrade(upgrade.value, game.run.opponent_deck)
    elseif upgrade.type == "kings_orders" then
        applyKingsOrdersUpgrade(upgrade.value, game.run.player_deck)
    elseif upgrade.type == "rogue" then
        applyRogueUpgrade(upgrade.value, game.run.player_deck)
    end
end

function applyUpgradesToDeck(upgrades, deck)
    for _, upgrade in ipairs(upgrades) do
        if upgrade.type == "prison_guard" then
            applyPrisonGuardUpgrade(upgrade.value, deck)
        elseif upgrade.type == "kings_orders" then
            applyKingsOrdersUpgrade(upgrade.value, deck)
        elseif upgrade.type == "rogue" then
            applyRogueUpgrade(upgrade.value, deck)
        end
    end
end

function applyPrisonGuardUpgrade(count, deck)
    local converted = 0
    for _, card in ipairs(deck) do
        if card.type == "normal" and converted < count then
            card.type = "trapped"
            converted = converted + 1
        end
    end
end

function applyKingsOrdersUpgrade(count, deck)
    local converted = 0
    for _, card in ipairs(deck) do
        if card.type == "normal" and converted < count then
            card.type = "gold"
            converted = converted + 1
        end
    end
end

function applyRogueUpgrade(count, deck)
    local converted = 0
    for _, card in ipairs(deck) do
        if card.type == "normal" and converted < count then
            card.type = "wild"
            card.suit = "wild"
            card.rank = "wild"
            converted = converted + 1
        end
    end
end

function gameOver()
    game.run.losses = game.run.losses + 1
    changeScene("end")
end

-- Animation helpers
function addAnimation(duration, callback)
    table.insert(animations, {
        time = 0,
        duration = duration,
        callback = callback
    })
end

function getTime()
    return time
end

-- Export game state for scenes
function getGame()
    return game
end
