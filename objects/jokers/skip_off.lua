SMODS.Atlas({
	key = "skip_off",
	path = "j_skip_off.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = "skip_off",
	atlas = "skip_off",
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { hands = 0, discards = 0, extra_hands = 1, extra_discards = 1 } },
	loc_vars = function(self, info_queue, card)
		MP.UTILS.add_nemesis_info(info_queue)
		if not MP.LOBBY.code then return { vars = { 0, 0, 0, 0, "" } } end
		local nemesis = MP.UTILS.get_nemesis().game_state
		if not nemesis then return { vars = { 0, 0, 0, 0, "" } } end
		return {
			vars = {
				card.ability.extra.extra_hands,
				card.ability.extra.extra_discards,
				card.ability.extra.hands,
				card.ability.extra.discards,
				G.GAME.skips ~= nil and nemesis.skips ~= nil and localize({
					type = "variable",
					key = nemesis.skips > G.GAME.skips and "a_mp_skips_behind"
						or nemesis.skips == G.GAME.skips and "a_mp_skips_tied"
						or "a_mp_skips_ahead",
					vars = { math.abs(nemesis.skips - G.GAME.skips) },
				})[1] or "",
			},
		}
	end,
	in_pool = function(self)
		return MP.LOBBY.code and MP.LOBBY.config.multiplayer_jokers
	end,
	update = function(self, card, dt)
		local nemesis = MP.UTILS.get_nemesis()
		if not nemesis then return end	
		local nemesis_skips = nemesis.game_state.skips or 0

		if G.STAGE == G.STAGES.RUN and G.GAME.skips ~= nil and nemesis_skips ~= nil then
			local skip_diff = (math.max(G.GAME.skips - nemesis_skips, 0))
			card.ability.extra.hands = skip_diff * card.ability.extra.extra_hands
			card.ability.extra.discards = skip_diff * card.ability.extra.extra_discards
		end
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.setting_blind and not context.blueprint then
			G.E_MANAGER:add_event(Event({
				func = function()
					ease_hands_played(card.ability.extra.hands)
					ease_discard(card.ability.extra.discards, nil, true)
					return true
				end,
			}))
		end
	end,
	mp_credits = {
		idea = { "Dr. Monty", "Carter" },
		art = { "Aura!" },
		code = { "Virtualized" },
	},
})
