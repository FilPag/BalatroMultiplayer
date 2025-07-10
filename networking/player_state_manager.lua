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

local function handle_nemesis_blind(update)
	sendTraceMessage(string.format("Received gameStateUpdate for nemesis player"), "MULTIPLAYER")

	local nemesis = MP.UTILS.get_nemesis()
	if update.score then
		local new_score = MP.INSANE_INT.from_string(update.score)
		MP.UTILS.ease_score(nemesis.score, new_score)
		local blind_count = G.HUD_blind and G.HUD_blind:get_UIE_by_ID("HUD_blind_count")
		local dollars_earned = G.HUD_blind and G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned")
		if blind_count then blind_count:juice_up() end
		if dollars_earned then dollars_earned:juice_up() end
	end
end

local function local_player_updates(updates)
	local local_player = get_or_create_player(MP.LOBBY.local_id)
	sendTraceMessage(string.format("Received gameStateUpdate for local player %s", MP.LOBBY.local_id), "MULTIPLAYER")
	if updates.lives then
		if local_player.lives ~= 0 and MP.LOBBY.config.gold_on_life_loss then
			local_player.comeback_bonus_given = false
			local_player.comeback_bonus = (local_player.comeback_bonus or 0) + 1
		end

		if MP.LOBBY.config.no_gold_on_round_loss and (G.GAME.blind and G.GAME.blind.dollars) then
			G.GAME.blind.dollars = 0
		end

		local_player.lives = updates.lives
		local hud_ante = G.HUD:get_UIE_by_ID("hud_ante")
		if hud_ante then hud_ante.children[2].children[1]:juice_up() end
	end

	if updates.score then
		new_score = MP.INSANE_INT.from_string(updates.score)
		local_player.score = MP.INSANE_INT.add(local_player.score, new_score)
	end
end

local function coop_updates(updates)
	if updates.score then
		local new_score = MP.INSANE_INT.empty()

		for _, player in pairs(MP.GAME.players) do
			new_score = MP.INSANE_INT.add(new_score, player.score)
		end

    G.E_MANAGER:add_event(Event({
      trigger = 'ease',
      blocking = false,
      ref_table = G.GAME,
      ref_value = 'chips',
      ease_to = new_score.coeffiocient, --TODO update Game.CHIPS to use MP.INSANE_INT
      delay =  0.5,
      func = (function(t) return math.floor(t) end)
    }))
	end
end

function M.process(player_id, updates)
	local player = get_or_create_player(player_id)

	if player_id == MP.LOBBY.local_id then
		local_player_updates(updates)
		updates.lives = nil
		updates.score = nil
	end

	if G.GAME.blind.config.blind.key == "bl_mp_nemesis" or G.GAME.blind.pvp then
		handle_nemesis_blind(updates)
		updates.score = nil
	end

	for key, value in pairs(updates) do
		if key == "location" then
			player[key] = M.parse_enemy_location(value)
		elseif key == "score" or key == "highest_score" then
			local new_score = MP.INSANE_INT.from_string(value)
			player.score = MP.INSANE_INT.add(player.score, new_score)
		else
			player[key] = value
		end
	end

	if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" then
		coop_updates(updates)
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
M.handle_nemesis_blind = handle_nemesis_blind
M.local_player_updates = local_player_updates

return M
