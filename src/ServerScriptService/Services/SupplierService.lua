--!strict
--[[
	SupplierService.lua
	Server-authoritative wholesale product purchases.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.Shared.Config.EconomyConfig)
local UIConfig = require(ReplicatedStorage.Shared.Config.UIConfig)
local DataValidator = require(script.Parent.Parent.Utilities.DataValidator)
local RateLimiter = require(script.Parent.Parent.Utilities.RateLimiter)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local EconomyService = require(script.Parent.EconomyService)
local InventoryService = require(script.Parent.InventoryService)
local NotificationService = require(script.Parent.NotificationService)
local ProductService = require(script.Parent.ProductService)

local SupplierService = {}

local limiter = RateLimiter.new(GameConfig.RateLimits.PurchaseWindowSeconds, GameConfig.RateLimits.PurchaseMaxRequests)

function SupplierService.Purchase(player: Player, productId: string, quantity: any): (boolean, string?)
	if not limiter:Allow(player) then
		NotificationService.Error(player, UIConfig.Texts.RateLimited)
		return false, "RateLimited"
	end

	if type(productId) ~= "string" then
		return false, "InvalidProduct"
	end

	local qty = DataValidator.IsValidQuantity(quantity)
	if not qty then
		NotificationService.Error(player, UIConfig.Texts.InvalidRequest)
		return false, "InvalidQuantity"
	end

	if not ProductService.IsUnlocked(player, productId) then
		NotificationService.Error(player, "Product is locked.")
		return false, "Locked"
	end

	local unitPrice = ProductService.GetPurchasePrice(productId)
	if not unitPrice then
		return false, "InvalidProduct"
	end

	local total = unitPrice * qty
	if not EconomyService.CanAfford(player, total) then
		NotificationService.Error(player, UIConfig.Texts.InsufficientFunds)
		return false, "InsufficientFunds"
	end

	if not InventoryService.CanAdd(player, qty) then
		NotificationService.Error(player, UIConfig.Texts.InventoryFull)
		return false, "InventoryFull"
	end

	local spent, spendErr = EconomyService.SpendCoins(player, total, EconomyConfig.Reasons.SupplierPurchase)
	if not spent then
		NotificationService.Error(player, UIConfig.Texts.InsufficientFunds)
		return false, spendErr
	end

	local added, addErr = InventoryService.Add(player, productId, qty)
	if not added then
		-- Refund on failure
		EconomyService.AddCoins(player, total, EconomyConfig.Reasons.AdminAdjust)
		NotificationService.Error(player, UIConfig.Texts.InventoryFull)
		return false, addErr
	end

	NotificationService.Success(player, UIConfig.Texts.PurchaseSuccess)
	return true, nil
end

function SupplierService.ClearRateLimit(player: Player)
	limiter:Clear(player)
end

return SupplierService
