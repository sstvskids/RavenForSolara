--Uninject feature instead of save system and rewrite save system
--[[
██████╗  █████╗ ██╗   ██╗███████╗███╗   ██╗    ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██║   ██║██╔════╝████╗  ██║    ██╔══██╗██║  ██║
██████╔╝███████║██║   ██║█████╗  ██╔██╗ ██║    ██████╔╝███████║
██╔══██╗██╔══██║╚██╗ ██╔╝██╔══╝  ██║╚██╗██║    ██╔══██╗╚════██║
██║  ██║██║  ██║ ╚████╔╝ ███████╗██║ ╚████║    ██████╔╝     ██║
╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝    ╚═════╝      ╚═╝
Author: Near (or nea.r)
Language: Lua
Category: GUI
]]
shared.listthemes = {
    ["Rainbow"] = { 0, 360 },
    ["Cotton Candy"] = { 250, 310 },
    ["Ocean"] = { 180, 240 }, -- Cyan to blue
    ["Sunset"] = { 0, 60 }, -- Red to orange
    ["Lime Glow"] = { 120, 180 }, -- Green to cyan
    ["Purple Berry"] = { 270, 330 }, -- Purple to magenta
    ["Forest"] = { 90, 150 }, -- Green to yellow-green
    ["Desert"] = { 30, 90 }, -- Yellow to orange-yellow
    ["Galaxy"] = { 240, 300 }, -- Blue to purple
    ["Berry"] = { 330, 360 } -- Magenta to red
}

shared.FileName = shared.RavenConfigName ~= nil and shared.RavenConfigName or 'Default Config'
local RepStorage = game:GetService("ReplicatedStorage")
local file = shared.FileName ~= nil and shared.FileName
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:service('HttpService')
local lib = {}
local ScreenGui = Instance.new("ScreenGui")
shared.ScreenGui2 = Instance.new("ScreenGui")
local Array = Instance.new("Frame")
local UIGridLayout = Instance.new("UIGridLayout")
local ScreenGUIFrame = Instance.new("Frame")
local GUILoadSettings = {}
local GUISaveSettings = {}
local FixedTable = {}
local RavenLogoButton = Instance.new("TextButton")
local ButtonLogo = Instance.new("ImageLabel")
local TweenService = game:GetService("TweenService")
local ModuleNotification = false
local allToggles = {} -- Table to store all toggle objects


-- At the top of the script, define the config file name and initialize variables
local HttpService = game:GetService("HttpService")
local file = shared.RavenConfigName or "DefaultConfig.json"
local GUISaveSettings = {}
local GUILoadSettings = {}
local saveDebounce = false
local saveDebounceTime = 0.5 -- Debounce time in seconds

-- Function to safely load settings from the config file
local function loadSettings()
    if isfile(file) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(file))
        end)
        if success and result then
            GUILoadSettings = result
        else
            warn("Failed to load config file: " .. tostring(result))
            GUILoadSettings = {}
        end
    else
        -- Initialize with an empty JSON object
        local success, err = pcall(function()
            writefile(file, HttpService:JSONEncode({}))
        end)
        if not success then
            warn("Failed to initialize config file: " .. tostring(err))
        end
        GUILoadSettings = {}
    end
end

-- Function to safely save settings to the config file
local function saveSettings()
    if saveDebounce then return end
    saveDebounce = true
    task.spawn(function()
        local success, err = pcall(function()
            writefile(file, HttpService:JSONEncode(GUISaveSettings))
        end)
        if not success then
            warn("Failed to save config file: " .. tostring(err))
        end
        task.wait(saveDebounceTime)
        saveDebounce = false
    end)
end

-- Load settings at script start
loadSettings()
-- Properties
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local MinimumTabletSize = Vector2.new(1024, 768)

-- Device type check
function CheckDeviceType()
    --[[if Mouse.ViewSizeX >= MinimumTabletSize.X and Mouse.ViewSizeY >= MinimumTabletSize.Y and UIS.MouseEnabled and UIS.KeyboardEnabled then
        return "Mobile"
    end]]
    return "Computer"
end

-- Sizing table based on device type
local sizingtable = {}
if CheckDeviceType() == "Mobile" then
    sizingtable.MainFrame = 170
    sizingtable.MainTabFrame = 10
    sizingtable.TabFrame = 15
    sizingtable.TabText = 25
    sizingtable.PlusMinuesButtonSize = 25
    sizingtable.PlusMinuesButtonSizeSecond = 23
    sizingtable.PlusMinuesButtonText = 25
    sizingtable.HolderFramePadding = 30
    sizingtable.MainButton = 30
    sizingtable.MainButtonText = 25
    sizingtable.BindSize = 15
    sizingtable.BindText = 11
    sizingtable.BindButtonPOS = 0.45
    sizingtable.BindButtonSize = 0.55
    sizingtable.InfoSize = 15
    sizingtable.InfoText = 13
    sizingtable.Minibutton = 17
    sizingtable.MinibuttonText = 12
    sizingtable.MainSlider = 30
    sizingtable.SliderText = 11
    sizingtable.SliderValueText = 13
else
    sizingtable.MainFrame = 255
    sizingtable.MainTabFrame = 40
    sizingtable.TabFrame = 23
    sizingtable.TabText = 29
    sizingtable.PlusMinuesButtonSize = 35
    sizingtable.PlusMinuesButtonSizeSecond = 32
    sizingtable.PlusMinuesButtonText = 30
    sizingtable.HolderFramePadding = 35
    sizingtable.MainButton = 40
    sizingtable.MainButtonText = 29
    sizingtable.BindSize = 25
    sizingtable.BindText = 14
    sizingtable.BindButtonPOS = 0.45
    sizingtable.BindButtonSize = 0.747
    sizingtable.InfoSize = 25
    sizingtable.InfoText = 14
    sizingtable.Minibutton = 25
    sizingtable.MinibuttonText = 14
    sizingtable.MainSlider = 35
    sizingtable.SliderText = 14
    sizingtable.SliderValueText = 14
end

-- Theme and animation logic
local usedtheme = "Cotton Candy"
local changefactor = false
local Converterdlist = {}
local Usedlist = {}

for i, v in pairs(shared.listthemes) do
    Converterdlist[i] = {}
    for i2 = 1, 10 do
        local offset = ((shared.listthemes[i][2] - shared.listthemes[i][1]) / 10)
        table.insert(Converterdlist[i], Color3.fromHSV(((i2 * offset) + shared.listthemes[i][1]) / 360, 1, 1))
    end
end

for i, v in pairs(shared.listthemes) do
    table.insert(Usedlist, i)
end

local counter = #Converterdlist[usedtheme]
local list = Converterdlist[usedtheme]
local canrun = true

spawn(function()
    repeat
        task.wait(1)
        if changefactor == true then
            changefactor = false
            counter = #Converterdlist[usedtheme]
            list = Converterdlist[usedtheme]
        end
        canrun = true
        task.wait(0.1)
        canrun = false
        if counter == #list - 1 then
            counter = 1
        elseif counter == #list then
            counter = 2
        elseif counter <= #list - 2 then
            counter = counter + 2
        end
    until not true
end)

