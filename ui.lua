-- Modern UI System - Colorful, bouncy, animated interface

local ui = {}

-- Color palette - vibrant and fun
ui.colors = {
    background = {0.08, 0.12, 0.18},
    primary = {0.2, 0.8, 1.0},
    secondary = {1.0, 0.5, 0.8},
    accent = {1.0, 0.8, 0.3},
    success = {0.3, 1.0, 0.5},
    danger = {1.0, 0.3, 0.4},
    warning = {1.0, 0.7, 0.2},
    white = {1, 1, 1},
    dark = {0.1, 0.1, 0.1},
    purple = {0.8, 0.3, 1.0}
}

-- Typography
ui.fonts = {}

-- UI state
ui.scene = "menu"
ui.mouse_x = 0
ui.mouse_y = 0
ui.rule_applied_timer = 0 -- Timer for rule application delay

-- Hover tooltips
ui.hovered_rule_icon = nil
ui.tooltip_text = ""
ui.tooltip_x = 0
ui.tooltip_y = 0

-- Menu system
ui.menu_buttons = {}
ui.rule_buttons = {}
ui.rule_queue = {} -- Visual rule indicators at bottom
ui.rule_menu = {visible = false, type = nil}

-- Animations and effects
ui.particles = {}
ui.floating_texts = {}
ui.rule_icons = {}

-- Button animations
ui.button_animations = {}

-- Game over buttons
ui.game_over_buttons = {}

function ui.load()
    print("Loading modern UI...")
    
    -- Load fonts
    ui.fonts.huge = love.graphics.newFont(48)
    ui.fonts.large = love.graphics.newFont(32)
    ui.fonts.medium = love.graphics.newFont(24)
    ui.fonts.small = love.graphics.newFont(16)
    
    -- Create menu buttons
    ui.create_menu_buttons()
    ui.create_rule_buttons()
    
    print("UI loaded successfully!")
end

function ui.create_menu_buttons()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    local button_width = 300
    local button_height = 80
    local button_spacing = 20
    local start_x = (screen_width - button_width) / 2
    local start_y = screen_height / 2 - 50
    
    ui.menu_buttons = {
        {
            text = "NEW GAME",
            x = start_x,
            y = start_y,
            width = button_width,
            height = button_height,
            color = ui.colors.success,
            action = function() 
                ui.add_particle_burst(start_x + button_width/2, start_y + button_height/2, ui.colors.success)
                local game_state = require("game_state")
                game_state.start_new_game() 
            end,
            scale = 1,
            target_scale = 1,
            bounce = 0
        },
        {
            text = "HOW TO PLAY",
            x = start_x,
            y = start_y + button_height + button_spacing,
            width = button_width,
            height = button_height,
            color = ui.colors.primary,
            action = function() 
                ui.show_instructions()
            end,
            scale = 1,
            target_scale = 1,
            bounce = 0
        },
        {
            text = "EXIT",
            x = start_x,
            y = start_y + 2 * (button_height + button_spacing),
            width = button_width,
            height = button_height,
            color = ui.colors.danger,
            action = function() 
                love.event.quit()
            end,
            scale = 1,
            target_scale = 1,
            bounce = 0
        }
    }
end

