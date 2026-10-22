--!strict
-- shared/Util/RateLimiter.luau
-- Per-player rate limiter for remote events (tech.md §3, §10)

local RateLimiter = {}
RateLimiter.__index = RateLimiter

export type RateLimiter = typeof(setmetatable(
	{} :: {
		_maxPerSecond: number,
		_records: { [Player]: { count: number, resetAt: number } },
		_clock: () -> number,
	},
	RateLimiter
))

function RateLimiter.new(maxPerSecond: number, clock: (() -> number)?): RateLimiter
	local self = setmetatable({
		_maxPerSecond = maxPerSecond,
		_records = {} :: { [Player]: { count: number, resetAt: number } },
		_clock = clock or os.clock,
	}, RateLimiter)
	return self
end

-- Returns true if allowed, false if rate limited
function RateLimiter.check(self: RateLimiter, player: Player): boolean
	local now = self._clock()
	local record = self._records[player]

	if not record or now >= record.resetAt then
		self._records[player] = { count = 1, resetAt = now + 1 }
		return true
	end

	record.count += 1
	if record.count > self._maxPerSecond then
		return false
	end

	return true
end

function RateLimiter.cleanup(self: RateLimiter, player: Player)
	self._records[player] = nil
end

return RateLimiter
