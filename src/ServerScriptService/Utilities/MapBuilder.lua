--!strict
--[[
	MapBuilder.lua
	Procedurally builds the supermarket neighborhood from parts.
]]

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local StoreService = require(script.Parent.Parent.Services.StoreService)
local Logger = require(script.Parent.Logger)

local MapBuilder = {}

local Colors = GameConfig.Colors

local function part(props: {
	Name: string,
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3,
	Material: Enum.Material?,
	Anchored: boolean?,
	Parent: Instance,
	CanCollide: boolean?,
}): Part
	local p = Instance.new("Part")
	p.Name = props.Name
	p.Size = props.Size
	p.CFrame = props.CFrame
	p.Color = props.Color
	p.Material = props.Material or Enum.Material.SmoothPlastic
	p.Anchored = if props.Anchored == nil then true else props.Anchored
	p.CanCollide = if props.CanCollide == nil then true else props.CanCollide
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = props.Parent
	return p
end

local function createStore(plotId: number, origin: CFrame, parent: Folder): Model
	local model = Instance.new("Model")
	model.Name = "Store_" .. tostring(plotId)
	model.Parent = parent

	local size = GameConfig.Map.StoreSize

	-- Floor
	part({
		Name = "Floor",
		Size = Vector3.new(size.X, 1, size.Z),
		CFrame = origin * CFrame.new(0, 0.5, 0),
		Color = Color3.fromHex("E8EEF4"),
		Material = Enum.Material.Concrete,
		Parent = model,
	})

	-- Walls
	local wallHeight = size.Y
	local wallThickness = 1
	local walls = {
		{ Name = "WallBack", Size = Vector3.new(size.X, wallHeight, wallThickness), Offset = CFrame.new(0, wallHeight / 2, -size.Z / 2) },
		{ Name = "WallLeft", Size = Vector3.new(wallThickness, wallHeight, size.Z), Offset = CFrame.new(-size.X / 2, wallHeight / 2, 0) },
		{ Name = "WallRight", Size = Vector3.new(wallThickness, wallHeight, size.Z), Offset = CFrame.new(size.X / 2, wallHeight / 2, 0) },
	}
	for _, w in ipairs(walls) do
		part({
			Name = w.Name,
			Size = w.Size,
			CFrame = origin * w.Offset,
			Color = Colors.Primary,
			Parent = model,
		})
	end

	-- Front wall with entrance gap (two side pieces)
	part({
		Name = "WallFrontLeft",
		Size = Vector3.new(size.X / 2 - 4, wallHeight, wallThickness),
		CFrame = origin * CFrame.new(-(size.X / 4 + 2), wallHeight / 2, size.Z / 2),
		Color = Colors.Primary,
		Parent = model,
	})
	part({
		Name = "WallFrontRight",
		Size = Vector3.new(size.X / 2 - 4, wallHeight, wallThickness),
		CFrame = origin * CFrame.new((size.X / 4 + 2), wallHeight / 2, size.Z / 2),
		Color = Colors.Primary,
		Parent = model,
	})

	-- Roof
	part({
		Name = "Roof",
		Size = Vector3.new(size.X + 2, 1, size.Z + 2),
		CFrame = origin * CFrame.new(0, wallHeight + 0.5, 0),
		Color = Color3.fromHex("1F6F98"),
		Parent = model,
	})

	-- Entrance marker
	part({
		Name = "Entrance",
		Size = Vector3.new(6, 0.2, 4),
		CFrame = origin * CFrame.new(0, 1.1, size.Z / 2 + 2),
		Color = Colors.Accent,
		CanCollide = false,
		Parent = model,
	})

	-- Spawn
	part({
		Name = "Spawn",
		Size = Vector3.new(4, 0.2, 4),
		CFrame = origin * CFrame.new(0, 1.1, size.Z / 2 - 6),
		Color = Colors.Secondary,
		CanCollide = false,
		Parent = model,
	})

	-- Checkout
	local checkout = part({
		Name = "Checkout",
		Size = Vector3.new(6, 2, 3),
		CFrame = origin * CFrame.new(10, 2, size.Z / 2 - 8),
		Color = Color3.fromHex("34495E"),
		Parent = model,
	})
	CollectionService:AddTag(checkout, "CheckoutCounter")

	-- Storage room
	part({
		Name = "StorageRoom",
		Size = Vector3.new(8, 0.2, 6),
		CFrame = origin * CFrame.new(-10, 1.1, -size.Z / 2 + 6),
		Color = Color3.fromHex("BDC3C7"),
		CanCollide = false,
		Parent = model,
	})

	-- Shelves
	local shelfCount = GameConfig.Shelves.BaseShelfCount + 2 -- physical anchors for upgrades
	for i = 1, shelfCount do
		local x = -12 + (i - 1) * 6
		local shelf = part({
			Name = "Shelf_" .. tostring(i),
			Size = Vector3.new(4, 4, 1.5),
			CFrame = origin * CFrame.new(x, 3, -4),
			Color = Color3.fromHex("A0522D"),
			Material = Enum.Material.Wood,
			Parent = model,
		})
		CollectionService:AddTag(shelf, "ShelfAnchor")
	end

	-- Upgrade pad
	part({
		Name = "UpgradePad",
		Size = Vector3.new(4, 0.3, 4),
		CFrame = origin * CFrame.new(12, 1.15, -8),
		Color = Colors.Accent,
		Parent = model,
	})

	-- Store sign
	local sign = part({
		Name = "StoreSign",
		Size = Vector3.new(12, 3, 0.5),
		CFrame = origin * CFrame.new(0, wallHeight + 2.5, size.Z / 2 + 0.5),
		Color = Colors.DarkText,
		Parent = model,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "Vacant Market"
	label.TextColor3 = Colors.White
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui

	model.PrimaryPart = model:FindFirstChild("Floor") :: BasePart
	StoreService.RegisterPlot(plotId, model)
	return model
end

function MapBuilder.Build()
	local map = StoreService.GetMapFolder()
	map:ClearAllChildren()

	-- Ground
	part({
		Name = "Ground",
		Size = Vector3.new(400, 1, 400),
		CFrame = CFrame.new(0, -0.5, 0),
		Color = Color3.fromHex("7CB342"),
		Material = Enum.Material.Grass,
		Parent = map,
	})

	-- Central road
	part({
		Name = "CentralRoad",
		Size = Vector3.new(GameConfig.Map.RoadWidth, 0.2, 220),
		CFrame = CFrame.new(0, 0.1, 0),
		Color = Color3.fromHex("5D6D7E"),
		Material = Enum.Material.Asphalt,
		Parent = map,
	})

	-- Cross road
	part({
		Name = "CrossRoad",
		Size = Vector3.new(220, 0.2, GameConfig.Map.RoadWidth),
		CFrame = CFrame.new(0, 0.1, 0),
		Color = Color3.fromHex("5D6D7E"),
		Material = Enum.Material.Asphalt,
		Parent = map,
	})

	-- Customer spawn plaza
	part({
		Name = "CustomerSpawn",
		Size = Vector3.new(20, 0.3, 20),
		CFrame = CFrame.new(0, 0.2, 50),
		Color = Colors.Accent,
		Parent = map,
	})

	-- Supplier warehouse
	local warehouse = Instance.new("Model")
	warehouse.Name = "SupplierWarehouse"
	warehouse.Parent = map
	part({
		Name = "WarehouseFloor",
		Size = Vector3.new(28, 1, 20),
		CFrame = CFrame.new(0, 0.5, -55),
		Color = Color3.fromHex("95A5A6"),
		Parent = warehouse,
	})
	part({
		Name = "WarehouseBuilding",
		Size = Vector3.new(28, 14, 20),
		CFrame = CFrame.new(0, 7.5, -55),
		Color = Color3.fromHex("7F8C8D"),
		Parent = warehouse,
	})
	local whSign = part({
		Name = "WarehouseSign",
		Size = Vector3.new(16, 3, 0.4),
		CFrame = CFrame.new(0, 16, -44.5),
		Color = Colors.DarkText,
		Parent = warehouse,
	})
	local whGui = Instance.new("SurfaceGui")
	whGui.Parent = whSign
	local whLabel = Instance.new("TextLabel")
	whLabel.Size = UDim2.fromScale(1, 1)
	whLabel.BackgroundTransparency = 1
	whLabel.Text = "SUPPLIER WAREHOUSE"
	whLabel.TextColor3 = Colors.White
	whLabel.TextScaled = true
	whLabel.Font = Enum.Font.GothamBold
	whLabel.Parent = whGui

	-- Plots in two rows along the road
	local plotsFolder = Instance.new("Folder")
	plotsFolder.Name = "Plots"
	plotsFolder.Parent = map

	local spacing = GameConfig.Map.PlotSpacing
	local plotCount = GameConfig.Map.PlotCount
	local half = math.ceil(plotCount / 2)

	for i = 1, plotCount do
		local row = if i <= half then 1 else 2
		local indexInRow = if row == 1 then i else i - half
		local x = (indexInRow - (half + 1) / 2) * spacing
		local z = if row == 1 then -28 else 28
		local facing = if row == 1 then 0 else math.rad(180)
		local origin = CFrame.new(x, 0, z) * CFrame.Angles(0, facing, 0)
		createStore(i, origin, plotsFolder)

		-- Parking pad
		part({
			Name = "Parking_" .. tostring(i),
			Size = Vector3.new(10, 0.15, 8),
			CFrame = CFrame.new(x, 0.15, if row == 1 then -10 else 10),
			Color = Color3.fromHex("85929E"),
			Parent = map,
		})
	end

	-- Trees / decorations
	local decor = Instance.new("Folder")
	decor.Name = "Decorations"
	decor.Parent = map
	for i = 1, 16 do
		local angle = (i / 16) * math.pi * 2
		local radius = 90
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		local trunk = part({
			Name = "TreeTrunk_" .. tostring(i),
			Size = Vector3.new(1.2, 6, 1.2),
			CFrame = CFrame.new(x, 3, z),
			Color = Color3.fromHex("8B5A2B"),
			Material = Enum.Material.Wood,
			Parent = decor,
		})
		part({
			Name = "TreeLeaves_" .. tostring(i),
			Size = Vector3.new(6, 6, 6),
			CFrame = trunk.CFrame * CFrame.new(0, 4, 0),
			Color = Color3.fromHex("27AE60"),
			Material = Enum.Material.Grass,
			Parent = decor,
		})
	end

	-- Ambient lighting friendly baseplate already green
	Logger.Info("MapBuilder", string.format("Built neighborhood with %d store plots", plotCount))
end

return MapBuilder
