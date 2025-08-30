function G.UIDEF.override_main_menu_play_button()
	if not G.SETTINGS.tutorial_complete or G.SETTINGS.tutorial_progress ~= nil then
		return (
			create_UIBox_generic_options({
				contents = {
					UIBox_button({
						label = { localize("b_singleplayer") },
						colour = G.C.BLUE,
						button = "setup_run_singleplayer",
						minw = 5,
					}),
					{
						n = G.UIT.R,
						config = {
							align = "cm",
							padding = 0.5,
						},
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = localize("k_tutorial_not_complete"),
									colour = G.C.UI.TEXT_LIGHT,
									scale = 0.45,
								},
							}
						}
					},
					UIBox_button({
						label = { localize("b_skip_tutorial") },
						colour = G.C.RED,
						button = "skip_tutorial",
						minw = 5,
					})
				},
			})
		)
	end

	return (
		create_UIBox_generic_options({
			contents = {
				UIBox_button({
					label = { localize("b_singleplayer") },
					colour = G.C.BLUE,
					button = "setup_run_singleplayer",
					minw = 5,
				}),
				MP.LOBBY.connected and UIBox_button({
					label = { localize("b_create_lobby") },
					colour = G.C.GREEN,
					button = "create_lobby",
					minw = 5,
				}) or nil,
				MP.LOBBY.connected and UIBox_button({
					label = { localize("b_join_lobby") },
					colour = G.C.RED,
					button = "join_lobby",
					minw = 5,
				}) or nil,
				not MP.LOBBY.connected and UIBox_button({
					label = { localize("b_reconnect") },
					colour = G.C.RED,
					button = "reconnect",
					minw = 5,
				}) or nil,
			},
		})
	)
end

local create_UIBox_main_menu_buttonsRef = create_UIBox_main_menu_buttons
---@diagnostic disable-next-line: lowercase-global
function create_UIBox_main_menu_buttons()
	local menu = create_UIBox_main_menu_buttonsRef()
	menu.nodes[1].nodes[1].nodes[1].nodes[1].config.button = "play_options"
	
	return menu
end