-- Multiplayer networking thread
local CONFIG_URL, CONFIG_PORT, msgpack_path = ...
local socket = require("socket")

-- MessagePack support - use SMODS loader in thread context
local NativeFS = require("nativefs")
local msgpack = NativeFS.load(msgpack_path)()

-- State
local client = nil
local isConnected = false
local shouldExit = false
local lastKeepAlive = 0

-- Constants
local KEEP_ALIVE_INTERVAL = 7
local CONNECTION_TIMEOUT_INTERVAL = 30 -- Simplified: just disconnect after 30s of no activity
local SLEEP_TIME = 0.1
local CONNECTION_TIMEOUT = 10

-- Channels
local networkToUi = love.thread.getChannel("networkToUi")
local uiToNetwork = love.thread.getChannel("uiToNetwork")

-- Message reception state
local messageState = {
	header = "",
	body = "",
	expectedLength = 0,
	receivingHeader = true
}

-- Helper functions
local function sendToUi(action, message)
	networkToUi:push({ action = action, message = message })
end

local function sendError(message)
	sendToUi("error", message)
end

local function sendDisconnected(reason)
	sendToUi("disconnected", reason)
end

local function resetMessageState()
	messageState.header = ""
	messageState.body = ""
	messageState.expectedLength = 0
	messageState.receivingHeader = true
end

local function closeConnection()
	if client then
		client:close()
		client = nil
	end
	isConnected = false
	resetMessageState()
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

local function createHeader(length)
	return string.char(
		math.floor(length / 16777216) % 256, -- (length >> 24) & 0xFF
		math.floor(length / 65536) % 256,  -- (length >> 16) & 0xFF
		math.floor(length / 256) % 256,    -- (length >> 8) & 0xFF
		length % 256                       -- length & 0xFF
	)
end

local function sendMessage(message)
	if not client or not isConnected then
		return false
	end

	-- Encode with MessagePack
	local packed = msgpack.pack(message)
	local header = createHeader(#packed)

	local success, err = client:send(header .. packed)
	if not success then
		if err == "closed" then
			isConnected = false
		end
		return false
	end
	return true
end

local function processMainThreadMessages(msg)
	if msg == "connect" then
		connect()
	elseif msg == "disconnect" then
		closeConnection()
	elseif msg == "exit" then
		closeConnection()
		shouldExit = true
		return
	else
		local success = sendMessage(msg)
		if not success then
			closeConnection()
			sendDisconnected("Failed to send message, connection lost")
		else
			lastKeepAlive = os.time()
		end
	end
end

local function handleNetworkError(err, context)
	if err == "closed" then
		isConnected = false
		sendDisconnected("Connection closed by server")
		return true -- break
	elseif err == "timeout" then
		return false -- continue
	else
		sendError("Network error " .. context .. ": " .. (err or "unknown"))
		return true -- break
	end
end

local function processNetworkMessages()
	if not client or not isConnected then return end

	local maxPackets = 10
	local processed = 0
	local MAX_MESSAGE_SIZE = 1048576 -- 1MB limit

	while processed < maxPackets do
		if messageState.receivingHeader then
			-- Try to receive remaining header bytes
			local needed = 4 - #messageState.header
			local chunk, err = client:receive(needed)

			if chunk then
				messageState.header = messageState.header .. chunk

				if #messageState.header == 4 then
					-- Complete header received, decode length
					local b1, b2, b3, b4 = messageState.header:byte(1, 4)
					messageState.expectedLength = b1 * 16777216 + b2 * 65536 + b3 * 256 + b4

					-- Validate message length
					if messageState.expectedLength <= 0 or messageState.expectedLength > MAX_MESSAGE_SIZE then
						sendError("Invalid message length: " .. messageState.expectedLength)
						closeConnection()
						sendDisconnected("Protocol violation: invalid message size")
						break
					end

					-- Switch to receiving message body
					messageState.receivingHeader = false
					messageState.header = ""
				end
			elseif err == "timeout" then
				-- No more data available right now, continue to other processing
				break
			elseif handleNetworkError(err, "reading header") then
				break
			end
		else
			-- Try to receive remaining message body bytes
			local needed = messageState.expectedLength - #messageState.body
			local chunk, err = client:receive(needed)

			if chunk then
				messageState.body = messageState.body .. chunk

				if #messageState.body == messageState.expectedLength then
					-- Complete message received
					lastKeepAlive = os.time()

					-- Decode MessagePack
					local ok, decoded = pcall(msgpack.unpack, messageState.body)
					if ok and decoded then
						local success = networkToUi:push(decoded)
						if not success then
							print("WARNING: networkToUi channel full, dropping message")
							break
						end
					else
						sendError("Failed to decode MessagePack message: " .. tostring(decoded))
					end

					-- Reset for next message
					resetMessageState()
					processed = processed + 1
				end
			elseif err == "timeout" then
				-- No more data available right now, continue to other processing
				break
			elseif handleNetworkError(err, "reading message") then
				break
			end
		end
	end
end

local function handleKeepAlive()
	if not isConnected then return end

	local timeSinceLastMessage = os.time() - lastKeepAlive

	-- Send keep-alive every KEEP_ALIVE_INTERVAL seconds
	if timeSinceLastMessage >= KEEP_ALIVE_INTERVAL then
		if sendMessage({ action = "k" }) then
			lastKeepAlive = os.time()
		else
			closeConnection()
			sendDisconnected("Failed to send keep-alive")
		end
	end

	-- Disconnect if no activity for too long
	if timeSinceLastMessage >= CONNECTION_TIMEOUT_INTERVAL then
		closeConnection()
		sendDisconnected("Connection closed due to inactivity")
	end
end

-- Main loop
while not shouldExit do
	-- Block until UI message or timeout
	local msg = uiToNetwork:demand(SLEEP_TIME)

	if msg then
		-- Process the UI message
		processMainThreadMessages(msg)
	end

	-- Check for network activity (non-blocking)
	local ready = socket.select({ client }, nil, 0)
	if ready and #ready > 0 then
		processNetworkMessages()
	end

	handleKeepAlive()
end
