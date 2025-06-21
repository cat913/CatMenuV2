-- 🖥️ Cat Menu V2 Fixed - Simplified and Robust
-- Execute via: Exploit injector (e.g., Synapse X, Krnl, Fluxus)
-- Toggles with: P key or /openmenu in chat

print("🖥️ [CatMenuV2] Fixed Script Started at: " .. os.date())

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 🧑‍🔧 Admins Only (Auto-Includes LocalPlayer)
local Admins = { [LocalPlayer.UserId] = true }
if not Admins[LocalPlayer.UserId] then
    warn("[CatMenuV2] Not an admin. Script terminated.")
    return
end
print("[CatMenuV2] LocalPlayer is admin")

-- 🖼️ GUI Setup
local screenGui, mainFrame, adminFrame, trollerFrame
local lastMainFramePosition = UDim2.new(0.5, -150, 0.5, -175)

local function initializeGUI()
    print("[CatMenuV2] Initializing GUI")
    local timeout = 10
    local startTime = tick()
    while not LocalPlayer:FindFirstChild("PlayerGui") do
        if tick() - startTime > timeout then
            warn("[CatMenuV2] Timeout waiting for PlayerGui")
            return nil
        end
        task.wait(0.5)
    end

    local success, err = pcall(function()
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CatMenuV2"
        screenGui.Enabled = false
        screenGui.ResetOnSpawn = false
        screenGui.Parent = LocalPlayer.PlayerGui

        mainFrame = Instance.new("Frame", screenGui)
        mainFrame.Size = UDim2.new(0, 300, 0, 350)
        mainFrame.Position = lastMainFramePosition
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.Visible = false
        mainFrame.Active = true
        mainFrame.Draggable = true
        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

        local titleLabel = Instance.new("TextLabel", mainFrame)
        titleLabel.Size = UDim2.new(1, 0, 0, 30)
        titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        titleLabel.Text = "🐱 Cat Menu V2"
        titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.GothamBold
        Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 8)

        local mainCanvas = Instance.new("ScrollingFrame", mainFrame)
        mainCanvas.Size = UDim2.new(1, 0, 1, -40)
        mainCanvas.Position = UDim2.new(0, 0, 0, 40)
        mainCanvas.BackgroundTransparency = 1
        mainCanvas.ScrollBarThickness = 5
        mainCanvas.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
        mainCanvas.CanvasSize = UDim2.new(0, 0, 0, 0)
        mainCanvas.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local layout = Instance.new("UIListLayout", mainCanvas)
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Instance.new("UIPadding", mainCanvas).PaddingTop = UDim.new(0, 8)

        adminFrame = mainFrame:Clone()
        adminFrame.Parent = screenGui
        adminFrame.Visible = false
        adminFrame:FindFirstChild("TextLabel").Text = "ADMIN MENU"

        trollerFrame = mainFrame:Clone()
        trollerFrame.Parent = screenGui
        trollerFrame.Visible = false
        trollerFrame:FindFirstChild("TextLabel").Text = "TROLLER MENU"
    end)

    if not success then
        warn("[CatMenuV2] GUI init failed: " .. tostring(err))
        return nil
    end
    print("[CatMenuV2] GUI initialized")
    return screenGui
end

screenGui = initializeGUI()
if not screenGui then
    warn("[CatMenuV2] GUI setup failed. Terminating.")
    return
end

-- 🔄 Toggle Menu
local function toggleMenu()
    screenGui.Enabled = not screenGui.Enabled
    if screenGui.Enabled then
        mainFrame.Visible = true
        adminFrame.Visible = false
        trollerFrame.Visible = false
        print("[CatMenuV2] Menu opened")
    else
        mainFrame.Visible = false
        adminFrame.Visible = false
        trollerFrame.Visible = false
        print("[CatMenuV2] Menu closed")
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        toggleMenu()
    end
end)

LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == "/openmenu" then
        toggleMenu()
    end
