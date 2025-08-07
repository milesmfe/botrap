-- End scene - Game completion and statistics
local End = {}

local game_ref
local run_won = false
local stats = {}

function End.init(game)
    game_ref = game
end

function End.enter()
    -- Determine if run was won or lost
    run_won = game_ref.run.current_round > 13
    
    -- Calculate run statistics
    stats = End.calculateRunStats()
end

function End.calculateRunStats()
    local player_normal = 0
    local player_trapped = 0
    local player_gold = 0
    local player_wild = 0
    
    local opponent_normal = 0
    local opponent_trapped = 0
    local opponent_gold = 0
    local opponent_wild = 0
    
    -- Count card types in player deck
    for _, card in ipairs(game_ref.run.player_deck) do
        if card.type == "normal" then
            player_normal = player_normal + 1
        elseif card.type == "trapped" then
            player_trapped = player_trapped + 1
        elseif card.type == "gold" then
            player_gold = player_gold + 1
        elseif card.type == "wild" then
            player_wild = player_wild + 1
        end
    end
    
    -- Count card types in opponent deck
    for _, card in ipairs(game_ref.run.opponent_deck) do
        if card.type == "normal" then
            opponent_normal = opponent_normal + 1
        elseif card.type == "trapped" then
            opponent_trapped = opponent_trapped + 1
        elseif card.type == "gold" then
            opponent_gold = opponent_gold + 1
        elseif card.type == "wild" then
            opponent_wild = opponent_wild + 1
        end
    end
    
    return {
        rounds_completed = math.min(game_ref.run.current_round - 1, 13),
        upgrades_earned = #game_ref.run.player_upgrades,
        trap_rules_used = #game_ref.run.trap_rules,
        gold_used = game_ref.run.gold_card ~= nil,
        player_deck = {
            normal = player_normal,
            trapped = player_trapped,
            gold = player_gold,
            wild = player_wild,
            total = player_normal + player_trapped + player_gold + player_wild
        },
        opponent_deck = {
            normal = opponent_normal,
            trapped = opponent_trapped,
            gold = opponent_gold,
            wild = opponent_wild,
            total = opponent_normal + opponent_trapped + opponent_gold + opponent_wild
        }
    }
end

function End.update(dt)
    -- No continuous updates needed
end

function End.draw()
    -- Background
    love.graphics.setColor(0.05, 0.05, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, game_ref.ui.width, game_ref.ui.height)
    
    -- Title
    love.graphics.setFont(game_ref.ui.font_large)
    if run_won then
        love.graphics.setColor(1, 0.8, 0.2, 1)
        drawFloatingText("VICTORY!", 0, 50, game_ref.ui.font_large, {1, 0.8, 0.2, 1})
        love.graphics.setFont(game_ref.ui.font_medium)
        love.graphics.setColor(0.8, 1, 0.8, 1)
        drawFloatingText("You have mastered the art of trapping!", 0, 100, game_ref.ui.font_medium, {0.8, 1, 0.8, 1})
    else
        love.graphics.setColor(1, 0.5, 0.5, 1)
        drawFloatingText("DEFEAT", 0, 50, game_ref.ui.font_large, {1, 0.5, 0.5, 1})
        love.graphics.setFont(game_ref.ui.font_medium)
        love.graphics.setColor(1, 0.8, 0.8, 1)
        drawFloatingText("You were trapped by your opponent", 0, 100, game_ref.ui.font_medium, {1, 0.8, 0.8, 1})
    end
    
    -- Run statistics
    End.drawRunStats()
    
    -- Overall game statistics
    End.drawOverallStats()
    
    -- Return to menu button
    End.drawReturnButton()
end

