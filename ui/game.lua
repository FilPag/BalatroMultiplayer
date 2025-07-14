local player_state_manager = SMODS.load_file('networking/player_state_manager.lua', 'Multiplayer')()


local create_UIBox_blind_choice_ref = create_UIBox_blind_choice
---@diagnostic disable-next-line: lowercase-global
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
		config = G.P_BLINDS[blind_choice_key],
	}
	-- Setup animation atlas and position
	local blind_atlas = blind_choice.config.atlas or "blind_chips"
	local blind_pos = blind_choice.config.pos

	if G.GAME.round_resets.blind_choices[type] == "bl_mp_nemesis" then
		local nemesis_blind_col = MP.UTILS.get_nemesis_key() or nil

		blind_atlas = "mp_player_blind_col"
		blind_pos = G.P_BLINDS[nemesis_blind_col].pos
	end

	blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, G.ANIMATION_ATLAS[blind_atlas], blind_pos)
	blind_choice.animation:define_draw_steps({
		{ shader = "dissolve", shadow_height = 0.05 },
		{ shader = "dissolve" },
	})

	-- Build extras UI
	local extras = nil
	
	-- Orbital choices setup
	setup_orbital_choices(type)

	-- Blind ante fallback
	G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante

	-- Localization
	local loc_target = localize({
		type = "raw_descriptions",
		key = blind_choice.config.key,
		set = "Blind",
		vars = { blind_choice.config.key == "bl_ox" and localize(G.GAME.current_round.most_played_poker_hand, "poker_hands") or "" },
	})
