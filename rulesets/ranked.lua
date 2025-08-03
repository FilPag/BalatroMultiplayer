MP.Ruleset({
	key = "ranked",
	multiplayer_content = true,
	standard = true,
	banned_jokers = {},
	banned_consumables = {
		"c_justice",
	},
	banned_vouchers = {},
	banned_enhancements = {},
	banned_tags = {},
	banned_blinds ={},
	reworked_jokers = {
		"j_hanging_chad",
	},
	reworked_consumables = {},
	reworked_vouchers = {},
	reworked_enhancements = {
		"m_glass"
	},
	reworked_tags = {},
	reworked_blinds = {},
	create_info_menu = function ()
		return {
			{
				n = G.UIT.R,
				config = {
					align = "tm"
				},
				nodes = {
					MP.UI.BackgroundGrouping(localize("k_has_multiplayer_content"), {
						{
							n = G.UIT.T,
							config = {
								text = localize("k_yes"),
								scale = 0.8,
								colour = G.C.GREEN,
							}
						}
					}, {col = true, text_scale = 0.6}),
					{
						n = G.UIT.C,
						config = {
							minw = 0.1,
							minh = 0.1
						}
					},
					MP.UI.BackgroundGrouping(localize("k_forces_lobby_options"), {
						{
							n = G.UIT.T,
							config = {
								text = localize("k_yes"),
								scale = 0.8,
								colour = G.C.GREEN,
							}
						}
					}, {col = true, text_scale = 0.6}),
					{
						n = G.UIT.C,
						config = {
							minw = 0.1,
							minh = 0.1
						}
					},
					MP.UI.BackgroundGrouping(localize("k_forces_gamemode"), {
						{
							n = G.UIT.T,
							config = {
								text = localize("k_attrition"),
								scale = 0.8,
								colour = G.C.GREEN,
							}
						}
					}, {col = true, text_scale = 0.6})
				},
			},
			{
				n = G.UIT.R,
				config = {
					minw = 0.05,
					minh = 0.05
				}
			},
			{
				n = G.UIT.R,
				config = {
					align = "cl",
					padding = 0.1
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = localize("k_ranked_description"),
							scale = 0.6,
							colour = G.C.UI.TEXT_LIGHT,
						}
					},
				},
			},
		}
	end,
	forced_gamemode = "gamemode_mp_attrition",
	forced_lobby_options = true,
	is_disabled = function(self)
		local required_version = "1.0.0~BETA-0506a"
		if SMODS.version ~= required_version then
			return localize({type = "variable", key="k_ruleset_disabled_smods_version", vars = {required_version}})
		end
		if not MP.INTEGRATIONS.TheOrder then
			return localize("k_ruleset_disabled_the_order_required")
		end
		return false
	end,
	force_lobby_options = function(self)
		return true
	end
}):inject()
