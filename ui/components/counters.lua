function MP.UI.round_replacement()
  local scale = 0.4
  local temp_col = G.C.DYN_UI.BOSS_MAIN
  local temp_col2 = G.C.DYN_UI.BOSS_DARK

  return MP.UI.lives_counter(scale, temp_col, temp_col2)
end

function MP.UI.ante_replacement()
  if MP.LOBBY.code and not MP.LOBBY.config.disable_live_and_timer_hud and not MP.UTILS.is_coop() then
    return MP.UI.timer_hud()
  end

  local scale = 0.4
  local temp_col = G.C.DYN_UI.BOSS_MAIN
  local temp_col2 = G.C.DYN_UI.BOSS_DARK
  return MP.UI.coop_ante_counter(scale, temp_col, temp_col2)
end

function MP.UI.timer_hud()
  return {
    n = G.UIT.C,
    config = {
      align = "cm",
      padding = 0.05,
      minw = 1.45,
      minh = 1,
      colour = G.C.DYN_UI.BOSS_MAIN,
      emboss = 0.05,
      r = 0.1,
    },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", maxw = 1.35 },
        nodes = {
          {
            n = G.UIT.T,
            config = {
              text = localize("k_timer"),
              minh = 0.33,
              scale = 0.34,
              colour = G.C.UI.TEXT_LIGHT,
              shadow = true,
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = {
          align = "cm",
          r = 0.1,
          minw = 1.2,
          colour = G.C.DYN_UI.BOSS_DARK,
          id = "row_round_text",
          func = "set_timer_box",
          button = "mp_timer_button",
        },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = { { ref_table = MP.GAME, ref_value = "timer" } },
                colours = { G.C.UI.TEXT_DARK },
                shadow = true,
                scale = 0.8,
              }),
              id = "timer_UI_count",
            },
          },
        },
      },
    },
  }
end

function MP.UI.lives_counter(scale, temp_col, temp_col2)
  return {
    n = G.UIT.C,
    config = { id = 'hud_ante', align = "cm", padding = 0.05, minw = 1.45, minh = 1, colour = temp_col, emboss = 0.05, r = 0.1 },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", minh = 0.33, maxw = 1.35 },
        nodes = {
          { n = G.UIT.T, config = { text = localize('k_lives'), scale = 0.85 * scale, colour = G.C.UI.TEXT_LIGHT, shadow = true } },
        }
      },
      {
        n = G.UIT.R,
        config = { align = "cm", r = 0.1, minw = 1.2, colour = temp_col2 },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = { { ref_table = MP.UTILS.get_local_player(), ref_value = "lives" } },
                colours = { G.C.IMPORTANT },
                shadow = true,
                font = G.LANGUAGES["en-us"].font,
                scale = 2 * scale,
              }),
              id = 'ante_UI_count'
            }
          },
        }
      },
    }
  }
end

function MP.UI.coop_ante_counter(scale, temp_col, temp_col2)
  return {
    n = G.UIT.C,
    config = { id = 'hud_ante', align = "cm", padding = 0.05, minw = 1.45, minh = 1, colour = temp_col, emboss = 0.05, r = 0.1 },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", minh = 0.33, maxw = 1.35 },
        nodes = {
          { n = G.UIT.T, config = { text = localize('k_ante'), scale = 0.85 * scale, colour = G.C.UI.TEXT_LIGHT, shadow = true } },
        }
      },
      {
        n = G.UIT.R,
        config = { align = "cm", r = 0.1, minw = 1.2, colour = temp_col2 },
        nodes = {
          { n = G.UIT.O, config = { object = DynaText({ string = { { ref_table = G.GAME.round_resets, ref_value = 'ante' } }, colours = { G.C.IMPORTANT }, shadow = true, font = G.LANGUAGES['en-us'].font, scale = 2 * scale }), id = 'ante_UI_count' } },
        }
      },
    }
  }
end
