function MP.UIDEF.create_UIBox_view_hash(index)
	local mod_hash = MP.LOBBY.players[index] and MP.LOBBY.players[index].profile.mod_hash or nil
	local modsTable = MP.UTILS.parse_Hash(mod_hash).Mods
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