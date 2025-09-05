MP.UTILS = {}

-- Credit to Steamo (https://github.com/Steamopollys/Steamodded/blob/main/core/core.lua)
function MP.UTILS.wrapText(text, maxChars)
	local wrappedText = ""
	local currentLineLength = 0

	for word in text:gmatch("%S+") do
		if currentLineLength + #word <= maxChars then
			wrappedText = wrappedText .. word .. " "
			currentLineLength = currentLineLength + #word + 1
		else
			wrappedText = wrappedText .. "\n" .. word .. " "
			currentLineLength = #word + 1
		end
	end

	return wrappedText
end

function MP.UTILS.get_array_index_by_value(options, value)
    for i, v in ipairs(options) do
        if v == value then
            return i
        end
    end
    return nil
end

function MP.UTILS.save_username(text)
  MP.username = text or "Guest"
	MP.ACTIONS.set_client_data()
	SMODS.Mods["Multiplayer"].config.username = text
end

function MP.UTILS.get_username()
	return SMODS.Mods["Multiplayer"].config.username
end

function MP.UTILS.save_blind_col(num)
	MP.ACTIONS.set_blind_col(num)
	SMODS.Mods["Multiplayer"].config.blind_col = num
end

function MP.UTILS.get_blind_col()
	return SMODS.Mods["Multiplayer"].config.blind_col
end

function MP.UTILS.blind_col_numtokey(num)
	local keys = {
		"tooth",
		"small",
		"big",
		"hook",
		"ox",
		"house",
		"wall",
		"wheel",
		"arm",
		"club",
		"fish",
		"psychic",
		"goad",
		"water",
		"window",
		"manacle",
		"eye",
		"mouth",
		"plant",
		"serpent",
		"pillar",
		"needle",
		"head",
		"flint",
		"mark",
	}
	return "bl_" .. keys[num]
end

function MP.UTILS.get_nemesis_key() -- calling this function assumes the user is currently in a multiplayer game
	-- Update to support n > 2 players
	local enemy = MP.UTILS.get_nemesis()
	local enemy_colour = enemy.profile.colour
	local ret = MP.UTILS.blind_col_numtokey(enemy_colour)

	if not enemy or not enemy.game_state.lives then
		return ret
	end

	if tonumber(enemy.game_state.lives) <= 1 and tonumber(MP.LOBBY.local_player.game_state.lives) <= 1 then
		if G.STATE ~= G.STATES.ROUND_EVAL then -- very messy fix that mostly works. breaks in a different way... but far harder to notice
			ret = "bl_final_heart"
		end
	end
	return ret
end

function MP.UTILS.string_split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function MP.UTILS.copy_to_clipboard(text)
	if G.F_LOCAL_CLIPBOARD then
		G.CLIPBOARD = text
	else
		love.system.setClipboardText(text)
	end
end

function MP.UTILS.get_from_clipboard()
	if G.F_LOCAL_CLIPBOARD then
		return G.F_LOCAL_CLIPBOARD
	else
		return love.system.getClipboardText()
	end
end

function MP.UTILS.overlay_message(message)
	G.SETTINGS.paused = true
	local message_table = MP.UTILS.string_split(message, "\n")
	local message_ui = {
		{
			n = G.UIT.R,
			config = {
				padding = 0.2,
				align = "cm",
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.8,
						shadow = true,
						text = "MULTIPLAYER",
						colour = G.C.UI.TEXT_LIGHT,
					},
				},
			},
		},
	}

	for _, v in ipairs(message_table) do
		table.insert(message_ui, {
			n = G.UIT.R,
			config = {
				padding = 0.1,
				align = "cm",
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.6,
						shadow = true,
						text = v,
						colour = G.C.UI.TEXT_LIGHT,
					},
				},
			},
		})
	end

	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.C,
					config = {
						padding = 0.2,
						align = "cm",
					},
					nodes = message_ui,
				},
			},
		}),
	})
end

