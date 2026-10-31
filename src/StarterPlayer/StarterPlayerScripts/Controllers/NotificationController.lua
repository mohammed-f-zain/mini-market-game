--!strict
--[[
	NotificationController.lua
	Toast notifications for feedback.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConfig = require(ReplicatedStorage.Shared.Config.UIConfig)
local RemoteBootstrap = require(ReplicatedStorage.Remotes.RemoteBootstrap)

local NotificationController = {}

local gui: ScreenGui
local queue: Frame

local function colorFor(kind: string): Color3
	if kind == "Success" then
		return UIConfig.Colors.Success
	elseif kind == "Error" then
		return UIConfig.Colors.Error
	end
	return UIConfig.Colors.Primary
end

function NotificationController.Show(payload: { Kind: string, Message: string, Duration: number? })
	if not queue then
		return
	end

	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(0, 320, 0, 48)
	toast.BackgroundColor3 = colorFor(payload.Kind)
	toast.BorderSizePixel = 0
	toast.Parent = queue

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = toast

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 1, 0)
	label.Position = UDim2.fromOffset(8, 0)
	label.BackgroundTransparency = 1
	label.Text = payload.Message
	label.TextColor3 = UIConfig.Colors.White
	label.Font = UIConfig.Font
	label.TextSize = 14
	label.TextWrapped = true
	label.Parent = toast

	toast.BackgroundTransparency = 1
	label.TextTransparency = 1
	TweenService:Create(toast, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(label, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()

	task.delay(payload.Duration or 3, function()
		local t1 = TweenService:Create(toast, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
		local t2 = TweenService:Create(label, TweenInfo.new(0.25), { TextTransparency = 1 })
		t1:Play()
		t2:Play()
		t1.Completed:Wait()
		toast:Destroy()
	end)
end

function NotificationController.Init()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	gui = Instance.new("ScreenGui")
	gui.Name = "MiniMarketToasts"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	queue = Instance.new("Frame")
	queue.Name = "Queue"
	queue.Size = UDim2.new(0, 340, 0, 400)
	queue.Position = UDim2.new(0.5, -170, 1, -220)
	queue.BackgroundTransparency = 1
	queue.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Parent = queue

	RemoteBootstrap.GetEvent("Notify").OnClientEvent:Connect(function(payload)
		NotificationController.Show(payload)
	end)

	RemoteBootstrap.GetEvent("MilestoneUnlocked").OnClientEvent:Connect(function(payload)
		NotificationController.Show({
			Kind = "Success",
			Message = "Milestone: " .. tostring(payload.Description) .. " (+" .. tostring(payload.Reward) .. ")",
			Duration = 4,
		})
	end)
end

return NotificationController
