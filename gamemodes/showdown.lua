MP.Gamemode({
    key = "showdown",
    get_blinds_by_ante = function(self, ante, choices)
        if ante >= MP.LOBBY.config.showdown_starting_antes then
            return "bl_mp_nemesis", "bl_mp_nemesis", "bl_mp_nemesis"
        end
        return choices.Small, choices.Big , choices.Boss 
    end,
}):inject()
