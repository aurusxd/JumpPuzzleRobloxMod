--!strict
-- tests/shared/Util/RateLimiter.spec.luau
-- Tests for RateLimiter (tech.md §13)

return function()
	local RateLimiter = require(game:GetService("ReplicatedStorage").Shared.Util.RateLimiter)

	describe("RateLimiter", function()
		it("should allow requests within limit", function()
			local clock = 0
			local limiter = RateLimiter.new(3, function()
				return clock
			end)

			local mockPlayer = { Name = "TestPlayer" } :: any

			expect(limiter:check(mockPlayer)).toBe(true)
			expect(limiter:check(mockPlayer)).toBe(true)
			expect(limiter:check(mockPlayer)).toBe(true)
		end)

		it("should reject requests over limit", function()
			local clock = 0
			local limiter = RateLimiter.new(2, function()
				return clock
			end)

			local mockPlayer = { Name = "TestPlayer" } :: any

			expect(limiter:check(mockPlayer)).toBe(true)
			expect(limiter:check(mockPlayer)).toBe(true)
			expect(limiter:check(mockPlayer)).toBe(false)
		end)

		it("should reset after 1 second", function()
			local clock = 0
			local limiter = RateLimiter.new(1, function()
				return clock
			end)

			local mockPlayer = { Name = "TestPlayer" } :: any

			expect(limiter:check(mockPlayer)).toBe(true)
			expect(limiter:check(mockPlayer)).toBe(false)

			clock = 1.1
			expect(limiter:check(mockPlayer)).toBe(true)
		end)

		it("should track players independently", function()
			local clock = 0
			local limiter = RateLimiter.new(1, function()
				return clock
			end)

			local player1 = { Name = "Player1" } :: any
			local player2 = { Name = "Player2" } :: any

			expect(limiter:check(player1)).toBe(true)
			expect(limiter:check(player1)).toBe(false)
			expect(limiter:check(player2)).toBe(true) -- independent
		end)

		it("should cleanup player data", function()
			local clock = 0
			local limiter = RateLimiter.new(1, function()
				return clock
			end)

			local mockPlayer = { Name = "TestPlayer" } :: any

			limiter:check(mockPlayer)
			limiter:cleanup(mockPlayer)
			-- After cleanup, should be treated as fresh
			expect(limiter:check(mockPlayer)).toBe(true)
		end)
	end)
end
