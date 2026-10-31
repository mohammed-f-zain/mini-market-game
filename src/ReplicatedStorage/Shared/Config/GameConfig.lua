--!strict
--[[
	GameConfig.lua
	Global game settings for Mini Market Tycoon.
]]

local GameConfig = {
	GameName = "Mini Market Tycoon",
	MaxPlayers = 12,
	StartingCoins = 500,
	AutosaveIntervalSeconds = 60,
	SchemaVersion = 1,

	Colors = {
		Primary = Color3.fromHex("28A9E0"),
		Secondary = Color3.fromHex("38C985"),
		Accent = Color3.fromHex("FFC857"),
		Background = Color3.fromHex("F4F7FA"),
		DarkText = Color3.fromHex("202A35"),
		White = Color3.fromHex("FFFFFF"),
		Error = Color3.fromHex("E74C3C"),
		Success = Color3.fromHex("27AE60"),
	},

	Map = {
		PlotCount = 12,
		PlotSpacing = 48,
		RoadWidth = 16,
		StoreSize = Vector3.new(36, 12, 28),
		NeighborhoodCenter = Vector3.new(0, 0, 0),
	},

	Customers = {
		MaxActive = 24,
		BaseSpawnInterval = 8,
		MinSpawnInterval = 3,
		WalkSpeed = 12,
		BrowseTimeMin = 1.5,
		BrowseTimeMax = 3.5,
		MaxBasketItems = 3,
	},

	Inventory = {
		BaseCapacity = 50,
		CapacityPerUpgrade = 25,
	},

	Shelves = {
		BaseShelfCount = 3,
		ShelvesPerUpgrade = 1,
		BaseCapacityPerShelf = 20,
	},

	DataStore = {
		Name = "MiniMarketPlayerData_v1",
		SessionLockTimeoutSeconds = 30,
		MaxRetries = 5,
		BaseRetryDelay = 1,
	},

	RateLimits = {
		DefaultWindowSeconds = 1,
		DefaultMaxRequests = 8,
		PurchaseWindowSeconds = 1,
		PurchaseMaxRequests = 4,
		UpgradeWindowSeconds = 2,
		UpgradeMaxRequests = 3,
	},
}

return GameConfig
