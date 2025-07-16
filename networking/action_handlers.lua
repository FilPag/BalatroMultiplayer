--- @class client_data
--- @field username string
--- @field colour string
--- @field modHash string
--- @field isCached boolean
--- @field isReady boolean
--- @field firstReady boolean

--- @player_state
--- @class player_state
--- @field lives number
--- @field score number 
--- @field highest_score number 
--- @field hands_left number
--- @field ante number
--- @field skips number
--- @field furthest_blind number
--- @field lives_blocker boolean
--- @field location string

--- @class lobby_info
--- @field host string
--- @field hostHash string
--- @field hostCached boolean
--- @field isHost boolean
--- @field local_id string
--- @field players? table[] @ Array of player objects: { username: string, modHash: string, isCached: boolean, id: string }


local json = require "json"
Client = {}

function Client.send(msg)
	if msg ~= '{"action":"keepAliveAck"}' and msg ~= "action:keepAliveAck" then
		sendTraceMessage(string.format("Client sent message: %s", msg), "MULTIPLAYER")
	end
	love.thread.getChannel("uiToNetwork"):push(msg)
end

-- Server to Client

--- @alias BossKey string

--- Handles setting the boss blind in the game.
--- @param bossKey BossKey
local function action_set_boss_blind(bossKey)
	if G.GAME.round_resets.blind_choices.Boss == bossKey then 
			MP.next_coop_boss = nil
		return 
	end

	G.GAME.round_resets.blind_choices.Boss = bossKey
	MP.next_coop_boss = bossKey

	if G.blind_select then
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				play_sound('other1')
				G.blind_select_opts.boss:set_role({ xy_bond = 'Weak' })
				G.blind_select_opts.boss.alignment.offset.y = 20
				return true
			end
		}))
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.3,
			func = function()
				local par = G.blind_select_opts.boss.parent
				G.blind_select_opts.boss:remove()
				G.blind_select_opts.boss = UIBox {
					T = { par.T.x, 0, 0, 0, },
					definition =
					{ n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR }, nodes = {
						UIBox_dyn_container({ create_UIBox_blind_choice('Boss') }, false, get_blind_main_colour('Boss'), mix_colours(G.C.BLACK, get_blind_main_colour('Boss'), 0.8))
					} },
					config = { align = "bmi",
						offset = { x = 0, y = G.ROOM.T.y + 9 },
						major = par,
						xy_bond = 'Weak'
					}
				}
				par.config.object = G.blind_select_opts.boss
				par.config.object:recalculate()
				G.blind_select_opts.boss.parent = par
				G.blind_select_opts.boss.alignment.offset.y = 0
				MP.next_coop_boss = nil
				return true
			end
		}))
	end
end

local function action_connected()
	MP.LOBBY.connected = true
	MP.UI.update_connection_status()
	Client.send(json.encode({
		action = "username",
		username = MP.LOBBY.username,
		colour = MP.LOBBY.blind_col,
		modHash = MP.MOD_STRING
	}))
end

local function action_joinedLobby(code, type)
	MP.FLAGS.join_pressed = false
	MP.LOBBY.code = code
	MP.LOBBY.type = type
	MP.ACTIONS.sync_client()
	MP.ACTIONS.lobby_info()
	MP.UI.update_connection_status()
end

--- @param lobby_info lobby_info
local function action_lobbyInfo(lobby_info)
	MP.LOBBY.isHost = lobby_info.isHost
	MP.LOBBY.players = lobby_info.players or {}
	MP.LOBBY.local_id = lobby_info.local_id
	MP.LOBBY.ready_to_start = MP.LOBBY.isHost and #MP.LOBBY.players >= 2

	MP.ACTIONS.update_player_usernames()
end

local function action_error(message)
	sendWarnMessage(message, "MULTIPLAYER")

	MP.UTILS.overlay_message(message)
end

local function action_keep_alive()
	Client.send(json.encode({ action = "keepAliveAck" }))
end

local function action_disconnected()
	MP.LOBBY.connected = false
	if MP.LOBBY.code then
		MP.LOBBY.code = nil
	end
	MP.UI.update_connection_status()
end

