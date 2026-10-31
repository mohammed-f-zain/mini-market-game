--!strict
--[[
	ProgressionSystem.lua
	Tracks stats and grants milestone rewards.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.Shared.Config.EconomyConfig)
local RemoteBootstrap = require(ReplicatedStorage.Remotes.RemoteBootstrap)

local EconomyService = require(script.Parent.Parent.Services.EconomyService)
local NotificationService = require(script.Parent.Parent.Services.NotificationService)
local PlayerDataService = require(script.Parent.Parent.Services.PlayerDataService)

local ProgressionSystem = {}

local MILESTONES = {
	{
		Id = "Customers10",
		Description = "Serve 10 customers",
		Check = function(p)
			return p.CustomersServed >= 10
		end,
		Reward = 100,
	},
	{
		Id = "Earned1000",
		Description = "Earn 1,000 coins",
		Check = function(p)
			return p.TotalEarned >= 1000
		end,
		Reward = 150,
	},
	{
		Id = "Sold50",
		Description = "Sell 50 products",
		Check = function(p)
			return p.ProductsSold >= 50
		end,
		Reward = 200,
	},
	{
		Id = "StoreLevel5",
		Description = "Reach store level 5",
		Check = function(p)
			return p.StoreLevel >= 5
		end,
		Reward = 300,
	},
}

local function recomputeStoreLevel(profile: any)
	local earned = profile.Progression.TotalEarned
	local level = 1 + math.floor(earned / 500)
	profile.Progression.StoreLevel = math.clamp(level, 1, 50)
end

function ProgressionSystem.RecordSale(player: Player, coinsEarned: number, productsSold: number)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return
	end
	profile.Progression.TotalEarned += coinsEarned
	profile.Progression.CustomersServed += 1
	profile.Progression.ProductsSold += productsSold
	recomputeStoreLevel(profile)
	ProgressionSystem.EvaluateMilestones(player)
end

function ProgressionSystem.AddTimePlayed(player: Player, seconds: number)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return
	end
	profile.Progression.TimePlayed += seconds
end

function ProgressionSystem.EvaluateMilestones(player: Player)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return
	end

	for _, milestone in ipairs(MILESTONES) do
		if not profile.Progression.MilestonesClaimed[milestone.Id] and milestone.Check(profile.Progression) then
			profile.Progression.MilestonesClaimed[milestone.Id] = true
			EconomyService.AddCoins(player, milestone.Reward, EconomyConfig.Reasons.MilestoneReward)
			NotificationService.Success(player, "Milestone: " .. milestone.Description)
			RemoteBootstrap.GetEvent("MilestoneUnlocked"):FireClient(player, {
				Id = milestone.Id,
				Description = milestone.Description,
				Reward = milestone.Reward,
			})
		end
	end
end

return ProgressionSystem
