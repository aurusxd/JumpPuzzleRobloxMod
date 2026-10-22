--!strict
-- tests/shared/Util/Rng.spec.luau
-- Tests for Rng with deterministic seed (tech.md §13)

return function()
	local Rng = require(game:GetService("ReplicatedStorage").Shared.Util.Rng)

	describe("Rng", function()
		it("should be deterministic with same seed", function()
			local rng1 = Rng.new(42)
			local rng2 = Rng.new(42)

			for _ = 1, 10 do
				expect(rng1:nextInteger(1, 100)).toBe(rng2:nextInteger(1, 100))
			end
		end)

		it("should return integers within range", function()
			local rng = Rng.new(12345)

			for _ = 1, 100 do
				local val = rng:nextInteger(5, 15)
				expect(val >= 5).toBe(true)
				expect(val <= 15).toBe(true)
			end
		end)

		it("should return number in [0, 1)", function()
			local rng = Rng.new(99)

			for _ = 1, 100 do
				local val = rng:nextNumber()
				expect(val >= 0).toBe(true)
				expect(val < 1).toBe(true)
			end
		end)

		it("weightedChoice should return valid index", function()
			local rng = Rng.new(42)
			local entries = {
				{ weight = 60 },
				{ weight = 30 },
				{ weight = 10 },
			}

			for _ = 1, 50 do
				local idx = rng:weightedChoice(entries)
				expect(idx >= 1).toBe(true)
				expect(idx <= #entries).toBe(true)
			end
		end)

		it("weightedChoice with single entry should always return 1", function()
			local rng = Rng.new(1)
			local entries = { { weight = 100 } }

			for _ = 1, 20 do
				expect(rng:weightedChoice(entries)).toBe(1)
			end
		end)
	end)
end
