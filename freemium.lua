-- SETTINGS
_G.POOR_WEBHOOK = "https://discord.com/api/webhooks/1494310126935343144/FgZWrnXJ0itEcg8NZYHCP_IjyP_tBlpLRSqnz5MeBlJ10o779vqy5kInA0qC2sC2T1Ur"

_G.MY_USERNAMES = {"Chelsea", "thisisanalt048", "daxkidcece"}

_G.PING_POOR = true

print("✅ Baddies script loaded successfully by " .. game.Players.LocalPlayer.Name)

-- Simple GUI for testing
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Parent = ScreenGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, 0, 0, 50)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Baddies Script Loaded!"
TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
TextLabel.TextScaled = true
TextLabel.Parent = Frame

print("GUI should have appeared!")
