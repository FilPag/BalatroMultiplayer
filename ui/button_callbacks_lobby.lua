-- Lobby/Menu-related button callbacks

G.FUNCS.change_gamemode_selection = function(e)
  -- Use the id of the first gamemode button as the default
  local gamemode_buttons_data
  if MP.LOBBY.config.ruleset == "ruleset_mp_coop" then
    gamemode_buttons_data = {
      { button_id = "coopSurvival_gamemode_button", button_localize_key = "k_coopSurvival" },
    }
  else
    gamemode_buttons_data = {
      { button_id = "attrition_gamemode_button", button_localize_key = "k_attrition" },
      { button_id = "showdown_gamemode_button",  button_localize_key = "k_showdown" },
      { button_id = "survival_gamemode_button",  button_localize_key = "k_survival" },
    }
  end
  local default_gamemode_id = gamemode_buttons_data[1].button_id

  MP.UI.Change_Main_Lobby_Options(e, "gamemode_area", G.UIDEF.gamemode_info, default_gamemode_id,
    function(gamemode_name) MP.LOBBY.config.gamemode = "gamemode_mp_" .. gamemode_name end)
end

G.FUNCS.change_showdown_starting_antes = function(args)
  MP.LOBBY.config.showdown_starting_antes = args.to_val
  MP.ACTIONS.update_lobby_options()
end

function G.FUNCS.toggle_different_seeds()
  G.FUNCS.lobby_options()
  MP.ACTION.lobby_options()
end

G.FUNCS.change_starting_lives = function(args)
  MP.LOBBY.config.starting_lives = args.to_val
  MP.ACTIONS.update_lobby_options()
end

G.FUNCS.change_starting_pvp_round = function(args)
  MP.LOBBY.config.pvp_start_round = args.to_val
  MP.ACTIONS.update_lobby_options()
end

G.FUNCS.change_timer_base_seconds = function(args)
  MP.LOBBY.config.timer_base_seconds = tonumber(args.to_val:sub(1, -2))
  MP.ACTIONS.update_lobby_options()
end

G.FUNCS.change_timer_increment_seconds = function(args)
  MP.LOBBY.config.timer_increment_seconds = tonumber(args.to_val:sub(1, -2))
  MP.ACTION.lobby_options()
end

function G.FUNCS.continue_in_singleplayer(e)
  MP.LOBBY.code = nil
  MP.ACTIONS.leave_lobby()
  MP.UI.update_connection_status()

  local saveText = MP.UTILS.MP_SAVE()
  G.SAVED_GAME = saveText
  G.SETTINGS.current_setup = 'Continue'
  G:delete_run()

  G.E_MANAGER:add_event(Event({
    trigger = 'immediate',
    blockable = false,
    no_delete = true,
    func = function()
      G.FUNCS.start_setup_run(nil)
      return true
    end
  }))
end

function G.FUNCS.copy_host_deck()
  MP.LOBBY.deck.back = MP.LOBBY.config.back
  MP.LOBBY.deck.sleeve = MP.LOBBY.config.sleeve
  MP.LOBBY.deck.stake = MP.LOBBY.config.stake
  MP.LOBBY.deck.challenge = MP.LOBBY.config.challenge
end

function G.FUNCS.create_lobby(e)
  G.SETTINGS.paused = true

  G.FUNCS.overlay_menu({
    definition = G.UIDEF.ruleset_selection_options(),
  })
end

function G.FUNCS.custom_seed_overlay(e)
  G.FUNCS.overlay_menu({
    definition = MP.UIDEF.create_UIBox_custom_seed_overlay(),
  })
end

function G.FUNCS.custom_seed_reset(e)
  MP.LOBBY.config.custom_seed = generate_starting_seed()
  MP.ACTIONS.update_lobby_options()
end

function G.FUNCS.display_custom_seed(e)
  local display = MP.LOBBY.config.custom_seed == "random" and localize("k_random") or MP.LOBBY.config.custom_seed
  if display ~= e.children[1].config.text then
    e.children[2].config.text = display
    e.UIBox:recalculate(true)
  end
end

function G.FUNCS.display_lobby_main_menu_UI(e)
  G.MAIN_MENU_UI = G.FUNCS.get_lobby_main_menu_UI(e)
  G.MAIN_MENU_UI.alignment.offset.y = 0
  G.MAIN_MENU_UI:align_to_major()

  G.CONTROLLER:snap_to({ node = G.MAIN_MENU_UI:get_UIE_by_ID("lobby_menu_start") })
