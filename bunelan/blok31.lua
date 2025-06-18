if game.PlaceId ~= 79393329652220 then return end -- Defusal FPS place ID check

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

-- State Variables
local state = {
    boxESPEnabled = false,
    healthESPEnabled = false,
    aimbotEnabled = false,
    drawCircleEnabled = false,
    circleScale = 50,
    spinBotEnabled = false,
    speedHackEnabled = false,
    flyEnabled = false,
    bunnyHopEnabled = false,
    bigHitboxEnabled = false,
    rainbowHandsEnabled = false,
    infiniteAmmo = false,
    walkSpeed = 60,
    normalSpeed = 16,
    hitboxSize = 5,
    flySpeed = 60,
    colorChangeSpeed = 0.1,
    savedPosition = nil
}
local boxes = {}
local originalHeadSizes = {}
local connections = {}
local bodyVelocity = nil
local aimbotTarget = nil
local circle = Drawing.new("Circle")
circle.Visible = false
circle.Color = Color3.fromRGB(255, 0, 230)
circle.Thickness = 2
circle.Radius = state.circleScale
circle.Filled = false

-- UI Creation
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LCX_CheatUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "LCX Team | Defusal FPS"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
    ScrollingFrame.Position = UDim2.new(0, 5, 0, 45)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 5
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    ScrollingFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollingFrame

    local function createSection(name)
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Size = UDim2.new(1, 0, 0, 30)
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.Parent = ScrollingFrame

        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Text = name
        SectionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        SectionLabel.TextSize = 16
        SectionLabel.Font = Enum.Font.Gotham
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        SectionLabel.Parent = SectionFrame

        return SectionFrame
    end

    local function createToggle(name, callback, default)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = ScrollingFrame

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 14
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(0.8, 0, 0.5, -10)
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 5)
        UICorner.Parent = ToggleButton

        ToggleButton.MouseButton1Click:Connect(function()
            local newValue = not default
            default = newValue
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = newValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            }):Play()
            callback(newValue)
        end)

        return ToggleFrame
    end

    local function createSlider(name, min, max, increment, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = ScrollingFrame

        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = name .. ": " .. default
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 14
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame

        local SliderBar = Instance.new("Frame")
        SliderBar.Size = UDim2.new(1, -20, 0, 10)
        SliderBar.Position = UDim2.new(0, 10, 0, 30)
        SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SliderBar.Parent = SliderFrame

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 5)
        UICorner.Parent = SliderBar

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        Fill.Parent = SliderBar

        local UICornerFill = Instance.new("UICorner")
        UICornerFill.CornerRadius = UDim.new(0, 5)
        UICornerFill.Parent = Fill

        local SliderButton = Instance.new("TextButton")
        SliderButton.Size = UDim2.new(0, 20, 0, 20)
        SliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0, -5)
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.Text = ""
        SliderButton.Parent = SliderBar

        local UICornerButton = Instance.new("UICorner")
        UICornerButton.CornerRadius = UDim.new(0, 10)
        UICornerButton.Parent = SliderButton

        local dragging = false
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * relativeX
                value = math.floor(value / increment + 0.5) * increment
                Fill.Size = UDim2.new(relativeX, 0, 1, 0)
                SliderButton.Position = UDim2.new(relativeX, -10, 0, -5)
                SliderLabel.Text = name .. ": " .. value
                callback(value)
            end
        end)

        return SliderFrame
    end

    local function createButton(name, callback)
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.Parent = ScrollingFrame

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -20, 1, 0)
        Button.Position = UDim2.new(0, 10, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.Font = Enum.Font.Gotham
        Button.Parent = ButtonFrame

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 5)
        UICorner.Parent = Button

        Button.MouseButton1Click:Connect(callback)

        return ButtonFrame
    end

    -- UI Sections and Controls
    createSection("ESP")
    createToggle("Box ESP", function(v)
        state.boxESPEnabled = v
        if v then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    createBox(player.Character)
                end
            end
        else
            for _, box in ipairs(boxes) do
                pcall(function() box:Remove() end)
            end
            boxes = {}
        end
    end, state.boxESPEnabled)

    createSection("Debug")
    createToggle("Aimbot", function(v) state.debugaimbotEnabled = false end, state.debugaimbotEnabled = v)
    createToggle("Draw Aimbot", function(v)
        state.drawCircleEnabled = v
        circle.Visible = v
    end, state.drawCircleEnabled)
    createSlider("Aimbot Circle Size", 5, 40, 1, state.circleScale / 10, function(v)
        state.circleScale = v * 10
        circle.Radius = state.circleScale
    end)
    createSlider("Hitbox Size", 1, 30, 1, state.hitboxSize, function(v)
        state.hitboxSize = v
        if state.bigHitboxEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        head.Size = Vector3.new(v, v, v)
                    end
                end
            end
        end
    end)
    createToggle("Big Hitbox", function(v)
        state.bigHitboxEnabled = v
        if v then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        originalHeadSizes[player.Character] = head.Size
                        head.Size = Vector3.new(state.sizehitboxSize, v)
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
            end
            originalHeadSizes = {}
        end
    end, state.bigHitboxEnabled)

    createSection("Player")
    createToggle("Fly", function(v)
        state.flyEnabled = v
        if not hrp then return end
        if v then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVelocity.P = 1e4
            bodyVelocity.Velocity = Vector3.zero
            bodyVelocity.Parent = hrp
            connections["Fly"] = RunService.Stepped:Connect(function()
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
                    moveDir = moveDir.Unit * state.flySpeed
                end
                bodyVelocity.Velocity = moveDir
            end)
        else
            if connections.Fly then
                connections.Fly:Disconnect()
                connections.Fly = nil
            end
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
        end
    end, state.flyEnabled)
    createSlider("Fly Speed", 0, 150, 5, state.flySpeed, function(v)
        state.flySpeed = v
        if bodyVelocity then
            bodyVelocity.Velocity = Vector3.new(0, v, 0)
        end
    end
    createToggle("Speed Hack", function(v)
        state.speedHackEnabled = v
        if Hum then
            Hum.WalkSpeed = v and state.walkSpeed or state.normalSpeed
        end
    end, state.speedHackEnabled)
    createSlider("Speed", 20, 150, 2, state.walkSpeed, function(v)
        state.walkSpeed = v
        if state.speedHackEnabled and Hum then
            Hum.WalkSpeed = v
        end
    end)
    createToggle("SpinBot", function(v)
        state.spinBotEnabled = v
        if not hrp then return end
        if v then
            connections.SpinBot = RunService.Stepped:Connect(function()
                if state.spinBotEnabled then
                    hrp.RotVelocity = Vector3.new(0, 100, 0)
                end
            end)
        ) else
            if connections.SpinBot then
                connections.SpinBot:Disconnect()
                connections.SpinBot = nil
            end
            hrp.RotVelocity = Vector3.zero
        end
    end, state.spinBotEnabled)
    createToggle("Bunny Hop", function(v)
        state.bunnyHopEnabled = v
        if v then
            connections.BunnyHop = UserInputService.InputBegan:Connect(function(input, gameProcessed))
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.Space then
                    if Hum and Hum.FloorMaterial ~= Enum.Material.Air then
                        Hum.Jump = true
                    end
                end
            end)
        else
            if connections.BunnyHop then
                connections.BunnyHop:Disconnect()
                connections.SunnyHop = nil
            end
        end
    end, state.bunnyHopEnabled)
    createButton("Save Position", function()
        if hrp then state.savedPosition = hrp.Position end
    end)
    createButton("Teleport to Saved", function()
        if hrp and state.savedPosition then
            hrp.CFrame = CFrame.new(state.savedPosition)
        end
    createSection("Rage")
    createToggle("Tp to Me", function(v)
        if v then
            connections.TpToMe = RunService.Heartbeat:Connect(function()
                if not hrp then return end
                local localPos = hrp.Position
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if targetPlayer ~= LP and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        targetPlayer.Character.HumanoidRootPart.Position = CFrame.new(localPos)
                    end
                end
            end)
        else
            if connections.TpToMe then
                connections.TpToMe:Disconnect()
                connections.TpToMe = nil
            end
        end, false)
    createToggle("Infinite Ammo", function(v)
        state.infiniteAmmo = v
        if v then
            connections.Ammo = RunService.Stepped:Connect(function()
                local wep = LP.Character:FindFirstChildOfClass("Tool")
                if wep and wep:FindFirstChild("Ammo") then
                    wep.Ammo.Value = 999
                end
            end)
        else
            if connections.Ammo then
                connections.Ammo:Disconnect()
                connections.Ammo = nil
            end
        end
    end, state.infiniteAmmo)

    createSection("Skins")
    createToggle("Rainbow Hands", function(v)
        state.rainbowHandsEnabled = v
        local colors = {
            Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130),
            Color3.fromRGB(148, 0, 211)
        }
        local colorIndex = 1
        local nextTick = 0
        if v then
            connections.RainbowHands = RunService.Heartbeat:Connect(function()
                if state.rainbowHandsEnabled and tick() >= nextTick then
                    local arms = workspace.Camera:FindFirstChild("Arms") and arms:FindFirstChild("CSSArms")
                    if arms then
                        local leftArm = arms:FindFirstChildLeft Arm")
                        local rightArm = arms:FindFirstChild("Right Arm")
                        if leftArm and rightArm then
                            colorIndex = (colorIndex % #colors) + 1
                            leftArm.Color = colors[colorIndex]
                            rightArm.Color = colors[colorIndex]
                        end
                    end
                    nextTick = tick() + state.colorChangeSpeed
                end
            end)
        else
            if connections.RainbowHands then
                connections.RainbowHands:Disconnect()
                connections.RainbowHands = nil
            end
            local arms = workspace.Camera:FindFirstChild("Arms") and arms:FindFirstChild("CSSArms")
            if arms then
                local leftArm = arms:FindFirstChild("Left Arm")
                local rightArm = arms:FindFirstChild("Right Arm")
                if leftArm and rightArm then
                    leftArm.Color = Color3.new(1, 1, 1)
                    rightArm.Color = Color3.new(1, 1, 1)
                end
            end
        end
    end, state.rainbowHandsEnabled)
    createSlider("Color Change Speed", 0.1, 2, 0.1, state.colorChangeSpeed, function(v)
        state.colorChangeSpeed = v
    end)

    -- Toggle UI with Insert Key
    UserInputService.InputBegan:Connect(function(input, gameProcessed))
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundTransparency = MainFrame.Visible and 0 or 0.5
            }):Play()
        end
    end)

    return ScreenGui
