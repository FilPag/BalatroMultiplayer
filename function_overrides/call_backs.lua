local exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function()

  if MP.LOBBY.code and MP.LOBBY.is_host and G.OVERLAY_MENU then
    if G.OVERLAY_MENU:get_UIE_by_ID("lobby_options") then
      MP.ACTIONS.update_lobby_options()
    end
  end
  exit_overlay_menu_ref()
end