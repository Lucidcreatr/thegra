-- 📌 GUI Oluştur
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()

local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "GrowGardenGUI"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 50, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local uiList = Instance.new("UIListLayout", mainFrame)
uiList.Padding = UDim.new(0, 5)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.SortOrder = Enum.SortOrder.LayoutOrder

-- 🔘 Buton oluşturucu
function createButton(text, callback)
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	btn.MouseButton1Click:Connect(callback)
end

-- 🕊️ FLY
local flying = false
createButton("🕊️ FLY AÇ/KAPA", function()
	flying = not flying
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	local bp = Instance.new("BodyPosition", root)
	local bg = Instance.new("BodyGyro", root)
	bp.MaxForce = Vector3.new(400000, 400000, 400000)
	bg.MaxTorque = Vector3.new(400000, 400000, 400000)

	while flying do
		task.wait()
		bp.Position = root.Position + (workspace.CurrentCamera.CFrame.LookVector * 5)
		bg.CFrame = workspace.CurrentCamera.CFrame
	end

	bp:Destroy()
	bg:Destroy()
end)

-- ⚡ SPEED
createButton("⚡ SPEED x3", function()
	char:FindFirstChildOfClass("Humanoid").WalkSpeed = 48
end)

-- 🚀 JUMP POWER
createButton("🚀 Zıplama Gücü x2", function()
	char:FindFirstChildOfClass("Humanoid").JumpPower = 150
end)

-- 🌱 TOHUM AL
createButton("🌱 Seed: Wheat Al", function()
	game.ReplicatedStorage.Events.FarmEvent:FireServer("Plant", "Wheat")
end)

-- 🐾 PET AL
createButton("🐾 Pet: Dog Al", function()
	game.ReplicatedStorage.Events.GivePet:FireServer("Dog")
end)

-- 🔁 DUPE
createButton("🔁 DUPE ITEM (Wheat)", function()
	for i = 1, 5 do
		game.ReplicatedStorage.Events.DupeEvent:FireServer("Wheat")
		wait(0.1)
	end
end)

-- 🎁 AUTO COLLECT
local autoCollect = false
createButton("🎁 Auto Collect AÇ/KAPA", function()
	autoCollect = not autoCollect
	while autoCollect do
		task.wait(0.5)
		for _, drop in pairs(workspace.Drops:GetChildren()) do
			if drop:IsA("Part") then
				drop.CFrame = char.HumanoidRootPart.CFrame
			end
		end
	end
end)

-- 🌾 AUTOFARM
local autoFarm = false
createButton("🌾 AutoFarm AÇ/KAPA", function()
	autoFarm = not autoFarm
	while autoFarm do
		task.wait(1)
		game.ReplicatedStorage.Events.FarmEvent:FireServer("Plant", "Wheat")
	end
end)

-- 🧲 Magnet
createButton("🧲 Magnet Aktif Et", function()
	for _, v in pairs(workspace.Drops:GetChildren()) do
		if v:IsA("Part") then
			v.CFrame = player.Character.HumanoidRootPart.CFrame
		end
	end
end)