-- Text table
	local text_table = loc_target
	if G.GAME.round_resets.pvp_blind_choices[type] then
		text_table[#text_table + 1] = localize("k_bl_mostchips")
	end

	-- Blind color
	local blind_col = get_blind_main_colour(type)

	-- Blind amount
	local blind_amt = get_blind_amt(type, blind_choice)
	-- Coop Survival scaling
	if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and type == "Boss" then
		blind_amt = blind_amt * #MP.LOBBY.players
	end

	

	-- Blind state and reward
	local blind_state = G.GAME.round_resets.blind_states[type]
	if blind_state == "Select" then blind_state = "Current" end
	local _reward = not (G.GAME.modifiers.no_blind_reward and G.GAME.modifiers.no_blind_reward[type])

	-- Params for UI
	local params = {
		type = type,
		run_info = run_info,
		blind_choice = blind_choice,
		extras = extras,
		blind_col = blind_col,
		blind_amt = blind_amt,
		text_table = text_table,
		blind_state = blind_state,
		disabled = disabled,
		stake_sprite = stake_sprite,
		_reward = _reward,
	}

	return MP.UIDEF.blind_choice_box(run_info, params)
end


-- the 5 hooks below handle ui related stuff with custom blinds

local get_blind_main_colourref = get_blind_main_colour
function get_blind_main_colour(type) -- handles ui colour stuff
	local nemesis = G.GAME.round_resets.blind_choices[type] == "bl_mp_nemesis" or type == "bl_mp_nemesis"
	if nemesis then
		type = MP.UTILS.get_nemesis_key()
	end
	return get_blind_main_colourref(type)
end

local blind_change_colourref = Blind.change_colour
function Blind:change_colour(blind_col) -- ensures that small/big blinds have proper colouration
	local small = false
	if self.config.blind.key == 'bl_mp_nemesis' then
		local blind_key = MP.UTILS.get_nemesis_key()
		if blind_key == "bl_small" or blind_key == "bl_big" then
			small = true
		end
	end
	local boss = self.boss
	if small then self.boss = false end
	blind_change_colourref(self, blind_col)
	self.boss = boss
end

local blind_set_blindref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
	-- Adjust blind multiplier for coop survival mode
	if blind and MP.LOBBY.code and MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and blind.boss then
		blind.mult = blind.mult * #MP.LOBBY.players
		player_state_manager.reset_scores()
		G.GAME.chips = 0
	end

	blind_set_blindref(self, blind, reset, silent)

	-- Special handling for nemesis blind
	if blind and blind.key == 'bl_mp_nemesis' then
		local boss = true
		local showdown = false
		local blind_key = MP.UTILS.get_nemesis_key()
		if blind_key == "bl_small" or blind_key == "bl_big" then
			boss = false
		end
		if blind_key == "bl_final_heart" then
			showdown = true
		end
		G.ARGS.spin.real = (G.SETTINGS.reduced_motion and 0 or 1) * (boss and (showdown and 0.5 or 0.25) or 0)
	end
end

local ease_background_colour_blindref = ease_background_colour_blind
function ease_background_colour_blind(state, blind_override) -- handles background
	local blindname = ((blind_override or (G.GAME.blind and G.GAME.blind.name ~= '' and G.GAME.blind.name)) or 'Small Blind')
	local blindname = (blindname == '' and 'Small Blind' or blindname)
	if blindname == "bl_mp_nemesis" then
		blind_override = MP.UTILS.get_nemesis_key()
		for k, v in pairs(G.P_BLINDS) do
			if blind_override == k then
				blind_override = v.name
			end
		end
	end
	return ease_background_colour_blindref(state, blind_override)
end

local add_round_eval_rowref = add_round_eval_row
function add_round_eval_row(config) -- if i could post a skull emoji i would, wtf is this (cashout screen)
	if config.name == 'blind1' and G.GAME.blind.config.blind.key == "bl_mp_nemesis" then
		G.P_BLINDS["bl_mp_nemesis"].atlas = 'mp_player_blind_col'
		G.GAME.blind.pos = G.P_BLINDS[MP.UTILS.get_nemesis_key()].pos -- this one is getting reset so no need to bother
		add_round_eval_rowref(config)
		G.E_MANAGER:add_event(Event({
			trigger = 'before',
			delay = 0.0,
			func = function()
				G.P_BLINDS["bl_mp_nemesis"].atlas = "mp_player_blind_chip" -- lmao
				return true
			end,
		}))
	else
		add_round_eval_rowref(config)
	end
end

G.FUNCS.blind_choice_handler = function(e)
	if
			not e.config.ref_table.run_info
			and G.blind_select
			and G.blind_select.VT.y < 10
			and e.config.id
			and G.blind_select_opts[string.lower(e.config.id)]
	then
		if e.UIBox.role.xy_bond ~= "Weak" then
			e.UIBox:set_role({ xy_bond = "Weak" })
		end
		if
				(e.config.ref_table.deck ~= "on" and e.config.id == G.GAME.blind_on_deck)
				or (e.config.ref_table.deck ~= "off" and e.config.id ~= G.GAME.blind_on_deck)
		then
			local _blind_choice = G.blind_select_opts[string.lower(e.config.id)]
			local _top_button = e.UIBox:get_UIE_by_ID("select_blind_button")
			local _border = e.UIBox.UIRoot.children[1].children[1]
			local _tag = e.UIBox:get_UIE_by_ID("tag_" .. e.config.id)
			local _tag_container = e.UIBox:get_UIE_by_ID("tag_container")
			if
					_tag_container
					and not G.SETTINGS.tutorial_complete
					and not G.SETTINGS.tutorial_progress.completed_parts["shop_1"]
			then
				_tag_container.states.visible = false
			elseif _tag_container then
				_tag_container.states.visible = true
			end
			if e.config.id == G.GAME.blind_on_deck then
				e.config.ref_table.deck = "on"
				e.config.draw_after = false
				e.config.colour = G.C.CLEAR
				_border.parent.config.outline = 2
				_border.parent.config.outline_colour = G.C.UI.TRANSPARENT_DARK
				_border.config.outline_colour = _border.config.outline and _border.config.outline_colour
						or get_blind_main_colour(e.config.id)
				_border.config.outline = 1.5
				_blind_choice.alignment.offset.y = -0.9
				if _tag and _tag_container then
					_tag_container.children[2].config.draw_after = false
					_tag_container.children[2].config.colour = G.C.BLACK
					_tag.children[2].config.button = "skip_blind"
					_tag.config.outline_colour = adjust_alpha(G.C.BLUE, 0.5)
					_tag.children[2].config.hover = true
					_tag.children[2].config.colour = G.C.RED
					_tag.children[2].children[1].config.colour = G.C.UI.TEXT_LIGHT
					local _sprite = _tag.config.ref_table
					_sprite.config.force_focus = nil
				end
				if _top_button then
					G.E_MANAGER:add_event(Event({
						func = function()
							G.CONTROLLER:snap_to({ node = _top_button })
							return true
						end,
					}))
					if _top_button.config.button ~= "mp_toggle_ready" then
						_top_button.config.button = "select_blind"
					end
					_top_button.config.colour = G.C.FILTER
					_top_button.config.hover = true
					_top_button.children[1].config.colour = G.C.WHITE
				end
			elseif e.config.id ~= G.GAME.blind_on_deck then
				e.config.ref_table.deck = "off"
				e.config.draw_after = true
				e.config.colour = adjust_alpha(
					G.GAME.round_resets.blind_states[e.config.id] == "Skipped"
					and mix_colours(G.C.BLUE, G.C.L_BLACK, 0.1)
					or G.C.L_BLACK,
					0.5
				)
				_border.parent.config.outline = nil
				_border.parent.config.outline_colour = nil
				_border.config.outline_colour = nil
				_border.config.outline = nil
				_blind_choice.alignment.offset.y = -0.2
				if _tag and _tag_container then
					if
							G.GAME.round_resets.blind_states[e.config.id] == "Skipped"
							or G.GAME.round_resets.blind_states[e.config.id] == "Defeated"
					then
						_tag_container.children[2]:set_role({ xy_bond = "Weak" })
						_tag_container.children[2]:align(0, 10)
						_tag_container.children[1]:set_role({ xy_bond = "Weak" })
						_tag_container.children[1]:align(0, 10)
					end
					if G.GAME.round_resets.blind_states[e.config.id] == "Skipped" then
						_blind_choice.children.alert = UIBox({
							definition = create_UIBox_card_alert({
								text_rot = -0.35,
								no_bg = true,
								text = localize("k_skipped_cap"),
								bump_amount = 1,
								scale = 0.9,
								maxw = 3.4,
							}),
							config = {
								align = "tmi",
								offset = { x = 0, y = 2.2 },
								major = _blind_choice,
								parent = _blind_choice,
							},
						})
					end
					_tag.children[2].config.button = nil
					_tag.config.outline_colour = G.C.UI.BACKGROUND_INACTIVE
					_tag.children[2].config.hover = false
					_tag.children[2].config.colour = G.C.UI.BACKGROUND_INACTIVE
					_tag.children[2].children[1].config.colour = G.C.UI.TEXT_INACTIVE
					local _sprite = _tag.config.ref_table
					_sprite.config.force_focus = true
				end
				if _top_button then
					_top_button.config.colour = G.C.UI.BACKGROUND_INACTIVE
					_top_button.config.button = nil
					_top_button.config.hover = false
					_top_button.children[1].config.colour = G.C.UI.TEXT_INACTIVE
				end
			end
		end
	end
end

G.FUNCS.pvp_ready_button = function(e)
	if e.children[1].config.ref_table[e.children[1].config.ref_value] == localize("Select", "blind_states") then
		e.config.button = "mp_toggle_ready"
		e.config.one_press = false
		e.children[1].config.ref_table = MP.GAME
		e.children[1].config.ref_value = "ready_blind_text"
	end
	if e.config.button == "mp_toggle_ready" then
		e.config.colour = (MP.GAME.ready_blind and G.C.GREEN) or G.C.RED
	end
end



local function reset_blind_HUD()
	if MP.LOBBY.code then
		G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object.config.string =
		{ { ref_table = G.GAME.blind, ref_value = "loc_name" } }
		G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:update_text()
		G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_table = G.GAME.blind
		G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_value = "chip_text"
		G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[1].children[1].config.text =
				localize("ph_blind_score_at_least")
		G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[3].children[1].config.text =
				localize("ph_blind_reward")
		G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object.config.string =
		{ { ref_table = G.GAME.current_round, ref_value = "dollars_to_be_earned" } }
		G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object:update_text()
	end
end

function G.FUNCS.mp_toggle_ready(e)
	sendTraceMessage("Toggling Ready", "MULTIPLAYER")
	MP.GAME.ready_blind = not MP.GAME.ready_blind
	MP.GAME.ready_blind_text = MP.GAME.ready_blind and localize("b_unready") or localize("b_ready")

	if MP.GAME.ready_blind then
		MP.ACTIONS.set_location("loc_ready")
		MP.ACTIONS.ready_blind(e)
	else
		MP.ACTIONS.set_location("loc_selecting")
		MP.ACTIONS.unready_blind()
	end
end

local blind_defeat_ref = Blind.defeat
function Blind:defeat(silent)
	blind_defeat_ref(self, silent)
	reset_blind_HUD()
end

local function eval_hand_and_jokers()
	for i = 1, #G.hand.cards do
		--Check for hand doubling
		local reps = { 1 }
		local j = 1
		while j <= #reps do
			local percent = (i - 0.999) / (#G.hand.cards - 0.998) + (j - 1) * 0.1
			if reps[j] ~= 1 then
				card_eval_status_text(
					(reps[j].jokers or reps[j].seals).card,
					"jokers",
					nil,
					nil,
					nil,
					(reps[j].jokers or reps[j].seals)
				)
			end

			--calculate the hand effects
			local effects = { G.hand.cards[i]:get_end_of_round_effect() }
			for k = 1, #G.jokers.cards do
				--calculate the joker individual card effects
				local eval = G.jokers.cards[k]:calculate_joker({
					cardarea = G.hand,
					other_card = G.hand.cards[i],
					individual = true,
					end_of_round = true,
				})
				if eval then
					table.insert(effects, eval)
				end
			end

			if reps[j] == 1 then
				--Check for hand doubling
				--From Red seal
				local eval = eval_card(
					G.hand.cards[i],
					{ end_of_round = true, cardarea = G.hand, repetition = true, repetition_only = true }
				)
				if next(eval) and (next(effects[1]) or #effects > 1) then
					for h = 1, eval.seals.repetitions do
						reps[#reps + 1] = eval
					end
				end

				--from Jokers
				for j = 1, #G.jokers.cards do
					--calculate the joker effects
					local eval = eval_card(G.jokers.cards[j], {
						cardarea = G.hand,
						other_card = G.hand.cards[i],
						repetition = true,
						end_of_round = true,
						card_effects = effects,
					})
					if next(eval) then
						for h = 1, eval.jokers.repetitions do
							reps[#reps + 1] = eval
						end
					end
				end
			end

			for ii = 1, #effects do
				--if this effect came from a joker
				if effects[ii].card then
					G.E_MANAGER:add_event(Event({
						trigger = "immediate",
						func = function()
							effects[ii].card:juice_up(0.7)
							return true
						end,
					}))
				end

				--If dollars
				if effects[ii].h_dollars then
					ease_dollars(effects[ii].h_dollars)
					card_eval_status_text(G.hand.cards[i], "dollars", effects[ii].h_dollars, percent)
				end

				--Any extras
				if effects[ii].extra then
					card_eval_status_text(G.hand.cards[i], "extra", nil, percent, nil, effects[ii].extra)
				end
			end
			j = j + 1
		end
	end
end

local update_hand_played_ref = Game.update_hand_played
---@diagnostic disable-next-line: duplicate-set-field
function Game:update_hand_played(dt)
	-- Ignore for singleplayer or regular blinds
	if not MP.LOBBY.connected or not MP.LOBBY.code or not MP.is_online_boss() then
		update_hand_played_ref(self, dt)
		return
	end

	if self.buttons then
		self.buttons:remove()
		self.buttons = nil
	end
	if self.shop then
		self.shop:remove()
		self.shop = nil
	end

	if not G.STATE_COMPLETE then
		G.STATE_COMPLETE = true
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			func = function()
				if MP.LOBBY.config.gamemode ~= "gamemode_mp_coopSurvival" then
					G.GAME.blind.chip_text = MP.INSANE_INT.to_string(MP.UTILS.get_nemesis().score)
				end
				-- For now, never advance to next round
				if G.GAME.current_round.hands_left < 1 then
					attention_text({
						scale = 0.8,
						text = localize("k_wait_enemy"),
						hold = 5,
						align = "cm",
						offset = { x = 0, y = -1.5 },
						major = G.play,
					})
					if G.hand.cards[1] and G.STATE == G.STATES.HAND_PLAYED then
						eval_hand_and_jokers()
						G.FUNCS.draw_from_hand_to_discard()
					end
				elseif not MP.GAME.end_pvp and G.STATE == G.STATES.HAND_PLAYED then
					G.STATE_COMPLETE = false
					G.STATE = G.STATES.DRAW_TO_HAND
				end
				return true
			end,
		}))
	end

	if MP.GAME.end_pvp and MP.is_online_boss() then
		G.STATE_COMPLETE = false
		G.STATE = G.STATES.NEW_ROUND
		MP.GAME.end_pvp = false
	end

	if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and MP.is_online_boss() then
		if G.GAME.chips - G.GAME.blind.chips >= 0 then
			G.STATE_COMPLETE = false
			G.STATE = G.STATES.NEW_ROUND
			player_state_manager.reset_scores()
		end
	end
end

local can_play_ref = G.FUNCS.can_play
G.FUNCS.can_play = function(e)
	if G.GAME.current_round.hands_left <= 0 then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		can_play_ref(e)
	end
end

local update_new_round_ref = Game.update_new_round
function Game:update_new_round(dt)
	if MP.GAME.end_pvp then
		G.FUNCS.draw_from_hand_to_deck()
		G.FUNCS.draw_from_discard_to_deck()
		MP.GAME.end_pvp = false
	end
	if MP.LOBBY.code and not G.STATE_COMPLETE then
		-- Prevent player from losing
		if to_big(G.GAME.chips) < to_big(G.GAME.blind.chips) and not MP.is_online_boss() then
			G.GAME.blind.chips = -1
			MP.GAME.wait_for_enemys_furthest_blind = (MP.LOBBY.config.gamemode == "gamemode_mp_survival") and
					(tonumber(MP.UTILS.get_local_player().lives) == 1) -- In Survival Mode, if this is the last live, wait for the enemy.
			MP.ACTIONS.fail_round(G.GAME.current_round.hands_played)
		end

		-- Prevent player from winning
		G.GAME.win_ante = 999

		if MP.LOBBY.config.gamemode == "gamemode_mp_survival" and MP.GAME.wait_for_enemys_furthest_blind then
			G.STATE_COMPLETE = true
			G.FUNCS.draw_from_hand_to_discard()
			attention_text({
				scale = 0.8,
				text = localize("k_wait_enemy_reach_this_blind"),
				hold = 5,
				align = "cm",
				offset = { x = 0, y = -1.5 },
				major = G.play,
			})
		else
			update_new_round_ref(self, dt)
		end

		-- Reset ante number
		G.GAME.win_ante = 8
		return
	end
	update_new_round_ref(self, dt)
end

function MP.end_round()
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

local start_run_ref = Game.start_run
function Game:start_run(args)
	start_run_ref(self, args)

	if not MP.LOBBY.connected or not MP.LOBBY.code or MP.LOBBY.config.disable_live_and_timer_hud then
		return
	end
	local scale = 0.4
	local hud_ante = G.HUD:get_UIE_by_ID("hud_ante")
	hud_ante.children[1].children[1].config.text = localize("k_lives")

	-- Set lives number
	hud_ante.children[2].children[1].config.object = DynaText({
		string = { { ref_table = MP.UTILS.get_local_player(), ref_value = "lives" } },
		colours = { G.C.IMPORTANT },
		shadow = true,
		font = G.LANGUAGES["en-us"].font,
		scale = 2 * scale,
	})

	-- Remove unnecessary HUD elements from ante counter
	hud_ante.children[2].children[2] = nil
	hud_ante.children[2].children[3] = nil
	hud_ante.children[2].children[4] = nil

	G.HUD:recalculate();
end

function G.FUNCS.overlay_endgame_menu()
	G.FUNCS.overlay_menu({
		definition = MP.GAME.won and create_UIBox_win() or create_UIBox_game_over(),
		config = { no_esc = true }
	})
	G.E_MANAGER:add_event(Event({
		trigger = 'after',
		delay = 2.5,
		blocking = false,
		func = (function()
			if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('jimbo_spot') then
				local Jimbo = Card_Character({ x = 0, y = 5 })
				local spot = G.OVERLAY_MENU:get_UIE_by_ID('jimbo_spot')
				spot.config.object:remove()
				spot.config.object = Jimbo
				Jimbo.ui_object_updated = true
				local jimbo_words = MP.GAME.won and 'wq_' .. math.random(1, 7) or 'lq_' .. math.random(1, 10)
				Jimbo:add_speech_bubble(jimbo_words, nil, { quip = true })
				Jimbo:say_stuff(5)
			end
			return true
		end)
	}))
end

function G.UIDEF.view_nemesis_deck()
	local playing_cards_ref = G.playing_cards
	G.playing_cards = MP.nemesis_cards
	local t = G.UIDEF.view_deck()
	G.playing_cards = playing_cards_ref
	return t
end

function G.UIDEF.create_UIBox_view_nemesis_deck()
	return create_UIBox_generic_options(
		{
			back_func = 'overlay_endgame_menu',
			contents = {
				create_tabs({
					tabs = {
						{
							label = localize('k_nemesis_deck'),
							chosen = true,
							tab_definition_function = G.UIDEF.view_nemesis_deck
						},
						{
							label = localize('k_your_deck'),
							tab_definition_function = G.UIDEF.view_deck
						},
					},
					tab_h = 8,
					snap_to_nav = true
				})
			},
		})
end

function G.FUNCS.view_nemesis_deck()
	G.SETTINGS.paused = true
	if G.deck_preview then
		G.deck_preview:remove()
		G.deck_preview = nil
	end
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_view_nemesis_deck()
	})
