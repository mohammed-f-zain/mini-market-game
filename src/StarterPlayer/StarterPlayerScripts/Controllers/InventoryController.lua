--!strict
--[[
	InventoryController.lua
	Thin wrapper around inventory panel.
]]

local UIController = require(script.Parent.UIController)

local InventoryController = {}

function InventoryController.Init() end

function InventoryController.Open()
	UIController.ShowInventory()
end

return InventoryController
