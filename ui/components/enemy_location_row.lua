-- ui/components/enemy_location_row.lua
function MP.UIDEF.enemy_location_row(ref_table, ref_value)
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
                  text = localize("ml_enemy_loc")[1],
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
                  text = localize("ml_enemy_loc")[2],
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
            n = G.UIT.T,
            config = {
              ref_table = ref_table,
              ref_value = ref_value,
              scale = 0.35,
              colour = G.C.WHITE,
              shadow = true,
            },
          },
        },
      },
    },
  }
end
