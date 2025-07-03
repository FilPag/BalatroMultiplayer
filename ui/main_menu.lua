MULTIPLAYER_VERSION = SMODS.Mods["Multiplayer"].version .. "-MULTIPLAYER"

function nope_a_joker(card)
	attention_text({
		text = localize("k_nope_ex"),
		scale = 0.8,
		hold = 0.8,
		major = card,
		backdrop_colour = G.C.SECONDARY_SET.Tarot,
		align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and "tm" or "cm",
		offset = {
			x = 0,
			y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0,
		},
		silent = true,
	})
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.06 * G.SETTINGS.GAMESPEED,
		blockable = false,
		blocking = false,
		func = function()
			play_sound("tarot2", 0.76, 0.4)
			return true
		end,
	}))
	play_sound("tarot2", 1, 0.4)
end

local function juice_up(thing, a, b)
	if SMODS.Mods["Talisman"] and SMODS.Mods["Talisman"].can_load then
		local disable_anims = Talisman.config_file.disable_anims
		Talisman.config_file.disable_anims = false
		thing:juice_up(a, b)
		Talisman.config_file.disable_anims = disable_anims
	else
		thing:juice_up(a, b)
	end
end

function wheel_of_fortune_the_card(card)
	math.randomseed(os.time())
	local chance = math.random(4)
	if chance == 1 then
		local editions = {
			{name = 'e_foil', weight = 499},
			{name = 'e_holo', weight = 350},
			{name = 'e_polychrome', weight = 150},
			{name = 'e_negative', weight = 1}
		}
		local edition = poll_edition("main_menu"..os.time(), nil, nil, true, editions)
		card:set_edition(edition, true)
		juice_up(card, 0.3, 0.5)
		G.CONTROLLER.locks.edition = false	-- if this isn't done, set_edition will block inputs for 0.1s
	else
		nope_a_joker(card)
		juice_up(card, 0.3, 0.5)
	end
end

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

function add_custom_multiplayer_cards(change_context)
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

local game_main_menu_ref = Game.main_menu
---@diagnostic disable-next-line: duplicate-set-field
function Game:main_menu(change_context)
	local ret = game_main_menu_ref(self, change_context)

	add_custom_multiplayer_cards(change_context)

	-- Add version to main menu
	UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = {
				align = "cm",
				colour = G.C.UI.TRANSPARENT_DARK,
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.3,
						text = MULTIPLAYER_VERSION,
						colour = G.C.UI.TEXT_LIGHT,
					},
				},
			},
		},
		config = {
			align = "tri",
			bond = "Weak",
			offset = {
				x = 0,
				y = 0.6,
			},
			major = G.ROOM_ATTACH,
		},
	})

	return ret
end

function G.UIDEF.ruleset_selection_options()
	MP.LOBBY.config.ruleset = "ruleset_mp_standard"

	local default_ruleset_area = UIBox({
		definition = G.UIDEF.ruleset_info("standard"),
		config = {align = "cm"}
	})

	local ruleset_buttons_data = {
		{button_id = "standard_ruleset_button", button_localize_key = "k_standard"},
		{button_id = "vanilla_ruleset_button", button_localize_key = "k_vanilla"},
		{button_id = "badlatro_ruleset_button", button_localize_key = "k_badlatro"},
	}

	return MP.UI.Main_Lobby_Options("ruleset_area", default_ruleset_area,
														 "change_ruleset_selection", ruleset_buttons_data)
end

function G.FUNCS.change_ruleset_selection(e)
	MP.UI.Change_Main_Lobby_Options(e, "ruleset_area", G.UIDEF.ruleset_info, "standard_ruleset_button",
														 function (ruleset_name) MP.LOBBY.config.ruleset = "ruleset_mp_" .. ruleset_name end)

	MP.LOBBY.ruleset_preview = false
end

