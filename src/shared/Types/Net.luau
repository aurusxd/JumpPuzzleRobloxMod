--!strict
-- shared/Types/Net.luau
-- Network payload types (tech.md §10)

local Profile = require(script.Parent.Profile)

-- Client -> Server payloads
export type RequestEquipCreaturePayload = {
	instanceId: string,
}

export type RequestJoinArenaPayload = {}

export type RequestLeaveArenaPayload = {}

export type ArenaUseAbilityPayload = {
	targetPosition: Vector3?,
}

-- Server -> Client payloads
export type ProgressChangedPayload = {
	stageId: string,
	highestStage: number,
}

export type CreatureGrantedPayload = {
	instance: Profile.CreatureInstance,
}

export type InventorySnapshotPayload = {
	owned: { [string]: Profile.CreatureInstance },
	equipped: string?,
}

export type ArenaStateChangedPayload = {
	state: string,
	endsAt: number?,
}

export type ArenaHitConfirmedPayload = {
	attackerId: number,
	targetId: number,
	damage: number,
}

return nil
