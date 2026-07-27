-- =====================================================
-- ROBLOX EGG FOOTBALL - MENU GUI
-- Arquivo: StarterPlayer > StarterPlayerGui > MenuGui (LocalScript)
-- =====================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Criar ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- =====================================================
-- MENU INICIAL
-- =====================================================

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(1, 0, 1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
menuFrame.BackgroundTransparency = 0.3
menuFrame.Parent = screenGui

-- Fundo com imagem do campo (simulado com cor degradada)
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- Verde do campo
background.BackgroundTransparency = 0
background.BorderSizePixel = 0
background.ZIndex = 1
background.Parent = menuFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.Position = UDim2.new(0, 0, 0.1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚽ EGG FOOTBALL ⚽"
titleLabel.TextSize = 80
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.ZIndex = 3
titleLabel.Parent = menuFrame

-- Subtítulo
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Size = UDim2.new(1, 0, 0.08, 0)
subtitleLabel.Position = UDim2.new(0, 0, 0.25, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Escolhe o modo de jogo"
subtitleLabel.TextSize = 32
subtitleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.ZIndex = 3
subtitleLabel.Parent = menuFrame

-- Função para criar botão
local function createButton(name, position, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.3, 0, 0.08, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(102, 126, 234)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextSize = 24
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.ZIndex = 3
    
    -- Efeito hover
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(150, 170, 255)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(102, 126, 234)
    end)
    
    button.MouseButton1Click:Connect(callback)
    button.Parent = menuFrame
    return button
end

-- Botões do menu inicial
local casualBtn = createButton("CasualBtn", UDim2.new(0.35, 0, 0.35, 0), "🎮 CASUAL", function()
    print("Casual selecionado!")
    showModeSelection("casual")
end)

local rankedBtn = createButton("RankedBtn", UDim2.new(0.35, 0, 0.45, 0), "🏆 RANQUEADA", function()
    print("Ranqueada selecionada!")
    showModeSelection("ranked")
end)

local trainingBtn = createButton("TrainingBtn", UDim2.new(0.35, 0, 0.55, 0), "🎯 TREINO", function()
    print("Treino selecionado!")
    showModeSelection("training")
end)

-- =====================================================
-- SELEÇÃO DE MODO (1v1, 2v2, etc)
-- =====================================================

local modeFrame = Instance.new("Frame")
modeFrame.Name = "ModeFrame"
modeFrame.Size = UDim2.new(1, 0, 1, 0)
modeFrame.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
modeFrame.BackgroundTransparency = 1
modeFrame.BorderSizePixel = 0
modeFrame.ZIndex = 2
modeFrame.Visible = false
modeFrame.Parent = screenGui

-- Título da seleção de modo
local modeTitle = Instance.new("TextLabel")
modeTitle.Size = UDim2.new(1, 0, 0.15, 0)
modeTitle.Position = UDim2.new(0, 0, 0.1, 0)
modeTitle.BackgroundTransparency = 1
modeTitle.Text = "Escolhe o número de jogadores"
modeTitle.TextSize = 48
modeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
modeTitle.Font = Enum.Font.GothamBold
modeTitle.ZIndex = 3
modeTitle.Parent = modeFrame

-- Função para criar botões de modo
local function createModeButton(text, position, players)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.15, 0, 0.1, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(76, 205, 196)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextSize = 28
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.ZIndex = 3
    
    button.MouseButton1Click:Connect(function()
        print("Iniciando jogo com " .. players .. " jogadores por time!")
        modeFrame.Visible = false
        menuFrame.Visible = false
        -- Aqui vais chamar a função de iniciar jogo
    end)
    
    button.Parent = modeFrame
    return button
end

-- Botões de modo
createModeButton("1v1", UDim2.new(0.1, 0, 0.35, 0), 1)
createModeButton("2v2", UDim2.new(0.27, 0, 0.35, 0), 2)
createModeButton("3v3", UDim2.new(0.44, 0, 0.35, 0), 3)
createModeButton("4v4", UDim2.new(0.61, 0, 0.35, 0), 4)
createModeButton("5v5", UDim2.new(0.78, 0, 0.35, 0), 5)

-- Botão voltar
local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0.15, 0, 0.08, 0)
backBtn.Position = UDim2.new(0.35, 0, 0.55, 0)
backBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
backBtn.BorderSizePixel = 0
backBtn.Text = "← VOLTAR"
backBtn.TextSize = 24
backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
backBtn.Font = Enum.Font.GothamBold
backBtn.ZIndex = 3

backBtn.MouseButton1Click:Connect(function()
    modeFrame.Visible = false
    menuFrame.Visible = true
end)

backBtn.Parent = modeFrame

-- =====================================================
-- FUNÇÕES GLOBAIS
-- =====================================================

function showModeSelection(mode)
    menuFrame.Visible = false
    modeFrame.Visible = true
end

function hideAllMenus()
    menuFrame.Visible = false
    modeFrame.Visible = false
end

print("MenuGui carregado!")
