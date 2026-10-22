--!strict
-- server/data/Migrations.luau
-- Profile data migrations (tech.md §5: only lead edits)

local Migrations = {}

-- Map from version to migration function
-- Each function takes old profile data and returns updated data
local migrations: { [number]: (data: any) -> any } = {
	-- Example for future:
	-- [1] = function(data)
	--     data.version = 2
	--     data.newField = defaultValue
	--     return data
	-- end,
}

function Migrations.migrate(data: any): any
	local currentVersion = data.version or 0

	while migrations[currentVersion] do
		data = migrations[currentVersion](data)
		currentVersion = data.version
	end

	return data
end

function Migrations.getLatestVersion(): number
	local max = 0
	for version in migrations do
		if version > max then
			max = version
		end
	end
	-- If no migrations, current version is 1
	return if max > 0 then max + 1 else 1
end

return Migrations
