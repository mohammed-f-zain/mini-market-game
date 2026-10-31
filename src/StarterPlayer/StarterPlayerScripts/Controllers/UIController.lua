--!strict
--[[
	UIController.lua
	Builds and manages the main HUD and panels.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIConfig = require(ReplicatedStorage.Shared.Config.UIConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)
local FormatNumber = require(ReplicatedStorage.Shared.Utils.FormatNumber)
local RemoteBootstrap = require(ReplicatedStorage.Remotes.RemoteBootstrap)

local UIController = {}

local player = Players.LocalPlayer
local playerGui: PlayerGui
local root: ScreenGui
local hudFrame: Frame
local coinsLabel: TextLabel
local levelLabel: TextLabel
local customersLabel: TextLabel
local panelHost: Frame
local activePanel: string? = nil
local snapshot: any = nil
local busy = false

local function corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
end

local function pad(parent: Instance, px: number)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, px)
	p.PaddingBottom = UDim.new(0, px)
	p.PaddingLeft = UDim.new(0, px)
	p.PaddingRight = UDim.new(0, px)
	p.Parent = parent
end

local function makeButton(text: string, color: Color3, parent: Instance, callback: () -> ()): TextButton
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 110, 0, 36)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = UIConfig.Colors.White
	btn.Font = UIConfig.Font
	btn.TextSize = 14
	btn.AutoButtonColor = true
	btn.Parent = parent
	corner(btn, 8)
	btn.MouseButton1Click:Connect(function()
		if busy then
			return
		end
		callback()
	end)
	return btn
end

local function clearPanel()
	for _, child in ipairs(panelHost:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	activePanel = nil
end

local function openPanel(name: string, builder: (Frame) -> ())
	if activePanel == name then
		clearPanel()
		return
	end
	clearPanel()
	activePanel = name

	local panel = Instance.new("Frame")
	panel.Name = name
	panel.Size = UDim2.fromOffset(UIConfig.Panel.Width, UIConfig.Panel.MaxHeight)
	panel.Position = UDim2.new(1, -UIConfig.Panel.Width - 16, 0, 80)
	panel.BackgroundColor3 = UIConfig.Colors.White
	panel.BorderSizePixel = 0
	panel.Parent = panelHost
	corner(panel, 12)
	pad(panel, 12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 28)
	title.BackgroundTransparency = 1
	title.Text = name
	title.Font = UIConfig.TitleFont
	title.TextSize = 20
	title.TextColor3 = UIConfig.Colors.DarkText
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local close = Instance.new("TextButton")
	close.Size = UDim2.fromOffset(28, 28)
	close.Position = UDim2.new(1, -28, 0, 0)
	close.BackgroundColor3 = UIConfig.Colors.Background
	close.Text = "X"
	close.TextColor3 = UIConfig.Colors.DarkText
	close.Font = UIConfig.Font
	close.Parent = panel
	corner(close, 6)
	close.MouseButton1Click:Connect(clearPanel)

	local body = Instance.new("ScrollingFrame")
	body.Name = "Body"
	body.Size = UDim2.new(1, 0, 1, -40)
	body.Position = UDim2.fromOffset(0, 36)
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.ScrollBarThickness = 6
	body.CanvasSize = UDim2.new(0, 0, 0, 0)
	body.AutomaticCanvasSize = Enum.AutomaticSize.Y
	body.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = body

	builder(body :: any)
end

local function card(parent: Instance): Frame
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -4, 0, 72)
	f.BackgroundColor3 = UIConfig.Colors.Background
	f.BorderSizePixel = 0
	f.Parent = parent
	corner(f, 8)
	pad(f, 8)
	return f
end