function MP.UTILS.get_joker(key)
	if not G.jokers or not G.jokers.cards then
		return nil
	end
	for i = 1, #G.jokers.cards do
		if G.jokers.cards[i].ability.name == key then
			return G.jokers.cards[i]
		end
	end
	return nil
end

function MP.UTILS.get_phantom_joker(key)
	if not MP.shared or not MP.shared.cards then
		return nil
	end
	for i = 1, #MP.shared.cards do
		if
			MP.shared.cards[i].ability.name == key
			and MP.shared.cards[i].edition
			and MP.shared.cards[i].edition.type == "mp_phantom"
		then
			return MP.shared.cards[i]
		end
	end
	return nil
end

function MP.UTILS.run_for_each_joker(key, func)
	if not G.jokers or not G.jokers.cards then
		return
	end
	for i = 1, #G.jokers.cards do
		if G.jokers.cards[i].ability.name == key then
			func(G.jokers.cards[i])
		end
	end
end

function MP.UTILS.run_for_each_phantom_joker(key, func)
	if not MP.shared or not MP.shared.cards then
		return
	end
	for i = 1, #MP.shared.cards do
		if MP.shared.cards[i].ability.name == key then
			func(MP.shared.cards[i])
		end
	end
end

-- Credit to Cryptid devs for this function
local create_mod_badges_ref = SMODS.create_mod_badges
function SMODS.create_mod_badges(obj, badges)
	create_mod_badges_ref(obj, badges)
	if obj and obj.mp_credits then
		obj.mp_credits.art = obj.mp_credits.art or {}
		obj.mp_credits.idea = obj.mp_credits.idea or {}
		obj.mp_credits.code = obj.mp_credits.code or {}
		local function calc_scale_fac(text)
			local size = 0.9
			local font = G.LANG.font
			local max_text_width = 2 - 2 * 0.05 - 4 * 0.03 * size - 2 * 0.03
			local calced_text_width = 0
			-- Math reproduced from DynaText:update_text
			for _, c in utf8.chars(text) do
				local tx = font.FONT:getWidth(c) * (0.33 * size) * G.TILESCALE * font.FONTSCALE
					+ 2.7 * 1 * G.TILESCALE * font.FONTSCALE
				calced_text_width = calced_text_width + tx / (G.TILESIZE * G.TILESCALE)
			end
			local scale_fac = calced_text_width > max_text_width and max_text_width / calced_text_width or 1
			return scale_fac
		end
		if obj.mp_credits.art or obj.mp_credits.code or obj.mp_credits.idea then
			local scale_fac = {}
			local min_scale_fac = 1
			local strings = { "MULTIPLAYER" }
			for _, v in ipairs({ "art", "idea", "code" }) do
				if obj.mp_credits[v] then
					for i = 1, #obj.mp_credits[v] do
						strings[#strings + 1] =
							localize({ type = "variable", key = "a_mp_" .. v, vars = { obj.mp_credits[v][i] } })[1]
					end
				end
			end
			for i = 1, #strings do
				scale_fac[i] = calc_scale_fac(strings[i])
				min_scale_fac = math.min(min_scale_fac, scale_fac[i])
			end
			local ct = {}
			for i = 1, #strings do
				ct[i] = {
					string = strings[i],
				}
			end
			local mp_badge = {
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						config = {
							align = "cm",
							colour = G.C.MULTIPLAYER,
							r = 0.1,
							minw = 2 / min_scale_fac,
							minh = 0.36,
							emboss = 0.05,
							padding = 0.03 * 0.9,
						},
						nodes = {
							{ n = G.UIT.B, config = { h = 0.1, w = 0.03 } },
							{
								n = G.UIT.O,
								config = {
									object = DynaText({
										string = ct or "ERROR",
										colours = { obj.mp_credits and obj.mp_credits.text_colour or G.C.WHITE },
										silent = true,
										float = true,
										shadow = true,
										offset_y = -0.03,
										spacing = 1,
										scale = 0.33 * 0.9,
									}),
								},
							},
							{ n = G.UIT.B, config = { h = 0.1, w = 0.03 } },
						},
					},
				},
			}
			local function eq_col(x, y)
				for i = 1, 4 do
					if x[1] ~= y[1] then
						return false
					end
				end
				return true
			end
			for i = 1, #badges do
				if eq_col(badges[i].nodes[1].config.colour, G.C.MULTIPLAYER) then
					badges[i].nodes[1].nodes[2].config.object:remove()
					badges[i] = mp_badge
					break
				end
			end
		end
	end
