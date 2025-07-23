local Disableable_Button = MP.UI.Disableable_Button
local Disableable_Toggle = MP.UI.Disableable_Toggle
local Disableable_Option_Cycle = MP.UI.Disableable_Option_Cycle
local unpack = table.unpack or unpack -- this is to support both Lua 5.1 and 5.2+

-- This needs to have a parameter because its a callback for inputs
local function send_lobby_options(value)
	MP.ACTIONS.lobby_options()
end

G.HUD_connection_status = nil

function G.UIDEF.get_connection_status_ui()
	return UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = {
				align = "cm",
				colour = G.C.UI.TRANSPARENT_DARK,
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.3,
						text = (MP.LOBBY.code and localize("k_in_lobby")) or (MP.LOBBY.connected and localize(
							"k_connected"
						)) or localize("k_warn_service"),
						colour = G.C.UI.TEXT_LIGHT,
					},
				},
			},
		},
		config = {
			align = "tri",
			bond = "Weak",
			offset = {
				x = 0,
				y = 0.9,
			},
			major = G.ROOM_ATTACH,
		},
	})
end

function G.UIDEF.create_UIBox_view_code()
	local var_495_0 = 0.75

	return (
		create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.R,
					config = {
						padding = 0,
						align = "cm",
					},
					nodes = {
						{
							n = G.UIT.R,
							config = {
								padding = 0.5,
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = MP.LOBBY.code,
										shadow = true,
										scale = var_495_0 * 0.6,
										colour = G.C.UI.TEXT_LIGHT,
									},
								},
							},
						},
						{
							n = G.UIT.R,
							config = {
								padding = 0,
								align = "cm",
							},
							nodes = {
								UIBox_button({
									label = { localize("b_copy_clipboard") },
									colour = G.C.BLUE,
									button = "copy_to_clipboard",
									minw = 5,
								}),
							},
						},
					},
				},
			},
		})
	)
end

local function all_players_same_order_config(players)
	if not players or #players == 0 then return true end
	local first_order = players[1].config and players[1].config.theOrder
	for i = 2, #players do
		local p = players[i]
		if p.config and p.config.theOrder ~= first_order then
			return false
		end
	end
	return true
end

local function check_player_configs(player)
	if player and player.cached == false then
		return MP.UTILS.wrapText(
			string.format(localize("k_warning_cheating"), MP.UTILS.random_message()),
			100
		), SMODS.Gradients.warning_text
	end
	if player and player.config and player.config.unlocked == false then
		return localize("k_warning_nemesis_unlock"), SMODS.Gradients.warning_text
	end
end

local function get_lobby_text()
	local players = MP.LOBBY.players

	if not players or #players == 0 then
		return ""
	end

	if not all_players_same_order_config(players) then
		return localize("k_warning_no_order"), SMODS.Gradients.warning_text
	end

	for i, player in ipairs(players) do
		if player.username == MP.LOBBY.username then
			goto continue
		end

		local msg, col = check_player_configs(player)
		if msg then return msg, col end

		::continue::
	end

	SMODS.Mods["Multiplayer"].config.unlocked = MP.UTILS.unlock_check()
	if not SMODS.Mods["Multiplayer"].config.unlocked then
		return localize("k_warning_unlock_profile"), SMODS.Gradients.warning_text
	end

	-- Check for mod hash mismatch among all players
	if players and #players > 1 then
		local hash = players[1].hash
		for i = 2, #players do
			if players[i].hash ~= hash then
				return localize("k_mod_hash_warning"), G.C.UI.TEXT_LIGHT
			end
		end
	end

	if MP.LOBBY.username == "Guest" then
		return localize("k_set_name"), G.C.UI.TEXT_LIGHT
	end

	return " ", G.C.UI.TEXT_LIGHT
end

local function create_player_nodes(players, text_scale)
	local player_nodes = {}
	if #players == 0 then return player_nodes end
	for i, player in ipairs(players or {}) do
		local player_row = {
			n = G.UIT.R,
			config = {
				padding = 0.1,
				align = "cm",
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						ref_table = player,
						ref_value = "username",
						shadow = true,
						scale = text_scale * 0.8,
						colour = G.C.UI.TEXT_LIGHT,
					},
				},
				{
					n = G.UIT.B,
					config = {
						w = 0.1,
						h = 0.1,
						colour = G.C.ORANGE,
					},
				},
			},
		}
		if player.modHash then
			table.insert(player_row.nodes, UIBox_button({
				id = "player_hash_" .. tostring(i),
				button = "view_player_hash",
				label = { hash(player.modHash) },
				minw = 0.75,
				minh = 0.3,
				scale = 0.25,
				shadow = false,
				colour = G.C.PURPLE,
				col = true,
				ref_table = { index = i }
			}))
		end
		table.insert(player_nodes, player_row)
	end
	return player_nodes
