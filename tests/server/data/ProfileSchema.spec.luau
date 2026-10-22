--!strict
-- tests/server/data/ProfileSchema.spec.luau
-- Tests for ProfileSchema defaults

return function()
	local ProfileSchema = require(game:GetService("ServerScriptService").Server.data.ProfileSchema)

	describe("ProfileSchema", function()
		it("default should return a valid profile", function()
			local profile = ProfileSchema.default()

			expect(profile.version).toBe(1)
			expect(profile.obby.highestStage).toBe(0)
			expect(profile.obby.checkpoint).toBe("")
			expect(profile.obby.jumpUpgradeLevel).toBe(0)
			expect(profile.creatures.equipped).toBeNil()
			expect(profile.stats.arenaWins).toBe(0)
			expect(profile.stats.arenaKills).toBe(0)
			expect(profile.stats.arenaDeaths).toBe(0)
		end)

		it("default should return independent copies", function()
			local p1 = ProfileSchema.default()
			local p2 = ProfileSchema.default()

			p1.obby.highestStage = 5
			expect(p2.obby.highestStage).toBe(0)
		end)
	end)
end
