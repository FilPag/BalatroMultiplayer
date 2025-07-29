local Disableable_Toggle = MP.UI.Disableable_Toggle

function G.FUNCS.lobby_info(e)
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu({
		definition = MP.UI.lobby_info(),
	})
end

function MP.UI.lobby_info()
	return create_UIBox_generic_options({
		contents = {
			create_tabs({
				tabs = {
					{
						label = localize("b_players"),
						chosen = true,
						tab_definition_function = MP.UI.create_UIBox_players,
					},
					{
						label = localize("b_lobby_info"),
						chosen = false,
						tab_definition_function = MP.UI.create_UIBox_settings, -- saying settings because _options is used in lobby
					},
				},
				tab_h = 8,
				snap_to_nav = true,
			}),
		},
	})
end

function MP.UI.create_UIBox_settings() -- optimize this please
	local ruleset = string.sub(MP.LOBBY.config.ruleset, 12, -1)
	local gamemode = string.sub(MP.LOBBY.config.gamemode, 13, -1)
	local seed = MP.LOBBY.config.custom_seed == "random" and localize("k_random") or MP.LOBBY.config.custom_seed
	return {
		n = G.UIT.ROOT,
			config = {
			emboss = 0.05,
			minh = 6,
			r = 0.1,
			minw = 10,
			align = "tm",
			padding = 0.2,
			colour = G.C.BLACK,
		},
		nodes = {
			{n=G.UIT.R, config={align = "tm", padding = 0.05}, nodes={
				{n=G.UIT.T, config={text = (localize("k_" .. ruleset) .. " " .. localize("k_" .. gamemode)), colour = G.C.UI.TEXT_LIGHT, scale = 0.6}}}},
			{n=G.UIT.R, config={align = "tm", padding = 0.05}, nodes={
				{n=G.UIT.T, config={text = (localize("k_current_seed") .. seed), colour = G.C.UI.TEXT_LIGHT, scale = 0.6}}}},
			{n = G.UIT.R,
				config = {
					padding = 0,
					align = "cr",
					},
				nodes = {
				Disableable_Toggle({
					enabled_ref_table = MP.LOBBY,
					label = localize("b_opts_cb_money"),
					ref_table = MP.LOBBY.config,
					ref_value = "gold_on_life_loss",})}},
			{n = G.UIT.R,
				config = {
					padding = 0,
					align = "cr",
					},
				nodes = {
				Disableable_Toggle({
					enabled_ref_table = MP.LOBBY,
					label = localize("b_opts_no_gold_on_loss"),
					ref_table = MP.LOBBY.config,
					ref_value = "no_gold_on_round_loss",})}},
			{n = G.UIT.R,
				config = {
					padding = 0,
					align = "cr",
					},
				nodes = {
				Disableable_Toggle({
					enabled_ref_table = MP.LOBBY,
					label = localize("b_opts_death_on_loss"),
					ref_table = MP.LOBBY.config,
					ref_value = "death_on_round_loss",})}},
			{n = G.UIT.R,
				config = {
					padding = 0,
					align = "cr",
					},
				nodes = {
				Disableable_Toggle({
					enabled_ref_table = MP.LOBBY,
					label = localize("b_opts_diff_seeds"),
					ref_table = MP.LOBBY.config,
					ref_value = "different_seeds",})}},
			{n = G.UIT.R,
				config = {
					padding = 0,
					align = "cr",
					},
				nodes = {
				Disableable_Toggle({
					enabled_ref_table = MP.LOBBY,
					label = localize("b_opts_player_diff_deck"),
					ref_table = MP.LOBBY.config,
					ref_value = "different_decks",})}},
			{n = G.UIT.R,
				config = {
					padding = 0,
					align = "cr",
					},
				nodes = {
				Disableable_Toggle({
					enabled_ref_table = MP.LOBBY,
					label = localize("b_opts_multiplayer_jokers"),
					ref_table = MP.LOBBY.config,
					ref_value = "multiplayer_jokers",})}},
			{n = G.UIT.R,
				config = {
					padding = 0,
					align = "cr",
					},
				nodes = {
				Disableable_Toggle({
					enabled_ref_table = MP.LOBBY,
					label = localize("b_opts_normal_bosses"),
					ref_table = MP.LOBBY.config,
					ref_value = "normal_bosses",})}},
		}
	}
end

function MP.UI.create_UIBox_players()

local players = {}
if MP.LOBBY.players then
	for i, player in pairs(MP.LOBBY.players) do
		local lobby_player = MP.LOBBY.players[i].profile
		local username = lobby_player and lobby_player.username or ("Player " .. tostring(i))
		local colour = G.C.RED
		if MP.UTILS.is_coop() then
			colour = lighten(G.C.BLUE, 0.5)
		end
		table.insert(players, MP.UI.create_UIBox_player_row(username, player.game_state, colour))
	end
end

	local t = {
		n = G.UIT.ROOT,
		config = { align = "cm", minw = 3, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
		nodes = {
			{ n = G.UIT.R, config = { align = "cm", colour = G.C.CLEAR, padding = 0.04 }, nodes = players },
		},
	}
	return t
end

function MP.UI.create_UIBox_mods_list(type)
	return {
		n = G.UIT.R,
		config = { align = "cm", colour = G.C.WHITE, r = 0.1 },
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = MP.UI.hash_str_to_view(
					type == "host" and MP.LOBBY.players[1].hash_str or MP.LOBBY.players[2].hash_str,
					G.C.UI.TEXT_DARK
				),
			},
		},
	}
end

local ease_round_ref = ease_round
function ease_round(mod)
	if MP.LOBBY.code and (not MP.LOBBY.config.disable_live_and_timer_hud) and MP.LOBBY.config.timer then
		return
	end
	ease_round_ref(mod)
end

function G.FUNCS.mp_timer_button(e)
	if MP.LOBBY.config.timer then
		if MP.GAME.ready_blind then
			if not MP.GAME.timer_started then
				MP.ACTIONS.start_ante_timer()
			else
				MP.ACTIONS.pause_ante_timer()
			end
		end
	end
end

function G.FUNCS.set_timer_box(e)
	if MP.LOBBY.config.timer then
		if MP.GAME.timer_started then
			e.config.colour = G.C.DYN_UI.BOSS_DARK
			e.children[1].config.object.colours = { G.C.IMPORTANT }
			return
		end
		if not MP.GAME.timer_started and MP.GAME.ready_blind then
			e.config.colour = G.C.IMPORTANT
			e.children[1].config.object.colours = { G.C.UI.TEXT_LIGHT }
			return
		end
		e.config.colour = G.C.DYN_UI.BOSS_DARK
		e.children[1].config.object.colours = { G.C.UI.TEXT_DARK }
	end
end

MP.timer_event = Event({
	blockable = false,
	blocking = false,
	pause_force = true,
	no_delete = true,
	trigger = "after",
	delay = 1,
	timer = "UPTIME",
	func = function()
		if not MP.GAME.timer_started then
			return true
		end
		MP.GAME.timer = MP.GAME.timer - 1
		if MP.GAME.timer <= 0 then
			MP.GAME.timer = 0
			if not MP.GAME.ready_blind and not MP.is_online_boss() then
				MP.ACTIONS.fail_timer()
			end
			return true
		end
		MP.timer_event.start_timer = false
	end,
})