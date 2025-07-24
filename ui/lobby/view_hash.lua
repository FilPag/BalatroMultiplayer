function MP.UIDEF.create_UIBox_view_hash(index)
	local modHash = MP.LOBBY.players[index] and MP.LOBBY.players[index].modHash or nil
	local modsTable = MP.UTILS.parse_Hash(modHash).Mods
	return (
		create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.C,
					config = {
						padding = 0.2,
						align = "lm",
					},
					nodes = MP.UI.mods_overlay(
						modsTable,
						G.C.UI.TEXT_LIGHT
					),
				},
			},
		})
	)
end