end

function ease_lives(mod)
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			if not G.hand_text_area then
				return
			end

			if MP.LOBBY.config.disable_live_and_timer_hud then
				return true -- Returning nothing hangs the game because it's a part of an event
			end

			local lives_UI = G.hand_text_area.ante
			mod = mod or 0
			local text = "+"
			local col = G.C.IMPORTANT
			if mod < 0 then
				text = "-"
				col = G.C.RED
			end
			lives_UI.config.object:update()
			G.HUD:recalculate()
			attention_text({
				text = text .. tostring(math.abs(mod)),
				scale = 1,
				hold = 0.7,
				cover = lives_UI.parent,
				cover_colour = col,
				align = "cm",
			})
			play_sound("highlight2", 0.685, 0.2)
			play_sound("generic1")
			return true
		end,
	}))
end

local exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
---@diagnostic disable-next-line: duplicate-set-field
function G.FUNCS:exit_overlay_menu()
	-- Saves username if user presses ESC instead of Enter
	if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID("username_input_box") ~= nil then
		MP.UTILS.save_username(MP.LOBBY.username)
	end

	exit_overlay_menu_ref(self)
end

local mods_button_ref = G.FUNCS.mods_button
function G.FUNCS.mods_button(arg_736_0)
	if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID("username_input_box") ~= nil then
		MP.UTILS.save_username(MP.LOBBY.username)
	end

	mods_button_ref(arg_736_0)
