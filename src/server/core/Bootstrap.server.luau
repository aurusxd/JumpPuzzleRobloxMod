--!strict
-- server/core/Bootstrap.server.luau
-- Server entry point: registers and boots all services (tech.md §3)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Net = require(ReplicatedStorage.Shared.Net.Net)
local ServiceLocator = require(script.Parent.ServiceLocator)
local DataService = require(script.Parent.Parent.data.DataService)

-- 1. Setup network remotes
Net.setup()

-- 2. Register services
ServiceLocator.register("DataService", DataService)

-- 3. Init phase (dependency injection)
ServiceLocator.initAll()

-- 4. Start phase (begin listening)
ServiceLocator.startAll()

-- 5. Cleanup on player leave
Players.PlayerRemoving:Connect(function(player: Player)
	Net.cleanupPlayer(player)
end)

print("[Bootstrap] Server started")
