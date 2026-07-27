-- =====================================================
-- ROBLOX EGG FOOTBALL - GAME MANAGER
-- Arquivo: ServerScriptService > GameManager
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variáveis do jogo
local gameRunning = false
local gameMode = "casual" -- casual, ranked, training
local timeLeft = 180 -- 3 minutos
local score = {team1 = 0, team2 = 0}
local maxGoals = 3

-- Criar instâncias de RemoteEvents para comunicação cliente-servidor
local gameEvents = Instance.new("Folder")
gameEvents.Name = "GameEvents"
gameEvents.Parent = ReplicatedStorage

local startGameEvent = Instance.new("RemoteEvent")
startGameEvent.Name = "StartGame"
startGameEvent.Parent = gameEvents

local updateScoreEvent = Instance.new("RemoteEvent")
updateScoreEvent.Name = "UpdateScore"
updateScoreEvent.Parent = gameEvents

local timerEvent = Instance.new("RemoteEvent")
timerEvent.Name = "UpdateTimer"
timerEvent.Parent = gameEvents

local endGameEvent = Instance.new("RemoteEvent")
endGameEvent.Name = "EndGame"
endGameEvent.Parent = gameEvents

-- Função para iniciar o jogo
local function startGame(mode, playersPerTeam)
    gameRunning = true
    gameMode = mode
    timeLeft = 180
    score = {team1 = 0, team2 = 0}
    
    -- Notificar todos os clientes
    startGameEvent:FireAllClients(mode, playersPerTeam)
end

-- Função para incrementar placar
local function scoreGoal(team)
    if team == 1 then
        score.team1 = score.team1 + 1
    else
        score.team2 = score.team2 + 1
    end
    
    -- Notificar clientes
    updateScoreEvent:FireAllClients(score.team1, score.team2)
    
    -- Verificar se alguém venceu
    if score.team1 >= maxGoals or score.team2 >= maxGoals then
        endGame()
    end
end

-- Função para terminar o jogo
local function endGame()
    gameRunning = false
    local winner = score.team1 > score.team2 and 1 or 2
    endGameEvent:FireAllClients(winner, score.team1, score.team2, gameMode)
end

-- Timer do jogo
local timerCoroutine = coroutine.create(function()
    while true do
        wait(1)
        if gameRunning then
            timeLeft = timeLeft - 1
            timerEvent:FireAllClients(timeLeft)
            
            if timeLeft <= 0 then
                endGame()
            end
        end
    end
end)

-- Listener para quando jogadores entram
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " entrou no jogo!")
end)

-- Iniciar timer
coroutine.resume(timerCoroutine)

-- Expor funções para outros scripts
_G.StartGame = startGame
_G.ScoreGoal = scoreGoal
_G.GameRunning = function() return gameRunning end
_G.GetScore = function() return score end
_G.GetTimeLeft = function() return timeLeft end
