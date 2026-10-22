--!strict
-- server/data/DataService.luau
-- Player data management via ProfileStore (tech.md §2, §5)

local Players = game:GetService("Players")

local ProfileSchema = require(script.Parent.ProfileSchema)
local Migrations = require(script.Parent.Migrations)

local DataService = {}

type ProfileHandle = {
	Data: any,
	Release: (self: any) -> (),
	IsActive: (self: any) -> boolean,
}

type ProfileStoreInterface = {
	LoadProfileAsync: (self: any, key: string) -> ProfileHandle?,
}

local profiles: { [Player]: ProfileHandle } = {}
local profileStore: ProfileStoreInterface? = nil
function DataService:Init(_locator: any) end

-- Inject a mock profile store for testing
function DataService:setProfileStore(store: ProfileStoreInterface)
	profileStore = store
end

function DataService:Start()
	-- In production, create the real ProfileStore here
	if not profileStore then
		local success, ProfileStore = pcall(function()
			return require(game:GetService("ServerScriptService"):FindFirstChild("ProfileStore", true))
		end)
		if success and ProfileStore then
			profileStore = ProfileStore.New("PlayerProfiles", ProfileSchema.default())
		else
			warn("[DataService] ProfileStore not found, data will not persist")
		end
	end

	Players.PlayerAdded:Connect(function(player: Player)
		self:_loadProfile(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:_releaseProfile(player)
	end)

	-- Handle players already in game (if script loads late)
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:_loadProfile(player)
		end)
	end
end

function DataService:_loadProfile(player: Player)
	if not profileStore then
		warn(`[DataService] No profile store, cannot load for {player.Name}`)
		return
	end

	local key = `Player_{player.UserId}`
	local profile = profileStore:LoadProfileAsync(key)

	if not profile then
		warn(`[DataService] Failed to load profile for {player.Name}`)
		player:Kick("Failed to load your data. Please rejoin.")
		return
	end

	-- Run migrations if needed
	if profile.Data.version and profile.Data.version < ProfileSchema.CURRENT_VERSION then
		profile.Data = Migrations.migrate(profile.Data)
	end

	-- Ensure defaults for any missing fields
	local default = ProfileSchema.default()
	for key, value in default do
		if profile.Data[key] == nil then
			profile.Data[key] = value
		end
	end

	if not player:IsDescendantOf(Players) then
		-- Player left before profile loaded
		profile:Release()
		return
	end

	profiles[player] = profile
end

function DataService:_releaseProfile(player: Player)
	local profile = profiles[player]
	if profile then
		profile:Release()
		profiles[player] = nil
	end
end

function DataService:getProfile(player: Player): any?
	local profile = profiles[player]
	if profile and profile:IsActive() then
		return profile.Data
	end
	return nil
end

function DataService:hasProfile(player: Player): boolean
	local profile = profiles[player]
	return profile ~= nil and profile:IsActive()
end

return DataService
