-- 💣 PASS The bomb @Find_Nulla1 

local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- *** FLOAT CONFIG ***
local ALTURA_LIMITE = 99999
local lerpSpeed = 1
local platform = Instance.new("Part")
platform.Name = "FloatPlatform"
platform.Size = Vector3.new(6, 1, 6)
platform.Transparency = 0.8
platform.Anchored = true
platform.CanCollide = true
platform.Parent = workspace
platform.Position = Vector3.new(0, -5000, 0)

-- *** FUNÇÃO CREATE ***
local function Create(class, parent, props)
    local new = Instance.new(class)
    for k, v in pairs(props) do new[k] = v end
    new.Parent = parent
    return new
end

-- Criar a ScreenGui
local gui = Create("ScreenGui", player:WaitForChild("PlayerGui"), {Name = "Pass The bomb"})

-- Frame principal (220px 4 BOTÕES!)
local frame = Create("Frame", gui, {
    Size = UDim2.new(0, 220, 0, 220),
    Position = UDim2.new(0, 30, 0, 300),
    BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
    BorderSizePixel = 2,
    BorderColor3 = Color3.new(1, 0, 0),
    Active = true,
    Draggable = true
})

-- Título GRANDE VERMELHO
Create("TextLabel", frame, {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 0),
    Text = "💣Pass The bomb",
    TextColor3 = Color3.new(1, 1, 1),
    BackgroundColor3 = Color3.new(1, 0, 0),
    Font = Enum.Font.SourceSansBold,
    TextSize = 20
})

-- *** 4 BOTÕES ORGANIZADOS! ***
local espBombButton = Create("TextButton", frame, {
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, 50),
    Text = "🔴 ESP Bomba: OFF",
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.SourceSansBold,
    TextSize = 14
})

local espPlayerButton = Create("TextButton", frame, {
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, 85),
    Text = "🟢 ESP Player: OFF",
    BackgroundColor3 = Color3.fromRGB(50, 200, 50),
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.SourceSansBold,
    TextSize = 14
})

local auraButton = Create("TextButton", frame, {
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, 120),
    Text = "💥 AUTO Pass: OFF",
    BackgroundColor3 = Color3.new(1, 0, 0),
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.SourceSansBold,
    TextSize = 14
})

local floatButton = Create("TextButton", frame, {
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, 155),
    Text = "🟦 Float: OFF",
    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.SourceSansBold,
    TextSize = 14
})

-- *** VARIÁVEIS ***
local espBombActive = false
local espPlayerActive = false
local autoMode = false
local floating = false
local cooldownActive = false
local originalPos = nil
local targetHistory = {}
local dashHistory = {}
local espObjects = {}
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- *** ESP FUNCTIONS ***
local function createESP(part, color, espType)
    local name = espType .. "_" .. part.Parent.Name .. "_" .. part.Name
    if espObjects[name] then espObjects[name]:Destroy() end
    
    local billboard = Create("BillboardGui", gui, {
        Name = name,
        Adornee = part,
        Size = UDim2.new(0, 13, 0, 13),
        StudsOffset = Vector3.new(0, 0, 0),
        AlwaysOnTop = true
    })
    
    local boxFrame = Create("Frame", billboard, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    })
    
    Create("UICorner", boxFrame, {CornerRadius = UDim.new(0, 0)})
    espObjects[name] = billboard
end

local function clearBombESP()
    for name, esp in pairs(espObjects) do
        if string.find(name, "bomb_") then
            esp:Destroy()
            espObjects[name] = nil
        end
    end
end

local function clearPlayerESP()
    for name, esp in pairs(espObjects) do
        if string.find(name, "player_") then
            esp:Destroy()
            espObjects[name] = nil
        end
    end
end

-- *** ALTURA EM RELAÇÃO AO CHÃO ***
local function alturaEmRelacaoAoChao()
    local ray = Ray.new(root.Position, Vector3.new(0, -500, 0))
    local hit, pos = Workspace:FindPartOnRay(ray, char)
    if hit then
        return (root.Position.Y - pos.Y)
    else
        return 0
    end
end

-- *** EVENTOS BOTÕES ***
espBombButton.MouseButton1Click:Connect(function()
    espBombActive = not espBombActive
    espBombButton.Text = "🔴 ESP Bomba: " .. (espBombActive and "ON" or "OFF")
    espBombButton.BackgroundColor3 = espBombActive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 50, 50)
    if not espBombActive then clearBombESP() end
end)

espPlayerButton.MouseButton1Click:Connect(function()
    espPlayerActive = not espPlayerActive
    espPlayerButton.Text = "🟢 ESP Player: " .. (espPlayerActive and "ON" or "OFF")
    espPlayerButton.BackgroundColor3 = espPlayerActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(50, 200, 50)
    if not espPlayerActive then clearPlayerESP() end
end)

auraButton.MouseButton1Click:Connect(function()
    autoMode = not autoMode
    if autoMode then
        auraButton.Text = "💥 AUTO Pass: ON"
        auraButton.BackgroundColor3 = Color3.new(0, 1, 0)
        print("SHARK v26.0: AUTO PASS ON!")
    else
        auraButton.Text = "💥 AUTO Pass: OFF"
        auraButton.BackgroundColor3 = Color3.new(1, 0, 0)
        if originalPos then
            player.Character.HumanoidRootPart.CFrame = originalPos
            originalPos = nil
            print("SHARK v26.0: RETURN FORÇADO!")
        end
        print("SHARK v26.0: AUTO PASS OFF!")
    end
end)

