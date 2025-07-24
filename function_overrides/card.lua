local sell_card_ref = Card.sell_card
function Card:sell_card()
	if self.ability and self.ability.name then
		sendTraceMessage(
			string.format("Client sent message: action:soldCard,card:%s", self.ability.name),
			"MULTIPLAYER"
		)
	end
	return sell_card_ref(self)
end