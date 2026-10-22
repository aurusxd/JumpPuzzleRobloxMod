--!strict
-- shared/Types/Profile.luau
-- Profile data types (tech.md §5)

export type CreatureInstance = {
	id: string,
	defId: string,
	level: number,
	xp: number,
	obtainedAt: number,
	source: string,
}

export type ProfileData = {
	version: number,
	obby: {
		highestStage: number,
		checkpoint: string,
		completedStages: { [string]: boolean },
		claimedRewards: { [string]: boolean },
		jumpUpgradeLevel: number,
	},
	creatures: {
		owned: { [string]: CreatureInstance },
		equipped: string?,
	},
	stats: {
		arenaWins: number,
		arenaKills: number,
		arenaDeaths: number,
	},
}

return nil
