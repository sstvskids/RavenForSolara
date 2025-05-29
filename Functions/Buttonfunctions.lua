local UIS = game:GetService("UserInputService")

local PCplaying = false
if UIS.KeyboardEnabled and UIS.MouseEnabled and not UIS.TouchEnabled then
    PCplaying = true
else
    PCplaying = false
end

local ScreenGui2 = Instance.new("ScreenGui")
local DownButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local ImageLabel = Instance.new("ImageLabel")
local UICorner_2 = Instance.new("UICorner")
local FlyButton = Instance.new("TextButton")
local UICorner_3 = Instance.new("UICorner")
local InfFlyButton = Instance.new("TextButton")
local UICorner_4 = Instance.new("UICorner")
local LongjumpButton = Instance.new("TextButton")
local UICorner_5 = Instance.new("UICorner")
local UpButton = Instance.new("TextButton")
local UICorner_6 = Instance.new("UICorner")
local ImageLabel_2 = Instance.new("ImageLabel")
local UICorner_7 = Instance.new("UICorner")

ScreenGui2.Name = "ScreenGui2"
ScreenGui2.Parent = game:WaitForChild("CoreGui")
ScreenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

DownButton.Name = "DownButton"
DownButton.Parent = ScreenGui2
DownButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DownButton.BackgroundTransparency = 0.400
DownButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
DownButton.BorderSizePixel = 0
DownButton.Position = UDim2.new(0.155999988, 0, 0.277943134, 0)
DownButton.Size = UDim2.new(0, 50, 0, 49)
DownButton.Font = Enum.Font.GothamBold
DownButton.Text = ""
DownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DownButton.TextSize = 18.000
DownButton.TextWrapped = true
DownButton.Visible = false

UICorner.CornerRadius = UDim.new(0, 50)
UICorner.Parent = DownButton

ImageLabel.Parent = DownButton
ImageLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0, 0, -3.24249268e-05, 0)
ImageLabel.Size = UDim2.new(1, 0, 1.02546406, 0)
ImageLabel.Image = "rbxassetid://14675812877"

UICorner_2.CornerRadius = UDim.new(0, 100)
UICorner_2.Parent = ImageLabel

FlyButton.Name = "FlyButton"
FlyButton.Parent = ScreenGui2
FlyButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FlyButton.BackgroundTransparency = 0.400
FlyButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlyButton.BorderSizePixel = 0
FlyButton.Position = UDim2.new(0.0232432075, 0, 0.417482257, 0)
FlyButton.Size = UDim2.new(0, 50, 0, 49)
FlyButton.Font = Enum.Font.GothamBold
FlyButton.Text = "Fly"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 18.000
FlyButton.TextWrapped = true
FlyButton.Visible = false

UICorner_3.CornerRadius = UDim.new(0, 50)
UICorner_3.Parent = FlyButton

InfFlyButton.Name = "InfFlyButton"
InfFlyButton.Parent = ScreenGui2
InfFlyButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InfFlyButton.BackgroundTransparency = 0.400
InfFlyButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
InfFlyButton.BorderSizePixel = 0
InfFlyButton.Position = UDim2.new(0.111921936, 0, 0.417482257, 0)
InfFlyButton.Size = UDim2.new(0, 50, 0, 49)
InfFlyButton.Font = Enum.Font.GothamBold
InfFlyButton.Text = "Inf Fly"
InfFlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfFlyButton.TextSize = 16.000
InfFlyButton.TextWrapped = true
InfFlyButton.Visible = false

UICorner_4.CornerRadius = UDim.new(0, 50)
UICorner_4.Parent = InfFlyButton

LongjumpButton.Name = "LongjumpButton"
LongjumpButton.Parent = ScreenGui2
LongjumpButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LongjumpButton.BackgroundTransparency = 0.400
LongjumpButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
LongjumpButton.BorderSizePixel = 0
LongjumpButton.Position = UDim2.new(0.20210211, 0, 0.417482257, 0)
LongjumpButton.Size = UDim2.new(0, 50, 0, 49)
LongjumpButton.Font = Enum.Font.GothamBold
LongjumpButton.Text = "Scaffold"
LongjumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LongjumpButton.TextSize = 10.000
LongjumpButton.TextWrapped = true
LongjumpButton.Visible = false

UICorner_5.CornerRadius = UDim.new(0, 50)
UICorner_5.Parent = LongjumpButton

UpButton.Name = "UpButton"
UpButton.Parent = ScreenGui2
UpButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
UpButton.BackgroundTransparency = 0.400
UpButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
UpButton.BorderSizePixel = 0
UpButton.Position = UDim2.new(0.067507498, 0, 0.277664095, 0)
UpButton.Size = UDim2.new(0, 50, 0, 49)
UpButton.Font = Enum.Font.GothamBold
UpButton.Text = ""
UpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UpButton.TextSize = 18.000
UpButton.TextWrapped = true
UpButton.Visible = false

UICorner_6.CornerRadius = UDim.new(0, 50)
UICorner_6.Parent = UpButton

ImageLabel_2.Parent = UpButton
ImageLabel_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel_2.BackgroundTransparency = 1.000
ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel_2.BorderSizePixel = 0
ImageLabel_2.Size = UDim2.new(1, 0, 1, 0)
ImageLabel_2.Image = "rbxassetid://14675825062"

