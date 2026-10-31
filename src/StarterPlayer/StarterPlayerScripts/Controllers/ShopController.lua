--!strict
--[[
	ShopController.lua
	Thin wrapper around supplier shop UI actions.
]]

local UIController = require(script.Parent.UIController)

local ShopController = {}

function ShopController.Init()
	-- UIController owns panel rendering; this module is reserved for shop-specific UX.
end

function ShopController.Open()
	UIController.ShowShop()
end

return ShopController
