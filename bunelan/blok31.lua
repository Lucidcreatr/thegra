-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- VARIABLES
local aimbotEnabled = false
local drawCircleEnabled = false
local circleScale = 50
local aimbotTarget = nil
local flyEnabled = false
local flySpeed = 50
local bodyVelocity = nil
local flyConnection = nil
local spinBotEnabled = false
local spinBotConnection = nil
local bunnyHopEnabled = false
local bunnyHopConnection = nil
local bigHitboxEnabled = false
local originalHeadSizes = {}
local state = {
    speed = false,
    walk = 16,
    infiniteAmmo = false,
    hitboxSize = 50,
}

local savedPosition = nil
local rainbowHandsConnection = nil
local colorChangeSpeed = 0.1

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "SimpleCheatGUI"

local function createTabButton(name, positionY)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Text = name
    btn.Position = UDim2.new(0, 10, 0, positionY)
    btn.Size = UDim2.new(0, 100, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.AutoButtonColor = true
    return btn
end

local function createToggle(name, parent, callback)
    local cb = Instance.new("TextButton", parent)
    cb.Size = UDim2.new(1, -20, 0, 30)
    cb.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    cb.TextColor3 = Color3.new(1,1,1)
    cb.Text = name .. ": OFF"
    local enabled = false
    cb.MouseButton1Click:Connect(function()
        enabled = not enabled
        cb.Text = name .. (enabled and ": ON" or ": OFF")
        callback(enabled)
    end)
    return cb
end

local function createSlider(name, parent, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1

    local slider = Instance.new("TextBox", frame)
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 20)
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.new(0,0,0)
    slider.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    slider.ClearTextOnFocus = false

    slider.FocusLost:Connect(function(enterPressed)
        local val = tonumber(slider.Text)
        if val then
            if val < min then val = min end
            if val > max then val = max end
            label.Text = name .. ": " .. val
            slider.Text = tostring(val)
            callback(val)
        else
            slider.Text = tostring(default)
        end
    end)

    return frame
end

-- TAB PANELS
local tabs = {}
local currentTab = nil

local function createTab(name, positionX)
    local frame = Instance.new("Frame", ScreenGui)
    frame.Size = UDim2.new(0, 400, 0, 400)
    frame.Position = UDim2.new(0, 120, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Visible = false
    tabs[name] = frame
    return frame
end

-- TAB BUTTONS
local tabNames = {"Main", "AimBot", "Player", "Skins", "Rage"}
local buttons = {}

for i, tabName in ipairs(tabNames) do
    local btn = createTabButton(tabName, 10 + (i-1)*35)
    btn.MouseButton1Click:Connect(function()
        if currentTab then currentTab.Visible = false end
        currentTab = tabs[tabName]
        currentTab.Visible = true
    end)
    buttons[tabName] = btn
end

-- Create tab frames
local MainTab = createTab("Main")
local AimBotTab = createTab("AimBot")
local PlayerTab = createTab("Player")
local SkinsTab = createTab("Skins")
local RageTab = createTab("Rage")

-- Initially show Main tab
currentTab = MainTab
MainTab.Visible = true

-- HELPER FUNCTIONS
local function getHumanoidRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

-- CIRCLE GUI FOR AIMBOT
local circle = Drawing and Drawing.new("Circle") or nil
if circle then
    circle.Visible = false
    circle.Color = Color3.fromRGB(255, 0, 230)
    circle.Thickness = 2
    circle.Radius = circleScale
    circle.Filled = false
end

-- ========== MAIN TAB ==========

-- ESP Toggle
local boxESPEnabled = false
local boxes = {}

local function createBox(character)
    -- Simplified: could add Drawing boxes here if you want
end

local ESPToggle = createToggle("ESP", MainTab, function(enabled)
    boxESPEnabled = enabled
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and getHumanoidRootPart(player.Character) then
                createBox(player.Character)
            end
        end
    else
        for _, box in pairs(boxes) do
            pcall(function() box:Remove() end)
        end
        boxes = {}
    end
end)

-- ========== AIMBOT TAB ==========

local AimbotToggle = createToggle("Aimbot", AimBotTab, function(enabled)
    aimbotEnabled = enabled
    circle.Visible = enabled and drawCircleEnabled
end)

local DrawCircleToggle = createToggle("Draw Aimbot Circle", AimBotTab, function(enabled)
    drawCircleEnabled = enabled
    if circle then
        circle.Visible = enabled and aimbotEnabled
    end
end)

local AimbotCircleSlider = createSlider("Aimbot Circle Size", AimBotTab, 5, 40, 5, function(val)
    circleScale = val * 10
    if circle then
        circle.Radius = circleScale
    end
end)

local HitboxSizeSlider = createSlider("Hitbox Size", AimBotTab, 1, 350, state.hitboxSize, function(val)
    state.hitboxSize = val
    if bigHitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    head.Size = Vector3.new(val, val, val)
                end
            end
        end
    end
end)

local BigHitboxToggle = createToggle("Big Hitbox", AimBotTab, function(enabled)
    bigHitboxEnabled = enabled
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    originalHeadSizes[player.Character] = head.Size
                    head.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
                end
            end
        end
    else
        for char, size in pairs(originalHeadSizes) do
            local head = char:FindFirstChild("Head")
            if head then
                head.Size = size
            end
        end
        originalHeadSizes = {}
    end
end)

-- ========== PLAYER TAB ==========

local flySpeedSlider = createSlider("Fly Speed", PlayerTab, 0, 150, flySpeed, function(val)
    flySpeed = val
    if bodyVelocity then
        bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
    end
end)

local SpinBotToggle = createToggle("SpinBot", PlayerTab, function(enabled)
    spinBotEnabled = enabled
    local hrp = getHumanoidRootPart(LP.Character)
    if not hrp then return end
    if enabled then
        spinBotConnection = RunService.Stepped:Connect(function()
            if spinBotEnabled then
                hrp.RotVelocity = Vector3.new(0, 150, 0)
            end
        end)
    else
        if spinBotConnection then
            pcall(function() spinBotConnection:Disconnect() end)
            spinBotConnection = nil
        end
        if hrp then hrp.RotVelocity = Vector3.zero end
    end
end)

local SpeedHackToggle = createToggle("Speed Hack", PlayerTab, function(enabled)
    state.speed = enabled
    local Hum = getHumanoid(LP.Character)
    if Hum then
        Hum.WalkSpeed = enabled and state.walk or 16
    end
end)

local SpeedSlider = createSlider("Speed", PlayerTab, 20, 150, state.walk, function(val)
    state.walk = val
    if state.speed then
        local Hum = getHumanoid(LP.Character)
        if Hum then
            Hum.WalkSpeed = val
        end
    end
end)

local FlyToggle = createToggle("Fly", PlayerTab, function(enabled)
    flyEnabled = enabled
    local hrp = getHumanoidRootPart(LP.Character)
    if not hrp then return end

    if enabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.P = 1e4
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp

        flyConnection = RunService.Stepped:Connect(function()
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir += camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir -= camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir -= camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir += camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir -= Vector3.new(0, 1, 0)
            end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * flySpeed
            end
            if bodyVelocity then
                bodyVelocity.Velocity = moveDir
            end
        end)
    else
        if flyConnection then
            pcall(function() flyConnection:Disconnect() end)
            flyConnection = nil
        end
        if bodyVelocity then
            pcall(function() bodyVelocity:Destroy() end)
            bodyVelocity = nil
        end
    end
end)

local BunnyHopToggle = createToggle("Bunny Hop", PlayerTab, function(enabled)
    bunnyHopEnabled = enabled
    local Hum = getHumanoid(LP.Character)
    if enabled then
        bunnyHopConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.Space and Hum and Hum.FloorMaterial ~= Enum.Material.Air then
                Hum.Jump = true
            end
        end)
    else
        if bunnyHopConnection then
            pcall(function() bunnyHopConnection:Disconnect() end)
            bunnyHopConnection = nil
        end
    end
end)

local SavePosBtn = Instance.new("TextButton", PlayerTab)
SavePosBtn.Size = UDim2.new(1, -20, 0, 30)
SavePosBtn.Position = UDim2.new(0, 10, 0, 350)
SavePosBtn.Text = "Save Position"
SavePosBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
SavePosBtn.TextColor3 = Color3.new(1,1,1)
SavePosBtn.MouseButton1Click:Connect(function()
    local hrp = getHumanoidRootPart(LP.Character)
    if hrp then
        savedPosition = hrp.Position
        print("Position saved:", savedPosition)
    end
end)

local TeleportBtn = Instance.new("TextButton", PlayerTab)
TeleportBtn.Size = UDim2.new(1, -20, 0, 30)
TeleportBtn.Position = UDim2.new(0, 10, 0, 390)
TeleportBtn.Text = "Teleport to Saved"
TeleportBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
TeleportBtn.TextColor3 = Color3.new(1,1,1)
TeleportBtn.MouseButton1Click:Connect(function()
    local hrp = getHumanoidRootPart(LP.Character)
    if hrp and savedPosition then
        hrp.CFrame = CFrame.new(savedPosition)
        print("Teleported to saved position.")
    end
end)

-- ========== SKINS TAB ==========

local RainbowHandsToggle = createToggle("Rainbow Hands", SkinsTab, function(enabled)
    local colors = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(148, 0, 211)
    }
    local colorIndex = 1
    local nextTick = 0

    if enabled then
        rainbowHandsConnection = RunService.Heartbeat:Connect(function()
            if tick() >= nextTick then
                local arms = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms")
                if arms then
                    local leftArm = arms:FindFirstChild("Left Arm")
                    local rightArm = arms:FindFirstChild("Right Arm")
                    if leftArm and rightArm then
                        colorIndex = (colorIndex % #colors) + 1
                        leftArm.Color = colors[colorIndex]
                        rightArm.Color = colors[colorIndex]
                    end
                end
                nextTick = tick() + colorChangeSpeed
            end
        end)
    else
        if rainbowHandsConnection then
            pcall(function() rainbowHandsConnection:Disconnect() end)
            rainbowHandsConnection = nil
        end
        local arms = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms")
        if arms then
            local leftArm = arms:FindFirstChild("Left Arm")
            local rightArm = arms:FindFirstChild("Right Arm")
            if leftArm and rightArm then
                leftArm.Color = Color3.new(1,1,1)
                rightArm.Color = Color3.new(1,1,1)
            end
        end
    end
end)

local ColorChangeSpeedSlider = createSlider("Color Change Speed", SkinsTab, 0.1, 2, colorChangeSpeed, function(val)
    colorChangeSpeed = val
end)

-- ========== RAGE TAB ==========

local InfiniteAmmoToggle = createToggle("Infinite Ammo", RageTab, function(enabled)
    state.infiniteAmmo = enabled
    if enabled then
        conns = conns or {}
        conns.ammo = RunService.Stepped:Connect(function()
            local wep = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if wep and wep:FindFirstChild("Ammo") then
                wep.Ammo.Value = 999
            end
        end)
    else
        if conns and conns.ammo then
            conns.ammo:Disconnect()
            conns.ammo = nil
        end
    end
end)

-- ========== AIMBOT LOGIC ==========

local function onTargetDied()
    aimbotTarget = nil
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotEnabled then
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mouseLocation = UserInputService:GetMouseLocation()

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and getHumanoidRootPart(player.Character) then
                local screenPos, onScreen = camera:WorldToViewportPoint(getHumanoidRootPart(player.Character).Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                    if dist < circle.Radius and dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end

        aimbotTarget = closestPlayer
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimbotTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and aimbotTarget and aimbotTarget.Character and getHumanoidRootPart(aimbotTarget.Character) then
        local targetPos = getHumanoidRootPart(aimbotTarget.Character).Position
        local cameraPos = camera.CFrame.Position
        local direction = (targetPos - cameraPos).Unit
        camera.CFrame = CFrame.new(cameraPos, targetPos)
    end

    if circle and drawCircleEnabled and aimbotEnabled then
        local mouseLoc = UserInputService:GetMouseLocation()
        circle.Position = Vector2.new(mouseLoc.X, mouseLoc.Y + 36)
        circle.Radius = circleScale
        circle.Visible = true
    else
        if circle then
            circle.Visible = false
        end
    end
end)

-- Cleanup on character death
LP.CharacterAdded:Connect(function(char)
    aimbotTarget = nil
    if bigHitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    originalHeadSizes[player.Character] = head.Size
                    head.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
                end
            end
        end
    end
end)

print("Custom cheat GUI loaded!")