local function animate(Parent, onlyrainbow)
    local status = true
    local first, second
    local s, kpt = ColorSequence.new, ColorSequenceKeypoint.new
    local gradient2 = Instance.new("UIGradient")
    gradient2.Parent = Parent
    local create = game:GetService("TweenService"):Create(gradient2, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Offset = Vector2.new(1, 0) })
    gradient2.Color = s({
        kpt(0, list[#list]),
        kpt(0.5, list[#list - 1]),
        kpt(1, list[#list - 2])
    })

    repeat
        task.wait()
        if not canrun then
            continue
        end
        gradient2.Offset = Vector2.new(-1, 0)
        gradient2.Rotation = status and 180 or 0
        if onlyrainbow then
            list = Converterdlist["Rainbow"]
        else
            list = Converterdlist[usedtheme]
        end
        first = (counter == #list - 1) and list[#list] or (counter == #list) and list[1] or list[counter + 1]
        second = (counter == #list - 1) and list[1] or (counter == #list) and list[2] or list[counter + 2]
        gradient2.Color = s({
            kpt(0, status and gradient2.Color.Keypoints[1].Value or second),
            kpt(0.5, first),
            kpt(1, status and second or gradient2.Color.Keypoints[3].Value),
        })
        status = not status
        create:Play()
        create.Completed:Wait()
    until gradient2 == nil
end

-- GUI setup
ScreenGUIFrame.Name = "ScreenGUIFrame"
ScreenGUIFrame.Parent = ScreenGui
ScreenGUIFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScreenGUIFrame.BackgroundTransparency = 1.000
ScreenGUIFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
ScreenGUIFrame.BorderSizePixel = 0
ScreenGUIFrame.Position = UDim2.new(0, 0, 0, 0)
ScreenGUIFrame.Size = UDim2.new(0, 0, 0, 0)

shared.ScreenGui2.Name = "ScreenGui2"
shared.ScreenGui2.Parent = game:WaitForChild("CoreGui")
shared.ScreenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Array.Name = "Array"
Array.Parent = shared.ScreenGui2
Array.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Array.BackgroundTransparency = 1.000
Array.BorderColor3 = Color3.fromRGB(0, 0, 0)
Array.BorderSizePixel = 0
Array.Position = UDim2.new(0.867999971, 0, 0, 10)
Array.Size = UDim2.new(0.127251238, 0, 0.980064094, 0)
Array.Visible = false

UIGridLayout.Parent = Array
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 0, 9.99999975e-05, 0)
UIGridLayout.CellSize = UDim2.new(1, 0, 0, 20)

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGUIFrame
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.650
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, -2000, 0, -2000)
Frame.Size = UDim2.new(0, 4016, 0, 4001)
Frame.Visible = false

local Lighting = game:GetService("Lighting")
local Blur = Instance.new("BlurEffect")
Blur.Name = "Blur"
Blur.Parent = Lighting
Blur.Enabled = false
Blur.Size = 25

local counter = 0

-- Notification function
function shared:createnotification(text, delay2, title, timer)
    spawn(function()
        local Frame = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local TextLabel = Instance.new("TextLabel")
        local ImageLabel = Instance.new("ImageLabel")
        local UIGradient = Instance.new("UIGradient")
        local TextLabel_2 = Instance.new("TextLabel")

        delay2 = delay2 or 1
        title = title or "Module Toggled"
        timer = timer or 0.5

        -- Store active notifications
        if not shared.ActiveNotifications then
            shared.ActiveNotifications = {}
        end

        Frame.Parent = shared.ScreenGui2
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 0.400
        Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Frame.BorderSizePixel = 0

        if UIS.TouchEnabled then
            Frame.Position = UDim2.new(1.1, 0, 0.8, -(counter * 102))
            Frame.Size = UDim2.new(0, 180, 0, 60)
        else
            Frame.Position = UDim2.new(1.105, 0, 0.8, -(counter * 102))
            Frame.Size = UDim2.new(0, 250, 0, 80)
        end

        UICorner.CornerRadius = UDim.new(0, 15)
        UICorner.Parent = Frame

        TextLabel.Parent = Frame
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1.000
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.BorderSizePixel = 0
        TextLabel.Position = UDim2.new(0.25, 0, 0.0549999997, 0)
        TextLabel.Size = UDim2.new(0.699999988, 0, 0.5, 0)
        TextLabel.Font = Enum.Font.SourceSansSemibold
        TextLabel.Text = title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextScaled = true
        TextLabel.TextSize = 14.000
        TextLabel.TextWrapped = true

        ImageLabel.Parent = Frame
        ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageLabel.BackgroundTransparency = 1.000
        ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageLabel.BorderSizePixel = 0
        ImageLabel.Position = UDim2.new(0.0642201826, 0, 0.294117659, 0)
        ImageLabel.Size = UDim2.new(0.158256873, 0, 0.411764711, 0)
        ImageLabel.Image = "rbxassetid://121722907322255"
        ImageLabel.ImageColor3 = Color3.fromRGB(125, 112, 211)

        UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(38, 10, 36)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(16, 20, 39))}
        UIGradient.Rotation = 90
        UIGradient.Parent = Frame

        TextLabel_2.Parent = Frame
        TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel_2.BackgroundTransparency = 1.000
        TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel_2.BorderSizePixel = 0
        TextLabel_2.Position = UDim2.new(0.25, 0, 0.504999995, 0)
        TextLabel_2.Size = UDim2.new(0.699999928, 0, 0.294117659, 0)
        TextLabel_2.Font = Enum.Font.SourceSans
        TextLabel_2.Text = text
        TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel_2.TextScaled = true
        TextLabel_2.TextSize = 14.000
        TextLabel_2.TextWrapped = true
        TextLabel_2.RichText = true

        -- Add to active notifications
        table.insert(shared.ActiveNotifications, Frame)

        -- Slide In Animation
        pcall(function()
            Frame:TweenPosition((Frame.Position - UDim2.new(0.274324248, 0, 0, 0)), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, timer)
            counter = counter + 1
            task.wait(delay2 + 0.5)
            local index = table.find(shared.ActiveNotifications, Frame)
            if index then
                table.remove(shared.ActiveNotifications, index)
                for i, notification in ipairs(shared.ActiveNotifications) do
                    local newY = 0.8 - (i * 0.102) -- Using 102px spacing as per original counter logic
                    TweenService:Create(notification, TweenInfo.new(timer, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(UIS.TouchEnabled and 1.1 or 1.105, 0, newY, 0)}):Play()
                end
                Frame:TweenPosition((Frame.Position + UDim2.new(0.274324248, 0, 0, 0)), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, timer)
            end
            counter = counter - 1
        end)
        task.wait(timer)
        Frame:Destroy()
    end)
end

-- Blur effect function
local function addblurtoobject(object)
    local Lighting = game:GetService("Lighting")
    local camera = workspace.CurrentCamera

    local BLUR_SIZE = Vector2.new(10, 10)
    local PART_SIZE = 0.0098
    local PART_TRANSPARENCY = 1 - 1e-7
    local START_INTENSITY = 20

    object:SetAttribute("BlurIntensity", START_INTENSITY)

    local BLUR_OBJ = Instance.new("DepthOfFieldEffect")
    BLUR_OBJ.FarIntensity = 0
    BLUR_OBJ.NearIntensity = object:GetAttribute("BlurIntensity")
    BLUR_OBJ.FocusDistance = 0.25
    BLUR_OBJ.InFocusRadius = 0
    BLUR_OBJ.Parent = Lighting

    local PartsList = {}
    local BlursList = {}
    local BlurObjects = {}
    local BlurredGui = {}

    BlurredGui.__index = BlurredGui

    function rayPlaneIntersect(planePos, planeNormal, rayOrigin, rayDirection)
        local n = planeNormal
        local d = rayDirection
        local v = rayOrigin - planePos

        local num = n.x * v.x + n.y * v.y + n.z * v.z
        local den = n.x * d.x + n.y * d.y + n.z * d.z
        local a = -num / den

        return rayOrigin + a * rayDirection, a
    end

    function rebuildPartsList()
        PartsList = {}
        BlursList = {}
        for blurObj, part in pairs(BlurObjects) do
            table.insert(PartsList, part)
            table.insert(BlursList, blurObj)
        end
    end

    function BlurredGui.new(frame, shape)
        local blurPart = Instance.new("Part")
        blurPart.Size = Vector3.new(1, 1, 1) * 0.01
        blurPart.Anchored = true
        blurPart.CanCollide = false
        blurPart.CanTouch = false
        blurPart.Material = Enum.Material.Glass
        blurPart.Transparency = PART_TRANSPARENCY
        blurPart.Parent = workspace.CurrentCamera

        local mesh
        if shape == "Rectangle" then
            mesh = Instance.new("BlockMesh")
            mesh.Parent = blurPart
        elseif shape == "Oval" then
            mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.Sphere
            mesh.Parent = blurPart
        end

        local ignoreInset = false
        local currentObj = frame

        while true do
            currentObj = currentObj.Parent

            if currentObj and currentObj:IsA("ScreenGui") then
                ignoreInset = currentObj.IgnoreGuiInset
                break
            elseif currentObj == nil then
                break
            end
        end

        local new = setmetatable({
            Frame = frame,
            Part = blurPart,
            Mesh = mesh,
            IgnoreGuiInset = ignoreInset,
        }, BlurredGui)

        BlurObjects[new] = blurPart
        rebuildPartsList()

        game:GetService("RunService"):BindToRenderStep("...", Enum.RenderPriority.Camera.Value + 1, function()
            blurPart.CFrame = camera.CFrame * CFrame.new(0, 0, 0)
            BlurredGui.updateAll()
        end)
        return new
    end

    function updateGui(blurObj)
        if not blurObj.Frame.Visible then
            blurObj.Part.Transparency = 1
            return
        end

        local camera = workspace.CurrentCamera
        local frame = blurObj.Frame
        local part = blurObj.Part
        local mesh = blurObj.Mesh

        part.Transparency = PART_TRANSPARENCY

        local corner0 = frame.AbsolutePosition + BLUR_SIZE
        local corner1 = corner0 + frame.AbsoluteSize - BLUR_SIZE * 2
        local ray0, ray1

        if blurObj.IgnoreGuiInset then
            ray0 = camera:ViewportPointToRay(corner0.X, corner0.Y, 1)
            ray1 = camera:ViewportPointToRay(corner1.X, corner1.Y, 1)
        else
            ray0 = camera:ScreenPointToRay(corner0.X, corner0.Y, 1)
            ray1 = camera:ScreenPointToRay(corner1.X, corner1.Y, 1)
        end

        local planeOrigin = camera.CFrame.Position + camera.CFrame.LookVector * (0.05 - camera.NearPlaneZ)
        local planeNormal = camera.CFrame.LookVector
        local pos0 = rayPlaneIntersect(planeOrigin, planeNormal, ray0.Origin, ray0.Direction)
        local pos1 = rayPlaneIntersect(planeOrigin, planeNormal, ray1.Origin, ray1.Direction)

        local pos0 = camera.CFrame:PointToObjectSpace(pos0)
        local pos1 = camera.CFrame:PointToObjectSpace(pos1)

        local size = pos1 - pos0
        local center = (pos0 + pos1) / 2

        mesh.Offset = center
        mesh.Scale = size / PART_SIZE
    end

    function BlurredGui.updateAll()
        pcall(function(...)
            BLUR_OBJ.NearIntensity = tonumber(object:GetAttribute("BlurIntensity"))

            for i = 1, #BlursList do
                updateGui(BlursList[i])
            end

            local cframes = table.create(#BlursList, workspace.CurrentCamera.CFrame)
            workspace:BulkMoveTo(PartsList, cframes, Enum.BulkMoveMode.FireCFrameChanged)

            BLUR_OBJ.FocusDistance = 0.25 - camera.NearPlaneZ
        end)
    end

    BlurredGui.new(object, "Rectangle")
end

-- Target HUD setup
spawn(function()
    shared.TargetHud = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    shared.TargetName = Instance.new("TextLabel")
    shared.TargetColor = Instance.new("TextLabel")
    shared.TargetHealth = Instance.new("TextLabel")
    shared.TargetState = Instance.new("TextLabel")
    local SliderMain = Instance.new("Frame")
    local UICorner_2 = Instance.new("UICorner")
    shared.SliderInner = Instance.new("Frame")
    local UICorner_3 = Instance.new("UICorner")
    local UIGradient = Instance.new("UIGradient")
    local UIGradient2 = Instance.new("UIGradient")
    shared.SliderInner2 = Instance.new("Frame")
    local UIGradient23 = Instance.new("UIGradient")
    local UICorner_32 = Instance.new("UICorner")
    local textsize = 27

    shared.TargetHud.Name = "TargetHud"
    shared.TargetHud.Parent = shared.ScreenGui2
    shared.TargetHud.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shared.TargetHud.BackgroundTransparency = 0.98
    shared.TargetHud.BorderColor3 = Color3.fromRGB(0, 0, 0)
    shared.TargetHud.BorderSizePixel = 0
    shared.TargetHud.Position = UDim2.new(0.425, 0, 0.65, 0)
    shared.TargetHud.Size = UDim2.new(0, 220, 0, 80)
    shared.TargetHud.Visible = false

    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = shared.TargetHud

    UIGradient.Name = "TargetHudGradient"
    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 139, 174)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 212, 225)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
    UIGradient.Parent = UIStroke

    shared.TargetName.Name = "TargetName"
    shared.TargetName.Parent = shared.TargetHud
    shared.TargetName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shared.TargetName.BackgroundTransparency = 1.000
    shared.TargetName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    shared.TargetName.BorderSizePixel = 0
    shared.TargetName.Position = UDim2.new(0.165, 0, 0.0799998939, 0)
    shared.TargetName.Size = UDim2.new(0.432998955, 0, 0.449999988, 0)
    shared.TargetName.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
    shared.TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
    shared.TargetName.TextSize = textsize
    shared.TargetName.TextWrapped = true
    shared.TargetName.TextXAlignment = Enum.TextXAlignment.Left

    shared.TargetColor.Name = "TargetColor"
    shared.TargetColor.Parent = shared.TargetHud
    shared.TargetColor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shared.TargetColor.BackgroundTransparency = 1.000
    shared.TargetColor.BorderColor3 = Color3.fromRGB(255, 255, 255)
    shared.TargetColor.BorderSizePixel = 0
    shared.TargetColor.Position = UDim2.new(0.0432427935, 0, 0.0800000802, 0)
    shared.TargetColor.Size = UDim2.new(0.083, 0, 0.449999988, 0)
    shared.TargetColor.FontFace = Font.new(getcustomasset("RavenB4/MCBold.json"))
    shared.TargetColor.Text = "W"
    shared.TargetColor.TextColor3 = Color3.fromRGB(255, 255, 255)
    shared.TargetColor.TextSize = textsize

    shared.TargetHealth.TextWrapped = true
    shared.TargetHealth.Name = "TargetHealth"
    shared.TargetHealth.Parent = shared.TargetHud
    shared.TargetHealth.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shared.TargetHealth.BackgroundTransparency = 1.000
    shared.TargetHealth.BorderColor3 = Color3.fromRGB(0, 0, 0)
    shared.TargetHealth.BorderSizePixel = 0
    shared.TargetHealth.Position = UDim2.new(0.660000026, 0, 0.0799999982, 0)
    shared.TargetHealth.Size = UDim2.new(0.193000004, 0, 0.449999988, 0)
    shared.TargetHealth.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
    shared.TargetHealth.Text = "100"
    shared.TargetHealth.TextColor3 = Color3.fromRGB(77, 255, 1)
    shared.TargetHealth.TextSize = textsize
    shared.TargetHealth.TextWrapped = true

    shared.TargetState.Name = "TargetState"
    shared.TargetState.Parent = shared.TargetHud
    shared.TargetState.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shared.TargetState.BackgroundTransparency = 1.000
    shared.TargetState.BorderColor3 = Color3.fromRGB(0, 0, 0)
    shared.TargetState.BorderSizePixel = 0
    shared.TargetState.Position = UDim2.new(0.839999974, 0, 0.0799999982, 0)
    shared.TargetState.Size = UDim2.new(0.118000001, 0, 0.449999988, 0)
    shared.TargetState.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
    shared.TargetState.Text = "W"
    shared.TargetState.TextColor3 = Color3.fromRGB(34, 255, 0)
    shared.TargetState.TextSize = textsize
    shared.TargetState.TextWrapped = true

    SliderMain.Name = "SliderMain"
    SliderMain.Parent = shared.TargetHud
    SliderMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderMain.BackgroundTransparency = 0.700
    SliderMain.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderMain.BorderSizePixel = 0
    SliderMain.Position = UDim2.new(0.0500000007, 0, 0.649999976, 0)
    SliderMain.Size = UDim2.new(0.899999976, 0, 0, 12)

    UICorner_2.CornerRadius = UDim.new(0, 4)
    UICorner_2.Parent = SliderMain

    shared.SliderInner.Name = "SliderInner"
    shared.SliderInner.Parent = SliderMain
    shared.SliderInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shared.SliderInner.BorderColor3 = Color3.fromRGB(0, 0, 0)
    shared.SliderInner.BorderSizePixel = 0
    shared.SliderInner.BackgroundTransparency = 0.5
    shared.SliderInner.Size = UDim2.new(1, 0, 1, 0)

    UICorner_3.CornerRadius = UDim.new(0, 4)
    UICorner_3.Parent = shared.SliderInner

    UIGradient2.Name = "SliderGradient"
    UIGradient2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 139, 174)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 212, 225)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
    UIGradient2.Parent = shared.SliderInner

    shared.SliderInner2.Name = "SliderInner"
    shared.SliderInner2.Parent = SliderMain
    shared.SliderInner2.BackgroundColor3 = Color3.fromRGB(254, 192, 210)
    shared.SliderInner2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    shared.SliderInner2.BorderSizePixel = 0
    shared.SliderInner2.BackgroundTransparency = 0
    shared.SliderInner2.Size = UDim2.new(1, 0, 1, 0)

    UICorner_32.CornerRadius = UDim.new(0, 4)
    UICorner_32.Parent = shared.SliderInner2

    UIGradient23.Name = "SliderGradient"
    UIGradient23.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 139, 174)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 212, 225)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
    UIGradient23.Parent = shared.SliderInner2

    addblurtoobject(shared.TargetHud)