floatButton.MouseButton1Click:Connect(function()
    if cooldownActive then return end
    cooldownActive = true
    
    if not floating then
        floating = true
        floatButton.Text = "🟦 Float: ON"
        floatButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        floating = false
        floatButton.Text = "🟦 Float: OFF"
        floatButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        platform.Position = Vector3.new(0, -5000, 0)
    end
    
    task.delay(0.5, function()
        cooldownActive = false
    end)
end)

-- *** LOOP ESP BOMBA ***
spawn(function()
    while wait(1) do
        if espBombActive then
            clearBombESP()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Bomb") then
                    createESP(p.Character.HumanoidRootPart, Color3.new(1, 0, 0), "bomb")
                    break
                end
            end
        end
    end
end)

-- *** LOOP ESP PLAYER ***
spawn(function()
    while wait(0.5) do
        if espPlayerActive then
            clearPlayerESP()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    createESP(p.Character.HumanoidRootPart, Color3.new(0, 1, 0), "player")
                end
            end
        end
    end
end)

-- *** FLOAT LOOP ***
RunService.Heartbeat:Connect(function()
    if floating and root and root.Parent then
        local alturaAtual = alturaEmRelacaoAoChao()
        if alturaAtual > ALTURA_LIMITE then
            floating = false
            floatButton.Text = "🟦 Float: OFF"
            floatButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            platform.Position = Vector3.new(0, -5000, 0)
        else
            local targetPos = root.Position - Vector3.new(0, 3.5, 0)
            platform.Position = platform.Position:Lerp(targetPos, lerpSpeed)
        end
    end
end)

-- *** RESPAWN FLOAT ***
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
end)

-- 🔥 AUTO PASS v26.0 = SEM MORTOS!
RunService.Heartbeat:Connect(function()
    if autoMode and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = player.Character.HumanoidRootPart
        local myBomb = player.Character:FindFirstChild("Bomb")
        
        if myBomb and not originalPos then
            originalPos = myRoot.CFrame
            print("SHARK v26.0: BOMBA DETECTADA!")
        end
        
        if myBomb and originalPos then
            local bestTarget = nil
            local bestScore = 0
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = p.Character:FindFirstChild("Humanoid")
                    -- ✅ IGNORA MORTOS/VIDA 0!
                    if humanoid and humanoid.Health > 0 then
                        local targetRoot = p.Character.HumanoidRootPart
                        local dist = (myRoot.Position - targetRoot.Position).Magnitude
                        
                        if dist < 300 then
                            local score = 0
                            local vel = targetRoot.Velocity
                            
                            if humanoid.Jump then score = score + 50 end
                            
                            if targetHistory[p.Name] then
                                local oldVel = targetHistory[p.Name]
                                local directionChange = (vel.Unit - oldVel.Unit).Magnitude
                                if directionChange > 1.5 then score = score + 60 end
                            end
                            targetHistory[p.Name] = vel
                            
                            if not dashHistory[p.Name] then dashHistory[p.Name] = 0 end
                            if vel.Magnitude > 30 then
                                dashHistory[p.Name] = dashHistory[p.Name] + 1
                                if dashHistory[p.Name] >= 9 then
                                    score = score + 75
                                    dashHistory[p.Name] = 0
                                end
                            else
                                dashHistory[p.Name] = 0
                            end
                            
                            if dist < 40 then score = score + 30 end
                            
                            if score > bestScore then
                                bestScore = score
                                bestTarget = p
                            end
                        end
                    end
                end
            end
            
            if bestTarget then
                local targetRoot = bestTarget.Character.HumanoidRootPart
                local handle = myBomb:FindFirstChild("Handle")
                
                if handle and handle:IsA("BasePart") then
                    local dashPos = targetRoot.Position
                    local vel = targetRoot.Velocity
                    if vel.Magnitude > 40 then dashPos = dashPos + vel * 0.5 end
                    
                    local windVelocity = vel * 0.4
                    local finalPos = dashPos + windVelocity
                    
                    handle.CFrame = CFrame.new(finalPos)
                    
                    task.spawn(function() firetouchinterest(targetRoot, handle, 0) end)
                    task.spawn(function() firetouchinterest(targetRoot, handle, 1) end)
                    
                    task.wait(0.1)
                    if not player.Character:FindFirstChild("Bomb") then
                        player.Character.HumanoidRootPart.CFrame = originalPos
                        autoMode = false
                        originalPos = nil
                        auraButton.Text = "💥 AUTO Pass: OFF"
                        auraButton.BackgroundColor3 = Color3.new(1, 0, 0)
                    end
                end
            end
        elseif not myBomb and originalPos then
            player.Character.HumanoidRootPart.CFrame = originalPos
            autoMode = false
            originalPos = nil
            auraButton.Text = "💥 AUTO Pass: OFF"
            auraButton.BackgroundColor3 = Color3.new(1, 0, 0)
        end
    end
end)

print("💣 SHARK v26.0 PASS SEM MORTOS + FLOAT CARREGADO!")
