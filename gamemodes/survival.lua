MP.Gamemode({
    key = "survival",
    get_blinds_by_ante = function(self, ante, choices)
        return choices.Small, choices.Big , choices.Boss 
    end,
}):inject()
