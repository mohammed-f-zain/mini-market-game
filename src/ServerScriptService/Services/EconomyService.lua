--!strict
--[[
	EconomyService.lua
	Centralized currency management. All coin changes go through here.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.Shared.Config.EconomyConfig)
local DataValidator = require(script.Parent.Parent.Utilities.DataValidator)
local Logger = require(script.Parent.Parent.Utilities.Logger)
local PlayerDataService = require(script.Parent.PlayerDataService)

local EconomyService = {}

local history: { [number]: { any } } = {}
local MAX_HISTORY = 50

local function pushHistory(player: Player, reason: string, amount: number, balanceAfter: number)
	local userId = player.UserId
	history[userId] = history[userId] or {}
	table.insert(history[userId], {
		Reason = reason,
		Amount = amount,
		BalanceAfter = balanceAfter,
		Timestamp = os.time(),
	})
	while #history[userId] > MAX_HISTORY do
		table.remove(history[userId], 1)
	end
end

function EconomyService.GetBalance(player: Player): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return 0
	end
	return profile.Coins
end

function EconomyService.CanAfford(player: Player, amount: number): boolean
	local validated = DataValidator.ValidateNumber(amount, EconomyConfig.MinTransaction, EconomyConfig.MaxTransaction)
	if validated == nil then
		return false
	end
	return EconomyService.GetBalance(player) >= validated
end

function EconomyService.AddCoins(player: Player, amount: number, reason: string): (boolean, string?)
	local validated = DataValidator.ValidateNumber(amount, EconomyConfig.MinTransaction, EconomyConfig.MaxTransaction)
	if validated == nil then
		return false, "InvalidAmount"
	end
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "NoProfile"
	end

	local nextBalance = math.min(profile.Coins + math.floor(validated), EconomyConfig.MaxBalance)
	local granted = nextBalance - profile.Coins
	profile.Coins = nextBalance
	pushHistory(player, reason, granted, nextBalance)
	Logger.Debug("EconomyService", string.format("%s +%d (%s) => %d", player.Name, granted, reason, nextBalance))
	return true, nil
end

function EconomyService.SpendCoins(player: Player, amount: number, reason: string): (boolean, string?)
	local validated = DataValidator.ValidateNumber(amount, EconomyConfig.MinTransaction, EconomyConfig.MaxTransaction)
	if validated == nil then
		return false, "InvalidAmount"
	end
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "NoProfile"
	end

	local cost = math.floor(validated)
	if profile.Coins < cost then
		return false, "InsufficientFunds"
	end

	profile.Coins -= cost
	pushHistory(player, reason, -cost, profile.Coins)
	Logger.Debug("EconomyService", string.format("%s -%d (%s) => %d", player.Name, cost, reason, profile.Coins))
	return true, nil
end

function EconomyService.GetHistory(player: Player): { any }
	return history[player.UserId] or {}
end

function EconomyService.ClearHistory(player: Player)
	history[player.UserId] = nil
end

return EconomyService