end

local can_open_ref = G.FUNCS.can_open
G.FUNCS.can_open = function(e)
	if MP.GAME.ready_blind then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
		return
	end
	can_open_ref(e)
end

local blind_disable_ref = Blind.disable
function Blind:disable()
	if MP.is_online_boss() and not (G.GAME.blind and G.GAME.blind.name == 'Verdant Leaf') then -- hackfix to make verdant work properly
		return
	end
	blind_disable_ref(self)
end

G.FUNCS.multiplayer_blind_chip_UI_scale = function(e)
	local score_ref = MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and MP.GAME.coop or MP.UTILS.get_nemesis()

	if not score_ref or not score_ref.score then
		if score_ref then score_ref.score_text = "" end
		return
	end

	local new_score_text = MP.INSANE_INT.to_string(score_ref.score)
	if G.GAME.blind and score_ref.score and score_ref.score_text ~= new_score_text then
		if not MP.INSANE_INT.greater_than(score_ref.score, MP.INSANE_INT.create(0, G.E_SWITCH_POINT, 0)) then
			e.config.scale = scale_number(score_ref.score.coeffiocient, 0.7, 100000)
		end
		score_ref.score_text = new_score_text
	end
end

local select_blind_ref = G.FUNCS.select_blind
function G.FUNCS.select_blind(e)
	MP.GAME.end_pvp = false
	MP.GAME.prevent_eval = false
	select_blind_ref(e)
	if MP.LOBBY.code then
		MP.GAME.ante_key = tostring(math.random())
		MP.ACTIONS.play_hand(0, G.GAME.round_resets.hands)
		MP.ACTIONS.set_location("loc_playing-" .. (e.config.ref_table.key or e.config.ref_table.name))
		hide_enemy_location()
	end
