--!strict
--[[
	RemoteBootstrap.lua
	Creates and returns RemoteEvent / RemoteFunction instances.
	Called once from the server; clients wait for children.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = script.Parent

local EVENT_NAMES = {
	"Notify",
	"PlayerSnapshot",
	"TutorialUpdate",
	"MilestoneUnlocked",
}

local FUNCTION_NAMES = {
	"GetSnapshot",
	"PurchaseProduct",
	"RefillShelf",
	"PurchaseUpgrade",
	"AdvanceTutorial",
	"SetStoreName",
}

local RemoteBootstrap = {}

local function ensureFolder(name: string): Folder
	local folder = RemotesFolder:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = RemotesFolder
	end
	return folder :: Folder
end

local function ensureRemoteEvent(parent: Folder, name: string): RemoteEvent
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = parent
	return remote
end

local function ensureRemoteFunction(parent: Folder, name: string): RemoteFunction
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("RemoteFunction") then
		return existing
	end
	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = parent
	return remote
end

function RemoteBootstrap.Init()
	local events = ensureFolder("Events")
	local functions = ensureFolder("Functions")

	for _, name in ipairs(EVENT_NAMES) do
		ensureRemoteEvent(events, name)
	end
	for _, name in ipairs(FUNCTION_NAMES) do
		ensureRemoteFunction(functions, name)
	end

	-- Ensure Remotes folder is discoverable under ReplicatedStorage
	if RemotesFolder.Parent ~= ReplicatedStorage then
		RemotesFolder.Parent = ReplicatedStorage
	end
end

function RemoteBootstrap.GetEvent(name: string): RemoteEvent
	local events = RemotesFolder:WaitForChild("Events")
	return events:WaitForChild(name) :: RemoteEvent
end

function RemoteBootstrap.GetFunction(name: string): RemoteFunction
	local functions = RemotesFolder:WaitForChild("Functions")
	return functions:WaitForChild(name) :: RemoteFunction
end

return RemoteBootstrap
