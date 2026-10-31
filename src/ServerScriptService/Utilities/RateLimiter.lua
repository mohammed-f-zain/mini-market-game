--!strict
--[[
	RateLimiter.lua
	Per-player sliding window rate limiting for remotes.
]]

local RateLimiter = {}
RateLimiter.__index = RateLimiter

export type RateLimiterType = typeof(setmetatable(
	{} :: {
		_windowSeconds: number,
		_maxRequests: number,
		_buckets: { [number]: { number } },
	},
	RateLimiter
))

function RateLimiter.new(windowSeconds: number, maxRequests: number): RateLimiterType
	local self = setmetatable({
		_windowSeconds = windowSeconds,
		_maxRequests = maxRequests,
		_buckets = {} :: { [number]: { number } },
	}, RateLimiter)
	return self
end

function RateLimiter.Allow(self: RateLimiterType, player: Player): boolean
	local now = os.clock()
	local userId = player.UserId
	local bucket = self._buckets[userId]
	if not bucket then
		bucket = {}
		self._buckets[userId] = bucket
	end

	local cutoff = now - self._windowSeconds
	local filtered: { number } = {}
	for _, timestamp in ipairs(bucket) do
		if timestamp >= cutoff then
			table.insert(filtered, timestamp)
		end
	end

	if #filtered >= self._maxRequests then
		self._buckets[userId] = filtered
		return false
	end

	table.insert(filtered, now)
	self._buckets[userId] = filtered
	return true
end

function RateLimiter.Clear(self: RateLimiterType, player: Player)
	self._buckets[player.UserId] = nil
end

return RateLimiter