end

local skip_blind_ref = G.FUNCS.skip_blind
G.FUNCS.skip_blind = function(e)
	skip_blind_ref(e)
	if MP.LOBBY.code then
		if not MP.GAME.timer_started then
			MP.GAME.timer = MP.GAME.timer + MP.LOBBY.config.timer_increment_seconds
		end
		MP.ACTIONS.skip(G.GAME.skips)

		--Update the furthest blind
		local temp_furthest_blind = 0
		if G.GAME.round_resets.blind_states.Big == "Skipped" then
			temp_furthest_blind = G.GAME.round_resets.ante * 10 + 2
		elseif G.GAME.round_resets.blind_states.Small == "Skipped" then
			temp_furthest_blind = G.GAME.round_resets.ante * 10 + 1
		end

		MP.GAME.furthest_blind = (temp_furthest_blind > MP.GAME.furthest_blind) and temp_furthest_blind or
				MP.GAME.furthest_blind
		MP.ACTIONS.set_furthest_blind(MP.GAME.furthest_blind)
	end
end

function G.FUNCS.open_kofi(e)
	love.system.openURL("https://ko-fi.com/virtualized")
end

function G.FUNCS:continue_in_singleplayer(e)
	MP.LOBBY.code = nil
	MP.ACTIONS.leave_lobby()
	MP.UI.update_connection_status()

	local saveText = MP.UTILS.MP_SAVE()
	G.SAVED_GAME = saveText
	G.SETTINGS.current_setup = 'Continue'
	G:delete_run()

	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		no_delete = true,
		func = function()
			G.FUNCS.start_setup_run(nil)
			return true
		end
	}))
