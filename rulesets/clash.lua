MP.Ruleset({
    key = "clash",
    multiplayer_content = true,
    banned_jokers = {
        "j_mp_conjoined_joker",
        "j_mp_defensive_joker",
        "j_mp_hanging_chad",
        "j_mp_lets_go_gambling",
        "j_mp_magnet",
        "j_mp_penny_pincher",
        "j_mp_pizza",
        "j_mp_skip_off",
        "j_mp_speedrun",
        "j_mp_taxes",
        "j_chicot",
        "j_matador",
        "j_mr_bones"
    },
    banned_consumables = {},
    banned_vouchers = {},
    banned_enhancements = {},
    banned_tags = {
        "tag_boss"
    },
    banned_blinds = {},
    reworked_jokers = {},
    reworked_consumables = {},
    reworked_vouchers = {},
    reworked_enhancements = {},
    reworked_tags = {},
    reworked_blinds = {},
    forced_gamemode = "gamemode_mp_clash",
    create_info_menu = function()
        return {
            {
                n = G.UIT.R,
                config = {
                    align = "tm"
                },
                nodes = {
                    MP.UI.BackgroundGrouping(localize("k_has_multiplayer_content"), {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_yes"),
                                scale = 0.8,
                                colour = G.C.GREEN,
                            }
                        }
                    }, { col = true, text_scale = 0.6 }),
                    {
                        n = G.UIT.C,
                        config = {
                            minw = 0.1,
                            minh = 0.1
                        }
                    },
                    MP.UI.BackgroundGrouping(localize("k_forces_lobby_options"), {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_yes"),
                                scale = 0.8,
                                colour = G.C.GREEN,
                            }
                        }
                    }, { col = true, text_scale = 0.6 }),
                    {
                        n = G.UIT.C,
                        config = {
                            minw = 0.1,
                            minh = 0.1
                        }
                    },
                    MP.UI.BackgroundGrouping(localize("k_forces_gamemode"), {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_yes"),
                                scale = 0.8,
                                colour = G.C.GREEN,
                            }
                        }
                    }, { col = true, text_scale = 0.6 })
                },
            },
            {
                n = G.UIT.R,
                config = {
                    minw = 0.05,
                    minh = 0.05
                }
            },
            {
                n = G.UIT.R,
                config = {
                    align = "cl",
                    padding = 0.1
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_clash_description"),
                            scale = 0.6,
                            colour = G.C.UI.TEXT_LIGHT,
                        }
                    },
                },
            },
        }
    end,
}):inject()
