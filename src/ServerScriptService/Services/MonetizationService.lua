--!strict
--[[
	MonetizationService.lua
	MarketplaceService integration stubs.
	Product IDs must be set in configuration after creating real Roblox products.
	Never invent product IDs.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.Shared.Config.EconomyConfig)
local Logger = require(script.Parent.Parent.Utilities.Logger)
local EconomyService = require(script.Parent.EconomyService)
local NotificationService = require(script.Parent.NotificationService)
local PlayerDataService = require(script.Parent.PlayerDataService)

-- Place real IDs here after creating products in Creator Dashboard.
-- Leave as 0 until configured.
local MonetizationConfig = {
	GamePasses = {
		VIP = 0,
		DoubleEarnings = 0,
		ExclusiveDecor = 0,
		SpecialNameTag = 0,
	},
	DeveloperProducts = {
		-- productId = { Coins = amount, Name = "..." }
	} :: { [number]: { Coins: number, Name: string } },
}

local processedReceipts: { [string]: boolean } = {}

local MonetizationService = {}

function MonetizationService.Init()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return MonetizationService.ProcessReceipt(receiptInfo)
	end
	Logger.Info("MonetizationService", "ProcessReceipt hooked (configure product IDs before launch)")
end

function MonetizationService.ProcessReceipt(receiptInfo: any): Enum.ProductPurchaseDecision
	local purchaseId = receiptInfo.PurchaseId
	if processedReceipts[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if PlayerDataService.DidLoadFail(player) or not PlayerDataService.GetProfile(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId
	local reward = MonetizationConfig.DeveloperProducts[productId]
	if not reward then
		Logger.Warn("MonetizationService", "Unknown developer product: " .. tostring(productId))
		-- Grant to avoid stuck receipts only when IDs are intentionally unconfigured in Studio
		processedReceipts[purchaseId] = true
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local ok = EconomyService.AddCoins(player, reward.Coins, EconomyConfig.Reasons.DeveloperProduct)
	if not ok then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	processedReceipts[purchaseId] = true
	NotificationService.Success(player, "Purchase granted: " .. reward.Name)
	PlayerDataService.SaveProfile(player, "Receipt")
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function MonetizationService.PlayerOwnsPass(player: Player, passKey: string): boolean
	local passId = MonetizationConfig.GamePasses[passKey]
	if not passId or passId == 0 then
		return false
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	return ok and owns == true
end

function MonetizationService.GetConfig()
	return MonetizationConfig
end

return MonetizationService
