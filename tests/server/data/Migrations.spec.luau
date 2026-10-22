--!strict
-- tests/server/data/Migrations.spec.luau
-- Tests for Migrations (tech.md §5, §13)

return function()
	local Migrations = require(game:GetService("ServerScriptService").Server.data.Migrations)

	describe("Migrations", function()
		it("should not modify a profile at the latest version", function()
			local profile = {
				version = 1,
				obby = {
					highestStage = 5,
					checkpoint = "s05",
					completedStages = {},
					claimedRewards = {},
					jumpUpgradeLevel = 2,
				},
				creatures = { owned = {}, equipped = nil },
				stats = { arenaWins = 3, arenaKills = 10, arenaDeaths = 7 },
			}

			local migrated = Migrations.migrate(profile)
			expect(migrated.version).toBe(1)
			expect(migrated.obby.highestStage).toBe(5)
			expect(migrated.stats.arenaWins).toBe(3)
		end)

		it("getLatestVersion should return 1 when no migrations exist", function()
			expect(Migrations.getLatestVersion()).toBe(1)
		end)
	end)
end
