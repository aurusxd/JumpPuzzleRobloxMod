--!strict
-- shared/Util/Result.luau
-- Lightweight Result type for error handling without exceptions

local Result = {}

export type Result<T> = {
	ok: boolean,
	value: T?,
	error: string?,
}

function Result.ok<T>(value: T): Result<T>
	return { ok = true, value = value, error = nil }
end

function Result.err<T>(message: string): Result<T>
	return { ok = false, value = nil, error = message }
end

function Result.isOk<T>(result: Result<T>): boolean
	return result.ok
end

function Result.unwrap<T>(result: Result<T>): T
	assert(result.ok, `Result.unwrap called on error: {result.error}`)
	return result.value :: T
end

return Result