end

function G.UIDEF.create_UIBox_lobby_menu()
	local text_scale = 0.45
	local back = MP.LOBBY.config.different_decks and MP.LOBBY.deck.back or MP.LOBBY.config.back
	local stake = MP.LOBBY.config.different_decks and MP.LOBBY.deck.stake or MP.LOBBY.config.stake

	local text, colour = get_lobby_text()

	local t = {
		n = G.UIT.ROOT,
		config = {
			align = "cm",
			colour = G.C.CLEAR,
		},
		nodes = {
			{
				n = G.UIT.C,
				config = {
					align = "bm",
				},
				nodes = {
					{
						n = G.UIT.R,
						config = {
							padding = 1.25,
							align = "cm",
						},
						nodes = {
							{
								n = G.UIT.T,
								config = {
									scale = 0.3,
									shadow = true,
									text = text,
									colour = colour,
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = {
							align = "cm",
							padding = 0.2,
							r = 0.1,
							emboss = 0.1,
							colour = G.C.L_BLACK,
							mid = true,
						},
						nodes = {
							MP.UI.lobby_ready_button(text_scale),
							{
								n = G.UIT.C,
								config = {
									align = "cm",
								},
								nodes = {
									UIBox_button({
										button = "lobby_options",
										colour = G.C.ORANGE,
										minw = 3.15,
										minh = 1.35,
										label = {
											localize("b_lobby_options"),
										},
										scale = text_scale * 1.2,
										col = true,
									}),
									{
										n = G.UIT.C,
										config = {
											align = "cm",
											minw = 0.2,
										},
										nodes = {},
									},
									MP.LOBBY.isHost and Disableable_Button({
										id = "lobby_choose_deck",
										button = "lobby_choose_deck",
										colour = G.C.PURPLE,
										minw = 2.15,
										minh = 1.35,
										label = {
											localize({
												type = "name_text",
												key = MP.UTILS.get_deck_key_from_name(back),
												set = "Back",
											}),
											localize({
												type = "name_text",
												key = SMODS.stake_from_index(
													type(stake) == "string" and tonumber(stake) or stake
												),
												set = "Stake",
											}),
										},
										scale = text_scale * 1.2,
										col = true,
										enabled_ref_table = MP.LOBBY,
										enabled_ref_value = "isHost",
									}) or Disableable_Button({
										id = "lobby_choose_deck",
										button = "lobby_choose_deck",
										colour = G.C.PURPLE,
										minw = 2.15,
										minh = 1.35,
										label = {
											localize({
												type = "name_text",
												key = MP.UTILS.get_deck_key_from_name(back),
												set = "Back",
											}),
											localize({
												type = "name_text",
												key = SMODS.stake_from_index(
													type(stake) == "string" and tonumber(stake) or stake
												),
												set = "Stake",
											}),
										},
										scale = text_scale * 1.2,
										col = true,
										enabled_ref_table = MP.LOBBY.config,
										enabled_ref_value = "different_decks",
									}),
									{
										n = G.UIT.C,
										config = {
											align = "cm",
											minw = 0.2,
										},
										nodes = {},
									},
									{
										n = G.UIT.C,
										config = {
											align = "tm",
											minw = 2.65,
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0.15,
													align = "tm",
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = localize("k_connect_player"),
															shadow = true,
															scale = text_scale * 0.8,
															colour = G.C.UI.TEXT_LIGHT,
														},
													},
												},
											},
											unpack(
												create_player_nodes(
													MP.LOBBY.players,
													text_scale)),
										},
									},
									{
										n = G.UIT.C,
										config = {
											align = "cm",
											minw = 0.2,
										},
										nodes = {},
									},
									UIBox_button({
										button = "view_code",
										colour = G.C.PALE_GREEN,
										minw = 3.15,
										minh = 1.35,
										label = { localize("b_view_code") },
										scale = text_scale * 1.2,
										col = true,
									}),
									{
										n = G.UIT.C,
										config = {
											align = "cm",
											minw = 0.2,
										},
										nodes = {},
									},
									UIBox_button({
										id = "lobby_menu_leave",
										button = "lobby_leave",
										colour = G.C.RED,
										minw = 3.65,
										minh = 1.55,
										label = { localize("b_leave") },
										scale = text_scale * 1.5,
										col = true,
									}),
								},
							},
						},
					},
				},
			},
		},
	}
	return t
