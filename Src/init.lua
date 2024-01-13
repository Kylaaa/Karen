--[[
	Karen - A Singleton Manager
	Allows for singleton registration and automatically handles initialization order.


    -- INITIALIZE ALL OF YOUR SINGLETONS
    local Packages = --your path to where your packages are stored
	local Karen = require(Packages.Karen)

    local ManagersFolder = --your path to where you store your singletons
	local sm = Karen.new() -- create a new singleton manager
	sm:registerSingleton(ManagersFolder.A, {
		ManagersFolder.B
	})
	sm:registerSingleton(ManagersFolder.B, {
		ManagersFolder.C,
		ManagersFolder.D
	})
	sm:registerSingleton(ManagersFolder.C, {})
	sm:registerSingleton(ManagersFolder.D, {})
	sm:initialize()



	-- ACCESSING REGISTERED SINGLETONS
	sm:get("A"):foo()
	-- or
	Karen.getInstance():get("A"):foo()



	-- CREATING SINGLETON MODULES WITH DEPENDENCIES
	local A = {}
	A.__index = A
	function A.new(dependencies : {})
		local B = dependencies.B
        return setmetatable({
        	-- optionally store the dependencies table for later
	        -- dependencies = dependencies
        }, A)
	end
	function A:foo()
        print("Hello world")
	end
]]

local _instance = nil
local _instances = {}

local SingletonManager = {}
SingletonManager.__index = SingletonManager

function SingletonManager.new(id : string?)
	if _instance and not id then
		warn("Creating multiple instances of the SingletonManager")
	end

	local self = {
		singletonModules = {}, -- { Instance }
		dependencies = {}, -- { Instance, { Instance }}
		names = {}, -- { Instance, string }
		
		-- initialized objects
		singletons = {}, -- { string, table }
	}
	setmetatable(self, SingletonManager)

	-- create a global accessor for this instance
	if id then
		_instances[id] = self
	else
		_instance = self
	end
	return self
end

function SingletonManager.getInstance(id : string?)
	if id then
		assert(_instances[id] ~= nil)
		return _instances[id]
	else
		assert(_instance ~= nil, "Karen hasn't been initialized yet. Create one first with Karen.new()")
		return _instance	
	end
end

function SingletonManager:registerSingleton(moduleScript : ModuleScript, dependencies : { ModuleScript })
	--
	table.insert(self.singletonModules, moduleScript)
	self.dependencies[moduleScript] = dependencies
end

function SingletonManager:initialize()
	assert(#self.singletonModules > 0)

	-- sort the list of singletons by number of dependencies ASC
	table.sort(self.singletonModules, function(a, b)
		return #self.dependencies[a] < #self.dependencies[b]
	end)
	
	local function getDependencies(module : ModuleScript, visitedNodes : {})
		-- lookup if there are any dependencies
		local dependencies = self.dependencies[module]
		local values = {}
		if #dependencies > 0 then
			-- check that the dependencies have been initialized
			for _ , module : ModuleScript in ipairs(dependencies) do
				local initializedValue = self.singletons[module.Name]
				if not initializedValue then
					-- check if we're trapped in a loop
					if visitedNodes[module.Name] then
						-- found a loop, try to tell people how we got here
						local nodes = {}
						for name, _ in pairs(visitedNodes) do
							table.insert(nodes, name)
						end
						local message = "Circular dependency detected in group (%s)"
						error(string.format(message, table.concat(nodes, ", ")))
					else
						visitedNodes[module.Name] = true
					end

					-- grab its dependencies
					local dependencies = getDependencies(module, visitedNodes)
					local manager = require(module)
					initializedValue = manager.new(dependencies)
					
					-- hold onto it for later
					self.singletons[module.Name] = initializedValue
				end
				
				values[module.Name] = initializedValue
			end 
		end
		return values
	end
	
	-- initialize all of the modules
	for _, module : ModuleScript in ipairs(self.singletonModules) do
		local singleton = self.singletons[module.Name]
		if not singleton then
			local manager = require(module)
			local visitedNodes = {}
			local dependencies = getDependencies(module, visitedNodes)
			self.singletons[module.Name] = manager.new(dependencies)
		end
	end
end

function SingletonManager:get(managerName : string)
	local manager = self.singletons[managerName]
	assert(manager ~= nil, "COULD NOT FIND MANAGER WITH NAME " .. managerName)
	return manager
end

return SingletonManager