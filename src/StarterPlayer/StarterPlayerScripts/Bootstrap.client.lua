--!strict
--[[
	Bootstrap.client.lua
	Client entry point for Mini Market Tycoon.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteBootstrap = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteBootstrap"))

-- Ensure remotes exist (server creates them; wait for Events/Functions)
ReplicatedStorage.Remotes:WaitForChild("Events")
ReplicatedStorage.Remotes:WaitForChild("Functions")

local Controllers = script.Parent.Controllers
local UIController = require(Controllers.UIController)
local NotificationController = require(Controllers.NotificationController)
local TutorialController = require(Controllers.TutorialController)
local ShopController = require(Controllers.ShopController)
local InventoryController = require(Controllers.InventoryController)
local StoreController = require(Controllers.StoreController)
local CameraController = require(Controllers.CameraController)

UIController.Init()
NotificationController.Init()
TutorialController.Init()
ShopController.Init()
InventoryController.Init()
StoreController.Init()
CameraController.Init()

RemoteBootstrap.GetEvent("PlayerSnapshot").OnClientEvent:Connect(function(snapshot)
	UIController.UpdateSnapshot(snapshot)
end)

-- Initial snapshot request
task.spawn(function()
	local player = Players.LocalPlayer
	player:WaitForChild("PlayerGui")
	task.wait(0.5)
	local ok, snapshot = pcall(function()
		return RemoteBootstrap.GetFunction("GetSnapshot"):InvokeServer()
	end)
	if ok and snapshot then
		UIController.UpdateSnapshot(snapshot)
	end
end)

print("[MiniMarket] Client ready")
