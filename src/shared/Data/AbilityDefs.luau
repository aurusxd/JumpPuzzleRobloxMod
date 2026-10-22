--!strict
-- shared/Data/AbilityDefs.luau
-- Ability definitions (tech.md §6)
-- Stub data: 1 ability for skeleton (LEAD.md §1 p.10)

local AbilityDefs: { [string]: {
	id: string,
	kind: string,
	cooldown: number,
	damage: number,
	params: { [string]: number },
} } = {
	fireball = {
		id = "fireball",
		kind = "Projectile",
		cooldown = 3,
		damage = 25,
		params = {
			speed = 60,
			radius = 2,
			range = 80,
		},
	},
}

return AbilityDefs
