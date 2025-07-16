local blind_change_colourref = Blind.change_colour
function Blind:change_colour(blind_col) -- ensures that small/big blinds have proper colouration
  local small = false
  if self.config.blind.key == 'bl_mp_nemesis' then
    local blind_key = MP.UTILS.get_nemesis_key()
    if blind_key == "bl_small" or blind_key == "bl_big" then
      small = true
    end
  end
  local boss = self.boss
  if small then self.boss = false end
  blind_change_colourref(self, blind_col)
  self.boss = boss
end

local blind_set_blindref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
  -- Adjust blind multiplier for coop survival mode
  if blind and MP.LOBBY.code and MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and blind.boss then
    blind.mult = blind.mult * #MP.LOBBY.players
    MP.player_state_manager.reset_scores()
    G.GAME.chips = 0
  end

  blind_set_blindref(self, blind, reset, silent)

  -- Special handling for nemesis blind
  if blind and blind.key == 'bl_mp_nemesis' then
    local boss = true
    local showdown = false
    local blind_key = MP.UTILS.get_nemesis_key()
    if blind_key == "bl_small" or blind_key == "bl_big" then
      boss = false
    end
    if blind_key == "bl_final_heart" then
      showdown = true
    end
    G.ARGS.spin.real = (G.SETTINGS.reduced_motion and 0 or 1) * (boss and (showdown and 0.5 or 0.25) or 0)
  end
end

local ease_background_colour_blindref = ease_background_colour_blind
function ease_background_colour_blind(state, blind_override) -- handles background
  local blindname = ((blind_override or (G.GAME.blind and G.GAME.blind.name ~= '' and G.GAME.blind.name)) or 'Small Blind')
  local blindname = (blindname == '' and 'Small Blind' or blindname)
  if blindname == "bl_mp_nemesis" then
    blind_override = MP.UTILS.get_nemesis_key()
    for k, v in pairs(G.P_BLINDS) do
      if blind_override == k then
        blind_override = v.name
      end
    end
  end
  return ease_background_colour_blindref(state, blind_override)
end

local function reset_blind_HUD()
  if MP.LOBBY.code then
    G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object.config.string =
    { { ref_table = G.GAME.blind, ref_value = "loc_name" } }
    G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:update_text()
    G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_table = G.GAME.blind
    G.HUD_blind:get_UIE_by_ID("HUD_blind_count").config.ref_value = "chip_text"
    G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[1].children[1].config.text =
        localize("ph_blind_score_at_least")
    G.HUD_blind:get_UIE_by_ID("HUD_blind").children[2].children[2].children[2].children[3].children[1].config.text =
        localize("ph_blind_reward")
    G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object.config.string =
    { { ref_table = G.GAME.current_round, ref_value = "dollars_to_be_earned" } }
    G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object:update_text()
  end
end

local blind_defeat_ref = Blind.defeat
function Blind:defeat(silent)
  blind_defeat_ref(self, silent)
  reset_blind_HUD()
end

local blind_disable_ref = Blind.disable
function Blind:disable()
  if MP.is_online_boss() and not (G.GAME.blind and G.GAME.blind.name == 'Verdant Leaf') then -- hackfix to make verdant work properly
    return
  end
  blind_disable_ref(self)
end

G.FUNCS.multiplayer_blind_chip_UI_scale = function(e)
  local score_ref = MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" and MP.GAME.coop or MP.UTILS.get_nemesis()

  if not score_ref or not score_ref.score then
    if score_ref then score_ref.score_text = "" end
    return
  end

  local new_score_text = MP.INSANE_INT.to_string(score_ref.score)
  if G.GAME.blind and score_ref.score and score_ref.score_text ~= new_score_text then
    if not MP.INSANE_INT.greater_than(score_ref.score, MP.INSANE_INT.create(0, G.E_SWITCH_POINT, 0)) then
      e.config.scale = scale_number(score_ref.score.coeffiocient, 0.7, 100000)
    end
    score_ref.score_text = new_score_text
  end
end