end

function G.UIDEF.create_UIBox_view_hash_player(index)
	return create_UIBox_generic_options({
		contents = {
			{
				n = G.UIT.C,
				config = {
					padding = 0.2,
					align = "cm",
				},
				nodes = MP.UI.hash_str_to_view(
					MP.LOBBY.players[index] and MP.LOBBY.players[index].hash_str,
					G.C.UI.TEXT_LIGHT
				),
			},
		},
	})
end

function G.UIDEF.create_UIBox_lobby_options()
	return create_UIBox_generic_options({
		contents = {
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm",
				},
				nodes = {
					not MP.LOBBY.isHost and {
						n = G.UIT.R,
						config = {
							padding = 0.3,
							align = "cm",
						},
						nodes = {
							{
								n = G.UIT.T,
								config = {
									scale = 0.6,
									shadow = true,
									text = localize("k_opts_only_host"),
									colour = G.C.UI.TEXT_LIGHT,
								},
							},
						},
					} or nil,
					create_tabs({
						snap_to_nav = true,
						colour = G.C.BOOSTER,
						tabs = {
							{
								label = localize("k_lobby_options"),
								chosen = true,
								tab_definition_function = function()
									return {
										n = G.UIT.ROOT,
										config = {
											emboss = 0.05,
											minh = 6,
											r = 0.1,
											minw = 10,
											align = "tm",
											padding = 0.2,
											colour = G.C.BLACK,
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "gold_on_life_loss_toggle",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("b_opts_cb_money"),
														ref_table = MP.LOBBY.config,
														ref_value = "gold_on_life_loss",
														callback = send_lobby_options,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "no_gold_on_round_loss_toggle",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("b_opts_no_gold_on_loss"),
														ref_table = MP.LOBBY.config,
														ref_value = "no_gold_on_round_loss",
														callback = send_lobby_options,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "death_on_round_loss_toggle",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("b_opts_death_on_loss"),
														ref_table = MP.LOBBY.config,
														ref_value = "death_on_round_loss",
														callback = send_lobby_options,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "different_seeds_toggle",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("b_opts_diff_seeds"),
														ref_table = MP.LOBBY.config,
														ref_value = "different_seeds",
														callback = toggle_different_seeds,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "different_decks_toggle",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("b_opts_player_diff_deck"),
														ref_table = MP.LOBBY.config,
														ref_value = "different_decks",
														callback = send_lobby_options,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "multiplayer_jokers_toggle",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("b_opts_multiplayer_jokers"),
														ref_table = MP.LOBBY.config,
														ref_value = "multiplayer_jokers",
														callback = send_lobby_options,
													}),
												},
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													Disableable_Toggle({
														id = "normal_bosses_toggle",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("b_opts_normal_bosses"),
														ref_table = MP.LOBBY.config,
														ref_value = "normal_bosses",
														callback = send_lobby_options,
													}),
												},
											},
											not MP.LOBBY.config.different_seeds and {
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cr",
												},
												nodes = {
													{
														n = G.UIT.C,
														config = {
															padding = 0,
															align = "cm",
														},
														nodes = {
															{
																n = G.UIT.R,
																config = {
																	padding = 0.2,
																	align = "cr",
																	func = "display_custom_seed",
																},
																nodes = {
																	{
																		n = G.UIT.T,
																		config = {
																			scale = 0.45,
																			text = localize("k_current_seed"),
																			colour = G.C.UI.TEXT_LIGHT,
																		},
																	},
																	{
																		n = G.UIT.T,
																		config = {
																			scale = 0.45,
																			text = MP.LOBBY.config.custom_seed,
																			colour = G.C.UI.TEXT_LIGHT,
																		},
																	},
																},
															},
															{
																n = G.UIT.R,
																config = {
																	padding = 0.2,
																	align = "cr",
																},
																nodes = {
																	Disableable_Button({
																		id = "custom_seed_overlay",
																		button = "custom_seed_overlay",
																		colour = G.C.BLUE,
																		minw = 3.65,
																		minh = 0.6,
																		label = {
																			localize("b_set_custom_seed"),
																		},
																		disabled_text = {
																			localize("b_set_custom_seed"),
																		},
																		scale = 0.45,
																		col = true,
																		enabled_ref_table = MP.LOBBY,
																		enabled_ref_value = "isHost",
																	}),
																	{
																		n = G.UIT.B,
																		config = {
																			w = 0.1,
																			h = 0.1,
																		},
																	},
																	Disableable_Button({
																		id = "custom_seed_reset",
																		button = "custom_seed_reset",
																		colour = G.C.RED,
																		minw = 1.65,
																		minh = 0.6,
																		label = {
																			localize("b_reset"),
																		},
																		disabled_text = {
																			localize("b_reset"),
																		},
																		scale = 0.45,
																		col = true,
																		enabled_ref_table = MP.LOBBY,
																		enabled_ref_value = "isHost",
																	}),
																},
															},
														},
													},
												},
											} or {
												n = G.UIT.B,
												config = {
													w = 0.1,
													h = 0.1,
												},
											},
										},
									}
								end,
							},
							{
								label = localize("k_opts_gm"),
								tab_definition_function = function()
									return {
										n = G.UIT.ROOT,
										config = {
											emboss = 0.05,
											minh = 6,
											r = 0.1,
											minw = 10,
											align = "tm",
											padding = 0.2,
											colour = G.C.BLACK,
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cm",
												},
												nodes = {
													Disableable_Option_Cycle({
														id = "starting_lives_option",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("b_opts_lives"),
														options = {
															1,
															2,
															3,
															4,
															5,
															6,
															7,
															8,
															9,
															10,
															11,
															12,
															13,
															14,
															15,
															16,
														},
														current_option = MP.LOBBY.config.starting_lives,
														opt_callback = "change_starting_lives",
													}),
													Disableable_Option_Cycle({
														id = "pvp_round_start_option",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("k_opts_pvp_start_round"),
														options = {
															1,
															2,
															3,
															4,
															5,
															6,
															7,
															8,
															9,
															10,
															11,
															12,
															13,
															14,
															15,
															16,
															17,
															18,
															19,
															20,
														},
														current_option = MP.LOBBY.config.pvp_start_round,
														opt_callback = "change_starting_pvp_round",
													}),
													Disableable_Option_Cycle({
														id = "pvp_timer_seconds_option",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("k_opts_pvp_timer"),
														options = {
															"30s",
															"60s",
															"90s",
															"120s",
															"150s",
															"180s"
														},
														current_option = (MP.LOBBY.config.timer_base_seconds) / 30,
														opt_callback = "change_timer_base_seconds"
													}),
													Disableable_Option_Cycle({
														id = "showdown_starting_antes_option",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("k_opts_showdown_starting_antes"),
														options = {
															1,
															2,
															3,
															4,
															5,
															6,
															7,
															8,
															9,
															10,
															11,
															12,
															13,
															14,
															15,
															16,
															17,
															18,
															19,
															20,
														},
														current_option = MP.LOBBY.config.showdown_starting_antes,
														opt_callback = "change_showdown_starting_antes",
													}),
													Disableable_Option_Cycle({
														id = "pvp_timer_increment_seconds_option",
														enabled_ref_table = MP.LOBBY,
														enabled_ref_value = "isHost",
														label = localize("k_opts_pvp_timer_increment"),
														options = {
															"0s",
															"30s",
															"60s",
															"90s",
															"120s",
															"150s",
															"180s"
														},
														current_option = (MP.LOBBY.config.timer_increment_seconds) / 30 + 1,
														opt_callback = "change_timer_increment_seconds"
													}),
												},
											},
										},
									}
								end,
							},
						},
					}),
				},
			},
		},
	})