function UIController.ShowShop()
	openPanel("Supplier Shop", function(body)
		if not snapshot or not snapshot.Catalog then
			return
		end
		for _, product in ipairs(snapshot.Catalog) do
			local row = card(body)
			row.Size = UDim2.new(1, -4, 0, 88)

			local name = Instance.new("TextLabel")
			name.Size = UDim2.new(1, -100, 0, 22)
			name.BackgroundTransparency = 1
			name.Text = product.DisplayName
			name.Font = UIConfig.TitleFont
			name.TextSize = 16
			name.TextColor3 = UIConfig.Colors.DarkText
			name.TextXAlignment = Enum.TextXAlignment.Left
			name.Parent = row

			local price = Instance.new("TextLabel")
			price.Size = UDim2.new(1, -100, 0, 18)
			price.Position = UDim2.fromOffset(0, 24)
			price.BackgroundTransparency = 1
			price.Text = string.format("Buy %d  |  Sell %d", product.PurchasePrice, product.SellPrice)
			price.Font = UIConfig.Font
			price.TextSize = 13
			price.TextColor3 = UIConfig.Colors.DarkText
			price.TextXAlignment = Enum.TextXAlignment.Left
			price.TextTransparency = 0.2
			price.Parent = row

			local buy = makeButton("Buy x5", UIConfig.Colors.Primary, row, function()
				busy = true
				local remote = RemoteBootstrap.GetFunction("PurchaseProduct")
				local result = remote:InvokeServer(product.Id, 5)
				busy = false
				if result and result.Ok then
					-- snapshot push will refresh
				end
			end)
			buy.Position = UDim2.new(1, -110, 0, 20)

			if not product.Unlocked then
				buy.Text = "Locked"
				buy.BackgroundColor3 = Color3.fromHex("95A5A6")
				buy.Active = false
			end
		end
	end)
end

function UIController.ShowInventory()
	openPanel("Inventory", function(body)
		if not snapshot then
			return
		end

		local cap = Instance.new("TextLabel")
		cap.Size = UDim2.new(1, 0, 0, 24)
		cap.BackgroundTransparency = 1
		cap.Text = string.format("Capacity %d / %d", snapshot.InventoryUsed, snapshot.InventoryCapacity)
		cap.Font = UIConfig.Font
		cap.TextSize = 14
		cap.TextColor3 = UIConfig.Colors.DarkText
		cap.TextXAlignment = Enum.TextXAlignment.Left
		cap.Parent = body

		for productId, quantity in pairs(snapshot.Inventory) do
			local row = card(body)
			local name = Instance.new("TextLabel")
			name.Size = UDim2.new(0.5, 0, 1, 0)
			name.BackgroundTransparency = 1
			name.Text = string.format("%s x%d", productId, quantity)
			name.Font = UIConfig.Font
			name.TextSize = 15
			name.TextColor3 = UIConfig.Colors.DarkText
			name.TextXAlignment = Enum.TextXAlignment.Left
			name.Parent = row

			-- Find first empty/matching shelf
			local targetShelf = "Shelf_1"
			if snapshot.Shelves then
				for shelfId, shelf in pairs(snapshot.Shelves) do
					if shelf.Quantity == 0 or shelf.ProductId == productId then
						targetShelf = shelfId
						break
					end
				end
			end

			local refill = makeButton("Refill", UIConfig.Colors.Secondary, row, function()
				busy = true
				local remote = RemoteBootstrap.GetFunction("RefillShelf")
				remote:InvokeServer(targetShelf, productId, math.min(10, quantity))
				busy = false
			end)
			refill.Position = UDim2.new(1, -110, 0.5, -18)
		end
	end)
end

function UIController.ShowUpgrades()
	openPanel("Upgrades", function(body)
		if not snapshot then
			return
		end
		for _, upgrade in ipairs(UpgradeConfig.GetAll()) do
			local level = snapshot.Upgrades[upgrade.Id] or 0
			local cost = UpgradeConfig.GetCost(upgrade.Id, level)
			local row = card(body)
			row.Size = UDim2.new(1, -4, 0, 96)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, -120, 0, 22)
			title.BackgroundTransparency = 1
			title.Text = upgrade.DisplayName
			title.Font = UIConfig.TitleFont
			title.TextSize = 16
			title.TextColor3 = UIConfig.Colors.DarkText
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = row

			local info = Instance.new("TextLabel")
			info.Size = UDim2.new(1, -120, 0, 40)
			info.Position = UDim2.fromOffset(0, 24)
			info.BackgroundTransparency = 1
			info.Text = string.format("%s\nLevel %d / %d", upgrade.Description, level, upgrade.MaxLevel)
			info.Font = UIConfig.Font
			info.TextSize = 12
			info.TextColor3 = UIConfig.Colors.DarkText
			info.TextXAlignment = Enum.TextXAlignment.Left
			info.TextYAlignment = Enum.TextYAlignment.Top
			info.Parent = row

			local label = if cost then ("Buy " .. FormatNumber.Coins(cost)) else "MAX"
			local btn = makeButton(label, UIConfig.Colors.Accent, row, function()
				if not cost then
					return
				end
				busy = true
				RemoteBootstrap.GetFunction("PurchaseUpgrade"):InvokeServer(upgrade.Id)
				busy = false
			end)
			btn.Position = UDim2.new(1, -110, 0.5, -18)
			btn.TextColor3 = UIConfig.Colors.DarkText
		end
	end)
