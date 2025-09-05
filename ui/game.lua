local create_UIBox_blind_choice_ref = create_UIBox_blind_choice
function create_UIBox_blind_choice(type, run_info)
	-- Fallback to original function if not in multiplayer
	if not MP.LOBBY.code then
		return create_UIBox_blind_choice_ref(type, run_info)
	end

	-- Set default blind if not present
	G.GAME.blind_on_deck = G.GAME.blind_on_deck or "Small"
	if not run_info then
		G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = "Select"
	end

	type = type or "Small"
	local disabled = false

	-- Build blind_choice object
	local blind_choice = {
		config = G.P_BLINDS[G.GAME.round_resets.blind_choices[type]],
	}


	-- Orbital choices setup
	MP.UTILS.setup_orbital_choices(type)
	G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante

	-- config for UI
	local config = {
		run_info = run_info,
		type = type,
		blind_choice = blind_choice,
		disabled = disabled,
	}

	return MP.UIDEF.blind_choice_box(config)
end

function MP.end_round()
	-- This prevents duplicate execution during certain cases. e.g. Full deck discard before playing any hands.
	if MP.GAME.round_ended then 
		if not MP.GAME.duplicate_end then
			MP.GAME.duplicate_end = true
			sendDebugMessage('Duplicate end_round calls prevented.', 'MULTIPLAYER'); 
		end
		return true 
	end 

	MP.GAME.round_ended  = true	
	
	G.GAME.blind.in_blind = false
	local game_over = false
	local game_won = false
	G.RESET_BLIND_STATES = true
	G.RESET_JIGGLES = true
	-- context.end_of_round calculations
	SMODS.saved = false
	SMODS.calculate_context({ end_of_round = true, game_over = false })

	G.GAME.unused_discards = (G.GAME.unused_discards or 0) + G.GAME.current_round.discards_left
	if G.GAME.blind and G.GAME.blind.config.blind then
		discover_card(G.GAME.blind.config.blind)
	end

	if G.GAME.blind:get_type() == "Boss" then
		local _handname, _played, _order = "High Card", -1, 100
		for k, v in pairs(G.GAME.hands) do
			if v.played > _played or (v.played == _played and _order > v.order) then
				_played = v.played
				_handname = k
			end
		end
		G.GAME.current_round.most_played_poker_hand = _handname
	end

	if G.GAME.blind:get_type() == "Boss" and not G.GAME.seeded and not G.GAME.challenge then
		G.GAME.current_boss_streak = G.GAME.current_boss_streak + 1
		check_and_set_high_score("boss_streak", G.GAME.current_boss_streak)
	end

	if G.GAME.current_round.hands_played == 1 then
		inc_career_stat("c_single_hand_round_streak", 1)
	else
		if not G.GAME.seeded and not G.GAME.challenge then
			G.PROFILES[G.SETTINGS.profile].career_stats.c_single_hand_round_streak = 0
			G:save_settings()
		end
	end

	check_for_unlock({ type = "round_win" })
	set_joker_usage()
	for _, v in ipairs(SMODS.get_card_areas("playing_cards", "end_of_round")) do
		SMODS.calculate_end_of_round_effects({ cardarea = v, end_of_round = true })
	end

	G.FUNCS.draw_from_hand_to_discard()
	if G.GAME.blind:get_type() == "Boss" then
		G.GAME.voucher_restock = nil
		if G.GAME.modifiers.set_eternal_ante and (G.GAME.round_resets.ante == G.GAME.modifiers.set_eternal_ante) then
			for k, v in ipairs(G.jokers.cards) do
				v:set_eternal(true)
			end
		end
		if
				G.GAME.modifiers.set_joker_slots_ante
				and (G.GAME.round_resets.ante == G.GAME.modifiers.set_joker_slots_ante)
		then
			G.jokers.config.card_limit = 0
		end
		delay(0.4)
		ease_ante(1)
		delay(0.4)
		check_for_unlock({ type = "ante_up", ante = G.GAME.round_resets.ante + 1 })
	end
	G.FUNCS.draw_from_discard_to_deck()
	
	-- This handles an edge case where a player plays no hands, and discards the only cards in their deck.
	-- Allows opponent to advance after playing anything, and eases a life from the person who discarded their deck.
	if G.GAME.current_round.hands_played == 0 
	   and G.GAME.current_round.discards_used > 0
	   and MP.LOBBY.config.gamemode ~= "gamemode_mp_survival" then
			if MP.UTILS.is_in_online_blind() then
				MP.ACTIONS.play_hand(0, 0)
			end
			
			MP.ACTIONS.fail_round(1)
	end	

	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.3,
		func = function()
			G.STATE = G.STATES.ROUND_EVAL
			G.STATE_COMPLETE = false

			local temp_furthest_blind = 0

			if G.GAME.round_resets.blind_states.Small ~= "Defeated" and G.GAME.round_resets.blind_states.Small ~= "Skipped" then
				G.GAME.round_resets.blind_states.Small = "Defeated"
				temp_furthest_blind = G.GAME.round_resets.ante * 10 + 1
			elseif G.GAME.round_resets.blind_states.Big ~= "Defeated" and G.GAME.round_resets.blind_states.Big ~= "Skipped" then
				G.GAME.round_resets.blind_states.Big = "Defeated"
				temp_furthest_blind = G.GAME.round_resets.ante * 10 + 2
			else
				G.GAME.current_round.voucher = SMODS.get_next_vouchers()
				G.GAME.round_resets.blind_states.Boss = "Defeated"
				temp_furthest_blind = (G.GAME.round_resets.ante - 1) * 10 + 3
				for k, v in ipairs(G.playing_cards) do
					v.ability.played_this_ante = nil
				end
			end

			MP.ACTIONS.set_furthest_blind(temp_furthest_blind)

			MP.GAME.pincher_index = MP.GAME.pincher_index + 1

			if G.GAME.round_resets.temp_handsize then
				G.hand:change_size(-G.GAME.round_resets.temp_handsize)
				G.GAME.round_resets.temp_handsize = nil
			end
			if G.GAME.round_resets.temp_reroll_cost then
				G.GAME.round_resets.temp_reroll_cost = nil
				calculate_reroll_cost(true)
			end

			reset_idol_card()
			reset_mail_rank()
			reset_ancient_card()
			reset_castle_card()
			for _, mod in ipairs(SMODS.mod_list) do
				if mod.reset_game_globals and type(mod.reset_game_globals) == "function" then
					mod.reset_game_globals(false)
				end
			end
			for k, v in ipairs(G.playing_cards) do
				v.ability.discarded = nil
				v.ability.forced_selection = nil
			end
			return true
		end,
	}))
	return true
end