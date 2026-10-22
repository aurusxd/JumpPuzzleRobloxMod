--!strict
-- tests/shared/Net/Contracts.spec.luau
-- Contract validation tests (tech.md §13: every remote rejects garbage payload)

return function()
	local Contracts = require(game:GetService("ReplicatedStorage").Shared.Net.Contracts)

	describe("Net Contracts", function()
		it("should define all client-to-server remotes", function()
			expect(Contracts.RequestEquipCreature).toBeDefined()
			expect(Contracts.RequestEquipCreature.direction).toBe("ClientToServer")
			expect(Contracts.RequestEquipCreature.rateLimit).toBe(2)

			expect(Contracts.RequestJoinArena).toBeDefined()
			expect(Contracts.RequestJoinArena.direction).toBe("ClientToServer")
			expect(Contracts.RequestJoinArena.rateLimit).toBe(1)

			expect(Contracts.RequestLeaveArena).toBeDefined()
			expect(Contracts.RequestLeaveArena.direction).toBe("ClientToServer")
			expect(Contracts.RequestLeaveArena.rateLimit).toBe(1)

			expect(Contracts.ArenaUseAbility).toBeDefined()
			expect(Contracts.ArenaUseAbility.direction).toBe("ClientToServer")
			expect(Contracts.ArenaUseAbility.rateLimit).toBe(10)
		end)

		it("should define all server-to-client remotes", function()
			expect(Contracts.ProgressChanged).toBeDefined()
			expect(Contracts.ProgressChanged.direction).toBe("ServerToClient")

			expect(Contracts.CreatureGranted).toBeDefined()
			expect(Contracts.CreatureGranted.direction).toBe("ServerToClient")

			expect(Contracts.InventorySnapshot).toBeDefined()
			expect(Contracts.InventorySnapshot.direction).toBe("ServerToClient")

			expect(Contracts.ArenaStateChanged).toBeDefined()
			expect(Contracts.ArenaStateChanged.direction).toBe("ServerToClient")

			expect(Contracts.ArenaHitConfirmed).toBeDefined()
			expect(Contracts.ArenaHitConfirmed.direction).toBe("ServerToClient")
		end)

		it("should have rate limits only on client-to-server remotes", function()
			-- Server->Client should not have rate limits
			expect(Contracts.ProgressChanged.rateLimit).toBeNil()
			expect(Contracts.CreatureGranted.rateLimit).toBeNil()
			expect(Contracts.InventorySnapshot.rateLimit).toBeNil()
			expect(Contracts.ArenaStateChanged.rateLimit).toBeNil()
			expect(Contracts.ArenaHitConfirmed.rateLimit).toBeNil()
		end)

		it("each contract should have a unique name", function()
			local names: { [string]: boolean } = {}
			for _, contract in Contracts :: any do
				if typeof(contract) == "table" and contract.name then
					expect(names[contract.name]).toBeNil()
					names[contract.name] = true
				end
			end
		end)
	end)
end
