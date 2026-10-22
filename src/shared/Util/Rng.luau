--!strict
-- shared/Util/Rng.luau
-- Injectable random number generator (tech.md §13: determinism in tests)

local Rng = {}
Rng.__index = Rng

export type Rng = typeof(setmetatable(
	{} :: {
		_random: Random,
	},
	Rng
))

function Rng.new(seed: number?): Rng
	local self = setmetatable({
		_random = if seed then Random.new(seed) else Random.new(),
	}, Rng)
	return self
end

-- Returns integer in [min, max]
function Rng.nextInteger(self: Rng, min: number, max: number): number
	return self._random:NextInteger(min, max)
end

-- Returns float in [0, 1)
function Rng.nextNumber(self: Rng): number
	return self._random:NextNumber()
end

-- Weighted random selection from entries with { weight: number }
-- Returns the index of the selected entry
function Rng.weightedChoice(self: Rng, entries: { { weight: number } }): number
	local totalWeight = 0
	for _, entry in entries do
		totalWeight += entry.weight
	end

	local roll = self:nextNumber() * totalWeight
	local cumulative = 0
	for i, entry in entries do
		cumulative += entry.weight
		if roll < cumulative then
			return i
		end
	end

	-- Fallback to last entry (floating point edge case)
	return #entries
end

return Rng
