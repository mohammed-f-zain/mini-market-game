--!strict
--[[
	CameraController.lua
	Optional camera framing helpers.
]]

local Players = game:GetService("Players")

local CameraController = {}

function CameraController.Init()
	local player = Players.LocalPlayer
	-- Default Roblox camera; future polish can add store overview shot.
	player.CameraMaxZoomDistance = 64
	player.CameraMinZoomDistance = 8
end

return CameraController
