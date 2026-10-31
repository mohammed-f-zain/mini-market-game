--!strict
--[[
	CustomerAI.lua
	Deterministic customer lifecycle for a single NPC.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local StoreService = require(script.Parent.Parent.Services.StoreService)
local CheckoutSystem = require(script.Parent.CheckoutSystem)
local CustomerMovement = require(script.Parent.CustomerMovement)
local ShoppingSystem = require(script.Parent.ShoppingSystem)
local ShelfSystem = require(script.Parent.ShelfSystem)
local TutorialSystem = require(script.Parent.TutorialSystem)

local CustomerAI = {}

local COLORS = {
	Color3.fromHex("28A9E0"),
	Color3.fromHex("38C985"),
	Color3.fromHex("FFC857"),
	Color3.fromHex("E67E22"),
	Color3.fromHex("9B59B6"),
}

function CustomerAI.Run(npcFolder: Folder, spawnCFrame: CFrame, plotId: number, onFinished: () -> ())
	task.spawn(function()
		local plot = StoreService.GetPlot(plotId)
		if not plot then
			onFinished()
			return
		end

		if not ShelfSystem.HasAnyStock(plotId) then
			onFinished()
			return
		end

		local color = COLORS[math.random(1, #COLORS)]
		local model = CustomerMovement.CreateHumanoidModel("Customer_" .. tostring(math.random(1000, 9999)), color)
		model:PivotTo(spawnCFrame)
		model.Parent = npcFolder

		local walkSpeed = GameConfig.Customers.WalkSpeed
		local okEnter = CustomerMovement.MoveTo(model, plot.EntranceCFrame.Position, walkSpeed)
		if not okEnter or not model.Parent then
			model:Destroy()
			onFinished()
			return
		end

		-- Browse shelves
		local shelfTarget = plot.EntranceCFrame.Position + Vector3.new(0, 0, -8)
		if #plot.ShelfAnchors > 0 then
			local anchor = plot.ShelfAnchors[math.random(1, #plot.ShelfAnchors)]
			shelfTarget = anchor.Position + Vector3.new(0, 0, 2)
		end
		CustomerMovement.MoveTo(model, shelfTarget, walkSpeed)

		local browse = GameConfig.Customers.BrowseTimeMin
			+ math.random() * (GameConfig.Customers.BrowseTimeMax - GameConfig.Customers.BrowseTimeMin)
		task.wait(browse)

		local basket = ShoppingSystem.SelectBasket(plotId)
		if #basket == 0 then
			CustomerMovement.MoveTo(model, spawnCFrame.Position, walkSpeed)
			model:Destroy()
			onFinished()
			return
		end

		CustomerMovement.MoveTo(model, plot.CheckoutCFrame.Position, walkSpeed)
		task.wait(0.4)

		local transactionId = string.format("%d_%d_%d", plotId, os.time(), math.random(1, 1_000_000))
		local sold = CheckoutSystem.ProcessSale(plotId, basket, transactionId)
		if sold then
			local owner = StoreService.GetOwner(plotId)
			if owner then
				TutorialSystem.MarkAction(owner, "Sale")
			end
		end

		CustomerMovement.MoveTo(model, spawnCFrame.Position, walkSpeed)
		if model.Parent then
			model:Destroy()
		end
		CheckoutSystem.CleanupOldTransactions()
		onFinished()
	end)
end

return CustomerAI
