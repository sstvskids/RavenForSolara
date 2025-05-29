
local HttpRequest = request or http_request
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local BASE_URL = "https://github.com/Ace-B4/Raven-B4-For-Roblox/raw/refs/heads/main/"
local RAW_BASE_URL = "https://raw.githubusercontent.com/Ace-B4/Raven-B4-For-Roblox/refs/heads/main"
local RavenB4 = {}
RavenB4.__index = RavenB4

function RavenB4.new()
    local self = setmetatable({}, RavenB4)
    self.ConfigPath = "RavenB4/Config"
    self.LoadFontPath = "RavenB4"
    self.FontPath = "RavenB4/Font"
    self.GameName = ""
    self.ConfigName = "Default Config"
    self.SupportedGames = {
        Bladeball = {13772394625, 14915220621, 15144787112, 15234596844, 15264892126, 15185247558},
        Petsim99 = {8737899170},
        Skywars = {8542259458, 8542275097, 8592115909, 8768229691, 8951451142, 13246639586},
        Bridgeduels = {10810646982, 11630038968},
        SurvivalGame = {11156779721},
        Bedwars = {6872265039, 6872274481, 8444591321, 8560631822},
        Booga = {11729688377}
    }
    self.IsInjected = false
    return self
end

function RavenB4:CheckExecutorSupport()
    if not (writefile and readfile and makefolder and isfolder) then
        Players.LocalPlayer:Kick("Executor is not supported, please use another executor for Raven B4!")
        return false
    end
    return true
end

function RavenB4:SetupDirectories()
    if not isfolder(self.FontPath) then
        makefolder(self.FontPath)
    end
    if not isfolder(self.ConfigPath) then
        makefolder(self.ConfigPath)
    end
end

function RavenB4:DownloadFonts()
    local fonts = {
        {name = "MCBold", url = BASE_URL .. "MCBold.otf", config = "MCBold.json"},
        {name = "MCReg", url = BASE_URL .. "MCReg.otf", config = "MCReg.json"}
    }

    for _, font in ipairs(fonts) do
        local success, response = pcall(function()
            return HttpRequest({
                Url = font.url,
                Method = "GET"
            }).Body
        end)

        if success then
            writefile(self.FontPath .. "/" .. font.name .. ".otf", response)
            self:WriteFontConfig(font.name, font.config)
        else
            print("Failed to download " .. font.name .. " font")
        end
    end
end

function RavenB4:WriteFontConfig(fontName, configFile)
    local config = {
        name = "Minecraft",
        faces = {{
            name = fontName == "MCBold" and "Bold" or "Regular",
            weight = 500,
            style = "normal",
            assetId = getcustomasset(self.FontPath .. "/" .. fontName .. ".otf")
        }}
    }
    writefile(self.LoadFontPath .. "/" .. configFile, HttpService:JSONEncode(config))
end

function RavenB4:DetectGame()
    for gameName, placeIds in pairs(self.SupportedGames) do
        if table.find(placeIds, game.PlaceId) then
            self.GameName = gameName
            self.ConfigName = "Raven B4 " .. gameName .. ".json"
            return true
        end
    end
    print("Game is not supported")
    return false
end

function RavenB4:LoadModules()
    local modulePath = shared.devtesting and "RavenB4s/ActualClient" or RAW_BASE_URL
    local success, result = pcall(function()
    lib = loadstring(game:HttpGet(modulePath .. "/GUI/RavenGUI.lua"))()
    buttons = loadstring(game:HttpGet(modulePath .. "/Functions/Buttonfunctions.lua"))()
    module = loadstring(game:HttpGet(modulePath .. "/Functions/" .. self.GameName .. "functions.lua"))()
    loadstring(game:HttpGet(modulePath .. "/Games/" .. self.GameName .. ".lua"))()
    return lib
    end)
    if not success then
        print("Failed to load modules: " .. tostring(result))
        return nil
    end
    return result
end

function RavenB4:Initialize()
    if shared.RavenB4Injected then
        error("RavenB4 is already injected!")
    end

    if not self:CheckExecutorSupport() then
        return
    end

    self:SetupDirectories()
    self:DownloadFonts()

    if self:DetectGame() then
        shared.RavenConfigName = self.ConfigName
        shared.RavenB4Injected = true
        return self:LoadModules()
    end
end

local raven = RavenB4.new()
local lib = raven:Initialize()

queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Near-B4/Raven-B4-For-Roblox/refs/heads/main/Raven%20B4%20Loader.lua"))()')

return lib