end

function G.FUNCS.display_custom_seed(e)
	local display = MP.LOBBY.config.custom_seed == "random" and localize("k_random") or MP.LOBBY.config.custom_seed
	if display ~= e.children[1].config.text then
		e.children[2].config.text = display
		e.UIBox:recalculate(true)
	end
end

function G.UIDEF.create_UIBox_custom_seed_overlay()
	return create_UIBox_generic_options({
		back_func = "lobby_options",
		contents = {
			{
				n = G.UIT.R,
				config = { align = "cm", colour = G.C.CLEAR },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm", minw = 0.1 },
						nodes = {
							create_text_input({
								max_length = 8,
								all_caps = true,
								ref_table = MP.LOBBY,
								ref_value = "temp_seed",
								prompt_text = localize("k_enter_seed"),
								callback = function(val)
									MP.LOBBY.config.custom_seed = MP.LOBBY.temp_seed
									send_lobby_options()
								end,
							}),
							{
								n = G.UIT.B,
								config = { w = 0.1, h = 0.1 },
							},
							{
								n = G.UIT.T,
								config = {
									scale = 0.3,
									text = localize("k_enter_to_save"),
									colour = G.C.UI.TEXT_LIGHT,
								},
							},
						},
					},
				},
			},
		},
	})
end

