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
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			G.GAME.round_resets.ante = G.GAME.round_resets.ante + mod
			check_and_set_high_score("furthest_ante", G.GAME.round_resets.ante)
			return true
		end,
	}))
end

local end_round_ref = end_round
function end_round()
	if MP.LOBBY.code then
		if MP.LOBBY.local_player.game_state.lives ~= 0 and MP.LOBBY.config.gold_on_life_loss then
			MP.LOBBY.local_player.comeback_bonus_given = false
			MP.LOBBY.local_player.comeback_bonus = (MP.LOBBY.local_player.comeback_bonus or 0) + 1
		end
		if MP.LOBBY.config.no_gold_on_round_loss and (G.GAME.blind and G.GAME.blind.dollars) then
			G.GAME.blind.dollars = 0
		end
	end
	end_round_ref()
end

local reset_blinds_ref = reset_blinds
function reset_blinds()
	reset_blinds_ref()
	G.GAME.round_resets.pvp_blind_choices = {}
	MP.ACTIONS.new_round()

	if MP.LOBBY.code then
		local mp_small_choice, mp_big_choice, mp_boss_choice = MP.Gamemodes[MP.LOBBY.config.gamemode]:get_blinds_by_ante(
			G.GAME.round_resets.ante, G.GAME.round_resets.blind_choices)
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

local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
	sendTraceMessage(string.format("Client sent message: action:moneyMoved,amount:%s", tostring(mod)), "MULTIPLAYER")
	return ease_dollars_ref(mod, instant)
end

local set_main_menu_UI_ref = set_main_menu_UI
---@diagnostic disable-next-line: lowercase-global
function set_main_menu_UI()
	if MP.LOBBY.code then
		if G.MAIN_MENU_UI then
			G.MAIN_MENU_UI:remove()
		end
		if G.STAGE == G.STAGES.MAIN_MENU then
			G.FUNCS.display_lobby_main_menu_UI()

			local ready_button_ref = G.MAIN_MENU_UI:get_UIE_by_ID("ready_button")
			if ready_button_ref then
				MP.LOBBY.ready_text = MP.LOBBY.local_player.lobby_state.is_ready and localize("b_unready") or localize("b_ready")
				ready_button_ref.config.colour = MP.LOBBY.local_player.lobby_state.is_ready and G.C.GREEN or G.C.RED
			end
		end
	else
		set_main_menu_UI_ref()
	end
end

function nope_a_joker(card)
	attention_text({
		text = localize("k_nope_ex"),
		scale = 0.8,
		hold = 0.8,
		major = card,
		backdrop_colour = G.C.SECONDARY_SET.Tarot,
		align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and "tm" or "cm",
		offset = {
			x = 0,
			y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0,
		},
		silent = true,
	})
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.06 * G.SETTINGS.GAMESPEED,
		blockable = false,
		blocking = false,
		func = function()
			play_sound("tarot2", 0.76, 0.4)
			return true
		end,
	}))
	play_sound("tarot2", 1, 0.4)
end

function wheel_of_fortune_the_card(card)
	math.randomseed(os.time())
	local chance = math.random(4)
	if chance == 1 then
		local editions = {
			{ name = 'e_foil',       weight = 499 },
			{ name = 'e_holo',       weight = 350 },
			{ name = 'e_polychrome', weight = 150 },
			{ name = 'e_negative',   weight = 1 }
		}
		local edition = poll_edition("main_menu" .. os.time(), nil, nil, true, editions)
		card:set_edition(edition, true)
		MP.UI_UTILS.juice_up(card, 0.3, 0.5)
		G.CONTROLLER.locks.edition = false -- if this isn't done, set_edition will block inputs for 0.1s
	else
		nope_a_joker(card)
		MP.UI_UTILS.juice_up(card, 0.3, 0.5)
	end
end
