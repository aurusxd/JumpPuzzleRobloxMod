--!strict
-- server/core/ServiceLocator.luau
-- Central service registry (tech.md §3: services with Init/Start)

local ServiceLocator = {}

type ServiceEntry = {
	service: any,
	initialized: boolean,
	started: boolean,
}

local services: { [string]: ServiceEntry } = {}

function ServiceLocator.register(name: string, service: any)
	assert(not services[name], `Service already registered: {name}`)
	services[name] = {
		service = service,
		initialized = false,
		started = false,
	}
end

function ServiceLocator.get(name: string): any
	local entry = services[name]
	assert(entry, `Service not found: {name}`)
	return entry.service
end

-- Init all services (dependency injection phase)
function ServiceLocator.initAll()
	for name, entry in services do
		if not entry.initialized and entry.service.Init then
			entry.service:Init(ServiceLocator)
			entry.initialized = true
		end
	end
end

-- Start all services (runtime phase, after all Init complete)
function ServiceLocator.startAll()
	for name, entry in services do
		if not entry.started and entry.service.Start then
			entry.service:Start()
			entry.started = true
		end
	end
end

function ServiceLocator.reset()
	services = {}
end

return ServiceLocator
