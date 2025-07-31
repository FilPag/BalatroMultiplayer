local M = {}

local function parse_value(key, raw_value)
    if key == "score" or key == "highest_score" then
        return MP.INSANE_INT.from_string(raw_value)
    elseif key == "location" then
        return MP.UI_UTILS.parse_enemy_location(raw_value)
    else
        return raw_value
    end
end

local function values_equal(key, old_value, new_value)
    if key == "score" or key == "highest_score" then
        return old_value and MP.INSANE_INT.equals(old_value, new_value)
    else
        return old_value == new_value
    end
end

local function handle_nemesis_score(player_id, new_score)
    if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and MP.is_online_boss() then
        return false
    end

    local nemesis = MP.UTILS.get_nemesis()
    if nemesis and nemesis.profile.id == player_id then
        MP.UTILS.ease_score(nemesis.game_state.score, new_score)
        return true
    end
    return false
end

function M.update_player_state(player_id, game_state)
    if not game_state then return end
    local player = MP.LOBBY.players[player_id]
    
    for key, raw_value in pairs(game_state) do
        local value = parse_value(key, raw_value)
        local old_value = player.game_state[key]
        
        if not values_equal(key, old_value, value) then
            -- Handle nemesis score special case
            if key == "score" and handle_nemesis_score(player_id, value) then
            else
                player.game_state[key] = value
            end
            
            MP.UI_EVENT_HANDLER.dispatch(player_id, key)
        end
    end
end

return M
