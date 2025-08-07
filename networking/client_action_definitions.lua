local json = require("json")

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

function MP.ACTIONS.leave_lobby()
  Client.send(json.encode({ action = "leaveLobby" }))
end

function MP.ACTIONS.start_game()
  Client.send(json.encode({ action = "startGame", seed = MP.LOBBY.config.custom_seed, stake = MP.LOBBY.config.stake }))
end

function MP.ACTIONS.send_lobby_ready(value)
  MP.LOBBY.local_player.lobby_state.is_ready = value
  Client.send(json.encode({ action = "setReady", is_ready = MP.LOBBY.local_player.lobby_state.is_ready }))

  if not G.MAIN_MENU_UI then return end

  local ready_button_ref = G.MAIN_MENU_UI:get_UIE_by_ID("ready_button")
  if ready_button_ref then
    MP.LOBBY.ready_text = MP.LOBBY.local_player.lobby_state.is_ready and localize("b_unready") or localize("b_ready")
    ready_button_ref.config.colour = MP.LOBBY.local_player.lobby_state.is_ready and G.C.GREEN or G.C.RED
  end
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

  if score > MP.LOBBY.local_player.game_state.highest_score then
    MP.LOBBY.local_player.game_state.highest_score = score
  end

  MP.LOBBY.local_player.game_state.score = score + MP.LOBBY.local_player.game_state.score

  local target = nil
  if MP.UTILS.is_coop() then
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
---@param chips number
function MP.ACTIONS.set_Boss(boss, chips)
  Client.send(json.encode({ action = "setBossBlind", key = boss, chips = tostring(chips) }))
end

function MP.ACTIONS.send_player_jokers()
  if not G.jokers or not G.jokers.cards then
    Client.send(json.encode({ action = "sendPlayerJokers", jokers = "" }))
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

  Client.send(json.encode({ action = "sendPlayerJokers", jokers = jokers_encoded }))
end

function MP.ACTIONS.set_ante(ante)
  Client.send(json.encode({ action = "setAnte", ante = ante }))
end

function MP.ACTIONS.set_furthest_blind(furthest_blind)
  Client.send(json.encode({ action = "setFurthestBlind", blind = furthest_blind }))
end

function MP.ACTIONS.skip(furthest_blind)
  Client.send(json.encode({ action = "skip", blind = furthest_blind }))
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

MP.ACTIONS.UpdateHandsAndDiscards = function(hands_max, discards_max)
  sendDebugMessage("Updating hands and discards", "\27[34m[Client Actions]\27[0m")
  Client.send(json.encode({ action = "updateHandsAndDiscards", hands_max = hands_max, discards_max = discards_max }))
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

function MP.ACTIONS.eat_pizza(discards)
  Client.send(json.encode({ action = "eatPizza", discards = discards }))
end

function MP.ACTIONS.spent_last_shop(amount)
  Client.send(json.encode({ action = "spentLastShop", amount = amount }))
end

function MP.ACTIONS.magnet()
  Client.send(json.encode({ action = "magnet" }))
end

function MP.ACTIONS.magnet_response(key)
  Client.send(json.encode({ action = "magnetResponse", key = key }))
end

function MP.ACTIONS.send_player_deck()
  local deck_str = ""
  for _, card in ipairs(G.playing_cards) do
    deck_str = deck_str .. ";" .. MP.UTILS.card_to_string(card)
  end
  Client.send(json.encode({ action = "sendPlayerDeck", deck = deck_str }))
end

function MP.ACTIONS.start_ante_timer()
  Client.send(json.encode({ action = "startAnteTimer", time = MP.GAME.timer }))
  MP.action_start_ante_timer(MP.GAME.timer)
end

function MP.ACTIONS.pause_ante_timer()
  Client.send(json.encode({ action = "pauseAnteTimer", time = MP.GAME.timer }))
  MP.action_pause_ante_timer(MP.GAME.timer)
end

function MP.ACTIONS.fail_timer()
  Client.send(json.encode({ action = "failTimer" }))
end

MP.ACTIONS.kick_player = function(player_id)
  Client.send(json.encode({ action = "kick", player_id = player_id }))
end

function MP.ACTIONS.send_money_to_player(player_id)
  Client.send(json.encode({ action = "sendMoney", player_id = player_id }))
end