end

function MP.UTILS.reverse_key_value_pairs(tbl, stringify_keys)
	local reversed_tbl = {}
	for k, v in pairs(tbl) do
		if stringify_keys then
			v = tostring(v)
		end
		reversed_tbl[v] = k
	end
	return reversed_tbl
end

function MP.UTILS.add_nemesis_info(info_queue)
	if not MP.LOBBY.code then return end

	local enemy_name = nil
	local my_id = MP.LOBBY.local_id

	-- Find the first player that is not the local user (by id)
	for _, player in pairs(MP.LOBBY.players or {}) do
		if player.profile.id ~= my_id then
			enemy_name = player.profile.username
			break
		end
	end

	-- Fallback if not found (single player or error)
	enemy_name = enemy_name or "?"

	info_queue[#info_queue + 1] = {
		set = "Other",
		key = "current_nemesis",
		vars = { enemy_name },
	}
end

function MP.UTILS.shallow_copy(t)
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = v
	end
	return copy
end

function MP.UTILS.get_deck_key_from_name(_name)
	for k, v in pairs(G.P_CENTERS) do
		if v.name == _name then
			return k
		end
	end
end

function MP.UTILS.merge_tables(t1, t2)
	local copy = MP.UTILS.shallow_copy(t1)
	for k, v in pairs(t2) do
		copy[k] = v
	end
	return copy
end

-- Pre-compile a reversed list of all the centers
local reversed_centers = nil

function MP.UTILS.card_to_string(card)
	if not card or not card.base or not card.base.suit or not card.base.value then
		return ""
	end

	if not reversed_centers then
		reversed_centers = MP.UTILS.reverse_key_value_pairs(G.P_CENTERS)
	end

	local suit = string.sub(card.base.suit, 1, 1)

	local rank_value_map = {
		["10"] = "T",
		Jack = "J",
		Queen = "Q",
		King = "K",
		Ace = "A",
	}
	local rank = rank_value_map[card.base.value] or card.base.value

	local enhancement = reversed_centers[card.config.center] or "none"
	local edition = card.edition and MP.UTILS.reverse_key_value_pairs(card.edition, true)["true"] or "none"
	local seal = card.seal or "none"

	local card_str = suit .. "-" .. rank .. "-" .. enhancement .. "-" .. edition .. "-" .. seal

	return card_str
end

function MP.UTILS.joker_to_string(card)
	if not card or not card.config or not card.config.center or not card.config.center.key then
		return ""
	end

	local edition = card.edition and MP.UTILS.reverse_key_value_pairs(card.edition, true)["true"] or "none"
	local eternal_or_perishable = "none"
	if card.ability then
		if card.ability.eternal then
			eternal_or_perishable = "eternal"
		elseif card.ability.perishable then
			eternal_or_perishable = "perishable"
		end
	end
	local rental = (card.ability and card.ability.rental) and "rental" or "none"

	local joker_string = card.config.center.key .. "-" .. edition .. "-" .. eternal_or_perishable .. "-" .. rental

	return joker_string
end

function MP.UTILS.unlock_check()
	local notFullyUnlocked = false

	for k, v in pairs(G.P_CENTER_POOLS.Joker) do
		if not v.unlocked then
			notFullyUnlocked = true
			break -- No need to keep checking once we know it's not fully unlocked
		end
	end

	return not notFullyUnlocked
end

