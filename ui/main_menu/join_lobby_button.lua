function G.UIDEF.create_UIBox_join_lobby_overlay()
	return (
		create_UIBox_generic_options({
			back_func = "play_options",
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
								create_text_input({
									w = 4,
									h = 1,
									max_length = 5,
									id = "join_lobby_code_input",
									all_caps = true,
									prompt_text = localize("k_enter_lobby_code"),
									ref_table = MP.LOBBY,
									ref_value = "temp_code",
									extended_corpus = false,
									keyboard_offset = 1,
									minw = 5,
									callback = function(val)
										if MP.FLAGS.join_pressed then return end
										MP.FLAGS.join_pressed = true
										MP.ACTIONS.join_lobby(MP.LOBBY.temp_code)
									end,
								}),
							},
						},
						UIBox_button({
							label = { localize("k_paste") },
							colour = G.C.RED,
							button = "join_from_clipboard",
							minw = 5,
						}),
					},
				},
			},
		})
	)
end