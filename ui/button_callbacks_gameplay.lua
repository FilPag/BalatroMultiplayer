-- Gameplay-related button callbacks
G.FUNCS.blind_choice_handler = function(e)
  if
      not e.config.ref_table.run_info
      and G.blind_select
      and G.blind_select.VT.y < 10
      and e.config.id
      and G.blind_select_opts[string.lower(e.config.id)]
  then
    if e.UIBox.role.xy_bond ~= "Weak" then
      e.UIBox:set_role({ xy_bond = "Weak" })
    end
    if
        (e.config.ref_table.deck ~= "on" and e.config.id == G.GAME.blind_on_deck)
        or (e.config.ref_table.deck ~= "off" and e.config.id ~= G.GAME.blind_on_deck)
    then
      local _blind_choice = G.blind_select_opts[string.lower(e.config.id)]
      local _top_button = e.UIBox:get_UIE_by_ID("select_blind_button")
      local _border = e.UIBox.UIRoot.children[1].children[1]
      local _tag = e.UIBox:get_UIE_by_ID("tag_" .. e.config.id)
      local _tag_container = e.UIBox:get_UIE_by_ID("tag_container")
      if
          _tag_container
          and not G.SETTINGS.tutorial_complete
          and not G.SETTINGS.tutorial_progress.completed_parts["shop_1"]
      then
        _tag_container.states.visible = false
      elseif _tag_container then
        _tag_container.states.visible = true
      end
      if e.config.id == G.GAME.blind_on_deck then
        e.config.ref_table.deck = "on"
        e.config.draw_after = false
        e.config.colour = G.C.CLEAR
        _border.parent.config.outline = 2
        _border.parent.config.outline_colour = G.C.UI.TRANSPARENT_DARK
        _border.config.outline_colour = _border.config.outline and _border.config.outline_colour
            or get_blind_main_colour(e.config.id)
        _border.config.outline = 1.5
        _blind_choice.alignment.offset.y = -0.9
        if _tag and _tag_container then
          _tag_container.children[2].config.draw_after = false
          _tag_container.children[2].config.colour = G.C.BLACK
          _tag.children[2].config.button = "skip_blind"
          _tag.config.outline_colour = adjust_alpha(G.C.BLUE, 0.5)
          _tag.children[2].config.hover = true
          _tag.children[2].config.colour = G.C.RED
          _tag.children[2].children[1].config.colour = G.C.UI.TEXT_LIGHT
          local _sprite = _tag.config.ref_table
          _sprite.config.force_focus = nil
        end
        if _top_button then
          G.E_MANAGER:add_event(Event({
            func = function()
              G.CONTROLLER:snap_to({ node = _top_button })
              return true
            end,
          }))
          if _top_button.config.button ~= "mp_toggle_ready" then
            _top_button.config.button = "select_blind"
          end
          _top_button.config.colour = G.C.FILTER
          _top_button.config.hover = true
          _top_button.children[1].config.colour = G.C.WHITE
        end
      elseif e.config.id ~= G.GAME.blind_on_deck then
        e.config.ref_table.deck = "off"
        e.config.draw_after = true
        e.config.colour = adjust_alpha(
          G.GAME.round_resets.blind_states[e.config.id] == "Skipped"
          and mix_colours(G.C.BLUE, G.C.L_BLACK, 0.1)
          or G.C.L_BLACK,
          0.5
        )
        _border.parent.config.outline = nil
        _border.parent.config.outline_colour = nil
        _border.config.outline_colour = nil
        _border.config.outline = nil
        _blind_choice.alignment.offset.y = -0.2
        if _tag and _tag_container then
          if
              G.GAME.round_resets.blind_states[e.config.id] == "Skipped"
              or G.GAME.round_resets.blind_states[e.config.id] == "Defeated"
          then
            _tag_container.children[2]:set_role({ xy_bond = "Weak" })
            _tag_container.children[2]:align(0, 10)
            _tag_container.children[1]:set_role({ xy_bond = "Weak" })
            _tag_container.children[1]:align(0, 10)
          end
          if G.GAME.round_resets.blind_states[e.config.id] == "Skipped" then
            _blind_choice.children.alert = UIBox({
              definition = create_UIBox_card_alert({
                text_rot = -0.35,
                no_bg = true,
                text = localize("k_skipped_cap"),
                bump_amount = 1,
                scale = 0.9,
                maxw = 3.4,
              }),
              config = {
                align = "tmi",
                offset = { x = 0, y = 2.2 },
                major = _blind_choice,
                parent = _blind_choice,
              },
            })
          end
          _tag.children[2].config.button = nil
          _tag.config.outline_colour = G.C.UI.BACKGROUND_INACTIVE
          _tag.children[2].config.hover = false
          _tag.children[2].config.colour = G.C.UI.BACKGROUND_INACTIVE
          _tag.children[2].children[1].config.colour = G.C.UI.TEXT_INACTIVE
          local _sprite = _tag.config.ref_table
          _sprite.config.force_focus = true
        end
        if _top_button then
          _top_button.config.colour = G.C.UI.BACKGROUND_INACTIVE
          _top_button.config.button = nil
          _top_button.config.hover = false
          _top_button.children[1].config.colour = G.C.UI.TEXT_INACTIVE
        end
      end
    end
  end
end