end)

-- 📦 UI Factories
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = parent
    btn.MouseButton1Click:Connect(function()
        local success, err = pcall(callback)
        if not success then
            warn("[CatMenuV2] Button error (" .. text .. "): " .. tostring(err))
        end
    end)
    return btn
end

local function createInput(parent, placeholder, callback)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.PlaceholderText = placeholder
    input.TextColor3 = Color3.fromRGB(0, 255, 255)
    input.TextSize = 14
    input.Font = Enum.Font.Gotham
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    input.Parent = parent
    input.FocusLost:Connect(function()
        local success, err = pcall(function() callback(input.Text) end)
        if not success then
            warn("[CatMenuV2] Input error (" .. placeholder .. "): " .. tostring(err))
        end
        input.Text = ""
    end)
    return input
end

-- 🛠️ Character Validation
local function isCharacterValid(player)
    local char = player and player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hrp and hum
end

-- 🛠️ State Management
local flyData = { flying = false, flySpeed = 50, flyConn = nil, bodyVelocity = nil }
local noClipData = { enabled = false, conn = nil }
local teleportData = { enabled = false, conn = nil }
local espData = { enabled = false, conns = {} }
local xrayData = { enabled = false, conns = {} }
local speedData = { enabled = false, speed = 50 }
local jumpData = { infinite = false, conn = nil }
local gravityData = { noGravity = false, lowGravity = false, conn = nil }
local godModeData = { enabled = false, conn = nil }
local invisibleData = { enabled = false }
local healData = { enabled = false, conn = nil }
local timeStopData = { enabled = false, conn = nil }
local timeSlowData = { enabled = false, conn = nil }
local explodeData = { enabled = false, conn = nil }
local oneHitData = { enabled = false, conn = nil }
local flingData = { enabled = false, conn = nil }

-- ✈️ Fly Logic
local flyButton
local function startFly()
    if not isCharacterValid(LocalPlayer) then return end
    if flyData.flying then return end
    flyData.flying = true
    flyButton.Text = "Disable Fly"
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local success, err = pcall(function()
        flyData.bodyVelocity = Instance.new("BodyVelocity")
        flyData.bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyData.bodyVelocity.Parent = hrp
        flyData.flyConn = RunService.RenderStepped:Connect(function()
            if not isCharacterValid(LocalPlayer) then
                stopFly()
                return
            end
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            flyData.bodyVelocity.Velocity = moveDir * flyData.flySpeed
        end)
    end)
    if not success then
        warn("[CatMenuV2] Fly error: " .. tostring(err))
        stopFly()
    else
        print("[CatMenuV2] Fly enabled")
    end
end

local function stopFly()
    flyData.flying = false
    flyButton.Text = "Toggle Fly"
    if flyData.flyConn then flyData.flyConn:Disconnect() end
    if flyData.bodyVelocity then flyData.bodyVelocity:Destroy() end
    flyData.flyConn = nil
    flyData.bodyVelocity = nil
    print("[CatMenuV2] Fly disabled")
end

