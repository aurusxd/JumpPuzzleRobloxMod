--!strict
-- shared/Data/CreatureDefs.luau
-- Creature definitions (tech.md §6)
-- Stub data: 2 creatures for skeleton (LEAD.md §1 p.10)

local CreatureDefs: {
	[string]: {
		id: string,
		displayName: string,
		element: string,
		rarity: string,
		baseStats: { hp: number, attack: number, speed: number },
		abilityId: string,
		modelAsset: string,
	},
} =
	{
		ember_blob = {
			id = "ember_blob",
			displayName = "Ember Blob",
			element = "Ember",
			rarity = "Common",
			baseStats = { hp = 100, attack = 15, speed = 10 },
			abilityId = "fireball",
			modelAsset = "rbxassetid://0", -- placeholder
		},
		tide_jelly = {
			id = "tide_jelly",
			displayName = "Tide Jelly",
			element = "Tide",
			rarity = "Common",
			baseStats = { hp = 120, attack = 10, speed = 12 },
			abilityId = "water_shield",
			modelAsset = "rbxassetid://0", -- placeholder
		},
	}

return CreatureDefs
