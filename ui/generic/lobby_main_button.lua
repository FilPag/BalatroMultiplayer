local Disableable_Button = MP.UI.Disableable_Button

-- Component for main start/ready button in lobby
function MP.UI.create_lobby_main_button(text_scale)
	if MP.LOBBY.is_host then
		return Disableable_Button({
			id = "lobby_menu_start",
			button = "lobby_start_game",
			colour = G.C.BLUE,
			minw = 3.65,
			minh = 1.55,
			label = { localize("b_start") },
			disabled_text = localize("b_wait_for_players"),
			scale = text_scale * 2,
			col = true,
			enabled_ref_table = MP.LOBBY,
			enabled_ref_value = "ready_to_start",
		})
	else
		return MP.UI.lobby_ready_button(text_scale)
	end
end
