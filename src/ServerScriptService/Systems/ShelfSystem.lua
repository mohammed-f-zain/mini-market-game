--!strict
--[[
	ShelfSystem.lua
	Stock / destock shelves from player inventory.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local ProductConfig = require(ReplicatedStorage.Shared.Config.ProductConfig)
local UIConfig = require(ReplicatedStorage.Shared.Config.UIConfig)
local DataValidator = require(script.Parent.Parent.Utilities.DataValidator)

local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local NotificationService = require(script.Parent.Parent.Services.NotificationService)
local StoreService = require(script.Parent.Parent.Services.StoreService)
local UpgradeService = require(script.Parent.Parent.Services.UpgradeService)

local ShelfSystem = {}

function ShelfSystem.GetCapacity(_player: Player): number
	return GameConfig.Shelves.BaseCapacityPerShelf
end

function ShelfSystem.Refill(player: Player, shelfId: any, productId: any, quantity: any): (boolean, string?)
	if type(shelfId) ~= "string" or type(productId) ~= "string" then
		return false, "InvalidRequest"
	end
	if not ProductConfig.IsValid(productId) then
		return false, "InvalidProduct"
	end

	local qty = DataValidator.IsValidQuantity(quantity)
	if not qty then
		NotificationService.Error(player, UIConfig.Texts.InvalidRequest)
		return false, "InvalidQuantity"
	end

	if not StoreService.GetPlotId(player) then
		return false, "NoStore"
	end

	UpgradeService.GetShelfCount(player) -- ensure upgrades applied
	StoreService.EnsureShelfCount(player, UpgradeService.GetShelfCount(player))

	local shelf = StoreService.GetShelf(player, shelfId)
	if not shelf then
		NotificationService.Error(player, "Shelf not found.")
		return false, "InvalidShelf"
	end

	if shelf.ProductId ~= nil and shelf.ProductId ~= productId and shelf.Quantity > 0 then
		NotificationService.Error(player, "Clear shelf before stocking a different product.")
		return false, "ShelfOccupied"
	end

	local capacity = ShelfSystem.GetCapacity(player)
	local space = capacity - shelf.Quantity
	if space <= 0 then
		NotificationService.Error(player, UIConfig.Texts.ShelfFull)
		return false, "ShelfFull"
	end

	local toPlace = math.min(qty, space, InventoryService.GetQuantity(player, productId))
	if toPlace <= 0 then
		NotificationService.Error(player, UIConfig.Texts.ShelfEmpty)
		return false, "NoStock"
	end

	local removed, err = InventoryService.Remove(player, productId, toPlace)
	if not removed then
		NotificationService.Error(player, "Could not remove from inventory.")
		return false, err
	end

	shelf.ProductId = productId
	shelf.Quantity += toPlace
	StoreService.UpdateShelfVisuals(player)
	NotificationService.Success(player, string.format("Stocked %dx on %s. Customers can come now!", toPlace, shelfId))
	return true, nil
end

function ShelfSystem.TakeForCustomer(plotId: number, maxItems: number): { { ProductId: string, Quantity: number, UnitPrice: number } }
	local owner = StoreService.GetOwner(plotId)
	if not owner then
		return {}
	end

	local shelves = StoreService.GetShelves(owner)
	local basket = {}
	local remaining = maxItems

	local shelfIds = {}
	for shelfId in pairs(shelves) do
		table.insert(shelfIds, shelfId)
	end
	table.sort(shelfIds)

	for _, shelfId in ipairs(shelfIds) do
		if remaining <= 0 then
			break
		end
		local shelf = shelves[shelfId]
		if shelf.ProductId and shelf.Quantity > 0 then
			local take = math.min(1, shelf.Quantity, remaining)
			local price = ProductConfig.Get(shelf.ProductId)
			if price then
				shelf.Quantity -= take
				if shelf.Quantity <= 0 then
					shelf.Quantity = 0
					shelf.ProductId = nil
				end
				table.insert(basket, {
					ProductId = price.Id,
					Quantity = take,
					UnitPrice = price.SellPrice,
				})
				remaining -= take
			end
		end
	end

	StoreService.UpdateShelfVisuals(owner)
	return basket
end

function ShelfSystem.HasAnyStock(plotId: number): boolean
	local owner = StoreService.GetOwner(plotId)
	if not owner then
		return false
	end
	for _, shelf in pairs(StoreService.GetShelves(owner)) do
		if shelf.ProductId and shelf.Quantity > 0 then
			return true
		end
	end
	return false
end

return ShelfSystem
