
-- Services initialization
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local inputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SwordAnimations = module.SwordAnimations
local store = module.store
local GetClosest = module.GetClosest
local IsAlive = module.IsAlive
local getTool = module.getTool
local parsePositions = module.parsePositions
local LoopManager = module.LoopManager
local getGamemode = module.getGamemode
local BridgeDuel = {}

spawn(function()
	BridgeDuel = {
		Functions = {},
		Remotes = {}
	}

	BridgeDuel.Functions.GetRemote = function(name: RemoteEvent | RemoteFunction): RemoteEvent | RemoteFunction
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
	BridgeDuel.Remotes = {
		AttackPlayer = BridgeDuel.Functions.GetRemote('AttackPlayerWithSword'),
		BlockSword = BridgeDuel.Functions.GetRemote('ToggleBlockSword'),
        EnterQueue = BridgeDuel.Functions.GetRemote('PlaceBlock')
	}
	repeat task.wait() until BridgeDuel.Functions and BridgeDuel.Remotes
end)

local Boxes, SwingDelay = {}, tick()
local animcompleted = true
local BreakAnimation = false
local CustomAnimationEnabled = false
local NoAnimationEnabled = false
local critsenabled = false
local AnimationTime = 100
local TransperancyValue = 50
local Anglemax = 180

