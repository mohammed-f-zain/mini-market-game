--!strict
--[[
	UIConfig.lua
	UI layout and text constants.
]]

local GameConfig = require(script.Parent.GameConfig)

local UIConfig = {
	Font = Enum.Font.GothamMedium,
	TitleFont = Enum.Font.GothamBold,
	CornerRadius = UDim.new(0, 8),

	Hud = {
		Height = 56,
		Padding = 12,
	},

	Panel = {
		Width = 420,
		MaxHeight = 520,
	},

	Texts = {
		Welcome = "Welcome to Mini Market Tycoon!",
		PurchaseSuccess = "Purchase successful.",
		InsufficientFunds = "Not enough coins.",
		InventoryFull = "Inventory is full.",
		UpgradeComplete = "Upgrade completed!",
		CustomerServed = "Customer served!",
		InvalidRequest = "Invalid request.",
		RateLimited = "Too many requests. Please wait.",
		ShelfEmpty = "No stock available for that shelf.",
		ShelfFull = "Shelf is already full.",
	},

	Colors = GameConfig.Colors,

	TutorialSteps = {
		{
			Id = "Welcome",
			Title = "Welcome!",
			Body = "You own a small supermarket. Grow it into a thriving business!",
		},
		{
			Id = "BuyStock",
			Title = "Buy Stock",
			Body = "Open the Supplier Shop and purchase your first products.",
		},
		{
			Id = "StockShelves",
			Title = "Stock Shelves",
			Body = "Use Inventory to refill a shelf with products.",
		},
		{
			Id = "ServeCustomer",
			Title = "Serve Customers",
			Body = "Customers will browse and buy from your shelves automatically.",
		},
		{
			Id = "EarnProfit",
			Title = "Earn Profit",
			Body = "Watch your coins grow as sales complete at checkout.",
		},
		{
			Id = "BuyUpgrade",
			Title = "Upgrade",
			Body = "Spend profits on upgrades to expand and attract more customers.",
		},
	},
}

return UIConfig
