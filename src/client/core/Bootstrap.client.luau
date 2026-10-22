--!strict
-- client/core/Bootstrap.client.luau
-- Client entry point (tech.md §3)
-- S0-8: initializes net, starts controllers, mounts HUD

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Net = require(ReplicatedStorage.Shared.Net.Net)
local CheckpointController = require(script.Parent.Parent.obby.CheckpointController)

-- Wait for server to create remotes, then initialize
Net.setup()

-- Start controllers
CheckpointController:Start()

-- Mount progress HUD
-- In production this uses React-Lua mounting; for now log updates
CheckpointController:onProgressChanged(function(stageId: string, highest: number)
	print(`[Client] Progress: stage={stageId}, highest={highest}`)
end)

print("[Bootstrap] Client started — reference vertical active")