function ui.create_rule_buttons()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local button_width = 150
    local button_height = 60
    local button_spacing = 20
    
    -- Center the rule buttons between the two hands (middle of screen)
    local total_width = 4 * button_width + 3 * button_spacing
    local start_x = (screen_width - total_width) / 2
    local y = screen_height / 2 - button_height / 2 -- Center vertically
    
    ui.rule_buttons = {
        {
            text = "SUIT",
            x = start_x,
            y = y,
            width = button_width,
            height = button_height,
            color = ui.colors.danger,
            rule_type = "suit",
            scale = 1,
            target_scale = 1,
            enabled = true,
            bounce = 0
        },
        {
            text = "RANK", 
            x = start_x + button_width + button_spacing,
            y = y,
            width = button_width,
            height = button_height,
            color = ui.colors.primary,
            rule_type = "rank",
            scale = 1,
            target_scale = 1,
            enabled = true,
            bounce = 0
        },
        {
            text = "MIX",
            x = start_x + 2 * (button_width + button_spacing),
            y = y,
            width = button_width,
            height = button_height,
            color = ui.colors.secondary,
            rule_type = "mix",
            scale = 1,
            target_scale = 1,
            enabled = true,
            bounce = 0
        },
        {
            text = "GOLD",
            x = start_x + 3 * (button_width + button_spacing),
            y = y,
            width = button_width,
            height = button_height,
            color = ui.colors.accent,
            rule_type = "gold",
            scale = 1,
            target_scale = 1,
            enabled = true,
            bounce = 0
        }
    }
    
    -- Create skip button (bottom right)
    ui.skip_button = {
        text = "SKIP",
        x = screen_width - 120,
        y = screen_height - 80,
        width = 100,
        height = 50,
        color = ui.colors.warning,
        scale = 1,
        target_scale = 1,
        bounce = 0
    }
end

function ui.update(dt)
    local game_state = require("game_state")
    ui.scene = game_state.get_scene()
    
    -- Update button animations
    ui.update_button_animations(dt)
    
    -- Update particles
    ui.update_particles(dt)
    
    -- Update floating texts
    ui.update_floating_texts(dt)
    
    -- Update rule queue animations
    ui.update_rule_queue(dt)
    
    -- Handle delayed rule completion
    if ui.rule_applied_timer > 0 then
        ui.rule_applied_timer = ui.rule_applied_timer - dt
        if ui.rule_applied_timer <= 0 then
            game_state.complete_hand()
        end
    end
end

function ui.update_button_animations(dt)
    local buttons = {}
    
    if ui.scene == "menu" then
        buttons = ui.menu_buttons
    elseif ui.scene == "playing" then
        buttons = ui.rule_buttons
    end
    
    for _, button in ipairs(buttons) do
        -- Scale animation
        local scale_diff = button.target_scale - button.scale
        button.scale = button.scale + scale_diff * dt * 8
        
        -- Bounce animation
        if button.bounce > 0 then
            button.bounce = button.bounce - dt * 4
        end
        
        -- Check if mouse is over button
        local mouse_over = ui.point_in_button(ui.mouse_x, ui.mouse_y, button)
        if mouse_over then
            button.target_scale = 1.1
        else
            button.target_scale = 1.0
        end
    end
    
    -- Update skip button animations
    if ui.skip_button then
        local scale_diff = ui.skip_button.target_scale - ui.skip_button.scale
        ui.skip_button.scale = ui.skip_button.scale + scale_diff * dt * 8
        
        if ui.skip_button.bounce > 0 then
            ui.skip_button.bounce = ui.skip_button.bounce - dt * 4
        end
        
        local mouse_over = ui.point_in_button(ui.mouse_x, ui.mouse_y, ui.skip_button)
        if mouse_over then
            ui.skip_button.target_scale = 1.1
        else
            ui.skip_button.target_scale = 1.0
        end
    end
end

function ui.update_particles(dt)
    for i = #ui.particles, 1, -1 do
        local particle = ui.particles[i]
        
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        particle.vy = particle.vy + 200 * dt -- gravity
        particle.life = particle.life - dt
        particle.scale = particle.scale + particle.scale_speed * dt
        
        if particle.life <= 0 then
            table.remove(ui.particles, i)
        end
    end
end

function ui.update_floating_texts(dt)
    for i = #ui.floating_texts, 1, -1 do
        local text = ui.floating_texts[i]
        
        text.y = text.y - 50 * dt
        text.life = text.life - dt
        text.alpha = math.max(0, text.life / text.max_life)
        
        if text.life <= 0 then
            table.remove(ui.floating_texts, i)
        end
    end
end

