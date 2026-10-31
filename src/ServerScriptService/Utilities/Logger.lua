--!strict
--[[
	Logger.lua
	Lightweight structured logging for server diagnostics.
]]

local Logger = {}

local PREFIX = "[MiniMarket]"

local function formatMessage(level: string, scope: string, message: string): string
	return string.format("%s [%s] [%s] %s", PREFIX, level, scope, message)
end

function Logger.Info(scope: string, message: string)
	print(formatMessage("INFO", scope, message))
end

function Logger.Warn(scope: string, message: string)
	warn(formatMessage("WARN", scope, message))
end

function Logger.Error(scope: string, message: string)
	warn(formatMessage("ERROR", scope, message))
end

function Logger.Debug(scope: string, message: string)
	if game:GetService("RunService"):IsStudio() then
		print(formatMessage("DEBUG", scope, message))
	end
end

return Logger