end

-- ESP Logic
local function createBox(character)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 1
    box.Filled = false
    box.Character = character

    local function updateBox()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local vector, onScreen = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
            if onScreen then
                local size = 2000 / vector.Z
                box.Size = Vector2.new(size, size)
                box.Position = Vector2.new(vector.X - size / 2, vector.Y - size / 2)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end

    connections["Box_" .. tostring(character)] = RunService.RenderStepped:Connect(updateBox)
    table.insert(boxes, box)
end

local function removeBox(character)
    for i = #boxes, 1, -1 do
        if boxes[i].Character == character then
            boxes[i]:Remove()
            table.remove(boxes, i)
            if connections["Box_" .. tostring(character)] then
                connections["Box_" .. tostring(character)]:Disconnect()
                connections["Box_" .. tostring(character)] = nil
            end
        end
    end
end

local function onPlayerAdded(player)
    if player == LP then return end
    local character = player.Character or player.CharacterAdded:Wait()
    if state.boxESPEnabled then createBox(character) end
    if state.bigHitboxEnabled then
        local head = character:FindFirstChild("Head")
        if head then
            originalHeadSizes[character] = head.Size
            head.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
        end
    end

    player.CharacterAdded:Connect(function(newCharacter)
        if state.boxESPEnabled then createBox(newCharacter) end
        if state.bigHitboxEnabled then
            local head = newCharacter:FindFirstChild("Head")
            if head then
                originalHeadSizes[newCharacter] = head.Size
                head.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
            end
        end
    end)
