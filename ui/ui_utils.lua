function MP.UI_UTILS.ease_lives(mod)
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			if not G.hand_text_area then
				return
			end

			if MP.LOBBY.config.disable_live_and_timer_hud then
				return true -- Returning nothing hangs the game because it's a part of an event
			end

			local lives_UI = G.hand_text_area.ante
			mod = mod or 0
			local text = "+"
			local col = G.C.IMPORTANT
			if mod < 0 then
				text = "-"
				col = G.C.RED
			end
			lives_UI.config.object:update()
			G.HUD:recalculate()
			attention_text({
				text = text .. tostring(math.abs(mod)),
				scale = 1,
				hold = 0.7,
				cover = lives_UI.parent,
				cover_colour = col,
				align = "cm",
			})
			play_sound("highlight2", 0.685, 0.2)
			play_sound("generic1")
			return true
		end,
	}))
end

function MP.UI_UTILS.update_blind_HUD()
	if MP.LOBBY.code then
		G.HUD_blind.alignment.offset.y = -10
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0,
			blockable = false,
			func = function()
				local nemesis = MP.UTILS.get_nemesis()
				G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_table = nemesis
				G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_value = "score_text"
				G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.func = "multiplayer_blind_chip_UI_scale"
				G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[1].children[1].config.text =
					localize("k_enemy_score")
				G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[3].children[1].config.text =
					localize("k_enemy_hands")
				G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object.config.string =
					{ { ref_table = nemesis, ref_value = "hands_left" } }
				G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object:update_text()
				G.HUD_blind.alignment.offset.y = 0
				if G.GAME.blind.config.blind.key == "bl_mp_nemesis" then	-- this was just the first place i thought of to implement this sprite swapping, change if inappropriate
					G.GAME.blind.children.animatedSprite.atlas = G.ANIMATION_ATLAS['mp_player_blind_col']
					local nemesis_blind_col = MP.UTILS.get_nemesis_key()
					G.GAME.blind.children.animatedSprite:set_sprite_pos(G.P_BLINDS[nemesis_blind_col].pos)
				end
				return true
			end,
		}))
	end
end

function MP.UI_UTILS.show_enemy_location()
	local row_dollars_chips = G.HUD:get_UIE_by_ID("row_dollars_chips")
	if row_dollars_chips then
		row_dollars_chips.children[1]:remove()
		row_dollars_chips.children[1] = nil
		G.HUD:add_child(MP.UIDEF.enemy_location_row(MP.UTILS.get_nemesis(), "location"), row_dollars_chips)
	end
end

function MP.UI_UTILS.hide_enemy_location()
	local row_dollars_chips = G.HUD:get_UIE_by_ID("row_dollars_chips")
	if row_dollars_chips then
		row_dollars_chips.children[1]:remove()
		row_dollars_chips.children[1] = nil
		G.HUD:add_child(MP.UIDEF.round_score(), row_dollars_chips)
	end
end

