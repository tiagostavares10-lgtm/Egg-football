-- =====================================================
-- ROBLOX EGG FOOTBALL - BALL PHYSICS
-- Arquivo: ServerScriptService > BallPhysics
-- =====================================================

local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

-- Criar a bola
local function createBall()
    local ball = Instance.new("Part")
    ball.Name = "Ball"
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(0.8, 0.8, 0.8)
    ball.Color = Color3.fromRGB(255, 255, 255)
    ball.Material = Enum.Material.SmoothPlastic
    ball.CanCollide = true
    ball.CFrame = CFrame.new(0, 5, 0)
    
    -- Adicionar física
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "BallVelocity"
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = ball
    
    ball.Parent = workspace
    return ball
end

-- Função para aplicar força à bola (chutar)
local function shootBall(ball, direction, force)
    local bodyVelocity = ball:FindFirstChild("BallVelocity")
    if bodyVelocity then
        bodyVelocity.Velocity = direction.Unit * force
    end
end

-- Função para aplicar força à bola (passar - menos força)
local function passBall(ball, direction, force)
    local bodyVelocity = ball:FindFirstChild("BallVelocity")
    if bodyVelocity then
        bodyVelocity.Velocity = direction.Unit * (force * 0.5)
    end
end

-- Criar bola no início
local ball = createBall()

-- Aplicar atrito e gravidade
RunService.Heartbeat:Connect(function()
    if ball and ball.Parent then
        local bodyVelocity = ball:FindFirstChild("BallVelocity")
        if bodyVelocity then
            -- Aplicar atrito
            bodyVelocity.Velocity = bodyVelocity.Velocity * 0.99
            
            -- Se velocidade for muito pequena, parar
            if bodyVelocity.Velocity.Magnitude < 0.1 then
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- Expor funções globais
_G.ShootBall = shootBall
_G.PassBall = passBall
_G.Ball = ball

print("BallPhysics carregado!")