function ui.update_rule_queue(dt)
    local rules = require("rules")
    local active_rules = rules.get_active_rules()
    
    -- Check for removed rules (like expired gold rules) and animate them out
    for i = #ui.rule_icons, 1, -1 do
        local icon = ui.rule_icons[i]
        local still_active = false
        
        for _, active_rule in ipairs(active_rules) do
            if icon.rule == active_rule then
                still_active = true
                break
            end
        end
        
        if not still_active then
            -- Start pop-out animation
            if not icon.popping_out then
                icon.popping_out = true
                icon.pop_timer = 0.5
                icon.pop_scale = 1
            end
            
            -- Update pop-out animation
            icon.pop_timer = icon.pop_timer - dt
            if icon.pop_timer > 0 then
                icon.pop_scale = 1 + (0.5 - icon.pop_timer) * 4 -- Scale up quickly
                icon.base_y = icon.base_y - dt * 100 -- Float upward
            else
                -- Remove icon after animation
                table.remove(ui.rule_icons, i)
            end
        end
    end
    
    -- Add new rule icons
    for i, rule in ipairs(active_rules) do
        if not ui.rule_icons[i] then
            ui.rule_icons[i] = {
                rule = rule,
                float_time = 0,
                scale = 1,
                base_y = 0,
                popping_out = false
            }
        end
        
        if not ui.rule_icons[i].popping_out then
            local icon = ui.rule_icons[i]
            icon.float_time = icon.float_time + dt
            icon.scale = 1 + math.sin(icon.float_time * 2) * 0.1
        end
    end
    
    -- Remove excess icons that aren't popping out
    while #ui.rule_icons > #active_rules do
        local icon = ui.rule_icons[#ui.rule_icons]
        if not icon.popping_out then
            table.remove(ui.rule_icons)
        else
            break
        end
    end
end

function ui.draw()
    -- Clear background with animated gradient
    ui.draw_background()
    
    if ui.scene == "menu" then
        ui.draw_menu()
    elseif ui.scene == "playing" then
        ui.draw_game()
    elseif ui.scene == "game_over" then
        ui.draw_game()
        ui.draw_game_over()
    end
    
    -- Draw particles and effects on top
    ui.draw_particles()
    ui.draw_floating_texts()
    
    -- Draw tooltip last (on top of everything)
    ui.draw_tooltip()
end

function ui.draw_background()
    -- Animated gradient background
    local time = love.timer.getTime()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    -- Create animated background
    local gradient_color1 = {
        ui.colors.background[1] + math.sin(time * 0.5) * 0.02,
        ui.colors.background[2] + math.sin(time * 0.3) * 0.02,
        ui.colors.background[3] + math.sin(time * 0.7) * 0.02
    }
    
    local gradient_color2 = {
        ui.colors.background[1] + 0.05,
        ui.colors.background[2] + 0.05,
        ui.colors.background[3] + 0.1
    }
    
    love.graphics.setColor(gradient_color1)
    love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
    
    -- Add subtle animated elements
    love.graphics.setColor(gradient_color2[1], gradient_color2[2], gradient_color2[3], 0.3)
    for i = 1, 5 do
        local x = (i * 200 + math.sin(time * 0.5 + i) * 50) % screen_width
        local y = (i * 150 + math.cos(time * 0.3 + i) * 30) % screen_height
        love.graphics.circle("fill", x, y, 100 + math.sin(time + i) * 20)
    end
end

function ui.draw_menu()
    local screen_width = love.graphics.getWidth()
    
    -- Title with rainbow effect
    love.graphics.setFont(ui.fonts.huge)
    local title = "BOTRAP"
    local title_width = ui.fonts.huge:getWidth(title)
    local title_x = (screen_width - title_width) / 2
    local title_y = 150
    
    -- Rainbow title effect
    local time = love.timer.getTime()
    for i = 1, #title do
        local char = title:sub(i, i)
        local char_x = title_x + ui.fonts.huge:getWidth(title:sub(1, i-1))
        local hue = (time * 2 + i * 0.3) % (math.pi * 2)
        local r = (math.sin(hue) + 1) / 2
        local g = (math.sin(hue + math.pi * 2/3) + 1) / 2
        local b = (math.sin(hue + math.pi * 4/3) + 1) / 2
        
        love.graphics.setColor(r, g, b, 1)
        love.graphics.print(char, char_x, title_y + math.sin(time * 3 + i) * 10)
    end
    
    -- Draw menu buttons
    for _, button in ipairs(ui.menu_buttons) do
        ui.draw_bouncy_button(button)
    end
end

function ui.draw_game()
    local game_state = require("game_state")
    local cards = require("cards")
    local deck = require("deck")
    
    -- Draw cards
    for _, card in ipairs(game_state.get_player_hand()) do
        cards.draw_card(card)
    end
    
    for _, card in ipairs(game_state.get_opponent_hand()) do
        cards.draw_card(card)
    end
    
    -- Draw decks with count
    deck.draw_decks()
    
    -- Draw rule buttons (center) when in rule selection phase
    if game_state.get_phase() == "rule_selection" then
        for _, button in ipairs(ui.rule_buttons) do
            ui.draw_bouncy_button(button)
        end
    end
    
    -- Draw skip button during both card selection and rule selection (but not when win is detected)
    local phase = game_state.get_phase()
    if (phase == "card_selection" or phase == "rule_selection") and not game_state.get_win_detected() then
        ui.draw_bouncy_button(ui.skip_button)
    end
    
    -- Draw rule queue (bottom) with animated icons
    ui.draw_rule_queue()
    
    -- Draw game info
    ui.draw_game_info()
end

function ui.draw_bouncy_button(button)
    love.graphics.push()
    
    -- Button position with bounce
    local bounce_offset = 0
    if button.bounce > 0 then
        bounce_offset = math.sin(button.bounce * 10) * button.bounce * 5
    end
    
    -- Translate to button position
    love.graphics.translate(button.x, button.y + bounce_offset)
    
    -- Translate to center for scaling
    love.graphics.translate(button.width / 2, button.height / 2)
    
    -- Scale animation from center
    love.graphics.scale(button.scale, button.scale)
    
    -- Translate back to draw from top-left
    love.graphics.translate(-button.width / 2, -button.height / 2)
    
    -- Button shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 2, 2, button.width, button.height, 15)
    
    -- Button background
    love.graphics.setColor(button.color)
    love.graphics.rectangle("fill", 0, 0, button.width, button.height, 15)
    
    -- Button highlight
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("fill", 0, 0, button.width, button.height / 3, 15)
    
    -- Button border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0, button.width, button.height, 15)
    
    -- Button text
    love.graphics.setFont(ui.fonts.medium)
    love.graphics.setColor(ui.colors.white)
    local text_width = ui.fonts.medium:getWidth(button.text)
    local text_height = ui.fonts.medium:getHeight()
    love.graphics.print(
        button.text,
        (button.width - text_width) / 2,
        (button.height - text_height) / 2
    )
    
    love.graphics.pop()
