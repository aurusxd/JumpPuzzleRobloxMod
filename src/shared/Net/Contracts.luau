--!strict
-- shared/Net/Contracts.luau
-- All remote event/function declarations (tech.md §10)
-- Every remote has: name, direction, rate limit

local Contracts = {}

export type ContractDirection = "ClientToServer" | "ServerToClient"

export type RemoteContract = {
	name: string,
	direction: ContractDirection,
	rateLimit: number?, -- requests per second (nil = no limit, server->client only)
}

-- Client -> Server remotes
Contracts.RequestEquipCreature: RemoteContract = {
	name = "RequestEquipCreature",
	direction = "ClientToServer",
	rateLimit = 2,
}

Contracts.RequestJoinArena: RemoteContract = {
	name = "RequestJoinArena",
	direction = "ClientToServer",
	rateLimit = 1,
}

Contracts.RequestLeaveArena: RemoteContract = {
	name = "RequestLeaveArena",
	direction = "ClientToServer",
	rateLimit = 1,
}

Contracts.ArenaUseAbility: RemoteContract = {
	name = "ArenaUseAbility",
	direction = "ClientToServer",
	rateLimit = 10,
}

-- Server -> Client remotes
Contracts.ProgressChanged: RemoteContract = {
	name = "ProgressChanged",
	direction = "ServerToClient",
}

Contracts.CreatureGranted: RemoteContract = {
	name = "CreatureGranted",
	direction = "ServerToClient",
}

Contracts.InventorySnapshot: RemoteContract = {
	name = "InventorySnapshot",
	direction = "ServerToClient",
}

Contracts.ArenaStateChanged: RemoteContract = {
	name = "ArenaStateChanged",
	direction = "ServerToClient",
}

Contracts.ArenaHitConfirmed: RemoteContract = {
	name = "ArenaHitConfirmed",
	direction = "ServerToClient",
}

-- Internal server signals (not network, just for reference)
-- StageCompleted(player, stageId)
-- CreatureGrantedServer(player, instance)
-- MatchEnded(results)

return Contracts
