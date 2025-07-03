local cloneref = cloneref or function(obj) return obj end

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local inputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local RunService = cloneref(game:GetService("RunService"))
local workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local store = {
	blocks = {},
	serverBlocks = {}
}

local bridgeduels = {
	BlinkClient = require(ReplicatedStorage.Blink.Client),
	CombatService = require(ReplicatedStorage.Modules.Knit.Client).GetService('CombatService'),
	CombatConstants = require(ReplicatedStorage.Constants.Melee),
	Entity = require(ReplicatedStorage.Modules.Entity),
	ViewmodelController = require(ReplicatedStorage.Client.Controllers.All.ViewmodelController),
	MovementController = require(ReplicatedStorage.Client.Controllers.All.MovementController),
	EffectsController = require(ReplicatedStorage.Client.Controllers.All.EffectsController),
	ToolService = require(ReplicatedStorage.Modules.Knit.Client).GetService("ToolService"),
	Communication = require(ReplicatedStorage.Client.Communication)
}

local bridgeduels = {
	Functions = {
		GetRemote = function(name: RemoteEvent | RemoteFunction): RemoteEvent | RemoteFunction
			local remote
			for _, v in pairs(game:GetDescendants()) do
				if (v:IsA('RemoteEvent') or v:IsA('RemoteFunction')) and v.Name == name then
					remote = v
					break
				end
			end
			if name == nil then Instance.new('RemoteEvent', name) end
			return remote
		end
	},
	Remotes = {
		AttackPlayer = bridgeduels.Functions.GetRemote("AttackPlayerWithSword"),
		BlockSword = bridgeduels.Functions.GetRemote("ToggleBlockSword"),
		EnterQueue = bridgeduels.Functions.GetRemote("EnterQueue")
	}
}

local function parsePositions(part, callback)
	if not part:IsA("Part") then
		return
	end
	local halfSize = part.Size / 2
	local gridStart = -halfSize + Vector3.new(1.5, 1.5, 1.5)
	for x = 0, part.Size.X - 1, 3 do
		for y = 0, part.Size.Y - 1, 3 do
			for z = 0, part.Size.Z - 1, 3 do
				local gridOffset = Vector3.new(x, y, z)
				local worldPosition = part.CFrame:PointToWorldSpace(gridStart + gridOffset)
				local roundedPosition = Vector3.new(
                    math.round(worldPosition.X),
                    math.round(worldPosition.Y),
                    math.round(worldPosition.Z)
                )
				callback(roundedPosition)
			end
		end
	end
end

task.spawn(function()
	local map = workspace:WaitForChild('Map', 99999)
	if not map then
		return
	end
	local function handleDescendant(descendant, action)
		parsePositions(descendant, function(pos)
			if action == "add" then
				store.blocks[pos] = descendant
			elseif action == "remove" and store.blocks[pos] == descendant then
				store.blocks[pos] = nil
				store.serverBlocks[pos] = nil
			end
		end)
	end
	map.DescendantAdded:Connect(function(v)
		handleDescendant(v, "add")
	end)
	map.DescendantRemoving:Connect(function(v)
		handleDescendant(v, "remove")
	end)
	for _, descendant in ipairs(map:GetDescendants()) do
		parsePositions(descendant, function(pos)
			store.blocks[pos] = descendant
			store.serverBlocks[pos] = descendant
		end)
	end
end)

local function IsAlive(plr)
	plr = plr or LocalPlayer
	local character = plr.Character
	return character
        and character:FindFirstChild("Head")
        and character:FindFirstChild("Humanoid")
        and character.Humanoid.Health > 0.1
end

local AttackRange = 25
local Targetoptions = ""

local function GetClosest(teamcheck)
	if not IsAlive(LocalPlayer) then
		return
	end
	local rootPart = LocalPlayer.Character.HumanoidRootPart
	if not rootPart then
		return
	end
	local closestTarget, closestDistance = nil, AttackRange
	local lowestHealth = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer or not IsAlive(player) then
			continue
		end
		if teamcheck and player.TeamColor == LocalPlayer.TeamColor then
			continue
		end
		local targetRoot = player.Character.HumanoidRootPart
		local distance = (rootPart.Position - targetRoot.Position).Magnitude
		if Targetoptions == "Health" then
			local health = player.Character.Humanoid.Health
			if distance < closestDistance and health < lowestHealth then
				lowestHealth = health
				closestTarget = player
			end
		elseif distance < closestDistance then
			closestDistance = distance
			closestTarget = player
		end
	end
	return closestTarget
end

local function getTool()
	return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA('Tool', true)
end
local LoopManager = {}
LoopManager.__index = LoopManager

function LoopManager.new()
	local self = setmetatable({
		tasks = {}
	}, LoopManager)
	return self
end

function LoopManager:AddTask(id, callback)
	if self.tasks[id] then
		warn("Task ID " .. id .. " already exists, overwriting")
		self:RemoveTask(id)
	end
	self.tasks[id] = {
		callback = callback,
		connection = RunService.Heartbeat:Connect(function(deltaTime)
			local success, errorMsg = pcall(callback, deltaTime)
			if not success then
				warn("Error in task " .. id .. ": " .. tostring(errorMsg))
			end
		end)
	}
end

function LoopManager:RemoveTask(id)
	local task = self.tasks[id]
	if task then
		if task.connection then
			task.connection:Disconnect()
		end
		self.tasks[id] = nil
	end
end

function LoopManager:Destroy()
	for id in pairs(self.tasks) do
		self:RemoveTask(id)
	end
end


local SwordAnimations = {
	Anim1 = {
		CFrame = CFrame.new(0, -0.75, 1) * CFrame.Angles(math.rad(120), math.rad(0), math.rad(0))
	},
	Anim2 = {
		CFrame = CFrame.new(0, -0.75, 1) * CFrame.Angles(math.rad(120), math.rad(0), math.rad(50))
	},
	Anim3 = {
		CFrame = CFrame.new(0, -0.75, 1) * CFrame.Angles(math.rad(120), math.rad(0), math.rad(-20))
	}
}

local function getGamemode(sub)
	local path = replicatedStorage.Modules.ServerData.Cache
	local jsonpath = HttpService:JSONDecode(path.Value)

	return sub and jsonpath.Submode or jsonpath.Gamemode
end

return {
	bridgeduels = bridgeduels,
	SwordAnimations = SwordAnimations,
	store = store,
	GetClosest = GetClosest,
	IsAlive = IsAlive,
	getTool = getTool,
	parsePositions = parsePositions,
	LoopManager = LoopManager,
	getGamemode = getGamemode
}