-- 🔄 Reset All
local function resetAll()
    if flyData.flying then stopFly() end
    if noClipData.enabled then
        noClipData.enabled = false
        if noClipData.conn then noClipData.conn:Disconnect() end
        if isCharacterValid(LocalPlayer) then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
    if teleportData.enabled then
        teleportData.enabled = false
        if teleportData.conn then teleportData.conn:Disconnect() end
    end
    if espData.enabled then
        espData.enabled = false
        for _, conn in ipairs(espData.conns) do conn:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                for _, adorn in ipairs(p.Character.HumanoidRootPart:GetChildren()) do
                    if adorn:IsA("BillboardGui") then adorn:Destroy() end
                end
            end
        end
        espData.conns = {}
    end
    if xrayData.enabled then
        xrayData.enabled = false
        for _, conn in ipairs(xrayData.conns) do conn:Disconnect() end
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local orig = part:FindFirstChild("OrigTransparency")
                if orig then
                    part.Transparency = orig.Value
                    orig:Destroy()
                end
            end
        end
        xrayData.conns = {}
    end
    if speedData.enabled then
        speedData.enabled = false
        if isCharacterValid(LocalPlayer) then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
    if jumpData.infinite then
        jumpData.infinite = false
        if jumpData.conn then jumpData.conn:Disconnect() end
    end
    if gravityData.noGravity or gravityData.lowGravity then
        gravityData.noGravity = false
        gravityData.lowGravity = false
        if gravityData.conn then gravityData.conn:Disconnect() end
        workspace.Gravity = 196.2
    end
    if godModeData.enabled then
        godModeData.enabled = false
        if godModeData.conn then godModeData.conn:Disconnect() end
        if isCharacterValid(LocalPlayer) then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = 100
            hum.Health = 100
        end
    end
    if invisibleData.enabled then
        invisibleData.enabled = false
        if isCharacterValid(LocalPlayer) then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                end
            end
        end
    end
    if healData.enabled then
        healData.enabled = false
        if healData.conn then healData.conn:Disconnect() end
    end
    if timeStopData.enabled then
        timeStopData.enabled = false
        if timeStopData.conn then timeStopData.conn:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isCharacterValid(p) then
                p.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
    if timeSlowData.enabled then
        timeSlowData.enabled = false
        if timeSlowData.conn then timeSlowData.conn:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isCharacterValid(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                hum.WalkSpeed = 16
            end
        end
    end
    if explodeData.enabled then
        explodeData.enabled = false
        if explodeData.conn then explodeData.conn:Disconnect() end
    end
    if oneHitData.enabled then
        oneHitData.enabled = false
        if oneHitData.conn then oneHitData.conn:Disconnect() end
    end
    if flingData.enabled then
        flingData.enabled = false
        if flingData.conn then flingData.conn:Disconnect() end
    end
    print("[CatMenuV2] All powers reset")
end

-- Main Menu
local mainCanvas = mainFrame:FindFirstChildOfClass("ScrollingFrame")
flyButton = createButton(mainCanvas, "Toggle Fly", function()
    if flyData.flying then stopFly() else startFly() end
end)

createInput(mainCanvas, "Fly Speed (50)", function(value)
    local num = tonumber(value)
    if num then flyData.flySpeed = num end
end)

createButton(mainCanvas, "NoClip", function()
    noClipData.enabled = not noClipData.enabled
    if noClipData.enabled then
        noClipData.conn = RunService.Stepped:Connect(function()
            if not isCharacterValid(LocalPlayer) then
                noClipData.enabled = false
                noClipData.conn:Disconnect()
                return
            end
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
        print("[CatMenuV2] NoClip enabled")
    else
        if noClipData.conn then noClipData.conn:Disconnect() end
        if isCharacterValid(LocalPlayer) then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
        print("[CatMenuV2] NoClip disabled")
    end
end)

createButton(mainCanvas, "Teleport (Ctrl+Click)", function()
    teleportData.enabled = not teleportData.enabled
    if teleportData.enabled then
        local mouse = LocalPlayer:GetMouse()
        teleportData.conn = mouse.Button1Down:Connect(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and isCharacterValid(LocalPlayer) then
                local hit = mouse.Hit
                if hit then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
                    print("[CatMenuV2] Teleported to mouse")
                end
            end
        end)
        print("[CatMenuV2] Teleport enabled")
    else
        if teleportData.conn then teleportData.conn:Disconnect() end
        print("[CatMenuV2] Teleport disabled")
    end
end)

createButton(mainCanvas, "Speed Boost", function()
    speedData.enabled = not speedData.enabled
    if isCharacterValid(LocalPlayer) then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speedData.enabled and speedData.speed or 16
        print("[CatMenuV2] Speed Boost: " .. tostring(speedData.enabled))
    end
end)

createInput(mainCanvas, "Walk Speed (50)", function(value)
    local num = tonumber(value)
    if num then
        speedData.speed = num
        if speedData.enabled and isCharacterValid(LocalPlayer) then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = num
        end
    end
end)

createButton(mainCanvas, "Infinite Jump", function()
    jumpData.infinite = not jumpData.infinite
    if jumpData.infinite then
        jumpData.conn = UserInputService.JumpRequest:Connect(function()
            if isCharacterValid(LocalPlayer) then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        print("[CatMenuV2] Infinite Jump enabled")
    else
        if jumpData.conn then jumpData.conn:Disconnect() end
        print("[CatMenuV2] Infinite Jump disabled")
    end
end)

createButton(mainCanvas, "ESP", function()
    espData.enabled = not espData.enabled
    if espData.enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isCharacterValid(p) then
                local hrp = p.Character.HumanoidRootPart
                local gui = Instance.new("BillboardGui", hrp)
                gui.Size = UDim2.new(0, 100, 0, 30)
                gui.StudsOffset = Vector3.new(0, 3, 0)
                gui.AlwaysOnTop = true
                local text = Instance.new("TextLabel", gui)
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = p.Name
                text.TextColor3 = Color3.fromRGB(0, 255, 255)
                text.TextSize = 14
            end
        end
        local conn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(char)
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if hrp and p ~= LocalPlayer then
                    local gui = Instance.new("BillboardGui", hrp)
                    gui.Size = UDim2.new(0, 100, 0, 30)
                    gui.StudsOffset = Vector3.new(0, 3, 0)
                    gui.AlwaysOnTop = true
                    local text = Instance.new("TextLabel", gui)
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = p.Name
                    text.TextColor3 = Color3.fromRGB(0, 255, 255)
                    text.TextSize = 14
                end
            end)
        end)
        table.insert(espData.conns, conn)
        print("[CatMenuV2] ESP enabled")
    else
        for _, conn in ipairs(espData.conns) do conn:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                for _, adorn in ipairs(p.Character.HumanoidRootPart:GetChildren()) do
                    if adorn:IsA("BillboardGui") then adorn:Destroy() end
                end
            end
        end
        espData.conns = {}
        print("[CatMenuV2] ESP disabled")
    end
end)

createButton(mainCanvas, "XRay", function()
    xrayData.enabled = not xrayData.enabled
    if xrayData.enabled then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                local orig = Instance.new("NumberValue", part)
                orig.Name = "OrigTransparency"
                orig.Value = part.Transparency
                part.Transparency = 0.7
            end
        end
        local conn = workspace.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") and part.Transparency < 1 then
                local orig = Instance.new("NumberValue", part)
                orig.Name = "OrigTransparency"
                orig.Value = part.Transparency
                part.Transparency = 0.7
            end
        end)
        table.insert(xrayData.conns, conn)
        print("[CatMenuV2] XRay enabled")
    else
        for _, conn in ipairs(xrayData.conns) do conn:Disconnect() end
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local orig = part:FindFirstChild("OrigTransparency")
                if orig then
                    part.Transparency = orig.Value
                    orig:Destroy()
                end
            end
        end
        xrayData.conns = {}
        print("[CatMenuV2] XRay disabled")
    end
end)

