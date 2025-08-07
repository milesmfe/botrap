-- Locker scene - Upgrade selection interface
local Locker = {}
local Upgrades = require("upgrades")

local game_ref
local upgrade_choices = {}
local selected_upgrade = nil

function Locker.init(game)
    game_ref = game
end

function Locker.enter()
    -- Generate upgrade choices based on current round
    local allowed_rarities = Locker.getAllowedRarities()
    upgrade_choices = Upgrades.generateUpgradeChoices(allowed_rarities)
    selected_upgrade = nil
end

function Locker.getAllowedRarities()
    local round = game_ref.run.current_round - 1  -- Previous round that was just completed
    
    if round <= 3 then
        return {"common"}
    elseif round <= 6 then
        return {"common", "uncommon"}
    elseif round <= 9 then
        return {"uncommon", "rare"}
    elseif round <= 12 then
        return {"rare"}
    else
        return {"rare", "trapcard"}
    end
end

function Locker.update(dt)
    -- No continuous updates needed
end

function Locker.draw()
    -- Background
    love.graphics.setColor(0.1, 0.05, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, game_ref.ui.width, game_ref.ui.height)
    
    -- Title
    love.graphics.setFont(game_ref.ui.font_large)
    love.graphics.setColor(1, 1, 1, 1)
    drawFloatingText("THE LOCKER", 0, 50, game_ref.ui.font_large, {1, 1, 1, 1})
    
    -- Subtitle
    love.graphics.setFont(game_ref.ui.font_medium)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    drawFloatingText("Choose Your Upgrade", 0, 100, game_ref.ui.font_medium, {0.8, 0.8, 0.8, 1})
    
    -- Round completion message
    love.graphics.setFont(game_ref.ui.font_small)
    love.graphics.setColor(0.6, 1, 0.6, 1)
    local completion_text = "Round " .. (game_ref.run.current_round - 1) .. " Complete!"
    drawFloatingText(completion_text, 0, 150, game_ref.ui.font_small, {0.6, 1, 0.6, 1})
    
    -- Draw upgrade choices
    Locker.drawUpgradeChoices()
    
    -- Draw continue button
    Locker.drawContinueButton()
    
    -- Draw instructions
    love.graphics.setFont(game_ref.ui.font_small)
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    drawFloatingText("Click an upgrade to select it, then continue to next round", 0, game_ref.ui.height - 50, game_ref.ui.font_small, {0.7, 0.7, 0.7, 1})
end

function Locker.drawUpgradeChoices()
    local upgrade_width = 200
    local upgrade_height = 150
    local spacing = 50
    local total_width = (#upgrade_choices * upgrade_width) + ((#upgrade_choices - 1) * spacing)
    local start_x = (game_ref.ui.width - total_width) / 2
    local y = 250
    
    for i, upgrade in ipairs(upgrade_choices) do
        local x = start_x + (i - 1) * (upgrade_width + spacing)
        local is_selected = selected_upgrade == i
        
        Upgrades.drawUpgrade(upgrade, x, y, upgrade_width, upgrade_height, is_selected)
    end
end

function Locker.drawContinueButton()
    local button = {
        x = game_ref.ui.width / 2 - 100,
        y = game_ref.ui.height - 150,
        w = 200,
        h = 50
    }
    
    local can_continue = selected_upgrade ~= nil
    local bg_color = can_continue and {0.3, 0.6, 0.3, 1} or {0.3, 0.3, 0.3, 1}
    
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
    
    love.graphics.setColor(can_continue and {1, 1, 1, 1} or {0.5, 0.5, 0.5, 1})
    love.graphics.rectangle("line", button.x, button.y, button.w, button.h)
    
    love.graphics.setFont(game_ref.ui.font_medium)
    local button_text = game_ref.run.current_round > 13 and "VICTORY!" or "CONTINUE"
    love.graphics.printf(button_text, button.x + 5, button.y + button.h/2 - 12, button.w - 10, "center")
end

function Locker.mousepressed(x, y, button)
    if button == 1 then  -- Left click
        -- Check upgrade selection
        local upgrade_width = 200
        local upgrade_height = 150
        local spacing = 50
        local total_width = (#upgrade_choices * upgrade_width) + ((#upgrade_choices - 1) * spacing)
        local start_x = (game_ref.ui.width - total_width) / 2
        local upgrade_y = 250
        
        for i, upgrade in ipairs(upgrade_choices) do
            local upgrade_x = start_x + (i - 1) * (upgrade_width + spacing)
            if isPointInRect(x, y, upgrade_x, upgrade_y, upgrade_width, upgrade_height) then
                selected_upgrade = i
                break
            end
        end
        
        -- Check continue button
        local continue_button = {
            x = game_ref.ui.width / 2 - 100,
            y = game_ref.ui.height - 150,
            w = 200,
            h = 50
        }
        
        if isPointInRect(x, y, continue_button.x, continue_button.y, continue_button.w, continue_button.h) then
            if selected_upgrade then
                Locker.applyUpgradeAndContinue()
            end
        end
    end
end

function Locker.applyUpgradeAndContinue()
    if not selected_upgrade or not upgrade_choices[selected_upgrade] then
        return
    end
    
    local chosen_upgrade = upgrade_choices[selected_upgrade]
    
    -- Return cards to deck BEFORE applying upgrade so upgrade affects full deck
    returnCardsToDeck()
    
    -- Apply the upgrade to the full deck
    applyUpgrade(chosen_upgrade)
    
    -- Continue to next round or end game
    if game_ref.run.current_round > 13 then
        -- Player has won the entire run
        changeScene("end")
    else
        -- Continue to next round
        changeScene("round")
    end
end

return Locker