function G.UIDEF.ruleset_info(ruleset_name)
	local ruleset = MP.Rulesets["ruleset_mp_" .. ruleset_name]

	local ruleset_desc = MP.UTILS.wrapText(localize("k_" .. ruleset_name .. "_description"), 100)
	local _, ruleset_desc_lines = ruleset_desc:gsub("\n", " ")

	local ruleset_banned_tabs = UIBox({
		definition = G.UIDEF.ruleset_tabs(ruleset),
		config = {align = "cm"}
	})

	return {n=G.UIT.ROOT, config={align = "tm", minh = 8, maxh = 8, minw = 11, maxw = 11, colour = G.C.CLEAR}, nodes={
		{n=G.UIT.C, config={align = "tm", padding = 0.2, r = 0.1, colour = G.C.BLACK}, nodes={
			{n=G.UIT.R, config={align = "tm", padding = 0.05, minw = 11, maxw = 11, minh = math.max(2, ruleset_desc_lines) * 0.35}, nodes={
				{n=G.UIT.T, config={text = ruleset_desc, colour = G.C.UI.TEXT_LIGHT, scale = 0.8}}
			}},
			{n=G.UIT.R, config={align = "cm"}, nodes={
				{n=G.UIT.O, config={object = ruleset_banned_tabs}}
			}},
			{n=G.UIT.R, config={align = "cm"}, nodes={
				{n=G.UIT.R, config={id = "select_gamemode_button", button = "select_gamemode", align = "cm", padding = 0.05, r = 0.1, minw = 8, minh = 0.8, colour = G.C.BLUE, hover = true, shadow = true}, nodes={
					{n=G.UIT.T, config={text = localize("b_next"), scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
				}}
			}}
		}}
	}}
end

function G.UIDEF.ruleset_tabs(ruleset)
	local default_tabs = UIBox({
		definition = G.UIDEF.ruleset_tabs_definition(ruleset, true, 1),
		config = {align = "cm", is_bans_tabs = true, chosen_tab = 1}
	})

	return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.L_BLACK, r = 0.1}, nodes={
		{n=G.UIT.C, config={align = "cm"}, nodes={
			{n=G.UIT.R, config={align = "tm", colour = G.C.GREY, r = 0.1}, nodes={
				{n=G.UIT.O, config={object = default_tabs}}
			}},
			{n=G.UIT.R, config={align = "bm", padding = 0.05}, nodes={
				create_option_cycle({
					options = {localize("k_bans"), localize("k_reworks")},
					current_option = 1,
					opt_callback = "ruleset_switch_tabs",
					opt_args = {ui = default_tabs, ruleset = ruleset},
					w = 5, colour = G.C.RED, cycle_shoulders = false})
			}}
		}}
	}}
end

function G.FUNCS.ruleset_switch_tabs(args)
	if not args or not args.cycle_config then return end
	local callback_args = args.cycle_config.opt_args

	local tabs_object = callback_args.ui
	local tabs_wrap = tabs_object.parent

	local active_tab_idx = tabs_wrap.UIBox:get_UIE_by_ID("ruleset_active_tab").config.tab_idx

	tabs_object.config.is_bans_tabs = not tabs_object.config.is_bans_tabs

	if tabs_object.config.is_bans_tabs then
		MP.LOBBY.config.ruleset = nil
		MP.LOBBY.ruleset_preview = false
	else
		MP.LOBBY.config.ruleset = callback_args.ruleset.key
		MP.LOBBY.ruleset_preview = true
	end

	tabs_wrap.config.object:remove()
	tabs_wrap.config.object = UIBox({
		definition = tabs_object.config.is_bans_tabs and G.UIDEF.ruleset_tabs_definition(callback_args.ruleset, true, active_tab_idx) or G.UIDEF.ruleset_tabs_definition(callback_args.ruleset, false, active_tab_idx),
		config = {align = "cm", parent = tabs_wrap}
	})

	tabs_wrap.UIBox:recalculate()
end