createButton(mainCanvas, "No Gravity", function()
    gravityData.noGravity = not gravityData.noGravity
    gravityData.lowGravity = false
    if gravityData.noGravity then
        gravityData.conn = RunService.Heartbeat:Connect(function()
            workspace.Gravity = 0
        end)
        print("[CatMenuV2] No Gravity enabled")
    else
        if gravityData.conn then gravityData.conn:Disconnect() end
        workspace.Gravity = 196.2
        print("[CatMenuV2] No Gravity disabled")
    end
end)

createButton(mainCanvas, "Low Gravity", function()
    gravityData.lowGravity = not gravityData.lowGravity
    gravityData.noGravity = false
    if gravityData.lowGravity then
        gravityData.conn = RunService.Heartbeat:Connect(function()
            workspace.Gravity = 50
        end)
        print("[CatMenuV2] Low Gravity enabled")
    else
        if gravityData.conn then gravityData.conn:Disconnect() end
        workspace.Gravity = 196.2
        print("[CatMenuV2] Low Gravity disabled")
    end
end)

createButton(mainCanvas, "Admin Menu", function()
    lastMainFramePosition = mainFrame.Position
    mainFrame.Visible = false
    adminFrame.Position = lastMainFramePosition
    adminFrame.Visible = true
    print("[CatMenuV2] Admin Menu opened")
end)

