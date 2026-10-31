--!strict
--[[
	ProductService.lua
	Product catalog access and pricing (server authority).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProductConfig = require(ReplicatedStorage.Shared.Config.ProductConfig)
local PlayerDataService = require(script.Parent.PlayerDataService)

local ProductService = {}

function ProductService.GetDefinition(productId: string)
	return ProductConfig.Get(productId)
end

function ProductService.GetPurchasePrice(productId: string): number?
	local def = ProductConfig.Get(productId)
	return if def then def.PurchasePrice else nil
end

function ProductService.GetSellPrice(productId: string): number?
	local def = ProductConfig.Get(productId)
	return if def then def.SellPrice else nil
end

function ProductService.IsUnlocked(player: Player, productId: string): boolean
	local def = ProductConfig.Get(productId)
	if not def then
		return false
	end
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false
	end
	return profile.Progression.StoreLevel >= def.UnlockStoreLevel
end

function ProductService.GetCatalog(player: Player)
	local list = {}
	for _, product in ipairs(ProductConfig.GetAll()) do
		table.insert(list, {
			Id = product.Id,
			DisplayName = product.DisplayName,
			Description = product.Description,
			PurchasePrice = product.PurchasePrice,
			SellPrice = product.SellPrice,
			Unlocked = ProductService.IsUnlocked(player, product.Id),
			IconColor = { product.IconColor.R, product.IconColor.G, product.IconColor.B },
		})
	end
	return list
end

return ProductService
