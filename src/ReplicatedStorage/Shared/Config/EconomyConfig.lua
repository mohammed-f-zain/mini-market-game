--!strict
--[[
	EconomyConfig.lua
	Economy rules and transaction reasons.
]]

local EconomyConfig = {
	StartingCoins = 500,
	MinTransaction = 1,
	MaxTransaction = 1_000_000,
	MaxBalance = 100_000_000,

	Reasons = {
		StartingBalance = "StartingBalance",
		SupplierPurchase = "SupplierPurchase",
		CustomerSale = "CustomerSale",
		UpgradePurchase = "UpgradePurchase",
		MilestoneReward = "MilestoneReward",
		DeveloperProduct = "DeveloperProduct",
		AdminAdjust = "AdminAdjust",
	},
}

return EconomyConfig
