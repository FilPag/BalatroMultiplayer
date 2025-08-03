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

local blind_set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)

  blind_set_blind_ref(self, blind, reset, silent)

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
  if blindname == "bl_mp_nemesis" and MP.is_online_boss() then
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
  if not (MP.LOBBY and MP.LOBBY.code) then
    return
  end

  local score_ref
  if MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival" then
    score_ref = MP.GAME.coop
  else
    local nemesis = MP.UTILS.get_nemesis()
    if not nemesis then
      return -- Exit early if no nemesis found
    end
    score_ref = nemesis.game_state
  end

  if not score_ref or not score_ref.score then
    if score_ref then score_ref.score_text = "" end
    return
  end

  local new_score_text = number_format(score_ref.score)
  if G.GAME.blind and score_ref.score and score_ref.score_text ~= new_score_text then
    score_ref.score_text = new_score_text
  end
end
