--!strict
--[[
	CustomerService.lua
	Spawns and budgets NPC customers across occupied stores.
]]

local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local Logger = require(script.Parent.Parent.Utilities.Logger)

local StoreService = require(script.Parent.StoreService)
local UpgradeService = require(script.Parent.UpgradeService)
local CustomerAI = require(script.Parent.Parent.Systems.CustomerAI)
local ShelfSystem = require(script.Parent.Parent.Systems.ShelfSystem)

local CustomerService = {}

local activeCount = 0
local running = false
local npcFolder: Folder? = nil
local spawnPart: BasePart? = nil

local function getNpcFolder(): Folder
	if npcFolder and npcFolder.Parent then
		return npcFolder
	end
	local folder = Workspace:FindFirstChild("ActiveCustomers")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "ActiveCustomers"
		folder.Parent = Workspace
	end
	npcFolder = folder :: Folder
	return npcFolder
end

local function getSpawnCFrame(): CFrame
	if spawnPart and spawnPart.Parent then
		return spawnPart.CFrame + Vector3.new(0, 3, 0)
	end
	local map = StoreService.GetMapFolder()
	local marker = map:FindFirstChild("CustomerSpawn", true)
	if marker and marker:IsA("BasePart") then
		spawnPart = marker
		return marker.CFrame + Vector3.new(0, 3, 0)
	end
	return CFrame.new(0, 5, 40)
end

local function pickTargetPlot(): number?
	local occupied = StoreService.GetOccupiedPlots()
	local candidates = {}
	for _, plot in ipairs(occupied) do
		if ShelfSystem.HasAnyStock(plot.PlotId) then
			table.insert(candidates, plot)
		end
	end
	if #candidates == 0 then
		return nil
	end
	-- Prefer stores with higher attraction upgrades
	table.sort(candidates, function(a, b)
		local ownerA = StoreService.GetOwner(a.PlotId)
		local ownerB = StoreService.GetOwner(b.PlotId)
		local attrA = if ownerA then UpgradeService.GetLevel(ownerA, "CustomerAttraction") else 0
		local attrB = if ownerB then UpgradeService.GetLevel(ownerB, "CustomerAttraction") else 0
		if attrA == attrB then
			return a.PlotId < b.PlotId
		end
		return attrA > attrB
	end)

	-- Weighted random among top candidates
	local index = math.random(1, math.min(3, #candidates))
	return candidates[index].PlotId
end

function CustomerService.Start()
	if running then
		return
	end
	running = true
	Logger.Info("CustomerService", "Customer spawn loop started")

	task.spawn(function()
		while running do
			local interval = GameConfig.Customers.BaseSpawnInterval
			local occupied = StoreService.GetOccupiedPlots()
			if #occupied > 0 then
				local minInterval = interval
				for _, plot in ipairs(occupied) do
					local owner = StoreService.GetOwner(plot.PlotId)
					if owner then
						minInterval = math.min(minInterval, UpgradeService.GetSpawnInterval(owner))
					end
				end
				interval = minInterval
			end

			task.wait(interval)

			if activeCount >= GameConfig.Customers.MaxActive then
				continue
			end

			local plotId = pickTargetPlot()
			if not plotId then
				continue
			end

			activeCount += 1
			CustomerAI.Run(getNpcFolder(), getSpawnCFrame(), plotId, function()
				activeCount = math.max(0, activeCount - 1)
			end)
		end
	end)
end

function CustomerService.Stop()
	running = false
end

function CustomerService.GetActiveCount(): number
	return activeCount
end

function CustomerService.CleanupAll()
	local folder = getNpcFolder()
	folder:ClearAllChildren()
	activeCount = 0
end

return CustomerService
