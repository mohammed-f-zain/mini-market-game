--!strict
--[[
	CheckoutSystem.lua
	Completes customer purchases and rewards store owners.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.Shared.Config.EconomyConfig)
local UIConfig = require(ReplicatedStorage.Shared.Config.UIConfig)

local EconomyService = require(script.Parent.Parent.Services.EconomyService)
local NotificationService = require(script.Parent.Parent.Services.NotificationService)
local StoreService = require(script.Parent.Parent.Services.StoreService)
local ProgressionSystem = require(script.Parent.ProgressionSystem)

local CheckoutSystem = {}

local processedTransactions: { [string]: boolean } = {}

function CheckoutSystem.ProcessSale(plotId: number, basket: { { ProductId: string, Quantity: number, UnitPrice: number } }, transactionId: string): boolean
	if processedTransactions[transactionId] then
		return false
	end
	if #basket == 0 then
		return false
	end

	local owner = StoreService.GetOwner(plotId)
	if not owner then
		return false
	end

	local total = 0
	local productsSold = 0
	for _, item in ipairs(basket) do
		if type(item.UnitPrice) == "number" and type(item.Quantity) == "number" then
			total += item.UnitPrice * item.Quantity
			productsSold += item.Quantity
		end
	end

	if total <= 0 then
		return false
	end

	processedTransactions[transactionId] = true

	local ok = EconomyService.AddCoins(owner, total, EconomyConfig.Reasons.CustomerSale)
	if not ok then
		processedTransactions[transactionId] = nil
		return false
	end

	ProgressionSystem.RecordSale(owner, total, productsSold)
	NotificationService.Success(owner, UIConfig.Texts.CustomerServed .. string.format(" (+%d)", total))
	return true
end

function CheckoutSystem.CleanupOldTransactions()
	-- Bound memory; transactions are short-lived IDs
	local count = 0
	for _ in pairs(processedTransactions) do
		count += 1
	end
	if count > 500 then
		table.clear(processedTransactions)
	end
end

return CheckoutSystem
