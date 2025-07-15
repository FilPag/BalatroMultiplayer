MP.Gamemode({
    key = "coopSurvival",
    get_blinds_by_ante = function(self, ante, choices)

        if MP.LOBBY.isHost then
            MP.ACTIONS.set_Boss(choices.Boss)
        elseif MP.next_coop_boss then
            choices.Boss = MP.next_coop_boss
            MP.next_coop_boss = nil
        end

        return choices.Small, choices.Big , choices.Boss 
    end,
}):inject()