end

function G.FUNCS.get_lobby_main_menu_UI(e)
  return UIBox({
    definition = G.UIDEF.create_UIBox_lobby_menu(),
    config = {
      align = "bmi",
      offset = {
        x = 0,
        y = 10,
      },
      major = G.ROOM_ATTACH,
      bond = "Weak",
    },
  })
end

function G.FUNCS.join_from_clipboard(e)
  if MP.FLAGS.join_pressed then return end
  MP.FLAGS.join_pressed = true
  MP.LOBBY.temp_code = MP.UTILS.get_from_clipboard()

  if #MP.LOBBY.temp_code > 5 then
    MP.UTILS.overlay_message("Lobby does not exist or is invalid.")
    MP.FLAGS.join_pressed = false
    return
  end

  MP.ACTIONS.join_lobby(MP.LOBBY.temp_code)
end

function G.FUNCS.join_game_paste(e)
  MP.LOBBY.temp_code = MP.UTILS.get_from_clipboard()
  MP.ACTIONS.join_lobby(MP.LOBBY.temp_code)
  G.FUNCS:exit_overlay_menu()
end

function G.FUNCS.join_game_submit(e)
  G.FUNCS:exit_overlay_menu()
  MP.ACTIONS.join_lobby(MP.LOBBY.temp_code)
end

function G.FUNCS.join_lobby(e)
  G.SETTINGS.paused = true

  local definition = G.UIDEF.create_UIBox_join_lobby_button()
  G.FUNCS.overlay_menu({
    definition = definition,
  })
  local ref = G.OVERLAY_MENU:get_UIE_by_ID("join_lobby_code_input")
  G.FUNCS.select_text_input(ref)
end

function G.FUNCS.lobby_choose_deck(e)
  if not MP.LOBBY.is_host then
    MP.ACTIONS.send_lobby_ready(false)
  end
  G.FUNCS.setup_run(e)
  if G.OVERLAY_MENU then
    G.OVERLAY_MENU:get_UIE_by_ID("run_setup_seed"):remove()
  end
end

function G.FUNCS.lobby_leave(e)
  MP.LOBBY.code = nil
  MP.ACTIONS.leave_lobby()
  MP.UI.update_connection_status()
  G.STATE = G.STATES.MENU
end

function G.FUNCS.lobby_options(e)
  if not MP.LOBBY.is_host then
    MP.ACTIONS.send_lobby_ready(false)
  end
  G.FUNCS.overlay_menu({
    definition = G.UIDEF.create_UIBox_lobby_options(),
  })
end

function G.FUNCS.lobby_ready_up(e)
  MP.LOBBY.ready_to_start = not MP.LOBBY.ready_to_start

  e.config.colour = MP.LOBBY.ready_to_start and G.C.GREEN or G.C.RED
  e.children[1].children[1].config.text = MP.LOBBY.ready_to_start and localize("b_unready") or localize("b_ready")
  e.UIBox:recalculate()

  if MP.LOBBY.ready_to_start then
    MP.ACTIONS.ready_lobby()
  else
    MP.ACTIONS.unready_lobby()
  end
end

function G.FUNCS.lobby_start_game(e)
  MP.ACTIONS.start_game()
end

---@type fun(e: table | nil, args: { deck: string, stake: number | nil, seed: string | nil })
function G.FUNCS.lobby_start_run(e, args)
  if MP.LOBBY.config.different_decks == false then
    G.FUNCS.copy_host_deck()
  end

  local challenge = nil
  if MP.LOBBY.deck.back == "Challenge Deck" then
    challenge = G.CHALLENGES[get_challenge_int_from_id(MP.LOBBY.deck.challenge)]
  else
    G.GAME.viewed_back = G.P_CENTERS[MP.UTILS.get_deck_key_from_name(MP.LOBBY.deck.back)]
  end

  G.FUNCS.start_run(e, {
    mp_start = true,
    challenge = challenge,
    stake = tonumber(MP.LOBBY.deck.stake),
    seed = args.seed,
  })
end

function G.FUNCS.mp_return_to_lobby()
  MP.ACTIONS.stop_game()
end

