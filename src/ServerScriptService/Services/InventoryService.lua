--!strict
--[[
	InventoryService.lua
	Per-player stock storage with capacity limits.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local ProductConfig = require(ReplicatedStorage.Shared.Config.ProductConfig)
local TableUtils = require(ReplicatedStorage.Shared.Utils.TableUtils)
local DataValidator = require(script.Parent.Parent.Utilities.DataValidator)
local PlayerDataService = require(script.Parent.PlayerDataService)

local InventoryService = {}

function InventoryService.GetCapacity(player: Player): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return GameConfig.Inventory.BaseCapacity
	end
	local upgradeLevel = profile.Upgrades.StorageCapacity or 0
	return GameConfig.Inventory.BaseCapacity + upgradeLevel * GameConfig.Inventory.CapacityPerUpgrade
end

function InventoryService.GetUsed(player: Player): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return 0
	end
	return TableUtils.SumValues(profile.Inventory)
end

function InventoryService.GetQuantity(player: Player, productId: string): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return 0
	end
	return profile.Inventory[productId] or 0
end

function InventoryService.CanAdd(player: Player, quantity: number): boolean
	local qty = DataValidator.IsValidQuantity(quantity)
	if not qty then
		return false
	end
	return InventoryService.GetUsed(player) + qty <= InventoryService.GetCapacity(player)
end

function InventoryService.Add(player: Player, productId: string, quantity: number): (boolean, string?)
	if not ProductConfig.IsValid(productId) then
		return false, "InvalidProduct"
	end
	local qty = DataValidator.IsValidQuantity(quantity)
	if not qty then
		return false, "InvalidQuantity"
	end
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "NoProfile"
	end
	if not InventoryService.CanAdd(player, qty) then
		return false, "InventoryFull"
	end
	profile.Inventory[productId] = (profile.Inventory[productId] or 0) + qty
	return true, nil
end

function InventoryService.Remove(player: Player, productId: string, quantity: number): (boolean, string?)
	if not ProductConfig.IsValid(productId) then
		return false, "InvalidProduct"
	end
	local qty = DataValidator.IsValidQuantity(quantity)
	if not qty then
		return false, "InvalidQuantity"
	end
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "NoProfile"
	end
	local current = profile.Inventory[productId] or 0
	if current < qty then
		return false, "InsufficientStock"
	end
	local remaining = current - qty
	if remaining <= 0 then
		profile.Inventory[productId] = nil
	else
		profile.Inventory[productId] = remaining
	end
	return true, nil
end

function InventoryService.GetAll(player: Player): { [string]: number }
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return {}
	end
	return TableUtils.DeepCopy(profile.Inventory)
end

return InventoryService
