--!strict
-- shared/Config/Constants.luau
-- Global constants (tech.md §3)

local Constants = {}

Constants.PROFILE_KEY_PREFIX = "Player_"
Constants.PROFILE_STORE_NAME = "PlayerProfiles"

-- Tags used by CollectionService
Constants.Tags = {
	Checkpoint = "Checkpoint",
	KillBrick = "KillBrick",
	LaunchPad = "LaunchPad",
	JumpBoostPickup = "JumpBoostPickup",
	ArenaPortal = "ArenaPortal",
}

-- Attributes on tagged parts
Constants.Attributes = {
	StageId = "StageId",
	Power = "Power",
	Direction = "Direction",
}

return Constants
