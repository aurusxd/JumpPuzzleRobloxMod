--!strict
-- client/core/Bootstrap.client.luau
-- Client entry point (tech.md §3)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net.Net)

-- Wait for server to create remotes, then initialize
Net.setup()

print("[Bootstrap] Client started")
