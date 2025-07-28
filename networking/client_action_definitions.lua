local json = require "json"

-- #region Client to Server
function MP.ACTIONS.connect()
  Client.send("connect")
end

function MP.ACTIONS.disconnect()
  Client.send("disconnect")
end

function MP.ACTIONS.update_player_usernames()
  if MP.UTILS.have_player_usernames_changed() then
    set_main_menu_UI()
  end
end

function MP.ACTIONS.create_lobby(ruleset, gamemode)
  Client.send(json.encode({ action = "createLobby", ruleset = ruleset, gameMode = gamemode }))
end

function MP.ACTIONS.join_lobby(code)
  Client.send(json.encode({ action = "joinLobby", code = code }))
end

function MP.ACTIONS.lobby_info()
  Client.send(json.encode({ action = "lobbyInfo" }))
end

function MP.ACTIONS.leave_lobby()
  Client.send(json.encode({ action = "leaveLobby" }))
end

function MP.ACTIONS.start_game()
  Client.send(json.encode({ action = "startGame" }))
end

function MP.ACTIONS.send_lobby_ready(value)
  MP.LOBBY.local_player.is_ready = value

  local ready_button_ref = G.MAIN_MENU_UI:get_UIE_by_ID("lobby_ready_button")
  if ready_button_ref then
    MP.LOBBY.ready_text = MP.LOBBY.local_player.is_ready and localize("b_unready") or localize("b_ready")
    ready_button_ref.config.colour = MP.LOBBY.local_player.is_ready and G.C.GREEN or G.C.RED
  end

  Client.send(json.encode({ action = "setReady", is_ready = MP.LOBBY.local_player.is_ready }))
end

function MP.ACTIONS.ready_blind(e)
  MP.GAME.next_blind_context = e
  MP.ACTIONS.send_lobby_ready(true)
end

function MP.ACTIONS.unready_blind()
  MP.ACTIONS.send_lobby_ready(false)
end

function MP.ACTIONS.stop_game()
  Client.send(json.encode({ action = "stopGame" }))
end

function MP.ACTIONS.set_client_data()
  if MP.LOBBY.connected then
    Client.send(json.encode({
      action = "setClientData",
      username = MP.username,
      colour = MP.blind_col,
      version = MULTIPLAYER_VERSION,
      mod_hash = MP.MOD_STRING
    }))

  end
end

function MP.ACTIONS.set_blind_col(num)
  MP.blind_col = num or 1
end

function MP.ACTIONS.fail_round(hands_used)
  if MP.LOBBY.config.no_gold_on_round_loss then
    G.GAME.blind.dollars = 0
  end
  if hands_used == 0 then
    return
  end
  Client.send(json.encode({ action = "failRound" }))
end

function MP.ACTIONS.version()
  Client.send(json.encode({ action = "version", version = MULTIPLAYER_VERSION }))
end

function MP.ACTIONS.set_location(location)
  if MP.GAME.location == location then
    return
  end
  MP.GAME.location = location
  Client.send(json.encode({ action = "setLocation", location = location }))
end

---@param score number
---@param hands_left number
function MP.ACTIONS.play_hand(score, hands_left)
  local fixed_score = tostring(to_big(score))
  -- Credit to sidmeierscivilizationv on discord for this fix for Talisman
  if string.match(fixed_score, "[eE]") == nil and string.match(fixed_score, "[.]") then
    -- Remove decimal from non-exponential numbers
    fixed_score = string.sub(string.gsub(fixed_score, "%.", ","), 1, -3)
  end
  fixed_score = string.gsub(fixed_score, ",", "") -- Remove commas

  local insane_int_score = MP.INSANE_INT.from_string(fixed_score)
  if MP.INSANE_INT.greater_than(insane_int_score, MP.GAME.highest_score) then
    MP.GAME.highest_score = insane_int_score
  end

  MP.UTILS.get_local_player().score = MP.INSANE_INT.add(insane_int_score, MP.UTILS.get_local_player().score)

  local target = nil
  if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" then
    target = G.GAME.blind.chips
  end

  Client.send(json.encode({ action = "playHand", score = fixed_score, hands_left = hands_left, target_score = target }))
end