end

function ui.draw_rule_queue()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    -- Draw active rules as animated icons in horizontal queue at bottom
    local icon_size = 50
    local icon_spacing = 10
    local start_x = 50
    local y = screen_height - 80
    
    for i, icon in ipairs(ui.rule_icons) do
        local x = start_x + (i - 1) * (icon_size + icon_spacing)
        
        -- Floating animation or pop-out animation
        local float_offset = 0
        local current_scale = icon.scale
        local alpha = 1
        
        if icon.popping_out then
            -- Pop-out animation
            current_scale = icon.pop_scale
            float_offset = icon.base_y
            alpha = math.max(0, icon.pop_timer / 0.5) -- Fade out
        else
            -- Normal floating animation
            float_offset = math.sin(icon.float_time * 3) * 5
        end
        
        -- Rule icon background with glow
        love.graphics.setColor(icon.rule.color[1], icon.rule.color[2], icon.rule.color[3], 0.8 * alpha)
        love.graphics.circle("fill", x + icon_size/2, y + icon_size/2 + float_offset, icon_size/2 * current_scale)
        
        -- Glow effect
        love.graphics.setColor(icon.rule.color[1], icon.rule.color[2], icon.rule.color[3], 0.3 * alpha)
        love.graphics.circle("fill", x + icon_size/2, y + icon_size/2 + float_offset, icon_size/2 * current_scale + 5)
        
        -- Rule icon
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.setFont(ui.fonts.large)
        local icon_text = icon.rule.icon
        local icon_width = ui.fonts.large:getWidth(icon_text)
        love.graphics.print(
            icon_text,
            x + (icon_size - icon_width) / 2,
            y + float_offset + 8
        )
    end
