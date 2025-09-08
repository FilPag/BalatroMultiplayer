MP.HOOKS = {}

MP.HOOKS.on_hand_played = function()
  if not MP.LOBBY.code then return end
  local score = SMODS.calculate_round_score()
  G.E_MANAGER:add_event(Event({
    blocking = false,
    blockable = true,
    func = function()
      MP.ACTIONS.play_hand(score, G.GAME.current_round.hands_left)
      return true
    end
  }))
end

SMODS.current_mod.calculate = function(self, context)
  if context.after then MP.HOOKS.on_hand_played() end
end
