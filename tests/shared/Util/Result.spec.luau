--!strict
-- tests/shared/Util/Result.spec.luau
-- Tests for Result type

return function()
	local Result = require(game:GetService("ReplicatedStorage").Shared.Util.Result)

	describe("Result", function()
		it("ok should create successful result", function()
			local r = Result.ok(42)
			expect(Result.isOk(r)).toBe(true)
			expect(Result.unwrap(r)).toBe(42)
		end)

		it("err should create error result", function()
			local r = Result.err("something broke")
			expect(Result.isOk(r)).toBe(false)
			expect(r.error).toBe("something broke")
		end)

		it("unwrap on error should throw", function()
			local r = Result.err("bad")
			expect(function()
				Result.unwrap(r)
			end).toThrow()
		end)
	end)
end