function MP.UTILS.encrypt_ID()
	local encryptID = 1
	for key, center in pairs(G.P_CENTERS or {}) do
		if type(key) == "string" and key:match("^j_") then
			if center.cost and type(center.cost) == "number" then
				encryptID = encryptID + center.cost
			end
			if center.config and type(center.config) == "table" then
				encryptID = encryptID + MP.UTILS.sum_numbers_in_table(center.config)
			end
		elseif type(key) == "string" and key:match("^[cvp]_") then
			if center.cost and type(center.cost) == "number" then
				if center.cost == 0 then
					return 0
				end
				encryptID = encryptID + center.cost
			end
		end
	end
	for key, value in pairs(G.GAME.starting_params or {}) do
		if type(value) == "number" and value % 1 == 0 then
			encryptID = encryptID * value
		end
	end
	local day = tonumber(os.date("%d")) or 1
	encryptID = encryptID * day
	local gameSpeed = G.SETTINGS.GAMESPEED
	if gameSpeed then
		gameSpeed = gameSpeed * 16
		gameSpeed = gameSpeed + 7
		encryptID = encryptID + (gameSpeed / 1000)
	else
		encryptID = encryptID + 0.404
	end
	return encryptID
end

function MP.UTILS.parse_Hash(hash)
	-- Split hash string into parts by ';'
	local parts = {}
	for part in string.gmatch(hash, "([^;]+)") do
		table.insert(parts, part)
	end

	local config = {
		encryptID = nil,
		unlocked = nil,
		theOrder = nil,
		Mods = {},
	}

	-- Helper to parse a mod entry like "modname-version"
	local function parse_mod_entry(entry)
		local dash_pos = string.find(entry, "-")
		if dash_pos then
			local mod_name = string.sub(entry, 1, dash_pos - 1)
			local mod_version = string.sub(entry, dash_pos + 1)
			return mod_name, mod_version
		else
			return entry, nil
		end
	end

	for _, part in ipairs(parts) do
		local key, val = string.match(part, "([^=]+)=([^=]+)")
		if key == "encryptID" then
			config.encryptID = tonumber(val)
		elseif key == "unlocked" then
			config.unlocked = val == "true"
		elseif key == "theOrder" then
			config.TheOrder = val == "true"
		elseif key ~= "serversideConnectionID" then
			-- If not a key=value pair, treat as mod entry
			if not string.find(part, "=") then
				local mod_name, mod_version = parse_mod_entry(part)
				config.Mods[mod_name] = mod_version
			end
		end
	end

	return config
end

function MP.UTILS.sum_numbers_in_table(t)
	local sum = 0
	for k, v in pairs(t) do
		if type(v) == "number" then
			sum = sum + v
		elseif type(v) == "table" then
			sum = sum + MP.UTILS.sum_numbers_in_table(v)
		end
		-- ignore other types
	end
	return sum
end

