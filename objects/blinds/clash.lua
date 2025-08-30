SMODS.Atlas({
	key = "player_blind_chip",
	path = "player_blind_row.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
	px = 34,
	py = 34,
})

SMODS.Atlas({
	key = "player_blind_col",
	path = "blind_col.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
	px = 34,
	py = 34,
})

SMODS.Blind({
	key = "clash",
	dollars = 5,
	mult = 1,
	boss_colour = G.C.GREEN,
	boss = { min = 1, max = 100 },
	atlas = "player_blind_col",
	pos = { x = 0, y = 10 },
	discovered = true,
	in_pool = function(self)
		return false
	end,
})