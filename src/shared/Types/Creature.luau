--!strict
-- shared/Types/Creature.luau
-- Creature-related types (tech.md §6)

export type Element = "Ember" | "Tide" | "Moss" | "Volt" | "Dust"

export type Rarity = "Common" | "Rare" | "Epic" | "Legendary"

export type CreatureDef = {
	id: string,
	displayName: string,
	element: Element,
	rarity: Rarity,
	baseStats: { hp: number, attack: number, speed: number },
	abilityId: string,
	modelAsset: string,
}

export type AbilityKind = "Projectile" | "AoE" | "Dash" | "Shield"

export type AbilityDef = {
	id: string,
	kind: AbilityKind,
	cooldown: number,
	damage: number,
	params: { [string]: number },
}

export type StageDef = {
	id: string,
	index: number,
	isMilestone: boolean,
	rewardTableId: string?,
	checkpointTag: string,
}

export type RewardTable = {
	id: string,
	entries: { { defId: string, weight: number } },
	guaranteedRarityAtLeast: string?,
}

return nil