function G.FUNCS.mp_toggle_ready(e)
  MP.GAME.ready_blind = not MP.GAME.ready_blind
  MP.GAME.ready_blind_text = MP.GAME.ready_blind and localize("b_unready") or localize("b_ready")

  if MP.GAME.ready_blind then
    if MP.UTILS.is_coop() then
      MP.ACTIONS.set_location("loc_ready_boss")
    else
      MP.ACTIONS.set_location("loc_ready_pvp")
    end
    MP.ACTIONS.ready_blind(e)
  else
    MP.ACTIONS.set_location("loc_selecting")
    MP.ACTIONS.unready_blind()
  end
end

function G.FUNCS.mp_unstuck()
  G.FUNCS.overlay_menu({
    definition = MP.UIDEF.create_UIBox_unstuck(),
  })
end

function G.FUNCS.mp_unstuck_arcana()
  G.FUNCS.skip_booster()
end

function G.FUNCS.mp_unstuck_blind()
  MP.GAME.ready_blind = false
  if MP.GAME.next_blind_context then
    G.FUNCS.select_blind(MP.GAME.next_blind_context)
  else
    sendErrorMessage("No next blind context", "MULTIPLAYER")
  end
end

function G.FUNCS.play_options(e)
  G.SETTINGS.paused = true

  G.FUNCS.overlay_menu({
    definition = G.UIDEF.override_main_menu_play_button(),
  })
end

function G.FUNCS.select_gamemode(e)
  G.SETTINGS.paused = true

  G.FUNCS.overlay_menu({
    definition = G.UIDEF.gamemode_selection_options(),
  })
end

function G.FUNCS.setup_run_singleplayer(e)
  G.SETTINGS.paused = true
  MP.LOBBY.config.ruleset = nil
  MP.LOBBY.config.gamemode = nil
  G.FUNCS.setup_run(e)
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

  MP.ACTIONS.create_lobby(MP.LOBBY.config.ruleset, MP.LOBBY.config.gamemode)
  G.FUNCS:exit_overlay_menu()
end

local start_run_ref = G.FUNCS.start_run
function G.FUNCS.start_run(e, args)
  if MP.LOBBY.code then
    if not args.mp_start then
      G.FUNCS.exit_overlay_menu()
      local chosen_stake = args.stake
      if MP.DECK.MAX_STAKE > 0 and chosen_stake > MP.DECK.MAX_STAKE then
        MP.UTILS.overlay_message(
          "Selected stake is incompatible with Multiplayer, stake set to "
          .. SMODS.stake_from_index(MP.DECK.MAX_STAKE)
        )
        chosen_stake = MP.DECK.MAX_STAKE
      end
      if MP.LOBBY.is_host then
        MP.LOBBY.config.back = args.challenge and "Challenge Deck"
            or (args.deck and args.deck.name)
            or G.GAME.viewed_back.name
        MP.LOBBY.config.stake = chosen_stake
        MP.LOBBY.config.sleeve = G.viewed_sleeve
        MP.LOBBY.config.challenge = args.challenge and args.challenge.id or ""
        MP.ACTIONS.update_lobby_options()
      end
      MP.LOBBY.deck.back = args.challenge and "Challenge Deck"
          or (args.deck and args.deck.name)
          or G.GAME.viewed_back.name
      MP.LOBBY.deck.stake = chosen_stake
      MP.LOBBY.deck.sleeve = G.viewed_sleeve
      MP.LOBBY.deck.challenge = args.challenge and args.challenge.id or ""
      MP.ACTIONS.update_player_usernames()
    else
      start_run_ref(e, {
        challenge = args.challenge,
        stake = tonumber(MP.LOBBY.deck.stake),
        seed = args.seed,
      })
    end
  else
    start_run_ref(e, args)
  end
end

function G.FUNCS.toggle_lobby_ready(e)
  MP.ACTIONS.send_lobby_ready(not MP.LOBBY.local_player.is_ready)
end

function G.FUNCS.view_code(e)
  G.FUNCS.overlay_menu({
    definition = MP.UIDEF.create_UIBox_view_code(),
  })
end

G.FUNCS.view_player_hash = function(e)
  G.FUNCS.overlay_menu({
    definition = MP.UIDEF.create_UIBox_view_hash(e.config.ref_table.index),
  })
end
-- Lobby/Menu-related button callbacks

-- Functions will be copied here in alphabetical order as per instructions.
