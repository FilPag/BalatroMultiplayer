local debug_players = {
  {profile = {id = 1, username = "Player1"}},
  {profile = {id = 2, username = "Player2"}},
  {profile = {id = 3, username = "Player3"}},
  {profile = {id = 4, username = "Player4"}},
  {profile = {id = 5, username = "Player5"}},
  {profile = {id = 6, username = "Player6"}},
  {profile = {id = 7, username = "Player7"}},
  {profile = {id = 8, username = "Player8"}},
  {profile = {id = 9, username = "Player9"}},
  {profile = {id = 10, username = "Player10"}},
  {profile = {id = 11, username = "Player11"}},
  {profile = {id = 12, username = "Player12"}},
  {profile = {id = 13, username = "Player13"}},
  {profile = {id = 14, username = "Player14"}},
  {profile = {id = 15, username = "Player15"}},
  {profile = {id = 16, username = "Player16"}},
}


function MP.UI.target_select()
  local players
  if MP.LOBBY.code then
    players = MP.LOBBY.players
  else
    players = debug_players
  end

  local options = {}
  for _, player in ipairs(players) do
    table.insert(options, player.profile.username)
  end

  return {
    n = G.UIT.R,
    config = {
      align = "cm",
      colour = G.C.UI.TRANSPARENT,
    },
    nodes = {
      create_option_cycle({
        options = options,
        cycle_shoulders = true,
        colour = G.C.RED,
        w = 1.5,
        h = 0.8
      })
    }
  }
end
