-- Botrap - A modern, animated card game
-- Main entry point with state management

local game_state = nil
local cards = nil
local deck = nil
local rules = nil
local ui = nil

function love.load()
    -- Set window properties
    love.window.setTitle("BOTRAP")
    love.window.setMode(1200, 800, {resizable = true, minwidth = 800, minheight = 600})
    
    -- Initialize random seed
    math.randomseed(os.time())
    
    -- Initialize game systems (delayed loading to avoid circular dependencies)
    game_state = require("game_state")
    cards = require("cards")
    deck = require("deck")
    rules = require("rules")
    ui = require("ui")
    
    game_state.load()
    cards.load()
    deck.load()
    rules.load()
    ui.load()
    
    print("Botrap loaded successfully!")
end

function love.update(dt)
    if game_state then
        game_state.update(dt)
    end
    if ui then
        ui.update(dt)
    end
end

function love.draw()
    if ui then
        ui.draw()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if ui then
        ui.mousepressed(x, y, button)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if ui then
        ui.mousemoved(x, y)
    end
end

function love.keypressed(key)
    if key == "escape" then
        if game_state and game_state.get_scene() == "menu" then
            love.event.quit()
        elseif game_state then
            game_state.set_scene("menu")
        end
    end
end