function G.UIDEF.create_UIBox_view_hash(index)
	local modsString = MP.LOBBY.players[index] and MP.LOBBY.players[index].modHash or nil
	_, modsString = MP.UTILS.parse_Hash(modsString)
	return (
		create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.C,
					config = {
						padding = 0.2,
						align = "cm",
					},
					nodes = MP.UI.hash_str_to_view(
						modsString,
						G.C.UI.TEXT_LIGHT
					),
				},
			},
		})
	)
end

function MP.UI.hash_str_to_view(str, text_colour)
	local t = {}




	if not str then
		return t
	end

	for s in str:gmatch("[^;]+") do
		table.insert(t, {
			n = G.UIT.R,
			config = {
				padding = 0.05,
				align = "cm",
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						text = s,
						shadow = true,
						scale = 0.45,
						colour = text_colour,
					},
				},
			},
		})
	end
	return t
end

G.FUNCS.view_player_hash = function(e)
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_view_hash(e.config.ref_table.index),
	})
end

function toggle_different_seeds()
	G.FUNCS.lobby_options()
	send_lobby_options()
end

G.FUNCS.change_starting_lives = function(args)
	MP.LOBBY.config.starting_lives = args.to_val
	send_lobby_options()
end

G.FUNCS.change_starting_pvp_round = function(args)
	MP.LOBBY.config.pvp_start_round = args.to_val
	send_lobby_options()
end

G.FUNCS.change_timer_base_seconds = function(args)
	MP.LOBBY.config.timer_base_seconds = tonumber(args.to_val:sub(1, -2))
	send_lobby_options()
end

G.FUNCS.change_timer_increment_seconds = function(args)
	MP.LOBBY.config.timer_increment_seconds = tonumber(args.to_val:sub(1, -2))
	send_lobby_options()
end

G.FUNCS.change_showdown_starting_antes = function(args)
	MP.LOBBY.config.showdown_starting_antes = args.to_val
	send_lobby_options()
end

function G.FUNCS.get_lobby_main_menu_UI(e)
	return UIBox({
		definition = G.UIDEF.create_UIBox_lobby_menu(),
		config = {
			align = "bmi",
			offset = {
				x = 0,
				y = 10,
			},
			major = G.ROOM_ATTACH,
			bond = "Weak",
		},
	})
end

---@type fun(e: table | nil, args: { deck: string, stake: number | nil, seed: string | nil })
function G.FUNCS.lobby_start_run(e, args)
	if MP.LOBBY.config.different_decks == false then
		G.FUNCS.copy_host_deck()
	end

	local challenge = nil
	if MP.LOBBY.deck.back == "Challenge Deck" then
		challenge = G.CHALLENGES[get_challenge_int_from_id(MP.LOBBY.deck.challenge)]
	else
		G.GAME.viewed_back = G.P_CENTERS[MP.UTILS.get_deck_key_from_name(MP.LOBBY.deck.back)]
	end

	G.FUNCS.start_run(e, {
		mp_start = true,
		challenge = challenge,
		stake = tonumber(MP.LOBBY.deck.stake),
		seed = args.seed,
	})
end

function G.FUNCS.copy_host_deck()
	MP.LOBBY.deck.back = MP.LOBBY.config.back
	MP.LOBBY.deck.sleeve = MP.LOBBY.config.sleeve
	MP.LOBBY.deck.stake = MP.LOBBY.config.stake
	MP.LOBBY.deck.challenge = MP.LOBBY.config.challenge
end

function G.FUNCS.lobby_start_game(e)
	MP.ACTIONS.start_game()
end

function G.FUNCS.lobby_options(e)
	MP.ACTIONS.send_lobby_ready(false)
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_lobby_options(),
	})
end

function G.FUNCS.view_code(e)
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_view_code(),
	})
end

function G.FUNCS.lobby_leave(e)
	MP.LOBBY.code = nil
	MP.ACTIONS.leave_lobby()
	MP.UI.update_connection_status()
	G.STATE = G.STATES.MENU
end

function G.FUNCS.lobby_choose_deck(e)
	MP.ACTIONS.send_lobby_ready(false)
	G.FUNCS.setup_run(e)
	if G.OVERLAY_MENU then
		G.OVERLAY_MENU:get_UIE_by_ID("run_setup_seed"):remove()
	end
