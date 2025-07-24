local add_round_eval_rowref = add_round_eval_row
function add_round_eval_row(config) -- if i could post a skull emoji i would, wtf is this (cashout screen)
	if config.name == 'blind1' and G.GAME.blind.config.blind.key == "bl_mp_nemesis" then
		G.P_BLINDS["bl_mp_nemesis"].atlas = 'mp_player_blind_col'
		G.GAME.blind.pos = G.P_BLINDS[MP.UTILS.get_nemesis_key()].pos -- this one is getting reset so no need to bother
		add_round_eval_rowref(config)
		G.E_MANAGER:add_event(Event({
			trigger = 'before',
			delay = 0.0,
			func = function()
				G.P_BLINDS["bl_mp_nemesis"].atlas = "mp_player_blind_chip" -- lmao
				return true
			end,
		}))
	else
		add_round_eval_rowref(config)
	end
end