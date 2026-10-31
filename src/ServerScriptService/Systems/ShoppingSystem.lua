--!strict
--[[
	ShoppingSystem.lua
	Customer product selection from shelves.
]]

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.Config.GameConfig)
local ShelfSystem = require(script.Parent.ShelfSystem)

local ShoppingSystem = {}

function ShoppingSystem.SelectBasket(plotId: number): { { ProductId: string, Quantity: number, UnitPrice: number } }
	local maxItems = math.random(1, GameConfig.Customers.MaxBasketItems)
	return ShelfSystem.TakeForCustomer(plotId, maxItems)
end

return ShoppingSystem
