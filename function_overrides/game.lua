local start_run_ref = Game.start_run
function Game:start_run(args)
	start_run_ref(self, args)
end

function G.UIDEF.view_player_deck(player)
	local playing_cards_ref = G.playing_cards
	G.playing_cards = player.cards or {} 
	local t = G.UIDEF.view_deck()
	G.playing_cards = playing_cards_ref
	return t
end

