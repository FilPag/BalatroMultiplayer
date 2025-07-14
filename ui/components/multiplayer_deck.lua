function G.UIDEF.multiplayer_deck()
	return G.UIDEF.challenge_description(
		get_challenge_int_from_id(MP.Rulesets[MP.LOBBY.config.ruleset].challenge_deck),
		nil,
		false
	)
end