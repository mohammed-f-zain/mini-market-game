--!strict
--[[
	DataValidator.lua
	Validates and sanitizes player profile data.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Shared.Config.EconomyConfig)
local ProductConfig = require(ReplicatedStorage.Shared.Config.ProductConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)
local TableUtils = require(ReplicatedStorage.Shared.Utils.TableUtils)

local DataValidator = {}

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function DataValidator.CreateDefaultProfile(player: Player): any
	return {
		Version = GameConfig.SchemaVersion,
		Coins = EconomyConfig.StartingCoins,
		Inventory = {},
		Upgrades = {
			Shelves = 0,
			CustomerAttraction = 0,
			StorageCapacity = 0,
		},
		Progression = {
			StoreLevel = 1,
			TotalEarned = 0,
			CustomersServed = 0,
			ProductsSold = 0,
			TimePlayed = 0,
			MilestonesClaimed = {},
		},
		TutorialStep = 0,
		TutorialCompleted = false,
		StoreName = string.format("%s's Market", player.DisplayName),
		LastSave = os.time(),
	}
end

function DataValidator.ValidateNumber(value: any, minValue: number?, maxValue: number?): number?
	if not isFiniteNumber(value) then
		return nil
	end
	local n = value :: number
	if minValue ~= nil and n < minValue then
		return nil
	end
	if maxValue ~= nil and n > maxValue then
		return nil
	end
	return n
end

function DataValidator.SanitizeProfile(raw: any, player: Player): any
	local defaults = DataValidator.CreateDefaultProfile(player)
	if type(raw) ~= "table" then
		return defaults
	end

	local profile = TableUtils.DeepCopy(defaults)

	local version = DataValidator.ValidateNumber(raw.Version, 1, 100)
	profile.Version = version or GameConfig.SchemaVersion

	local coins = DataValidator.ValidateNumber(raw.Coins, 0, EconomyConfig.MaxBalance)
	profile.Coins = if coins ~= nil then math.floor(coins) else defaults.Coins

	if type(raw.Inventory) == "table" then
		profile.Inventory = {}
		for productId, quantity in pairs(raw.Inventory) do
			if ProductConfig.IsValid(tostring(productId)) then
				local qty = DataValidator.ValidateNumber(quantity, 0, 100000)
				if qty then
					profile.Inventory[tostring(productId)] = math.floor(qty)
				end
			end
		end
	end

	if type(raw.Upgrades) == "table" then
		for upgradeId, _ in pairs(UpgradeConfig) do
			if type(UpgradeConfig[upgradeId]) == "table" and UpgradeConfig[upgradeId].Id then
				local def = UpgradeConfig[upgradeId]
				local level = DataValidator.ValidateNumber(raw.Upgrades[upgradeId], 0, def.MaxLevel)
				profile.Upgrades[upgradeId] = if level ~= nil then math.floor(level) else 0
			end
		end
	end

	if type(raw.Progression) == "table" then
		local p = raw.Progression
		profile.Progression.StoreLevel = math.floor(DataValidator.ValidateNumber(p.StoreLevel, 1, 100) or 1)
		profile.Progression.TotalEarned = math.floor(DataValidator.ValidateNumber(p.TotalEarned, 0, EconomyConfig.MaxBalance) or 0)
		profile.Progression.CustomersServed = math.floor(DataValidator.ValidateNumber(p.CustomersServed, 0, 1e9) or 0)
		profile.Progression.ProductsSold = math.floor(DataValidator.ValidateNumber(p.ProductsSold, 0, 1e9) or 0)
		profile.Progression.TimePlayed = math.floor(DataValidator.ValidateNumber(p.TimePlayed, 0, 1e12) or 0)
		if type(p.MilestonesClaimed) == "table" then
			profile.Progression.MilestonesClaimed = {}
			for key, claimed in pairs(p.MilestonesClaimed) do
				if type(key) == "string" and claimed == true then
					profile.Progression.MilestonesClaimed[key] = true
				end
			end
		end
	end

	local tutorialStep = DataValidator.ValidateNumber(raw.TutorialStep, 0, 20)
	profile.TutorialStep = if tutorialStep ~= nil then math.floor(tutorialStep) else 0
	profile.TutorialCompleted = raw.TutorialCompleted == true

	if type(raw.StoreName) == "string" and #raw.StoreName > 0 and #raw.StoreName <= 40 then
		profile.StoreName = raw.StoreName
	end

	profile.LastSave = math.floor(DataValidator.ValidateNumber(raw.LastSave, 0, 1e12) or os.time())

	-- Migrations: bump schema when older versions appear
	if profile.Version < GameConfig.SchemaVersion then
		profile.Version = GameConfig.SchemaVersion
	end

	return profile
end

function DataValidator.IsValidQuantity(quantity: any): number?
	local n = DataValidator.ValidateNumber(quantity, 1, 1000)
	if n == nil then
		return nil
	end
	if n ~= math.floor(n) then
		return nil
	end
	return n
end

return DataValidator