end

function ui.draw_game_info()
    local game_state = require("game_state")
    local screen_width = love.graphics.getWidth()
    
    -- Hand number and instruction at the top (center)
    love.graphics.setFont(ui.fonts.large)
    love.graphics.setColor(ui.colors.white)
    
    local hand_text = "Hand " .. game_state.get_hand()
    local hand_width = ui.fonts.large:getWidth(hand_text)
    love.graphics.print(hand_text, (screen_width - hand_width) / 2, 20)
    
    -- Phase-specific instruction below hand number
    local phase = game_state.get_phase()
    local instruction_text = ""
    local instruction_color = ui.colors.white
    
    if phase == "card_selection" then
        instruction_text = "Select cards for your rule"
        instruction_color = ui.colors.primary
    elseif phase == "rule_selection" then
        instruction_text = "Choose a rule to apply"
        instruction_color = ui.colors.accent
    end
    
    if instruction_text ~= "" then
        love.graphics.setFont(ui.fonts.medium)
        love.graphics.setColor(instruction_color)
        local instr_width = ui.fonts.medium:getWidth(instruction_text)
        love.graphics.print(instruction_text, (screen_width - instr_width) / 2, 60)
    end
end

function ui.draw_game_over()
    local game_state = require("game_state")
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
    
    -- Game over panel
    local panel_width = 500
    local panel_height = 300
    local panel_x = (screen_width - panel_width) / 2
    local panel_y = (screen_height - panel_height) / 2
    
    -- Panel background
    love.graphics.setColor(ui.colors.dark)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_width, panel_height, 20)
    
    -- Panel border with glow
    love.graphics.setColor(ui.colors.accent)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", panel_x, panel_y, panel_width, panel_height, 20)
    
    -- Game over message
    love.graphics.setFont(ui.fonts.large)
    love.graphics.setColor(ui.colors.white)
    local message = game_state.get_game_over_message()
    local message_width = ui.fonts.large:getWidth(message)
    love.graphics.print(message, panel_x + (panel_width - message_width) / 2, panel_y + 50)
    
    -- Buttons
    local button_width = 150
    local button_height = 60
    local button_spacing = 20
    local buttons_total_width = 2 * button_width + button_spacing
    local buttons_start_x = panel_x + (panel_width - buttons_total_width) / 2
    local buttons_y = panel_y + 180
    
    local play_again_button = {
        text = "PLAY AGAIN",
        x = buttons_start_x,
        y = buttons_y,
        width = button_width,
        height = button_height,
        color = ui.colors.success,
        scale = 1,
        bounce = 0
    }
    
    local menu_button = {
        text = "MENU",
        x = buttons_start_x + button_width + button_spacing,
        y = buttons_y,
        width = button_width,
        height = button_height,
        color = ui.colors.primary,
        scale = 1,
        bounce = 0
    }
    
    ui.draw_bouncy_button(play_again_button)
    ui.draw_bouncy_button(menu_button)
    
    -- Store for click detection
    ui.game_over_buttons = {play_again_button, menu_button}
end

function ui.draw_particles()
    for _, particle in ipairs(ui.particles) do
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], particle.life / particle.max_life)
        love.graphics.circle("fill", particle.x, particle.y, particle.scale)
    end
end

function ui.draw_floating_texts()
    love.graphics.setFont(ui.fonts.medium)
    for _, text in ipairs(ui.floating_texts) do
        love.graphics.setColor(text.color[1], text.color[2], text.color[3], text.alpha)
        love.graphics.print(text.text, text.x, text.y)
    end
end

