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
--- @field hostHash string
--- @field hostCached boolean
--- @field players? table[] @ Array of player objects: { username: string, modHash: string, isCached: boolean, id: string }


local json = require "json"
Client = {}

function Client.send(msg)
	if msg ~= '{"action":"a"}' then
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
  MP.ACTIONS.set_client_data()
end

-- Simple config update for lobby options
local function update_lobby_options(options)
  for k, v in pairs(options) do
    MP.LOBBY.config[k] = v
  end

	MP.LOBBY.local_player.lobby_state.is_ready = false

  set_main_menu_UI()

  if G.OVERLAY_MENU then
    G.FUNCS.exit_overlay_menu()
  end
end

local function action_joined_lobby(action_data)
	if not MP.LOBBY.players then
		MP.LOBBY.players = {}
	end

	MP.FLAGS.join_pressed = false
  MP.LOBBY.players = action_data.lobby_data.players or {}

  local player_id = action_data.player_id

  for _, player in pairs(MP.LOBBY.players) do
		MP.LOBBY.players[player.profile.id] = player
    if player.profile.id == player_id then
      MP.LOBBY.local_player = player
      MP.LOBBY.is_host = player.lobby_state.is_host
    end
		player.game_state.score = MP.INSANE_INT.from_string(player.game_state.score or "0")
		player.game_state.highest_score = MP.INSANE_INT.from_string(player.game_state.highest_score or "0")
  end

	MP.LOBBY.code = action_data.lobby_data.code
	MP.LOBBY.ready_to_start = false
  update_lobby_options(action_data.lobby_data.lobby_options)
	MP.UI.update_connection_status()
end

local function new_player_joined_lobby(player)
	player.game_state.score = MP.INSANE_INT.from_string(player.game_state.score or "0")
	player.game_state.highest_score = MP.INSANE_INT.from_string(player.game_state.highest_score or "0")
	MP.LOBBY.players[player.profile.id] = player

  if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove() end
  set_main_menu_UI()
end

local function action_game_stopped()
	if G.STAGE ~= G.STAGES.MAIN_MENU then
		G.FUNCS.go_to_menu()
		MP.UI.update_connection_status()
		MP.reset_game_states()
	end
end

local function action_reset_players(players)
	for _, player in ipairs(players) do
		local player_id = player.profile.id
		if MP.LOBBY.players[player_id] then
			MP.STATE_UPDATER.update_player_state(player_id, player.game_state)
		end
	end
end

local function player_left_lobby(player_id, host_id)
	MP.LOBBY.players[host_id].lobby_state.is_host = true
	MP.LOBBY.players[host_id].lobby_state.is_ready = true
  MP.LOBBY.players[player_id] = nil

	if host_id == MP.LOBBY.local_player.profile.id then
		MP.LOBBY.is_host = true
	end

	action_game_stopped()

  if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove() end
  set_main_menu_UI()
end

local function action_error(message)
	sendWarnMessage(message, "MULTIPLAYER")

	MP.FLAGS.join_pressed = false
	MP.UTILS.overlay_message(message)
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
local function action_game_started(seed, stake)
	MP.reset_game_states()
	if type(stake) == "string" then
		stake = tonumber(stake) or 0
	end

	sendDebugMessage("Different seeds: " .. tostring(MP.LOBBY.config.different_seeds) .. "custom_seed: " .. tostring(MP.LOBBY.config.custom_seed))
	if not MP.LOBBY.config.different_seeds and seed ~= "random" then
		seed = MP.LOBBY.config.custom_seed
	else
		seed = generate_starting_seed()
	end

	sendDebugMessage("Starting game with seed: " .. seed .. " and stake: " .. tostring(stake))
	MP.LOBBY.local_player.lives = MP.LOBBY.config.starting_lives
	G.FUNCS.lobby_start_run(nil, { seed = seed, stake = stake })
	G.E_MANAGER:add_event(Event({
    trigger = 'immediate',
    func = function()
			MP.ACTIONS.UpdateHandsAndDiscards(G.GAME.starting_params.hands, G.GAME.starting_params.discards)
      return true
    end
  }))
	MP.LOBBY.ready_to_start = false
end

