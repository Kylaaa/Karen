return function()
	local Karen = require(script.Parent.Parent)
	local TestsFolder = script.Parent

	describe("initialize()", function()
		it("should throw when initializing with zero singletons", function()
			local sm = Karen.new()
			expect(function()
				sm:initialize()
			end).to.throw()
		end)

		it("should initialize the provided singletons", function()
			local sm = Karen.new()
			sm:registerSingleton(TestsFolder.A, {}) -- no dependencies
			sm:registerSingleton(TestsFolder.B, { -- many dependencies
				TestsFolder.C,
				TestsFolder.D,
			}) 
			sm:registerSingleton(TestsFolder.C, { -- one dependency
				TestsFolder.D,
			})
			sm:registerSingleton(TestsFolder.D, {})
			sm:initialize()

			local a = sm:get("A")
			local b = sm:get("B")
			local c = sm:get("C")
			local d = sm:get("D")

			expect(next(a.dependencies)).to.equal(nil)
			expect(b.dependencies["C"]).to.equal(c)
			expect(b.dependencies["D"]).to.equal(d)
			expect(c.dependencies["D"]).to.equal(d)
			expect(next(d.dependencies)).to.equal(nil)
		end)

		it("should throw when detecting circular dependencies", function()
			local sm = Karen.new()
			sm:registerSingleton(TestsFolder.A, {
				TestsFolder.B,
			})
			sm:registerSingleton(TestsFolder.B, {
				TestsFolder.C,
			})
			sm:registerSingleton(TestsFolder.C, {
				TestsFolder.D,
			})
			sm:registerSingleton(TestsFolder.D, {
				TestsFolder.A,
			})

			local success, err = pcall(function()
				sm:initialize()
			end)

			local success, err = pcall(function()
				sm:initialize()
			end)

			local expectedErrMessagePrefix = "Circular dependency detected"
			expect(success).to.equal(false)
			expect(err:find(expectedErrMessagePrefix)).to.never.equal(nil)
		end)
	end)

	describe("getInstance()", function()
		-- note - due to the way the the test runner creates a test plan, there's no way to guarantee that this test executes first
		itSKIP("should throw when Karen hasn't been initialized", function()
			expect(function()
				Karen.getInstance()
			end).to.throw()
		end)

		it("should return the initialized singleton manager", function()
			local sm = Karen.new()
			expect(sm).to.equal(Karen.getInstance())
		end)

		it("should allow for a library to create a custom accessor", function()
			local sm = Karen.new()
			local librarySM = Karen.new("foo")

			local sm2 = Karen.getInstance()
			local librarySM2 = Karen.getInstance("foo")

			expect(sm).to.equal(sm2)
			expect(librarySM).to.equal(librarySM2)
			expect(sm).to.never.equal(librarySM)
			expect(sm2).to.never.equal(librarySM2)
		end)
	end)

	describe("get()", function()
		it("should return an initialized singleton based on the name of the module", function()
			local sm = Karen.new()
			sm:registerSingleton(TestsFolder.A, {})
			sm:initialize()

			local a = sm:get("A")
			expect(a).to.never.equal(nil)
		end)

		it("should throw if there are no singletons that match the name", function()
			local sm = Karen.new()
			sm:registerSingleton(TestsFolder.A, {})
			sm:initialize()

			expect(function()
				local b = sm:get("B")
			end).to.throw()
		end)
	end)
end