UICorner_7.CornerRadius = UDim.new(0, 100)
UICorner_7.Parent = ImageLabel_2
local FlyCounter = Instance.new("Frame")
local FlyCounterInner = Instance.new("Frame")
local FlyCounterText = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")
local UICornerInner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local UIGradient = Instance.new("UIGradient")
local UIGradientInner = Instance.new("UIGradient")
local ShineGradient = Instance.new("UIGradient")
local ShadowFrame = Instance.new("Frame")
local ShadowBlur = Instance.new("BlurEffect")

-- Determine device type (assuming PCplaying is defined elsewhere)
local PCplaying = true -- Replace with your actual device check

-- Fly Counter (Base Frame)
FlyCounter.Name = "FlyCounter"
FlyCounter.Parent = ScreenGui2
FlyCounter.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Darker base for glass effect
FlyCounter.BackgroundTransparency = 0.3 -- Slightly transparent
FlyCounter.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlyCounter.BorderSizePixel = 0
if PCplaying then
    FlyCounter.Position = UDim2.new(0.429146886, 0, 0.716593087, 0)
    FlyCounter.Size = UDim2.new(0.16667591, 0, 0.024887735, 0)
else
    FlyCounter.Position = UDim2.new(0.433879852, 0, 0.616842389, 0)
    FlyCounter.Size = UDim2.new(0.144879505, 0, 0.0261346232, 0)
end
FlyCounter.Visible = false

-- Rounded Corners for FlyCounter
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = FlyCounter

-- UI Stroke for FlyCounter
UIStroke.Parent = FlyCounter
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.5

-- Gradient for FlyCounter
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
UIGradient.Rotation = 45
UIGradient.Parent = FlyCounter

-- Fly Counter Inner (Progress Bar)
FlyCounterInner.Name = "FlyCounterInner"
FlyCounterInner.Parent = FlyCounter
FlyCounterInner.BackgroundColor3 = Color3.fromRGB(10, 213, 236)
FlyCounterInner.BackgroundTransparency = 0.1 -- Slightly transparent for depth
FlyCounterInner.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlyCounterInner.BorderSizePixel = 0
FlyCounterInner.Position = UDim2.new(-0.00188207824, 0, 0, 0)
FlyCounterInner.Size = UDim2.new(0.856437743, 0, 1, 0)

-- Rounded Corners for FlyCounterInner
UICornerInner.CornerRadius = UDim.new(0, 6)
UICornerInner.Parent = FlyCounterInner

-- Gradient for FlyCounterInner
UIGradientInner.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 213, 236)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
}
UIGradientInner.Rotation = 45
UIGradientInner.Parent = FlyCounterInner

-- Shine Effect on FlyCounterInner
ShineGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.4, 0.2),
    NumberSequenceKeypoint.new(0.6, 0.2),
    NumberSequenceKeypoint.new(1, 1)
}
ShineGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
ShineGradient.Offset = Vector2.new(-1, 0)
ShineGradient.Parent = FlyCounterInner

-- Animate the Shine Effect
spawn(function()
    while FlyCounterInner.Parent do
        local tween = game:GetService("TweenService"):Create(
            ShineGradient,
            TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
            {Offset = Vector2.new(1, 0)}
        )
        tween:Play()
        tween.Completed:Wait()
        ShineGradient.Offset = Vector2.new(-1, 0)
        task.wait(0.5)
    end
end)

-- Fly Counter Text
FlyCounterText.Name = "FlyCounterText"
FlyCounterText.Parent = FlyCounter
FlyCounterText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyCounterText.BackgroundTransparency = 1.000
FlyCounterText.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlyCounterText.BorderSizePixel = 0
FlyCounterText.Position = UDim2.new(0, 0, -1.19083965, 0)
FlyCounterText.Size = UDim2.new(1, 0, 1.19084013, 0)
FlyCounterText.FontFace = Font.new(getcustomasset("RavenB4/MCReg.json")) -- Using Minecraft font
FlyCounterText.Text = "2.5s"
FlyCounterText.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyCounterText.TextSize = PCplaying and 25 or 20
FlyCounterText.TextWrapped = true

-- Add a subtle shadow to the text
local TextShadow = Instance.new("UIStroke")
TextShadow.Parent = FlyCounterText
TextShadow.Thickness = 1
TextShadow.Color = Color3.fromRGB(0, 0, 0)
TextShadow.Transparency = 0.7

-- Drop Shadow (Simulated with a Frame and Blur)
ShadowFrame.Name = "ShadowFrame"
ShadowFrame.Parent = FlyCounter
ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShadowFrame.BackgroundTransparency = 0.6
ShadowFrame.BorderSizePixel = 0
ShadowFrame.Size = FlyCounter.Size
ShadowFrame.Position = UDim2.new(0, 4, 0, 4) -- Slight offset for shadow effect
ShadowFrame.ZIndex = FlyCounter.ZIndex - 1

-- Rounded Corners for Shadow
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 8)
ShadowCorner.Parent = ShadowFrame

-- Add Blur to Shadow
ShadowBlur.Name = "ShadowBlur"
ShadowBlur.Parent = game:GetService("Lighting")
ShadowBlur.Size = 5
ShadowBlur.Enabled = true

spawn(function()
    repeat
        task.wait(0.1)
        if not FlyButton.Visible and not InfFlyButton.Visible then
            UpButton.Visible = false
            DownButton.Visible = false
        else
            UpButton.Visible = true
            DownButton.Visible = true
        end
    until not true
end)
return {
    FlyCounter = FlyCounter,
    FlyCounterInner = FlyCounterInner,
    FlyCounterText = FlyCounterText,
    DownButton = DownButton,
    UpButton = UpButton,
    LongjumpButton = LongjumpButton,
    InfFlyButton = InfFlyButton,
    FlyButton = FlyButton
}
