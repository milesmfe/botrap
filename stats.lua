-- Stats Manager - Handles save/load of player statistics

local stats = {}

-- Default stats structure
local default_stats = {
    runs_completed = 0,
    runs_attempted = 0,
    total_rounds_won = 0,
    total_hands_played = 0,
    best_run_length = 0,
    opponents_defeated = {},
    upgrades_used = {},
    last_run = {
        completed = false,
        rounds_won = 0,
        hands_played = 0,
        opponents_faced = {},
        upgrades_chosen = {},
        final_score = 0
    }
}

local current_stats = {}
local saves_folder = "saves"

function stats.load()
    -- Create saves directory if it doesn't exist
    local info = love.filesystem.getInfo(saves_folder)
    if not info then
        love.filesystem.createDirectory(saves_folder)
    end
    
    -- Load existing stats or create default
    local stats_file = saves_folder .. "/player_stats.lua"
    local file_info = love.filesystem.getInfo(stats_file)
    
    if file_info then
        local contents = love.filesystem.read(stats_file)
        if contents then
            local success, loaded_stats = pcall(function()
                local chunk = load(contents)
                if chunk then
                    return chunk()
                end
                return nil
            end)
            
            if success and loaded_stats then
                current_stats = loaded_stats
            else
                current_stats = stats.copy_table(default_stats)
            end
        else
            current_stats = stats.copy_table(default_stats)
        end
    else
        current_stats = stats.copy_table(default_stats)
    end
end

function stats.save()
    local stats_file = saves_folder .. "/player_stats.lua"
    
    -- Save as Lua table (simpler than JSON)
    local lua_content = stats.serialize_table(current_stats)
    local success = love.filesystem.write(stats_file, "return " .. lua_content)
    return success
end

function stats.start_new_run()
    current_stats.runs_attempted = current_stats.runs_attempted + 1
    current_stats.last_run = {
        completed = false,
        rounds_won = 0,
        hands_played = 0,
        opponents_faced = {},
        upgrades_chosen = {},
        final_score = 0
    }
end

function stats.complete_run(won_final_round)
    if won_final_round then
        current_stats.runs_completed = current_stats.runs_completed + 1
        current_stats.last_run.completed = true
    end
    
    current_stats.total_rounds_won = current_stats.total_rounds_won + current_stats.last_run.rounds_won
    current_stats.total_hands_played = current_stats.total_hands_played + current_stats.last_run.hands_played
    current_stats.best_run_length = math.max(current_stats.best_run_length, current_stats.last_run.rounds_won)
    
    -- Update opponent defeat counts
    for _, opponent_name in ipairs(current_stats.last_run.opponents_faced) do
        current_stats.opponents_defeated[opponent_name] = (current_stats.opponents_defeated[opponent_name] or 0) + 1
    end
    
    -- Update upgrade usage counts
    for _, upgrade_name in ipairs(current_stats.last_run.upgrades_chosen) do
        current_stats.upgrades_used[upgrade_name] = (current_stats.upgrades_used[upgrade_name] or 0) + 1
    end
    
    stats.save()
end

function stats.record_round_victory(opponent_name)
    current_stats.last_run.rounds_won = current_stats.last_run.rounds_won + 1
    table.insert(current_stats.last_run.opponents_faced, opponent_name)
end

function stats.record_hand_played()
    current_stats.last_run.hands_played = current_stats.last_run.hands_played + 1
end

function stats.record_upgrade_chosen(upgrade_name)
    table.insert(current_stats.last_run.upgrades_chosen, upgrade_name)
end

function stats.get_stats()
    return current_stats
end

function stats.get_last_run_stats()
    return current_stats.last_run
end

-- Utility functions
function stats.copy_table(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = stats.copy_table(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function stats.serialize_table(t, indent)
    indent = indent or ""
    local result = "{\n"
    
    for key, value in pairs(t) do
        local key_str = type(key) == "string" and string.format('"%s"', key) or tostring(key)
        result = result .. indent .. "  [" .. key_str .. "] = "
        
        if type(value) == "table" then
            result = result .. stats.serialize_table(value, indent .. "  ")
        elseif type(value) == "string" then
            result = result .. string.format('"%s"', value)
        else
            result = result .. tostring(value)
        end
        result = result .. ",\n"
    end
    
    result = result .. indent .. "}"
    return result
end

return stats
