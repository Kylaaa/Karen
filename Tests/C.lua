local C = {}
C.__index = C

function C.new(dependencies : {})
	local self = {
		dependencies = dependencies
	}
	setmetatable(self, C)

	return self
end

return C