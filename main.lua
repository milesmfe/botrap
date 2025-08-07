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
        hand_size = 5,
        base_hand_size = 5
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
    print("DEBUG: Starting new run...")
    
    -- Reset run state
    game.run.current_round = 1
    game.run.trap_rules = {}
    game.run.gold_card = nil
    game.run.player_upgrades = {}
    game.run.opponent_upgrades = {}
    
    -- Create fresh decks
    createStandardDeck(game.run.player_deck)
    createStandardDeck(game.run.opponent_deck)
    print("DEBUG: Created fresh decks - Player:", #game.run.player_deck, "Opponent:", #game.run.opponent_deck)
    
    -- Load first opponent
    game.run.current_opponent = Opponents.getOpponent(1)
    game.run.opponent_upgrades = Opponents.getOpponentUpgrades(game.run.current_opponent)
    print("DEBUG: First opponent loaded:", game.run.current_opponent.name, "with", #game.run.opponent_upgrades, "upgrades")
    
    -- Apply opponent upgrades to opponent deck
    applyUpgradesToDeck(game.run.opponent_upgrades, game.run.opponent_deck)
    
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
            table.insert(deck, {
                suit = suit, 
                rank = rank, 
                type = "normal",
                permanent_type = "normal"  -- Track permanent modifications separate from temporary ones
            })
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
    print("DEBUG: Dealing new hand...")
    
    -- Clear current hands
    game.hand.player_cards = {}
    game.hand.opponent_cards = {}
    game.hand.selected_cards = {}
    
    -- Calculate hand size based on opponent
    local current_hand_size = game.hand.base_hand_size
    if game.run.current_opponent and game.run.current_opponent.increases_hand_size then
        current_hand_size = current_hand_size + game.run.current_opponent.level
        print("DEBUG: Opponent", game.run.current_opponent.name, "increases hand size by", game.run.current_opponent.level)
    end
    game.hand.hand_size = current_hand_size
    print("DEBUG: Hand size for this hand:", game.hand.hand_size)
    
    -- Deal cards
    for i = 1, game.hand.hand_size do
        if #game.run.player_deck > 0 then
            local card = table.remove(game.run.player_deck, 1)
            table.insert(game.hand.player_cards, card)
        end
        if #game.run.opponent_deck > 0 then
            local card = table.remove(game.run.opponent_deck, 1)
            table.insert(game.hand.opponent_cards, card)
        end
    end
    
    print("DEBUG: Cards dealt. Player deck remaining:", #game.run.player_deck, "Opponent deck remaining:", #game.run.opponent_deck)
    
    -- Apply current trap rules to dealt cards (includes gold rule logic)
    applyTrapRulesToHand()
    
    print("DEBUG: Hand dealing complete")
end

function applyTrapRulesToHand()
    print("DEBUG: Applying trap rules to hand...")
    print("DEBUG: Current trap rules count:", #game.run.trap_rules)
    
    -- First, check for gold cards and mark them
    local player_has_gold = false
    local opponent_has_gold = false
    
    if game.run.gold_card then
        -- Check player hand for gold cards
        for i, card in ipairs(game.hand.player_cards) do
            if card.suit == game.run.gold_card.suit and card.rank == game.run.gold_card.rank then
                card.type = "gold"
                player_has_gold = true
                print("DEBUG: Player card", i, "("..card.rank.." of "..card.suit..") is GOLD")
            end
        end
        
        -- Check opponent hand for gold cards
        for i, card in ipairs(game.hand.opponent_cards) do
            if card.suit == game.run.gold_card.suit and card.rank == game.run.gold_card.rank then
                card.type = "gold"
                opponent_has_gold = true
                print("DEBUG: Opponent card", i, "("..card.rank.." of "..card.suit..") is GOLD")
            end
        end
    end
    
    -- Apply trap rules to player hand only if they don't have gold
    if not player_has_gold then
        print("DEBUG: Applying trap rules to player hand")
        for i, card in ipairs(game.hand.player_cards) do
            if card.type ~= "gold" then
                if card.permanent_type ~= "normal" then
                    -- Keep permanent type from upgrades
                    card.type = card.permanent_type
                    print("DEBUG: Player card", i, "("..card.rank.." of "..card.suit..") keeps permanent type:", card.permanent_type)
                elseif isCardTrapped(card) then
                    card.type = "trapped"
                    print("DEBUG: Player card", i, "("..card.rank.." of "..card.suit..") became TRAPPED")
                else
                    card.type = "normal"
                end
            end
        end
    else
        print("DEBUG: Player has gold card - skipping trap rules for player hand")
        for i, card in ipairs(game.hand.player_cards) do
            if card.type ~= "gold" then
                card.type = "normal"
            end
        end
    end
    
    -- Apply trap rules to opponent hand only if they don't have gold
    if not opponent_has_gold then
        print("DEBUG: Applying trap rules to opponent hand")
        for i, card in ipairs(game.hand.opponent_cards) do
            if card.type ~= "gold" then
                if card.permanent_type ~= "normal" then
                    -- Keep permanent type from upgrades
                    card.type = card.permanent_type
                    print("DEBUG: Opponent card", i, "("..card.rank.." of "..card.suit..") keeps permanent type:", card.permanent_type)
                elseif isCardTrapped(card) then
                    card.type = "trapped"
                    print("DEBUG: Opponent card", i, "("..card.rank.." of "..card.suit..") became TRAPPED")
                else
                    card.type = "normal"
                end
            end
        end
    else
        print("DEBUG: Opponent has gold card - skipping trap rules for opponent hand")
        for i, card in ipairs(game.hand.opponent_cards) do
            if card.type ~= "gold" then
                card.type = "normal"
            end
        end
    end
end

function isCardTrapped(card)
    for i, rule in ipairs(game.run.trap_rules) do
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

function applyTrapRule(rule_type, selected_cards)
    print("DEBUG: Applying trap rule:", rule_type, "with", #selected_cards, "selected cards")
    
    local rule = {type = rule_type}
    
    if rule_type == "suit" and #selected_cards == 1 then
        rule.value = selected_cards[1].suit
        print("DEBUG: Adding suit trap rule for:", rule.value)
    elseif rule_type == "rank" and #selected_cards == 1 then
        rule.value = selected_cards[1].rank
        print("DEBUG: Adding rank trap rule for:", rule.value)
    elseif rule_type == "suit_match" and #selected_cards == 2 then
        rule.value = {selected_cards[1].suit, selected_cards[2].suit}
        print("DEBUG: Adding suit match trap rule for:", rule.value[1], "+", rule.value[2])
    elseif rule_type == "rank_match" and #selected_cards == 2 then
        rule.value = {selected_cards[1].rank, selected_cards[2].rank}
        print("DEBUG: Adding rank match trap rule for:", rule.value[1], "+", rule.value[2])
    elseif rule_type == "gold" and #selected_cards == 1 then
        game.run.gold_card = {suit = selected_cards[1].suit, rank = selected_cards[1].rank}
        print("DEBUG: Setting gold card to:", game.run.gold_card.rank, "of", game.run.gold_card.suit)
        
        -- Return cards to deck, reshuffle, and deal new hand for gold rule
        print("DEBUG: Gold rule applied - returning cards to deck and dealing new hand")
        returnCardsToDeck()
        shuffleDeck(game.run.player_deck)
        shuffleDeck(game.run.opponent_deck)
        dealHand()
        return true
    else
        print("DEBUG: Invalid rule application - rule_type:", rule_type, "selected_cards:", #selected_cards)
        return false
    end
    
    table.insert(game.run.trap_rules, rule)
    print("DEBUG: Total trap rules now:", #game.run.trap_rules)
    
    -- Return cards to deck, reshuffle, and deal new hand after applying trap rule
    print("DEBUG: Trap rule applied - returning cards to deck and dealing new hand")
    returnCardsToDeck()
    shuffleDeck(game.run.player_deck)
    shuffleDeck(game.run.opponent_deck)
    dealHand()
    
    return true
end

function checkWinCondition()
    -- Check if player hand has gold card
    local player_has_gold = false
    if game.run.gold_card then
        for _, card in ipairs(game.hand.player_cards) do
            if card.suit == game.run.gold_card.suit and card.rank == game.run.gold_card.rank then
                player_has_gold = true
                break
            end
        end
    end
    
    -- Check if opponent hand has gold card
    local opponent_has_gold = false
    if game.run.gold_card then
        for _, card in ipairs(game.hand.opponent_cards) do
            if card.suit == game.run.gold_card.suit and card.rank == game.run.gold_card.rank then
                opponent_has_gold = true
                break
            end
        end
    end
    
    -- Count effective trapped cards (gold immunity overrides trapped status)
    local player_has_trapped = false
    local opponent_has_trapped = false
    
    -- Player trapped cards count only if they don't have gold immunity
    if not player_has_gold then
        for i, card in ipairs(game.hand.player_cards) do
            if card.type == "trapped" then
                player_has_trapped = true
                break
            end
        end
    end
    
    -- Opponent trapped cards count only if they don't have gold immunity
    if not opponent_has_gold then
        for i, card in ipairs(game.hand.opponent_cards) do
            if card.type == "trapped" then
                opponent_has_trapped = true
                break
            end
        end
    end
    
    local can_win = not player_has_trapped and opponent_has_trapped
    if can_win then
        print("DEBUG: WIN CONDITION MET - Opponent has trapped cards, player doesn't!")
        if player_has_gold then
            print("DEBUG: Player immune due to gold card")
        end
        if opponent_has_gold then
            print("DEBUG: Opponent should be immune due to gold card - this shouldn't happen!")
        end
    else
        print("DEBUG: Win condition not met - Player trapped:", player_has_trapped, "Opponent trapped:", opponent_has_trapped)
        if player_has_gold then
            print("DEBUG: Player has gold immunity")
        end
        if opponent_has_gold then
            print("DEBUG: Opponent has gold immunity")
        end
    end
    
    return can_win
end

function nextRound()
    print("DEBUG: nextRound() called - current round:", game.run.current_round)
    
    game.run.current_round = game.run.current_round + 1
    
    if game.run.current_round > 13 then
        -- Player wins the run
        print("DEBUG: Player completed all 13 rounds - RUN WON!")
        game.run.wins = game.run.wins + 1
        changeScene("end")
        return
    end
    
    print("DEBUG: Advancing to round", game.run.current_round)
    
    -- Reset round state
    game.run.trap_rules = {}
    game.run.gold_card = nil
    game.hand.hand_size = game.hand.base_hand_size
    print("DEBUG: Round state reset - trap rules cleared, gold card cleared")
    
    -- Return player cards to player deck (preserve player upgrades)
    for i, card in ipairs(game.hand.player_cards) do
        card.type = card.permanent_type  -- Restore permanent type (from upgrades)
        table.insert(game.run.player_deck, card)
    end
    game.hand.player_cards = {}
    
    -- Don't return opponent cards - they belong to the previous opponent
    game.hand.opponent_cards = {}
    
    -- Load new opponent and create fresh deck
    game.run.current_opponent = Opponents.getOpponent(game.run.current_round)
    game.run.opponent_upgrades = Opponents.getOpponentUpgrades(game.run.current_opponent)
    print("DEBUG: New opponent loaded:", game.run.current_opponent.name, "with", #game.run.opponent_upgrades, "upgrades")
    
    -- Create fresh opponent deck for new opponent
    createStandardDeck(game.run.opponent_deck)
    
    -- Apply new opponent's upgrades to fresh deck
    applyUpgradesToDeck(game.run.opponent_upgrades, game.run.opponent_deck)
    
    -- Shuffle both decks
    shuffleDeck(game.run.player_deck)
    shuffleDeck(game.run.opponent_deck)
    print("DEBUG: Cards returned to decks and reshuffled")
    
    changeScene("locker")
end

function returnCardsToDeck()
    print("DEBUG: Returning cards to decks...")
    
    -- Return player cards and restore their permanent types
    for i, card in ipairs(game.hand.player_cards) do
        card.type = card.permanent_type  -- Restore permanent type (from upgrades)
        table.insert(game.run.player_deck, card)
    end
    
    -- Return opponent cards and restore their permanent types
    for i, card in ipairs(game.hand.opponent_cards) do
        card.type = card.permanent_type  -- Restore permanent type (from upgrades)
        table.insert(game.run.opponent_deck, card)
    end
    
    game.hand.player_cards = {}
    game.hand.opponent_cards = {}
    
    print("DEBUG: All cards returned. Player deck size:", #game.run.player_deck, "Opponent deck size:", #game.run.opponent_deck)
end

function applyUpgrade(upgrade)
    print("DEBUG: Applying upgrade:", upgrade.name, "type:", upgrade.type, "value:", upgrade.value)
    table.insert(game.run.player_upgrades, upgrade)
    
    if upgrade.type == "prison_guard" then
        print("DEBUG: Applying Prison Guard upgrade to opponent deck")
        applyPrisonGuardUpgrade(upgrade.value, game.run.opponent_deck)
    elseif upgrade.type == "kings_orders" then
        print("DEBUG: Applying King's Orders upgrade to player deck")
        applyKingsOrdersUpgrade(upgrade.value, game.run.player_deck)
    elseif upgrade.type == "rogue" then
        print("DEBUG: Applying Rogue upgrade to player deck")
        applyRogueUpgrade(upgrade.value, game.run.player_deck)
    else
        print("DEBUG: Unknown upgrade type:", upgrade.type)
    end
    
    print("DEBUG: Player now has", #game.run.player_upgrades, "upgrades")
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
    print("DEBUG: applyPrisonGuardUpgrade called - converting", count, "cards to trapped in deck of size", #deck)
    local converted = 0
    for i, card in ipairs(deck) do
        if card.permanent_type == "normal" and converted < count then
            card.permanent_type = "trapped"
            card.type = "trapped"
            converted = converted + 1
            print("DEBUG: Converted card", i, "("..card.rank.." of "..card.suit..") to permanently trapped")
        end
    end
    print("DEBUG: Prison Guard upgrade complete - converted", converted, "cards to trapped")
end

function applyKingsOrdersUpgrade(count, deck)
    print("DEBUG: applyKingsOrdersUpgrade called - converting", count, "cards to gold in deck of size", #deck)
    local converted = 0
    for _, card in ipairs(deck) do
        if card.permanent_type == "normal" and converted < count then
            card.permanent_type = "gold"
            card.type = "gold"
            converted = converted + 1
            print("DEBUG: Converted card ("..card.rank.." of "..card.suit..") to permanently gold")
        end
    end
    print("DEBUG: King's Orders upgrade complete - converted", converted, "cards to gold")
end

function applyRogueUpgrade(count, deck)
    print("DEBUG: applyRogueUpgrade called - converting", count, "cards to wild in deck of size", #deck)
    local converted = 0
    for _, card in ipairs(deck) do
        if card.permanent_type == "normal" and converted < count then
            card.permanent_type = "wild"
            card.type = "wild"
            card.suit = "wild"
            card.rank = "wild"
            converted = converted + 1
            print("DEBUG: Converted card to permanently wild")
        end
    end
    print("DEBUG: Rogue upgrade complete - converted", converted, "cards to wild")
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
