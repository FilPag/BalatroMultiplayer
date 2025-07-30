local Disableable_Button = MP.UI.Disableable_Button
local Disableable_Toggle = MP.UI.Disableable_Toggle
local Disableable_Option_Cycle = MP.UI.Disableable_Option_Cycle

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
					not MP.LOBBY.is_host and {
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
														enabled_ref_value = "is_host",
														label = localize("b_opts_cb_money"),
														ref_table = MP.LOBBY.config,
														ref_value = "gold_on_life_loss",
														callback = MP.ACTIONS.update_lobby_options,
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
														enabled_ref_value = "is_host",
														label = localize("b_opts_no_gold_on_loss"),
														ref_table = MP.LOBBY.config,
														ref_value = "no_gold_on_round_loss",
														callback = MP.ACTIONS.update_lobby_options,
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
														enabled_ref_value = "is_host",
														label = localize("b_opts_death_on_loss"),
														ref_table = MP.LOBBY.config,
														ref_value = "death_on_round_loss",
														callback = MP.ACTIONS.update_lobby_options,
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
														enabled_ref_value = "is_host",
														label = localize("b_opts_diff_seeds"),
														ref_table = MP.LOBBY.config,
														ref_value = "different_seeds",
														callback = function() 
															G.FUNCS.set_lobby_options()
															MP.ACTIONS.update_lobby_options()
														end,
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
														enabled_ref_value = "is_host",
														label = localize("b_opts_player_diff_deck"),
														ref_table = MP.LOBBY.config,
														ref_value = "different_decks",
														callback = MP.ACTIONS.update_lobby_options,
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
														enabled_ref_value = "is_host",
														label = localize("b_opts_multiplayer_jokers"),
														ref_table = MP.LOBBY.config,
														ref_value = "multiplayer_jokers",
														callback = MP.ACTIONS.update_lobby_options,
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
														enabled_ref_value = "is_host",
														label = localize("b_opts_normal_bosses"),
														ref_table = MP.LOBBY.config,
														ref_value = "normal_bosses",
														callback = MP.ACTIONS.update_lobby_options,
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
																		enabled_ref_value = "is_host",
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
																		enabled_ref_value = "is_host",
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
														enabled_ref_value = "is_host",
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
														enabled_ref_value = "is_host",
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
														enabled_ref_value = "is_host",
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
														enabled_ref_value = "is_host",
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
														enabled_ref_value = "is_host",
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
