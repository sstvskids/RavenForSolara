local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local KnitClient = require(RepStorage.rbxts_include.node_modules["@easy-games"].knit.src.Knit.KnitClient)
local collectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local bedwars = {
    ["AnimationType"] = require(RepStorage.TS.animation["animation-type"]).AnimationType,
    ["AnimationUtil"] = require(RepStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
    ["BlockCpsController"] = KnitClient.GetController("BlockCpsController"),
    ["BlockEngine"] = require(RepStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
    ["BlockPlacementController"] = KnitClient.GetController("BlockPlacementController"),
    ["BlockPlacer"] = require(RepStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client.placement['block-placer']).BlockPlacer,
    ["BowConstantsTable"] = debug.getupvalue(KnitClient.GetController("ProjectileController").enableBeam, 6),
    ["ClientConstructor"] = require(RepStorage['rbxts_include']['node_modules']['@rbxts'].net.out.client),
    ["ClientDamageBlock"] = require(game:GetService('ReplicatedStorage')['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client,
    ["ClientHandler"] = require(RepStorage.TS.remotes).default.Client,
    ["ClientHandlerStore"] = require(LocalPlayer.PlayerScripts.TS.ui.store).ClientStore,
    ["ClientSyncEvents"] = require(LocalPlayer.PlayerScripts.TS['client-sync-events']).ClientSyncEvents,
    ["CombatConstant"] = require(RepStorage.TS.combat["combat-constant"]).CombatConstant,
    ["CombatController"] = KnitClient.GetController("CombatController"),
    ["DamageIndicator"] = KnitClient.GetController("DamageIndicatorController").spawnDamageIndicator,
    ["FovController"] = KnitClient.GetController("FovController"),
    ["GrimReaperController"] = KnitClient.GetController("GrimReaperController"),
    ["HighlightController"] = KnitClient.GetController("EntityHighlightController"),
    ["ItemMeta"] = debug.getupvalue(require(RepStorage.TS.item["item-meta"]).getItemMeta, 1),
	["InventoryUtil"] = require(RepStorage.TS.inventory['inventory-util']).InventoryUtil,
    ["KatanaController"] = KnitClient.GetController("DaoController"),
    ["KillEffectController"] = KnitClient.GetController("KillEffectController"),
    ["KnockbackUtil"] = require(RepStorage.TS.damage["knockback-util"]).KnockbackUtil,
    ["ProjectileController"] = KnitClient.GetController("ProjectileController"),
    ["ProjectileMeta"] = require(RepStorage.TS.projectile['projectile-meta']).ProjectileMeta,
    ["QueryUtil"] = require(RepStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil,
    ["ScytheController"] = KnitClient.GetController("ScytheController"),
    ["Shop"] = require(RepStorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop,
    ["ShopItems"] = require(RepStorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop.ShopItems,
    ["SoundList"] = require(RepStorage.TS.sound['game-sound']).GameSound,
    ["SprintController"] = KnitClient.GetController("SprintController"),
    ["StopwatchController"] = KnitClient.GetController("StopwatchController"),
    ["SwordController"] = KnitClient.GetController("SwordController"),
    ["ViewmodelController"] = KnitClient.GetController("ViewmodelController"),
    ["ZephyrController"] = KnitClient.GetController("WindWalkerController"),
}
local RavenEquippedKit = "none"
local function RavenGameInfo(Info, Info2)
	if Info.Bedwars ~= Info2.Bedwars then
		RavenEquippedKit = Info.Bedwars.kit ~= "none" and Info.Bedwars.kit or ""
	end
end
bedwars["ClientHandlerStore"].changed:connect(RavenGameInfo)
RavenGameInfo(bedwars["ClientHandlerStore"]:getState(), {})

local SwordAnimations = {
	['Remade'] = {
		{
			CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)),
			Time = 0.05
		},
		{
			CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)),
			Time = 0.05
		}
	},
	['New'] = {
		{
			CFrame = CFrame.new(0.69, -1.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)),
			Time = 0.069
		},
		{
			CFrame = CFrame.new(0.7, -1.8, 0.65) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)),
			Time = 0.069
		}
	},
	["Old"] = {
		{
			CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(220), math.rad(100), math.rad(100)),
			Time = 0.25
		},
		{
			CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),
			Time = 0.25
		}
	},
    ['AutoBlock'] = {
            -- Pull sword toward player (closer to chest)
            {
                CFrame = CFrame.new(0.3, -0.5, 0.2) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0)),
                Time = 0.2
            },
            -- Push sword forward to block position
            {
                CFrame = CFrame.new(0.7, -0.7, 0.8) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)),
                Time = 0.2
            },
            -- Return to neutral (optional intermediate step)
            {
                CFrame = CFrame.new(0.5, -0.6, 0.5) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0)),
                Time = 0.2
            }
        }
}

