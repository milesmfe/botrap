local upgrades = {}

-- Upgrade definitions - organized by rarity
upgrades.upgrade_types = {
    common = {
        {
            name = "Extra Aces",
            description = "Add 2 additional Aces to your deck",
            type = "deck_add",
            effect = {cards = {{"hearts", "A"}, {"spades", "A"}}},
            rarity = "common"
        },
        {
            name = "Remove Twos", 
            description = "Remove all 2s from your deck",
            type = "deck_remove",
            effect = {rank = "2"},
            rarity = "common"
        }
    },
    rare = {
        {
            name = "Golden Start",
            description = "Start each hand with gold protection on a random card",
            type = "rule_bonus",
            effect = {auto_gold = true},
            rarity = "rare"
        },
        {
            name = "Opponent Handicap",
            description = "Opponent starts with 4 cards instead of 5",
            type = "opponent_nerf",
            effect = {hand_size = -1},
            rarity = "rare"
        }
    },
    epic = {
        {
            name = "Face Card Ban",
            description = "Remove all face cards from opponent's deck",
            type = "opponent_deck_remove", 
            effect = {ranks = {"J", "Q", "K"}},
            rarity = "epic"
        }
    }
}

-- Get random upgrades for selection
function upgrades.get_random_upgrades(count, round)
    local available_upgrades = {}
    
    -- Collect all upgrades based on rarity chances
    local rarity_chances = {
        common = 0.6,   -- 60% chance
        rare = 0.3,     -- 30% chance  
        epic = 0.1      -- 10% chance
    }
    
    -- Adjust rarity chances based on round (later rounds have better upgrades)
    if round >= 3 then
        rarity_chances.common = 0.4
        rarity_chances.rare = 0.4
        rarity_chances.epic = 0.2
    end
    if round >= 4 then
        rarity_chances.common = 0.2
        rarity_chances.rare = 0.5
        rarity_chances.epic = 0.3
    end
    
    -- Build pool of all available upgrades
    local upgrade_pool = {}
    for rarity, upgrades_list in pairs(upgrades.upgrade_types) do
        for _, upgrade in ipairs(upgrades_list) do
            table.insert(upgrade_pool, upgrade)
        end
    end
    
    -- Select random upgrades
    local selected = {}
    for i = 1, count do
        if #upgrade_pool == 0 then break end
        
        -- Roll for rarity
        local roll = math.random()
        local target_rarity = "common"
        
        if roll <= rarity_chances.epic then
            target_rarity = "epic"
        elseif roll <= rarity_chances.epic + rarity_chances.rare then
            target_rarity = "rare"
        end
        
        -- Find upgrades of target rarity
        local target_upgrades = {}
        for j, upgrade in ipairs(upgrade_pool) do
            if upgrade.rarity == target_rarity then
                table.insert(target_upgrades, {upgrade = upgrade, index = j})
            end
        end
        
        -- Fallback to any rarity if target not available
        if #target_upgrades == 0 then
            for j, upgrade in ipairs(upgrade_pool) do
                table.insert(target_upgrades, {upgrade = upgrade, index = j})
            end
        end
        
        if #target_upgrades > 0 then
            local choice = target_upgrades[math.random(#target_upgrades)]
            table.insert(selected, choice.upgrade)
            table.remove(upgrade_pool, choice.index)
        end
    end
    
    return selected
end

-- Apply upgrade effect
function upgrades.apply_upgrade(upgrade, game_state)
    local deck = require("deck")
    local rules = require("rules")
    
    if upgrade.type == "deck_add" then
        for _, card_def in ipairs(upgrade.effect.cards) do
            deck.add_card_to_player_deck(card_def[1], card_def[2])
        end
    elseif upgrade.type == "deck_remove" then
        deck.remove_cards_from_player_deck(upgrade.effect.rank)
    elseif upgrade.type == "opponent_nerf" then
        game_state.config.hand_size = game_state.config.hand_size + upgrade.effect.hand_size
    elseif upgrade.type == "opponent_deck_remove" then
        for _, rank in ipairs(upgrade.effect.ranks) do
            deck.remove_cards_from_opponent_deck(rank)
        end
    elseif upgrade.type == "rule_bonus" then
        if upgrade.effect.auto_gold then
            game_state.player_auto_gold = true
        end
    end
end

-- Apply all player upgrades
function upgrades.apply_all_upgrades(game_state)
    for _, upgrade in ipairs(game_state.player_upgrades) do
        upgrades.apply_upgrade(upgrade, game_state)
    end
end

return upgrades
