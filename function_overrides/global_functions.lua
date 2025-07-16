local ease_ante_ref = ease_ante
function ease_ante(mod)
	if not MP.LOBBY.code or MP.LOBBY.config.disable_live_and_timer_hud then
		return ease_ante_ref(mod)
	end
	-- Prevents easing multiple times at once
	if MP.GAME.antes_keyed[MP.GAME.ante_key] then
		return
	end
	MP.GAME.antes_keyed[MP.GAME.ante_key] = true
	MP.ACTIONS.set_ante(G.GAME.round_resets.ante + mod)
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			G.GAME.round_resets.ante = G.GAME.round_resets.ante + mod
			check_and_set_high_score("furthest_ante", G.GAME.round_resets.ante)
			return true
		end,
	}))
end

local reset_blinds_ref = reset_blinds
function reset_blinds()
	reset_blinds_ref()
	G.GAME.round_resets.pvp_blind_choices = {}
	MP.ACTIONS.new_round()

	if MP.LOBBY.code then
		local mp_small_choice, mp_big_choice, mp_boss_choice = MP.Gamemodes[MP.LOBBY.config.gamemode]:get_blinds_by_ante(G.GAME.round_resets.ante, G.GAME.round_resets.blind_choices)
		G.GAME.round_resets.blind_choices.Small = mp_small_choice
		G.GAME.round_resets.blind_choices.Big = mp_big_choice
		if MP.LOBBY.config.gamemode ~= "gamemode_mp_coopSurvival" then
			G.GAME.round_resets.blind_choices.Boss = mp_boss_choice
		end
	end
end

local get_blind_main_colourref = get_blind_main_colour
function get_blind_main_colour(type) -- handles ui colour stuff
	local nemesis = G.GAME.round_resets.blind_choices[type] == "bl_mp_nemesis" or type == "bl_mp_nemesis"
	if nemesis then
		type = MP.UTILS.get_nemesis_key()
	end
	return get_blind_main_colourref(type)
end