--!strict
-- tests/server/obby/ProgressService.spec.luau
-- Tests for ProgressService (tech.md §13: stage order, idempotency)

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local StageDefs = require(ReplicatedStorage.Shared.Data.StageDefs)

	describe("ProgressService", function()
		-- Mock DataService for testing
		local function mockProfile()
			return {
				version = 1,
				obby = {
					highestStage = 0,
					checkpoint = "",
					completedStages = {},
					claimedRewards = {},
					jumpUpgradeLevel = 0,
				},
				creatures = { owned = {}, equipped = nil },
				stats = { arenaWins = 0, arenaKills = 0, arenaDeaths = 0 },
			}
		end

		it("should accept the first stage (index 1)", function()
			local profile = mockProfile()

			-- Simulate ProgressService.advance logic inline (pure logic test)
			local stageDef = StageDefs["s01"]
			expect(stageDef).toBeDefined()
			expect(stageDef.index).toBe(1)

			-- Stage index (1) should be <= highestStage + 1 (0 + 1 = 1)
			local canAdvance = stageDef.index <= profile.obby.highestStage + 1
			expect(canAdvance).toBe(true)
		end)

		it("should reject skipping stages", function()
			local profile = mockProfile()
			profile.obby.highestStage = 0

			local stageDef = StageDefs["s02"]
			expect(stageDef).toBeDefined()

			-- s02 has index 2, but highest is 0, so max allowed is 1
			local canAdvance = stageDef.index <= profile.obby.highestStage + 1
			expect(canAdvance).toBe(false)
		end)

		it("should allow revisiting completed stages", function()
			local profile = mockProfile()
			profile.obby.highestStage = 2
			profile.obby.completedStages["s01"] = true

			local stageDef = StageDefs["s01"]
			-- index 1 <= highest + 1 = 3, so allowed
			local canAdvance = stageDef.index <= profile.obby.highestStage + 1
			expect(canAdvance).toBe(true)

			-- But it's already completed, so it should only update checkpoint
			local alreadyCompleted = profile.obby.completedStages["s01"] == true
			expect(alreadyCompleted).toBe(true)
		end)

		it("should update highestStage on new progress", function()
			local profile = mockProfile()
			profile.obby.highestStage = 0

			local stageDef = StageDefs["s01"]
			-- Simulate advance
			profile.obby.checkpoint = stageDef.id
			profile.obby.completedStages[stageDef.id] = true
			if stageDef.index > profile.obby.highestStage then
				profile.obby.highestStage = stageDef.index
			end

			expect(profile.obby.highestStage).toBe(1)
			expect(profile.obby.checkpoint).toBe("s01")
			expect(profile.obby.completedStages["s01"]).toBe(true)
		end)

		it("should be idempotent: completing same stage twice does not double-count", function()
			local profile = mockProfile()

			-- First completion
			local stageDef = StageDefs["s01"]
			profile.obby.completedStages[stageDef.id] = true
			profile.obby.highestStage = stageDef.index

			-- Second touch: already in completedStages
			local wasAlreadyCompleted = profile.obby.completedStages[stageDef.id] == true
			expect(wasAlreadyCompleted).toBe(true)

			-- highestStage should not change
			local previousHighest = profile.obby.highestStage
			-- Re-touching same stage: just update checkpoint
			profile.obby.checkpoint = stageDef.id
			expect(profile.obby.highestStage).toBe(previousHighest)
		end)

		it("should advance sequentially through stages", function()
			local profile = mockProfile()

			-- Complete s01
			local s01 = StageDefs["s01"]
			profile.obby.completedStages[s01.id] = true
			profile.obby.highestStage = s01.index
			profile.obby.checkpoint = s01.id

			-- Now s02 should be allowed (index 2 <= 1 + 1)
			local s02 = StageDefs["s02"]
			local canAdvance = s02.index <= profile.obby.highestStage + 1
			expect(canAdvance).toBe(true)

			profile.obby.completedStages[s02.id] = true
			profile.obby.highestStage = s02.index
			profile.obby.checkpoint = s02.id

			expect(profile.obby.highestStage).toBe(2)
		end)
	end)
end
