MP.UI.lobby_ready_button = function(text_scale)
  if MP.LOBBY.isHost then
    return MP.UI.Disableable_Button({
      id = "lobby_menu_start",
      button = "lobby_start_game",
      colour = G.C.BLUE,
      minw = 3.65,
      minh = 1.55,
      label = { localize("b_start") },
      disabled_text = localize("b_wait_for_players"),
      scale = text_scale * 2,
      col = true,
      enabled_ref_table = MP.LOBBY,
      enabled_ref_value = "ready_to_start",
    })
  else
    local player = MP.UTILS.get_local_player_lobby_data()
    return {
      n = G.UIT.C,
      config = {
        id = "lobby_ready_button",
        button = "toggle_lobby_ready",
        align = "cm",
        r = 0.1,
        hover = true,
        colour = player and (player.isReady and G.C.GREEN or G.C.RED),
        maxw = 3.45,
        minw = 3.65,
        minh = 1.55,
      },
      nodes = {
        {
          n = G.UIT.O,
          config = {
            align = "cm",
            object = DynaText({
              string = { { ref_table = MP.LOBBY, ref_value = "ready_text" } },
              colours = { G.C.UI.TEXT_LIGHT },
              shadow = true,
              font = G.LANGUAGES["en-us"].font,
              scale = 2 * text_scale,
            }),
          }
        },
      }
    }
  end
end
