--!strict
--[[
	UpgradeService.lua
	Server-authoritative store upgrades.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.Shared.Config.EconomyConfig)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)
local UIConfig = require(ReplicatedStorage.Shared.Config.UIConfig)

local RateLimiter = require(script.Parent.Parent.Utilities.RateLimiter)
local EconomyService = require(script.Parent.EconomyService)
local NotificationService = require(script.Parent.NotificationService)
local PlayerDataService = require(script.Parent.PlayerDataService)
local StoreService = require(script.Parent.StoreService)

local UpgradeService = {}

local limiter = RateLimiter.new(GameConfig.RateLimits.UpgradeWindowSeconds, GameConfig.RateLimits.UpgradeMaxRequests)

function UpgradeService.GetLevel(player: Player, upgradeId: string): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return 0
	end
	return profile.Upgrades[upgradeId] or 0
end

function UpgradeService.Purchase(player: Player, upgradeId: any): (boolean, string?)
	if not limiter:Allow(player) then
		NotificationService.Error(player, UIConfig.Texts.RateLimited)
		return false, "RateLimited"
	end
	if type(upgradeId) ~= "string" then
		return false, "InvalidUpgrade"
	end

	local def = UpgradeConfig.Get(upgradeId)
	if not def then
		return false, "InvalidUpgrade"
	end

	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "NoProfile"
	end

	local current = profile.Upgrades[upgradeId] or 0
	if current >= def.MaxLevel then
		NotificationService.Error(player, "Upgrade already maxed.")
		return false, "MaxLevel"
	end

	local cost = UpgradeConfig.GetCost(upgradeId, current)
	if not cost then
		return false, "InvalidCost"
	end

	local spent, err = EconomyService.SpendCoins(player, cost, EconomyConfig.Reasons.UpgradePurchase)
	if not spent then
		NotificationService.Error(player, UIConfig.Texts.InsufficientFunds)
		return false, err
	end

	profile.Upgrades[upgradeId] = current + 1

	if upgradeId == "Shelves" then
		local shelfCount = GameConfig.Shelves.BaseShelfCount + profile.Upgrades.Shelves * GameConfig.Shelves.ShelvesPerUpgrade
		StoreService.EnsureShelfCount(player, shelfCount)
	end

	NotificationService.Success(player, UIConfig.Texts.UpgradeComplete)
	return true, nil
end

function UpgradeService.GetShelfCount(player: Player): number
	local level = UpgradeService.GetLevel(player, "Shelves")
	return GameConfig.Shelves.BaseShelfCount + level * GameConfig.Shelves.ShelvesPerUpgrade
end

function UpgradeService.GetSpawnInterval(player: Player): number
	local level = UpgradeService.GetLevel(player, "CustomerAttraction")
	local interval = GameConfig.Customers.BaseSpawnInterval - level * 0.9
	return math.max(GameConfig.Customers.MinSpawnInterval, interval)
end

function UpgradeService.ClearRateLimit(player: Player)
	limiter:Clear(player)
end

return UpgradeService