function MP.UTILS.get_culled_pool(_type, _rarity, _legendary, _append)
	local pool = get_current_pool(_type, _rarity, _legendary, _append)
	local ret = {}
	for i, v in ipairs(pool) do
		if v ~= 'UNAVAILABLE' then
			ret[#ret+1] = v
		end
	end
	return ret
end

function MP.UTILS.bxor(a, b)
	local res = 0
	local bitval = 1
	while a > 0 and b > 0 do
		local a_bit = a % 2
		local b_bit = b % 2
		if a_bit ~= b_bit then
			res = res + bitval
		end
		bitval = bitval * 2
		a = math.floor(a / 2)
		b = math.floor(b / 2)
	end
	res = res + (a + b) * bitval
	return res
end

function MP.UTILS.encrypt_string(str)
	local hash = 2166136261
	for i = 1, #str do
		hash = MP.UTILS.bxor(hash, str:byte(i))
		hash = (hash * 16777619) % 2 ^ 32
	end
	return string.format("%08x", hash)
end

function MP.UTILS.server_connection_ID()
	local os_name = love.system.getOS()
	local raw_id

	if os_name == "Windows" then
		local ffi = require("ffi")

		ffi.cdef([[
		typedef unsigned long DWORD;
		typedef int BOOL;
		typedef const char* LPCSTR;

		BOOL GetVolumeInformationA(
			LPCSTR lpRootPathName,
			char* lpVolumeNameBuffer,
			DWORD nVolumeNameSize,
			DWORD* lpVolumeSerialNumber,
			DWORD* lpMaximumComponentLength,
			DWORD* lpFileSystemFlags,
			char* lpFileSystemNameBuffer,
			DWORD nFileSystemNameSize
		);
		]])

		local serial_ptr = ffi.new("DWORD[1]")
		local ok = ffi.C.GetVolumeInformationA("C:\\", nil, 0, serial_ptr, nil, nil, nil, 0)
		if ok ~= 0 then
			raw_id = tostring(serial_ptr[0])
		end
	end

	if not raw_id then
		raw_id = os.getenv("USER") or os.getenv("USERNAME") or os_name
	end

	return MP.UTILS.encrypt_string(raw_id)
end

function MP.UTILS.random_message()
	local messages = {
		localize("k_message1"),
		localize("k_message2"),
		localize("k_message3"),
		localize("k_message4"),
		localize("k_message5"),
		localize("k_message6"),
		localize("k_message7"),
		localize("k_message8"),
		localize("k_message9"),
	}
	return messages[math.random(1, #messages)]
end

-- From https://github.com/lunarmodules/Penlight (MIT license)
local function save_global_env()
	local env = {}
	env.hook, env.mask, env.count = debug.gethook()

	-- env.hook is "external hook" if is a C hook function
	if env.hook ~= "external hook" then
		debug.sethook()
	end

	env.string_mt = getmetatable("")
	debug.setmetatable("", nil)
	return env
end

-- From https://github.com/lunarmodules/Penlight (MIT license)
local function restore_global_env(env)
	if env then
		debug.setmetatable("", env.string_mt)
		if env.hook ~= "external hook" then
			debug.sethook(env.hook, env.mask, env.count)
		end
	end
end

local function STR_UNPACK_CHECKED(str)
	-- Code generated from STR_PACK should only return a table and nothing else
	if str:sub(1, 8) ~= "return {" then
		error('Invalid string header, expected "return {..."')
	end

	-- Protect against code injection by disallowing function definitions
	-- This is a very naive check, but hopefully won't trigger false positives
	if str:find("[^\"'%w_]function[^\"'%w_]") then
		error("Function keyword detected")
	end

	-- Load with an empty environment, no functions or globals should be available
	local chunk = assert(load(str, nil, "t", {}))
	local global_env = save_global_env()
	local success, str_unpacked = pcall(chunk)
	restore_global_env(global_env)
	if not success then
		error(str_unpacked)
	end

	return str_unpacked
end

function MP.UTILS.str_pack_and_encode(data)
	local str = STR_PACK(data)
	local str_compressed = love.data.compress("string", "gzip", str)
	local str_encoded = love.data.encode("string", "base64", str_compressed)
	return str_encoded
end

function MP.UTILS.str_decode_and_unpack(str)
	local success, str_decoded, str_decompressed, str_unpacked
	success, str_decoded = pcall(love.data.decode, "string", "base64", str)
	if not success then
		return nil, str_decoded
	end
	success, str_decompressed = pcall(love.data.decompress, "string", "gzip", str_decoded)
	if not success then
		return nil, str_decompressed
	end
	success, str_unpacked = pcall(STR_UNPACK_CHECKED, str_decompressed)
	if not success then
		return nil, str_unpacked
	end
	return str_unpacked
end

function MP.UTILS.get_standard_rulesets()
	local ret = {}
	for k, v in pairs(MP.Rulesets) do
		if v.standard then
			ret[#ret+1] = string.sub(v.key, 12, #v.key)
		end
	end
	return ret
end

function MP.UTILS.is_standard_ruleset()
	if MP.LOBBY.config.ruleset == nil then
		return false
	end
	for _, ruleset in ipairs(MP.UTILS.get_standard_rulesets()) do
		if MP.LOBBY.config.ruleset == "ruleset_mp_" .. ruleset then
			return true
		end
	end
	return false
end

function MP.UTILS.ease_score(score_table, new_score, delay)
	delay = delay or 0.3
	G.E_MANAGER:add_event(Event({
		trigger = 'ease',
		blocking = true,
		blockable = true,
		ref_table = score_table,
		ref_value = 'score',
		ease_to = new_score,
		delay = 0.5,
		func = (function(t) return math.floor(t) end)
	}))
end

-- Save current run and return as table
function MP.UTILS.MP_SAVE()
	local cardAreas = {}
	for k, v in pairs(G) do
		if (type(v) == "table") and v.is and v:is(CardArea) then
			local cardAreaSer = v:save()
			if cardAreaSer then cardAreas[k] = cardAreaSer end
		end
	end

	local tags = {}
	for k, v in ipairs(G.GAME.tags) do
		if (type(v) == "table") and v.is and v:is(Tag) then
			local tagSer = v:save()
			if tagSer then tags[k] = tagSer end
		end
	end

	local state = G.STATE
	if G.GAME.blind and G.GAME.blind.name == "bl_mp_nemesis" then
		state = G.STATES.NEW_ROUND
		G.GAME.blind.chips = 0
	end

	return {
		cardAreas = cardAreas,
		tags = tags,
		GAME = G.GAME,
		STATE = state,
		ACTION = G.action,
		BLIND = G.GAME.blind and G.GAME.blind:save() or nil,
		BACK = G.GAME.selected_back and G.GAME.selected_back:save() or nil,
		VERSION = G.VERSION,
	}
end

function MP.UTILS.is_coop()
	if not MP.LOBBY.code then return false end
	return MP.LOBBY.config.gamemode == "gamemode_mp_coopSurvival"
end

function MP.UTILS.is_local_player(player)
	if not player then
		sendErrorMessage("MP.UTILS.is_local_player called with nil player")
		return false
	end

	return player.profile.id == MP.LOBBY.local_player.profile.id
end

-- Returns the local player for the current client.
-- @param players table: array of player tables
-- @param my_id string: the id of the local player
function MP.UTILS.get_local_player()
	return MP.LOBBY.local_player.game_state
end

function MP.UTILS.get_local_player_lobby_data()
	return MP.LOBBY.local_player.profile
end

-- Returns the enemy player for the current client.
-- @param players table: array of player tables
-- @param my_id string: the id of the local player
function MP.UTILS.get_nemesis()
	if not MP.LOBBY.code then return nil end
	local players = MP.LOBBY.players
	local my_id = MP.LOBBY.local_player.profile.id

	if not players then error("MP.LOBBY.players is nil") end
	for i, player in pairs(players) do
		if player.profile.id and player.profile.id ~= my_id then
			return player
		end
	end
	return nil
end

function MP.UTILS.have_player_usernames_changed()
	if not MP.LOBBY.code then return false end

	local prev_usernames = MP.LOBBY._prev_usernames or {}
	local players = MP.LOBBY.players or {}

	if #prev_usernames ~= #players then
		return true
	end

	for i, player in pairs(players) do
		if prev_usernames[i] ~= player.username then
			return true
		end
	end

	return false
end

function MP.UTILS.get_weekly()
	return SMODS.Mods["Multiplayer"].config.weekly
end

function MP.UTILS.is_weekly(arg)
	return MP.UTILS.get_weekly() == arg and MP.LOBBY.config.ruleset == 'ruleset_mp_weekly'
end

function MP.UTILS.is_in_pvp_blind()
	if not G.GAME.blind then return false end

	local pvp_blinds = {
		["bl_mp_clash"] = true,
		["bl_mp_nemesis"] = true
	}

	return pvp_blinds[G.GAME.blind.config.blind.key] or false
end

function MP.UTILS.is_in_online_blind()
	if not G.GAME.blind then return false end

	if MP.UTILS.is_coop() and G.GAME.blind.boss then
		return true
	end

	return MP.UTILS.is_in_pvp_blind()
end

function MP.UTILS.should_display_ready_check(key, type)
		local pvp_blinds = {
			["bl_mp_clash"] = true,
			["bl_mp_nemesis"] = true
		}

		if MP.UTILS.is_coop() and type == "Boss" then
			return true
		end

		return pvp_blinds[key] or false
	end