function MP.ACTIONS.update_lobby_options(_)
  local options = {}
  for k, v in pairs(MP.LOBBY.config) do
    options[k] = v
  end

	MP.LOBBY.ready_to_start = false
  for _, player in pairs(MP.LOBBY.players) do
    if not player.lobby_state.is_host then
      player.lobby_state.is_ready = false
    end
  end

  set_main_menu_UI()
  Client.send(json.encode({ action = "updateLobbyOptions", options = options }))
end

---@param boss string
function MP.ACTIONS.set_Boss(boss)
  Client.send(json.encode({ action = "setBossBlind", bossKey = boss }))
end

function MP.ACTIONS.set_ante(ante)
  Client.send(json.encode({ action = "setAnte", ante = ante }))
end

function MP.ACTIONS.new_round()
  Client.send(json.encode({ action = "newRound" }))
end

function MP.ACTIONS.set_furthest_blind(furthest_blind)
  Client.send(json.encode({ action = "setFurthestBlind", furthest_blind = furthest_blind }))
end

function MP.ACTIONS.skip(skips)
  Client.send(json.encode({ action = "skip", skips = skips }))
end

--- @class GameStateData
--- @field ante number Current ante
--- @field furthest_blind number Furthest blind reached
--- @field hands_left number Hands left in round
--- @field hands_max number Max hands per round
--- @field discards_left number Discards left
--- @field discards_max number Max discards per round
--- @field highest_score table Highest score (InsaneInt)
--- @field lives number Lives remaining
--- @field lives_blocker boolean If life loss is blocked
--- @field location string Current location/state
--- @field score table Current score (InsaneInt)
--- @field skips number Skips used
--- @field spent_in_shop table Chips spent in shop (array of numbers)
---
--- Update the player's game state on the server.
--- @param updates GameStateData|table Table of fields to update (partial GameStateData)
MP.ACTIONS.update_player_state = function(updates)
  Client.send(json.encode({ action = "updatePlayerGameState", updates = updates }))
end

function MP.ACTIONS.send_phantom(key)
  Client.send(json.encode({ action = "sendPhantom", key = key }))
end

function MP.ACTIONS.remove_phantom(key)
  Client.send(json.encode({ action = "removePhantom", key = key }))
end

function MP.ACTIONS.asteroid()
  Client.send(json.encode({ action = "asteroid" }))
end

function MP.ACTIONS.sold_joker()
  Client.send(json.encode({ action = "soldJoker" }))
end

function MP.ACTIONS.lets_go_gambling_nemesis()
  Client.send(json.encode({ action = "letsGoGamblingNemesis" }))
end

function MP.ACTIONS.eat_pizza(whole)
  Client.send(json.encode({ action = "eatPizza", whole = tostring(whole and true) }))
end

function MP.ACTIONS.spent_last_shop(amount)
  Client.send(json.encode({ action = "spentLastShop", amount = tostring(amount) }))
end

function MP.ACTIONS.magnet()
  Client.send(json.encode({ action = "magnet" }))
end

function MP.ACTIONS.magnet_response(key)
  Client.send(json.encode({ action = "magnetResponse", key = key }))
end

function MP.ACTIONS.get_end_game_jokers()
  Client.send(json.encode({ action = "getEndGameJokers" }))
end

function MP.ACTIONS.sendPlayerDeck()
  local deck_str = ""
  for _, card in ipairs(G.playing_cards) do
    deck_str = deck_str .. ";" .. MP.UTILS.card_to_string(card)
  end
  Client.send(json.encode({ action = "sendPlayerDeck", cards = deck_str }))
end

function MP.ACTIONS.start_ante_timer()
  Client.send(json.encode({ action = "startAnteTimer", time = tostring(MP.GAME.timer) }))
  MP.action_start_ante_timer(MP.GAME.timer)
end

function MP.ACTIONS.pause_ante_timer()
  Client.send(json.encode({ action = "pauseAnteTimer", time = tostring(MP.GAME.timer) }))
  MP.action_pause_ante_timer(MP.GAME.timer) -- TODO
end

function MP.ACTIONS.fail_timer()
  Client.send(json.encode({ action = "failTimer" }))
end

function MP.ACTIONS.sync_client()
  Client.send(json.encode({ action = "syncClient", isCached = _RELEASE_MODE }))
end

-- #endregion Client to Server