local loop = LoopManager.new()
Killaura = Combat:CreateToggle({
	Name = "Killaura",
	Callback = function(Callback)
		if Callback then
			loop:AddTask("Killaura", function()
				if not IsAlive(LocalPlayer) then
					Boxes.Adornee = nil
					BreakAnimation = true
					return
				end
				local tool = getTool()
				local Target
				if getGamemode() == "Special" then
                    Target = GetClosest()
                else
                    Target = GetClosest(TeamCheckEnabled)
                end
				if not Target or not tool or not tool:HasTag('Sword') or not IsAlive(Target) then
					Boxes.Adornee = nil
					BreakAnimation = true
					return
				end
				if tool and tool:HasTag('Sword') and Target and Target.Character then
					local selfpos = LocalPlayer.Character.HumanoidRootPart.Position
					local localfacing = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
					local delta = (Target.Character.HumanoidRootPart.Position - selfpos)
					if delta.Magnitude > AttackRange then
						if AutoBlock then
							if BridgeDuel.Functions and BridgeDuel.Remotes then
								BridgeDuel.Remotes.BlockSword:InvokeServer(false, tool.Name)
							end
						end
						Boxes.Adornee = nil
						BreakAnimation = true
						return
					end
					local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
					if angle > (math.rad(Anglemax) / 2) then
						if AutoBlock then
							if BridgeDuel.Functions and BridgeDuel.Remotes then
								BridgeDuel.Remotes.BlockSword:InvokeServer(false, tool.Name)
							end
						end
						BreakAnimation = true
						Boxes.Adornee = nil
						return
					end
					if AutoBlock and (delta.Magnitude < BlockRange) then
						if BridgeDuel.Functions and BridgeDuel.Remotes then
							BridgeDuel.Remotes.BlockSword:InvokeServer(true, tool.Name)
						end
					end
					if SwingDelay < tick() then
						SwingDelay = tick() + 0.25
						LocalPlayer.Character.Humanoid.Animator:LoadAnimation(tool.Animations.Swing):Play()
						--[[if not CustomAnimationEnabled and not NoAnimationEnabled then
							BridgeDuel.ViewmodelController:PlayAnimation(tool.Name)
						end]]
					end
					if animcompleted and CustomAnimationEnabled and not NoAnimationEnabled then
						animcompleted = false
						task.spawn(function()
							local viewmodel
							pcall(function()
								viewmodel = workspace.CurrentCamera:WaitForChild('Viewmodel')[tool.Name].Handle.MainPart
							end)
							if viewmodel == nil then
								animcompleted = true
								return
							end
							local viewmodelcopy = viewmodel.C0
							local oldviewmodel = viewmodel.C0
							if workspace.CurrentCamera.Viewmodel and viewmodel ~= nil then
								Anim = game:GetService("TweenService"):Create(viewmodel, TweenInfo.new(AnimationTime / 1000), {
									C0 = viewmodelcopy * SwordAnimations.Anim1.CFrame
								})
								Anim:Play()
								Anim.Completed:Wait()
								repeat
									if BreakAnimation == true then
										BreakAnimation = false
										break
									end
									Anim = game:GetService("TweenService"):Create(viewmodel, TweenInfo.new(AnimationTime / 1000), {
										C0 = viewmodelcopy * SwordAnimations.Anim2.CFrame
									})
									Anim:Play()
									Anim.Completed:Wait()
									Anim = game:GetService("TweenService"):Create(viewmodel, TweenInfo.new(AnimationTime / 1000), {
										C0 = viewmodelcopy * SwordAnimations.Anim3.CFrame
									})
									Anim:Play()
									Anim.Completed:Wait()
								until not true
								Anim = game:GetService("TweenService"):Create(viewmodel, TweenInfo.new(AnimationTime / 1000), {
									C0 = oldviewmodel
								})
								Anim:Play()
								Anim.Completed:Wait()
								animcompleted = true
							end
						end)
					end
					--[[local bdent = BridgeDuel.Entity.FindByCharacter(Target.Character)
					if bdent ~= nil then
						BridgeDuel.BlinkClient.item_action.attack_entity.fire({
							["target_entity_id"] = bdent.Id,
							["is_crit"] = LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0,
							["weapon_name"] = tool.Name,
							["extra"] = {
								["rizz"] = "No",
								["sigma"] = "The.",
								["those"] = workspace.Name == "Ok"
							}
						})
						BridgeDuel.ToolService:AttackPlayerWithSword(bdent.Id, LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0, tool.Name, "\226\128\139")
					end]]
					print('what the heck')
					if BridgeDuel.Remotes and BridgeDuel.Functions then
						print('what the helly?')
						BridgeDuel.Remotes.AttackPlayerWithSword:InvokeServer(Target.Character, (critsenabled == true and true) or LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0, tool.Name)
					end
					Boxes.Adornee = Target.Character.HumanoidRootPart
					Boxes.Color3 = Color3.fromRGB(204, 0, 204)
					Boxes.Transparency = (TransperancyValue / 100)
				else
					Boxes.Adornee = nil
				end
			end,0.01, 2)
		else
			task.wait(0.1)
			loop:Destroy()
			Boxes.Adornee = nil
			BreakAnimation = true
			loop = LoopManager.new()
		end
	end
})
Killaura:CreateInfo("Spiderman!")
Killaura:CreateDropDown({
	Name = "Mode",
	DefaultOption = "Health",
	SecondArrayitem = true,
	Options = {
		"Closest",
		"Health",
	},
	Callback = function(Callback)
		Targetoptions = Callback
	end
})
Killaura:CreateToggle({
	Name = "AutoBlock",
	Callback = function(Callback)
		AutoBlock = Callback
	end
})
Killaura:CreateToggle({
	Name = "TeamCheck",
	Callback = function(Callback)
		TeamCheckEnabled = Callback
	end
})
Killaura:CreateToggle({
	Name = "Show target",
	Callback = function(Callback)
		if Callback then
			local box = Instance.new('BoxHandleAdornment')
			box.Adornee = nil
			box.AlwaysOnTop = true
			box.Size = Vector3.new(3, 5, 3)
			box.CFrame = CFrame.new(0, -0.5, 0)
			box.ZIndex = 0
			box.Parent = workspace
			Boxes = box
		else
			Boxes:Destroy()
		end
	end
})
Killaura:CreateSlider({
	Name = "Transperancy",
	Default = 50,
	Min = 1,
	Max = 100,
	Callback = function(Callback)
		TransperancyValue = Callback
	end
})
Killaura:CreateToggle({
	Name = "No Animation",
	Callback = function(Callback)
		NoAnimationEnabled = Callback
	end
})
Killaura:CreateToggle({
	Name = "CustomAnimation",
	Callback = function(Callback)
		CustomAnimationEnabled = Callback
	end
})
Killaura:CreateSlider({
	Name = "Attack Range",
	Default = 20,
	Min = 5,
	Max = 25,
	Callback = function(Callback)
		AttackRange = Callback
	end
})
Killaura:CreateSlider({
	Name = "Block Range",
	Default = 20,
	Min = 5,
	Max = 25,
	Callback = function(Callback)
		BlockRange = Callback
	end
})
Killaura:CreateSlider({
	Name = "Max angle",
	Default = 360,
	Min = 1,
	Max = 360,
	Callback = function(Callback)
		Anglemax = Callback
	end
})
Killaura:CreateSlider({
	Name = "AnimationTime",
	Default = 100,
	Min = 10,
	Max = 1000,
	Callback = function(Callback)
		AnimationTime = Callback
	end
})