function G.UIDEF.ruleset_tabs_definition(ruleset, is_banned_tab, chosen_tab_idx)
	local banned_cards_tabs = {}

	local function copy_all_banned_ids(global_bans, ruleset_bans)
		local ret = {}
		for v,_ in pairs(global_bans) do ret[#ret+1] = v end
		if ruleset_bans then
			for _,v in ipairs(ruleset_bans) do table.insert(ret, v) end
		end
		return ret
	end

	for k, v in ipairs({{type = localize("b_jokers"), obj_ids = is_banned_tab and copy_all_banned_ids(MP.DECK.BANNED_JOKERS, ruleset.banned_jokers) or ruleset.reworked_jokers},
											{type = localize("b_stat_consumables"), obj_ids = is_banned_tab and copy_all_banned_ids(MP.DECK.BANNED_CONSUMABLES, ruleset.banned_consumables) or ruleset.reworked_consumables},
											{type = localize("b_vouchers"), obj_ids = is_banned_tab and copy_all_banned_ids(MP.DECK.BANNED_VOUCHERS, ruleset.banned_vouchers) or ruleset.reworked_vouchers},
											{type = localize("b_enhanced_cards"), obj_ids = is_banned_tab and copy_all_banned_ids(MP.DECK.BANNED_ENHANCEMENTS, ruleset.banned_enhancements) or ruleset.reworked_enhancements},
											{type = localize("k_other"), obj_ids = is_banned_tab and {tags = copy_all_banned_ids(MP.DECK.BANNED_TAGS, ruleset.banned_tags), blinds = copy_all_banned_ids(MP.DECK.BANNED_BLINDS, ruleset.banned_blinds)} or {tags = ruleset.reworked_tags or {}, blinds = ruleset.reworked_blinds or {}}}})
	do
		v.idx = k
		v.is_banned_tab = is_banned_tab
		local tab_def = {label = v.type,
										 chosen = (k == chosen_tab_idx),
										 tab_definition_function = G.UIDEF.ruleset_cardarea_definition,
										 tab_definition_function_args = v}
		table.insert(banned_cards_tabs, tab_def)
	end

	return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
		create_tabs({tab_h = 4.2, padding = 0, scale = 0.8, text_scale = 0.36, no_shoulders = true, no_loop = true,
								 tabs = banned_cards_tabs})
	}}
end