createButton(mainCanvas, "Troller Menu", function()
    lastMainFramePosition = mainFrame.Position
    mainFrame.Visible = false
    trollerFrame.Position = lastMainFramePosition
    trollerFrame.Visible = true
    print("[CatMenuV2] Troller Menu opened")
end)

createButton(mainCanvas, "Reset All", resetAll)

createButton(mainCanvas, "Close", function()
    screenGui.Enabled = false
    mainFrame.Visible = false
    print("[CatMenuV2] Menu closed")
end, Color3.fromRGB(200, 50, 50))

-- Admin Menu
local adminCanvas = adminFrame:FindFirstChildOfClass("ScrollingFrame")
createButton(adminCanvas, "Back to Main", function()
    adminFrame.Visible = false
    mainFrame.Position = lastMainFramePosition
    mainFrame.Visible = true
    print("[CatMenuV2] Returned to Main Menu")
end)

createButton(adminCanvas, "God Mode", function()
    godModeData.enabled = not godModeData.enabled
    if godModeData.enabled then
        if isCharacterValid(LocalPlayer) then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
        godModeData.conn = LocalPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
        end)
        print("[CatMenuV2] God Mode enabled")
    else
        if godModeData.conn then godModeData.conn:Disconnect() end
        if isCharacterValid(LocalPlayer) then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = 100
            hum.Health = 100
        end
        print("[CatMenuV2] God Mode disabled")
    end
end)

createButton(adminCanvas, "Invisible", function()
    invisibleData.enabled = not invisibleData.enabled
    if isCharacterValid(LocalPlayer) then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = invisibleData.enabled and 1 or 0
            end
        end
        print("[CatMenuV2] Invisible: " .. tostring(invisibleData.enabled))
    end
end)

createButton(adminCanvas, "Loop Heal", function()
    healData.enabled = not healData.enabled
    if healData.enabled then
        healData.conn = RunService.Heartbeat:Connect(function()
            if isCharacterValid(LocalPlayer) then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                hum.Health = hum.MaxHealth
            end
        end)
        print("[CatMenuV2] Loop Heal enabled")
    else
        if healData.conn then healData.conn:Disconnect() end
        print("[CatMenuV2] Loop Heal disabled")
    end
end)

createButton(adminCanvas, "Explode Mode", function()
    explodeData.enabled = not explodeData.enabled
    if explodeData.enabled then
        explodeData.conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = LocalPlayer:GetMouse()
                if mouse.Hit then
                    local explosion = Instance.new("Explosion")
                    explosion.Position = mouse.Hit.Position
                    explosion.BlastRadius = 10
                    explosion.Parent = workspace
                    print("[CatMenuV2] Explosion created")
                end
            end
        end)
        print("[CatMenuV2] Explode Mode enabled")
    else
        if explodeData.conn then explodeData.conn:Disconnect() end
        print("[CatMenuV2] Explode Mode disabled")
    end
end)

