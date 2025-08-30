MP.DEBUG = true
local blind_set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
  blind_set_blind_ref(self, blind, reset, silent)
  G.HUD_blind:get_UIE_by_ID("HUD_blind").states.visible = false
  G.HUD_blind:recalculate()
  UIBox({
    definition = MP.UI.clash_leaderboard(),
    config = {major = G.HUD_blind, align = 'cm'}
  })
end

function generate_player_slots(from, to)
  local slots = {}
  for i = from, to do
    table.insert(slots, {
      n = G.UIT.C,
      config = { align = "cm", padding = 0.1, colour = G.C.PURPLE, minw = 1.4, minh = 0.8},
      nodes = {
        {
          n = G.UIT.R,
          config = {
            align = "cm",
            padding = 0,
            colour = G.C.RED,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                text = "Player " .. tostring(i) .. ":",
                scale = 0.25,
                colour = G.C.UI.TEXT_LIGHT,
                padding = 0,
                minh = 0.4,
                minw = 1.4
              }
            },
          }
        },
        {
          n = G.UIT.R,
          config = {
            align = "cm",
            padding = 0,
            colour = G.C.RED,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                text = "0",
                scale = 0.3,
                colour = G.C.UI.TEXT_LIGHT,
                padding = 0,
                minh = 0.4,
                minw = 1.4
              }
            }
          },
        }
      },
    })
  end
  return slots
end

function MP.UI.clash_leaderboard()
  local scale = 0.4

  return {
    n = G.UIT.ROOT,
    config = { align = "cm", minw = 5, r = 0.1, colour = G.C.BLACK, emboss = 0.05, padding = 0.05 },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", minh = 0.7, r = 0.1, emboss = 0.05, colour = G.C.DYN_UI.MAIN },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "cm", minw = 3 },
            nodes = {
              { n = G.UIT.O, config = { object = DynaText({ string = { { ref_table = G.GAME.blind, ref_value = 'loc_name' } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, rotate = true, silent = true, float = true, scale = 1.6 * scale, y_offset = -4 }), id = 'HUD_blind_name' } },
            }
          },
        }
      },
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0, colour = G.C.RED, minw = 4.5, minh = 0.8 },
        nodes = generate_player_slots(1, 3)
      },
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0, colour = G.C.GREEN, minw = 4.5, minh = 0.8 },
        nodes = generate_player_slots(4, 6)
      },
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0, colour = G.C.BLUE, minw = 4.5, minh = 0.8 },
        nodes = generate_player_slots(7, 8)
      }
    },
  }
end
