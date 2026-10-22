--!strict
-- server/data/ProfileSchema.luau
-- Default profile and version (tech.md §5)

local ProfileSchema = {}

ProfileSchema.CURRENT_VERSION = 1

function ProfileSchema.default(): any
	return {
		version = ProfileSchema.CURRENT_VERSION,
		obby = {
			highestStage = 0,
			checkpoint = "",
			completedStages = {},
			claimedRewards = {},
			jumpUpgradeLevel = 0,
		},
		creatures = {
			owned = {},
			equipped = nil,
		},
		stats = {
			arenaWins = 0,
			arenaKills = 0,
			arenaDeaths = 0,
		},
	}
end

return ProfileSchema
