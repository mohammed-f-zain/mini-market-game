--!strict
--[[
	FormatNumber.lua
	Human-readable number formatting for UI.
]]

local FormatNumber = {}

function FormatNumber.Coins(amount: number): string
	local n = math.floor(amount)
	if n >= 1_000_000 then
		return string.format("%.1fM", n / 1_000_000)
	elseif n >= 10_000 then
		return string.format("%.1fK", n / 1_000)
	end

	local formatted = tostring(n)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

function FormatNumber.Compact(amount: number): string
	return FormatNumber.Coins(amount)
end

return FormatNumber
