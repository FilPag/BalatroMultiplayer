local create_UIBox_game_over_ref = create_UIBox_game_over
function create_UIBox_game_over()
  if not MP.LOBBY.code then
    return create_UIBox_game_over_ref()
  end
  MP.end_game_jokers = CardArea(
    0,
    0,
    5 * G.CARD_W,
    G.CARD_H,
    { card_limit = G.GAME.starting_params.joker_slots, type = "joker", highlight_limit = 1 }
  )

	G.SETTINGS.PAUSED = false
  local eased_red = copy_table(G.GAME.round_resets.ante <= G.GAME.win_ante and G.C.RED or G.C.BLUE)
  eased_red[4] = 0
  ease_value(eased_red, 4, 0.8, nil, nil, true)
  local t = create_UIBox_generic_options({
    bg_colour = eased_red,
    no_back = true,
    padding = 0,
    contents = {
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = { localize("ph_game_over") },
                colours = { G.C.RED },
                shadow = true,
                float = true,
                scale = 1.5,
                pop_in = 0.4,
                maxw = 6.5,
              }),
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.15 },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "cm" },
            nodes = {
              {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                  {
                    n = G.UIT.T,
                    config = {
                      text = localize("k_enemy_jokers"),
                      scale = 0.8,
                      maxw = 5,
                      shadow = true,
                    },
                  },
                },
              },
              {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                  { n = G.UIT.O, config = { object = MP.end_game_jokers } },
                },
              },
              {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                  {
                    n = G.UIT.C,
                    config = {
                      maxw = 1,
                      minw = 1,
                      minh = 0.7,
                      colour = G.C.CLEAR,
                      no_fill = false
                    }
                  },
                  {
                    n = G.UIT.C,
                    config = {
                      button = "view_nemesis_deck",
                      align = "cm",
                      padding = 0.12,
                      colour = G.C.BLUE,
                      emboss = 0.05,
                      minh = 0.7,
                      minw = 2,
                      maxw = 2,
                      r = 0.1,
                      shadow = true,
                      hover = true,
                    },
                    nodes = {
                      {
                        n = G.UIT.T,
                        config = {
                          text = localize("b_view_nemesis_deck"),
                          colour = G.C.UI.TEXT_LIGHT,
                          scale = 0.65,
                          col = true,
                        }
                      }
                    }
                  },
                  {
                    n = G.UIT.C,
                    config = {
                      maxw = 1,
                      minw = 1,
                      minh = 0.7,
                      colour = G.C.CLEAR,
                      no_fill = false
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
                    config = { align = "cm", padding = 0.08 },
                    nodes = {
                      create_UIBox_round_scores_row("hand"),
                      create_UIBox_round_scores_row("poker_hand"),
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.08, minw = 2 },
                        nodes = {
                          {
                            n = G.UIT.T,
                            config = {
                              text = localize("ml_mp_kofi_message")[1],
                              scale = 0.35,
                              colour = G.C.UI.TEXT_LIGHT,
                              col = true,
                            },
                          },
                        },
                      },
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.08, minw = 2 },
                        nodes = {
                          {
                            n = G.UIT.T,
                            config = {
                              text = localize("ml_mp_kofi_message")[2],
                              scale = 0.35,
                              colour = G.C.UI.TEXT_LIGHT,
                              col = true,
                            },
                          },
                        },
                      },
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.08, minw = 2 },
                        nodes = {
                          {
                            n = G.UIT.T,
                            config = {
                              text = localize("ml_mp_kofi_message")[3],
                              scale = 0.35,
                              colour = G.C.UI.TEXT_LIGHT,
                              col = true,
                            },
                          },
                        },
                      },
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.08, minw = 2 },
                        nodes = {
                          {
                            n = G.UIT.T,
                            config = {
                              text = localize("ml_mp_kofi_message")[4],
                              scale = 0.35,
                              colour = G.C.UI.TEXT_LIGHT,
                              col = true,
                            },
                          },
                        },
                      },
                      {
                        n = G.UIT.R,
                        config = {
                          id = "ko-fi_button",
                          align = "cm",
                          padding = 0.1,
                          r = 0.1,
                          hover = true,
                          colour = HEX("72A5F2"),
                          button = "open_kofi",
                          shadow = true,
                        },
                        nodes = {
                          {
                            n = G.UIT.R,
                            config = {
                              align = "cm",
                              padding = 0,
                              no_fill = true,
                              maxw = 3,
                            },
                            nodes = {
                              {
                                n = G.UIT.T,
                                config = {
                                  text = localize("b_mp_kofi_button"),
                                  scale = 0.35,
                                  colour = G.C.UI.TEXT_LIGHT,
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                  {
                    n = G.UIT.C,
                    config = { align = "tr", padding = 0.08 },
                    nodes = {
                      create_UIBox_round_scores_row("furthest_ante", G.C.FILTER),
                      create_UIBox_round_scores_row("furthest_round", G.C.FILTER),
                      create_UIBox_round_scores_row("seed", G.C.WHITE),
                      UIBox_button({
                        button = "copy_seed",
                        label = { localize("b_copy") },
                        colour = G.C.BLUE,
                        scale = 0.3,
                        minw = 2.3,
                        minh = 0.4,
                      }),
                      {
                        n = G.UIT.R,
                        config = { align = "cm", minh = 0.4, minw = 0.1 },
                        nodes = {},
                      },
                      UIBox_button({
                        id = "from_game_won",
                        button = "mp_return_to_lobby",
                        label = { localize("b_return_lobby") },
                        minw = 2.5,
                        maxw = 2.5,
                        minh = 1,
                        focus_args = { nav = "wide", snap_to = true },
                      }),
                      UIBox_button({
                        button = "lobby_leave",
                        label = { localize("b_leave_lobby") },
                        minw = 2.5,
                        maxw = 2.5,
                        minh = 1,
                        focus_args = { nav = "wide" },
                      }),
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  })
  t.nodes[1] = {
    n = G.UIT.R,
    config = { align = "cm", padding = 0.1 },
    nodes = {
      {
        n = G.UIT.C,
        config = { align = "cm", padding = 2 },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              padding = 0,
              id = "jimbo_spot",
              object = Moveable(0, 0, G.CARD_W * 1.1, G.CARD_H * 1.1),
            },
          },
        },
      },
      { n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = { t.nodes[1] } },
    },
  }

  return t
end

local create_UIBox_win_ref = create_UIBox_win
function create_UIBox_win()
  if not MP.LOBBY.code then
    return create_UIBox_win_ref()
  end
  MP.end_game_jokers = CardArea(
    0,
    0,
    5 * G.CARD_W,
    G.CARD_H,
    { card_limit = G.GAME.starting_params.joker_slots, type = "joker", highlight_limit = 1 }
  )

	G.SETTINGS.PAUSED = false
  if not MP.end_game_jokers_received then
    MP.ACTIONS.get_end_game_jokers()
  else
    G.FUNCS.load_end_game_jokers()
  end

  local eased_green = copy_table(G.C.GREEN)
  eased_green[4] = 0
  ease_value(eased_green, 4, 0.5, nil, nil, true)
  local t = create_UIBox_generic_options({
    padding = 0,
    bg_colour = eased_green,
    colour = G.C.BLACK,
    outline_colour = G.C.EDITION,
    no_back = true,
    no_esc = true,
    contents = {
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = { localize("ph_you_win") },
                colours = { G.C.EDITION },
                shadow = true,
                float = true,
                spacing = 10,
                rotate = true,
                scale = 1.5,
                pop_in = 0.4,
                maxw = 6.5,
              }),
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.15 },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "cm" },
            nodes = {
              {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                  {
                    n = G.UIT.T,
                    config = {
                      text = localize("k_enemy_jokers"),
                      scale = 0.8,
                      maxw = 5,
                      shadow = true,
                    },
                  },
                },
              },
              {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                  { n = G.UIT.O, config = { object = MP.end_game_jokers } },
                },
              },
              {
                n = G.UIT.C,
                config = {
                  maxw = 0.8,
                  minw = 0.8,
                  minh = 0.7,
                  colour = G.C.CLEAR,
                  no_fill = false
                }
              },
              {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                  {
                    n = G.UIT.C,
                    config = {
                      id = "view_nemesis_deck_button",
                      button = "view_nemesis_deck",
                      align = "cm",
                      padding = 0.12,
                      colour = G.C.BLUE,
                      emboss = 0.05,
                      minh = 0.7,
                      minw = 2,
                      maxw = 2,
                      r = 0.1,
                      shadow = true,
                      hover = true,
                      focus_args = { nav = "wide" },
                    },
                    nodes = {
                      {
                        n = G.UIT.T,
                        config = {
                          text = localize("b_view_nemesis_deck"),
                          colour = G.C.UI.TEXT_LIGHT,
                          scale = 0.65,
                          col = true,
                        }
                      }
                    }
                  },
                  {
                    n = G.UIT.C,
                    config = {
                      maxw = 0.8,
                      minw = 0.8,
                      minh = 0.7,
                      colour = G.C.CLEAR,
                      no_fill = false
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
                    config = { align = "cm", padding = 0.08 },
                    nodes = {
                      create_UIBox_round_scores_row("hand"),
                      create_UIBox_round_scores_row("poker_hand"),
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.08, minw = 2 },
                        nodes = {
                          {
                            n = G.UIT.T,
                            config = {
                              text = localize("ml_mp_kofi_message")[1],
                              scale = 0.35,
                              colour = G.C.UI.TEXT_LIGHT,
                              col = true,
                            },
                          },
                        },
                      },
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.08, minw = 2 },
                        nodes = {
                          {
                            n = G.UIT.T,
                            config = {
                              text = localize("ml_mp_kofi_message")[2],
                              scale = 0.35,
                              colour = G.C.UI.TEXT_LIGHT,
                              col = true,
                            },
                          },
                        },
                      },
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.08, minw = 2 },
                        nodes = {
                          {
                            n = G.UIT.T,
                            config = {
                              text = localize("ml_mp_kofi_message")[3],
                              scale = 0.35,
                              colour = G.C.UI.TEXT_LIGHT,
                              col = true,
                            },
                          },
                        },
                      },
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.08, minw = 2 },
                        nodes = {
                          {
                            n = G.UIT.T,
                            config = {
                              text = localize("ml_mp_kofi_message")[4],
                              scale = 0.35,
                              colour = G.C.UI.TEXT_LIGHT,
                              col = true,
                            },
                          },
                        },
                      },
                      {
                        n = G.UIT.R,
                        config = {
                          id = "ko-fi_button",
                          align = "cm",
                          padding = 0.1,
                          r = 0.1,
                          hover = true,
                          colour = HEX("72A5F2"),
                          button = "open_kofi",
                          shadow = true,
                        },
                        nodes = {
                          {
                            n = G.UIT.R,
                            config = {
                              align = "cm",
                              padding = 0,
                              no_fill = true,
                              maxw = 3,
                            },
                            nodes = {
                              {
                                n = G.UIT.T,
                                config = {
                                  text = localize("b_mp_kofi_button"),
                                  scale = 0.35,
                                  colour = G.C.UI.TEXT_LIGHT,
                                },
                              },
                            },
                          },
                        },
                      },
                      UIBox_button({
                        id = "continue_singpleplayer_button",
                        align = "lm",
                        button = "continue_in_singleplayer",
                        label = { localize("b_continue_singleplayer") },
                        colour = G.C.GREEN,
                        minw = 6,
                        minh = 1,
                        focus_args = { nav = "wide" },
                      })
                    },
                  },
                  {
                    n = G.UIT.C,
                    config = { align = "tr", padding = 0.08 },
                    nodes = {
                      create_UIBox_round_scores_row("furthest_ante", G.C.FILTER),
                      create_UIBox_round_scores_row("furthest_round", G.C.FILTER),
                      create_UIBox_round_scores_row("seed", G.C.WHITE),
                      UIBox_button({
                        id = "copy_seed_button",
                        button = "copy_seed",
                        label = { localize("b_copy") },
                        colour = G.C.BLUE,
                        scale = 0.3,
                        minw = 2.3,
                        minh = 0.4,
                      }),
                      {
                        n = G.UIT.R,
                        config = { align = "cm", minh = 0.4, minw = 0.1 },
                        nodes = {},
                      },
                      UIBox_button({
                        id = "from_game_won",
                        button = "mp_return_to_lobby",
                        label = { localize("b_return_lobby") },
                        minw = 2.5,
                        maxw = 2.5,
                        minh = 1,
                        focus_args = { nav = "wide", snap_to = true },
                      }),
                      UIBox_button({
                        button = "lobby_leave",
                        label = { localize("b_leave_lobby") },
                        minw = 2.5,
                        maxw = 2.5,
                        minh = 1,
                        focus_args = { nav = "wide" },
                      }),
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  })
  t.nodes[1] = {
    n = G.UIT.R,
    config = { align = "cm", padding = 0.1 },
    nodes = {
      {
        n = G.UIT.C,
        config = { align = "cm", padding = 2 },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              padding = 0,
              id = "jimbo_spot",
              object = Moveable(0, 0, G.CARD_W * 1.1, G.CARD_H * 1.1),
            },
          },
        },
      },
      { n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = { t.nodes[1] } },
    },
  }
  --t.nodes[1].config.mid = true
  t.config.id = "you_win_UI"
  return t
end
