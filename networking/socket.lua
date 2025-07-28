-- Multiplayer networking thread
local CONFIG_URL, CONFIG_PORT = ...
local json = require("json")
local socket = require("socket")

-- State
local client = nil
local isConnected = false
local shouldExit = false
local lastKeepAlive = 0
local retryCount = 0

-- Constants
local KEEP_ALIVE_INTERVAL = 7
local RETRY_TIMEOUT = 3
local MAX_RETRIES = 3
local SLEEP_TIME = 0.2
local CONNECTION_TIMEOUT = 10

-- Channels
local networkToUi = love.thread.getChannel("networkToUi")
local uiToNetwork = love.thread.getChannel("uiToNetwork")

-- Helper functions
local function sendError(message)
	local errorMsg = { action = "error", message = message }
	networkToUi:push(json.encode(errorMsg))
end

local function sendDisconnected(reason)
	local disconnectedMsg = { action = "disconnected", message = reason }
	networkToUi:push(json.encode(disconnectedMsg))
end

local function closeConnection()
	if client then
		client:close()
		client = nil
	end
	isConnected = false
	retryCount = 0
end

local function connect()
	closeConnection()
	
	client = socket.tcp()
	if not client then
		sendError("Failed to create TCP socket")
		return false
	end

	-- Set short timeout for connection attempt to avoid blocking
	client:settimeout(CONNECTION_TIMEOUT)
	client:setoption("tcp-nodelay", true)
	
	local result, err = client:connect(CONFIG_URL, CONFIG_PORT)
	if result ~= 1 then
		sendError("Failed to connect to multiplayer server: " .. (err or "unknown error"))
		closeConnection()
		return false
	end
	
	client:settimeout(0) -- Non-blocking mode
	isConnected = true
	lastKeepAlive = os.time()
	return true
end

local function sendMessage(message)
	if not client or not isConnected then
		return false
	end
	
	local success, err = client:send(message .. "\n")
	if not success then
		if err == "closed" then
			isConnected = false
		end
		return false
	end
	return true
end

local function processMainThreadMessages()
	-- Process multiple messages per cycle to prevent queue buildup
	local maxMessages = 10
	local processed = 0
	
	while processed < maxMessages do
		local msg = uiToNetwork:pop()
		if not msg then break end
		
		processed = processed + 1
		
		if msg == "connect" then
			connect()
		elseif msg == "disconnect" then
			closeConnection()
		elseif msg == "exit" then
			closeConnection()
			shouldExit = true
			break -- Exit immediately on exit command
		else
			sendMessage(msg)
		end
	end
end

local function processNetworkMessages()
	if not client or not isConnected then return end
	
	-- Process multiple packets per cycle to prevent message buildup
	local maxPackets = 10
	local processed = 0
	
	while processed < maxPackets do
		local data, err = client:receive()
		if data then
			lastKeepAlive = os.time()
			networkToUi:push(data)
			processed = processed + 1
		elseif err == "closed" then
			isConnected = false
			sendDisconnected("Connection closed by server")
			break
		else
			-- No more data available (would block), exit loop
			break
		end
	end
end

local function handleKeepAlive()
	if not isConnected then return end
	
	local currentTime = os.time()
	local timeSinceLastMessage = currentTime - lastKeepAlive
	
	if timeSinceLastMessage >= KEEP_ALIVE_INTERVAL then
		retryCount = retryCount + 1
		
		if retryCount > MAX_RETRIES then
			closeConnection()
			sendDisconnected("Connection closed due to inactivity")
			return
		end
		
		local keepAliveMsg = json.encode({ action = "k" })
		if not sendMessage(keepAliveMsg) then
			closeConnection()
			sendDisconnected("Failed to send keep-alive")
		else
			lastKeepAlive = currentTime
		end
	end
end

-- Main loop
while not shouldExit do
	processMainThreadMessages()
	processNetworkMessages()
	handleKeepAlive()
	socket.sleep(SLEEP_TIME)
end
