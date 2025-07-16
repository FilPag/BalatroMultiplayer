function MP.UI.create_UIBox_player_row(username, player_state, colour)
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
                  text = tostring(player_state.lives) .. " " .. localize("k_lives"),
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
                  text = " " .. username,
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
              ref_table = player_state,
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
                  text = tostring(player_state.hands_left), -- Will be hands in the future
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
                  text = "???", -- Will be discards in the future
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
              text = MP.INSANE_INT.to_string(player_state.highest_score),
              scale = 0.45,
              colour = G.C.FILTER,
              shadow = true,
            },
          },
        },
      },
    },
  }
end