local buy_from_shop_ref = G.FUNCS.buy_from_shop
function G.FUNCS.buy_from_shop(e)
  local c1 = e.config.ref_table
  if c1 and c1:is(Card) then
    sendTraceMessage(
      string.format("Client sent message: action:boughtCardFromShop,card:%s,cost:%s", c1.ability.name, c1.cost),
      "MULTIPLAYER"
    )
  end
  return buy_from_shop_ref(e)
end

local can_play_ref = G.FUNCS.can_play
G.FUNCS.can_play = function(e)
  if G.GAME.current_round.hands_left <= 0 then
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  else
    can_play_ref(e)
  end
end

local evaluate_round_ref = G.FUNCS.evaluate_round
G.FUNCS.evaluate_round = function()
  if G.after_pvp then
    G.after_pvp = nil
    SMODS.calculate_context({ mp_end_of_pvp = true })
  end
  evaluate_round_ref()
end

function G.FUNCS.overlay_endgame_menu()
  G.FUNCS.overlay_menu({
    definition = MP.GAME.won and create_UIBox_win() or create_UIBox_game_over(),
    config = { no_esc = true }
  })
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 2.5,
    blocking = false,
    func = (function()
      if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('jimbo_spot') then
        local Jimbo = Card_Character({ x = 0, y = 5 })
        local spot = G.OVERLAY_MENU:get_UIE_by_ID('jimbo_spot')
        spot.config.object:remove()
        spot.config.object = Jimbo
        Jimbo.ui_object_updated = true
        local jimbo_words = MP.GAME.won and 'wq_' .. math.random(1, 7) or 'lq_' .. math.random(1, 10)
        Jimbo:add_speech_bubble(jimbo_words, nil, { quip = true })
        Jimbo:say_stuff(5)
      end
      return true
    end)
  }))
end

G.FUNCS.pvp_ready_button = function(e)
  if e.children[1].config.ref_table[e.children[1].config.ref_value] == localize("Select", "blind_states") then
    e.config.button = "mp_toggle_ready"
    e.config.one_press = false
    e.children[1].config.ref_table = MP.GAME
    e.children[1].config.ref_value = "ready_blind_text"
  end
  if e.config.button == "mp_toggle_ready" then
    e.config.colour = (MP.GAME.ready_blind and G.C.GREEN) or G.C.RED
  end
end

local reroll_shop_ref = G.FUNCS.reroll_shop
function G.FUNCS.reroll_shop(e)
  sendTraceMessage(
    string.format("Client sent message: action:rerollShop,cost:%s", G.GAME.current_round.reroll_cost),
    "MULTIPLAYER"
  )

  -- Update reroll stats if in a multiplayer game
  if MP.LOBBY.code and MP.GAME.stats then
    MP.GAME.stats.reroll_count = MP.GAME.stats.reroll_count + 1
    MP.GAME.stats.reroll_cost_total = MP.GAME.stats.reroll_cost_total + G.GAME.current_round.reroll_cost
  end

  return reroll_shop_ref(e)
end

local select_blind_ref = G.FUNCS.select_blind
function G.FUNCS.select_blind(e)
  MP.GAME.end_pvp = false
  MP.GAME.prevent_eval = false
  select_blind_ref(e)
  if MP.LOBBY.code then
    MP.GAME.ante_key = tostring(math.random())
    MP.LOBBY.local_player.game_state.score = to_big(0)
    MP.ACTIONS.set_location("loc_playing-" .. (e.config.ref_table.key or e.config.ref_table.name))
	  MP.ACTIONS.UpdateHandsAndDiscards(G.GAME.current_round.hands_left, G.GAME.current_round.discards_left)
    MP.UI_UTILS.hide_enemy_location()
  end
end

local skip_blind_ref = G.FUNCS.skip_blind
G.FUNCS.skip_blind = function(e)
  skip_blind_ref(e)
  if MP.LOBBY.code then
    if not MP.GAME.timer_started then
      MP.GAME.timer = MP.GAME.timer + MP.LOBBY.config.timer_increment_seconds
    end

    --Update the furthest blind
    local temp_furthest_blind = 0
    if G.GAME.round_resets.blind_states.Big == "Skipped" then
      temp_furthest_blind = G.GAME.round_resets.ante * 10 + 2
    elseif G.GAME.round_resets.blind_states.Small == "Skipped" then
      temp_furthest_blind = G.GAME.round_resets.ante * 10 + 1
    end

    MP.GAME.furthest_blind = (temp_furthest_blind > MP.GAME.furthest_blind) and temp_furthest_blind or
        MP.GAME.furthest_blind

  MP.ACTIONS.skip(temp_furthest_blind)
  end
end

local use_card_ref = G.FUNCS.use_card
function G.FUNCS.use_card(e, mute, nosave)
  if e.config and e.config.ref_table and e.config.ref_table.ability and e.config.ref_table.ability.name then
    sendTraceMessage(
      string.format("Client sent message: action:usedCard,card:%s", e.config.ref_table.ability.name),
      "MULTIPLAYER"
    )
  end
  return use_card_ref(e, mute, nosave)
end

function G.FUNCS.view_nemesis_deck()
  G.SETTINGS.paused = true
  if G.deck_preview then
    G.deck_preview:remove()
    G.deck_preview = nil
  end
  G.FUNCS.overlay_menu({
    definition = G.UIDEF.create_UIBox_view_nemesis_deck()
  })
end

local can_open_ref = G.FUNCS.can_open
G.FUNCS.can_open = function(e)
  if MP.GAME.ready_blind then
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
    return
  end
  can_open_ref(e)
end