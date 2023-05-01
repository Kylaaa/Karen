local D = {}
D.__index = D

function D.new(dependencies : {})
	local self = {
		dependencies = dependencies
	}
	setmetatable(self, D)

	return self
end

return D