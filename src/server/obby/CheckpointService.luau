--!strict
-- server/obby/CheckpointService.luau
-- Handles checkpoint touches with server validation (tech.md §7)
-- S0-8: reference vertical implementation

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Constants = require(game:GetService("ReplicatedStorage").Shared.Config.Constants)

local CheckpointService = {}

local progressService: any = nil
local dataService: any = nil

-- Max distance a player can be from a checkpoint to register a touch
local MAX_TOUCH_DISTANCE = 15

function CheckpointService:Init(locator: any)
	dataService = locator.get("DataService")
	progressService = locator.get("ProgressService")
end

function CheckpointService:Start()
	-- Bind to existing and future Checkpoint-tagged parts
	for _, part in CollectionService:GetTagged(Constants.Tags.Checkpoint) do
		self:_bindCheckpoint(part)
	end

	CollectionService:GetInstanceAddedSignal(Constants.Tags.Checkpoint):Connect(function(part)
		self:_bindCheckpoint(part)
	end)
end

function CheckpointService:_bindCheckpoint(part: BasePart)
	local stageId = part:GetAttribute(Constants.Attributes.StageId)
	if not stageId or typeof(stageId) ~= "string" then
		warn(`[CheckpointService] Part {part:GetFullName()} missing StageId attribute`)
		return
	end

	part.Touched:Connect(function(hit: BasePart)
		local character = hit.Parent
		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		-- Distance validation: player must be physically near the checkpoint
		local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not rootPart then
			return
		end

		local distance = (rootPart.Position - part.Position).Magnitude
		if distance > MAX_TOUCH_DISTANCE then
			return
		end

		-- Delegate to ProgressService for validation and state update
		progressService:advance(player, stageId)
	end)
end

return CheckpointService
