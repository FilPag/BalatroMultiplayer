-- Main process function: handles all multiplayer state updates and UI/animations for a given player_id and updates
local M = {}

-- === Helpers ===

local function localize_blind(val)
	if not val or val == "" then return "" end
	local loc = localize({ type = "name_text", key = val, set = "Blind" })
	if loc ~= "ERROR" then return loc end
	return (G.P_BLINDS[val] and G.P_BLINDS[val].name) or val
end

local function localize_player_location(val)
	if not val or val == "" then return "Unknown" end
	local loc = G.localization.misc.dictionary[val]
	if loc then return loc end
	return val
end

local function juice_player_ui(uie_id)
	local uie = G.HUD and G.HUD.get_UIE_by_ID and G.HUD:get_UIE_by_ID(uie_id)
	if uie and uie.juice_up then uie:juice_up() end
end

local function get_or_create_player(player_id)
	MP.GAME.players = MP.GAME.players or {}
	for _, player in pairs(MP.GAME.players) do
		if player.id == player_id then return player end
	end
	local new_player = { id = player_id, lives = 1 }
	table.insert(MP.GAME.players, new_player)
	sendTraceMessage(string.format("Created new game player entry for %s", player_id), "MULTIPLAYER")
	return new_player
end


--[[
	Update Handlers Table
	Each handler is responsible for a specific update key.
	Handlers receive (player, value, context) and may use context for conditional logic.
]]
local update_handlers = {}

-- Handles player life updates, including local player UI and comeback bonus logic
update_handlers.lives = function(player, value, context)
	if context.is_local then
		if player.lives ~= 0 and MP.LOBBY.config.gold_on_life_loss then
			player.comeback_bonus_given = false
			player.comeback_bonus = (player.comeback_bonus or 0) + 1
		end
		if MP.LOBBY.config.no_gold_on_round_loss and (G.GAME.blind and G.GAME.blind.dollars) then
			G.GAME.blind.dollars = 0
		end
		player.lives = value

		if G.HUD then
			local hud_ante = G.HUD:get_UIE_by_ID("hud_ante")
			if hud_ante then hud_ante.children[2].children[1]:juice_up() end
			sendTraceMessage(string.format("Received gameStateUpdate for local player %s", MP.LOBBY.local_id), "MULTIPLAYER")
		end
	else
		player.lives = value
	end
end

-- Handles score updates, including nemesis-specific UI logic
update_handlers.score = function(player, value, context)
	if context.is_nemesis and not context.is_local then
		sendTraceMessage(string.format("Received gameStateUpdate for nemesis player"), "MULTIPLAYER")
		local nemesis = MP.UTILS.get_nemesis()
		local new_score = MP.INSANE_INT.from_string(value)
		MP.UTILS.ease_score(nemesis.score, new_score)

		local blind_count = G.HUD_blind and G.HUD_blind:get_UIE_by_ID("HUD_blind_count")
		local dollars_earned = G.HUD_blind and G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned")
		if blind_count then blind_count:juice_up() end
		if dollars_earned then dollars_earned:juice_up() end

	elseif not context.is_local then
		player.score = MP.INSANE_INT.from_string(value)
	end
end

-- Handles highest_score updates
update_handlers.highest_score = function(player, value, context)
	player.score = MP.INSANE_INT.from_string(value)
end

-- Handles location updates, parsing enemy location
update_handlers.location = function(player, value, context)
	player.location = M.parse_enemy_location(value)
end

update_handlers.ante = function(player, value, context)
	if context.is_local and value > 1 then
		play_sound('highlight2', 0.685, 0.2)
		play_sound('generic1')
	end
end

-- Default handler for any other keys
local function default_update_handler(player, key, value, context)
	player[key] = value
end

-- Cooperative mode update handler
local function handle_coop_updates(updates)
	if not updates.score then return end
	G.E_MANAGER:add_event(Event({
		blocking = true,
		func = (function()
			if not MP.is_online_boss() then return true end
			MP.coop_score = MP.INSANE_INT.empty()
			for _, player in pairs(MP.GAME.players) do
				MP.coop_score = MP.INSANE_INT.add(MP.coop_score, player.score)
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

--[[
	Main process function: handles all multiplayer state updates and UI/animations for a given player_id and updates.
	The shape of updates is a table of key-value pairs, where each key is handled by a registered handler or the default handler.
]]
function M.process(player_id, updates)
	if not updates or next(updates) == nil then return end -- Early exit for empty updates
	local player = get_or_create_player(player_id)
	local is_local = player_id == MP.LOBBY.local_id
	local is_nemesis = G.GAME.blind and (G.GAME.blind.config.blind.key == "bl_mp_nemesis" or G.GAME.blind.pvp)
	local context = {
		player_id = player_id,
		is_local = is_local,
		is_nemesis = is_nemesis,
		updates = updates
	}

	-- Apply updates to player state using handlers
	for key, value in pairs(updates) do
		local handler = update_handlers[key]
		if handler then
			handler(player, value, context)
		else
			default_update_handler(player, key, value, context)
		end
	end

	-- Handle cooperative mode updates
	if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and MP.is_online_boss() then
		handle_coop_updates(updates)
	end
end

function M.parse_enemy_location(location)
	if type(location) ~= "string" or location == "" then return "Unknown" end
	local main, sub = location:match("([^%-]+)%-(.+)")
	main = main or location
	sub = sub or ""
	return localize_player_location(main) .. localize_blind(sub)
end

function M.reset_scores()
	for _, player in pairs(MP.GAME.players) do
		player.score = MP.INSANE_INT.empty()
		player.score_text = "0"
	end
end

-- Expose helpers for testability or future use
M.get_or_create_player = get_or_create_player
M.juice_player_ui = juice_player_ui
-- The following helpers are now handled via update_handlers and are not exported
-- M.handle_nemesis_blind = handle_nemesis_blind
-- M.local_player_updates = local_player_updates

return M
