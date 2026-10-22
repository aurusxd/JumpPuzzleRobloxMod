--!strict
-- shared/Data/RewardTables.luau
-- Reward tables for milestone stages (tech.md §6)
-- Stub data: 1 table for skeleton (LEAD.md §1 p.10)

local RewardTables: { [string]: {
	id: string,
	entries: { { defId: string, weight: number } },
	guaranteedRarityAtLeast: string?,
} } =
	{
		milestone_basic = {
			id = "milestone_basic",
			entries = {
				{ defId = "ember_blob", weight = 60 },
				{ defId = "tide_jelly", weight = 40 },
			},
			guaranteedRarityAtLeast = nil,
		},
	}

return RewardTables
