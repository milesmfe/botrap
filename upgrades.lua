-- Upgrade system definitions and logic
local Upgrades = {}

local upgrade_definitions = {
    -- Prison Guard upgrades
    {
        id = "prison_guard_common",
        name = "Prison Guard",
        description = "Convert 2 opponent cards to Trapped",
        type = "prison_guard",
        value = 2,
        rarity = "common"
    },
    {
        id = "prison_guard_uncommon",
        name = "Prison Guard",
        description = "Convert 4 opponent cards to Trapped",
        type = "prison_guard",
        value = 4,
        rarity = "uncommon"
    },
    {
        id = "prison_guard_rare",
        name = "Prison Guard",
        description = "Convert 8 opponent cards to Trapped",
        type = "prison_guard",
        value = 8,
        rarity = "rare"
    },
    {
        id = "prison_guard_trapcard",
        name = "Prison Guard",
        description = "Convert 16 opponent cards to Trapped",
        type = "prison_guard",
        value = 16,
        rarity = "trapcard"
    },
    
    -- King's Orders upgrades
    {
        id = "kings_orders_common",
        name = "King's Orders",
        description = "Convert 2 player cards to Gold",
        type = "kings_orders",
        value = 2,
        rarity = "common"
    },
    {
        id = "kings_orders_uncommon",
        name = "King's Orders",
        description = "Convert 4 player cards to Gold",
        type = "kings_orders",
        value = 4,
        rarity = "uncommon"
    },
    {
        id = "kings_orders_rare",
        name = "King's Orders",
        description = "Convert 8 player cards to Gold",
        type = "kings_orders",
        value = 8,
        rarity = "rare"
    },
    {
        id = "kings_orders_trapcard",
        name = "King's Orders",
        description = "Convert 16 player cards to Gold",
        type = "kings_orders",
        value = 16,
        rarity = "trapcard"
    },
    
    -- Rogue upgrades
    {
        id = "rogue_common",
        name = "Rogue",
        description = "Convert 2 player cards to Wild",
        type = "rogue",
        value = 2,
        rarity = "common"
    },
    {
        id = "rogue_uncommon",
        name = "Rogue",
        description = "Convert 4 player cards to Wild",
        type = "rogue",
        value = 4,
        rarity = "uncommon"
    },
    {
        id = "rogue_rare",
        name = "Rogue",
        description = "Convert 8 player cards to Wild",
        type = "rogue",
        value = 8,
        rarity = "rare"
    },
    {
        id = "rogue_trapcard",
        name = "Rogue",
        description = "Convert 16 player cards to Wild",
        type = "rogue",
        value = 16,
        rarity = "trapcard"
    }
}

local rarity_weights = {
    common = 100,
    uncommon = 50,
    rare = 20,
    trapcard = 5
}

local rarity_colors = {
    common = {0.8, 0.8, 0.8, 1},      -- Light gray
    uncommon = {0.3, 1, 0.3, 1},      -- Green
    rare = {0.3, 0.3, 1, 1},          -- Blue
    trapcard = {1, 0.5, 0, 1}         -- Orange
}

function Upgrades.generateUpgradeChoices(allowed_rarities)
    local available_upgrades = {}
    
    -- Filter upgrades by allowed rarities
    for _, upgrade in ipairs(upgrade_definitions) do
        for _, rarity in ipairs(allowed_rarities) do
            if upgrade.rarity == rarity then
                table.insert(available_upgrades, upgrade)
                break
            end
        end
    end
    
    -- Generate 3 random choices
    local choices = {}
    for i = 1, 3 do
        if #available_upgrades > 0 then
            local total_weight = 0
            for _, upgrade in ipairs(available_upgrades) do
                total_weight = total_weight + rarity_weights[upgrade.rarity]
            end
            
            local random_weight = math.random() * total_weight
            local current_weight = 0
            
            for j, upgrade in ipairs(available_upgrades) do
                current_weight = current_weight + rarity_weights[upgrade.rarity]
                if random_weight <= current_weight then
                    table.insert(choices, upgrade)
                    table.remove(available_upgrades, j)
                    break
                end
            end
        end
    end
    
    return choices
end

function Upgrades.getUpgradesByRarity(rarity)
    local upgrades = {}
    for _, upgrade in ipairs(upgrade_definitions) do
        if upgrade.rarity == rarity then
            table.insert(upgrades, upgrade)
        end
    end
    return upgrades
end

function Upgrades.getRandomUpgrade(rarity)
    local upgrades = Upgrades.getUpgradesByRarity(rarity)
    if #upgrades > 0 then
        return upgrades[math.random(#upgrades)]
    end
    return nil
end

function Upgrades.getRarityColor(rarity)
    return rarity_colors[rarity] or {1, 1, 1, 1}
end

function Upgrades.drawUpgrade(upgrade, x, y, w, h, selected)
    -- Background
    local bg_color = selected and {0.3, 0.3, 0.5, 1} or {0.2, 0.2, 0.2, 1}
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h)
    
    -- Rarity border
    love.graphics.setColor(Upgrades.getRarityColor(upgrade.rarity))
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setLineWidth(1)
    
    -- Text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    
    local text_y = y + 10
    love.graphics.printf(upgrade.name, x + 10, text_y, w - 20, "center")
    text_y = text_y + 30
    
    love.graphics.setColor(Upgrades.getRarityColor(upgrade.rarity))
    love.graphics.printf(upgrade.rarity:upper(), x + 10, text_y, w - 20, "center")
    text_y = text_y + 25
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(upgrade.description, x + 10, text_y, w - 20, "center")
end

return Upgrades