local TargetHudRange = 25
TargetHudModule = Client:CreateToggle({
	Name = "Target Hud",
	Callback = function(Callback)
		TargetHudEnabled = Callback
		if TargetHudEnabled then
			repeat
				task.wait()
				if shared.TargetHud == nil then
					continue
				end
				GetClosestPlayer = GetClosest()
				if GetClosestPlayer ~= nil then
					if getGamemode() ~= "Special" and TargetTeamCheckEnabled and GetClosest().TeamColor == LocalPlayer.TeamColor then
						continue
					end
					local Magnitude = (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - GetClosestPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
					if Magnitude < TargetHudRange then
						pcall(function (...)
							shared.TargetHud.Visible = true
							shared.TargetName.Text = GetClosestPlayer.Name
							shared.TargetName.TextColor3 = GetClosestPlayer.TeamColor.Color
							shared.TargetState.Text = GetClosestPlayer.Character.Humanoid.Health <= LocalPlayer.Character.Humanoid.Health and "W" or "L"
							shared.TargetState.TextColor3 = GetClosestPlayer.Character.Humanoid.Health <= LocalPlayer.Character.Humanoid.Health and Color3.fromRGB(34, 255, 0) or Color3.fromRGB(255, 5, 22)
							shared.TargetColor.TextColor3 = GetClosestPlayer.TeamColor.Color
							shared.TargetColor.Text = GetClosestPlayer.TeamColor ~= nil and tostring(string.sub(tostring(GetClosestPlayer.TeamColor), 1, 1)) or ""
							shared.TargetHealth.Text = tostring(math.round(GetClosestPlayer.Character.Humanoid.Health))
							if GetClosestPlayer.Character.Humanoid.Health >= 90 then
								shared.TargetHealth.TextColor3 = Color3.fromRGB(34, 255, 0)
							elseif GetClosestPlayer.Character.Humanoid.Health >= 50 then
								shared.TargetHealth.TextColor3 = Color3.fromRGB(255, 125, 11)
							else
								shared.TargetHealth.TextColor3 = Color3.fromRGB(255, 5, 22)
							end
							game:GetService("TweenService"):Create(shared.SliderInner, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
								Size = UDim2.fromScale((GetClosestPlayer.Character.Humanoid.Health / GetClosestPlayer.Character.Humanoid.MaxHealth), 1)
							}):Play()
							shared.SliderInner2.Size = UDim2.fromScale((GetClosestPlayer.Character.Humanoid.Health / GetClosestPlayer.Character.Humanoid.MaxHealth), 1)
						end)
					else
						shared.TargetHud.Visible = false
					end
				else
					shared.TargetHud.Visible = false
				end
			until not TargetHudEnabled
			shared.TargetHud.Visible = false
		end
	end
})
TargetHudModule:CreateInfo("Shows Infos about the Player!")
TargetHudModule:CreateToggle({
	Name = "TeamCheck",
	Callback = function(Callback)
		TargetTeamCheckEnabled = Callback
	end
})
TargetHudModule:CreateSlider({
	Name = "Range",
	Default = 20,
	Min = 0,
	Max = 20,
	Callback = function(Callback)
		TargetHudRange = Callback
	end
})

local Critcals
Criticals = Combat:CreateToggle({
	Name = "Critcals",
	Function = function(callback)
		critsenabled = callback
	end
})

local reachpath = ReplicatedStorage.Constants.Melee.Reach
local loop = LoopManager.new()
ReachRange = 16
Reach = Combat:CreateToggle({
	Name = "Reach",
	Callback = function(Callback)
		if Callback then
			loop:AddTask('Reach', function()
				reachpath.Value = ReachRange
			end)
		else
			reachpath.Value = 9
			loop = LoopManager.new()
		end
	end
})
Reach:CreateSlider({
	Name = "Range",
	Default = 16,
	Min = 3,
	Max = 16,
	Callback = function(Callback)
		ReachRange = Callback
	end
})

Velocity = Combat:CreateToggle({
	Name = "Velocity",
	Callback = function(Callback)
		if Callback then
			pcall(function()
				local old = ReplicatedStorage.Modules.Knit.Services.CombatService.RE.KnockBackApplied
				old:Destroy()
			end)
		else
			shared:createnotification('Velocity will be disabled next game', 5, 'Raven')
		end
	end
})

EnabledFly = false
FlyDown = false
FlyUp = false
Fly = Blatant:CreateToggle({
	Name = "Fly",
	Callback = function(Callback)
		EnabledFly = Callback
		if EnabledFly and IsAlive(LocalPlayer) then
			task.spawn(function()
				velo = Instance.new("BodyVelocity")
				velo.MaxForce = Vector3.new(0, 9e9, 0)
				velo.Parent = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				inputService.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Space then
						FlyUp = true
					end
					if input.KeyCode == Enum.KeyCode.LeftShift then
						FlyDown = true
					end
				end)
				inputService.InputEnded:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Space then
						FlyUp = false
					end
					if input.KeyCode == Enum.KeyCode.LeftShift then
						FlyDown = false
					end
				end)
				spawn(function()
					repeat
						task.wait()
						velo.Velocity = Vector3.new(0, (FlyUp and UpValue or 0) + (FlyDown and -DownValue or 0), 0)
					until not (EnabledFly and IsAlive(LocalPlayer))
					if not (EnabledFly and IsAlive(LocalPlayer)) then
						LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity"):Destroy()
						Flyup = false
						FlyDown = false
					end
				end)
			end)
		end
	end
})
Fly:CreateInfo("Makes you a raven ;)")
Fly:CreateSlider({
	Name = "Up",
	Default = 50,
	Min = 0,
	Max = 100,
	Callback = function(Callback)
		UpValue = Callback
	end
})
Fly:CreateSlider({
	Name = "Down",
	Default = 50,
	Min = 0,
	Max = 100,
	Callback = function(Callback)
		DownValue = Callback
	end
})

