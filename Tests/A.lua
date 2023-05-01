local A = {}
A.__index = A

function A.new(dependencies : {})
	local self = {
		dependencies = dependencies
	}
	setmetatable(self, A)

	return self
end

return A