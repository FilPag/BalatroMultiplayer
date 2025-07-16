function MP.UTILS.setup_orbital_choices(type)
	G.GAME.orbital_choices = G.GAME.orbital_choices or {}
	local ante = G.GAME.round_resets.ante
	G.GAME.orbital_choices[ante] = G.GAME.orbital_choices[ante] or {}

	if not G.GAME.orbital_choices[ante][type] then
		local visible_hands = {}
		for hand, data in pairs(G.GAME.hands) do
			if data.visible then table.insert(visible_hands, hand) end
		end
		G.GAME.orbital_choices[ante][type] = pseudorandom_element(visible_hands, pseudoseed("orbital"))
	end
end

--- Returns the display name for a blind, handling nemesis and fallback
local function get_blind_loc_name(type, blind_choice)
	local key = (G.GAME.round_resets.blind_choices or {})[type]
	if key == "bl_mp_nemesis" then
		local enemy = MP.UTILS.get_nemesis_lobby_data()
		if enemy and enemy.username and #enemy.username > 0 then
			return { { string = enemy.username, colour = G.C.BLUE } }
		end
	end
	return { { string = localize({ type = "name_text", key = blind_choice and blind_choice.config and blind_choice.config.key or key, set = "Blind" }), colour = G.C.WHITE } }
end


local get_blind_amount_ref = get_blind_amount
local function get_blind_amount_MP(type, blind_choice)
	if type == "bl_mp_nemesis" or G.GAME.round_resets.blind_choices[type] == "bl_mp_nemesis" or G.GAME.round_resets.pvp_blind_choices[type] then
		return "????"
	end

	local amount = get_blind_amount_ref(G.GAME.round_resets.blind_ante) * blind_choice.config.mult *
			G.GAME.starting_params.ante_scaling

	if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and type == "Boss" then
		amount = amount * #MP.LOBBY.players
	end

	return amount
end

-- Helper: Get run info color
function MP.UTILS.get_run_info_colour(blind_state)
	if blind_state == "Defeated" then return G.C.GREY end
	if blind_state == "Skipped" then return G.C.BLUE end
	if blind_state == "Upcoming" then return G.C.ORANGE end
	if blind_state == "Current" then return G.C.RED end
	return G.C.GOLD
end