---@param deck string
---@param seed string
---@param stake_str string
local function action_start_game(players, seed, stake_str)
	MP.reset_game_states()
	local stake = tonumber(stake_str)
	MP.ACTIONS.set_ante(0)
	MP.GAME.players = players

	for _, player in ipairs(MP.GAME.players) do
		player.location = MP.player_state_manager.parse_enemy_location(player.location)
		player.score = MP.INSANE_INT.from_string(player.score) or MP.INSANE_INT.empty()
		player.highest_score = MP.INSANE_INT.from_string(player.highest_score) or MP.INSANE_INT.empty()
	end

	if not MP.LOBBY.config.different_seeds and MP.LOBBY.config.custom_seed ~= "random" then
		seed = MP.LOBBY.config.custom_seed
	end

	G.FUNCS.lobby_start_run(nil, { seed = seed, stake = stake })
end

local function action_start_blind()
	MP.GAME.ready_blind = false
	MP.GAME.timer_started = false
	MP.GAME.timer = MP.LOBBY.config.timer_base_seconds

	if MP.GAME.next_blind_context then
		G.FUNCS.select_blind(MP.GAME.next_blind_context)
	else
		sendErrorMessage("No next blind context", "MULTIPLAYER")
	end
end

local function action_game_state_update(player_id, updates)
	MP.player_state_manager.process(player_id, updates)
end

local function action_stop_game()
	if G.STAGE ~= G.STAGES.MAIN_MENU then
		G.FUNCS.go_to_menu()
		MP.UI.update_connection_status()
		MP.reset_game_states()
	end
end

local function action_end_pvp()
	MP.GAME.end_pvp = true
	MP.GAME.timer = MP.LOBBY.config.timer_base_seconds
	MP.GAME.timer_started = false
end

local function action_win_game()
  MP.ACTIONS.sendPlayerDeck()
	G.E_MANAGER:add_event(Event({
		no_delete = true,
		trigger = "immediate",
		blockable = true,
		blocking = false,
		func = function()
			MP.end_game_jokers_payload = ""
			MP.nemesis_deck_string = ""
			MP.end_game_jokers_received = false
			MP.nemesis_deck_received = false
			win_game()
			MP.GAME.won = true
			return true
		end,
	}))
end

local function action_lose_game()
  MP.ACTIONS.sendPlayerDeck()
	G.E_MANAGER:add_event(Event({
		no_delete = true,
		trigger = "immediate",
		blockable = true,
		blocking = false,
		func = function()
			MP.GAME.won = false
			MP.end_game_jokers_payload = ""
			MP.nemesis_deck_string = ""
			MP.end_game_jokers_received = false
			MP.nemesis_deck_received = false
			G.STATE_COMPLETE = false
			G.STATE = G.STATES.GAME_OVER
			return true
		end,
	}))
end

-- Helper: parse option value by type
local function parse_option_value(type_str, v)
	if type_str == "boolean" then
		return (v == true or v == "true")
	elseif type_str == "number" then
		return tonumber(v)
	elseif type_str == "string" then
		return tostring(v)
	else
		return v
	end
end

-- Helper: check if any of the given keys changed between two tables
local function any_key_changed(keys, old_tbl, new_tbl)
	for _, k in ipairs(keys) do
		if old_tbl[k] ~= new_tbl[k] then
			return true
		end
	end
	return false
end

local config_map = {
	starting_lives = { type = "number" },
	pvp_start_round = { type = "number" },
	timer_base_seconds = { type = "number" },
	timer_increment_seconds = { type = "number" },
	showdown_starting_antes = { type = "number" },
	different_decks = { type = "boolean" },
	gold_on_life_loss = { type = "boolean" },
	no_gold_on_round_loss = { type = "boolean" },
	death_on_round_loss = { type = "boolean" },
	different_seeds = { type = "boolean" },
	multiplayer_jokers = { type = "boolean" },
	normal_bosses = { type = "boolean" },
	custom_seed = { type = "string" },
	stake = { type = "number" },
	back = { type = "string" },
	challenge = { type = "string" },
	-- Add more config keys here as needed
}

local function update_lobby_config(options)
	local changed_keys = {}
	local old_config = {}
	for k, v in pairs(MP.LOBBY.config) do old_config[k] = v end

	for k, v in pairs(options) do
		local entry = config_map[k]
		local parsed_v = entry and parse_option_value(entry.type, v) or v
		if MP.LOBBY.config[k] ~= parsed_v then
			MP.LOBBY.config[k] = parsed_v
			changed_keys[k] = true
		end
	end
	return changed_keys, old_config, MP.LOBBY.config
end

