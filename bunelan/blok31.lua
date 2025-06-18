-- Defusal FPS GUI + Özellikler (Rayfield olmadan)
if game.PlaceId == 79393329652220 then
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LP = Players.LocalPlayer
    local PlayerGui = LP:WaitForChild("PlayerGui")
    local camera = workspace.CurrentCamera

    local gui = Instance.new("ScreenGui")
    gui.Name = "LCX_GUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local function createTab(name, position)
        local frame = Instance.new("Frame")
        frame.Name = name .. "Tab"
        frame.Size = UDim2.new(0, 200, 0, 300)
        frame.Position = position
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.Parent = gui

        local title = Instance.new("TextLabel")
        title.Text = name
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 20
        title.Parent = frame

        return frame
    end

    local function createButton(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 30)
        button.Position = UDim2.new(0, 10, 0, 40 + #parent:GetChildren() * 35)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 16
        button.Text = text
        button.AutoButtonColor = true
        button.Parent = parent
        button.MouseButton1Click:Connect(callback)
        return button
    end

    local espTab = createTab("ESP", UDim2.new(0, 0, 0, 50))
    local aimTab = createTab("Aimbot", UDim2.new(0, 210, 0, 50))
    local playerTab = createTab("Player", UDim2.new(0, 420, 0, 50))
    local rageTab = createTab("Rage", UDim2.new(0, 630, 0, 50))
    local skinsTab = createTab("Skins", UDim2.new(0, 840, 0, 50))

    -- Durumlar
    local espEnabled = false
    local aimbotEnabled = false
    local aimbotTarget = nil
    local flyEnabled = false
    local bodyVelocity = nil
    local flyConnection = nil
    local speedHack = false
    local infiniteAmmo = false
    local rainbowHands = false
    local conns = {}

    -- ESP kutuları (Drawing API)
    local boxes = {}
    local function createESPBox(char)
        local box = Drawing.new("Square")
        box.Color = Color3.new(1,0,0)
        box.Thickness = 2
        box.Filled = false
        box.Visible = true
        local rsConn = RunService.RenderStepped:Connect(function()
            if char and char:FindFirstChild("HumanoidRootPart") then
                local vec, onscreen = camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                if onscreen then
                    local size = 2000 / vec.Z
                    box.Size = Vector2.new(size, size)
                    box.Position = Vector2.new(vec.X - size/2, vec.Y - size/2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end)
        table.insert(boxes, {box = box, conn = rsConn})
    end

    local function removeAllBoxes()
        for _, b in pairs(boxes) do
            b.box:Remove()
            b.conn:Disconnect()
        end
        boxes = {}
    end

    createButton(espTab, "ESP Aç/Kapat", function()
        espEnabled = not espEnabled
        print("ESP:", espEnabled)
        if espEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    createESPBox(plr.Character)
                end
            end
        else
            removeAllBoxes()
        end
    end)

    createButton(aimTab, "Aimbot Aç/Kapat", function()
        aimbotEnabled = not aimbotEnabled
        print("Aimbot:", aimbotEnabled)
    end)

    createButton(playerTab, "Fly Aç/Kapat", function()
        flyEnabled = not flyEnabled
        print("Fly:", flyEnabled)
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if flyEnabled and hrp then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVelocity.P = 1e4
            bodyVelocity.Velocity = Vector3.zero
            bodyVelocity.Parent = hrp

            flyConnection = RunService.Stepped:Connect(function()
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
                bodyVelocity.Velocity = move.Unit * 50
            end)
        else
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        end
    end)

    createButton(playerTab, "SpeedHack Aç/Kapat", function()
        speedHack = not speedHack
        print("SpeedHack:", speedHack)
        local humanoid = LP.Character and LP.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedHack and 80 or 16
        end
    end)

    createButton(rageTab, "Infinite Ammo Aç/Kapat", function()
        infiniteAmmo = not infiniteAmmo
        print("Infinite Ammo:", infiniteAmmo)
        if infiniteAmmo then
            conns.ammo = RunService.Stepped:Connect(function()
                local wep = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                if wep and wep:FindFirstChild("Ammo") then
                    wep.Ammo.Value = 999
                end
            end)
        else
            if conns.ammo then conns.ammo:Disconnect() conns.ammo = nil end
        end
    end)

    createButton(skinsTab, "Rainbow Hands Aç/Kapat", function()
        rainbowHands = not rainbowHands
        print("Rainbow Hands:", rainbowHands)
        local colors = {
            Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130),
            Color3.fromRGB(148, 0, 211)
        }
        local index = 1
        if rainbowHands then
            conns.hands = RunService.Heartbeat:Connect(function()
                local arms = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms")
                if arms then
                    local left = arms:FindFirstChild("Left Arm")
                    local right = arms:FindFirstChild("Right Arm")
                    if left and right then
                        left.Color = colors[index]
                        right.Color = colors[index]
                        index = (index % #colors) + 1
                    end
                end
            end)
        else
            if conns.hands then conns.hands:Disconnect() conns.hands = nil end
        end
    end)

    -- Aimbot logic
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotEnabled then
            local closest, dist = nil, math.huge
            local mousePos = UserInputService:GetMouseLocation()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Head") then
                    local screenPos, onScreen = camera:WorldToViewportPoint(plr.Chara
