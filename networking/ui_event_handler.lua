local M = {}
local handlers = {}

handlers.lives = function(player, is_local, is_nemesis)
	if is_local then
		if G.HUD then
			local hud_ante = G.HUD:get_UIE_by_ID("hud_ante")
			if hud_ante then hud_ante.children[2].children[1]:juice_up() end
			sendTraceMessage(string.format("Received gameStateUpdate for local player %s", MP.LOBBY.local_id), "MULTIPLAYER")
		end
	end
end

handlers.score = function(player, is_local, is_nemesis)
	if is_nemesis and not is_local then
		local blind_count = G.HUD_blind and G.HUD_blind:get_UIE_by_ID("HUD_blind_count")
		local dollars_earned = G.HUD_blind and G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned")
		if blind_count then blind_count:juice_up() end
		if dollars_earned then dollars_earned:juice_up() end
	end
	if MP.UTILS.is_coop() and MP.UTILS.is_in_online_blind() then
		G.E_MANAGER:add_event(Event({
			blocking = true,
			blockable = true,
			func = (function()
				MP.coop_score = to_big(0)
				for _, player in pairs(MP.LOBBY.players) do
					MP.coop_score = MP.coop_score + player.game_state.score
				end
				G.E_MANAGER:add_event(Event({
					trigger = 'ease',
					blocking = true,
					blockable = true,
					ref_table = G.GAME,
					ref_value = 'chips',
					ease_to = MP.coop_score,
					delay = 0.5,
					func = (function(t) return math.floor(t) end)
				}))
				return true
			end)
		}))
	end

	if MP.UTILS.is_in_pvp_blind() and G.GAME.blind.config.blind.key == "bl_mp_clash" then
		MP.UTILS.re_sort_players()
	end
end

handlers.ante = function(player, is_local, is_nemesis)
	if is_local then
		play_sound('highlight2', 0.685, 0.2)
		play_sound('generic1')
	end
end

function M.dispatch(player_id, key)
	local player = MP.LOBBY.players[player_id]
	local is_local = player_id == MP.LOBBY.local_id
	local is_nemesis = MP.UTILS.is_in_pvp_blind() and G.GAME.blind.config.blind.key == "bl_mp_nemesis"
	local handler = handlers[key]
	if handler then
		handler(player, is_local, is_nemesis)
	end
end

return M
