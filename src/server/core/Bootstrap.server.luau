--!strict
-- server/core/Bootstrap.server.luau
-- Server entry point: registers and boots all services (tech.md §3)
-- S0-8: registers obby services for reference vertical

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Net = require(ReplicatedStorage.Shared.Net.Net)
local ServiceLocator = require(script.Parent.ServiceLocator)
local DataService = require(script.Parent.Parent.data.DataService)
local ProgressService = require(script.Parent.Parent.obby.ProgressService)
local CheckpointService = require(script.Parent.Parent.obby.CheckpointService)

-- 1. Setup network remotes
Net.setup()

-- 2. Register services (order doesn't matter, Init resolves deps)
ServiceLocator.register("DataService", DataService)
ServiceLocator.register("ProgressService", ProgressService)
ServiceLocator.register("CheckpointService", CheckpointService)

-- 3. Init phase (dependency injection)
ServiceLocator.initAll()

-- 4. Start phase (begin listening)
ServiceLocator.startAll()

-- 5. Cleanup on player leave
Players.PlayerRemoving:Connect(function(player: Player)
	Net.cleanupPlayer(player)
end)

-- 6. Respawn player at last checkpoint
Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		-- Wait for profile to load
		task.wait(0.5)
		local spawnCFrame = ProgressService:getSpawnPosition(player)
		if spawnCFrame then
			local rootPart = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
			if rootPart then
				rootPart.CFrame = spawnCFrame
			end
		end
	end)
end)

print("[Bootstrap] Server started — reference vertical active")