end

function G.FUNCS.display_lobby_main_menu_UI(e)
	G.MAIN_MENU_UI = G.FUNCS.get_lobby_main_menu_UI(e)
	G.MAIN_MENU_UI.alignment.offset.y = 0
	G.MAIN_MENU_UI:align_to_major()

	G.CONTROLLER:snap_to({ node = G.MAIN_MENU_UI:get_UIE_by_ID("lobby_menu_start") })
end

function G.FUNCS.mp_return_to_lobby()
	MP.ACTIONS.stop_game()
end

function G.FUNCS.custom_seed_overlay(e)
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_custom_seed_overlay(),
	})
end

function G.FUNCS.custom_seed_reset(e)
	MP.LOBBY.config.custom_seed = "random"
	send_lobby_options()
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
		end
	else
		set_main_menu_UI_ref()
	end
end

local in_lobby = false
local gameUpdateRef = Game.update
---@diagnostic disable-next-line: duplicate-set-field
function Game:update(dt)
	-- Track lobby state transitions
	if (MP.LOBBY.code and not in_lobby) or (not MP.LOBBY.code and in_lobby) then
		in_lobby = not in_lobby
		G.F_NO_SAVING = in_lobby
		self.FUNCS.go_to_menu()
		MP.reset_game_states()
	end
	gameUpdateRef(self, dt)
end

function G.UIDEF.create_UIBox_unstuck()
	return (
		create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.C,
					config = {
						padding = 0.2,
						align = "cm",
					},
					nodes = {
						UIBox_button({ label = { localize("b_unstuck_blind") }, button = "mp_unstuck_blind", minw = 5 }),
					},
				},
			},
		})
	)
end

function G.FUNCS.mp_unstuck()
	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_unstuck(),
	})
end

function G.FUNCS.mp_unstuck_arcana()
	G.FUNCS.skip_booster()
end

function G.FUNCS.mp_unstuck_blind()
	MP.GAME.ready_blind = false
	if MP.GAME.next_blind_context then
		G.FUNCS.select_blind(MP.GAME.next_blind_context)
	else
		sendErrorMessage("No next blind context", "MULTIPLAYER")
	end
end

function MP.UI.update_connection_status()
	if G.HUD_connection_status then
		G.HUD_connection_status:remove()
	end
	if G.STAGE == G.STAGES.MAIN_MENU then
		G.HUD_connection_status = G.UIDEF.get_connection_status_ui()
	end
end

local gameMainMenuRef = Game.main_menu
---@diagnostic disable-next-line: duplicate-set-field
function Game:main_menu(change_context)
	MP.UI.update_connection_status()
	gameMainMenuRef(self, change_context)
end

function G.FUNCS.copy_to_clipboard(e)
	MP.UTILS.copy_to_clipboard(MP.LOBBY.code)
end

function G.FUNCS.reconnect(e)
	MP.ACTIONS.connect()
	G.FUNCS:exit_overlay_menu()
end

function MP.have_player_usernames_changed()
	if not MP.LOBBY.code then return false end

	local prev_usernames = MP.LOBBY._prev_usernames or {}
	local players = MP.LOBBY.players or {}

	if #prev_usernames ~= #players then
		return true
	end

	for i, player in ipairs(players) do
		if prev_usernames[i] ~= player.username then
			return true
		end
	end

	return false
end

--[[ function MP.UI.set_lobby_menu()
	G.MAIN_MENU_UI = UIBox {
		definition = create_UIBox_main_menu_buttons(),
		config = { align = "bmi", offset = { x = 0, y = 0}, major = G.ROOM_ATTACH, bond = 'Weak' }
	}
	G.MAIN_MENU_UI.alignment.offset.y = 0
	G.MAIN_MENU_UI:align_to_major()
	G.E_MANAGER:add_event(Event({
		blockable = false,
		blocking = false,
		func = (function()
			if (not G.F_DISP_USERNAME) or (type(G.F_DISP_USERNAME) == 'string') then
				G.PROFILE_BUTTON = UIBox {
					definition = create_UIBox_profile_button(),
					config = { align = "bli", offset = { x = -10, y = 0 }, major = G.ROOM_ATTACH, bond = 'Weak' } }
				G.PROFILE_BUTTON.alignment.offset.x = 0
				G.PROFILE_BUTTON:align_to_major()
				return true
			end
		end)
	}))

	G.CONTROLLER:snap_to { node = G.MAIN_MENU_UI:get_UIE_by_ID('main_menu_play') }
end
-- ]]
