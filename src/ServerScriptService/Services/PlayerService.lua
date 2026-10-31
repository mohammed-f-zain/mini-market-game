--!strict
--[[
	PlayerService.lua
	Player join/leave lifecycle and snapshot sync.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteBootstrap = require(ReplicatedStorage.Remotes.RemoteBootstrap)
local TableUtils = require(ReplicatedStorage.Shared.Utils.TableUtils)
local Logger = require(script.Parent.Parent.Utilities.Logger)

local PlayerDataService = require(script.Parent.PlayerDataService)
local EconomyService = require(script.Parent.EconomyService)
local StoreService = require(script.Parent.StoreService)
local InventoryService = require(script.Parent.InventoryService)
local UpgradeService = require(script.Parent.UpgradeService)
local SupplierService = require(script.Parent.SupplierService)
local CustomerService = require(script.Parent.CustomerService)
local NotificationService = require(script.Parent.NotificationService)

local ProgressionSystem = require(script.Parent.Parent.Systems.ProgressionSystem)
local TutorialSystem = require(script.Parent.Parent.Systems.TutorialSystem)
local ShelfSystem = require(script.Parent.Parent.Systems.ShelfSystem)

local PlayerService = {}

local joinTimes: { [number]: number } = {}

function PlayerService.BuildSnapshot(player: Player)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return nil
	end
	return {
		Coins = profile.Coins,
		Inventory = TableUtils.DeepCopy(profile.Inventory),
		Upgrades = TableUtils.DeepCopy(profile.Upgrades),
		Progression = TableUtils.DeepCopy(profile.Progression),
		InventoryCapacity = InventoryService.GetCapacity(player),
		InventoryUsed = InventoryService.GetUsed(player),
		PlotId = StoreService.GetPlotId(player),
		StoreName = profile.StoreName,
		TutorialStep = profile.TutorialStep,
		TutorialCompleted = profile.TutorialCompleted,
		Shelves = TableUtils.DeepCopy(StoreService.GetShelves(player)),
		Catalog = require(script.Parent.ProductService).GetCatalog(player),
		ActiveCustomers = CustomerService.GetActiveCount(),
	}
end

function PlayerService.PushSnapshot(player: Player)
	local snapshot = PlayerService.BuildSnapshot(player)
	if not snapshot then
		return
	end
	RemoteBootstrap.GetEvent("PlayerSnapshot"):FireClient(player, snapshot)
end

function PlayerService.OnPlayerAdded(player: Player)
	Logger.Info("PlayerService", "Player joining: " .. player.Name)

	local profile = PlayerDataService.LoadProfile(player)
	if not profile then
		NotificationService.Error(player, "Failed to load your data. Rejoin shortly.")
		task.delay(3, function()
			player:Kick("Data load failed. Please rejoin.")
		end)
		return
	end

	joinTimes[player.UserId] = os.time()

	local shelfCount = UpgradeService.GetShelfCount(player)
	local plotId = StoreService.AssignPlot(player, shelfCount)
	if not plotId then
		player:Kick("Server is full. No store plots available.")
		return
	end

	local function setupCharacter(character: Model)
		task.defer(function()
			StoreService.TeleportToStore(player)
		end)
	end

	if player.Character then
		setupCharacter(player.Character)
	end
	player.CharacterAdded:Connect(setupCharacter)

	TutorialSystem.Sync(player)
	PlayerService.PushSnapshot(player)
	NotificationService.Info(player, "Welcome to Mini Market Tycoon!")
end

function PlayerService.OnPlayerRemoving(player: Player)
	Logger.Info("PlayerService", "Player leaving: " .. player.Name)

	local joined = joinTimes[player.UserId]
	if joined then
		ProgressionSystem.AddTimePlayed(player, os.time() - joined)
	end

	StoreService.ReleasePlot(player)
	SupplierService.ClearRateLimit(player)
	UpgradeService.ClearRateLimit(player)
	EconomyService.ClearHistory(player)
	PlayerDataService.ReleaseProfile(player)
	joinTimes[player.UserId] = nil
end

function PlayerService.BindRemotes()
	local getSnapshot = RemoteBootstrap.GetFunction("GetSnapshot")
	getSnapshot.OnServerInvoke = function(player: Player)
		return PlayerService.BuildSnapshot(player)
	end

	local purchaseProduct = RemoteBootstrap.GetFunction("PurchaseProduct")
	purchaseProduct.OnServerInvoke = function(player: Player, productId: any, quantity: any)
		local ok, err = SupplierService.Purchase(player, productId, quantity)
		if ok then
			TutorialSystem.MarkAction(player, "Purchase")
		end
		PlayerService.PushSnapshot(player)
		return { Ok = ok, Error = err }
	end

	local refillShelf = RemoteBootstrap.GetFunction("RefillShelf")
	refillShelf.OnServerInvoke = function(player: Player, shelfId: any, productId: any, quantity: any)
		local ok, err = ShelfSystem.Refill(player, shelfId, productId, quantity)
		if ok then
			TutorialSystem.MarkAction(player, "Refill")
		end
		PlayerService.PushSnapshot(player)
		return { Ok = ok, Error = err }
	end

	local purchaseUpgrade = RemoteBootstrap.GetFunction("PurchaseUpgrade")
	purchaseUpgrade.OnServerInvoke = function(player: Player, upgradeId: any)
		local ok, err = UpgradeService.Purchase(player, upgradeId)
		if ok then
			TutorialSystem.MarkAction(player, "Upgrade")
		end
		PlayerService.PushSnapshot(player)
		return { Ok = ok, Error = err }
	end

	local advanceTutorial = RemoteBootstrap.GetFunction("AdvanceTutorial")
	advanceTutorial.OnServerInvoke = function(player: Player)
		local ok, err = TutorialSystem.Advance(player)
		PlayerService.PushSnapshot(player)
		return { Ok = ok, Error = err }
	end

	local setStoreName = RemoteBootstrap.GetFunction("SetStoreName")
	setStoreName.OnServerInvoke = function(player: Player, name: any)
		if type(name) ~= "string" or #name < 3 or #name > 40 then
			return { Ok = false, Error = "InvalidName" }
		end
		local profile = PlayerDataService.GetProfile(player)
		if not profile then
			return { Ok = false, Error = "NoProfile" }
		end
		profile.StoreName = name
		local plotId = StoreService.GetPlotId(player)
		if plotId then
			local plot = StoreService.GetPlot(plotId)
			if plot and plot.Model then
				local sign = plot.Model:FindFirstChild("StoreSign", true)
				if sign and sign:IsA("BasePart") then
					local gui = sign:FindFirstChildOfClass("SurfaceGui")
					if gui then
						local label = gui:FindFirstChildWhichIsA("TextLabel")
						if label then
							label.Text = name
						end
					end
				end
			end
		end
		PlayerService.PushSnapshot(player)
		return { Ok = true }
	end
end

function PlayerService.Init()
	PlayerService.BindRemotes()

	Players.PlayerAdded:Connect(PlayerService.OnPlayerAdded)
	Players.PlayerRemoving:Connect(PlayerService.OnPlayerRemoving)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(PlayerService.OnPlayerAdded, player)
	end

	-- Periodic snapshot + time tracking
	task.spawn(function()
		while true do
			task.wait(5)
			for _, player in ipairs(Players:GetPlayers()) do
				if PlayerDataService.GetProfile(player) then
					PlayerService.PushSnapshot(player)
				end
			end
		end
	end)
end

return PlayerService