function End.drawRunStats()
    local x = 50
    local y = 180
    local line_height = 25
    
    love.graphics.setFont(game_ref.ui.font_medium)
    love.graphics.setColor(1, 1, 1, 1)
    drawFloatingText("Run Statistics", x, y, game_ref.ui.font_medium)
    y = y + 40
    
    love.graphics.setFont(game_ref.ui.font_small)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    
    -- Basic stats
    drawFloatingText("Rounds Completed: " .. stats.rounds_completed .. " / 13", x, y, game_ref.ui.font_small)
    y = y + line_height
    
    drawFloatingText("Upgrades Earned: " .. stats.upgrades_earned, x, y, game_ref.ui.font_small)
    y = y + line_height
    
    drawFloatingText("Trap Rules Used: " .. stats.trap_rules_used, x, y, game_ref.ui.font_small)
    y = y + line_height
    
    drawFloatingText("Gold Rule Used: " .. (stats.gold_used and "Yes" or "No"), x, y, game_ref.ui.font_small)
    y = y + line_height * 1.5
    
    -- Deck composition
    love.graphics.setColor(0.7, 0.9, 1, 1)
    drawFloatingText("Final Player Deck:", x, y, game_ref.ui.font_small)
    y = y + line_height
    
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    drawFloatingText("  Normal: " .. stats.player_deck.normal, x, y, game_ref.ui.font_small)
    y = y + line_height
    
    if stats.player_deck.trapped > 0 then
        love.graphics.setColor(1, 0.7, 0.7, 1)
        drawFloatingText("  Trapped: " .. stats.player_deck.trapped, x, y, game_ref.ui.font_small)
        y = y + line_height
    end
    
    if stats.player_deck.gold > 0 then
        love.graphics.setColor(1, 1, 0.7, 1)
        drawFloatingText("  Gold: " .. stats.player_deck.gold, x, y, game_ref.ui.font_small)
        y = y + line_height
    end
    
    if stats.player_deck.wild > 0 then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        drawFloatingText("  Wild: " .. stats.player_deck.wild, x, y, game_ref.ui.font_small)
        y = y + line_height
    end
    
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    drawFloatingText("  Total: " .. stats.player_deck.total, x, y, game_ref.ui.font_small)
end

function End.drawOverallStats()
    local x = game_ref.ui.width / 2 + 50
    local y = 180
    
    love.graphics.setFont(game_ref.ui.font_medium)
    love.graphics.setColor(1, 1, 1, 1)
    drawFloatingText("Overall Statistics", x, y, game_ref.ui.font_medium)
    y = y + 40
    
    love.graphics.setFont(game_ref.ui.font_small)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    
    drawFloatingText("Total Wins: " .. game_ref.run.wins, x, y, game_ref.ui.font_small)
    y = y + 25
    
    drawFloatingText("Total Losses: " .. game_ref.run.losses, x, y, game_ref.ui.font_small)
    y = y + 25
    
    local total_runs = game_ref.run.wins + game_ref.run.losses
    if total_runs > 0 then
        local win_rate = math.floor((game_ref.run.wins / total_runs) * 100)
        drawFloatingText("Win Rate: " .. win_rate .. "%", x, y, game_ref.ui.font_small)
        y = y + 25
    end
    
    -- Show upgrades used this run
    if #game_ref.run.player_upgrades > 0 then
        y = y + 15
        love.graphics.setColor(0.8, 1, 0.8, 1)
        drawFloatingText("Upgrades Used This Run:", x, y, game_ref.ui.font_small)
        y = y + 25
        
        for _, upgrade in ipairs(game_ref.run.player_upgrades) do
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            drawFloatingText("  " .. upgrade.name .. " (" .. upgrade.rarity .. ")", x, y, game_ref.ui.font_small)
            y = y + 20
        end
    end
end

function End.drawReturnButton()
    local button = {
        x = game_ref.ui.width / 2 - 100,
        y = game_ref.ui.height - 100,
        w = 200,
        h = 50
    }
    
    love.graphics.setColor(0.3, 0.3, 0.5, 1)
    love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", button.x, button.y, button.w, button.h)
    
    love.graphics.setFont(game_ref.ui.font_medium)
    love.graphics.printf("RETURN TO MENU", button.x + 5, button.y + button.h/2 - 12, button.w - 10, "center")
end

function End.mousepressed(x, y, button)
    if button == 1 then  -- Left click
        local return_button = {
            x = game_ref.ui.width / 2 - 100,
            y = game_ref.ui.height - 100,
            w = 200,
            h = 50
        }
        
        if isPointInRect(x, y, return_button.x, return_button.y, return_button.w, return_button.h) then
            changeScene("menu")
        end
    end
end

return End
