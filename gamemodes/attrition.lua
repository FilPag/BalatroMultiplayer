MP.Gamemode({
    key = "attrition",
    get_blinds_by_ante = function(self, ante, choices)
        if ante >= MP.LOBBY.config.pvp_start_round then
            if not MP.LOBBY.config.normal_bosses then
                return choices.Small, choices.Big, "bl_mp_nemesis"
            else
                G.GAME.round_resets.pvp_blind_choices.Boss = true
            end
        end
        return choices.Small, choices.Big , choices.Boss 
    end,
}):inject()