local function update_overlay_toggles(changed_keys)
	if not G.OVERLAY_MENU then return end
	for k in pairs(changed_keys) do
		local config_uie = G.OVERLAY_MENU:get_UIE_by_ID(k .. "_toggle")
		if config_uie then
			G.FUNCS.toggle(config_uie)
		end
	end
end

local function action_invalidLobby()
	MP.FLAGS.join_pressed = false
	MP.UTILS.overlay_message("Invalid lobby code")
end

local function action_lobby_options(options)
	local changed_keys, old_config, new_config = update_lobby_config(options)

	-- Only update UI if deck, stake, or different_decks changed
	if any_key_changed({ "stake", "back", "different_decks" }, old_config, new_config) then
		if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove() end
		set_main_menu_UI()
	end

	update_overlay_toggles(changed_keys)

	if old_config.different_decks ~= new_config.different_decks then
		G.FUNCS.exit_overlay_menu() -- throw out guest from any menu.
	end
end

local function action_send_phantom(key)
	local menu = G.OVERLAY_MENU -- we are spoofing a menu here, which disables duplicate protection
	G.OVERLAY_MENU = G.OVERLAY_MENU or true
	local new_card = create_card("Joker", MP.shared, false, nil, nil, nil, key)
	new_card:set_edition("e_mp_phantom")
	new_card:add_to_deck()
	MP.shared:emplace(new_card)
	G.OVERLAY_MENU = menu
end

local function action_remove_phantom(key)
	local card = MP.UTILS.get_phantom_joker(key)
	if card then
		card:remove_from_deck()
		card:start_dissolve({ G.C.RED }, nil, 1.6)
		MP.shared:remove_card(card)
	end
end

-- card:remove is called in an event so we have to hook the function instead of doing normal things
local cardremove = Card.remove
function Card:remove()
	local menu = G.OVERLAY_MENU
	if self.edition and self.edition.type == 'mp_phantom' then
		G.OVERLAY_MENU = G.OVERLAY_MENU or true
	end
	cardremove(self)
	G.OVERLAY_MENU = menu
end

-- and smods find card STILL needs to be patched here
local smodsfindcard = SMODS.find_card
function SMODS.find_card(key, count_debuffed)
	local ret = smodsfindcard(key, count_debuffed)
	local new_ret = {}
	for i, v in ipairs(ret) do
		if not v.edition or v.edition.type ~= 'mp_phantom' then
			new_ret[#new_ret + 1] = v
		end
	end
	return new_ret
end

-- don't poll edition
local origedpoll = poll_edition
function poll_edition(_key, _mod, _no_neg, _guaranteed)
	if G.OVERLAY_MENU then return nil end
	return origedpoll(_key, _mod, _no_neg, _guaranteed)
end

local function action_speedrun()
	local function speedrun(card)
		card:juice_up()
		if #G.consumeables.cards < G.consumeables.config.card_limit then
			local card = create_card("Spectral", G.consumeables, nil, nil, nil, nil, nil, "speedrun")
			card:add_to_deck()
			G.consumeables:emplace(card)
		end
	end
	MP.UTILS.run_for_each_joker("j_mp_speedrun", speedrun)
end

local function action_version()
	MP.ACTIONS.version()
end

local action_asteroid = action_asteroid
		or function()
			local hand_priority = {
				["Flush Five"] = 1,
				["Flush House"] = 2,
				["Five of a Kind"] = 3,
				["Straight Flush"] = 4,
				["Four of a Kind"] = 5,
				["Full House"] = 6,
				["Flush"] = 7,
				["Straight"] = 8,
				["Three of a Kind"] = 9,
				["Two Pair"] = 11,
				["Pair"] = 12,
				["High Card"] = 13
			}
			local hand_type = "High Card"
			local max_level = 0


			for k, v in pairs(G.GAME.hands) do
				if v.visible then
					if to_big(v.level) > to_big(max_level) or
							(to_big(v.level) == to_big(max_level) and
								hand_priority[k] < hand_priority[hand_type]) then
						hand_type = k
						max_level = v.level
					end
				end
			end
			update_hand_text({ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 }, {
				handname = localize(hand_type, "poker_hands"),
				chips = G.GAME.hands[hand_type].chips,
				mult = G.GAME.hands[hand_type].mult,
				level = G.GAME.hands[hand_type].level,
			})
			level_up_hand(nil, hand_type, false, -1)
			update_hand_text(
				{ sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
				{ mult = 0, chips = 0, handname = "", level = "" }
			)
		end

local function action_sold_joker()
	local function juice_taxes(card)
		if card then
			card.ability.extra.mult = card.ability.extra.mult_gain + card.ability.extra.mult
			card:juice_up()
		end
	end
	MP.UTILS.run_for_each_joker("j_mp_taxes", juice_taxes)
end

local function action_lets_go_gambling_nemesis()
	local card = MP.UTILS.get_phantom_joker("j_mp_lets_go_gambling")
	if card then
		card:juice_up()
	end
	ease_dollars(card and card.ability and card.ability.extra and card.ability.extra.nemesis_dollars or 5)
end

local function action_eat_pizza(whole)
	local function eat_whole(card)
		card:remove_from_deck()
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				attention_text({
					text = localize("k_eaten_ex"),
					scale = 0.6,
					hold = 1.4,
					major = card,
					backdrop_colour = G.C.FILTER,
					align = "bm",
					offset = {
						x = 0,
						y = 0,
					},
				})
				card:start_dissolve({ G.C.RED }, nil, 1.6)
				return true
			end,
		}))
	end

	whole = whole == "true"
	local card = MP.UTILS.get_joker("j_mp_pizza") or MP.UTILS.get_phantom_joker("j_mp_pizza")
	if card then
		if whole then
			eat_whole(card)
			return
		end
		card:juice_up()
		card.ability.extra.discards = card.ability.extra.discards - card.ability.extra.discards_loss
		if card.ability.extra.discards <= 0 then
			eat_whole(card)
			return
		end
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				attention_text({
					text = localize({
						type = "variable",
						key = "a_remaining",
						vars = { card.ability.extra.discards },
					}),
					scale = 0.6,
					hold = 1.4,
					major = card,
					backdrop_colour = G.C.RED,
					align = "bm",
					offset = {
						x = 0,
						y = 0,
					},
				})
				return true
			end,
		}))
	end
