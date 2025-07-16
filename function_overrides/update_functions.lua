local update_selecting_hand_ref = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
	if G.GAME.current_round.hands_left < G.GAME.round_resets.hands
			and #G.hand.cards < 1
			and #G.deck.cards < 1
			and #G.play.cards < 1
			and MP.LOBBY.code
	then
		G.GAME.current_round.hands_left = 0
		if MP.is_online_boss() then
			MP.ACTIONS.play_hand(G.GAME.chips, 0)
			G.STATE_COMPLETE = false
			G.STATE = G.STATES.HAND_PLAYED
		else
			G.STATE_COMPLETE = false
			G.STATE = G.STATES.NEW_ROUND
		end
		return
	end
	update_selecting_hand_ref(self, dt)

	if MP.GAME.end_pvp and MP.is_online_boss() then
		G.hand:unhighlight_all()
		G.STATE_COMPLETE = false
		G.STATE = G.STATES.NEW_ROUND
		MP.GAME.end_pvp = false
	end

	if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" then
		if G.GAME.chips - G.GAME.blind.chips >= 0 then
			G.hand:unhighlight_all()
			G.STATE_COMPLETE = false
			G.STATE = G.STATES.NEW_ROUND
			MP.GAME.end_pvp = false
		end
	end
end

local update_shop_ref = Game.update_shop
function Game:update_shop(dt)
  local function update_location()
    MP.ACTIONS.set_location("loc_shop")
    MP.GAME.spent_before_shop = to_big(MP.GAME.spent_total) + to_big(0)
    MP.UI_UTILS.show_enemy_location()
  end

  local updated_location = false

  if MP.LOBBY.code and not G.STATE_COMPLETE and not updated_location and not G.GAME.USING_RUN then
    updated_location = true
    update_location()
  end

  if not G.STATE_COMPLETE then
    MP.GAME.ready_blind = false
    MP.GAME.ready_blind_text = localize("b_ready")
    MP.GAME.end_pvp = false
  end

  if G.STATE_COMPLETE and updated_location then
    updated_location = false
  end

  update_shop_ref(self, dt)
end

local update_blind_select_ref = Game.update_blind_select
function Game:update_blind_select(dt)
	local updated_location = false
	if MP.LOBBY.code and not G.STATE_COMPLETE and not updated_location then
		updated_location = true
		MP.ACTIONS.set_location("loc_selecting")
		MP.UI_UTILS.show_enemy_location()
	end
	if G.STATE_COMPLETE and updated_location then
		updated_location = false
	end
	update_blind_select_ref(self, dt)
end

local update_draw_to_hand_ref = Game.update_draw_to_hand
function Game:update_draw_to_hand(dt)
	if MP.LOBBY.code then
		if
			not G.STATE_COMPLETE
			and G.GAME.current_round.hands_played == 0
			and G.GAME.current_round.discards_used == 0
			and G.GAME.facing_blind
		then
			if G.GAME.round_resets.pvp_blind_choices[G.GAME.blind_on_deck] then
				G.GAME.blind.pvp = true
			else
				G.GAME.blind.pvp = false
			end
			if MP.is_online_boss() and G.GAME.blind.config.blind.key == "bl_mp_nemesis" then
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0,
					blockable = false,
					func = function()
						G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:pop_out(0)
						MP.UI_UTILS.update_blind_HUD()
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.45,
							blockable = false,
							func = function()
								G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object.config.string = {
									{
										-- Show the enemy player for the current client, supports n players
										ref_table = MP.UTILS.get_nemesis_lobby_data(),
										ref_value = "username",
									},
								}
								G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:update_text()
								G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:pop_in(0)
								return true
							end,
						}))
						return true
					end,
				}))
			end
		end
	end
	update_draw_to_hand_ref(self, dt)
end