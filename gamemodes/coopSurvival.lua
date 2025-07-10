MP.Gamemode({
    key = "coopSurvival",
    get_blinds_by_ante = function(self, ante, choices)
        if MP.LOBBY.isHost then
            MP.ACTIONS.set_Boss(choices.Boss)
        end

        return choices.Small, choices.Big , choices.Boss 
    end,
}):inject()
