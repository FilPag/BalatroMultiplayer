local start_run_ref = Game.start_run
function Game:start_run(args)
	start_run_ref(self, args)
end

function G.UIDEF.view_nemesis_deck()
	local playing_cards_ref = G.playing_cards
	G.playing_cards = MP.nemesis_cards
	local t = G.UIDEF.view_deck()
	G.playing_cards = playing_cards_ref
	return t
end