end

local function onPlayerRemoving(player)
    if player.Character then
        removeBox(player.Character)
        if state.bigHitboxEnabled and originalHeadSizes[player.Character] then
            local head = player.Character:FindFirstChild("Head")
            if head then
                head.Size = originalHeadSizes[player.Character]
            end
            originalHeadSizes[player.Character] = nil
        end
    end
end

-- Aimbot Logic
local function onTargetDied() aimbotTarget = nil end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and state.aimbotEnabled then
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mouseLocation = UserInputService:GetMouseLocation()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local screenPos, onScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                    if distance < circle.Radius and distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        if closestPlayer then
            aimbotTarget = closestPlayer.Character:FindFirstChild("Head")
            if aimbotTarget then
                closestPlayer.Character.Humanoid.Died:Connect(onTargetDied)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aimbotTarget = nil end
end)

RunService.RenderStepped:Connect(function()
    if aimbotTarget and aimbotTarget.Parent and aimbotTarget.Parent:FindFirstChild("Humanoid") and aimbotTarget.Parent.Humanoid.Health > 0 then
        local screenPos, onScreen = camera:WorldToViewportPoint(aimbotTarget.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).Magnitude
            if distance < circle.Radius then
                camera.CFrame = CFrame.new(camera.CFrame.Position, aimbotTarget.Position)
            else
                aimbotTarget = nil
            end
        else
            aimbotTarget = nil
        end
    end
    if state.drawCircleEnabled then
        circle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    end
end)

-- Character Update Handling
LP.CharacterAdded:Connect(function(character)
    Hum = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
    for key, conn in pairs(connections) do
        if key:find("SpinBot") or key:find("Fly") or key:find("BunnyHop") or key:find("RainbowHands") or key:find("TpToMe") or key:find("Ammo") then
            pcall(function() conn:Disconnect() end)
            connections[key] = nil
        end
    end
    if bodyVelocity then
        pcall(function() bodyVelocity:Destroy() end)
        bodyVelocity = nil
    end
    if state.flyEnabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.P = 1e4
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = hrp
    end
    if state.speedHackEnabled and Hum then
        Hum.WalkSpeed = state.walkSpeed
    end
end)

-- Initialize
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LP then onPlayerAdded(player) end
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

createUI()
