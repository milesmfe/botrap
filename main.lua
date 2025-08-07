local game_state = require("game_state")
local cards = require("cards")
local deck = require("deck")
local rules = require("rules")
local ui = require("ui")

function love.load()
    love.window.setTitle("BOTRAP")
    love.window.setMode(1200, 800, {resizable = true, minwidth = 800, minheight = 600})
    math.randomseed(os.time())
    
    game_state.load()
    cards.load()
    deck.load()
    rules.load()
    ui.load()
end

function love.update(dt)
    game_state.update(dt)
    ui.update(dt)
end

function love.draw()
    ui.draw()
end

function love.mousepressed(x, y, button)
    ui.mousepressed(x, y, button)
end

function love.mousemoved(x, y)
    ui.mousemoved(x, y)
end

function love.keypressed(key)
    if key == "escape" then
        if game_state.get_scene() == "menu" then
            love.event.quit()
        else
            game_state.set_scene("menu")
        end
    end
end
