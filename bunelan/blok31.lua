-- Defusal FPS GUI (JJSploit uyumlu sürüm - Drawing API ve gelişmiş özellikler çıkarıldı)
if game.PlaceId == 79393329652220 then
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LP = Players.LocalPlayer
    local PlayerGui = LP:WaitForChild("PlayerGui")

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
    local flyEnabled = false
    local bodyVelocity = nil
    local flyConnection = nil
    local speedHack = false
    local infiniteAmmo = false

    createButton(espTab, "ESP (Yalnızca Gelişmiş Exploit)", function()
        print("[UYARI] ESP çalışmaz: Drawing API desteklenmiyor (JJSploit)")
    end)

    createButton(aimTab, "Aimbot (Desteklenmez)", function()
        print("[UYARI] Aimbot çalışmaz: Kamera yönü değiştirme desteklenmiyor (JJSploit)")
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
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
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

    createButton(rageTab, "Infinite Ammo (Sadece bazı oyunlarda)", function()
        infiniteA