function MP.UIDEF.blind_choice_box(config)
	-- Setup life_or_death_text
	local extras
	if config.type == "Small" or config.type == "Big" then
		extras = create_UIBox_blind_tag(config.type, config.run_info)
	else
		extras = MP.UIDEF.blind_choice_extras(G.GAME.round_resets.blind_choices[config.type])
	end

	-- Setup animation atlas and position
	local blind_atlas = config.blind_choice.config.atlas or "blind_chips"
	local blind_pos = config.blind_choice.config.pos

	if G.GAME.round_resets.blind_choices[config.type] == "bl_mp_nemesis" then
		local nemesis_blind_col = MP.UTILS.get_nemesis_key() or nil

		blind_atlas = "mp_player_blind_col"
		blind_pos = G.P_BLINDS[nemesis_blind_col].pos
	end

	config.blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, G.ANIMATION_ATLAS[blind_atlas], blind_pos)
	config.blind_choice.animation:define_draw_steps({
		{ shader = "dissolve", shadow_height = 0.05 },
		{ shader = "dissolve" },
	})

	-- Setup text table
	local text_table = localize({
		type = "raw_descriptions",
		key = config.blind_choice.config.key,
		set = "Blind",
		vars = { config.blind_choice.config.key == "bl_ox" and localize(G.GAME.current_round.most_played_poker_hand, "poker_hands") or "" },
	})

	if G.GAME.round_resets.pvp_blind_choices[config.type] then
		text_table[#text_table + 1] = localize("k_bl_mostchips")
	end

	local blind_state = G.GAME.round_resets.blind_states[config.type]
	if blind_state == "Select" then blind_state = "Current" end
	local _reward = not (G.GAME.modifiers.no_blind_reward and G.GAME.modifiers.no_blind_reward[config.type])

	-- Blind color
	local blind_col = get_blind_main_colour(config.type)
	-- Blind amount
	local blind_amt = get_blind_amount_MP(config.type, config.blind_choice)

	return {
		n = G.UIT.R,
		config = {
			id = config.type,
			align = "tm",
			func = "blind_choice_handler",
			minh = not config.run_info and 10 or nil,
			ref_table = { deck = nil, run_info = config.run_info },
			r = 0.1,
			padding = 0.05,
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					colour = mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5),
					r = 0.1,
					outline = 1,
					outline_colour = G.C.L_BLACK,
				},
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.2 },
						nodes = {
							not config.run_info and {
								n = G.UIT.R,
								config = {
									id = "select_blind_button",
									align = "cm",
									ref_table = config.blind_choice.config,
									colour = config.disabled and G.C.UI.BACKGROUND_INACTIVE or G.C.ORANGE,
									minh = 0.6,
									minw = 2.7,
									padding = 0.07,
									r = 0.1,
									shadow = true,
									hover = true,
									one_press = true,
									func = (
												G.GAME.round_resets.blind_choices[config.type] == "bl_mp_nemesis"
												or G.GAME.round_resets.pvp_blind_choices[config.type]
												or (
													MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival"
													and (config.type == "Boss")
												)
											)
											and "pvp_ready_button"
											or nil,
									button = "select_blind",
								},
								nodes = {
									{
										n = G.UIT.T,
										config = {
											ref_table = G.GAME.round_resets.loc_blind_states,
											ref_value = config.type,
											scale = 0.45,
											colour = config.disabled and G.C.UI.TEXT_INACTIVE or G.C.UI.TEXT_LIGHT,
											shadow = not config.disabled,
										},
									},
								},
							} or {
								n = G.UIT.R,
								config = {
									id = "select_blind_button",
									align = "cm",
									ref_table = config.blind_choice.config,
									colour = config.disabled and G.C.UI.BACKGROUND_INACTIVE or G.C.ORANGE,
									minh = 0.6,
									minw = 2.7,
									padding = 0.07,
									r = 0.1,
									emboss = 0.08,
								},
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = localize(blind_state, "blind_states"),
											scale = 0.45,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = true,
										},
									},
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { id = "blind_name", align = "cm", padding = 0.07 },
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									r = 0.1,
									outline = 1,
									outline_colour = blind_col,
									colour = darken(blind_col, 0.3),
									minw = 2.9,
									emboss = 0.1,
									padding = 0.07,
									line_emboss = 1,
								},
								nodes = {
									{
										n = G.UIT.O,
										config = {
											object = DynaText({
												string = get_blind_loc_name(config.type, config.blind_choice),
												colours = { config.disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE },
												shadow = not config.disabled,
												float = not config.disabled,
												y_offset = -4,
												scale = 0.45,
												maxw = 2.8,
											}),
										},
									},
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.05 },
						nodes = {
							{
								n = G.UIT.R,
								config = { id = "blind_desc", align = "cm", padding = 0.05 },
								nodes = {
									{
										n = G.UIT.R,
										config = { align = "cm" },
										nodes = {
											{
												n = G.UIT.R,
												config = { align = "cm", minh = 1.5 },
												nodes = {
													{ n = G.UIT.O, config = { object = config.blind_choice.animation } },
												},
											},
											text_table and text_table[1] and {
												n = G.UIT.R,
												config = {
													align = "cm",
													minh = 0.7,
													padding = 0.05,
													minw = 2.9,
												},
												nodes = {
													text_table[1]
													and {
														n = G.UIT.R,
														config = { align = "cm", maxw = 2.8 },
														nodes = {
															{
																n = G.UIT.T,
																config = {
																	id = config.blind_choice.config.key,
																	ref_table = { val = "" },
																	ref_value = "val",
																	scale = 0.32,
																	colour = config.disabled
																			and G.C.UI.TEXT_INACTIVE
																			or G.C.WHITE,
																	shadow = not config.disabled,
																	func = "HUD_blind_debuff_prefix",
																},
															},
															{
																n = G.UIT.T,
																config = {
																	text = text_table[1] or "-",
																	scale = 0.32,
																	colour = config.disabled
																			and G.C.UI.TEXT_INACTIVE
																			or G.C.WHITE,
																	shadow = not config.disabled,
																},
															},
														},
													}
													or nil,
													text_table[2] and {
														n = G.UIT.R,
														config = { align = "cm", maxw = 2.8 },
														nodes = {
															{
																n = G.UIT.T,
																config = {
																	text = text_table[2] or "-",
																	scale = 0.32,
																	colour = config.disabled and G.C.UI.TEXT_INACTIVE
																			or G.C.WHITE,
																	shadow = not config.disabled,
																},
															},
														},
													} or nil,
													text_table[3] and {
														n = G.UIT.R,
														config = { align = "cm", maxw = 2.8 },
														nodes = {
															{
																n = G.UIT.T,
																config = {
																	text = text_table[3] or "-",
																	scale = 0.32,
																	colour = config.disabled and G.C.UI.TEXT_INACTIVE
																			or G.C.WHITE,
																	shadow = not config.disabled,
																},
															},
														},
													} or nil,
												},
											} or nil,
										},
									},
									{
										n = G.UIT.R,
										config = {
											align = "cm",
											r = 0.1,
											padding = 0.05,
											minw = 3.1,
											colour = G.C.BLACK,
											emboss = 0.05,
										},
										nodes = {
											{
												n = G.UIT.R,
												config = { align = "cm", maxw = 3 },
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = localize("ph_blind_score_at_least"),
															scale = 0.3,
															colour = config.disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE,
															shadow = not config.disabled,
														},
													},
												},
											},
											{
												n = G.UIT.R,
												config = { align = "cm", minh = 0.6 },
												nodes = {
													{
														n = G.UIT.O,
														config = {
															w = 0.5,
															h = 0.5,
															colour = G.C.BLUE,
															object = get_stake_sprite(G.GAME.stake or 1, 0.5),
															hover = true,
															can_collide = false,
														},
													},
													{ n = G.UIT.B, config = { h = 0.1, w = 0.1 } },
													{
														n = G.UIT.T,
														config = {
															text = number_format(blind_amt),
															scale = score_number_scale(0.9, blind_amt),
															colour = config.disabled and G.C.UI.TEXT_INACTIVE or G.C.RED,
															shadow = not config.disabled,
														},
													},
												},
											},
											_reward
											and {
												n = G.UIT.R,
												config = { align = "cm" },
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = localize("ph_blind_reward"),
															scale = 0.35,
															colour = config.disabled and G.C.UI.TEXT_INACTIVE
																	or G.C.WHITE,
															shadow = not config.disabled,
														},
													},
													{
														n = G.UIT.T,
														config = {
															text = string.rep(
															---@diagnostic disable-next-line: param-type-mismatch
																localize("$"),
																config.blind_choice.config.dollars
															) .. "+",
															scale = 0.35,
															colour = config.disabled and G.C.UI.TEXT_INACTIVE
																	or G.C.MONEY,
															shadow = not config.disabled,
														},
													},
												},
											}
											or nil,
										},
									},
								},
							},
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = { id = "blind_extras", align = "cm" },
				nodes = {
					extras,
				}
			},
		},
	}