end)

function lib:CreateWindow(text, Position)
    local TopFrame = Instance.new("Frame")
    local TabName = Instance.new("TextLabel")
    local TabTextPadding = Instance.new("UIPadding")
    local PlusMinusButton = Instance.new("TextButton")
    local TFCorner = Instance.new("UICorner")
    local TFStroke = Instance.new("UIStroke")
    local TFStrokeGrad = Instance.new("UIGradient")
    local HolderFrame = Instance.new("Frame")
    local HolderUIList = Instance.new("UIListLayout")
    local UICorner_10 = Instance.new("UICorner")
    local UIGradient_10 = Instance.new("UIGradient")
    
    local Toggles = {}

    ScreenGui.Name = "ScreenGui"
    ScreenGui.Parent = game:WaitForChild("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    TopFrame.Name = "TopFrame"
    TopFrame.Parent = ScreenGUIFrame
    TopFrame.AutomaticSize = "Y"
    TopFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TopFrame.BackgroundTransparency = 0.500
    TopFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TopFrame.BorderSizePixel = 0
    TopFrame.Position = Position
    TopFrame.Size = UDim2.new(0, sizingtable.MainFrame, 0, sizingtable.MainTabFrame)

    TabName.Name = "TabName"
    TabName.Parent = TopFrame
    TabName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabName.BackgroundTransparency = 1.000
    TabName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabName.BorderSizePixel = 0
    TabName.Size = UDim2.new(1, 0,0, sizingtable.TabFrame)
    TabName.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
    TabName.Text = text
    TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabName.TextSize = sizingtable.TabText
    TabName.TextXAlignment = Enum.TextXAlignment.Left

    TabTextPadding.Name = "TabTextPadding"
    TabTextPadding.Parent = TabName
    TabTextPadding.PaddingLeft = UDim.new(0, 10)
    TabTextPadding.PaddingTop = UDim.new(0, 10)

    PlusMinusButton.Name = "PlusMinusButton"
    PlusMinusButton.Parent = TabName
    PlusMinusButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlusMinusButton.BackgroundTransparency = 1.000
    PlusMinusButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlusMinusButton.BorderSizePixel = 0
    PlusMinusButton.Position = UDim2.new(0.799999988, 0, 0, -9)
    PlusMinusButton.Size = UDim2.new(0, sizingtable.PlusMinuesButtonSize, 0, sizingtable.PlusMinuesButtonSizeSecond)
    PlusMinusButton.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
    PlusMinusButton.Text = "-"
    PlusMinusButton.TextColor3 = Color3.fromRGB(235, 39, 39)
    PlusMinusButton.TextSize = sizingtable.PlusMinuesButtonText
    PlusMinusButton.TextWrapped = true

    TFCorner.Name = "TFCorner"
    TFCorner.Parent = TopFrame

    TFStroke.Name = "TFStroke"
    TFStroke.Parent = TopFrame
    TFStroke.Thickness = 2
    TFStroke.Color = Color3.new(255,255,255)

    TFStrokeGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(142, 132, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(160, 193, 255))}
    TFStrokeGrad.Parent = TFStroke

    HolderFrame.Name = "HolderFrame"
    HolderFrame.Parent = TopFrame
    HolderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HolderFrame.BackgroundTransparency = 1.000
    HolderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    HolderFrame.BorderSizePixel = 0
    HolderFrame.Position = UDim2.new(0, 0, 0, sizingtable.HolderFramePadding)
    HolderFrame.Size = UDim2.new(1, 0, 0, 0)
    HolderFrame.AutomaticSize = "Y"

    HolderUIList.Name = "HolderUIList"
    HolderUIList.Parent = HolderFrame
    HolderUIList.SortOrder = Enum.SortOrder.LayoutOrder

    ScreenGui.Enabled = false

    PlusMinusButton.MouseButton1Click:Connect(function ()
        if PlusMinusButton.Text == "+" then
            PlusMinusButton.Text = "-"
            PlusMinusButton.TextColor3 = Color3.fromRGB(235, 39, 39)
            HolderFrame.Visible = true
        else
            PlusMinusButton.Text = "+"
            PlusMinusButton.TextColor3 = Color3.fromRGB(153, 255, 168)
            HolderFrame.Visible = false
        end
    end)

    --Credits to a guy that the name I forgot (Made a client back then named "LachsHub" with him where he came up with this clever GUI Drag script)

    local frame = TopFrame
    local dragToggle = nil
    local dragSpeed = 0.5
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
    end

    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)

    function Toggles:ravenb4(defaults, options)
        defaults = defaults or {}
        options = options or {}
        for option, value in next, options do
            defaults[option] = value
        end
        return defaults
    end

    function Toggles:CreateToggle(options)
        options = self:ravenb4({
            Name = "Toggle",
            Keybind = nil,
            Animation = true,
            Untoggle = false,
            StartingState = false,
            Callback = function() end
        }, options)
        local function OptionsName()
            return options.Name
        end
        if GUILoadSettings[options.Name] ~= nil then
            if GUILoadSettings[options.Name].Value ~= nil then
                options.StartingState = GUILoadSettings[options.Name].Value
            end
            if GUILoadSettings[options.Name].Keybind ~= nil then
                options.Keybind = Enum.KeyCode[GUILoadSettings[options.Name].Keybind]
            end
        end
        GUISaveSettings[options.Name] = {}
        GUISaveSettings[options.Name]["Value"] = options.StartingState
        GUISaveSettings[options.Name]["Keybind"] = options.Keybind ~= nil and options.Keybind.Name or options.Keybind

        local Toggle = {}
        Toggle.Connections = {} -- Store event connections
        table.insert(allToggles, Toggle)
        local toggled = options.StartingState
        local MainButton = Instance.new("TextButton")
        local MiniHolderFrame = Instance.new("Frame")
        local MiniHolderUIList = Instance.new("UIListLayout")
        local Bind = Instance.new("Frame")
        local BindText = Instance.new("TextLabel")
        local BindTextPad = Instance.new("UIPadding")
        local TextButton = Instance.new("TextButton")
        local MainButtonCorner = Instance.new("UICorner")

        do

        MainButton.Name = "MainButton"
        MainButton.Parent = HolderFrame
        MainButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
        MainButton.BackgroundTransparency = 1.000
        MainButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        MainButton.BorderSizePixel = 0
        MainButton.Size = UDim2.new(1, 0, 0, sizingtable.MainButton)
        MainButton.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
        MainButton.Text = options.Name
        MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MainButton.TextSize = sizingtable.MainButtonText

        MainButtonCorner.CornerRadius = UDim.new(0, 12)
        MainButtonCorner.Name = "TFCorner"
        MainButtonCorner.Parent = MainButton

        MiniHolderFrame.Name = "MiniHolderFrame"
        MiniHolderFrame.Parent = HolderFrame
        MiniHolderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MiniHolderFrame.BackgroundTransparency = 1.000
        MiniHolderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        MiniHolderFrame.BorderSizePixel = 0
        MiniHolderFrame.Size = UDim2.new(1, 0, 0, 0)
        MiniHolderFrame.AutomaticSize = "Y"
        MiniHolderFrame.Visible = false

        MiniHolderUIList.Name = "MiniHolderUIList"
        MiniHolderUIList.Parent = MiniHolderFrame
        MiniHolderUIList.SortOrder = Enum.SortOrder.LayoutOrder

        Bind.Name = "Bind"
        Bind.Parent = HolderFrame
        Bind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Bind.BackgroundTransparency = 1.000
        Bind.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Bind.BorderSizePixel = 0
        Bind.Size = UDim2.new(1, 0, 0,sizingtable.BindSize)
        Bind.Visible = false

        BindText.Name = "BindText"
        BindText.Parent = Bind
        BindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BindText.BackgroundTransparency = 1.000
        BindText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        BindText.BorderSizePixel = 0
        BindText.Size = UDim2.new(1, 0, 1,0)
        BindText.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
        BindText.Text = "Current bind:"
        BindText.TextColor3 = Color3.fromRGB(10, 213, 236)
        BindText.TextSize = sizingtable.BindText
        BindText.TextXAlignment = Enum.TextXAlignment.Left

        BindTextPad.Name = "BindTextPad"
        BindTextPad.Parent = BindText
        BindTextPad.PaddingLeft = UDim.new(0, 15)

        TextButton.Parent = Bind
        TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextButton.BackgroundTransparency = 1.000
        TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextButton.BorderSizePixel = 0
        TextButton.Position = UDim2.new(sizingtable.BindButtonPOS, 0, 0, 0)
        TextButton.Size = UDim2.new(sizingtable.BindButtonSize, 0, 1,0)
        TextButton.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
        TextButton.Text = "\'NONE\'"
        TextButton.TextColor3 = Color3.fromRGB(255, 248, 34)
        TextButton.TextSize = sizingtable.BindText
        TextButton.TextXAlignment = Enum.TextXAlignment.Left
            RavenArraylist = {
            Add = function(Name)
                local TextLabel = Instance.new("TextLabel",Array)
                local TextLabel2 = Instance.new("TextLabel",TextLabel)

                TextLabel.Name = Name
                TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextLabel.BorderSizePixel = 0
                TextLabel.Position = UDim2.new(1, 0, 0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
                TextLabel.TextSize = 21
                TextLabel.Text = Name.." "
                TextLabel.TextColor3 = Color3.new(255,255,255)
                TextLabel.Size = UDim2.new(0,0,0,0)
                local params = Instance.new("GetTextBoundsParams")
                params.Text = Name.." "
                params.Font = Font.new(getcustomasset("RavenB4/MCReg.json"))
                params.Size = 25
                local size = game:GetService("TextService"):GetTextBoundsAsync(params)
                TextLabel.TextXAlignment = "Right"
                TextLabel.LayoutOrder = -size.X
                TextLabel.RichText = true

                TextLabel2.Name = Name .."2"
                TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextLabel2.BorderSizePixel = 0
                TextLabel2.Position = UDim2.new(0, 0, 0, 0)
                TextLabel2.BackgroundTransparency = 1
                TextLabel2.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
                TextLabel2.TextSize = 21
                TextLabel2.Text = Name.." "
                TextLabel2.TextColor3 = Color3.new(255,255,255)
                TextLabel2.Size = UDim2.new(1,0,1,0)
                TextLabel2.TextXAlignment = "Right"
                TextLabel2.TextTransparency = 1
                TextLabel2.RichText = true
                spawn(function ()
                    animate(TextLabel)
                end)
            end,
            Remove = function(Name)
                if Array:FindFirstChild(Name) then
                    Array:FindFirstChild(Name):Destroy()
                end
            end,
        }
            local function toggle()
                toggled = not toggled
                if toggled then
                    MainButton.TextColor3 = Color3.fromRGB(44, 128, 255)
                    RavenArraylist.Remove(options.Name)
                    RavenArraylist.Add(options.Name)
                    if ModuleNotification and options.Animation ~= false then
                        shared:createnotification(tostring(options.Name .. ' has been <font color="#00ff00">enabled</font>'), 0.5, "Module Toggled", 0.2)
                    end
                else
                    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    RavenArraylist.Remove(options.Name)
                    if ModuleNotification and options.Animation ~= false then
                        if options.Untoggle ~= true then
                            shared:createnotification(tostring(options.Name .. ' has been <font color="#ff0000">disabled</font>'), 0.5, "Module Toggled", 0.2)
                        end
                    end
                end
                if GUISaveSettings[options.Name] ~= nil then
                    GUISaveSettings[options.Name].Value = toggled
                else
                    print("Toggle Save doesn't seem to function!")
                end
                saveSettings() -- Save settings on toggle change
                options.Callback(toggled)
            end

            Toggle.Connections[#Toggle.Connections + 1] = MainButton.MouseButton1Click:Connect(function()
                toggle()
                if options.Untoggle == true then
                    toggle()
                end
            end)
            Toggle.Connections[#Toggle.Connections + 1] = MainButton.MouseButton2Click:Connect(function()
                MiniHolderFrame.Visible = not MiniHolderFrame.Visible
                Bind.Visible = not Bind.Visible
            end)
            Toggle.Connections[#Toggle.Connections + 1] = MainButton.MouseEnter:Connect(function()
                MainButton.BackgroundTransparency = 0.7
            end)
            Toggle.Connections[#Toggle.Connections + 1] = MainButton.MouseLeave:Connect(function()
                MainButton.BackgroundTransparency = 1
            end)

            function Toggle:SetState(state)
                toggled = state
                if toggled then
                    MainButton.TextColor3 = Color3.fromRGB(44, 128, 255)
                    RavenArraylist.Add(options.Name)
                    if ModuleNotification and options.Animation ~= false then
                        shared:createnotification(tostring(options.Name .. ' has been <font color="#00ff00">enabled</font>'), 0.5, "Module Toggled", 0.2)
                    end
                else
                    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    RavenArraylist.Remove(options.Name)
                    if ModuleNotification and options.Animation ~= false and options.Untoggle ~= true then
                        shared:createnotification(tostring(options.Name .. ' has been <font color="#ff0000">disabled</font>'), 0.5, "Module Toggled", 0.2)
                    end
                end
                GUISaveSettings[options.Name].Value = toggled
                task.spawn(function() options.Callback(toggled) end)
            end

            if options.StartingState then Toggle:SetState(true) end
            local listening = false
            Toggle.Connections[#Toggle.Connections + 1] = UIS.InputBegan:Connect(function(key)
                --if not shared.Injected then return end -- Prevent keybinds post-uninjection
                if listening and not UIS:GetFocusedTextBox() then
                    if key.UserInputType == Enum.UserInputType.Keyboard then
                        if key.KeyCode ~= Enum.KeyCode.Escape then
                            if key.KeyCode ~= Enum.KeyCode.Backspace then
                                options.Keybind = key.KeyCode
                            else
                                options.Keybind = nil
                            end
                            GUISaveSettings[options.Name].Keybind = options.Keybind ~= nil and options.Keybind.Name or nil
                            saveSettings()
                        end
                        TextButton.Text = options.Keybind and tostring("\'"..tostring(options.Keybind.Name):upper().."\'") or "\'NONE\'"
                        BindText.Text = "Current bind:"
                        listening = false
                    end
                else
                    if key.KeyCode == options.Keybind and not UIS:GetFocusedTextBox() then
                        toggle()
                        if options.Untoggle == true then
                            toggle()
                        end
                    end
                end
            end)

            Toggle.Connections[#Toggle.Connections + 1] = TextButton.MouseButton1Click:Connect(function()
                if not listening then
                    listening = true
                    BindText.Text = "Press a key..."
                    TextButton.Text = ""
                end
            end)
        end

        function Toggle:Set(keycode)
            TextButton.Text = keycode and tostring("\'"..tostring(keycode.Name):upper().."\'") or "\'NONE\'"
        end
        if options.Keybind ~= nil then
            Toggle:Set(options.Keybind)
        end
        function Toggle:ravenb4(defaults, options)
            defaults = defaults or {}
            options = options or {}
            for option, value in next, options do
                defaults[option] = value
            end
            return defaults
        end
        function Toggle:CreateDropDown(options)
            options = self:ravenb4({
                Name = "DropDown",
                Title = "",
                DefaultOption = "",
                Options = {},
                SecondArrayitem = false,
                Callback = function() end
            }, options)

            if table.find(options.Options,options.DefaultOption) == nil then
                options.DefaultOption = ""
            end
            if GUILoadSettings[OptionsName()] ~= nil then
                if GUILoadSettings[OptionsName()][options.Name] ~= nil then
                    options.DefaultOption = GUILoadSettings[OptionsName()][options.Name].Value
                end
            end

            GUISaveSettings[OptionsName()][options.Name] = {}
            GUISaveSettings[OptionsName()][options.Name]["Value"] = options.DefaultOption

            local DefaultOptionPOS
            local Listsize = #(options.Options)
            if options.DefaultOption ~= "" then
                for i,v in pairs(options.Options) do
                    if v == options.DefaultOption then
                        DefaultOptionPOS = i
                    end
                end
            else
                DefaultOptionPOS = 1
                options.DefaultOption = options.Options[DefaultOptionPOS]
            end

            local TextButton = Instance.new("TextButton")
            local UIPadding = Instance.new("UIPadding")
            local breaking = false
            TextButton.Parent = MiniHolderFrame
            TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextButton.BackgroundTransparency = 1.000
            TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextButton.BorderSizePixel = 0
            TextButton.Size = UDim2.new(1, 0, 0, 25)
            TextButton.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
            TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextButton.TextSize = 14.000
            TextButton.TextXAlignment = Enum.TextXAlignment.Left
            TextButton.Text = options.Name .. ": " .. options.DefaultOption
            
            UIPadding.Parent = TextButton
            UIPadding.PaddingLeft = UDim.new(0, 15)

            TextButton.MouseButton1Click:Connect(function ()
                pcall(function (...)
                    breaking = true
                    if DefaultOptionPOS < Listsize then
                        DefaultOptionPOS = DefaultOptionPOS + 1
                    else
                        DefaultOptionPOS = 1
                    end
                    options.DefaultOption = options.Options[DefaultOptionPOS]
                    GUISaveSettings[OptionsName()][options.Name]["Value"] = options.DefaultOption
                    options.Callback(options.DefaultOption)
                    saveSettings()
                    TextButton.Text = options.Name .. ": " .. options.DefaultOption
                    breaking = false
                    --[[spawn(function ()
                        repeat task.wait(0.1)
                            if breaking == true then return end
                            local item = Array:FindFirstChild(OptionsName())
                            if item ~= nil and options.SecondArrayitem == true then
                                item.Text = OptionsName() .. ' <font transparency="1">' .. options.DefaultOption .. "</font> "
                            end
                        until breaking
                    end)]]
                end)
            end)
            TextButton.MouseEnter:Connect(function ()
                TextButton.TextColor3 = Color3.fromRGB(207,207,207)
            end)
            TextButton.MouseLeave:Connect(function ()
                TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
            function FindFirstDescendant(obj, child)
                for _, objs in pairs(obj:GetDescendants()) do
                    if objs.Name == child then
                        return objs
                    end
                end
            end


            options.Callback(options.Options[DefaultOptionPOS])
            if options.SecondArrayitem == true then
                breaking = true
                task.wait(0.2)
                breaking = false
                local params = Instance.new("GetTextBoundsParams")
                spawn(function ()
                    repeat task.wait(0.1)
                        if breaking == true then return end
                        local item = Array:FindFirstChild(OptionsName())
                        local item2 = FindFirstDescendant(Array,OptionsName().."2")
                        local newitemname = options.DefaultOption .. " "
                        if item ~= nil and options.SecondArrayitem == true then
                            params.Font = Font.new(getcustomasset("RavenB4/MCReg.json"))
                            params.Size = 18
                            params.Text = OptionsName().." "
                            local size = game:GetService("TextService"):GetTextBoundsAsync(params)
                            params.Text = newitemname
                            local size2 = game:GetService("TextService"):GetTextBoundsAsync(params)
                            item.LayoutOrder = (-size.X -size2.X -50)
                            item.Text = OptionsName() .. '<font transparency="1"> ' .. newitemname .. '</font>'
                            item2.Text = '<font transparency="1">' .. OptionsName() .. '</font>'..'<font color="#bbbbbb"> ' .. newitemname.. '</font>'
                            --item2.Text = '<font transparency="1">' .. OptionsName() .. '</font>'..'<stroke color="#000000" joins="miter" thickness="0.5" transparency="0.25">'.. '<font color="#bbbbbb"> ' .. options.DefaultOption .. '</font>' ..'</stroke>'
                            item2.TextTransparency = 0
                        end
                    until breaking
                end)
            end
        end -- Original Raven B4 doesn't have this, will see what I'll do with this!

        function Toggle:CreateInfo(text)
            local Info = Instance.new("TextLabel")
            local InfoPad = Instance.new("UIPadding")

            Info.Name = "Info"
            Info.Parent = MiniHolderFrame
            Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Info.BackgroundTransparency = 1.000
            Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Info.BorderSizePixel = 0
            Info.Size = UDim2.new(1, 0, 0, sizingtable.InfoSize)
            Info.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
            Info.Text = text
            Info.TextColor3 = Color3.fromRGB(0, 174, 255)
            Info.TextSize = sizingtable.InfoText
            Info.TextWrapped = true
            Info.TextXAlignment = Enum.TextXAlignment.Left

            InfoPad.Name = "InfoPad"
            InfoPad.Parent = Info
            InfoPad.PaddingLeft = UDim.new(0, 15)
        end
        function Toggle:CreateSlider(options)
            options = self:ravenb4({
                Name = "Slider",
                Default = 0,
                Min = 0,
                Max = 100,
                Callback = function() end
            }, options)

            if GUILoadSettings[OptionsName()] ~= nil then
                if GUILoadSettings[OptionsName()][options.Name] ~= nil then
                    options.Default = GUILoadSettings[OptionsName()][options.Name]
                end
            end

            GUISaveSettings[OptionsName()][options.Name] = options.Default

            --[[if options.Default == true or options.Default == false then
                options.Default = 15
            end]]
            
            local Slider = Instance.new("Frame")
            local SliderButton = Instance.new("TextButton")
            local SliderInner = Instance.new("Frame")
            local SliderName = Instance.new("TextLabel")
            local SliderNamePad = Instance.new("UIPadding")
            local SliderValue = Instance.new("TextLabel")
            local SliderValuePad = Instance.new("UIPadding")
            local SliderInnerCorner = Instance.new("UICorner")
            local SliderButtonCorner = Instance.new("UICorner")

            local Precent
            local Mouse = game.Players.LocalPlayer:GetMouse()
            local Parent = Slider
		    local down = false
            local raven = {}

            Slider.Name = "Slider"
            Slider.Parent = MiniHolderFrame
            Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Slider.BackgroundTransparency = 1.000
            Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Slider.BorderSizePixel = 0
            Slider.Size = UDim2.new(1, 0, 0, sizingtable.MainSlider)
            
            SliderButton.Name = "SliderButton"
            SliderButton.Parent = Slider
            SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderButton.BackgroundTransparency = 0.500
            SliderButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SliderButton.BorderSizePixel = 0
            SliderButton.Position = UDim2.new(0.0500000007, 0, 0.600000024, 0)
            SliderButton.Size = UDim2.new(0.899999976, 0, 0.300000003, 0)
            SliderButton.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
            SliderButton.Text = ""
            SliderButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            SliderButton.TextSize = sizingtable.SliderText

            SliderButtonCorner.Name = "TFCorner2"
            SliderButtonCorner.Parent = SliderButton
            
            SliderInner.Name = "SliderInner"
            SliderInner.Parent = SliderButton
            SliderInner.BackgroundColor3 = Color3.fromRGB(10, 213, 236)
            SliderInner.BackgroundTransparency = 0.100
            SliderInner.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SliderInner.BorderSizePixel = 0
            SliderInner.Size = UDim2.fromScale(((options.Default - options.Min) / (options.Max - options.Min)), 1)
            
            SliderInnerCorner.Name = "TFCorner"
            SliderInnerCorner.Parent = SliderInner

            SliderName.Name = "SliderName"
            SliderName.Parent = Slider
            SliderName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderName.BackgroundTransparency = 1.000
            SliderName.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SliderName.BorderSizePixel = 0
            SliderName.Size = UDim2.new(0.486000001, 0, 0, 15)
            SliderName.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
            SliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderName.TextSize = sizingtable.SliderValueText
            SliderName.TextWrapped = true
            SliderName.TextXAlignment = Enum.TextXAlignment.Left
            SliderName.Text = options.Name .. ": " .. options.Default
            
            SliderNamePad.Name = "SliderNamePad"
            SliderNamePad.Parent = SliderName
            SliderNamePad.PaddingLeft = UDim.new(0, 15)
            
            SliderValue.Name = "SliderValue"
            SliderValue.Parent = Slider
            SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderValue.BackgroundTransparency = 1.000
            SliderValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SliderValue.BorderSizePixel = 0
            SliderValue.Position = UDim2.new(0.571428537, 0, 0, 0)
            SliderValue.Size = UDim2.new(0.42900002, 0, 0, 15)
            SliderValue.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
            SliderValue.Text = options.Default
            SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderValue.TextSize = sizingtable.SliderValueText
            SliderValue.TextWrapped = true
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.TextYAlignment = Enum.TextYAlignment.Top
            SliderValue.Visible = false

            SliderValuePad.Name = "SliderValuePad"
            SliderValuePad.Parent = SliderValue
            SliderValuePad.PaddingRight = UDim.new(0, 15)

            function raven:SetValue(v)
                if v == nil then
                    task.wait()
                    Precent = math.clamp((Mouse.X-Parent.AbsolutePosition.X)/Parent.AbsoluteSize.X,0,1) -- this should work, try and see lol
                    local value = math.floor(((options.Max - options.Min) * Precent) + options.Min)
                    SliderName.Text = options.Name .. ": " .. tostring(value)
                    SliderValue.Text = tostring(value)
                    SliderInner.Size = UDim2.fromScale(Precent,1)
                else
                    SliderValue.Text = tostring(v)
                    SliderName.Text = options.Name .. ": " .. tostring(v)
                    SliderInner.Size = UDim2.fromScale(((options.Default - options.Min) / (options.Max - options.Min)), 1)
                end
                options.Callback(raven:GetValue())
                saveSettings()
                if raven:GetValue() ~= nil then
                    GUISaveSettings[OptionsName()][options.Name] = raven:GetValue()
                end
            end
            function raven:GetValue()
                return tonumber(SliderValue.Text)
            end

            SliderButton.MouseButton1Down:connect(function ()
                down = true
                while RunService.RenderStepped:wait() and down do
                    raven:SetValue()
                end
            end)

            UIS.InputEnded:connect(function(key)
                if key.UserInputType == Enum.UserInputType.MouseButton1 then
                    down = false
                end
            end)

            options.Callback(raven:GetValue())
        end
        --[[
        function Toggle:CreateAdaptiveInput(options)
            options = self:ravenb4({
                Name = "Input",
                StartingText = "",
                Callback = function() end
            }, options)

            if GUILoadSettings[OptionsName()] ~= nil then
                if GUILoadSettings[OptionsName()][options.Name] ~= nil then
                    options.StartingText = GUILoadSettings[OptionsName()][options.Name]
                end
            end
            table.insert(GUISaveSettings,{[OptionsName()] = {[options.Name] = options.StartingText}})

            local AdaptiveInput = Instance.new("TextBox")
            local UICornerAdaptive = Instance.new("UICorner")

            AdaptiveInput.Name = "Adaptive Input"
            AdaptiveInput.Parent = ButtonHolder
            AdaptiveInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            AdaptiveInput.BackgroundTransparency = 0.800
            AdaptiveInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
            AdaptiveInput.BorderSizePixel = 0
            AdaptiveInput.Size = UDim2.new(1, 0, 0, 20)
            AdaptiveInput.Font = Enum.Font.SourceSans
            AdaptiveInput.Text = options.StartingText
            AdaptiveInput.TextColor3 = Color3.fromRGB(187, 110, 255)
            AdaptiveInput.TextSize = 14.000
            
            UICornerAdaptive.Name = "UICornerAdaptive"
            UICornerAdaptive.Parent = AdaptiveInput

            AdaptiveInput.FocusLost:Connect(function ()
                options.Callback(AdaptiveInput.Text)
                FixedTable[OptionsName()][options.Name] = tostring(AdaptiveInput.Text)
            end)

            if options.StartingText ~= "" then options.Callback(options.StartingText) end
        end]]

        function Toggle:CreateToggle(options)
            options = self:ravenb4({
                Name = "Toggle",
                SecondArrayitem = false,
                StartingState = false,
                Callback = function() end
            }, options)
            
            if GUILoadSettings[OptionsName()] ~= nil then
                if GUILoadSettings[OptionsName()][options.Name] ~= nil then
                    options.StartingState = GUILoadSettings[OptionsName()][options.Name]
                end
            end

            GUISaveSettings[OptionsName()][options.Name] = options.StartingState

            local MiniButton = Instance.new("TextButton")
            local MiniButtonPad = Instance.new("UIPadding")
            local MiniButtonText = Instance.new("TextLabel")
            local MIniButtonTextPad = Instance.new("UIPadding")
            local toggled = options.StartingState

            
            MiniButton.Name = "MiniButton"
            MiniButton.Parent = MiniHolderFrame
            MiniButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MiniButton.BackgroundTransparency = 1.000
            MiniButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            MiniButton.BorderSizePixel = 0
            MiniButton.Size = UDim2.new(1, 0, 0, sizingtable.Minibutton)
            MiniButton.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
            MiniButton.Text = "[-]"
            MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            MiniButton.TextSize = sizingtable.MinibuttonText
            MiniButton.TextXAlignment = Enum.TextXAlignment.Left

            MiniButtonPad.Parent = MiniButton
            MiniButtonPad.PaddingLeft = UDim.new(0, 15)

            MiniButtonText.Name = "MiniButtonText"
            MiniButtonText.Parent = MiniButton
            MiniButtonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MiniButtonText.BackgroundTransparency = 1.000
            MiniButtonText.BorderColor3 = Color3.fromRGB(255, 255, 255)
            MiniButtonText.BorderSizePixel = 0
            MiniButtonText.Size = UDim2.new(1, 0, 1, 0)
            MiniButtonText.Font = Enum.Font.Fantasy
            MiniButtonText.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
            MiniButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
            MiniButtonText.TextSize = 14.000
            MiniButtonText.TextXAlignment = Enum.TextXAlignment.Left
            MiniButtonText.Text = options.Name

            MIniButtonTextPad.Parent = MiniButtonText
            MIniButtonTextPad.PaddingLeft = UDim.new(0, 27) 

            local function toggle()
                toggled = not toggled
                if toggled then
                    MiniButton.Text = "[+]"
                    MiniButton.TextColor3 = Color3.fromRGB(0, 255, 0)
                    MiniButtonText.TextColor3 = Color3.fromRGB(0, 255, 0)
                else
                    MiniButton.Text = "[-]"
                    MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    MiniButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                options.Callback(toggled)
                if GUISaveSettings[OptionsName()][options.Name] ~= nil then
                    GUISaveSettings[OptionsName()][options.Name] = toggled
                else
                    print("Mini Toggle Save doesn't seem to function!")
                end
            end
            MiniButton.MouseButton1Click:Connect(function ()
                toggle()
            end)
            MiniButton.MouseEnter:Connect(function ()
                if toggled then
                    MiniButton.TextColor3 = Color3.fromRGB(0, 162, 0)
                    MiniButtonText.TextColor3 = Color3.fromRGB(0, 162, 0)
                elseif not toggled then
                    MiniButton.TextColor3 = Color3.fromRGB(162, 162, 162)
                    MiniButtonText.TextColor3 = Color3.fromRGB(162, 162, 162)
                end
            end)
            MiniButton.MouseLeave:Connect(function ()
                if toggled then
                    MiniButton.TextColor3 = Color3.fromRGB(0, 255, 0)
                    MiniButtonText.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif not toggled then
                    MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    MiniButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end)

            function Toggle:SetState(state)
                toggled = state
                if toggled then
                    MiniButton.Text = "[+]"
                    MiniButton.TextColor3 = Color3.fromRGB(0, 255, 0)
                    MiniButtonText.TextColor3 = Color3.fromRGB(0, 255, 0)
                else
                    MiniButton.Text = "[-]"
                    MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    MiniButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                task.spawn(function() options.Callback(toggled) end)
                saveSettings()
            end
    
            if options.StartingState then Toggle:SetState(true) end
        end
        return Toggle
    end
    return Toggles
end
--Raven WaterMark :)
local RavenB4WaterMark = Instance.new("Frame")
local TopRaven = Instance.new("Frame")
local BottomRaven = Instance.new("Frame")
local LeftSideRaven = Instance.new("Frame")
local RightSideRaven = Instance.new("Frame")
local RavenTextB4 = Instance.new("Frame")
local B4Letter = Instance.new("TextLabel")
local RavenText = Instance.new("Frame")
local RLetter = Instance.new("TextLabel")
local ALetter = Instance.new("TextLabel")
local VLetter = Instance.new("TextLabel")
local ELetter = Instance.new("TextLabel")
local NLetter = Instance.new("TextLabel")
local lineswidth = 3
local textsize = 27.5
local textboxsize = 0.15

RavenB4WaterMark.Name = "Raven B4 WaterMark"
RavenB4WaterMark.Parent = ScreenGUIFrame
RavenB4WaterMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RavenB4WaterMark.BackgroundTransparency = 1.000
RavenB4WaterMark.BorderColor3 = Color3.fromRGB(0, 0, 0)
RavenB4WaterMark.BorderSizePixel = 0
RavenB4WaterMark.Position = UDim2.new(0.498525, 0, 0.10, 0)
RavenB4WaterMark.Size = UDim2.new(0.025, 0, 0.2, 0)

TopRaven.Name = "TopRaven"
TopRaven.Parent = RavenB4WaterMark
TopRaven.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopRaven.BorderColor3 = Color3.fromRGB(0, 0, 0)
TopRaven.BorderSizePixel = 0
TopRaven.Size = UDim2.new(0, 0, 0, lineswidth)
TopRaven.Position = UDim2.new(0, 0, 0, 0)

BottomRaven.Name = "BottomRaven"
BottomRaven.Parent = RavenB4WaterMark
BottomRaven.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BottomRaven.BorderColor3 = Color3.fromRGB(0, 0, 0)
BottomRaven.BorderSizePixel = 0
BottomRaven.Position = UDim2.new(0, 0, 1, 0)
BottomRaven.Size = UDim2.new(0, 0, 0, lineswidth)
BottomRaven.Rotation = 180  

LeftSideRaven.Name = "LeftSideRaven"
LeftSideRaven.Parent = RavenB4WaterMark
LeftSideRaven.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LeftSideRaven.BorderColor3 = Color3.fromRGB(0, 0, 0)
LeftSideRaven.BorderSizePixel = 0
LeftSideRaven.Size = UDim2.new(0,lineswidth, 1, 0)
LeftSideRaven.Position = UDim2.new(-1,0,0, 0)

RightSideRaven.Name = "RightSideRaven"
RightSideRaven.Parent = RavenB4WaterMark
RightSideRaven.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RightSideRaven.BorderColor3 = Color3.fromRGB(0, 0, 0)
RightSideRaven.BorderSizePixel = 0
RightSideRaven.Position = UDim2.new(2, 0, 0, 0)
RightSideRaven.Size = UDim2.new(0, lineswidth, 1.015, 0)

RavenTextB4.Name = "RavenTextB4"
RavenTextB4.Parent = RavenB4WaterMark
RavenTextB4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RavenTextB4.BackgroundTransparency = 1.000
RavenTextB4.BorderColor3 = Color3.fromRGB(0, 0, 0)
RavenTextB4.BorderSizePixel = 0
RavenTextB4.Position = UDim2.new(1, 0, textboxsize*5, 0)
RavenTextB4.Size = UDim2.new(1, 0, 0.25, 0)

B4Letter.Name = "B4 Letter"
B4Letter.Parent = RavenTextB4
B4Letter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
B4Letter.BackgroundTransparency = 1.000
B4Letter.BorderColor3 = Color3.fromRGB(0, 0, 0)
B4Letter.BorderSizePixel = 0
B4Letter.Size = UDim2.new(1, 0, 1, 0)
B4Letter.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
B4Letter.Text = "B4"
B4Letter.TextColor3 = Color3.fromRGB(255,255,255)
B4Letter.TextSize = textsize

RavenText.Name = "RavenText"
RavenText.Parent = RavenB4WaterMark
RavenText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RavenText.BackgroundTransparency = 1.000
RavenText.BorderColor3 = Color3.fromRGB(0, 0, 0)
RavenText.BorderSizePixel = 0
RavenText.Size = UDim2.new(1, 0, 1, 1)
RavenText.Position = UDim2.new(-1, 0, 0, 0)

RLetter.Name = "R Letter"
RLetter.Parent = RavenText
RLetter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RLetter.BackgroundTransparency = 1.000
RLetter.BorderColor3 = Color3.fromRGB(0, 0, 0)
RLetter.BorderSizePixel = 0
RLetter.Size = UDim2.new(1, 0,textboxsize , 0)
RLetter.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
RLetter.Text = "r"
RLetter.TextColor3 = Color3.fromRGB(255,255,255)
RLetter.TextSize = textsize

ALetter.Name = "A Letter"
ALetter.Parent = RavenText
ALetter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ALetter.BackgroundTransparency = 1.000
ALetter.BorderColor3 = Color3.fromRGB(0, 0, 0)
ALetter.BorderSizePixel = 0
ALetter.Position = UDim2.new(0, 0, textboxsize, 0)
ALetter.Size = UDim2.new(1, 0, textboxsize, 0)
ALetter.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
ALetter.Text = "a"
ALetter.TextColor3 = Color3.fromRGB(255,255,255)
ALetter.TextSize = textsize

VLetter.Name = "V Letter"
VLetter.Parent = RavenText
VLetter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VLetter.BackgroundTransparency = 1.000
VLetter.BorderColor3 = Color3.fromRGB(0, 0, 0)
VLetter.BorderSizePixel = 0
VLetter.Position = UDim2.new(0, 0, textboxsize*2, 0)
VLetter.Size = UDim2.new(1, 0, textboxsize, 0)
VLetter.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
VLetter.Text = "v"
VLetter.TextColor3 = Color3.fromRGB(255,255,255)
VLetter.TextSize = textsize

ELetter.Name = "E Letter"
ELetter.Parent = RavenText
ELetter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ELetter.BackgroundTransparency = 1.000
ELetter.BorderColor3 = Color3.fromRGB(0, 0, 0)
ELetter.BorderSizePixel = 0
ELetter.Position = UDim2.new(0, 0, textboxsize*3, 0)
ELetter.Size = UDim2.new(1, 0, textboxsize, 0)
ELetter.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
ELetter.Text = "e"
ELetter.TextColor3 = Color3.fromRGB(255,255,255)
ELetter.TextSize = textsize

NLetter.Name = "N Letter"
NLetter.Parent = RavenText
NLetter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
NLetter.BackgroundTransparency = 1.000
NLetter.BorderColor3 = Color3.fromRGB(0, 0, 0)
NLetter.BorderSizePixel = 0
NLetter.Position = UDim2.new(0, 0, textboxsize*4, 0)
NLetter.Size = UDim2.new(1, 0, textboxsize, 0)
NLetter.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json"))
NLetter.Text = "n"
NLetter.TextColor3 = Color3.fromRGB(255,255,255)
NLetter.TextSize = textsize

local function CustomTween(Part,Info,Style,Time,DelayTime)
    TweenService:Create(Part, TweenInfo.new(Time,Style,Enum.EasingDirection.Out,0,false,DelayTime), Info):Play()
end
function RainbowGradient(Parent)
    task.spawn(function ()
        local UIGradient2 = Instance.new("UIGradient")
        UIGradient2.Parent = Parent
        repeat task.wait(0.1)
            UIGradient2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromHSV(tick()%5/5,1,0.6)), ColorSequenceKeypoint.new(1.00, Color3.fromHSV(tick()%5/6,1,0.6))}
        until false
    end)
