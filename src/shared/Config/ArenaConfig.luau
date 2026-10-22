--!strict
-- shared/Config/ArenaConfig.luau
-- Arena timing and match parameters (tech.md §9)

local ArenaConfig = {}

-- Match state machine timers (seconds)
ArenaConfig.LOBBY_MIN_PLAYERS = 2
ArenaConfig.LOBBY_MAX_WAIT = 60
ArenaConfig.COUNTDOWN_DURATION = 5
ArenaConfig.MATCH_DURATION = 120
ArenaConfig.END_SCREEN_DURATION = 8

-- Combat
ArenaConfig.ABILITY_RATE_LIMIT = 10 -- per second
ArenaConfig.RESPAWN_DELAY = 3

return ArenaConfig
