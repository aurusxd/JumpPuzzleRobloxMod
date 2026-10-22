--!strict
-- shared/Net/Contracts.luau
-- All remote event/function declarations (tech.md §10)
-- Every remote has: name, direction, rate limit

export type ContractDirection = "ClientToServer" | "ServerToClient"

export type RemoteContract = {
	name: string,
	direction: ContractDirection,
	rateLimit: number?, -- requests per second (nil = no limit, server->client only)
}

local Contracts: { [string]: RemoteContract } = {}

-- Client -> Server remotes
Contracts.RequestEquipCreature = {
	name = "RequestEquipCreature",
	direction = "ClientToServer",
	rateLimit = 2,
}

Contracts.RequestJoinArena = {
	name = "RequestJoinArena",
	direction = "ClientToServer",
	rateLimit = 1,
}

Contracts.RequestLeaveArena = {
	name = "RequestLeaveArena",
	direction = "ClientToServer",
	rateLimit = 1,
}

Contracts.ArenaUseAbility = {
	name = "ArenaUseAbility",
	direction = "ClientToServer",
	rateLimit = 10,
}

-- Server -> Client remotes
Contracts.ProgressChanged = {
	name = "ProgressChanged",
	direction = "ServerToClient",
}

Contracts.CreatureGranted = {
	name = "CreatureGranted",
	direction = "ServerToClient",
}

Contracts.InventorySnapshot = {
	name = "InventorySnapshot",
	direction = "ServerToClient",
}

Contracts.ArenaStateChanged = {
	name = "ArenaStateChanged",
	direction = "ServerToClient",
}

Contracts.ArenaHitConfirmed = {
	name = "ArenaHitConfirmed",
	direction = "ServerToClient",
}

-- Internal server signals (not network, just for reference)
-- StageCompleted(player, stageId)
-- CreatureGrantedServer(player, instance)
-- MatchEnded(results)

return Contracts
