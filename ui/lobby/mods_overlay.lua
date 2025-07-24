function MP.UI.mods_overlay(modsTable, text_colour)
	local t = {}

	if not modsTable then
		return t
	end

	for k, v in pairs(modsTable) do
		table.insert(t, {
			n = G.UIT.R,
			config = {
				padding = 0.05,
				align = "lm",
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						text = tostring(k) .. " - " .. tostring(v),
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