local function action_start_blind()
	MP.GAME.ready_blind = false
	MP.GAME.timer_started = false
	MP.GAME.timer = MP.LOBBY.config.timer_base_seconds

	for _, player in pairs(MP.LOBBY.players) do
		player.game_state.score = MP.INSANE_INT.empty()
	end

	if MP.GAME.next_blind_context then
		G.FUNCS.select_blind(MP.GAME.next_blind_context)
	else
		sendErrorMessage("No next blind context", "MULTIPLAYER")
	end
end

local function action_game_state_update(player_id, game_state)
	MP.STATE_UPDATER.update_player_state(player_id, game_state)
end
---@param won boolean
local function action_end_pvp(won)
	if not MP.LOBBY.code then return end

	sendDebugMessage("Ending PVP won: " .. tostring(won))

	MP.GAME.end_pvp = true
	MP.GAME.timer = MP.LOBBY.config.timer_base_seconds
	MP.GAME.timer_started = false

	if won then return end

	if MP.LOBBY.config.gold_on_life_loss then
		MP.LOBBY.local_player.comeback_bonus_given = false
		MP.LOBBY.local_player.comeback_bonus = (MP.LOBBY.local_player.comeback_bonus or 0) + 1
	end

	if MP.LOBBY.config.no_gold_on_round_loss and G.GAME.blind and G.GAME.blind.dollars then
		G.GAME.blind.dollars = 0
	end
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

local function action_invalidLobby()
	MP.FLAGS.join_pressed = false
	MP.UTILS.overlay_message("Invalid lobby code")
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
	if self.edition and self.edition.type == "mp_phantom" then
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
		if not v.edition or v.edition.type ~= "mp_phantom" then
			new_ret[#new_ret + 1] = v
		end
	end
	return new_ret
end

-- don't poll edition
local origedpoll = poll_edition
function poll_edition(_key, _mod, _no_neg, _guaranteed, _options)
	if G.OVERLAY_MENU then
		return nil
	end
	return origedpoll(_key, _mod, _no_neg, _guaranteed, _options)
end

local function action_speedrun()
	SMODS.calculate_context({ mp_speedrun = true })
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
				["High Card"] = 13,
			}
			local hand_type = "High Card"
			local max_level = 0

			for k, v in pairs(G.GAME.hands) do
				if v.visible then
					if
							to_big(v.level) > to_big(max_level)
							or (to_big(v.level) == to_big(max_level) and hand_priority[k] < hand_priority[hand_type])
					then
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
	-- HACK: this action is being sent when any card is being sold, since Taxes is now reworked
	local enemy = MP.UTILS.get_nemesis().game_state
	if not enemy then return end
	enemy.sells = (enemy.sells or 0) + 1
	if not enemy.sells_per_ante then
		enemy.sells_per_ante = {}
	end
	enemy.sells_per_ante[G.GAME.round_resets.ante] = (
		(enemy.sells_per_ante[G.GAME.round_resets.ante] or 0) + 1
	)
end

local function action_lets_go_gambling_nemesis()
	local card = MP.UTILS.get_phantom_joker("j_mp_lets_go_gambling")
	if card then
		card:juice_up()
	end
	ease_dollars(card and card.ability and card.ability.extra and card.ability.extra.nemesis_dollars or 5)
end

local function action_eat_pizza(discards)
	MP.GAME.pizza_discards = MP.GAME.pizza_discards + discards
	G.GAME.round_resets.discards = G.GAME.round_resets.discards + discards
	ease_discard(discards)
end