-- Event handlers
function ui.mousepressed(x, y, button)
    if button ~= 1 then return end -- Only left mouse button
    
    local game_state = require("game_state")
    local cards = require("cards")
    
    if ui.scene == "menu" then
        for _, btn in ipairs(ui.menu_buttons) do
            if ui.point_in_button(x, y, btn) then
                btn.bounce = 1.0
                btn.action()
                return
            end
        end
    elseif ui.scene == "playing" then
        local phase = game_state.get_phase()
        
        -- Check rule buttons (only show in rule selection phase and when no win is detected)
        if phase == "rule_selection" and not game_state.get_win_detected() then
            for _, btn in ipairs(ui.rule_buttons) do
                if ui.point_in_button(x, y, btn) then
                    btn.bounce = 1.0
                    ui.show_rule_selection_menu(btn.rule_type)
                    return
                end
            end
        end
        
        -- Check skip button (available in both card_selection and rule_selection, but not when win is detected)
        if (phase == "card_selection" or phase == "rule_selection") and 
           not game_state.get_win_detected() and
           ui.skip_button and ui.point_in_button(x, y, ui.skip_button) then
            ui.skip_button.bounce = 1.0
            game_state.complete_hand() -- Skip to next hand
            return
        end
        
        -- Check card clicks (allow in both card_selection and rule_selection phases, but not when win is detected)
        local phase = game_state.get_phase()
        if (phase == "card_selection" or phase == "rule_selection") and not game_state.get_win_detected() then
            for _, card in ipairs(game_state.get_player_hand()) do
                if cards.contains_point(card, x, y) then
                    game_state.select_card(card)
                    return
                end
            end
            
            for _, card in ipairs(game_state.get_opponent_hand()) do
                if cards.contains_point(card, x, y) then
                    game_state.select_card(card)
                    return
                end
            end
        end
    elseif ui.scene == "game_over" then
        if ui.game_over_buttons then
            for i, btn in ipairs(ui.game_over_buttons) do
                if ui.point_in_button(x, y, btn) then
                    btn.bounce = 1.0
                    if i == 1 then -- Play again
                        game_state.start_new_game()
                    else -- Menu
                        game_state.set_scene("menu")
                    end
                    return
                end
            end
        end
    end
end

function ui.mousemoved(x, y)
    ui.mouse_x = x
    ui.mouse_y = y
    
    local game_state = require("game_state")
    local cards = require("cards")
    
    -- Check rule icon hover
    ui.hovered_rule_icon = nil
    ui.tooltip_text = ""
    
    local screen_height = love.graphics.getHeight()
    local icon_size = 50
    local icon_spacing = 10
    local start_x = 50
    local rule_y = screen_height - 80
    
    for i, icon in ipairs(ui.rule_icons) do
        local icon_x = start_x + (i - 1) * (icon_size + icon_spacing)
        
        if x >= icon_x and x <= icon_x + icon_size and 
           y >= rule_y and y <= rule_y + icon_size then
            ui.hovered_rule_icon = icon
            ui.tooltip_text = icon.rule.description
            ui.tooltip_x = x
            ui.tooltip_y = y - 40
            break
        end
    end
    
    -- Update card hover states
    if ui.scene == "playing" then
        for _, card in ipairs(game_state.get_player_hand()) do
            local hovered = cards.contains_point(card, x, y)
            cards.set_hovered(card, hovered)
        end
        
        for _, card in ipairs(game_state.get_opponent_hand()) do
            local hovered = cards.contains_point(card, x, y)
            cards.set_hovered(card, hovered)
        end
    end
end

-- Utility functions
function ui.point_in_button(x, y, button)
    return x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height
end

