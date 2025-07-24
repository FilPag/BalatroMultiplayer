-- NOTE: unused?
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
