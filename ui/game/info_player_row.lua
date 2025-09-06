function MP.UI.create_UIBox_player_row(player)
  local lobby_state = player.lobby_state or {}
  local game_state  = player.game_state or {}
  local profile = player.profile or {}

  local colour = G.C.RED
  if MP.UTILS.is_coop() or MP.UTILS.is_local_player(player) then
    colour = lighten(G.C.BLUE, 0.5)
  elseif lobby_state.in_game == false or game_state.lives == 0 then
    colour = G.C.DARK_GREY
  end

  return {
    n = G.UIT.R,
    config = {
      align = "cm",
      padding = 0.05,
      r = 0.1,
      colour = colour,
      emboss = 0.05,
      hover = true,
      force_focus = true,
      --[[on_demand_tooltip = {
        text = { localize("k_mods_list") },
        filler = { func = MP.UI.create_UIBox_mods_list, args = type },
      },]] --
    },
    nodes = {
      {
        n = G.UIT.C,
        config = { align = "cl", padding = 0, minw = 5 },
        nodes = {
          {
            n = G.UIT.C,
            config = {
              align = "cm",
              padding = 0.02,
              r = 0.1,
              colour = G.C.RED,
              minw = 2,
              outline = 0.8,
              outline_colour = G.C.RED,
            },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  text = tostring(game_state.lives) .. " " .. localize("k_lives"),
                  scale = 0.4,
                  colour = G.C.UI.TEXT_LIGHT,
                },
              },
            },
          },
          {
            n = G.UIT.C,
            config = { align = "cm", minw = 4, maxw = 4 },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  text = " " .. profile.username,
                  scale = 0.45,
                  colour = G.C.UI.TEXT_LIGHT,
                  shadow = true,
                },
              },
            },
          },
        },
      },
      {
        n = G.UIT.C,
        config = { align = "cm", minw = 3, maxw = 3, r = 0.1, padding = 0.1, colour = G.C.DYN_UI.BOSS_DARK },
        nodes = {
          {
            n = G.UIT.T,
            config = {
              ref_table = game_state,
              ref_value = "location",
              scale = 0.35,
              colour = G.C.WHITE,
              shadow = true,
            },
          },
        },
      },
      {
        n = G.UIT.C,
        config = { align = "cm", padding = 0.05, colour = G.C.BLACK, r = 0.1 },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "cr", padding = 0.01, r = 0.1, colour = G.C.CHIPS, minw = 1.1 },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  text = tostring(game_state.hands_max),
                  scale = 0.45,
                  colour = G.C.UI.TEXT_LIGHT,
                },
              },
              { n = G.UIT.B, config = { w = 0.08, h = 0.01 } },
            },
          },
          {
            n = G.UIT.C,
            config = { align = "cl", padding = 0.01, r = 0.1, colour = G.C.MULT, minw = 1.1 },
            nodes = {
              { n = G.UIT.B, config = { w = 0.08, h = 0.01 } },
              {
                n = G.UIT.T,
                config = {
                  text = tostring(game_state.discards_max),
                  scale = 0.45,
                  colour = G.C.UI.TEXT_LIGHT,
                },
              },
            },
          },
        },
      },
      {
        n = G.UIT.C,
        config = { align = "cm", padding = 0.05, colour = G.C.L_BLACK, r = 0.1, minw = 1.5 },
        nodes = {
          {
            n = G.UIT.T,
            config = {
              text = number_format(game_state.highest_score),
              scale = 0.45,
              colour = G.C.FILTER,
              shadow = true,
            },
          },
        },
      },
      MP.UI.Disableable_Button({
        id = "send_money_to_" .. profile.id,
        button = "send_money_to_player",
        button_args = { player_id = profile.id },
        colour = G.C.GOLD,
        label = { localize("b_send_money") .. " $" .. (5 - (MP.LOBBY.config.nano_br_hivemind_transfer_tax or 0)) .. " ($5)" },
        scale = 0.45,
        minw = 2.5,
        minh = 0.45,
        col = true,
        enabled_ref_table = { enabled = (not MP.UTILS.is_local_player(player) and MP.UTILS.is_coop()) and G.GAME.dollars >= to_big(5) },
        enabled_ref_value = "enabled",
      }) or {
        n = G.UIT.C,
        config = { align = "cm", colour = G.C.CLEAR, r = 0.1, minw = 2.5 }
      } or nil,
    },
  }
end
