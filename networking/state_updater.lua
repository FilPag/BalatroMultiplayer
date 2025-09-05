local M = {}

local function parse_value(key, raw_value)
    if key == "score" or key == "highest_score" then
        return to_big(raw_value)
    elseif key == "location" then
        return MP.UI_UTILS.parse_enemy_location(raw_value)
    else
        return raw_value
    end
end

local function values_equal(key, old_value, new_value)
    return old_value == new_value
end

local function handle_online_score_update(player, new_score)
    if MP.UTILS.is_in_online_blind() and MP.UTILS.is_coop() then
        player.game_state.score = new_score
        return
    end

    MP.UTILS.ease_score(player.game_state, new_score)
end

function M.update_player_state(player_id, game_state)
    if not game_state then return end
    local player = MP.LOBBY.players[player_id]

    for key, raw_value in pairs(game_state) do
        local value = parse_value(key, raw_value)
        local old_value = player.game_state[key]

        if not values_equal(key, old_value, value) then
            if key == "score" then
                handle_online_score_update(player, value)
            else
                player.game_state[key] = value
            end

            MP.UI_EVENT_HANDLER.dispatch(player_id, key)
        end
    end
end

return M
