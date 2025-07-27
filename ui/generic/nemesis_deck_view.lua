function G.UIDEF.create_UIBox_view_nemesis_deck()
  local players = MP.LOBBY.players

  local tabs = {
    {
      label = localize('k_your_deck'),
      tab_definition_function = G.UIDEF.view_deck,
      chosen = true,
    },
  }

  for _, player in ipairs(players) do
    if player.deck and player.profile.id ~= MP.LOBBY.local_id then
      table.insert(tabs, {
        label = player.username,
        tab_definition_function = G.UIDEF.view_player_deck,
        tab_definition_function_args = player
      })
    end
  end

  return create_UIBox_generic_options(
    {
      back_func = 'overlay_endgame_menu',
      contents = {
        create_tabs({
          tabs = tabs,
          tab_h = 8,
          snap_to_nav = true
        })
      },
    })
end
