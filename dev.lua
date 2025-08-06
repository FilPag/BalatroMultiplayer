G.FPS_CAP = 60
MP.DEV = {}

local lock_path = os.getenv("HOME") .. "/.balatro_multiplayer.lock"
local file = io.open(lock_path, "r")
local created_lock = false
if file then
    file:close()
    love.window.setMode(1200, 900, {display = 1})
else
    file = io.open(lock_path, "w")
    file:write("locked")
    created_lock = true
    file:close()

    love.window.setMode(1200, 900, {display = 2})
end

local love_errorhandler_ref = love.errorhandler
function love.errorhandler(msg, traceback)
    if created_lock then
        os.remove(lock_path)
    end
    return love_errorhandler_ref(msg, traceback)
end

local restart_game_ref = SMODS.restart_game
function SMODS.restart_game()
  if created_lock then
    os.remove(lock_path)
  end
  restart_game_ref()
end

local quit_ref = love.event.quit
function love.event.quit()
    if created_lock then
        os.remove(lock_path)
    end
    quit_ref()
end