--[[local isTowerActive = false
local isLimitItemActive = false
local isKeepYActive = false
local isShowBlockCountActive = false
local towerSpeed = 20
local initialYPosition = nil
local isFirstRun = true
local IsBlockdeleteenabled = false
local gridOffsets = {}
for dx = -1, 1 do
    for dy = -1, 1 do
        for dz = -1, 1 do
            if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                local offset = Vector3.new(dx * 3, dy * 3, dz * 3)
                table.insert(gridOffsets, offset)
            end
        end
    end
end
local function round(pos)
    return Vector3.new(
        math.floor((pos.X + 1.5) / 3) * 3,
        math.floor((pos.Y + 1.5) / 3) * 3,
        math.floor((pos.Z + 1.5) / 3) * 3
    )
end
local function hasNeighbors(pos)
    for _, offset in ipairs(gridOffsets) do
        if store.blocks[pos + offset] then
            return true
        end
    end
    return false
end
local blockCountLabel = Instance.new("TextLabel")
blockCountLabel.Parent = shared.ScreenGui2
blockCountLabel.BackgroundTransparency = 1
blockCountLabel.Position = UDim2.new(0.515, 0, 0.429, 0)
blockCountLabel.Size = UDim2.new(0, 122, 0, 30)
blockCountLabel.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
blockCountLabel.Text = "Blocks: 0"
blockCountLabel.TextColor3 = Color3.new(1, 1, 1)
blockCountLabel.TextSize = 20
blockCountLabel.Visible = false
blockCountLabel.RichText = true
local loop = LoopManager.new()
Scaffold = Blatant:CreateToggle({
    Name = "Scaffold",
    Callback = function(isEnabled)
        if isEnabled then
            isFirstRun = true
            loop:AddTask("Scaffold", function()
                if not isEnabled then return end 
                if IsAlive() then
                    local tool = true
                    if isLimitItemActive then
                        tool = getTool()
                        tool = tool and tool.Name:find('Block')
                    end
                    if tool then

                        if isShowBlockCountActive then
                            blockCountLabel.Visible = true
                            for _, v in pairs(LocalPlayer.PlayerGui.Hotbar:GetDescendants()) do
                                if v.Name == "Blocks" and v.Parent.Name == "ViewportFrame" then
                                    blockCountLabel.Text = '<stroke color="#000000" thickness="1" transparency="0.25">' .. "Blocks: " .. v.Parent.Parent.Number.Text .. '</stroke>'
                                end
                            end
                        else
                            blockCountLabel.Visible = false
                        end
                        if isFirstRun then
                            isFirstRun = false
                            initialYPosition = LocalPlayer.Character.HumanoidRootPart.Position.Y
                        end
                        local root = LocalPlayer.Character.HumanoidRootPart
                        local rootPosition = isKeepYActive and Vector3.new(root.Position.X, initialYPosition, root.Position.Z) or root.Position
                        if isTowerActive and inputService:IsKeyDown(Enum.KeyCode.Space) and not inputService:GetFocusedTextBox() then
                            root.Velocity = Vector3.new(root.Velocity.X, towerSpeed, root.Velocity.Z)
                            isFirstRun = true
                        end
                        local targetPosition = round(rootPosition - Vector3.new(0, LocalPlayer.Character.Humanoid.HipHeight + 1.5, 0))
                        if not store.blocks[targetPosition] then
                            if targetPosition and hasNeighbors(targetPosition) then
                                local fakeBlock = Instance.new('Part')
                                fakeBlock.Name = 'TempBlock'
                                fakeBlock.Anchored = true
                                fakeBlock.Transparency = 1
                                fakeBlock.Size = Vector3.new(3, 3, 3)
                                fakeBlock.Position = targetPosition
                                fakeBlock:AddTag('TempBlock')
                                fakeBlock:AddTag('Block')
                                fakeBlock.Parent = workspace.Map
                                BridgeDuel.EffectsController:PlaySound(targetPosition)
                                if not IsBlockdeleteenabled then
                                    BridgeDuel.Entity.LocalEntity:RemoveTool('Blocks', 1)
                                end
                                task.spawn(function()
                                    local suc, block = BridgeDuel.BlinkClient.item_action.place_block.invoke({
                                        position = targetPosition,
                                        block_type = 'Clay',
                                        extra = {
                                            rizz = "No",
                                            sigma = "The.",
                                            those = workspace.Name == "Ok"
                                        }
                                    })
                                    fakeBlock:Destroy()
                                    if not (suc or block) and not IsBlockdeleteenabled then
                                        BridgeDuel.Entity.LocalEntity:RemoveTool('Blocks', 1)
                                    end
                                end)
                            end
                        end
                    else
                        isFirstRun = true
                        blockCountLabel.Visible = false
                    end
                end
            end,0.01, 2)
        else
			loop:Destroy()
			loop = LoopManager.new()
            blockCountLabel.Visible = false
            isFirstRun = true
            initialYPosition = nil
            for _, block in pairs(workspace.Map:GetChildren()) do
                if block.Name == "TempBlock" then
                    block:Destroy()
                end
            end
        end
    end
})
Scaffold:CreateToggle({
    Name = "No Block delete",
    StartingState = true,
    Callback = function(Callback)
        IsBlockdeleteenabled = Callback
    end
})
Scaffold:CreateToggle({
    Name = "Limit to items",
    StartingState = true,
    Callback = function(Callback)
        isLimitItemActive = Callback
    end
})
Scaffold:CreateToggle({
    Name = "Blockcount",
    StartingState = true,
    Callback = function(Callback)
        isShowBlockCountActive = Callback
    end
})
Scaffold:CreateToggle({
    Name = "Keep Y",
    StartingState = true,
    Callback = function(Callback)
        isKeepYActive = Callback
    end
})
Scaffold:CreateToggle({
    Name = "Tower",
    StartingState = true,
    Callback = function(Callback)
        isTowerActive = Callback
    end
})
Scaffold:CreateSlider({
    Name = "Tower Speed",
    Default = 40,
    Min = 10,
    Max = 40,
    Callback = function(Callback)
        towerSpeed = Callback
    end
})]]