end
spawn(function ()
    animate(B4Letter,true)
end)spawn(function ()
    animate(RLetter,true)
end)spawn(function ()
    animate(ALetter,true)
end)spawn(function ()
    animate(VLetter,true)
end)spawn(function ()
    animate(ELetter,true)
end)spawn(function ()
    animate(NLetter,true)
end)

function lib:ToggleLib()
    if not ScreenGui.Enabled then
        ScreenGui.Enabled = true
        Frame.Visible = true
        Blur.Enabled = true
        ScreenGUIFrame.Size = UDim2.new(1,0,0,0)
        ScreenGUIFrame.Position = UDim2.new(0,0,1,0)
        ScreenGUIFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.2)
        ScreenGUIFrame:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.2)
        CustomTween(LeftSideRaven,{Position = UDim2.new(0, 0, 0, 0)},Enum.EasingStyle.Bounce,0.5,0)
        CustomTween(RavenText,{Position = UDim2.new(0, 0, 0, 0)},Enum.EasingStyle.Bounce,0.5,0)
        CustomTween(RightSideRaven,{Position = UDim2.new(1, 0, 0, 0)},Enum.EasingStyle.Bounce,0.5,0)
        CustomTween(RavenTextB4,{Position = UDim2.new(0, 0, 0.75, 0)},Enum.EasingStyle.Bounce,0.5,0)
        CustomTween(TopRaven,{Size = UDim2.new(1, 0, 0, lineswidth)},Enum.EasingStyle.Linear,0.25,0.5)
        CustomTween(BottomRaven,{Size = UDim2.new(1.08, 0, 0, lineswidth)},Enum.EasingStyle.Linear,0.25,0.5)
    else
        ScreenGui.Enabled = false
        Frame.Visible = false
        Blur.Enabled = false
        ScreenGUIFrame.Size = UDim2.new(1,0,0,0)
        ScreenGUIFrame.Position = UDim2.new(0,0,1,0)
        TopRaven.Size = UDim2.new(0, 0, 0, lineswidth)
        BottomRaven.Size = UDim2.new(0, 0, 0, lineswidth)
        LeftSideRaven.Position = UDim2.new(-1,0,0, 0)
        RightSideRaven.Position = UDim2.new(2, 0, 0, 0)
        RavenTextB4.Position = UDim2.new(1, 0, 0.75, 0)
        RavenText.Position = UDim2.new(-1, 0, 0, 0)
    end
