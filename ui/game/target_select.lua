local debug_players = {
  { profile = { id = 1, username = "Player1" } },
  { profile = { id = 2, username = "Player2" } },
  { profile = { id = 3, username = "Player3" } },
  { profile = { id = 4, username = "Player4" } },
  { profile = { id = 5, username = "Player5" } },
  { profile = { id = 6, username = "Player6" } },
  { profile = { id = 7, username = "Player7" } },
  { profile = { id = 8, username = "Player8" } },
  { profile = { id = 9, username = "Player9" } },
  { profile = { id = 10, username = "Player10" } },
  { profile = { id = 11, username = "Player11" } },
  { profile = { id = 12, username = "Player12" } },
  { profile = { id = 13, username = "Player13" } },
  { profile = { id = 14, username = "Player14" } },
  { profile = { id = 15, username = "Player15" } },
  { profile = { id = 16, username = "Player16" } },
}

-- Define the callback outside the UI function
G.FUNCS.target_select_callback = function(e)
  -- Get the name_id_map from the cycle config
  local name_id_map = e.cycle_config.name_id_map
  local display_name = e.to_val
  sendDebugMessage("Target selected: " .. e.to_val)
  local selected_id = name_id_map[display_name]
  sendDebugMessage("Selected ID: " .. tostring(selected_id))

  MP.GAME.selected_target = selected_id
end

function MP.UI.target_select()

  -- Select players (excluding local player)
  local players = MP.LOBBY.code and MP.LOBBY.players or debug_players
  local local_id = MP.LOBBY.local_player.profile.id

  local names, name_id_map = {}, {}
  local selected_index = 1
  for _, player in pairs(players) do
    if player.profile.id ~= local_id then
      table.insert(names, player.profile.username)
      name_id_map[player.profile.username] = player.profile.id
      if player.profile.id == MP.GAME.selected_target then
        selected_index = #names
      end
    end
  end

  MP.GAME.selected_target = MP.GAME.selected_target or name_id_map[names[selected_index]]

  return {
    n = G.UIT.R,
    config = {
      align = "cm",
      colour = G.C.UI.TRANSPARENT,
    },
    nodes = {
      create_option_cycle({
        options = names,
        current_option = selected_index,
        opt_callback = 'target_select_callback',
        cycle_shoulders = true,
        colour = G.C.RED,
        w = 1.5,
        h = 0.8,
        name_id_map = name_id_map
      })
    }
  }
end