end

local function action_spent_last_shop(amount)
	MP.UTILS.get_nemesis().spent_last_shop = tonumber(amount)
end

local function action_magnet()
	local card = nil
	for _, v in pairs(G.jokers.cards) do
		if not card or v.sell_cost > card.sell_cost then
			card = v
		end
	end

	if card then
		local candidates = {}
		for _, v in pairs(G.jokers.cards) do
			if (v.sell_cost == card.sell_cost) then
				table.insert(candidates, v)
			end
		end

		-- Scale the pseudo from 0 - 1 to the number of candidates
		local random_index = math.floor(pseudorandom('j_mp_magnet') * #candidates) + 1
		local chosen_card = candidates[random_index]
		sendTraceMessage(string.format("Sending magnet joker: %s", MP.UTILS.joker_to_string(chosen_card)), "MULTIPLAYER")

		local card_save = chosen_card:save()
		local card_encoded = MP.UTILS.str_pack_and_encode(card_save)
		MP.ACTIONS.magnet_response(card_encoded)
	end
end

local function action_magnet_response(key)
	local card_save, success, err

	card_save, err = MP.UTILS.str_decode_and_unpack(key)
	if not card_save then
		sendDebugMessage(string.format("Failed to unpack magnet joker: %s", err), "MULTIPLAYER")
		return
	end

	local card = Card(G.jokers.T.x + G.jokers.T.w / 2, G.jokers.T.y, G.CARD_W, G.CARD_H, G.P_CENTERS.j_joker,
		G.P_CENTERS.c_base)
	-- Avoid crashing if the load function ends up indexing a nil value
	success, err = pcall(card.load, card, card_save)
	if not success then
		sendDebugMessage(string.format("Failed to load magnet joker: %s", err), "MULTIPLAYER")
		return
	end

	-- BALATRO BUG (version 1.0.1o): `card.VT.h` is mistakenly set to nil after calling `card:load()`
	-- Without this call to `card:hard_set_VT()`, the game will crash later when the card is drawn
	card:hard_set_VT()

	-- Enforce "add to deck" effects (e.g. increase hand size effects)
	card.added_to_deck = nil

	card:add_to_deck()
	G.jokers:emplace(card)
	sendTraceMessage(string.format("Received magnet joker: %s", MP.UTILS.joker_to_string(card)), "MULTIPLAYER")
end

function G.FUNCS.load_end_game_jokers()
	local card_area_save, success, err

	if not MP.end_game_jokers and not MP.end_game_jokers_payload then
		return
	end

	card_area_save, err = MP.UTILS.str_decode_and_unpack(MP.end_game_jokers_payload)
	if not card_area_save then
		sendDebugMessage(string.format("Failed to unpack enemy jokers: %s", err), "MULTIPLAYER")
		return
	end

	-- Avoid crashing if the load function ends up indexing a nil value
	success, err = pcall(MP.end_game_jokers.load, MP.end_game_jokers, card_area_save)
	if not success then
		sendDebugMessage(string.format("Failed to load enemy jokers: %s", err), "MULTIPLAYER")
		-- Reset the card area if loading fails to avoid inconsistent state
		MP.end_game_jokers:remove()
		MP.end_game_jokers:init(
			0,
			0,
			5 * G.CARD_W,
			G.CARD_H,
			{ card_limit = G.GAME.starting_params.joker_slots, type = "joker", highlight_limit = 1 }
		)
		return
	end

	-- Log the jokers
	if MP.end_game_jokers.cards then
		local jokers_str = ""
		for _, card in pairs(MP.end_game_jokers.cards) do
			jokers_str = jokers_str .. ";" .. MP.UTILS.joker_to_string(card)
		end
		sendTraceMessage(string.format("Received end game jokers: %s", jokers_str), "MULTIPLAYER")
	end
end

local function action_receive_end_game_jokers(keys)
	MP.end_game_jokers_payload = keys
	MP.end_game_jokers_received = true
	G.FUNCS.load_end_game_jokers()
end

local function action_get_end_game_jokers()
	if not G.jokers or not G.jokers.cards then
		Client.send(json.encode({ action = "receiveEndGameJokers", keys = "" }))
		return
	end

	-- Log the jokers
	local jokers_str = ""
	for _, card in pairs(G.jokers.cards) do
		jokers_str = jokers_str .. ";" .. MP.UTILS.joker_to_string(card)
	end
	sendTraceMessage(string.format("Sending end game jokers: %s", jokers_str), "MULTIPLAYER")

	local jokers_save = G.jokers:save()
	local jokers_encoded = MP.UTILS.str_pack_and_encode(jokers_save)

	Client.send(json.encode({ action = "receiveEndGameJokers", keys = jokers_encoded }))
end

function G.FUNCS.load_player_deck(player)
	if not MP.LOBBY.code or not player.deck_str then
		return
	end

	if not player.cards then player.cards = {} end

	if not player.deck then
		player.deck = CardArea(-100, -100, G.CARD_W, G.CARD_H, { type = 'deck' })
	end

	local card_strings = MP.UTILS.string_split(player.deck_str, ";")

	for k, _ in pairs(player.cards) do
		player.cards[k] = nil
	end

	for _, card_str in pairs(card_strings) do
		if card_str == "" then
			goto continue
		end

		local card_params = MP.UTILS.string_split(card_str, "-")

		local suit = card_params[1]
		local rank = card_params[2]
		local enhancement = card_params[3]
		local edition = card_params[4]
		local seal = card_params[5]

		-- Validate the card parameters
		-- If invalid suit or rank, skip the card
		-- If invalid enhancement, edition, or seal, fallback to "none"
		local front_key = tostring(suit) .. "_" .. tostring(rank)
		if not G.P_CARDS[front_key] then
			sendDebugMessage(string.format("Invalid playing card key: %s", front_key), "MULTIPLAYER")
			goto continue
		end
		if not enhancement or (enhancement ~= "none" and not G.P_CENTERS[enhancement]) then
			sendDebugMessage(string.format("Invalid enhancement: %s", enhancement), "MULTIPLAYER")
			enhancement = "none"
		end
		if not edition or (edition ~= "none" and not G.P_CENTERS["e_" .. edition]) then
			sendDebugMessage(string.format("Invalid edition: %s", edition), "MULTIPLAYER")
			edition = "none"
		end
		if not seal or (seal ~= "none" and not G.P_SEALS[seal]) then
			sendDebugMessage(string.format("Invalid seal: %s", seal), "MULTIPLAYER")
			seal = "none"
		end

		-- Create the card
		local card = create_playing_card(
			{
				front = G.P_CARDS[front_key],
				center = enhancement ~= "none" and G.P_CENTERS[enhancement] or nil
			},
			player.deck, true, true, nil, false
		)
		if edition ~= "none" then
			card:set_edition({ [edition] = true }, true, true)
		end
		if seal ~= "none" then
			card:set_seal(seal, true, true)
		end

		-- Remove the card from G.playing_cards and insert into MP.nemesis_cards
		table.remove(G.playing_cards, #G.playing_cards)
		table.insert(player.cards, card)

		::continue::
	end
end

local function action_receive_player_deck(player_id, cards)
	local player = MP.UTILS.get_player_by_id(player_id)
	player.deck_str = cards
	player.deck_received = true
	G.FUNCS.load_player_deck(player)
end

local function action_start_ante_timer(time)
	if type(time) == "string" then
		time = tonumber(time)
	end
	MP.GAME.timer = time
	MP.GAME.timer_started = true
	G.E_MANAGER:add_event(MP.timer_event)
end

local function action_pause_ante_timer(time)
	if type(time) == "string" then
		time = tonumber(time)
	end
	MP.GAME.timer = time
	MP.GAME.timer_started = false
end

local action_table = {
	connected = function() action_connected() end,
	version = function() action_version() end,
	disconnected = function() action_disconnected() end,
	invalidLobby = function() action_invalidLobby() end,
	joinedLobby = function(parsedAction) action_joinedLobby(parsedAction.code, parsedAction.type) end,
	lobbyInfo = function(parsedAction) action_lobbyInfo(parsedAction) end,
	startGame = function(parsedAction) action_start_game(parsedAction.players, parsedAction.seed, parsedAction.stake) end,
	startBlind = function() action_start_blind() end,
	gameStateUpdate = function(parsedAction) action_game_state_update(parsedAction.id, parsedAction.updates) end,
	stopGame = function() action_stop_game() end,
	endPvP = function() action_end_pvp() end,
	winGame = function() action_win_game() end,
	loseGame = function() action_lose_game() end,
	lobbyOptions = function(parsedAction) action_lobby_options(parsedAction.options) end,
	setBossBlind = function(parsedAction) action_set_boss_blind(parsedAction.bossKey) end,
	sendPhantom = function(parsedAction) action_send_phantom(parsedAction.key) end,
	removePhantom = function(parsedAction) action_remove_phantom(parsedAction.key) end,
	speedrun = function() action_speedrun() end,
	asteroid = function() action_asteroid() end,
	soldJoker = function() action_sold_joker() end,
	letsGoGamblingNemesis = function() action_lets_go_gambling_nemesis() end,
	eatPizza = function(parsedAction) action_eat_pizza(parsedAction.whole) end,
	spentLastShop = function(parsedAction) action_spent_last_shop(parsedAction.amount) end,
	magnet = function() action_magnet() end,
	magnetResponse = function(parsedAction) action_magnet_response(parsedAction.key) end,
	getEndGameJokers = function() action_get_end_game_jokers() end,
	receiveEndGameJokers = function(parsedAction) action_receive_end_game_jokers(parsedAction.keys) end,
	receivePlayerDeck = function(parsedAction) action_receive_player_deck(parsedAction.playerId, parsedAction.cards) end,
	startAnteTimer = function(parsedAction) action_start_ante_timer(parsedAction.time) end,
	pauseAnteTimer = function(parsedAction) action_pause_ante_timer(parsedAction.time) end,
	error = function(parsedAction) action_error(parsedAction.message) end,
	keepAlive = function() action_keep_alive() end,
}

function MP.NETWORKING.update(dt)
	repeat
		local msg = love.thread.getChannel("networkToUi"):pop()
		-- if message not starting with { wrap msg string with {}

		if msg then
			local ok, parsedAction = pcall(json.decode, msg)
			if not ok or type(parsedAction) ~= "table" then
				sendWarnMessage("Received non-JSON message: " .. tostring(msg), "MULTIPLAYER")
				return
			end

			if not ((parsedAction.action == "keepAlive") or (parsedAction.action == "keepAliveAck")) then
				local log = string.format("Client got %s message: ", parsedAction.action)
				for k, v in pairs(parsedAction) do
					if parsedAction.action == "startGame" and k == "seed" then
						last_game_seed = v
					else
						log = log .. string.format(" (%s: %s) ", k, v)
					end
				end
				if (parsedAction.action == "receiveEndGameJokers" or parsedAction.action == "stopGame") and last_game_seed then
					log = log .. string.format(" (seed: %s) ", last_game_seed)
				end
				sendTraceMessage(log, "MULTIPLAYER")
			end

			local handler = action_table[parsedAction.action]
			if handler then
				handler(parsedAction)
			end
		end
	until not msg
end
