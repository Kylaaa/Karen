local B = {}
B.__index = B

function B.new(dependencies : {})
	local self = {
		dependencies = dependencies
	}
	setmetatable(self, B)

	return self
end

return B