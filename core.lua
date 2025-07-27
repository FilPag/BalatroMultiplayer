local NativeFS = require("nativefs")
MP = SMODS.current_mod
G.FPS_CAP = 60
MP.LOBBY = {
	connected = false,
	temp_code = "",
	temp_seed = "",
	code = nil,
	type = "",
	config = {
		gold_on_life_loss = true,
		no_gold_on_round_loss = false,
		death_on_round_loss = true,
		different_seeds = false,
		starting_lives = 4,
		pvp_start_round = 2,
		timer_base_seconds = 150,
		timer_increment_seconds = 60,
		showdown_starting_antes = 3,
		ruleset = nil,
		gamemode = "gamemode_mp_attrition",
		custom_seed = "random",
		different_decks = false,
		back = "Red Deck",
		sleeve = "sleeve_casl_none",
		stake = 1,
		challenge = "",
		multiplayer_jokers = true,
		timer = true,
	},
	deck = {
		back = "Red Deck",
		sleeve = "sleeve_casl_none",
		stake = 1,
		challenge = "",
	},
	username = "Guest",
	ready_text = "Ready",
	blind_col = 1,
	players = {},
	local_player = {},
}
MP.FLAGS = {
	join_pressed = false,
}
MP.GAME = {}
MP.NETWORKING = {}
MP.UI = {}
MP.UI_UTILS = {}
MP.UIDEF = {}
MP.ACTIONS = {}
MP.INTEGRATIONS = {
	TheOrder = SMODS.Mods["Multiplayer"].config.integrations.TheOrder,
}
MP.player_state_manager = SMODS.load_file('networking/player_state_manager.lua', 'Multiplayer')()
G.C.MULTIPLAYER = HEX("AC3232")

function MP.load_mp_file(file)
	local chunk, err = SMODS.load_file(file, "Multiplayer")
	if chunk then
		local ok, func = pcall(chunk)
		if ok then
			return func
		else
			sendWarnMessage("Failed to process file: " .. func, "MULTIPLAYER")
		end
	else
		sendWarnMessage("Failed to find or compile file: " .. tostring(err), "MULTIPLAYER")
	end
	return nil
end

function MP.load_mp_dir(directory)
	local files = NFS.getDirectoryItems(MP.path .. "/" .. directory)
	local regular_files = {}

	for _, filename in ipairs(files) do
		local file_path = directory .. "/" .. filename
		if file_path:match(".lua$") then
			if filename:match("^_") then
				MP.load_mp_file(file_path)
			else
				table.insert(regular_files, file_path)
			end
		end
	end

	for _, file_path in ipairs(regular_files) do
		MP.load_mp_file(file_path)
	end
end

MP.load_mp_file("misc/utils.lua")
MP.load_mp_file("misc/insane_int.lua")

function MP.reset_game_states()
	sendDebugMessage("Resetting game states", "MULTIPLAYER")
	MP.GAME = {
		ready_blind = false,
		ready_blind_text = localize("b_ready"),
		processed_round_done = false,
		lives = 0,
		loaded_ante = 0,
		loading_blinds = false,
		comeback_bonus_given = true,
		comeback_bonus = 0,
		end_pvp = false,
		next_coop_boss = nil,
		players = {}, --[[@type table<string, {score: any, score_text: string, hands: number, location: string, skips: number, lives: number, sells: number, spent_last_shop: number, highest_score: any}>]]
		--[[enemy = {
			score = MP.INSANE_INT.empty(),
			score_text = "0",
			hands = 4,
			location = localize("loc_selecting"),
			skips = 0,
			lives = MP.LOBBY.config.starting_lives,
			sells = 0,
			sells_per_ante = {},
			spent_in_shop = {},
			highest_score = MP.INSANE_INT.empty(),
		}, --]]
		location = "loc_selecting",
		next_blind_context = nil,
		ante_key = tostring(math.random()),
		antes_keyed = {},
		prevent_eval = false,
		misprint_display = "",
		spent_total = 0,
		spent_before_shop = 0,
		highest_score = MP.INSANE_INT.empty(),
		timer = MP.LOBBY.config.timer_base_seconds,
		timer_started = false,
		real_money = 0,
		ce_cache = false,
		furthest_blind = 0,
		pincher_index = -3,
		pincher_unlock = false,
		asteroids = 0,
		pizza_discards = 0,
		wait_for_enemys_furthest_blind = false,
		disable_live_and_timer_hud = false,
		stats = {
			reroll_count = 0,
			reroll_cost_total = 0,
			-- Add more stats here in the future
		},
	}

	MP.LOBBY.ready_text = localize("b_ready")
	MP.LOBBY.ready_to_start = false
