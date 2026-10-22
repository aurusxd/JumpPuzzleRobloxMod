--!strict
-- server/obby/ProgressService.luau
-- Manages player obby progression (tech.md §7)
-- S0-8: reference vertical — validates stage order, writes profile, fires events

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net.Net)
local StageDefs = require(ReplicatedStorage.Shared.Data.StageDefs)

local ProgressService = {}

local dataService: any = nil

-- Internal signal subscribers (tech.md §10: StageCompleted)
local stageCompletedCallbacks: { (player: Player, stageId: string) -> () } = {}

-- Debounce per player to avoid rapid-fire touches
local advanceCooldowns: { [Player]: number } = {}
local ADVANCE_COOLDOWN = 0.5

function ProgressService:Init(locator: any)
	dataService = locator.get("DataService")
end

function ProgressService:Start()
	-- Clean up cooldowns when players leave
	game:GetService("Players").PlayerRemoving:Connect(function(player: Player)
		advanceCooldowns[player] = nil
	end)
end

-- Called by CheckpointService when a player touches a valid checkpoint
function ProgressService:advance(player: Player, stageId: string)
	-- Cooldown check
	local now = os.clock()
	if advanceCooldowns[player] and now < advanceCooldowns[player] then
		return
	end
	advanceCooldowns[player] = now + ADVANCE_COOLDOWN

	-- Get profile
	local profile = dataService:getProfile(player)
	if not profile then
		return
	end

	-- Get stage definition
	local stageDef = StageDefs[stageId]
	if not stageDef then
		warn(`[ProgressService] Unknown stageId: {stageId}`)
		return
	end

	-- Validate stage order: only accept next stage or already-completed stage
	local currentHighest = profile.obby.highestStage
	if stageDef.index > currentHighest + 1 then
		-- Player trying to skip stages
		warn(`[ProgressService] {player.Name} tried to skip to stage {stageId} (highest: {currentHighest})`)
		return
	end

	-- Already completed this stage — update checkpoint but don't re-complete
	if profile.obby.completedStages[stageId] then
		profile.obby.checkpoint = stageId
		return
	end

	-- Advance progress
	profile.obby.checkpoint = stageId
	profile.obby.completedStages[stageId] = true

	if stageDef.index > currentHighest then
		profile.obby.highestStage = stageDef.index
	end

	-- Fire network event to client (tech.md §10: ProgressChanged)
	Net.fireClient("ProgressChanged", player, {
		stageId = stageId,
		highestStage = profile.obby.highestStage,
	})

	-- Fire internal signal (tech.md §10: StageCompleted)
	-- Idempotent: only fires once per stage because of completedStages check above
	for _, callback in stageCompletedCallbacks do
		task.spawn(callback, player, stageId)
	end
end

-- Register a callback for StageCompleted internal signal
function ProgressService:onStageCompleted(callback: (player: Player, stageId: string) -> ())
	table.insert(stageCompletedCallbacks, callback)
end

-- Get the spawn CFrame for a player based on their checkpoint
function ProgressService:getSpawnPosition(player: Player): CFrame?
	local profile = dataService:getProfile(player)
	if not profile or profile.obby.checkpoint == "" then
		return nil
	end

	local stageDef = StageDefs[profile.obby.checkpoint]
	if not stageDef then
		return nil
	end

	-- Find the checkpoint part in workspace by tag and attribute
	local CollectionService = game:GetService("CollectionService")
	local Constants = require(ReplicatedStorage.Shared.Config.Constants)

	for _, part in CollectionService:GetTagged(Constants.Tags.Checkpoint) do
		if part:GetAttribute(Constants.Attributes.StageId) == profile.obby.checkpoint then
			return (part :: BasePart).CFrame + Vector3.new(0, 5, 0)
		end
	end

	return nil
end

return ProgressService