end

function UIController.UpdateSnapshot(data: any)
	snapshot = data
	if coinsLabel then
		coinsLabel.Text = "Coins: " .. FormatNumber.Coins(data.Coins or 0)
	end
	if levelLabel then
		local storeLevel = data.Progression and data.Progression.StoreLevel or 1
		levelLabel.Text = "Store Lv " .. tostring(storeLevel)
	end
	if customersLabel then
		customersLabel.Text = "Customers: " .. tostring(data.ActiveCustomers or 0)
	end
end

function UIController.Init()
	playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

	root = Instance.new("ScreenGui")
	root.Name = "MiniMarketHUD"
	root.ResetOnSpawn = false
	root.IgnoreGuiInset = true
	root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	root.Parent = playerGui

	hudFrame = Instance.new("Frame")
	hudFrame.Name = "HUD"
	hudFrame.Size = UDim2.new(1, -24, 0, UIConfig.Hud.Height)
	hudFrame.Position = UDim2.fromOffset(12, 12)
	hudFrame.BackgroundColor3 = UIConfig.Colors.White
	hudFrame.BorderSizePixel = 0
	hudFrame.Parent = root
	corner(hudFrame, 12)
	pad(hudFrame, 10)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 10)
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = hudFrame

	coinsLabel = Instance.new("TextLabel")
	coinsLabel.Size = UDim2.new(0, 140, 1, 0)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.Text = "Coins: 0"
	coinsLabel.Font = UIConfig.TitleFont
	coinsLabel.TextSize = 16
	coinsLabel.TextColor3 = UIConfig.Colors.DarkText
	coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
	coinsLabel.Parent = hudFrame

	levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(0, 100, 1, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Store Lv 1"
	levelLabel.Font = UIConfig.Font
	levelLabel.TextSize = 14
	levelLabel.TextColor3 = UIConfig.Colors.DarkText
	levelLabel.Parent = hudFrame

	customersLabel = Instance.new("TextLabel")
	customersLabel.Size = UDim2.new(0, 120, 1, 0)
	customersLabel.BackgroundTransparency = 1
	customersLabel.Text = "Customers: 0"
	customersLabel.Font = UIConfig.Font
	customersLabel.TextSize = 14
	customersLabel.TextColor3 = UIConfig.Colors.DarkText
	customersLabel.Parent = hudFrame

	makeButton("Shop", UIConfig.Colors.Primary, hudFrame, function()
		UIController.ShowShop()
	end)
	makeButton("Inventory", UIConfig.Colors.Secondary, hudFrame, function()
		UIController.ShowInventory()
	end)
	local upBtn = makeButton("Upgrades", UIConfig.Colors.Accent, hudFrame, function()
		UIController.ShowUpgrades()
	end)
	upBtn.TextColor3 = UIConfig.Colors.DarkText

	panelHost = Instance.new("Frame")
	panelHost.Name = "Panels"
	panelHost.Size = UDim2.fromScale(1, 1)
	panelHost.BackgroundTransparency = 1
	panelHost.Parent = root

	-- Subtle intro tween
	hudFrame.Position = UDim2.fromOffset(12, -70)
	TweenService:Create(hudFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(12, 12),
	}):Play()
end

function UIController.GetSnapshot()
	return snapshot
end

return UIController
