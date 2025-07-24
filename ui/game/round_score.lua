function MP.UIDEF.round_score()
  return {
    n = G.UIT.C,
    config = { align = "cm", padding = 0.1 },
    nodes = {
      {
        n = G.UIT.C,
        config = { align = "cm", minw = 1.3 },
        nodes = {
          {
            n = G.UIT.R,
            config = { align = "cm", padding = 0, maxw = 1.3 },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  text = G.SETTINGS.language == "vi" and localize("k_lower_score") or localize("k_round"),
                  scale = 0.42,
                  colour = G.C.UI.TEXT_LIGHT,
                  shadow = true,
                },
              },
            },
          },
          {
            n = G.UIT.R,
            config = { align = "cm", padding = 0, maxw = 1.3 },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  text = G.SETTINGS.language == "vi" and localize("k_round") or localize("k_lower_score"),
                  scale = 0.42,
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
        config = { align = "cm", minw = 3.3, minh = 0.7, r = 0.1, colour = G.C.DYN_UI.BOSS_DARK },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              w = 0.5,
              h = 0.5,
              object = get_stake_sprite(G.GAME.stake or 1, 0.5),
              hover = true,
              can_collide = false,
            },
          },
          { n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
          {
            n = G.UIT.T,
            config = {
              ref_table = G.GAME,
              ref_value = "chips_text",
              lang = G.LANGUAGES["en-us"],
              scale = 0.85,
              colour = G.C.WHITE,
              id = "chip_UI_count",
              func = "chip_UI_set",
              shadow = true,
            },
          },
        },
      },
    },
  }
end
