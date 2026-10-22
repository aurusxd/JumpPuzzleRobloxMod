--!strict
-- shared/Net/Net.luau
-- Typed wrapper over RemoteEvent with validation and rate limiting (tech.md §2, §10)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Contracts = require(script.Parent.Contracts)
local RateLimiter = require(script.Parent.Parent.Util.RateLimiter)

local Net = {}

type RemoteMap = { [string]: RemoteEvent }

local remotes: RemoteMap = {}
local rateLimiters: { [string]: RateLimiter.RateLimiter } = {}
local isServer = RunService:IsServer()

-- Initialize all remotes from contracts
function Net.setup()
	local folder: Folder

	if isServer then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage

		for _, contract in Contracts :: any do
			if typeof(contract) == "table" and contract.name then
				local remote = Instance.new("RemoteEvent")
				remote.Name = contract.name
				remote.Parent = folder
				remotes[contract.name] = remote

				-- Set up rate limiters for client->server remotes
				if contract.direction == "ClientToServer" and contract.rateLimit then
					rateLimiters[contract.name] = RateLimiter.new(contract.rateLimit)
				end
			end
		end
	else
		folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
		for _, remote in folder:GetChildren() do
			if remote:IsA("RemoteEvent") then
				remotes[remote.Name] = remote
			end
		end
	end
end

-- Server: listen for client->server events with rate limiting
function Net.onServerEvent(contractName: string, callback: (player: Player, payload: any) -> ())
	assert(isServer, "Net.onServerEvent can only be called on server")
	local remote = remotes[contractName]
	assert(remote, `Remote not found: {contractName}`)

	remote.OnServerEvent:Connect(function(player: Player, payload: any)
		-- Rate limit check
		local limiter = rateLimiters[contractName]
		if limiter and not limiter:check(player) then
			warn(`[Net] Rate limited: {player.Name} on {contractName}`)
			return
		end

		callback(player, payload)
	end)
end

-- Server: fire event to specific client
function Net.fireClient(contractName: string, player: Player, payload: any)
	assert(isServer, "Net.fireClient can only be called on server")
	local remote = remotes[contractName]
	assert(remote, `Remote not found: {contractName}`)
	remote:FireClient(player, payload)
end

-- Server: fire event to all clients
function Net.fireAllClients(contractName: string, payload: any)
	assert(isServer, "Net.fireAllClients can only be called on server")
	local remote = remotes[contractName]
	assert(remote, `Remote not found: {contractName}`)
	remote:FireAllClients(payload)
end

-- Client: fire event to server
function Net.fireServer(contractName: string, payload: any)
	assert(not isServer, "Net.fireServer can only be called on client")
	local remote = remotes[contractName]
	assert(remote, `Remote not found: {contractName}`)
	remote:FireServer(payload)
end

-- Client: listen for server->client events
function Net.onClientEvent(contractName: string, callback: (payload: any) -> ())
	assert(not isServer, "Net.onClientEvent can only be called on client")
	local remote = remotes[contractName]
	assert(remote, `Remote not found: {contractName}`)

	remote.OnClientEvent:Connect(function(payload: any)
		callback(payload)
	end)
end

-- Cleanup rate limiter state when a player leaves
function Net.cleanupPlayer(player: Player)
	for _, limiter in rateLimiters do
		limiter:cleanup(player)
	end
end

return Net