createButton(adminCanvas, "Time Stop", function()
    timeStopData.enabled = not timeStopData.enabled
    if timeStopData.enabled then
        timeStopData.conn = RunService.Heartbeat:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isCharacterValid(p) then
                    p.Character.HumanoidRootPart.Anchored = true
                end
            end
        end)
        print("[CatMenuV2] Time Stop enabled")
    else
        if timeStopData.conn then timeStopData.conn:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isCharacterValid(p) then
                p.Character.HumanoidRootPart.Anchored = false
            end
        end
        print("[CatMenuV2] Time Stop disabled")
    end
end)

createButton(adminCanvas, "Time Slow", function()
    timeSlowData.enabled = not timeSlowData.enabled
    if timeSlowData.enabled then
        timeSlowData.conn = RunService.Heartbeat:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isCharacterValid(p) then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    hum.WalkSpeed = 4
                end
            end
        end)
        print("[CatMenuV2] Time Slow enabled")
    else
        if timeSlowData.conn then timeSlowData.conn:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isCharacterValid(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                hum.WalkSpeed = 16
            end
        end
        print("[CatMenuV2] Time Slow disabled")
    end
end)

createButton(adminCanvas, "One-Hit Kill", function()
    oneHitData.enabled = not oneHitData.enabled
    if oneHitData.enabled then
        oneHitData.conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = LocalPlayer:GetMouse()
                local target = Players:GetPlayerFromCharacter(mouse.Target.Parent)
                if target and target ~= LocalPlayer and isCharacterValid(target) then
                    target.Character:FindFirstChildOfClass("Humanoid").Health = 0
                    print("[CatMenuV2] Killed: " .. target.Name)
                end
            end
        end)
        print("[CatMenuV2] One-Hit Kill enabled")
    else
        if oneHitData.conn then oneHitData.conn:Disconnect() end
        print("[CatMenuV2] One-Hit Kill disabled")
    end
end)

createButton(adminCanvas, "Click Fling", function()
    flingData.enabled = not flingData.enabled
    if flingData.enabled then
        local mouse = LocalPlayer:GetMouse()
        flingData.conn = mouse.Button1Down:Connect(function()
            local target = Players:GetPlayerFromCharacter(mouse.Target.Parent)
            if target and target ~= LocalPlayer and isCharacterValid(target) and isCharacterValid(LocalPlayer) then
                local hrp = target.Character.HumanoidRootPart
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(math.random(-100, 100), 200, math.random(-100, 100))
                bv.Parent = hrp
                game:GetService("Debris"):AddItem(bv, 0.3)
                print("[CatMenuV2] Flung: " .. target.Name)
            end
        end)
        print("[CatMenuV2] Click Fling enabled")
    else
        if flingData.conn then flingData.conn:Disconnect() end
        print("[CatMenuV2] Click Fling disabled")
    end
end)

createButton(adminCanvas, "Close", function()
    screenGui.Enabled = false
    adminFrame.Visible = false
    print("[CatMenuV2] Admin Menu closed")
end, Color3.fromRGB(200, 50, 50))

-- Troller Menu
local trollerCanvas = trollerFrame:FindFirstChildOfClass("ScrollingFrame")
createButton(trollerCanvas, "Back to Main", function()
    trollerFrame.Visible = false
    mainFrame.Position = lastMainFramePosition
    mainFrame.Visible = true
    print("[CatMenuV2] Returned to Main Menu")
end)

createButton(trollerCanvas, "Select Player", function()
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 200, 0, 250)
    frame.Position = UDim2.new(0.5, -100, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "Select Player"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 1, -40)
    scroll.Position = UDim2.new(0, 0, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            createButton(scroll, p.Name, function()
                print("[CatMenuV2] Selected: " .. p.Name)
                frame:Destroy()
            end)
        end
    end

    createButton(scroll, "Close", function()
        frame:Destroy()
    end, Color3.fromRGB(200, 50, 50))
end)

createButton(trollerCanvas, "Close", function()
    screenGui.Enabled = false
    trollerFrame.Visible = false
    print("[CatMenuV2] Troller Menu closed")
end, Color3.fromRGB(200, 50, 50))

print("[CatMenuV2] Script loaded")