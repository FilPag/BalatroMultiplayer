---@class ClientGameState
---@field ante integer
---@field round integer
---@field furthest_blind integer
---@field hands_left integer
---@field hands_max integer
---@field discards_left integer
---@field discards_max integer
---@field lives integer
---@field lives_blocker boolean
---@field location string
---@field skips integer
---@field score string InsaneInt
---@field highest_score string InsaneInt
---@field spent_in_shop integer[]  -- Array of integers


-- Main process function: handles all multiplayer state updates and UI/animations for a given player_id and updates
local M = {}


function M.reset_scores()
	for _, player in pairs(MP.GAME.players) do
		player.score = MP.INSANE_INT.empty()
		player.score_text = "0"
	end
end

local function update_coop_score()
	G.E_MANAGER:add_event(Event({
		blocking = true,
		func = (function()
			if not MP.is_online_boss() then return true end
			MP.coop_score = MP.INSANE_INT.empty()

			for _, player in pairs(MP.LOBBY.players) do
				MP.coop_score = MP.INSANE_INT.add(MP.coop_score, player.game_state.score)
			end

			G.E_MANAGER:add_event(Event({
				trigger = 'ease',
				blocking = false,
				blockable = true,
				ref_table = G.GAME,
				ref_value = 'chips',
				ease_to = MP.INSANE_INT.to_number(MP.coop_score),
				delay = 0.5,
				func = (function(t) return math.floor(t) end)
			}))
			return true
		end)
	}))
end

local function create_reactive_state(initial)
	local listeners = {}
	local proxy = initial or {}

	proxy = setmetatable(proxy, {
		__newindex = function(tbl, key, value)
			local old = rawget(tbl, key)
			sendTraceMessage("updating key: " .. key .. " from " .. tostring(old) .. " to " .. tostring(value))
			rawset(tbl, key, value)
			if old ~= value and listeners[key] then
				for _, cb in ipairs(listeners[key]) do
					cb(old, value, key)
				end
			end
		end,
	})

	-- Register a callback for a key
	function proxy.on_change(key, cb)
		listeners[key] = listeners[key] or {}
		table.insert(listeners[key], cb)
	end

	return proxy
end

---@param initial_state ClientGameState
function M.create_player_game_state(player_id, initial_state)
	local game_state = create_reactive_state(initial_state)
	local is_local = player_id == MP.LOBBY.local_id

	---------------------------- On-change handlers ----------------------------

	---@param new_value string
	game_state.on_change("score", function(_, new_value)
		local is_nemesis = G.GAME.blind and (G.GAME.blind.config.blind.key == "bl_mp_nemesis" or G.GAME.blind.pvp)
		sendDebugMessage("Player " .. player_id .. " score changed to: " .. tprint(new_value))

		if is_nemesis and not is_local then
			local nemesis = MP.UTILS.get_nemesis()
			MP.UTILS.ease_score(nemesis.score, new_value)

			local blind_count = G.HUD_blind and G.HUD_blind:get_UIE_by_ID("HUD_blind_count")
			local dollars_earned = G.HUD_blind and G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned")
			if blind_count then blind_count:juice_up() end
			if dollars_earned then dollars_earned:juice_up() end
		elseif MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and MP.is_online_boss() then
			update_coop_score()
		end
	end)

	---@param new_value integer
	game_state.on_change("ante", function(_, new_value)
		if is_local then
			play_sound('highlight2', 0.685, 0.2)
			play_sound('generic1')
		end
	end)

	return game_state
end

return M