end
local Credits = Instance.new("TextLabel")

Credits.Name = "Credits"
Credits.Parent = ScreenGui
Credits.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Credits.BackgroundTransparency = 1.000
Credits.BorderColor3 = Color3.fromRGB(0, 0, 0)
Credits.BorderSizePixel = 0
Credits.Position = UDim2.new(0.76, 0, 0.95, 0)
Credits.Size = UDim2.new(0, 183, 0, 24)
Credits.Font = Enum.Font.Fantasy
Credits.Text = "Still bypasses most supported games even 1.5 years later!"
Credits.TextColor3 = Color3.fromRGB(255, 255, 255)
Credits.TextSize = 14.000
Credits.TextXAlignment = Enum.TextXAlignment.Right

--Tabs
shared:createnotification("Press \"V\" or the Raven Icon to open the GUI!",3,"Raven B4 Loaded")

shared.RavenB4TabName1 = shared.RavenB4TabName1 or "combat" -- litteraly only made this for the ps99 version, more will come sooner or later tbh
Combat = lib:CreateWindow(shared.RavenB4TabName1,UDim2.new(0.03, 0, 0.1, 0),"15047268885")
Blatant = lib:CreateWindow("blatant",UDim2.new(0.23, 0, 0.1, 0),"15090672783")
Render = lib:CreateWindow("render",UDim2.new(0.62, 0, 0.1, 0),"15090679835")
Utility = lib:CreateWindow("utility",UDim2.new(0.82, 0, 0.1, 0),"15090688384")
Client = lib:CreateWindow("client",UDim2.new(0.435, 0, 0.4, 0),"15090649788")
Exploit = lib:CreateWindow("exploits",UDim2.new(0.82, 0, 0.8, 0),"15090649788")
GUIToggle = Client:CreateToggle({
    Name = "GUI",
    Animation = false,
    StartingState = true,
    Keybind = Enum.KeyCode.RightShift,
    Callback = function() 
        lib:ToggleLib()
    end
})
GUIToggle:CreateInfo("All GUI modules in one place!")
GUIToggle:CreateDropDown({
    Name = "Theme",
    DefaultOption = Usedlist[1],
    Options = Usedlist,
    Callback = function(Callback)
    usedtheme = Callback
    changefactor = true
end})
GUIToggle:CreateToggle({
    Name = "Arraylist",
    StartingState = true,
    Callback = function(Callback) 
        Array.Visible = Callback
end})
GUIToggle:CreateToggle({
    Name = "Uninject",
    Animation = false,
    StartingState = false,
    Untoggle = true,
    Callback = function(Callback)
        if Callback then
            -- Toggle off all modules and disconnect their connections
            saveSettings()
            for _, toggle in ipairs(allToggles) do
                if toggle.SetState then
                    toggle:SetState(false)
                end
                -- Disconnect all stored connections
                for _, connection in ipairs(toggle.Connections or {}) do
                    pcall(function() connection:Disconnect() end)
                end
            end
            -- Destroy GUI elements
            if ScreenGui then ScreenGui:Destroy() end
            if shared.ScreenGui2 then shared.ScreenGui2:Destroy() end
            if ScreenGUIFrame then ScreenGUIFrame:Destroy() end
            if Blur then Blur:Destroy() end
            -- Clear global state
            shared.RavenB4Injected = false
            shared.ScreenGui2 = nil
            allToggles = {}
            GUISaveSettings = {}
            GUILoadSettings = {}
            -- Stop any running coroutines
            for _, thread in ipairs(getgc(true)) do
                if type(thread) == "thread" and coroutine.status(thread) ~= "dead" then
                    pcall(coroutine.close, thread)
                end
            end
        end
    end
})
GUIToggle:CreateToggle({
    Name = "ReInject",
    Animation = false,
    StartingState = false,
    Untoggle = true,
    Callback = function(Callback)
        if Callback then
            -- Toggle off all modules and disconnect their connections
            for _, toggle in ipairs(allToggles) do
                if toggle.SetState then
                    toggle:SetState(false)
                end
                -- Disconnect all stored connections
                for _, connection in ipairs(toggle.Connections or {}) do
                    pcall(function() connection:Disconnect() end)
                end
            end
            -- Destroy GUI elements
            if ScreenGui then ScreenGui:Destroy() end
            if shared.ScreenGui2 then shared.ScreenGui2:Destroy() end
            if ScreenGUIFrame then ScreenGUIFrame:Destroy() end
            if Blur then Blur:Destroy() end
            -- Clear global state
            shared.RavenB4Injected = false
            shared.ScreenGui2 = nil
            allToggles = {}
            GUISaveSettings = {}
            GUILoadSettings = {}
            -- Stop any running coroutines
            for _, thread in ipairs(getgc(true)) do
                if type(thread) == "thread" and coroutine.status(thread) ~= "dead" then
                    pcall(coroutine.close, thread)
                end
            end
            loadstring(readfile("RavenB4s/ActualClient/ravenloader.lua"))()
        end
    end
})
--[[
GUIToggle:CreateToggle({
    Name = "Notification",
    StartingState = false,
    Callback = function(Callback)
        ModuleNotification = Callback
end})]]
if shared.WaterMark ~= nil then
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = shared.ScreenGui2
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Position = UDim2.new(0, 0, 0, -1)
    TextLabel.Size = UDim2.new(0, 200, 0, 50)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = shared.WaterMark
    if shared.WaterMarkColor ~= nil then
        TextLabel.TextColor3 = shared.WaterMarkColor
    else
        TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
    TextLabel.TextSize = 30.000
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Visible = false
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local raventag = Client:CreateToggle({
    Name = "RavenB4 Tag",
    Callback = function(Callback) 
        RavenTagEnabled = Callback
            TextChatService.OnIncomingMessage = function(message)
				local properties = Instance.new("TextChatMessageProperties")
				if message.TextSource then
					local getidplayer = Players:GetPlayerByUserId(message.TextSource.UserId)
					if getidplayer and getidplayer.UserId == LocalPlayer.UserId then
                        if RavenTagEnabled then
						    properties.PrefixText = "<font color='#692B97'>[RAVEN B4 USER]</font> " .. message.PrefixText
                        else
                            properties.PrefixText = message.PrefixText
                        end
					end
				end
			return properties
		end
end})
local bedwarsids = {6872265039,6872274481,8444591321,8560631822}
local inbedwars = false
if table.find(bedwarsids,game.PlaceId) then
    inbedwars = true
