function G.UIDEF.gamemode_selection_options()
	local gamemode_buttons_data
	if MP.LOBBY.config.ruleset == "ruleset_mp_coop" then
		gamemode_buttons_data = {
			{ button_id = "coopSurvival_gamemode_button", button_localize_key = "k_coopSurvival" },
		}
	else
		gamemode_buttons_data = {
			{ button_id = "attrition_gamemode_button", button_localize_key = "k_attrition" },
			{ button_id = "showdown_gamemode_button",  button_localize_key = "k_showdown" },
			{ button_id = "survival_gamemode_button",  button_localize_key = "k_survival" },
		}
	end

	-- Default to the first gamemode in the list
	local default_gamemode_key = gamemode_buttons_data[1].button_localize_key
	local default_gamemode_name = default_gamemode_key:gsub("^k_", "")
	MP.LOBBY.config.gamemode = "gamemode_mp_" .. default_gamemode_name

	local default_gamemode_area = UIBox({
		definition = G.UIDEF.gamemode_info(default_gamemode_name),
		config = { align = "cm" }
	})

	return MP.UI.Main_Lobby_Options("gamemode_area", default_gamemode_area,
		"change_gamemode_selection", gamemode_buttons_data)
end

function G.UIDEF.gamemode_info(gamemode_name)
	local gamemode = MP.Gamemodes["gamemode_mp_" .. gamemode_name]

	local gamemode_desc = MP.UTILS.wrapText(localize("k_" .. gamemode_name .. "_description"), 100)
	local _, gamemode_desc_lines = gamemode_desc:gsub("\n", " ")

	return {
		n = G.UIT.ROOT,
		config = { align = "tm", minh = 8, maxh = 8, minw = 11, maxw = 11, colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "tm", padding = 0.2, r = 0.1, colour = G.C.BLACK, minh = 8 },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "tm", padding = 0.05, minw = 11, maxw = 11, minh = 8 },
						nodes = {
						{ n = G.UIT.T, config = { text = gamemode_desc, colour = G.C.UI.TEXT_LIGHT, scale = 0.8 } }
						}
					},
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							{
								n = G.UIT.R,
								config = { id = "start_lobby_button", button = "start_lobby", align = "cm", padding = 0.05, r = 0.1, minw = 8, minh = 0.8, colour = G.C.BLUE, hover = true, shadow = true },
								nodes = {
									{ n = G.UIT.T, config = { text = localize("b_create_lobby"), scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
								}
							}
						}
					}
				}
			}
		}
	}
end
