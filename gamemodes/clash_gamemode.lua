MP.Gamemode({
    key = "clash",
    get_blinds_by_ante = function(self, ante, choices)
		--G.GAME.round_resets.pvp_blind_choices.Boss = true
        return choices.Small, choices.Big, "bl_mp_clash"
    end,
    banned_jokers = {
    },
    banned_consumables = {},
    banned_vouchers = {
    },
    banned_enhancements = {},
    banned_tags = {
        "tag_boss"
    },
    banned_blinds = {
    },
    reworked_jokers = {},
    reworked_consumables = {},
    reworked_vouchers = {},
    reworked_enhancements = {},
    reworked_tags = {},
    reworked_blinds = {},
    create_info_menu = function()
        return {
            {
                n = G.UIT.R,
                config = {
                    align = "tm"
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = MP.UTILS.wrapText(localize("k_clash_description"), 70),
                            scale = 0.6,
                            colour = G.C.UI.TEXT_LIGHT,
                        }
                    },
                },
            },
            {
                n = G.UIT.R,
                config = {
                    minw = 0.2,
                    minh = 0.2
                }
            },
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    padding = 0.3
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm"
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm"
                                },
                                nodes = {
                                    MP.UI.BackgroundGrouping(
                                        localize({ type = "variable", key = "k_ante_number", vars = { "1" } }), {
                                            {
                                                n = G.UIT.O,
                                                config = {
                                                    object = MP.UI.BlindChip.small()
                                                }
                                            },
                                            {
                                                n = G.UIT.C,
                                                config = {
                                                    minw = 0.2,
                                                    minh = 0.2
                                                }
                                            },
                                            {
                                                n = G.UIT.O,
                                                config = {
                                                    object = MP.UI.BlindChip.big()
                                                }
                                            },
                                            {
                                                n = G.UIT.C,
                                                config = {
                                                    minw = 0.2,
                                                    minh = 0.2
                                                }
                                            },
                                            {
                                                n = G.UIT.O,
                                                config = {
                                                    object = MP.UI.BlindChip.random()
                                                }
                                            },
                                        }, { text_scale = 0.6 }),
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = {
                                    minw = 0.2,
                                    minh = 0.2
                                }
                            },
                        },
                    },
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm"
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm"
                                },
                                nodes = {
                                    MP.UI.BackgroundGrouping(localize("k_lives"), {
                                        {
                                            n = G.UIT.T,
                                            config = {
                                                text = "50",
                                                scale = 1.5,
                                                colour = G.C.UI.TEXT_LIGHT,
                                            }
                                        },
                                    }, { text_scale = 0.6 }),
                                }
                            },
                        }
                    }
                },
            },
            {
                n = G.UIT.R,
                config = {
                    align = "bm"
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_values_are_modifiable"),
                            scale = 0.4,
                            colour = G.C.UI.TEXT_LIGHT,
                        }
                    },
                },
            },
        }
    end
}):inject()
