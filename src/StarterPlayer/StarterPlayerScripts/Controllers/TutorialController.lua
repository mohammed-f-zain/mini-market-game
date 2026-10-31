--!strict
--[[
	TutorialController.lua
	Displays guided onboarding overlay.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConfig = require(ReplicatedStorage.Shared.Config.UIConfig)
local RemoteBootstrap = require(ReplicatedStorage.Remotes.RemoteBootstrap)

local TutorialController = {}

local frame: Frame?
local titleLabel: TextLabel?
local bodyLabel: TextLabel?

function TutorialController.Update(payload: any)
	if not frame or not titleLabel or not bodyLabel then
		return
	end
	if payload.Completed or not payload.Step then
		frame.Visible = false
		return
	end
	frame.Visible = true
	titleLabel.Text = payload.Step.Title
	bodyLabel.Text = string.format(
		"%s\n(%d / %d)",
		payload.Step.Body,
		(payload.StepIndex or 0) + 1,
		payload.TotalSteps or #UIConfig.TutorialSteps
	)
end

function TutorialController.Init()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "MiniMarketTutorial"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(360, 150)
	frame.Position = UDim2.new(0, 16, 1, -180)
	frame.BackgroundColor3 = UIConfig.Colors.White
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = frame

	titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 24)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = UIConfig.TitleFont
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = UIConfig.Colors.DarkText
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = ""
	titleLabel.Parent = frame

	bodyLabel = Instance.new("TextLabel")
	bodyLabel.Size = UDim2.new(1, 0, 0, 60)
	bodyLabel.Position = UDim2.fromOffset(0, 28)
	bodyLabel.BackgroundTransparency = 1
	bodyLabel.Font = UIConfig.Font
	bodyLabel.TextSize = 14
	bodyLabel.TextColor3 = UIConfig.Colors.DarkText
	bodyLabel.TextWrapped = true
	bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
	bodyLabel.Text = ""
	bodyLabel.Parent = frame

	local nextBtn = Instance.new("TextButton")
	nextBtn.Size = UDim2.fromOffset(100, 32)
	nextBtn.Position = UDim2.new(1, -100, 1, -32)
	nextBtn.BackgroundColor3 = UIConfig.Colors.Primary
	nextBtn.Text = "Next"
	nextBtn.TextColor3 = UIConfig.Colors.White
	nextBtn.Font = UIConfig.Font
	nextBtn.TextSize = 14
	nextBtn.Parent = frame
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = nextBtn

	nextBtn.MouseButton1Click:Connect(function()
		RemoteBootstrap.GetFunction("AdvanceTutorial"):InvokeServer()
	end)

	RemoteBootstrap.GetEvent("TutorialUpdate").OnClientEvent:Connect(function(payload)
		TutorialController.Update(payload)
	end)
end

return TutorialController
