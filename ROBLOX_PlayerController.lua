-- =====================================================
-- ROBLOX EGG FOOTBALL - PLAYER CONTROLLER
-- Arquivo: StarterPlayer > StarterPlayerScripts > PlayerController
-- =====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Variáveis de movimento
local moveDirection = Vector3.new(0, 0, 0)
local moveSpeed = 25
local isMoving = false

-- Função para criar o ovo do jogador
local function createEgg()
    local egg = Instance.new("Part")
    egg.Name = "EggCharacter"
    egg.Shape = Enum.PartType.Ball
    egg.Size = Vector3.new(1.5, 1.5, 1.5)
    egg.Color = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
    egg.TopSurface = Enum.SurfaceType.Smooth
    egg.BottomSurface = Enum.SurfaceType.Smooth
    egg.CanCollide = true
    egg.Parent = workspace
    
    -- Adicionar brilho
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 1
    pointLight.Range = 15
    pointLight.Parent = egg
    
    return egg
end

-- Função para mover o ovo
local function moveEgg(eggPart, direction)
    if eggPart then
        local humanoid = eggPart:FindFirstChild("Humanoid")
        if not humanoid then
            humanoid = Instance.new("Humanoid")
            humanoid.Parent = eggPart
        end
        
        -- Aplicar velocidade ao ovo
        if eggPart:FindFirstChild("BodyVelocity") then
            eggPart:FindFirstChild("BodyVelocity"):Destroy()
        end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = direction * moveSpeed
        bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
        bodyVelocity.Parent = eggPart
        game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
    end
end

-- Controle de entrada (WASD)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        moveDirection = moveDirection + Vector3.new(0, 0, -1)
        isMoving = true
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirection = moveDirection + Vector3.new(-1, 0, 0)
        isMoving = true
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirection = moveDirection + Vector3.new(0, 0, 1)
        isMoving = true
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirection = moveDirection + Vector3.new(1, 0, 0)
        isMoving = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then
        moveDirection = moveDirection - Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirection = moveDirection - Vector3.new(-1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirection = moveDirection - Vector3.new(0, 0, 1)
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirection = moveDirection - Vector3.new(1, 0, 0)
    end
    
    if moveDirection.Magnitude == 0 then
        isMoving = false
    end
end)

-- Cliques do rato para chutar e passar
local mouse = player:GetMouse()

mouse.Button1Down:Connect(function()
    -- CHUTAR (botão esquerdo)
    local eggPart = character:FindFirstChild("EggCharacter") or humanoidRootPart
    print("CHUTAR!")
end)

mouse.Button2Down:Connect(function()
    -- PASSAR (botão direito)
    local eggPart = character:FindFirstChild("EggCharacter") or humanoidRootPart
    print("PASSAR!")
end)

-- Loop para atualizar movimento
RunService.RenderStepped:Connect(function()
    local eggPart = character:FindFirstChild("EggCharacter")
    if eggPart then
        if moveDirection.Magnitude > 0 then
            moveEgg(eggPart, moveDirection.Unit)
        end
    end
end)

print("PlayerController carregado!")
