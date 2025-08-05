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
				local nemesis = MP.UTILS.get_nemesis().game_state
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
				if G.GAME.blind.config.blind.key == "bl_mp_nemesis" then -- this was just the first place i thought of to implement this sprite swapping, change if inappropriate
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
	if MP.UTILS.is_coop() then return end

	local row_dollars_chips = G.HUD:get_UIE_by_ID("row_dollars_chips")
	if row_dollars_chips then
		row_dollars_chips.children[1]:remove()
		row_dollars_chips.children[1] = nil
		G.HUD:add_child(MP.UIDEF.enemy_location_row(MP.UTILS.get_nemesis().game_state, "location"), row_dollars_chips)
	end
end

function MP.UI_UTILS.hide_enemy_location()
	if MP.UTILS.is_coop() then return end

	local row_dollars_chips = G.HUD:get_UIE_by_ID("row_dollars_chips")
	if row_dollars_chips then
		row_dollars_chips.children[1]:remove()
		row_dollars_chips.children[1] = nil
		G.HUD:add_child(MP.UIDEF.round_score(), row_dollars_chips)
	end
end

function MP.UI_UTILS.juice_up(thing, a, b)
	if SMODS.Mods["Talisman"] and SMODS.Mods["Talisman"].can_load then
		local disable_anims = Talisman.config_file.disable_anims
		Talisman.config_file.disable_anims = false
		thing:juice_up(a, b)
		Talisman.config_file.disable_anims = disable_anims
	else
		thing:juice_up(a, b)
	end
end

MULTIPLAYER_VERSION = SMODS.Mods["Multiplayer"].version .. "-MULTIPLAYER"

local function has_mod_manipulating_title_card()
	-- maintain a list of all mods that affect the title card here
	-- (must use the mod's id, not its name)
	local modlist = { "BUMod", "Cryptid", "Talisman" }
	for _, modname in ipairs(modlist) do
		if SMODS.Mods[modname] and SMODS.Mods[modname].can_load then
			return true
		end
	end
	return false
end

function make_wheel_of_fortune_a_card_func(card)
	return function()
		if card then
			wheel_of_fortune_the_card(card)
		end
		return true
	end
end

MP.title_card = nil

function MP.UI_UTILS.add_custom_multiplayer_cards(change_context)
	local only_mod_affecting_title_card = not has_mod_manipulating_title_card()

	if only_mod_affecting_title_card then
		G.title_top.cards[1]:set_base(G.P_CARDS["S_A"], true)
	end

	-- Credit to the Cryptid mod for the original code to add a card to the main menu
	local title_card = create_card("Base", G.title_top, nil, nil, nil, nil)
	title_card:set_base(G.P_CARDS["H_A"], true)
	G.title_top.T.w = G.title_top.T.w * 1.7675
	G.title_top.T.x = G.title_top.T.x - 0.8
	G.title_top:emplace(title_card)
	title_card.T.w = title_card.T.w * 1.1 * 1.2
	title_card.T.h = title_card.T.h * 1.1 * 1.2
	title_card.no_ui = true
	title_card.states.visible = false

	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = change_context == "game" and 1.5 or 0,
		blockable = false,
		blocking = false,
		func = function()
			if change_context == "splash" then
				title_card.states.visible = true
				title_card:start_materialize({ G.C.WHITE, G.C.WHITE }, true, 2.5)
				play_sound("whoosh1", math.random() * 0.1 + 0.3, 0.3)
				play_sound("crumple" .. math.random(1, 5), math.random() * 0.2 + 0.6, 0.65)
			else
				title_card.states.visible = true
				title_card:start_materialize({ G.C.WHITE, G.C.WHITE }, nil, 1.2)
			end
			G.VIBRATION = G.VIBRATION + 1
			return true
		end,
	}))

	MP.title_card = title_card

	-- base delay in seconds, increases as needed
	local wheel_delay = 2

	if only_mod_affecting_title_card then
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = wheel_delay,
			blockable = false,
			blocking = false,
			func = make_wheel_of_fortune_a_card_func(G.title_top.cards[1]),
		}))
		wheel_delay = wheel_delay + 1
	end

	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = wheel_delay,
		blockable = false,
		blocking = false,
		func = make_wheel_of_fortune_a_card_func(MP.title_card),
	}))
end

local function localize_blind(val)
	if not val or val == "" then return "" end
	local loc = localize({ type = "name_text", key = val, set = "Blind" })
	if loc ~= "ERROR" then return loc end
	return (G.P_BLINDS[val] and G.P_BLINDS[val].name) or val
end

local function localize_player_location(val)
	if not val or val == "" then return "Unknown" end
	local loc = G.localization.misc.dictionary[val]
	if loc then return loc end
	return val
end

function MP.UI_UTILS.parse_enemy_location(location)
	if type(location) ~= "string" or location == "" then return "Unknown" end
	local main, sub = location:match("([^%-]+)%-(.+)")
	main = main or location
	sub = sub or ""
	return localize_player_location(main) .. localize_blind(sub)
end

function MP.UI_UTILS.juice_player_ui(uie_id)
	local uie = G.HUD and G.HUD.get_UIE_by_ID and G.HUD:get_UIE_by_ID(uie_id)
	if uie and uie.juice_up then uie:juice_up() end
end

function MP.UI_UTILS.get_mp_blind_amount(blind, chips, is_boss)
	if not MP.LOBBY or not MP.LOBBY.code then
		return to_big(chips)
	end

	if not blind then return chips end

	if blind.key == "bl_small" or blind.key == "bl_big" then
		return to_big(chips)
	end

	if blind.key == "bl_mp_nemesis" then
		return to_big(0)
	end

	local amount = chips
	if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" then
    local num_players = 0
    for _ in pairs(MP.LOBBY.players) do
			num_players = num_players + 1
		end
		amount = amount * num_players
	end

	return to_big(amount)
end
