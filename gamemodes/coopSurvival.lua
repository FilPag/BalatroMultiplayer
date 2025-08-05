MP.Gamemode({
    key = "coopSurvival",
    get_blinds_by_ante = function(self, ante, choices)
        if MP.LOBBY.is_host then
            local config = G.P_BLINDS[tostring(choices.Boss)]
            local chips = get_blind_amount(G.GAME.round_resets.ante) * config.mult * G.GAME.starting_params.ante_scaling
            chips = MP.UI_UTILS.get_mp_blind_amount(config, chips)
            MP.ACTIONS.set_Boss(choices.Boss, chips)
        elseif MP.next_coop_boss then
            choices.Boss = MP.next_coop_boss
            MP.next_coop_boss = nil
        end

        return choices.Small, choices.Big, choices.Boss
    end,
}):inject()