function ui.show_rule_selection_menu(rule_type)
    local rules = require("rules")
    local game_state = require("game_state")
    
    -- Get selected cards to base rule on
    local selected_cards = game_state.get_selected_cards()
    
    if #selected_cards == 0 then
        ui.add_floating_text("Select cards first!", love.graphics.getWidth() / 2, 300, ui.colors.warning)
        return
    end
    
    local success, message = false, ""
    
    if rule_type == "suit" then
        -- Check if all selected cards have same suit
        local first_suit = selected_cards[1].suit
        local same_suit = true
        for _, card in ipairs(selected_cards) do
            if card.suit ~= first_suit then
                same_suit = false
                break
            end
        end
        
        if same_suit then
            success, message = game_state.apply_rule("suit", first_suit)
        else
            ui.add_floating_text("Selected cards must have same suit!", love.graphics.getWidth() / 2, 300, ui.colors.danger)
            return
        end
        
    elseif rule_type == "rank" then
        -- Check if all selected cards have same rank
        local first_rank = selected_cards[1].rank
        local same_rank = true
        for _, card in ipairs(selected_cards) do
            if card.rank ~= first_rank then
                same_rank = false
                break
            end
        end
        
        if same_rank then
            success, message = game_state.apply_rule("rank", first_rank)
        else
            ui.add_floating_text("Selected cards must have same rank!", love.graphics.getWidth() / 2, 300, ui.colors.danger)
            return
        end
        
    elseif rule_type == "mix" then
        -- Mix rule: opponent can't have both selected suits
        if #selected_cards ~= 2 then
            ui.add_floating_text("Select exactly 2 cards for mix rule!", love.graphics.getWidth() / 2, 300, ui.colors.danger)
            return
        end
        
        local suits = {selected_cards[1].suit, selected_cards[2].suit}
        if suits[1] == suits[2] then
            ui.add_floating_text("Selected cards must have different suits!", love.graphics.getWidth() / 2, 300, ui.colors.danger)
            return
        end
        
        success, message = game_state.apply_rule("mix", suits)
        
    elseif rule_type == "gold" then
        -- Gold rule: selected rank overrides all rules
        if #selected_cards ~= 1 then
            ui.add_floating_text("Select exactly 1 card for gold rule!", love.graphics.getWidth() / 2, 300, ui.colors.danger)
            return
        end
        
        success, message = game_state.apply_rule("gold", selected_cards[1].rank)
    end
    
    if success then
        ui.add_floating_text("Rule applied: " .. message, love.graphics.getWidth() / 2, 300, ui.colors.success)
        -- Set delay before completing hand to show animations
        ui.rule_applied_timer = 1.5
    else
        ui.add_floating_text("Failed to apply rule: " .. message, love.graphics.getWidth() / 2, 300, ui.colors.danger)
    end
end

function ui.show_instructions()
    ui.add_floating_text("Set rules to trap your opponent's hand!", love.graphics.getWidth() / 2, 400, ui.colors.primary)
end

function ui.add_particle_burst(x, y, color)
    for i = 1, 20 do
        local angle = math.random() * math.pi * 2
        local speed = math.random(50, 200)
        local particle = {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = math.random() * 1.5 + 0.5,
            max_life = 2,
            scale = math.random() * 5 + 2,
            scale_speed = math.random() * 10 - 5,
            color = color
        }
        table.insert(ui.particles, particle)
    end
end

function ui.add_floating_text(text, x, y, color)
    local floating_text = {
        text = text,
        x = x - ui.fonts.medium:getWidth(text) / 2,
        y = y,
        life = 2,
        max_life = 2,
        alpha = 1,
        color = color
    }
    table.insert(ui.floating_texts, floating_text)
end

function ui.draw_tooltip()
    if ui.tooltip_text ~= "" and ui.hovered_rule_icon then
        local padding = 10
        local font = ui.fonts.small
        local text_width = font:getWidth(ui.tooltip_text)
        local text_height = font:getHeight()
        
        local tooltip_width = text_width + padding * 2
        local tooltip_height = text_height + padding * 2
        
        -- Adjust position to stay on screen
        local x = ui.tooltip_x
        local y = ui.tooltip_y
        
        if x + tooltip_width > love.graphics.getWidth() then
            x = love.graphics.getWidth() - tooltip_width - 10
        end
        if y < 0 then
            y = 10
        end
        
        -- Tooltip background
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", x, y, tooltip_width, tooltip_height, 5)
        
        -- Tooltip border
        love.graphics.setColor(ui.hovered_rule_icon.rule.color[1], ui.hovered_rule_icon.rule.color[2], ui.hovered_rule_icon.rule.color[3], 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, tooltip_width, tooltip_height, 5)
        
        -- Tooltip text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(font)
        love.graphics.print(ui.tooltip_text, x + padding, y + padding)
    end
end

return ui
