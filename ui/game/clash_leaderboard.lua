local debug_players = {
  ["1"] = { profile = { name = "Player 1" }, game_state = { score = 100000000000 } },
  ["2"] = { profile = { name = "Player 2" }, game_state = { score = 200000000000 } },
  ["3"] = { profile = { name = "Player 3" }, game_state = { score = 300000000000 } },
  ["4"] = { profile = { name = "Player 4" }, game_state = { score = 400000000000 } },
  ["5"] = { profile = { name = "Player 5" }, game_state = { score = 500000000000 } },
  ["6"] = { profile = { name = "Player 6" }, game_state = { score = 600000000000 } },
  ["7"] = { profile = { name = "Player 7" }, game_state = { score = 700000000000 } },
  ["8"] = { profile = { name = "Player 8" }, game_state = { score = 800000000000 } },
}

-- Helper function to sort players by score (descending)
function MP.UTILS.get_sorted_players()
  local sorted_players = {}
  for idx, player in pairs(debug_players) do
    if player.game_state and player.game_state.score then
      table.insert(sorted_players, { idx = idx, player = player })
    end
  end
  table.sort(sorted_players, function(a, b)
    return (a.player.game_state.score or 0) > (b.player.game_state.score or 0)
  end)
  return sorted_players
end

-- Helper function to create or update player UI slot
function MP.UTILS.update_player_slot(player_data, position, slot_id)
  local slot = MP.GAME.leaderboard:get_UIE_by_ID("mp_player_slot_" .. tostring(slot_id))
  if not slot then return end
  
  -- Remove existing slot if it exists
  if debug_players[player_data.idx].game_state.player_slot then
    debug_players[player_data.idx].game_state.player_slot:remove()
  end
  
  debug_players[player_data.idx].game_state.player_slot = UIBox({
    definition = MP.UIDEF.player_leaderboard_entry(player_data.player, position),
    config = { major = slot, bond = "Strong" }
  })
end

-- Helper function to populate all player slots
function MP.UTILS.populate_leaderboard(sorted_players)
  for position, player_data in ipairs(sorted_players) do
    MP.UTILS.update_player_slot(player_data, position, position)
  end
end

function MP.UTILS.re_sort_players()
  if not MP.GAME.leaderboard then return end
  
  sendDebugMessage("Re-sorting players")
  
  -- Randomize scores for testing
  for _, player in pairs(debug_players) do
    player.game_state.score = math.random(1, 100000000)
  end
  
  local sorted_players = MP.UTILS.get_sorted_players()
  MP.UTILS.populate_leaderboard(sorted_players)
end

local keypressed_ref = love.keypressed
function love.keypressed(key, scancode, isrepeat)
  if key == "n" then
    MP.UTILS.re_sort_players()
  end
  keypressed_ref(key, scancode, isrepeat)
end

local blind_set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
  blind_set_blind_ref(self, blind, reset, silent)
  G.HUD_blind:get_UIE_by_ID("HUD_blind").states.visible = false
  MP.GAME.leaderboard = UIBox({
    definition = MP.UIDEF.clash_leaderboard(),
    config = { major = G.HUD_blind, align = 'cm', padding = 0.1 }
  })

  local sorted_players = MP.UTILS.get_sorted_players()
  MP.UTILS.populate_leaderboard(sorted_players)
end

MP.DEBUG = true

function MP.UIDEF.player_leaderboard_entry(player, position)
  return {
    n = G.UIT.ROOT,
    config = { align = "cm", colour = G.C.BLACK, minw = 1.5, minh = 0.8, padding = 0, r = 0.1, hover = true, shadow = true },
    nodes = { {
      n = G.UIT.R,
      config = {
        align = "tm",
        minw = 1.5,
        minh = 0.4,
        padding = 0,
      },
      nodes = {
        {
          n = G.UIT.T,
          config = {
            text = "#" .. tostring(position) .. " ",
            scale = 0.25,
            colour = G.C.UI.TEXT_LIGHT,
            padding = 0,
            minh = 0.4,
          }
        },
        {
          n = G.UIT.T,
          config = {
            text = player.profile.name,
            scale = 0.25,
            colour = G.C.UI.TEXT_LIGHT,
            padding = 0,
            minh = 0.4,
          }
        },
      },
    },
      {
        n = G.UIT.R,
        config = {
          align = "bm",
          padding = 0,
        },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = { { ref_table = player.game_state, ref_value = 'score' } },
                colours = { G.C.UI.TEXT_LIGHT },
                float = true,
                scale = 0.3,
              }),
              padding = 0.05,
              minh = 0.4,
            }
          }
        },
      }
    }
  }
end

-- Generate player slot rows based on player count
function generate_player_rows()
  local player_count = 0
  for _, player in pairs(debug_players) do
    if player.game_state and player.game_state.score then
      player_count = player_count + 1
    end
  end
  
  local rows = {}
  local slots_per_row = 3
  local current_slot = 1
  
  while current_slot <= player_count do
    local slots_in_this_row = math.min(slots_per_row, player_count - current_slot + 1)
    local row_slots = {}
    
    for i = current_slot, current_slot + slots_in_this_row - 1 do
      table.insert(row_slots, {
        n = G.UIT.C,
        config = { align = "cm", minw = 1.5, minh = 0.8, padding = 0, id = "mp_player_slot_" .. tostring(i) },
      })
    end
    
    table.insert(rows, {
      n = G.UIT.R,
      config = { align = "cm", padding = 0.05, minh = 0.8 },
      nodes = row_slots
    })
    
    current_slot = current_slot + slots_in_this_row
  end
  
  return rows
end

function MP.UIDEF.clash_leaderboard()
  local scale = 0.4

  return {
    n = G.UIT.ROOT,
    config = { align = "cm", minw = 4.95, maxw = 4.95, r = 0.1, emboss = 0.05, padding = 0.05, colour = G.C.BLACK },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", minh = 0.7, r = 0.1, emboss = 0.05, colour = G.C.DYN_UI.MAIN, minw = 4.95 },
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
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "cm", r = 0.1, padding = 0.05, minw = 4.90, minh = 2.74, colour = G.C.DYN_UI.DARK },
            nodes = generate_player_rows()
          }
        }
      }
    },
  }
end