end
local TweenService = game:GetService("TweenService")
function IsAlive(plr)
    plr = plr or LocalPlayer
        if not plr.Character then return false end        
        if not plr.Character:FindFirstChild("Head") then return false end
        if not plr.Character:FindFirstChild("Humanoid") then return false end
        if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then return false end
    return true
 end
local RavenCape = false
local DecalId = "rbxassetid://15695670048"
local function CreateCape()
    local Cape = Instance.new("Part")

    Cape.Parent = LocalPlayer.Character
    Cape.Name = "RavenCape"
    Cape.Size = Vector3.new(0.2, 0.2, 0.08)
    Cape.Material = Enum.Material.Glass
    Cape.Color = Color3.fromRGB(28, 2, 22)
    Cape.CanCollide = false

    local BlockMesh = Instance.new("BlockMesh")

    BlockMesh.Parent = Cape
    BlockMesh.Name = "BlockMesh"
    BlockMesh.Scale = Vector3.new(9, 17.5, 0.5)
    BlockMesh.VertexColor = Vector3.new(1, 1, 1)

    local Motor = Instance.new("Motor")

    Motor.Parent = Cape
    Motor.Name = "Motor"
    Motor.C0 = CFrame.new(0, 2, 0, -4.37113883e-08, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-08)
    Motor.C1 = CFrame.new(0, 1, 0.449999988, -4.37113883e-08, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-08)
    Motor.Part1 = LocalPlayer.Character.UpperTorso
    Motor.Part0 = Cape
    Motor.CurrentAngle = -0.16208772361278534
    Motor.DesiredAngle = -0.1002269834280014

    local Decal = Instance.new("Decal")

    Decal.Parent = Cape
    Decal.Name = "Decal"
    Decal.Face = Enum.NormalId.Back
    Decal.Texture = DecalId
