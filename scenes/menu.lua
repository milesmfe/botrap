-- Menu scene - Main menu interface
local Menu = {}

local game_ref
local buttons = {}
local title_animation_time = 0

function Menu.init(game)
    game_ref = game
    
    -- Initialize menu buttons
    buttons = {
        {
            text = "NEW GAME",
            x = game.ui.width / 2 - 100,
            y = game.ui.height / 2,
            w = 200,
            h = 50,
            action = function()
                startNewRun()
            end
        },
        {
            text = "STATS",
            x = game.ui.width / 2 - 100,
            y = game.ui.height / 2 + 70,
            w = 200,
            h = 50,
            action = function()
                -- Stats display (placeholder)
            end
        },
        {
            text = "QUIT",
            x = game.ui.width / 2 - 100,
            y = game.ui.height / 2 + 140,
            w = 200,
            h = 50,
            action = function()
                love.event.quit()
            end
        }
    }
end

function Menu.enter()
    title_animation_time = 0
end

function Menu.update(dt)
    title_animation_time = title_animation_time + dt
end

function Menu.draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.2, 1)
    love.graphics.rectangle("fill", 0, 0, game_ref.ui.width, game_ref.ui.height)
    
    -- Animated title
    local title_y = game_ref.ui.height / 2 - 150
    local bounce = math.sin(title_animation_time * 2) * 10
    local wobble_x = math.sin(title_animation_time * 3) * 5
    local wobble_y = math.cos(title_animation_time * 2.5) * 3
    
    -- Title shadow
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.setFont(game_ref.ui.font_large)
    love.graphics.printf("BOTRAP", wobble_x + 3, title_y + bounce + 3 + wobble_y, game_ref.ui.width, "center")
    
    -- Title main
    love.graphics.setColor(1, 0.8, 0.2, 1)
    love.graphics.printf("BOTRAP", wobble_x, title_y + bounce + wobble_y, game_ref.ui.width, "center")
    
    -- Subtitle
    love.graphics.setFont(game_ref.ui.font_medium)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    drawFloatingText("Master the Art of Trapping", 0, title_y + 80, game_ref.ui.font_medium, {0.8, 0.8, 0.8, 1})
    
    -- Draw buttons
    for _, button in ipairs(buttons) do
        Menu.drawButton(button)
    end
    
    -- Stats display
    if game_ref.run.wins > 0 or game_ref.run.losses > 0 then
        love.graphics.setFont(game_ref.ui.font_small)
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        local stats_text = string.format("Wins: %d  Losses: %d", game_ref.run.wins, game_ref.run.losses)
        love.graphics.printf(stats_text, 0, game_ref.ui.height - 50, game_ref.ui.width, "center")
    end
end

function Menu.drawButton(button)
    local hover = Menu.isPointInButton(love.mouse.getX(), love.mouse.getY(), button)
    
    -- Button background
    local bg_color = hover and {0.3, 0.3, 0.5, 1} or {0.2, 0.2, 0.3, 1}
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
    
    -- Button border
    love.graphics.setColor(hover and {0.6, 0.6, 0.8, 1} or {0.4, 0.4, 0.5, 1})
    love.graphics.rectangle("line", button.x, button.y, button.w, button.h)
    
    -- Button text
    love.graphics.setFont(game_ref.ui.font_medium)
    love.graphics.setColor(1, 1, 1, 1)
    drawFloatingText(button.text, button.x, button.y + button.h/2 - 12, game_ref.ui.font_medium, {1, 1, 1, 1})
end

function Menu.isPointInButton(x, y, button)
    return isPointInRect(x, y, button.x, button.y, button.w, button.h)
end

function Menu.mousepressed(x, y, button_num)
    if button_num == 1 then  -- Left click
        for _, button in ipairs(buttons) do
            if Menu.isPointInButton(x, y, button) then
                button.action()
                break
            end
        end
    end
end

return Menu