function G.UIDEF.ruleset_cardarea_definition(args)
	local function get_ruleset_cardarea(obj_ids, width, height)
		local ret = {}

		if #obj_ids > 0 then
			local card_rows = {}
			local n_rows = math.max(1, 1 + math.floor(#obj_ids/10) - math.floor(math.log(6, #obj_ids)))
			local max_width = 1
			for k, v in ipairs(obj_ids) do
				local _row = math.ceil(n_rows * (k/(#obj_ids)))
				card_rows[_row] = card_rows[_row] or {}
				card_rows[_row][#card_rows[_row]+1] = v
				if #card_rows[_row] > max_width then max_width = #card_rows[_row] end
			end

			local card_size = math.max(0.3, 0.8 - 0.01*(max_width*n_rows))

			for _, card_row in ipairs(card_rows) do
				local card_area = CardArea(
					0, 0,
					width, height/n_rows,
					{card_limit = nil, type = 'title_2', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*card_size}
				)

				for k, v in ipairs(card_row) do -- Each card_row consists of Card IDs
					local card = Card(0,0, G.CARD_W*card_size, G.CARD_H*card_size, nil, G.P_CENTERS[v], {bypass_discovery_center = true,bypass_discovery_ui = true})
					card_area:emplace(card)
				end

				table.insert(ret,
										 {n=G.UIT.R, config={align = "cm"}, nodes={
											 {n=G.UIT.O, config={object = card_area}}
										 }})
			end
		end

		return ret
	end

	local function get_ruleset_obj_grid(obj_ids, obj_ref_table, objs_per_row, obj_constructor, wrap_as_object)
		local objs = {}
		for _,v in ipairs(obj_ids) do objs[#objs+1] = obj_ref_table[v] end
		-- table.sort(objs, function (a, b) return a.order < b.order end)

		local obj_grid = {}
		local obj_rows = {}
		for k,v in ipairs(objs) do
			local obj = obj_constructor(v)

			local row_idx = math.ceil(k/objs_per_row)
			if not obj_rows[row_idx] then obj_rows[row_idx] = {} end
			table.insert(obj_rows[row_idx], {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
				wrap_as_object
					and {n=G.UIT.O, config={object = obj}}
					or obj
			}})
		end
		for _,v in ipairs(obj_rows) do
			table.insert(obj_grid, {n=G.UIT.R, config={align = "cm"}, nodes=v})
		end

		return obj_grid
	end

	local function get_localised_label(objs, obj_type)
		return (#objs > 0)
			and {n=G.UIT.T, config={text = localize({type = "variable", key = args.is_banned_tab and "k_banned_objs" or "k_reworked_objs", vars = {obj_type}}), colour = lighten(G.C.L_BLACK, 0.5), scale = 0.33}}
			or {n=G.UIT.T, config={text = localize({type = "variable", key = args.is_banned_tab and "k_no_banned_objs" or "k_no_reworked_objs", vars = {obj_type}}), colour = lighten(G.C.L_BLACK, 0.5), scale = 0.33}}
	end

	if args.type == localize("k_other") then
		local function tag_constructor(tag_spec)
			return Tag(tag_spec.key):generate_UI(1 - 0.1*(math.sqrt(#args.obj_ids.tags)))
		end

		local function blind_constructor(blind_spec)
			local temp_blind = AnimatedSprite(0,0,1.1,1.1, G.ANIMATION_ATLAS[blind_spec.atlas] or G.ANIMATION_ATLAS['blind_chips'], blind_spec.pos)
			temp_blind:define_draw_steps({
				{shader = 'dissolve', shadow_height = 0.05},
				{shader = 'dissolve'}
			})
			temp_blind.float = true
			temp_blind.states.hover.can = true
			temp_blind.states.drag.can = false
			temp_blind.states.collide.can = true
			temp_blind.config = {blind = blind_spec, force_focus = true}
			temp_blind.hover = function()
				if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
						if not temp_blind.hovering and temp_blind.states.visible then
							temp_blind.hovering = true
							temp_blind.hover_tilt = 3
							juice_up(temp_blind, 0.05, 0.02)
							temp_blind.config.h_popup = create_UIBox_blind_popup(blind_spec, true)
							temp_blind.config.h_popup_config ={align = 'cl', offset = {x=-0.1,y=0},parent = temp_blind}
							Node.hover(temp_blind)
						end
				end
			end
			temp_blind.stop_hover = function() temp_blind.hovering = false; Node.stop_hover(temp_blind); temp_blind.hover_tilt = 0 end

			return temp_blind
		end

		local tag_grid = get_ruleset_obj_grid(args.obj_ids.tags, G.P_TAGS, 4, tag_constructor)
		local blind_grid = get_ruleset_obj_grid(args.obj_ids.blinds, G.P_BLINDS, 3, blind_constructor, true)

		return {n=G.UIT.ROOT, config={id = "ruleset_active_tab", tab_idx = args.idx, align = "cm", colour = G.C.CLEAR}, nodes={
			{n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1, minw = 5.4, minh = 4.8, maxh = 4.8}, nodes={
				{n=G.UIT.R, config={align = "cm", minh = 4}, nodes=tag_grid},
				{n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={get_localised_label(args.obj_ids.tags, localize("b_tags"))}}
			}},
			{n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1, minw = 5.4, minh = 4.8, maxh = 4.8}, nodes={
				{n=G.UIT.R, config={align = "cm", minh = 4}, nodes=blind_grid},
				{n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={get_localised_label(args.obj_ids.blinds, localize("b_blinds"))}}
			}}
		}}
	else
		local cards_grid = get_ruleset_cardarea(args.obj_ids, 10, 4)

		return {n=G.UIT.ROOT, config={id = "ruleset_active_tab", tab_idx = args.idx, align = "cm", colour = G.C.CLEAR}, nodes={
			{n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1, minw = 10.8, minh = 4.8, maxh = 4.8}, nodes={
				{n=G.UIT.R, config={align = "cm"}, nodes=cards_grid},
				{n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={get_localised_label(args.obj_ids, args.type)}}
			}}
		}}
	end
end

function G.UIDEF.gamemode_selection_options()
	MP.LOBBY.config.gamemode = "gamemode_mp_attrition"

	local default_gamemode_area = UIBox({
		definition = G.UIDEF.gamemode_info("attrition"),
		config = {align = "cm"}
	})

	local gamemode_buttons_data = {
		{button_id = "attrition_gamemode_button", button_localize_key = "k_attrition"},
		{button_id = "showdown_gamemode_button", button_localize_key = "k_showdown"},
		{button_id = "survival_gamemode_button", button_localize_key = "k_survival"},
	}

	return MP.UI.Main_Lobby_Options("gamemode_area", default_gamemode_area,
														 "change_gamemode_selection", gamemode_buttons_data)
end

function G.FUNCS.change_gamemode_selection(e)
	MP.UI.Change_Main_Lobby_Options(e, "gamemode_area", G.UIDEF.gamemode_info, "attrition_gamemode_button",
														 function (gamemode_name) MP.LOBBY.config.gamemode = "gamemode_mp_" .. gamemode_name end)
end

function G.UIDEF.gamemode_info(gamemode_name)
	local gamemode = MP.Gamemodes["gamemode_mp_" .. gamemode_name]

	local gamemode_desc = MP.UTILS.wrapText(localize("k_" .. gamemode_name .. "_description"), 100)
	local _, gamemode_desc_lines = gamemode_desc:gsub("\n", " ")

	return {n=G.UIT.ROOT, config={align = "tm", minh = 8, maxh = 8, minw = 11, maxw = 11, colour = G.C.CLEAR}, nodes={
		{n=G.UIT.C, config={align = "tm", padding = 0.2, r = 0.1, colour = G.C.BLACK, minh = 8}, nodes={
			{n=G.UIT.R, config={align = "tm", padding = 0.05, minw = 11, maxw = 11, minh = 8}, nodes={
				{n=G.UIT.T, config={text = gamemode_desc, colour = G.C.UI.TEXT_LIGHT, scale = 0.8}}
			}},
			{n=G.UIT.R, config={align = "cm"}, nodes={
				{n=G.UIT.R, config={id = "start_lobby_button", button = "start_lobby", align = "cm", padding = 0.05, r = 0.1, minw = 8, minh = 0.8, colour = G.C.BLUE, hover = true, shadow = true}, nodes={
					{n=G.UIT.T, config={text = localize("b_create_lobby"), scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
				}}
			}}
		}}
	}}
end

function G.UIDEF.create_UIBox_join_lobby_button()
	return (
		create_UIBox_generic_options({
			back_func = "play_options",
			contents = {
				{
					n = G.UIT.R,
					config = {
						padding = 0,
						align = "cm",
					},
					nodes = {
						{
							n = G.UIT.R,
							config = {
								padding = 0.5,
								align = "cm",
							},
							nodes = {
								create_text_input({
									w = 4,
									h = 1,
									max_length = 5,
									all_caps = true,
									prompt_text = localize("k_enter_lobby_code"),
									ref_table = MP.LOBBY,
									ref_value = "temp_code",
									extended_corpus = false,
									keyboard_offset = 1,
									minw = 5,
									callback = function(val)
										MP.ACTIONS.join_lobby(MP.LOBBY.temp_code)
									end,
								}),
							},
						},
						UIBox_button({
							label = { localize("k_paste") },
							colour = G.C.RED,
							button = "join_from_clipboard",
							minw = 5,
						}),
					},
				},
			},
		})
	)
end

function G.UIDEF.override_main_menu_play_button()
	return (
		create_UIBox_generic_options({
			contents = {
				UIBox_button({
					label = { localize("b_singleplayer") },
					colour = G.C.BLUE,
					button = "setup_run_singleplayer",
					minw = 5,
				}),
				MP.LOBBY.connected and UIBox_button({
					label = { localize("b_create_lobby") },
					colour = G.C.GREEN,
					button = "create_lobby",
					minw = 5,
				}) or nil,
				MP.LOBBY.connected and UIBox_button({
					label = { localize("b_join_lobby") },
					colour = G.C.RED,
					button = "join_lobby",
					minw = 5,
				}) or nil,
				not MP.LOBBY.connected and UIBox_button({
					label = { localize("b_reconnect") },
					colour = G.C.RED,
					button = "reconnect",
					minw = 5,
				}) or nil,
			},
		})
	)
end

function G.FUNCS.setup_run_singleplayer(e)
	G.SETTINGS.paused = true
	MP.LOBBY.config.ruleset = nil
	MP.LOBBY.config.gamemode = nil
	G.FUNCS.setup_run(e)
end

function G.FUNCS.play_options(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = G.UIDEF.override_main_menu_play_button(),
	})
end

function G.FUNCS.create_lobby(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = G.UIDEF.ruleset_selection_options(),
	})
end

function G.FUNCS.select_gamemode(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = G.UIDEF.gamemode_selection_options(),
	})
end

function G.FUNCS.join_lobby(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = G.UIDEF.create_UIBox_join_lobby_button(),
	})
end

function G.FUNCS.join_from_clipboard(e)
	MP.LOBBY.temp_code = MP.UTILS.get_from_clipboard()
	MP.ACTIONS.join_lobby(MP.LOBBY.temp_code)
end

function G.FUNCS.start_lobby(e)
	G.SETTINGS.paused = false
	if MP.LOBBY.config.ruleset == "ruleset_mp_vanilla" then
		MP.LOBBY.config.multiplayer_jokers = false
	else
		MP.LOBBY.config.multiplayer_jokers = true
	end

	if MP.LOBBY.config.gamemode == "gamemode_mp_survival" then
		MP.LOBBY.config.starting_lives = 1
		MP.LOBBY.config.disable_live_and_timer_hud = true
	else
		MP.LOBBY.config.starting_lives = 4
		MP.LOBBY.config.disable_live_and_timer_hud = false
	end

	-- Check if the current gamemode is valid. If it's not, default to attrition.
	local gamemode_check = false
	for k, _ in pairs(MP.Gamemodes) do
		if k == MP.LOBBY.config.gamemode then
			gamemode_check = true
		end
	end
	MP.LOBBY.config.gamemode = gamemode_check and MP.LOBBY.config.gamemode or "gamemode_mp_attrition"

	MP.ACTIONS.create_lobby(string.sub(MP.LOBBY.config.gamemode, 13))
	G.FUNCS.exit_overlay_menu()
end

-- Modify play button to take you to mode select first
local create_UIBox_main_menu_buttonsRef = create_UIBox_main_menu_buttons
---@diagnostic disable-next-line: lowercase-global
function create_UIBox_main_menu_buttons()
	local menu = create_UIBox_main_menu_buttonsRef()
	menu.nodes[1].nodes[1].nodes[1].nodes[1].config.button = "play_options"
	return menu
end

G.FUNCS.wipe_off = function()
	G.E_MANAGER:add_event(Event({
		no_delete = true,
		func = function()
			delay(0.3)
			if not G.screenwipe then
				return true
			end
			G.screenwipe.children.particles.max = 0
			G.E_MANAGER:add_event(Event({
				trigger = "ease",
				no_delete = true,
				blockable = false,
				blocking = false,
				timer = "REAL",
				ref_table = G.screenwipe.colours.black,
				ref_value = 4,
				ease_to = 0,
				delay = 0.3,
				func = function(t)
					return t
				end,
			}))
			G.E_MANAGER:add_event(Event({
				trigger = "ease",
				no_delete = true,
				blockable = false,
				blocking = false,
				timer = "REAL",
				ref_table = G.screenwipe.colours.white,
				ref_value = 4,
				ease_to = 0,
				delay = 0.3,
				func = function(t)
					return t
				end,
			}))
			return true
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.55,
		no_delete = true,
		blocking = false,
		timer = "REAL",
		func = function()
			if not G.screenwipe then
				return true
			end
			if G.screenwipecard then
				G.screenwipecard:start_dissolve({ G.C.BLACK, G.C.ORANGE, G.C.GOLD, G.C.RED })
			end
			if G.screenwipe:get_UIE_by_ID("text") then
				for k, v in ipairs(G.screenwipe:get_UIE_by_ID("text").children) do
					v.children[1].config.object:pop_out(4)
				end
			end
			return true
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 1.1,
		no_delete = true,
		blocking = false,
		timer = "REAL",
		func = function()
			if not G.screenwipe then
				return true
			end
			G.screenwipe.children.particles:remove()
			G.screenwipe:remove()
			G.screenwipe.children.particles = nil
			G.screenwipe = nil
			G.screenwipecard = nil
			return true
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 1.2,
		no_delete = true,
		blocking = true,
		timer = "REAL",
		func = function()
			return true
		end,
	}))
end

function G.FUNCS.join_game_submit(e)
	G.FUNCS.exit_overlay_menu()
	MP.ACTIONS.join_lobby(MP.LOBBY.temp_code)
end

function G.FUNCS.join_game_paste(e)
	MP.LOBBY.temp_code = MP.UTILS.get_from_clipboard()
	MP.ACTIONS.join_lobby(MP.LOBBY.temp_code)
	G.FUNCS.exit_overlay_menu()
end