end
LocalPlayer.CharacterAdded:Connect(function()
    if LocalPlayer.Character:FindFirstChild("RavenCape") then LocalPlayer.Character:FindFirstChild("RavenCape"):Destroy() end
    task.wait(0.3)
    if IsAlive(LocalPlayer) and not LocalPlayer.Character:FindFirstChild("RavenCape") and RavenCape then
        CreateCape()
    end
end)
local CapeAngle = nil
Client:CreateToggle({
    Name = "Raven Cape",
    Callback = function(Callback) 
        RavenCape = Callback
        if RavenCape and IsAlive(LocalPlayer)then
            CreateCape()
        else
            if LocalPlayer.Character:FindFirstChild("RavenCape") then LocalPlayer.Character:FindFirstChild("RavenCape"):Destroy() end
        end
        repeat task.wait(0.5)
            if IsAlive(LocalPlayer) then
                if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 and LocalPlayer.Character:FindFirstChild("RavenCape") and CapeAngle then
                    CapeAngle = (LocalPlayer.Character.HumanoidRootPart.Velocity.magnitude < 45 and (-1 *(LocalPlayer.Character.HumanoidRootPart.Velocity.magnitude / 30)) or -1.5)
                else
                    CapeAngle = -0.2
                end
                if LocalPlayer.Character:FindFirstChild("RavenCape") then
                    TweenService:Create(LocalPlayer.Character:FindFirstChild("RavenCape"):FindFirstChild("Motor"), TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {CurrentAngle = CapeAngle}):Play()
                end
            end
        until not RavenCape
end})
local CapeAngle = nil
Client:CreateToggle({
    Name = "AutoToxic",
    Callback = function(Callback) 
        RavenCape = Callback
        if RavenCape and IsAlive(LocalPlayer)then
            CreateCape()
        else
            if LocalPlayer.Character:FindFirstChild("RavenCape") then LocalPlayer.Character:FindFirstChild("RavenCape"):Destroy() end
        end
        repeat task.wait(0.5)
            if IsAlive(LocalPlayer) then
                if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 and LocalPlayer.Character:FindFirstChild("RavenCape") and CapeAngle then
                    CapeAngle = (LocalPlayer.Character.HumanoidRootPart.Velocity.magnitude < 45 and (-1 *(LocalPlayer.Character.HumanoidRootPart.Velocity.magnitude / 30)) or -1.5)
                else
                    CapeAngle = -0.2
                end
                if LocalPlayer.Character:FindFirstChild("RavenCape") then
                    TweenService:Create(LocalPlayer.Character:FindFirstChild("RavenCape"):FindFirstChild("Motor"), TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {CurrentAngle = CapeAngle}):Play()
                end
            end
        until not RavenCape
end})
return lib