end

MP.reset_game_states()

MP.username = MP.UTILS.get_username()
MP.blind_col = MP.UTILS.get_blind_col()

if not SMODS.current_mod.lovely then
	G.E_MANAGER:add_event(Event({
		no_delete = true,
		trigger = "immediate",
		blockable = false,
		blocking = false,
		func = function()
			if G.MAIN_MENU_UI then
				MP.UTILS.overlay_message(
					MP.UTILS.wrapText(
						"Your Multiplayer Mod is not loaded correctly, make sure the Multiplayer folder does not have an extra Multiplayer folder around it.",
						50
					)
				)
				return true
			end
		end,
	}))
	return
end

SMODS.Atlas({
	key = "modicon",
	path = "modicon.png",
	px = 34,
	py = 34,
})

MP.load_mp_dir("compatibility")

MP.load_mp_dir("objects/editions")
MP.load_mp_dir("objects/enhancements")
MP.load_mp_dir("objects/stickers")
MP.load_mp_dir("objects/blinds")
MP.load_mp_dir("objects/decks")
MP.load_mp_dir("objects/jokers")
MP.load_mp_dir("objects/consumables")
MP.load_mp_dir("objects/challenges")
MP.load_mp_dir("gamemodes")
MP.load_mp_dir("rulesets")
MP.load_mp_dir("function_overrides")
MP.apply_rulesets()

MP.load_mp_dir("ui")
MP.load_mp_dir("ui/generic")
MP.load_mp_dir("ui/game")
MP.load_mp_dir("ui/lobby")
MP.load_mp_dir("ui/main_menu")

MP.load_mp_file("networking/action_handlers.lua")
MP.load_mp_file("networking/client_action_definitions.lua")
MP.load_mp_file("networking/player_state_manager.lua")


MP.load_mp_file("misc/disable_restart.lua")
MP.load_mp_file("misc/mod_hash.lua")

local restart_game_ref = SMODS.restart_game
function SMODS.restart_game()
  sendDebugMessage("Restarting game from Multiplayer Mod", "MULTIPLAYER")
  Client.send("disconnect")
  Client.send("exit")
  MP.NETWORKING_THREAD:wait() -- Wait for the networking thread to finish before restarting
  restart_game_ref()
end

local file_path = SMODS.current_mod.path .. 'networking\\socket.lua'
file_path = file_path:gsub("/", "\\")
local thread_code = NativeFS.read(file_path)
MP.NETWORKING_THREAD = love.thread.newThread(thread_code)

love.errorhandler_ref = love.errorhandler
function love.errorhandler(msg, traceback)
    if MP.NETWORKING_THREAD then
        local uiToNetworkChannel = love.thread.getChannel("uiToNetwork")
        uiToNetworkChannel:push("exit")
        
        -- Wait for thread to finish
        MP.NETWORKING_THREAD:wait()
        print("Network thread safely stopped")
    end
    return love.errorhandler_ref(msg, traceback)
end


MP.NETWORKING_THREAD:start(SMODS.Mods["Multiplayer"].config.server_url, SMODS.Mods["Multiplayer"].config.server_port)
MP.ACTIONS.connect()