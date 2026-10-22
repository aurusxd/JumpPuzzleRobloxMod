--!strict
-- server/arena/DamageCalc.luau
-- Pure function: compute damage (tech.md §9)
-- Placeholder: Alexey implements in S3-2

local DamageCalc = {}

function DamageCalc.compute(
	_attackerStats: { hp: number, attack: number, speed: number },
	_abilityDef: any,
	_targetStats: { hp: number, attack: number, speed: number }
): number
	-- TODO: implement in S3-2
	return 0
end

return DamageCalc
