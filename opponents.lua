-- Opponent definitions and logic
local Opponents = {}
local Upgrades = require("upgrades")

local opponent_definitions = {
    -- Level 1 opponents (rounds 1-3)
    {
        id = "rookie_guard",
        name = "Rookie Guard",
        level = 1,
        description = "A new guard learning the ropes",
        rounds = {1, 2, 3},
        increases_hand_size = false
    },
    {
        id = "street_dealer",
        name = "Street Dealer",
        level = 1,
        description = "A cunning card dealer from the streets",
        rounds = {1, 2, 3},
        increases_hand_size = true
    },
    
    -- Level 2 opponents (rounds 4-6)
    {
        id = "veteran_guard",
        name = "Veteran Guard",
        level = 2,
        description = "An experienced prison guard",
        rounds = {4, 5, 6},
        increases_hand_size = false
    },
    {
        id = "casino_boss",
        name = "Casino Boss",
        level = 2,
        description = "A seasoned casino owner",
        rounds = {4, 5, 6},
        increases_hand_size = true
    },
    
    -- Level 3 opponents (rounds 7-9)
    {
        id = "warden_assistant",
        name = "Warden's Assistant",
        level = 3,
        description = "The warden's right hand",
        rounds = {7, 8, 9},
        increases_hand_size = false
    },
    {
        id = "card_master",
        name = "Card Master",
        level = 3,
        description = "A master of card manipulation",
        rounds = {7, 8, 9},
        increases_hand_size = true
    },
    
    -- Level 4 opponents (rounds 10-12)
    {
        id = "prison_warden",
        name = "Prison Warden",
        level = 4,
        description = "The formidable prison warden",
        rounds = {10, 11, 12},
        increases_hand_size = false
    },
    {
        id = "trap_specialist",
        name = "Trap Specialist",
        level = 4,
        description = "An expert in trap mechanics",
        rounds = {10, 11, 12},
        increases_hand_size = true
    },
    
    -- Level 5 opponent (round 13)
    {
        id = "bo_trap",
        name = "Bo Trap",
        level = 5,
        description = "The legendary master of all traps",
        rounds = {13},
        increases_hand_size = false
    }
}

local level_upgrade_rarities = {
    [1] = {"common"},
    [2] = {"common", "uncommon"},
    [3] = {"uncommon", "rare"},
    [4] = {"rare"},
    [5] = {"rare", "trapcard"}
}

function Opponents.getOpponent(round)
    -- Filter opponents available for this round
    local available_opponents = {}
    for _, opponent in ipairs(opponent_definitions) do
        for _, valid_round in ipairs(opponent.rounds) do
            if valid_round == round then
                table.insert(available_opponents, opponent)
                break
            end
        end
    end
    
    -- Return random opponent from available ones
    if #available_opponents > 0 then
        return available_opponents[math.random(#available_opponents)]
    end
    
    -- Fallback
    return opponent_definitions[1]
end

function Opponents.getOpponentUpgrades(opponent)
    if not opponent then return {} end
    
    local upgrades = {}
    local allowed_rarities = level_upgrade_rarities[opponent.level] or {"common"}
    
    -- First opponent has no upgrades
    if opponent.id == "rookie_guard" and opponent.rounds[1] == 1 then
        return upgrades
    end
    
    -- Bo Trap gets special upgrades
    if opponent.id == "bo_trap" then
        -- 1 rare + 2 trapcard upgrades
        local rare_upgrade = Upgrades.getRandomUpgrade("rare")
        if rare_upgrade then
            table.insert(upgrades, rare_upgrade)
        end
        
        for i = 1, 2 do
            local trapcard_upgrade = Upgrades.getRandomUpgrade("trapcard")
            if trapcard_upgrade then
                table.insert(upgrades, trapcard_upgrade)
            end
        end
    else
        -- Generate 3 random upgrades from allowed rarities
        for i = 1, 3 do
            local rarity = allowed_rarities[math.random(#allowed_rarities)]
            local upgrade = Upgrades.getRandomUpgrade(rarity)
            if upgrade then
                table.insert(upgrades, upgrade)
            end
        end
    end
    
    return upgrades
end

function Opponents.drawOpponent(opponent, x, y, w, h)
    if not opponent then return end
    
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.2, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0.3, 0.3, 0.4, 1)
    love.graphics.rectangle("line", x, y, w, h)
    
    -- Opponent portrait (placeholder colored rectangle)
    local portrait_size = math.min(w * 0.4, h * 0.5)
    local portrait_x = x + (w - portrait_size) / 2
    local portrait_y = y + 10
    
    local level_colors = {
        [1] = {0.5, 0.8, 0.5, 1},    -- Green
        [2] = {0.8, 0.8, 0.5, 1},    -- Yellow
        [3] = {0.8, 0.5, 0.5, 1},    -- Red
        [4] = {0.6, 0.3, 0.8, 1},    -- Purple
        [5] = {1, 0.5, 0, 1}         -- Orange (Bo Trap)
    }
    
    love.graphics.setColor(level_colors[opponent.level] or {0.5, 0.5, 0.5, 1})
    love.graphics.rectangle("fill", portrait_x, portrait_y, portrait_size, portrait_size)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", portrait_x, portrait_y, portrait_size, portrait_size)
    
    -- Opponent name
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    local text_y = portrait_y + portrait_size + 15
    love.graphics.printf(opponent.name, x + 5, text_y, w - 10, "center")
    
    -- Level indicator
    text_y = text_y + 25
    love.graphics.setColor(level_colors[opponent.level] or {0.5, 0.5, 0.5, 1})
    love.graphics.printf("Level " .. opponent.level, x + 5, text_y, w - 10, "center")
    
    -- Hand size increase indicator
    if opponent.increases_hand_size then
        text_y = text_y + 20
        love.graphics.setColor(1, 0.8, 0.3, 1)
        love.graphics.printf("+" .. opponent.level .. " Hand Size", x + 5, text_y, w - 10, "center")
    end
    
    -- Description
    text_y = text_y + 25
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf(opponent.description, x + 5, text_y, w - 10, "center")
end

return Opponents
