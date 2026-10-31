--!strict
--[[
	Bootstrap.server.lua
	Server entry point for Mini Market Tycoon.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

Players.CharacterAutoLoads = true

local RemoteBootstrap = require(ReplicatedStorage.Remotes.RemoteBootstrap)
local Logger = require(script.Parent.Utilities.Logger)
local MapBuilder = require(script.Parent.Utilities.MapBuilder)

local PlayerDataService = require(script.Parent.Services.PlayerDataService)
local PlayerService = require(script.Parent.Services.PlayerService)
local CustomerService = require(script.Parent.Services.CustomerService)
local MonetizationService = require(script.Parent.Services.MonetizationService)
local StoreService = require(script.Parent.Services.StoreService)

Logger.Info("Bootstrap", "Starting Mini Market Tycoon server...")

RemoteBootstrap.Init()
PlayerDataService.Init()
MapBuilder.Build()
MonetizationService.Init()
PlayerService.Init()
PlayerDataService.StartAutosave()
CustomerService.Start()

game:BindToClose(function()
	Logger.Info("Bootstrap", "Server shutting down — saving all profiles")
	CustomerService.Stop()
	CustomerService.CleanupAll()
	PlayerDataService.SaveAll("Shutdown")
	for _, player in ipairs(Players:GetPlayers()) do
		StoreService.ReleasePlot(player)
	end
	task.wait(2)
end)

Logger.Info("Bootstrap", "Server ready")