end

--[[
function MP.UI.create_UIBox_Misprint_Display()
	return {
		n = G.UIT.ROOT,
		config = { align = "cm", padding = 0.03, colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.05, colour = G.C.UI.TRANSPARENT_DARK, r = 0.1 },
				nodes = {
					{
						n = G.UIT.O,
						config = {
							id = "misprint_display",
							func = "misprint_display_set",
							object = DynaText({
								string = { { ref_table = MP.GAME, ref_value = "misprint_display" } },
								colours = { G.C.UI.TEXT_LIGHT },
								shadow = true,
								float = true,
								scale = 0.5,
							}),
						},
					},
				},
			},
		},
	}
end

function G.FUNCS.misprint_display_set(e)
	local misprint_raw = (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.id or 11)
		.. (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.suit:sub(1, 1) or "D")
	if misprint_raw == e.config.last_misprint then
		return
	end
	e.config.last_misprint = misprint_raw

	local value = tonumber(misprint_raw:sub(1, -2))
	local suit = misprint_raw:sub(-1)

	local suit_full = { H = "Hearts", D = "Diamonds", C = "Clubs", S = "Spades" }

	local value_key = tostring(value)
	if value == 14 then
		value_key = "Ace"
	elseif value == 11 then
		value_key = "Jack"
	elseif value == 12 then
		value_key = "Queen"
	elseif value == 13 then
		value_key = "King"
	end

	local localized_card = {}

	localize({
		type = "other",
		key = "playing_card",
		set = "Other",
		nodes = localized_card,
		vars = {
			localize(value_key, "ranks"),
			localize(suit_full[suit], "suits_plural"),
			colours = { G.C.UI.TEXT_LIGHT },
		},
	})

	-- Yes I know this is stupid
	MP.GAME.misprint_display = localized_card[1][2].config.text .. localized_card[1][3].config.text
	e.config.object.colours = { G.C.SUITS[suit_full[suit]]
--}
--end