end

function MP.UIDEF.blind_choice_extras(blind_type)
	local texts = {
		{ key = "ph_up_ante_1", colour = G.C.FILTER, scale = 0.55, bump = true },
		{ key = "ph_up_ante_2", colour = G.C.WHITE,  scale = 0.35 },
		{ key = "ph_up_ante_3", colour = G.C.WHITE,  scale = 0.35 },
	}
	if blind_type == "bl_mp_nemesis" then
		texts = {
			{ key = "k_bl_life",  colour = G.C.FILTER, scale = 0.55, bump = true },
			{ key = "k_bl_or",    colour = G.C.WHITE,  scale = 0.35 },
			{ key = "k_bl_death", colour = G.C.FILTER, scale = 0.55, bump = true },
		}
	end

	local nodes = {}
	for i, t in ipairs(texts) do
		local dt = DynaText({
			string = { { string = localize(t.key), colour = t.colour } },
			colours = t.key == "k_bl_or" and { G.C.CHANCE } or { G.C.BLACK },
			scale = t.scale,
			silent = true,
			pop_delay = 4.5,
			shadow = true,
			bump = t.bump or nil,
			maxw = 3,
		})
		table.insert(nodes, { n = G.UIT.R, config = { align = "cm" }, nodes = { { n = G.UIT.O, config = { object = dt } } } })
	end
	return {
		n = G.UIT.R,
		config = { align = "cm" },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.07, r = 0.1, colour = { 0, 0, 0, 0.12 }, minw = 2.9 },
				nodes = nodes,
			},
		},
	}
end
