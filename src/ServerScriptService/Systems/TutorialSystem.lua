--!strict
--[[
	TutorialSystem.lua
	Guided onboarding step tracking.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIConfig = require(ReplicatedStorage.Shared.Config.UIConfig)
local RemoteBootstrap = require(ReplicatedStorage.Remotes.RemoteBootstrap)

local PlayerDataService = require(script.Parent.Parent.Services.PlayerDataService)
local NotificationService = require(script.Parent.Parent.Services.NotificationService)

local TutorialSystem = {}

function TutorialSystem.GetStep(player: Player): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return 0
	end
	return profile.TutorialStep
end

function TutorialSystem.Sync(player: Player)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return
	end
	local steps = UIConfig.TutorialSteps
	local stepIndex = math.clamp(profile.TutorialStep + 1, 1, #steps)
	local step = steps[stepIndex]
	RemoteBootstrap.GetEvent("TutorialUpdate"):FireClient(player, {
		Completed = profile.TutorialCompleted,
		StepIndex = profile.TutorialStep,
		Step = if profile.TutorialCompleted then nil else step,
		TotalSteps = #steps,
	})
end

function TutorialSystem.Advance(player: Player): (boolean, string?)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "NoProfile"
	end
	if profile.TutorialCompleted then
		return true, nil
	end

	local maxStep = #UIConfig.TutorialSteps
	profile.TutorialStep = math.min(profile.TutorialStep + 1, maxStep)
	if profile.TutorialStep >= maxStep then
		profile.TutorialCompleted = true
		NotificationService.Success(player, "Tutorial complete! Grow your market.")
	end
	TutorialSystem.Sync(player)
	return true, nil
end

function TutorialSystem.MarkAction(player: Player, action: string)
	local profile = PlayerDataService.GetProfile(player)
	if not profile or profile.TutorialCompleted then
		return
	end

	local mapping = {
		Purchase = 1,
		Refill = 2,
		Sale = 3,
		Upgrade = 5,
	}
	local required = mapping[action]
	if required and profile.TutorialStep == required then
		TutorialSystem.Advance(player)
	elseif action == "Sale" and profile.TutorialStep == 3 then
		TutorialSystem.Advance(player)
		if profile.TutorialStep == 4 then
			TutorialSystem.Advance(player)
		end
	end
end

return TutorialSystem