local function action_spent_last_shop(player_id, amount)
	-- TODO make support more than one player
	local enemy = MP.UTILS.get_nemesis().game_state
	if not enemy then
		sendWarnMessage("No enemy found for spent_last_shop action", "MULTIPLAYER")
		return
	end

	if not enemy.spent_in_shop then
		enemy.spent_in_shop = {}
	end

	enemy.spent_in_shop[#enemy.spent_in_shop + 1] = tonumber(amount)
end

---@param ready_states table<string, boolean> <player_id, is_ready
local function action_lobby_ready_update(ready_states)
	for player_id, is_ready in pairs(ready_states) do
		MP.LOBBY.players[player_id].lobby_state.is_ready = is_ready
	end


	local ready_check = true
	local count = 0
	for _, player in pairs(MP.LOBBY.players) do
		count = count + 1
		if not player.lobby_state.is_ready then
			ready_check = false
			break
		end
	end

	if ready_check ~= MP.LOBBY.ready_to_start and count > 1 then
		MP.LOBBY.ready_to_start = ready_check
		set_main_menu_UI()
	end
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
			if v.sell_cost == card.sell_cost then
				table.insert(candidates, v)
			end
		end

		-- Scale the pseudo from 0 - 1 to the number of candidates
		local random_index = math.floor(pseudorandom("j_mp_magnet") * #candidates) + 1
		local chosen_card = candidates[random_index]
		sendTraceMessage(
			string.format("Sending magnet joker: %s", MP.UTILS.joker_to_string(chosen_card)),
			"MULTIPLAYER"
		)

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

	local card =
			Card(G.jokers.T.x + G.jokers.T.w / 2, G.jokers.T.y, G.CARD_W, G.CARD_H, G.P_CENTERS.j_joker, G.P_CENTERS.c_base)
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

	if not MP.end_game_jokers or not MP.end_game_jokers_payload then
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
	local player = MP.LOBBY.players[player_id]
	player.deck_str = cards
	player.deck_received = true
	G.FUNCS.load_player_deck(player)
end

-- Special cases since they're used elsewhere
function MP.action_start_ante_timer(time)
	if type(time) == "string" then
		time = tonumber(time)
	end
	MP.GAME.timer = time
	MP.GAME.timer_started = true
	G.E_MANAGER:add_event(MP.timer_event)
end

function MP.action_pause_ante_timer(time)
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
	joinedLobby = function(parsedAction) action_joined_lobby(parsedAction) end,
	playerJoinedLobby = function(parsedAction) new_player_joined_lobby(parsedAction.player) end,
	playerLeftLobby = function(parsedAction) player_left_lobby(parsedAction.player_id, parsedAction.host_id) end,
	gameStarted = function(parsedAction) action_game_started(parsedAction.seed, parsedAction.stake) end,
	startBlind = function() action_start_blind() end,
	lobbyReady = function(parsedAction) action_lobby_ready_update(parsedAction.ready_states) end,
	gameStateUpdate = function(parsedAction) action_game_state_update(parsedAction.player_id, parsedAction.game_state) end,
	gameStopped = function() action_game_stopped() end,
	resetPlayers = function(parsedAction) action_reset_players(parsedAction.players) end,
	endPvp = function(parsedAction) action_end_pvp(parsedAction.won) end,
	winGame = function() action_win_game() end,
	loseGame = function() action_lose_game() end,
	updateLobbyOptions = function(parsedAction) update_lobby_options(parsedAction.options) end,
	setBossBlind = function(parsedAction) action_set_boss_blind(parsedAction.key) end,
	sendPhantom = function(parsedAction) action_send_phantom(parsedAction.key) end,
	removePhantom = function(parsedAction) action_remove_phantom(parsedAction.key) end,
	speedrun = function() action_speedrun() end,
	asteroid = function() action_asteroid() end,
	soldJoker = function() action_sold_joker() end,
	letsGoGamblingNemesis = function() action_lets_go_gambling_nemesis() end,
	eatPizza = function(parsedAction) action_eat_pizza(parsedAction.discards) end,
	spentLastShop = function(parsedAction) action_spent_last_shop(parsedAction.playerId, parsedAction.amount) end,
	magnet = function() action_magnet() end,
	magnetResponse = function(parsedAction) action_magnet_response(parsedAction.key) end,
	getEndGameJokers = function() action_get_end_game_jokers() end,
	receiveEndGameJokers = function(parsedAction) action_receive_end_game_jokers(parsedAction.keys) end,
	receivePlayerDeck = function(parsedAction) action_receive_player_deck(parsedAction.playerId, parsedAction.cards) end,
	startAnteTimer = function(parsedAction) MP.action_start_ante_timer(parsedAction.time) end,
	pauseAnteTimer = function(parsedAction) MP.action_pause_ante_timer(parsedAction.time) end,
	error = function(parsedAction) action_error(parsedAction.message) end,
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

			if not (parsedAction.action == "a") then
				local log = string.format("Client got %s message: ", parsedAction.action)
				for k, v in pairs(parsedAction) do
					if parsedAction.action == "startGame" and k == "seed" then
						last_game_seed = v
					else
						log = log .. string.format(" (%s: %s) ", k, v)
					end
				end
				if
						(parsedAction.action == "receiveEndGameJokers" or parsedAction.action == "stopGame")
						and last_game_seed
				then
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