--[[local Breaker
local function getPickaxe()
	for name in BridgeDuel.Entity.LocalEntity.Inventory do
		if name:find('Pickaxe') then
			return name
		end
	end
end
local BreakerRange = 10
local breakTime = os.clock()
Breaker = Blatant:CreateToggle({
	Name = "BedNuker",
	Callback = function(Callback)
		BreakerEnabed = Callback
		if BreakerEnabed then
			local breakPosition
			local lastBreak
			repeat
				task.wait()
				breakPosition = nil
				if IsAlive() then
					local pickaxe = getPickaxe()
					if pickaxe then
						local maxpos = math.huge
						for i, v in pairs(workspace.Map:GetDescendants()) do
							if v.Name == 'Block' and (v.Parent.Name == 'Bed' and LocalPlayer.Team and v.Parent:GetAttribute('Team') ~= LocalPlayer.Team.Name) then
								local posmag = (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
								if (maxpos > posmag) and (posmag < BreakerRange) then
									maxpos = posmag
									breakPosition = v.Position
								end
							end
						end
						if breakPosition ~= nil and breakPosition ~= lastBreak then
							if breakPosition then
								breakTime = os.clock() + 0.3
                                        --fake2.Position = breakPosition
                                        --fake2.Transparency = 0
								BridgeDuel.BlinkClient.item_action.start_break_block.fire({
									position = breakPosition,
									pickaxe_name = pickaxe,
									timestamp = workspace:GetServerTimeNow()
								})
							else 
								BridgeDuel.BlinkClient.item_action.stop_break_block.fire(false)
							end
							lastBreak = breakPosition
						elseif breakPosition and breakTime < os.clock() then
								BridgeDuel.BlinkClient.item_action.stop_break_block.fire(true)
								breakTime = os.clock() + 100
						end
					else
                                --fake2.Transparency = 1
					end
				else
                            --fake2.Transparency = 1
				end

			until not BreakerEnabed
                    --fake2.Transparency = 1
		else
                    --fake2.Transparency = 1
		end
	end
})
Breaker:CreateSlider({
	Name = "Range",
	Default = 15,
	Min = 1,
	Max = 15,
	Callback = function(Callback)
		BreakerRange = Callback
	end
})]]

local NewSpeed = 23
local raycastparameters = RaycastParams.new()
local Jumpoptions = ""
local loop = LoopManager.new()
local noslowactive = false

Speed = Blatant:CreateToggle({ 
	Name = "Speed",
	Callback = function(Callback)
		EnabledSpeed = Callback
		if EnabledSpeed then
			loop:AddTask("Speed", function(delta)
				if IsAlive(LocalPlayer) then
					local ActualSpeed = NewSpeed
					if noslowactive then
						ActualSpeed = NewSpeed + 20
					end
					local speedCFrame = LocalPlayer.Character.Humanoid.MoveDirection * ((ActualSpeed) - 20) * delta
					local speedCFrame2 = LocalPlayer.Character.Humanoid.MoveDirection * ((ActualSpeed) - 18) * delta
					raycastparameters.FilterDescendantsInstances = {
						LocalPlayer.Character
					}
					local ray = workspace:Raycast(LocalPlayer.Character.HumanoidRootPart.Position, speedCFrame2, raycastparameters)
					if ray then
						LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
					else
						LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + speedCFrame
					end
					if LocalPlayer.character.Humanoid.FloorMaterial ~= Enum.Material.Air and LocalPlayer.Character.Humanoid.MoveDirection ~= Vector3.zero and Jumpoptions ~= "" then
						if Jumpoptions == "Normal" then
						elseif Jumpoptions == "AutoJump" then
							LocalPlayer.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						elseif Jumpoptions == "Lowhop" then
							local velocity = LocalPlayer.character.HumanoidRootPart.Velocity * Vector3.new(1, 0, 1)
							LocalPlayer.character.HumanoidRootPart.Velocity = Vector3.new(velocity.X, 10, velocity.Z)
						end
					end
				end
			end)
		else
			loop:Destroy()
		end
	end
})
Speed:CreateInfo("Makes you go zoooom")
Speed:CreateDropDown({
	Name = "Mode",
	DefaultOption = "Lowhop",
	SecondArrayitem = true,
	Options = {
		"Normal",
		"AutoJump",
		"Lowhop",
	},
	Callback = function(Callback)
		Jumpoptions = Callback
	end
})
Speed:CreateSlider({
	Name = "Speed",
	Default = 28,
	Min = 0,
	Max = 28,
	Callback = function(Callback)
		NewSpeed = Callback - 0.01
	end
})

HighJump = Blatant:CreateToggle({
	Name = "HighJump",
	Callback = function(Callback)
		HighJump = Callback
		if HighJump then
			JumpingConnect = LocalPlayer.Character.Humanoid.Jumping:Connect(function(IsJumping) --Best way to do this
				if IsJumping then
					if IsAlive(LocalPlayer) then
						workspace.Gravity = 192.6
						LocalPlayer.Character.HumanoidRootPart.Velocity += Vector3.new(0, JumpHeight, 0)
						task.wait(0.2)
						workspace.Gravity = 10
						task.wait(0.6)
						workspace.Gravity = 192.6
					end
				end
			end)
		else
			JumpingConnect:Disconnect()
		end
	end
})
HighJump:CreateInfo("Makes you lebron James")
HighJump:CreateSlider({
	Name = "JumpHeight",
	Default = 50,
	Min = 0,
	Max = 10000,
	Callback = function(Callback)
		JumpHeight = Callback
	end
})

local CheckInfJump = false
Blatant:CreateToggle({
	Name = "INF Jump",
	Callback = function(Callback)
		EnabledINFJUMP = Callback
		if EnabledINFJUMP then
			CheckInfJump = true
			ConnectionINFJUMP = game:GetService("UserInputService").JumpRequest:Connect(function()
				game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
			end)
		else
			if CheckInfJump then
				ConnectionINFJUMP:Disconnect()
			end
		end
	end
})

Render:CreateToggle({
	Name = "Bed Esp",
	Callback = function(Callback)
		if Callback then
			repeat
				task.wait()
			until workspace.Map ~= nil
			for i, v in pairs(workspace.Map:GetDescendants()) do
				if v.Parent.Name == 'Bed' and v.Parent:GetAttribute('Team') ~= LocalPlayer.Team.Name then
					local Highlight = Instance.new("Highlight", v)
					Highlight.Name = "Highlight"
					Highlight.Enabled = true
                        --Highlight.FillColor = Color3.new(255, 89, 227)
					Highlight.FillColor = Color3.new(80, 0, 80)
					Highlight.FillTransparency = 0.992
					Highlight.OutlineTransparency = 1
				end
			end
		else
			for i, v in pairs(workspace.Map:GetDescendants()) do
				if v.Parent ~= nil and v.Parent.Name == 'Bed' and v.Highlight ~= nil then
					v.Highlight:Destroy()
				end
			end
		end
	end
})

local Lighting = game:GetService("Lighting")
local Sky
Render:CreateToggle({
	Name = "Galaxy Sky",
	Callback = function(Callback)
		SkyEnabled = Callback
		if SkyEnabled then
			Sky = Instance.new("Sky")
			ID = 8281961896
			Sky.SkyboxBk = "http://www.roblox.com/asset/?id=" .. ID
			Sky.SkyboxDn = "http://www.roblox.com/asset/?id=" .. ID
			Sky.SkyboxFt = "http://www.roblox.com/asset/?id=" .. ID
			Sky.SkyboxLf = "http://www.roblox.com/asset/?id=" .. ID
			Sky.SkyboxRt = "http://www.roblox.com/asset/?id=" .. ID
			Sky.SkyboxUp = "http://www.roblox.com/asset/?id=" .. ID
			Sky.Parent = Lighting
		else
			if Sky then
				Sky:Destroy()
			end
		end
	end
})

local Atmosphere
Render:CreateToggle({
	Name = "Atmosphere",
	Callback = function(Callback)
		AtmoEnabled = Callback
		AtmoEnabled = Callback
		if AtmoEnabled then
			Atmosphere = Instance.new("ColorCorrectionEffect")
			Atmosphere.TintColor = Color3.fromHSV(0.7, 0.05, 0.7)
			Atmosphere.Parent = Lighting
		else
			if Atmosphere then
				Atmosphere:Destroy()
			end
		end
	end
})

local round2 = function(...)
	local a = {}
	for i, v in next, table.pack(...) do
		a[i] = math.round(v)
	end
	return unpack(a)
end
local wtvp = function(...)
	local a, b = Camera.WorldToViewportPoint(Camera, ...)
	return Vector2.new(a.X, a.Y), b, a.Z
end
local Esptable = {}
local function createEsp(plr)
	local drawings = {}
	drawings.box = Drawing.new("Square")
	drawings.box.Thickness = 1
	drawings.box.Filled = false
	drawings.box.Color = Color3.new(255, 255, 255)
	drawings.box.Visible = false
	drawings.box.ZIndex = 2
	Esptable[plr] = drawings
end
local function removeEsp(plr)
	if rawget(Esptable, plr) then
		for _, drawing in next, Esptable[plr] do
			drawing:Remove()
		end
		Esptable[plr] = nil
	end
end
local function updateEsp(plr, esp)
	local character = plr and plr.Character
	if character then
		local cframe = character:GetModelCFrame()
		local position, visible, depth = wtvp(cframe.Position)
		esp.box.Visible = visible
		if cframe and visible then
			local scaleFactor = 1 / (depth * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
			local width, height = round2(4 * scaleFactor, 5 * scaleFactor)
			local x, y = round2(position.X, position.Y)
			esp.box.Size = Vector2.new(width, height)
			esp.box.Position = Vector2.new(round2(x - width / 2, y - height / 2))
			esp.box.Color = ESPTeamCheck and plr.TeamColor.Color or Color3.fromRGB(255, 255, 255)
		end
	else
		esp.box.Visible = false
	end
end
Players.PlayerAdded:Connect(function(player)
	if EnabledESP then
		createEsp(player)
	end
end)
Players.PlayerRemoving:Connect(function(player)
	if EnabledESP then
		removeEsp(player)
	end
end)
ESP = Render:CreateToggle({
	Name = "ESP",
	Callback = function(Callback)
		EnabledESP = Callback
		if EnabledESP then
			for i, v in next, Players:GetPlayers() do
				if v ~= LocalPlayer then
					createEsp(v)
				end
			end
			repeat
				task.wait()
				for i, v in next, Esptable do
					if v and i ~= LocalPlayer then
						updateEsp(i, v)
					end
				end
			until not EnabledESP
		else
			for i, v in next, Players:GetPlayers() do
				if v ~= LocalPlayer then
					removeEsp(v)
				end
			end
		end
	end
})
ESP:CreateInfo("Makes you see people through walls O-O")
ESP:CreateToggle({
	Name = "TeamCheck",
	StartingState = true,
	Callback = function(Callback)
		ESPTeamCheck = Callback
	end
})

Render:CreateToggle({
	Name = "FPS Unlocker",
	Callback = function(Callback)
		EnabledFPS = Callback
		if EnabledFPS then
			setfpscap((120))
		end
	end
})

local ConnectionSlowdown = nil
NoSlow = Utility:CreateToggle({
	Name = "No Slow",
	Callback = function(Callback)
		if Callback and not Fly.Enabled then
			game:GetService("RunService").Heartbeat:Connect(function()
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
				bodyVelocity.Velocity = Vector3.new(0, 0, 0)
				bodyVelocity.Parent = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
				local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
				--local moveDirection = humanoid.MoveDirection
				bodyVelocity.Velocity = Vector3.new(0, 0, 0)
				noslowactive = true
			end)
		else
			if ConnectionSlowdown ~= nil then
				ConnectionSlowdown = nil
			end
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
			noslowactive = false
		end
	end
})
NoSlow:CreateDropDown({ --made for later
	Name = "Mode",
	DefaultOption = "Spoof",
	SecondArrayitem = true,
	Options = {
		"Spoof",
	},
	Callback = function(Callback)
	end
})

local Nofall
local loop = LoopManager.new()
Nofall = Utility:CreateToggle({
	Name = "No Fall",
	Callback = function(Callback)
		if Callback then
			loop:AddTask("Nofall", function()
				if LocalPlayer.character.Humanoid.FloorMaterial == Enum.Material.Air and (LocalPlayer.character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall or LocalPlayer.character.Humanoid:GetState() == Enum.HumanoidStateType.FallingDown) then
					LocalPlayer.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
				end
			end)
		else
			loop = LoopManager.new()
		end
	end
})
Nofall:CreateDropDown({ --made for later
	Name = "Mode",
	DefaultOption = "Cancel",
	SecondArrayitem = true,
	Options = {
		"Cancel",
	},
	Callback = function(Callback)
	end
})

--[[local old3
Utility:CreateToggle({
	Name = "Cps Check Remover",
	Callback = function(Callback)
		if Callback then
			old3 = hookfunction(BridgeDuel.BlinkClient.player_state.update_cps.fire, function ()
			end)
		else
			hookfunction(BridgeDuel.BlinkClient.player_state.update_cps.fire, old3)
			old3 = nil
		end
	end
})]]

Utility:CreateToggle({
	Name = "No Jumpscare",
	Callback = function(Callback)
		if Callback then
			game:GetService("ReplicatedStorage").UI.All.MainGui.Jumpscare:Destroy()
			game:GetService("ReplicatedStorage").CmdrClient.Commands.Jumpscare:Destroy()
			game:GetService("ReplicatedStorage").Remotes.Jumpscare:Destroy()
		end
	end
})

local apoption = "BedWarsDuos"
local autodtcmode = false
local gamemode
AutoQueue = Utility:CreateToggle({
	Name = "AutoQueue",
	Callback = function(Callback)
		if Callback then
			if LocalPlayer.PlayerGui.Hotbar.MainFrame.GameEndFrame.Visible == true then
				print("visible")
			else
				print("not visible")
			end
			print(getGamemode())
			repeat
				task.wait(1)
			until LocalPlayer.PlayerGui.Hotbar.MainFrame.GameEndFrame.Visible == true
			if not Callback then
				return -- nigga what
			end

			if autodtcmode then
				gamemode = getGamemode(true)
			else
				gamemode = apoption
			end
			if BridgeDuel.Functions and BridgeDuel.Remotes then
				BridgeDuel.Remotes.EnterQueue:InvokeServer(gamemode)
			end
		end
	end
})
local modetable = {
	"Solo",
	"Duos",
	"Trios",
	"Quads",
	"RankedSolo",
	"BoxingSolo",
	"BoxingBotSolo",
	"BasicFightSolo",
	"BasicFightDuos",
	"RankedBasicFightSolo",
	"BedWarsDuos",
}
AutoQueue:CreateDropDown({ --made for later
	Name = "Mode",
	DefaultOption = "BedWarsDuos",
	Options = modetable,
	Callback = function(Callback)
		apoption = Callback
	end
})
AutoQueue:CreateToggle({
	Name = "AutoDetect",
	Callback = function(Callback)
		autodtcmode = Callback
	end
})

local apoption2 = "RankedSolo"
ReQueue = Utility:CreateToggle({
	Name = "Re Queue",
	Callback = function(Callback)
		if Callback then
			if BridgeDuel.Functions and BridgeDuel.Remotes then
				BridgeDuel.Remotes.EnterQueue:InvokeServer(apoption2)
			end
		end
	end
})
local modetable = {
	"Solo",
	"Duos",
	"Trios",
	"Quads",
	"RankedSolo",
	"BoxingSolo",
	"BoxingBotSolo",
	"BasicFightSolo",
	"BasicFightDuos",
	"RankedBasicFightSolo",
	"BedWarsDuos",
}
ReQueue:CreateDropDown({ --made for later
	Name = "Mode",
	DefaultOption = "RankedSolo",
	Untoggle = true,
	Options = modetable,
	Callback = function(Callback)
		apoption2 = Callback
	end
})

local connect
Utility:CreateToggle({
	Name = "StaffLeave",
	Callback = function(Callback)
		if Callback then
			for i, v in pairs(game:GetService('Players'):GetChildren()) do
				if v:IsInGroup(6604847) and v:GetRankInGroup(6604847) > 1 then
					game:GetService('Players').LocalPlayer:Kick(v.Name .. ", A Staff is in the Game!")
				end
			end
			connect = game:GetService('Players').PlayerAdded:Connect(function(Player)
				if Player:IsInGroup(6604847) and Player:GetRankInGroup(6604847) > 1 then
					game:GetService('Players').LocalPlayer:Kick(Player.Name .. ", A Staff Has Joined Your Game!")
				end
			end)
		else
			connect:Disconnect()
		end
	end
})