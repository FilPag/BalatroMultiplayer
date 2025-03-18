SMODS.Atlas({
	key = "taxes",
	path = "j_taxes.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = "taxes",
	atlas = "taxes",
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { mult_gain = 5, mult = 0 } },
	loc_vars = function(self, info_queue, card)
		add_nemesis_info(info_queue)
		return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
	end,
	in_pool = function(self)
		return MP.LOBBY.code and MP.LOBBY.config.multiplayer_jokers
	end,
	mp_credits = {
		idea = { "Zwei" },
		art = { "Kittyknight" },
		code = { "Virtualized" },
	},
}) 