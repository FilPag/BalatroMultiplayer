local unpack = table.unpack or unpack -- this is to support both Lua 5.1 and 5.2+


local function all_players_same_order_config(players)
  if not players or #players == 0 then return true end
  local first_order = MP.UTILS.parse_Hash(players[1].modHash).theOrder
  for i = 2, #players do
    local p_order = MP.UTILS.parse_Hash(players[i].modHash).theOrder
    if p_order ~= first_order then
      return false
    end
  end
  return true
end

local function check_player_configs(player)
  if player and player.isCached == false then
    return MP.UTILS.wrapText(
      string.format(localize("k_warning_cheating"), MP.UTILS.random_message()),
      100
    ), SMODS.Gradients.warning_text
  end
  if player and player.config and player.config.unlocked == false then
    return localize("k_warning_nemesis_unlock"), SMODS.Gradients.warning_text
  end
end

local function get_lobby_text()
  local players = MP.LOBBY.players

  if not players or #players == 0 then
    return ""
  end

  if not all_players_same_order_config(players) then
    return localize("k_warning_no_order"), SMODS.Gradients.warning_text
  end

  for i, player in ipairs(players) do
    if player.id ~= MP.LOBBY.id then
      local msg, col = check_player_configs(player)
      if msg then return msg, col end
    end
  end

  if not SMODS.Mods["Multiplayer"].config.unlocked then
    return localize("k_warning_unlock_profile"), SMODS.Gradients.warning_text
  end

  -- Remove the mod hash warning from main warning display area since it's shown
  -- alongside critical warnings (cheating, compatibility issues). This makes users
  -- learn to ignore all warnings. Instead, we should indicate hash differences
  -- through other UI elements like colored usernames or separate indicators.
  -- The hash check itself remains useful for debugging but shouldn't be presented
  -- as a blocking warning alongside serious compatibility issues.
  -- steph

  -- TODO : Revisit this logic if we want to reintroduce mod hash warnings as colour or something
  --[[if players and #players > 1 then
		local modHash = players[1].modHash
		for i = 2, #players do
			if players[i].modHash ~= modHash then
				return localize("k_mod_hash_warning"), G.C.UI.TEXT_LIGHT
			end
		end
	end --]]

  -- ???: What is this supposed to accomplish?
  if MP.LOBBY.username == "Guest" then
    return localize("k_set_name"), G.C.UI.TEXT_LIGHT
  end

  return " ", G.C.UI.TEXT_LIGHT
end

local function create_player_nodes(players, text_scale)
  local player_nodes = {}
  if #players == 0 then return player_nodes end
  for i, player in ipairs(players or {}) do
    local player_row = {
      n = G.UIT.R,
      config = {
        padding = 0.1,
        align = "cm",
      },
      nodes = {
        {
          n = G.UIT.T,
          config = {
            ref_table = player,
            ref_value = "username",
            shadow = true,
            scale = text_scale * 0.8,
            colour = G.C.UI.TEXT_LIGHT,
          },
        },
        {
          n = G.UIT.B,
          config = {
            w = 0.1,
            h = 0.1,
            colour = G.C.ORANGE,
          },
        },
      },
    }
    if player.modHash then
      table.insert(player_row.nodes, UIBox_button({
        id = "player_hash_" .. tostring(i),
        button = "view_player_hash",
        label = { hash(player.modHash) },
        minw = 0.75,
        minh = 0.3,
        scale = 0.25,
        shadow = false,
        colour = G.C.PURPLE,
        col = true,
        ref_table = { index = i }
      }))
    end
    table.insert(player_nodes, player_row)
  end
  return player_nodes
end

function G.UIDEF.create_UIBox_lobby_menu()
	local text_scale = 0.45
	local back = MP.LOBBY.config.different_decks and MP.LOBBY.deck.back or MP.LOBBY.config.back
	local stake = MP.LOBBY.config.different_decks and MP.LOBBY.deck.stake or MP.LOBBY.config.stake

	local t = {
		n = G.UIT.ROOT,
		config = {
			align = "cm",
			colour = G.C.CLEAR,
		},
		nodes = {
			{
				n = G.UIT.C,
				config = {
					align = "bm",
				},
				nodes = {
					MP.UI.lobby_status_display(),
					{
						n = G.UIT.R,
						config = {
							align = "cm",
							padding = 0.2,
							r = 0.1,
							emboss = 0.1,
							colour = G.C.L_BLACK,
							mid = true,
						},
						nodes = {
							MP.UI.create_lobby_main_button(text_scale),
							{
								n = G.UIT.C,
								config = {
									align = "cm",
								},
								nodes = {
									not MP.LOBBY.config.forced_config and UIBox_button({
										button = "lobby_options",
										colour = G.C.ORANGE,
										minw = 3.15,
										minh = 1.35,
										label = {
											localize("b_lobby_options"),
										},
										scale = text_scale * 1.2,
										col = true,
									}) or nil,
									MP.UI.create_spacer(),
									MP.UI.create_lobby_deck_button(text_scale, back, stake),
									MP.UI.create_spacer(),
									MP.UI.create_players_section(text_scale),
									MP.UI.create_spacer(),
									MP.UI.create_lobby_code_buttons(text_scale),
								},
							},
						},
					},
				},
			},
		},
	}
	return t
end