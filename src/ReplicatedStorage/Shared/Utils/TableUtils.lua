--!strict
--[[
	TableUtils.lua
	Small table helpers used across client and server.
]]

local TableUtils = {}

function TableUtils.DeepCopy<T>(value: T): T
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in pairs(value :: any) do
		result[TableUtils.DeepCopy(key)] = TableUtils.DeepCopy(child)
	end
	return result :: T
end

function TableUtils.Count(map: { [any]: any }): number
	local count = 0
	for _ in pairs(map) do
		count += 1
	end
	return count
end

function TableUtils.SumValues(map: { [any]: number }): number
	local total = 0
	for _, value in pairs(map) do
		if type(value) == "number" then
			total += value
		end
	end
	return total
end

function TableUtils.Keys(map: { [any]: any }): { any }
	local keys = {}
	for key in pairs(map) do
		table.insert(keys, key)
	end
	return keys
end

return TableUtils
