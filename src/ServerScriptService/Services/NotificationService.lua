--!strict
--[[
	NotificationService.lua
	Sends short feedback messages to clients.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteBootstrap = require(ReplicatedStorage.Remotes.RemoteBootstrap)

local NotificationService = {}

function NotificationService.Notify(player: Player, kind: string, message: string, duration: number?)
	local remote = RemoteBootstrap.GetEvent("Notify")
	remote:FireClient(player, {
		Kind = kind,
		Message = message,
		Duration = duration or 3,
	})
end

function NotificationService.Success(player: Player, message: string)
	NotificationService.Notify(player, "Success", message, 3)
end

function NotificationService.Error(player: Player, message: string)
	NotificationService.Notify(player, "Error", message, 3.5)
end

function NotificationService.Info(player: Player, message: string)
	NotificationService.Notify(player, "Info", message, 3)
end

return NotificationService