local function SetCamera(Camera)
	workspace.CurrentCamera.CameraSubject = Camera
end

local function IsAlive(plr)
	plr = plr or LocalPlayer
	if not plr.Character then
		return false
	end
	if not plr.Character:FindFirstChild("Head") then
		return false
	end
	if not plr.Character:FindFirstChild("Humanoid") then
		return false
	end
	if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then
		return false
	end
	return true
end

local function GetClosest()
	if not IsAlive(LocalPlayer) then
		return
	end
	local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not (LocalPlayer.Character or HumanoidRootPart) then
		return
	end
	local TargetDistance = math.huge
	local Target
	for i, v in ipairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local TargetHRP = v.Character.HumanoidRootPart
			local mag = (HumanoidRootPart.Position - TargetHRP.Position).magnitude
			if mag < TargetDistance then
				TargetDistance = mag
				Target = v
			end
		end
	end
	return Target
end

local function GetClosestTeamCheck(distance)
	local closestDistance = distance or math.huge
	local lowestHealth = math.huge
	if not IsAlive(LocalPlayer) then
		return
	end
	local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not (LocalPlayer.Character or HumanoidRootPart) then
		return
	end
	local Target
	local Targetoptions = "Health" -- Default to Health, can be overridden externally
	for i, v in ipairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local TargetHRP = v.Character.HumanoidRootPart
			local distance = (HumanoidRootPart.Position - TargetHRP.Position).magnitude
			if Targetoptions == "Health" then
				local health = v.Character.Humanoid.Health
				if distance < closestDistance and health < lowestHealth then
					lowestHealth = health
					Target = v
				end
			elseif distance < closestDistance then
				closestDistance = distance
				Target = v
			end
		end
	end
	return Target
end

local function GetBeds()
	local beds = {}
	for i, v in pairs(game:GetService("Workspace"):GetChildren()) do
		if string.lower(v.Name) == "bed" and v:FindFirstChild("Blanket").BrickColor ~= nil and v:FindFirstChild("Blanket").BrickColor ~= LocalPlayer.Team.TeamColor then
			table.insert(beds, v)
		end
	end
	return beds
end

local function GetClosestBeds()
	local TargetDistance = math.huge
	local Target
	local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	for i, v in pairs(game:GetService("Workspace"):GetChildren()) do
		if string.lower(v.Name) == "bed" and v:FindFirstChild("Blanket") ~= nil and v:FindFirstChild("Blanket").Color ~= LocalPlayer.Team.TeamColor then
			local mag = (HumanoidRootPart.Position - v.Position).magnitude
			if mag < TargetDistance then
				TargetDistance = mag
				Target = v
			end
		end
	end
	return Target
end

local function getPlacedBlock(pos)
	local roundedPosition = bedwars["BlockEngine"]:getBlockPosition(pos)
	return bedwars["BlockEngine"]:getStore():getBlockAt(roundedPosition), roundedPosition
end

local function getserverpos(Position)
	local x = math.round(Position.X / 3)
	local y = math.round(Position.Y / 3)
	local z = math.round(Position.Z / 3)
	return Vector3.new(x, y, z)
end

