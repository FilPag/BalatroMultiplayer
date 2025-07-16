function G.UIDEF.create_UIBox_view_nemesis_deck()
  return create_UIBox_generic_options(
    {
      back_func = 'overlay_endgame_menu',
      contents = {
        create_tabs({
          tabs = {
            {
              label = localize('k_nemesis_deck'),
              chosen = true,
              tab_definition_function = G.UIDEF.view_nemesis_deck
            },
            {
              label = localize('k_your_deck'),
              tab_definition_function = G.UIDEF.view_deck
            },
          },
          tab_h = 8,
          snap_to_nav = true
        })
      },
    })
end
