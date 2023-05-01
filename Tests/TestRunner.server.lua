local LibaryRoot = script.Parent.Parent
local DevPackages = LibaryRoot.DevPackages
local TestEZ = require(DevPackages.testez)

local runner = TestEZ.TextReporterQuiet

TestEZ.TestBootstrap:run({
	LibaryRoot
}, runner)