local function GetMatchState()
	return bedwars["ClientHandlerStore"]:getState().Game.matchState
end

local function GetQueueType()
	local state = bedwars["ClientHandlerStore"]:getState()
	return state.Game.queueType or "bedwars_test"
end

local function GetInventory(plr)
    local suc, res = pcall(function()
        return bedwars["InventoryUtil"].getInventory(plr)
    end)
    return suc and res or { items = {}, armor = {} }
end

local BedwarsSwords = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"]).BedwarsMelees

local function valuefunc(vec)
	return {
		value = vec
	}
end

local function getSword()
	local highest, returning = -9e9, nil
	for i, v in next, GetInventory(LocalPlayer).items do
		local swords = table.find(BedwarsSwords, v.itemType)
		if not swords then
			continue
		end
		if swords > highest then
			returning = v
			highest = swords
		end
	end
	return returning
end

local function GetItemNear(itemName)
	for slot, item in next, GetInventory(LocalPlayer).items do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local cachedNormalSides = {}
for i, v in next, (Enum.NormalId:GetEnumItems()) do
	if v.Name ~= 'Bottom' then
		table.insert(cachedNormalSides, v)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in next, (cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function switchItem(tool)
	if LocalPlayer.Character.HandInvItem.Value ~= tool then
		game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged
            .SetInvItem:InvokeServer({
			hand = tool
		})
	end
end
local Store = {}
Store.__index = Store

function Store.new()
	local self = setmetatable({
		tools = { stone = nil, wood = nil, wool = nil },
		inventory = { items = {}, armor = {} }
	}, Store)
	return self
end

function Store:GetTool(breakType)
	local bestTool, bestSlot, bestDamage = nil, nil, 0
	for slot, item in pairs(self.inventory.items) do
		local toolMeta = bedwars.ItemMeta[item.itemType].breakBlock
		if toolMeta and (toolMeta[breakType] or 0) > bestDamage then
			bestTool, bestSlot, bestDamage = item, slot, toolMeta[breakType]
		end
	end
	return bestTool, bestSlot
end

function Store:UpdateTools()
	local newInventory = bedwars["InventoryUtil"].getInventory(LocalPlayer)
	if newInventory.items ~= self.inventory.items then
		self.inventory = newInventory
		for _, breakType in ipairs({'stone', 'wood', 'wool'}) do
			self.tools[breakType] = self:GetTool(breakType)
		end
	end
end

-- Replace store initialization
local store = Store.new()

-- Update init function to use metatable method
local function init()
	local oldstore = {}
	store.inventory = bedwars["InventoryUtil"].getInventory(LocalPlayer)
	repeat task.wait(0.5)
		if not IsAlive(LocalPlayer) then
			print("[ToolManager] Player not alive, skipping update")
		else
			store.inventory = bedwars["InventoryUtil"].getInventory(LocalPlayer)
			if store.inventory ~= oldstore then
				store:UpdateTools()
			end
			oldstore = store.inventory
		end
	until not true -- will check if injected if I don't forget it, if I do, make a issue request or give a bug report on discord.
end

-- Run the script
task.spawn(function()
    local suc, err = pcall(init)
    if not suc then
        warn("[ToolManager] Error:", err)
    end
end)

local cache = {}
local sides = {}
for _, v in pairs(Enum.NormalId:GetEnumItems()) do
	table.insert(sides, Vector3.FromNormalId(v) * 3)
end
local function getBlockHealth(block, blockpos)
	local success, result = pcall(function()
		local blockdata = bedwars["BlockEngine"]:getStore():getBlockData(blockpos)
		return (blockdata and (blockdata:GetAttribute('1') or blockdata:GetAttribute('Health')) or block:GetAttribute('Health') or 0)
	end)
	if not success then
		return 0
	end
	return result
end
local function getToolDamage(breakType)
	if not breakType or not store.tools[breakType] then
		return 2
	end
	local toolItem = store.tools[breakType]
	return bedwars.ItemMeta[toolItem.itemType].breakBlock[breakType] or 2
end

local function calculateNodeCost(block, blockPos, nodeCost)
	local health = getBlockHealth(block, blockPos)
	local breakType = bedwars.ItemMeta[block.Name].block and bedwars.ItemMeta[block.Name].block.breakType
	return health / getToolDamage(breakType) + nodeCost
end

local function findBestAirNode(air, distances)
	local bestPos, bestCost = nil, math.huge
	for node in pairs(air) do
		if distances[node] < bestCost then
			bestPos, bestCost = node, distances[node]
		end
	end
	return bestPos, bestCost
end

local function calculatePath(target, blockpos)
	if cache[blockpos] then
		return unpack(cache[blockpos])
	end

	local visited, unvisited, distances, air, path = {}, {{0, blockpos}}, {[blockpos] = 0}, {}, {}
	for _ = 1, 10000 do
		local _, node = next(unvisited)
		if not node then break end
		table.remove(unvisited, 1)
		visited[node[2]] = true

		for _, side in ipairs(sides) do
			local nextPos = node[2] + side
			if visited[nextPos] then continue end

			local block = getPlacedBlock(nextPos)
			if not block or block:GetAttribute('NoBreak') or block == target then
				if not block then air[node[2]] = true end
				continue
			end

			local curDist = calculateNodeCost(block, nextPos, node[1])
			if curDist < (distances[nextPos] or math.huge) then
				table.insert(unvisited, {curDist, nextPos})
				distances[nextPos] = curDist
				path[nextPos] = node[2]
			end
		end
	end

	local pos, cost = findBestAirNode(air, distances)
	if pos then
		cache[blockpos] = {pos, cost, path}
		return pos, cost, path
	end
	return nil
end
-- Initialize the single part for highlighting
shared.parts = {}
local part = Instance.new('Part')
part.Anchored = true
part.CanQuery = false
part.CanCollide = false
part.Transparency = 1
part.Parent = Camera
local highlight = Instance.new('BoxHandleAdornment')
highlight.Size = Vector3.new(3, 3, 3)
highlight.AlwaysOnTop = true
highlight.ZIndex = 1
highlight.Transparency = 0.5
highlight.Color3 = Color3.fromRGB(128, 0, 128) -- Purple color
highlight.Adornee = part
highlight.Parent = part
table.insert(shared.parts, part)
shared.parts[1].Position = Vector3.new(0, -1000, 0) -- Move off-screen initially
local function getBlockPositions(block)
	local handler = bedwars["BlockEngine"]:getHandlerRegistry():getHandler(block.Name)
	return handler and handler:getContainedPositions(block) or { getserverpos(block.Position) }
end

local function findBestPosition(positions, beddistance, block)
	local bestCost, bestPos = math.huge, nil
	local localPos = LocalPlayer.Character.HumanoidRootPart.Position
	for _, pos in ipairs(positions) do
		local worldPos = (type(pos) == "table" and Vector3.new(pos[1] * 3, pos[2] * 3, pos[3] * 3)) or (pos * 3)
		if typeof(worldPos) ~= "Vector3" or (localPos - worldPos).Magnitude > beddistance then
			continue
		end
		local dpos, dcost = calculatePath(block, worldPos)
		if dpos and dcost < bestCost then
			bestCost, bestPos = dcost, dpos
		end
	end
	return bestPos
end

local function updateHighlight(bedToHighlight, HighlightBlockEnabled)
	local targetPos = HighlightBlockEnabled and bedToHighlight or Vector3.new(0, -1000, 0)
	if shared.parts[1].Position ~= targetPos then
		shared.parts[1].Position = targetPos
	end
end

local function breakBlock(block, beddistance, HighlightBlockEnabled)
	local success, result = pcall(function()
		if LocalPlayer:GetAttribute('DenyBlockBreak') or not IsAlive(LocalPlayer) then
			return false
		end

		local bestPos = findBestPosition(getBlockPositions(block), beddistance, block)
		if not bestPos then
			return false
		end

		local dblock, dpos = getPlacedBlock(bestPos)
		if not dblock then
			return false
		end

		updateHighlight(dpos * 3, HighlightBlockEnabled)

		local breakType = bedwars.ItemMeta[dblock.Name].block and bedwars.ItemMeta[dblock.Name].block.breakType
		if breakType and store.tools[breakType] then
			task.spawn(function() switchItem(store.tools[breakType].tool) end)
		end

		local serverResult = game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@easy-games")
			:FindFirstChild("block-engine").node_modules:FindFirstChild("@rbxts").net.out
			._NetManaged.DamageBlock:InvokeServer({
				blockRef = { blockPosition = dpos },
				hitPosition = bestPos,
				hitNormal = Vector3.FromNormalId(Enum.NormalId.Top)
			})

		if serverResult == "destroyed" then
			cache[dpos] = nil
			updateHighlight(nil, false)
			return true
		end
		return serverResult ~= "cancelled"
	end)

	if not success then
		print("[BedNuker] Error in breakBlock:", result)
		return false
	end
	return result
end
function endnuker()
	for _, v in pairs(cache) do
		table.clear(v[3])
		table.clear(v)
	end
	updateHighlight(nil, false)
	table.clear(cache)
end
local function isNotHoveringOverGui()
	local mousepos = game:GetService("UserInputService"):GetMouseLocation() - Vector2.new(0, 36)
	for i, v in pairs(LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
		if v.Active then
			return false
		end
	end
	for i, v in pairs(game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
		if v.Parent:IsA("ScreenGui") and v.Parent.Enabled then
			if v.Active then
				return false
			end
		end
	end
	return true
end

local function getWool()
	local wool = GetItemNear("wool")
	return wool and wool.itemType, wool and wool.amount
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

function placeblock(blocktype, blockpos)
	game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@easy-games")
        :FindFirstChild("block-engine").node_modules:FindFirstChild("@rbxts").net.out._NetManaged
        .PlaceBlock:InvokeServer({
		["blockType"] = blocktype,
		["blockData"] = 0,
		["position"] = getserverpos(blockpos)
	})
	return true
end

function ClosestEntity(distance)
	local returnedtarget = nil
	local getclosettablemonster = {}
	local TargetDistance = math.huge
	for i, v in next, (collectionService:GetTagged('Monster')) do
		if v.PrimaryPart then
			local mag = (v.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
			if mag <= distance then
				table.insert(getclosettablemonster, v)
			end
		end
	end
	for i, v in next, (collectionService:GetTagged('DiamondGuardian')) do
		if v.PrimaryPart then
			local mag = (v.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
			if mag <= distance then
				table.insert(getclosettablemonster, v)
			end
		end
	end
	for i, v in next, (workspace:GetChildren()) do
		if v.Name == "Emerald Enemy Dummy" and v.PrimaryPart then
			local mag = (v.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
			if mag <= distance then
				table.insert(getclosettablemonster, v)
			end
		end
	end
	for i, v in pairs(getclosettablemonster) do
		local MosterPOS = v.PrimaryPart.Position
		local mag = (MosterPOS - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
		if mag < TargetDistance then
			TargetDistance = mag
			returnedtarget = v
		end
	end
	return returnedtarget
end

local function ClosetEntityPlayerCheck(entity, distance, enitycheck)
	if ((enitycheck and entity.PrimaryPart.Position or entity.Character.HumanoidRootPart.Position) - LocalPlayer.Character.HumanoidRootPart.Position).magnitude < distance then
		return true
	else
		return false
	end
end

local function rotateTo(position)
	local x = position.X
	local z = position.Z
	local hroot = LocalPlayer.Character.HumanoidRootPart
	local newcf = CFrame.lookAt(hroot.Position,
        (GetMatchState() ~= 0) and Vector3.new(x, hroot.Position.Y, z) or hroot.CFrame)
	if newcf == newcf then
		hroot.CFrame = newcf
	end
end

local function sendattackfire(sword, entity, monster, plr, selfpos, rootpos, cursdirection, camerapositon, chargedmeta)
	game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged
        .SwordHit:FireServer({
		["weapon"] = sword.tool,
		["entityInstance"] = entity and monster or plr.Character,
		["chargedAttack"] = {
			["chargeRatio"] = chargedmeta.sword.chargedAttack and not chargedmeta.sword.chargedAttack.disableOnGrounded and 0.999 or 0
		},
		["validate"] = {
			["raycast"] = {
				["cameraPosition"] = valuefunc(camerapositon),
				["cursorDirection"] = valuefunc(cursdirection)
			},
			["targetPosition"] = valuefunc(rootpos),
			["selfPosition"] = valuefunc(selfpos +
                ((selfpos - rootpos).Magnitude > 14 and (CFrame.lookAt(selfpos, rootpos).LookVector * 4) or Vector3.new(0, 0, 0))),
		},
		["lastSwingServerTimeDelta"] = workspace:GetServerTimeNow() - bedwars["SwordController"].lastAttackTimeDelta,
	})
end

local blockRaycast = RaycastParams.new()
blockRaycast.FilterType = Enum.RaycastFilterType.Include
local blocks = collectionService:GetTagged('block')
blockRaycast.FilterDescendantsInstances = {
	blocks
}
collectionService:GetInstanceAddedSignal('block'):Connect(function(block)
	table.insert(blocks, block)
	blockRaycast.FilterDescendantsInstances = {
		blocks
	}
end)
collectionService:GetInstanceRemovedSignal('block'):Connect(function(block)
	block = table.find(blocks, block)
	if block then
		table.remove(blocks, block)
		blockRaycast.FilterDescendantsInstances = {
			blocks
		}
	end
end)
-- Function to get shop item details by itemType
local function getShopItem(itemType)
	for _, item in ipairs(bedwars["ShopItems"]) do
		if item.itemType == itemType then
			return item
		end
	end
	return nil
end
-- Function to buy an item from the shop
local function buyremote(swordarmorname, shopid)
	if swordarmorname == nil or shopid == nil then
		return
	end
	local args = {
		[1] = {
			["shopItem"] = {
				["ignoredByKit"] = {},
				["itemType"] = swordarmorname,
				["price"] = 1,
				["superiorItems"] = {
					[1] = "ravenb4"
				},
				["currency"] = "iron",
				["amount"] = 1,
				["lockAfterPurchase"] = true,
				["category"] = "Combat",
				["disabledInQueue"] = {}
			},
			["shopId"] = shopid
		}
	}
	RepStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("BedwarsPurchaseItem"):InvokeServer(unpack(args))
end
return {
	bedwars = bedwars,
	SwordAnimations = SwordAnimations,
	SetCamera = SetCamera,
	IsAlive = IsAlive,
	GetClosest = GetClosest,
	GetClosestTeamCheck = GetClosestTeamCheck,
	GetBeds = GetBeds,
	GetClosestBeds = GetClosestBeds,
	getPlacedBlock = getPlacedBlock,
	getserverpos = getserverpos,
	GetMatchState = GetMatchState,
	GetQueueType = GetQueueType,
	GetInventory = GetInventory,
	BedwarsSwords = BedwarsSwords,
	valuefunc = valuefunc,
	getSword = getSword,
	GetItemNear = GetItemNear,
	cachedNormalSides = cachedNormalSides,
	isBlockCovered = isBlockCovered,
	switchItem = switchItem,
	isNotHoveringOverGui = isNotHoveringOverGui,
	getWool = getWool,
	LoopManager = LoopManager,
	ClosestEntity = ClosestEntity,
	ClosetEntityPlayerCheck = ClosetEntityPlayerCheck,
	rotateTo = rotateTo,
	sendattackfire = sendattackfire,
	blockRaycast = blockRaycast,
	placeblock = placeblock,
    breakBlock = breakBlock,
    endnuker = endnuker,
    RavenEquippedKit = RavenEquippedKit,
	getShopItem = getShopItem,
	buyremote = buyremote,
}
