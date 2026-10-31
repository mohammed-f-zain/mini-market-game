--!strict
--[[
	UpgradeConfig.lua
	Store upgrade definitions and cost formulas.
]]

export type UpgradeDefinition = {
	Id: string,
	DisplayName: string,
	Description: string,
	MaxLevel: number,
	BaseCost: number,
	CostMultiplier: number,
	EffectPerLevel: number,
}

local UpgradeConfig: { [string]: UpgradeDefinition } = {
	Shelves = {
		Id = "Shelves",
		DisplayName = "Additional Shelves",
		Description = "Add more shelves to stock more products.",
		MaxLevel = 5,
		BaseCost = 200,
		CostMultiplier = 1.75,
		EffectPerLevel = 1,
	},
	CustomerAttraction = {
		Id = "CustomerAttraction",
		DisplayName = "Customer Attraction",
		Description = "Attract customers more frequently.",
		MaxLevel = 5,
		BaseCost = 250,
		CostMultiplier = 1.8,
		EffectPerLevel = 1,
	},
	StorageCapacity = {
		Id = "StorageCapacity",
		DisplayName = "Storage Capacity",
		Description = "Increase maximum inventory capacity.",
		MaxLevel = 5,
		BaseCost = 180,
		CostMultiplier = 1.7,
		EffectPerLevel = 25,
	},
}

function UpgradeConfig.GetCost(upgradeId: string, currentLevel: number): number?
	local def = UpgradeConfig[upgradeId]
	if type(def) ~= "table" or not def.Id then
		return nil
	end
	if currentLevel < 0 or currentLevel >= def.MaxLevel then
		return nil
	end
	local cost = def.BaseCost * (def.CostMultiplier ^ currentLevel)
	return math.floor(cost + 0.5)
end

function UpgradeConfig.GetAll(): { UpgradeDefinition }
	local list: { UpgradeDefinition } = {}
	for _, upgrade in pairs(UpgradeConfig) do
		if type(upgrade) == "table" and upgrade.Id then
			table.insert(list, upgrade :: UpgradeDefinition)
		end
	end
	table.sort(list, function(a, b)
		return a.DisplayName < b.DisplayName
	end)
	return list
end

function UpgradeConfig.Get(upgradeId: string): UpgradeDefinition?
	local upgrade = UpgradeConfig[upgradeId]
	if type(upgrade) == "table" and upgrade.Id then
		return upgrade :: UpgradeDefinition
	end
	return nil
end

return UpgradeConfig
