--!strict
-- shared/Data/StageDefs.luau
-- Stage definitions (tech.md §6)
-- Stub data: 2 stages for skeleton (LEAD.md §1 p.10)

local StageDefs: { [string]: {
	id: string,
	index: number,
	isMilestone: boolean,
	rewardTableId: string?,
	checkpointTag: string,
} } = {
	s01 = {
		id = "s01",
		index = 1,
		isMilestone = false,
		rewardTableId = nil,
		checkpointTag = "Checkpoint_s01",
	},
	s02 = {
		id = "s02",
		index = 2,
		isMilestone = false,
		rewardTableId = nil,
		checkpointTag = "Checkpoint_s02",
	},
}

return StageDefs
