--!strict
-- shared/Config/JumpConfig.luau
-- Jump power parameters (tech.md §7)

local JumpConfig = {}

JumpConfig.BASE_JUMP_POWER = 50
JumpConfig.MAX_JUMP_POWER = 130

-- Each upgrade level adds this much jump power
-- Index = upgrade level (1-based), value = total added power at that level
JumpConfig.UPGRADE_STEPS = { 5, 12, 20, 30, 42, 55, 70 }

JumpConfig.BOOST_DURATION = 8 -- seconds
JumpConfig.BOOST_POWER_ADD = 25

-- Launch pad limits
JumpConfig.LAUNCH_POWER_MIN = 50
JumpConfig.LAUNCH_POWER_MAX = 250
JumpConfig.MAX_LAUNCH_VELOCITY = 200

-- MovementValidator
JumpConfig.MAX_HORIZONTAL_SPEED = 100
JumpConfig.SPEED_MARGIN = 1.15 -- 15% tolerance
JumpConfig.SUSPICION_THRESHOLD = 5 -- teleport-back after this many violations

return JumpConfig
