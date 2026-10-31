--!strict
--[[
	StoreService.lua
	Plot assignment, store ownership, and shelf state.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local Logger = require(script.Parent.Parent.Utilities.Logger)

local StoreService = {}

export type PlotInfo = {
	PlotId: number,
	OwnerUserId: number?,
	Model: Model?,
	SpawnCFrame: CFrame,
	EntranceCFrame: CFrame,
	CheckoutCFrame: CFrame,
	ShelfAnchors: { BasePart },
}

local plots: { [number]: PlotInfo } = {}
local ownerToPlot: { [number]: number } = {}
local shelvesByPlot: { [number]: { [string]: { ProductId: string?, Quantity: number } } } = {}

local function buildShelfState(shelfCount: number): { [string]: { ProductId: string?, Quantity: number } }
	local shelves = {}
	for i = 1, shelfCount do
		shelves["Shelf_" .. tostring(i)] = {
			ProductId = nil,
			Quantity = 0,
		}
	end
	return shelves
end

function StoreService.RegisterPlot(plotId: number, model: Model)
	local spawn = model:FindFirstChild("Spawn", true)
	local entrance = model:FindFirstChild("Entrance", true)
	local checkout = model:FindFirstChild("Checkout", true)

	local spawnPart = if spawn and spawn:IsA("BasePart") then spawn else model:FindFirstChildWhichIsA("BasePart", true)
	local entrancePart = if entrance and entrance:IsA("BasePart") then entrance else spawnPart
	local checkoutPart = if checkout and checkout:IsA("BasePart") then checkout else spawnPart

	local shelfAnchors: { BasePart } = {}
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and CollectionService:HasTag(descendant, "ShelfAnchor") then
			table.insert(shelfAnchors, descendant)
		end
	end
	table.sort(shelfAnchors, function(a, b)
		return a.Name < b.Name
	end)

	plots[plotId] = {
		PlotId = plotId,
		OwnerUserId = nil,
		Model = model,
		SpawnCFrame = if spawnPart then spawnPart.CFrame + Vector3.new(0, 3, 0) else CFrame.new(0, 5, 0),
		EntranceCFrame = if entrancePart then entrancePart.CFrame else CFrame.new(0, 5, 0),
		CheckoutCFrame = if checkoutPart then checkoutPart.CFrame else CFrame.new(0, 5, 0),
		ShelfAnchors = shelfAnchors,
	}

	model:SetAttribute("PlotId", plotId)
	model:SetAttribute("OwnerUserId", 0)
	CollectionService:AddTag(model, "StorePlot")
end

function StoreService.GetAvailablePlotId(): number?
	for plotId = 1, GameConfig.MaxPlayers do
		local plot = plots[plotId]
		if plot and plot.OwnerUserId == nil then
			return plotId
		end
	end
	return nil
end

function StoreService.AssignPlot(player: Player, shelfCount: number): number?
	if ownerToPlot[player.UserId] then
		return ownerToPlot[player.UserId]
	end

	local plotId = StoreService.GetAvailablePlotId()
	if not plotId then
		Logger.Error("StoreService", "No free plots for " .. player.Name)
		return nil
	end

	local plot = plots[plotId]
	plot.OwnerUserId = player.UserId
	ownerToPlot[player.UserId] = plotId
	shelvesByPlot[plotId] = buildShelfState(shelfCount)

	if plot.Model then
		plot.Model:SetAttribute("OwnerUserId", player.UserId)
		plot.Model:SetAttribute("OwnerName", player.DisplayName)
		local sign = plot.Model:FindFirstChild("StoreSign", true)
		if sign and sign:IsA("BasePart") then
			local gui = sign:FindFirstChildOfClass("SurfaceGui")
			if gui then
				local label = gui:FindFirstChildWhichIsA("TextLabel")
				if label then
					label.Text = player.DisplayName .. "'s Market"
				end
			end
		end
	end

	Logger.Info("StoreService", string.format("Assigned plot %d to %s", plotId, player.Name))
	return plotId
end

function StoreService.ReleasePlot(player: Player)
	local plotId = ownerToPlot[player.UserId]
	if not plotId then
		return
	end
	local plot = plots[plotId]
	if plot then
		plot.OwnerUserId = nil
		if plot.Model then
			plot.Model:SetAttribute("OwnerUserId", 0)
			plot.Model:SetAttribute("OwnerName", "Vacant")
		end
	end
	shelvesByPlot[plotId] = nil
	ownerToPlot[player.UserId] = nil
	Logger.Info("StoreService", string.format("Released plot %d from %s", plotId, player.Name))
end

function StoreService.GetPlotId(player: Player): number?
	return ownerToPlot[player.UserId]
end

function StoreService.GetPlot(plotId: number): PlotInfo?
	return plots[plotId]
end

function StoreService.GetOwner(plotId: number): Player?
	local plot = plots[plotId]
	if not plot or not plot.OwnerUserId then
		return nil
	end
	return Players:GetPlayerByUserId(plot.OwnerUserId)
end

function StoreService.OwnsPlot(player: Player, plotId: number): boolean
	return ownerToPlot[player.UserId] == plotId
end

function StoreService.GetShelves(player: Player): { [string]: { ProductId: string?, Quantity: number } }
	local plotId = ownerToPlot[player.UserId]
	if not plotId then
		return {}
	end
	return shelvesByPlot[plotId] or {}
end

function StoreService.GetShelf(player: Player, shelfId: string): { ProductId: string?, Quantity: number }?
	local shelves = StoreService.GetShelves(player)
	return shelves[shelfId]
end

function StoreService.EnsureShelfCount(player: Player, shelfCount: number)
	local plotId = ownerToPlot[player.UserId]
	if not plotId then
		return
	end
	local shelves = shelvesByPlot[plotId]
	if not shelves then
		shelvesByPlot[plotId] = buildShelfState(shelfCount)
		return
	end
	for i = 1, shelfCount do
		local id = "Shelf_" .. tostring(i)
		if not shelves[id] then
			shelves[id] = { ProductId = nil, Quantity = 0 }
		end
	end
end

function StoreService.GetOccupiedPlots(): { PlotInfo }
	local occupied = {}
	for _, plot in pairs(plots) do
		if plot.OwnerUserId then
			table.insert(occupied, plot)
		end
	end
	return occupied
end

function StoreService.TeleportToStore(player: Player)
	local plotId = ownerToPlot[player.UserId]
	if not plotId then
		return
	end
	local plot = plots[plotId]
	local character = player.Character
	if plot and character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then
			hrp.CFrame = plot.SpawnCFrame
		end
	end
end

function StoreService.GetMapFolder(): Folder
	local map = Workspace:FindFirstChild("Map")
	if not map then
		map = Instance.new("Folder")
		map.Name = "Map"
		map.Parent = Workspace
	end
	return map :: Folder
end

return StoreService
