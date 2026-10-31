--!strict
--[[
	CustomerMovement.lua
	Pathfinding helpers for NPC customers.
]]

local PathfindingService = game:GetService("PathfindingService")

local CustomerMovement = {}

local AGENT_PARAMS = {
	AgentRadius = 1.5,
	AgentHeight = 5,
	AgentCanJump = true,
	WaypointSpacing = 4,
}

function CustomerMovement.CreateHumanoidModel(name: string, color: Color3): Model
	local model = Instance.new("Model")
	model.Name = name

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Color = color
	root.Material = Enum.Material.SmoothPlastic
	root.Anchored = false
	root.CanCollide = true
	root.Parent = model

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Color = color
	torso.Material = Enum.Material.SmoothPlastic
	torso.CanCollide = false
	torso.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = torso
	weld.Parent = root

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Color = Color3.fromHex("F5CBA7")
	head.Material = Enum.Material.SmoothPlastic
	head.CanCollide = false
	head.Parent = model

	local headWeld = Instance.new("WeldConstraint")
	headWeld.Part0 = root
	headWeld.Part1 = head
	head.CFrame = root.CFrame + Vector3.new(0, 1.6, 0)
	headWeld.Parent = root

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = 12
	humanoid.Parent = model

	model.PrimaryPart = root
	return model
end

function CustomerMovement.MoveTo(model: Model, target: Vector3, walkSpeed: number): boolean
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model.PrimaryPart
	if not humanoid or not root then
		return false
	end
	humanoid.WalkSpeed = walkSpeed

	local path = PathfindingService:CreatePath(AGENT_PARAMS)
	local ok, err = pcall(function()
		path:ComputeAsync(root.Position, target)
	end)
	if not ok then
		humanoid:MoveTo(target)
		local finished = humanoid.MoveToFinished:Wait()
		return finished
	end

	if path.Status ~= Enum.PathStatus.Success then
		humanoid:MoveTo(target)
		return humanoid.MoveToFinished:Wait()
	end

	for _, waypoint in ipairs(path:GetWaypoints()) do
		if not model.Parent then
			return false
		end
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end
		humanoid:MoveTo(waypoint.Position)
		local reached = humanoid.MoveToFinished:Wait()
		if not reached then
			-- Attempt direct move as fallback
			humanoid:MoveTo(target)
			return humanoid.MoveToFinished:Wait()
		end
	end
	return true
end

return CustomerMovement
