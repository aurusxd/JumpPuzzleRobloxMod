--!strict
-- client/obby/CheckpointController.luau
-- Client-side: listens for ProgressChanged and updates UI (S0-8 reference vertical)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Net = require(ReplicatedStorage.Shared.Net.Net)

local CheckpointController = {}

local currentStage: string = ""
local highestStage: number = 0

-- Callbacks for UI updates
local onProgressChangedCallbacks: { (stageId: string, highest: number) -> () } = {}

function CheckpointController:Start()
	Net.onClientEvent("ProgressChanged", function(payload: any)
		if not payload or typeof(payload) ~= "table" then
			return
		end

		local stageId = payload.stageId
		local highest = payload.highestStage

		if typeof(stageId) ~= "string" or typeof(highest) ~= "number" then
			return
		end

		currentStage = stageId
		highestStage = highest

		-- Notify listeners (UI)
		for _, callback in onProgressChangedCallbacks do
			task.spawn(callback, stageId, highest)
		end
	end)
end

function CheckpointController:getCurrentStage(): string
	return currentStage
end

function CheckpointController:getHighestStage(): number
	return highestStage
end

function CheckpointController:onProgressChanged(callback: (stageId: string, highest: number) -> ())
	table.insert(onProgressChangedCallbacks, callback)
end

return CheckpointController
